import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 🛡️ KUANTUM EKSPERTİZ MÜHÜR SERVİSİ (İkili Doğrulama / Two-Sided Sealing)
/// Usta testleri bitirdiğinde Rapor "Müşteri Onayına (Beklemede)" düşer.
/// Müşteri kendi ekranından görüp "ONAYLA" dediğinde İki Anahtar birleşir, 
/// GPS mühürleri atılır ve Yapay Zeka OtoDNA Skorunu hesaplayıp veriyi kilitler.
class EkspertizMuhurServisi {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // =======================================================================
  // 1. ADIM: USTA ANAHTARI (TASLAK OLUŞTURMA VE ONAYA GÖNDERME)
  // =======================================================================
  
  /// Ustanın rapor taslağını oluşturup Müşterinin onayına gönderdiği aşama.
  /// Burada veri Kuantum Ağı'na asıl veri (Immutable) olarak YAZILMAZ. Sadece taslaktır.
  Future<Map<String, dynamic>> ustaOnayinaGonder({
    required String saseNo,
    required Map<String, String> testSonuclari,
    required String aracCinsi,
    required String yakitTipi,
  }) async {
    try {
      String ustaUid = _auth.currentUser?.uid ?? 'BILINMEYEN_USTA_UID';
      GeoPoint ustaMühürKonumu = const GeoPoint(40.7634, 29.9248); // Örn: Tarcanlar Kocaeli Merkez

      // Rapor Taslağını "arac_dna_raporlari" koleksiyonuna "bekliyor" durumuyla at
      DocumentReference raporRef = _db.collection('arac_dna_raporlari').doc();
      
      await raporRef.set({
        'saseNo': saseNo,
        'ustaUid': ustaUid,
        'aracCinsi': aracCinsi,
        'yakitTipi': yakitTipi,
        'hamTestVerisi': testSonuclari,
        'ustaMühürKonumu': ustaMühürKonumu, // Ustanın Konumu
        'taslakTarihi': FieldValue.serverTimestamp(),
        'durum': 'musteri_onayi_bekliyor', // İkinci Anahtar Bekleniyor
        'isImmutable': false // Hala değiştirilebilir (Müşteri itiraz edebilir)
      });

      // Aracın sahibine bildirim düşmesi için araca taslak bildirimi at
      await _db.collection('araclar').doc(saseNo).set({
        'bekleyenRaporId': raporRef.id,
      }, SetOptions(merge: true));

      return {
        'basarili': true,
        'mesaj': 'Rapor taslağı oluşturuldu. Müşteri onayı bekleniyor.',
      };
    } catch (e) {
      return {
        'basarili': false,
        'mesaj': 'Taslak Oluşturma Hatası: $e',
      };
    }
  }

  // =======================================================================
  // 2. ADIM: MÜŞTERİ ANAHTARI (İKİNCİ ONAY VE KUANTUM KİLİDİ)
  // =======================================================================

  /// Müşterinin kendi telefonundan uygulamayı açıp Raporu okuduğu ve 
  /// "Onayla" dediği an çalışan devasa kilit motoru.
  Future<Map<String, dynamic>> musteriOnaylaVeMuhrle(String raporId, String musteriUid, String saseNo) async {
    try {
      DocumentReference raporRef = _db.collection('arac_dna_raporlari').doc(raporId);
      DocumentReference aracRef = _db.collection('araclar').doc(saseNo);
      
      GeoPoint musteriMühürKonumu = const GeoPoint(40.7630, 29.9240); // Müşterinin o anki konumu

      // Atomik İşlem (WriteBatch): Veriler yarım kalamaz.
      await _db.runTransaction((transaction) async {
        DocumentSnapshot raporSnap = await transaction.get(raporRef);
        if (!raporSnap.exists) throw Exception("Rapor bulunamadı.");
        
        Map<String, dynamic> raporData = raporSnap.data() as Map<String, dynamic>;
        
        if (raporData['durum'] != 'musteri_onayi_bekliyor') {
          throw Exception("Bu rapor zaten kilitlenmiş veya iptal edilmiş.");
        }

        Map<String, String> testler = Map<String, String>.from(raporData['hamTestVerisi'] ?? {});

        // AI (YAPAY ZEKA) DNA SKORU HESAPLAMASI BURADA YAPILIR (İki anahtar birleşince)
        int yeniDnaSkoru = _yapayZekaDnaSkoruHesapla(testler);
        String genelDurum = yeniDnaSkoru >= 80 ? 'Kusursuz' : (yeniDnaSkoru >= 50 ? 'Bakım Gerekli' : 'Riskli / Ağır Hasarlı');

        // RAPORU SONSUZA KADAR KİLİTLE (IMMUTABLE)
        transaction.update(raporRef, {
          'durum': 'muhurlendi',
          'musteriUid': musteriUid,
          'musteriMühürKonumu': musteriMühürKonumu, // İkinci Anahtarın Konumu
          'muhurZamani': FieldValue.serverTimestamp(), // Ortak Kilit Saati
          'yapayZekaSkoru': yeniDnaSkoru,
          'isImmutable': true // BİR DAHA ASLA DEĞİŞTİRİLEMEZ
        });

        // ARACIN KÜNYESİNİ GÜNCELLE
        transaction.set(aracRef, {
          'dnaSkoru': yeniDnaSkoru,
          'genelDurum': genelDurum,
          'sonEkspertizTarihi': FieldValue.serverTimestamp(),
          'aktifRaporId': raporId,
          'bekleyenRaporId': FieldValue.delete() // Bekleyen raporu sil
        }, SetOptions(merge: true));
      });

      return {
        'basarili': true,
        'mesaj': 'SİBER MÜHÜR VURULDU! Araç Raporu kilitlendi.',
      };
    } catch (e) {
      return {
        'basarili': false,
        'mesaj': 'Mühürleme Hatası: $e',
      };
    }
  }

  // =======================================================================
  // AI: YAPAY ZEKA VERİ İŞLEME MOTORU
  // =======================================================================
  int _yapayZekaDnaSkoruHesapla(Map<String, String> testler) {
    int baslangicSkoru = 100;
    
    // Ağır Kritik Parçalar
    List<String> agirKusurlar = [
      "Şase Direkleri, Podye ve Alt Takım",
      "Motor Bloğu & Yağ/Sıvı Kaçakları",
      "Yüksek Voltaj Batarya Sağlığı (%SOH)", 
      "Kaporta, Boya Değişen ve Mikron Ölçümü"
    ];

    testler.forEach((modulAdi, durum) {
      if (durum == 'riskli') {
        if (agirKusurlar.contains(modulAdi)) {
          baslangicSkoru -= 20; // Hayati parça
        } else {
          baslangicSkoru -= 5; // Normal parça
        }
      }
    });

    if (baslangicSkoru < 0) baslangicSkoru = 0;
    if (baslangicSkoru > 100) baslangicSkoru = 100;

    return baslangicSkoru;
  }
}