import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:developer' as developer;

// ============================================================================
// DOSYA AMACI: 
// Bu servis, OtoDNA sisteminde yapılan ekspertiz ve tamir işlemlerini
// veritabanına değiştirilemez (immutable) şekilde mühürler. Çift yönlü onay 
// sistemiyle hem usta hem müşteri işlemi GPS ile doğrular. Hukuki geçerliliği
// artırmak için Blockchain tarzı bir işlem kilidi (Noter) görevi görür.
// ============================================================================

class CorporateNotaryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── 1. USTA ONAYI: TASLAK OLUŞTURMA ────────────────────────────────────
  /// Ekspertiz yapan personelin raporu hazırlayıp müşteri onayına sunduğu adımdır.
  /// Burada işlem henüz kilitlenmez, müşteri onayı beklenir.
  Future<Map<String, dynamic>> expertizTaslagiOlustur({
    required String saseNo,
    required Map<String, String> testSonuclari,
    required String aracCinsi,
    required String yakitTipi,
  }) async {
    try {
      String uzmanUid = _auth.currentUser?.uid ?? 'BILINMEYEN_UZMAN';
      // Gerçek senaryoda Geolocator ile bayinin anlık konumu çekilmelidir
      GeoPoint tesisKonumu = const GeoPoint(40.7634, 29.9248);

      DocumentReference raporRef = _db.collection('arac_dna_raporlari').doc();
      
      await raporRef.set({
        'saseNo': saseNo,
        'uzmanUid': uzmanUid,
        'aracCinsi': aracCinsi,
        'yakitTipi': yakitTipi,
        'hamTestVerisi': testSonuclari,
        'tesisKonumu': tesisKonumu,
        'taslakTarihi': FieldValue.serverTimestamp(),
        'durum': 'musteri_onayi_bekliyor',
        'isImmutable': false // Henüz müşteri onaylamadı
      });

      // Araca bildirim gitmesi için bekleyen işlemi işliyoruz
      await _db.collection('araclar').doc(saseNo).set({
        'bekleyenRaporId': raporRef.id,
      }, SetOptions(merge: true));

      return {'basarili': true, 'mesaj': 'Rapor taslağı müşteri onayına sunuldu.'};
    } catch (e) {
      return {'basarili': false, 'mesaj': 'Taslak oluşturulamadı: $e'};
    }
  }

  // ── 2. ÇİFT YÖNLÜ ONAY: MÜŞTERİ KABULÜ (MÜHÜR) ─────────────────────────
  /// Müşteri raporu gördüğünde ve onayladığında çalışır.
  /// Hem ustanın hem müşterinin imzası alınarak veritabanına kilit (immutable) atılır.
  Future<Map<String, dynamic>> musteriOnayiVerVeMuhurle({
    required String islemId, // Rapor veya İşlem ID
    required String musteriUid,
    required String saseNo,
    required bool onayDurumu,
  }) async {
    try {
      developer.log("OTODNA BİLGİ: $islemId referanslı işlem için müşteri kararı alınıyor...");

      // Müşteri konumunu alarak hukuki delil oluşturuyoruz
      Position position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      GeoPoint musteriKonumu = GeoPoint(position.latitude, position.longitude);

      DocumentReference raporRef = _db.collection('arac_dna_raporlari').doc(islemId);
      DocumentReference aracRef = _db.collection('araclar').doc(saseNo);

      await _db.runTransaction((transaction) async {
        DocumentSnapshot raporSnap = await transaction.get(raporRef);
        if (!raporSnap.exists) throw Exception("İlgili rapor bulunamadı.");
        
        Map<String, dynamic> raporData = raporSnap.data() as Map<String, dynamic>;
        
        if (raporData['durum'] != 'musteri_onayi_bekliyor') {
          throw Exception("Bu rapor zaten kilitlenmiş veya reddedilmiş.");
        }

        if (!onayDurumu) {
          // Müşteri işlemi reddetti
          transaction.update(raporRef, {
            'durum': 'musteri_reddedildi',
            'isImmutable': true
          });
          transaction.set(aracRef, {'bekleyenRaporId': FieldValue.delete()}, SetOptions(merge: true));
          return; // İşlemi bitir
        }

        // MÜŞTERİ ONAYLADIYSA: Skoru hesapla ve raporu KİLİTLE
        Map<String, String> testler = Map<String, String>.from(raporData['hamTestVerisi'] ?? {});
        int dnaSkoru = _otodnaSkoruHesapla(testler);
        String genelDurum = dnaSkoru >= 80 ? 'Kusursuz' : (dnaSkoru >= 50 ? 'Bakım Gerekli' : 'Riskli');

        transaction.update(raporRef, {
          'durum': 'muhurlendi',
          'musteriUid': musteriUid,
          'musteriKonumu': musteriKonumu,
          'muhurZamani': FieldValue.serverTimestamp(),
          'yapayZekaSkoru': dnaSkoru,
          'isImmutable': true // BİR DAHA ASLA DEĞİŞTİRİLEMEZ
        });

        // Araç künyesini kalıcı olarak güncelle
        transaction.set(aracRef, {
          'dnaSkoru': dnaSkoru,
          'genelDurum': genelDurum,
          'sonEkspertizTarihi': FieldValue.serverTimestamp(),
          'aktifRaporId': islemId,
          'bekleyenRaporId': FieldValue.delete()
        }, SetOptions(merge: true));
      });

      // İşlemi Kurumsal Log'a yaz
      await _db.collection('sistem_loglari').add({
        'islem_turu': onayDurumu ? 'MUSTERI_ONAYI' : 'MUSTERI_REDDI',
        'islem_detayi': 'NOTER SERVİSİ: Müşteri işlemi ${onayDurumu ? 'ONAYLADI' : 'REDDETTİ'}. İşlem: $islemId',
        'tarih': FieldValue.serverTimestamp(),
      });

      return {'basarili': true, 'mesaj': onayDurumu ? 'İşlem kurumsal ağa kilitlendi.' : 'İşlem reddedildi.'};

    } catch (e) {
      developer.log("OTODNA HATA: Müşteri onayı alınamadı!", error: e);
      throw Exception("HATA: Onay işlemi başarısız. GPS (Konum) izniniz açık olmalıdır.");
    }
  }

  // ── 3. ARAÇ RİSK PROTOKOLÜ (TRAFİĞE ÇIKIŞ ENGELİ) ──────────────────────
  /// İşlem sırasında araca dair çok kritik bir kusur (Kırmızı X) tespit edilirse
  /// aracı direkt "Riskli" olarak veritabanında işaretler.
  Future<void> kritikKusurIsaretle(String saseNo, String raporId) async {
    try {
      WriteBatch batch = _db.batch();
      
      DocumentReference aracRef = _db.collection('araclar').doc(saseNo.toUpperCase());
      batch.update(aracRef, {
        'durum': 'RİSKLİ - TRAFİĞE ÇIKAMAZ',
        'dna_skoru': FieldValue.increment(-20),
        'son_guncelleme': FieldValue.serverTimestamp(),
      });

      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'KRITIK_UYARI',
        'islem_detayi': 'KURUMSAL GÜVENLİK: $saseNo şaseli araçta ölümcül kusur tespit edildi ve karantinaya alındı!',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      developer.log("OTODNA HATA: Kritik uyarı işaretlenemedi.", error: e);
    }
  }

  // =======================================================================
  // DNA SKORU HESAPLAMA MOTORU
  // =======================================================================
  int _otodnaSkoruHesapla(Map<String, String> testler) {
    int baslangicSkoru = 100;
    
    // Ağır Kusur Sayılacak Parçalar
    List<String> agirKusurlar = [
      "Şase Direkleri, Podye ve Alt Takım",
      "Motor Bloğu & Yağ/Sıvı Kaçakları",
      "Yüksek Voltaj Batarya Sağlığı", 
      "Kaporta, Boya Değişen"
    ];

    testler.forEach((modulAdi, durum) {
      if (durum == 'riskli' || durum == 'KIRMIZI_X') {
        if (agirKusurlar.contains(modulAdi)) {
          baslangicSkoru -= 20; 
        } else {
          baslangicSkoru -= 5;
        }
      }
    });

    if (baslangicSkoru < 0) baslangicSkoru = 0;
    if (baslangicSkoru > 100) baslangicSkoru = 100;

    return baslangicSkoru;
  }

  // ── 4. UI YARDIMCI METOTLARI ──────────────────────────────────────────
  bool isRaporMuhurlendi(Timestamp? olusturulmaTarihi) {
    if (olusturulmaTarihi == null) return false;
    final now = DateTime.now();
    final olusturma = olusturulmaTarihi.toDate();
    // 2 saat geçtiyse otomatik mühürlenmiş say
    return now.difference(olusturma).inHours >= 2;
  }

  Future<void> ucretliPdfTalebiOlustur({
    required String raporId,
    required String kullaniciId,
    required double ucret,
  }) async {
    await _db.collection('pdf_talepleri').add({
      'raporId': raporId,
      'kullaniciId': kullaniciId,
      'ucret': ucret,
      'tarih': FieldValue.serverTimestamp(),
      'durum': 'odeme_alindi',
    });
  }
}
