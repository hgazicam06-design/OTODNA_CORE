import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

// ============================================================================
// DOSYA AMACI: 
// Bu servis, Türkiye genelindeki 81 ilin bayi istihbaratını, ciro durumunu
// ve bayilerin güvenilirlik seviyelerini analiz eder. Aynı zamanda bölge
// yöneticilerinin (eski adıyla Bölge Komutanı) atanması ve görevden alınması
// ile riskli bayilerin sistemden uzaklaştırılması işlemlerini yönetir.
// ============================================================================

class BolgeYoneticisi {
  final String id;
  final String isim;
  final String sorumluOlduguBolge;
  final String rutbe;

  BolgeYoneticisi({
    required this.id,
    required this.isim,
    required this.sorumluOlduguBolge,
    required this.rutbe,
  });

  Map<String, dynamic> toMap() {
    return {
      'isim': isim,
      'sorumlu_bolge': sorumluOlduguBolge,
      'rutbe': rutbe,
      'atanma_tarihi': FieldValue.serverTimestamp(),
      'yetki_seviyesi': 2,
      'aktif': true,
    };
  }
}

class CorporateRegionManager {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Belirli bir şehrin detaylı analizini yapar.
  /// O şehirdeki bayilerin cirolarını hesaplar, şikayeti yüksek olan
  /// riskli bayileri listeler ve Kurumsal Hizmet Payını (%12) çıkarır.
  Future<Map<String, dynamic>> ilAnaliziYap(String sehir) async {
    try {
      developer.log("OTODNA BİLGİ: $sehir için Bölge Analizi başlatıldı...");

      // Şehirdeki aktif bayileri çekiyoruz
      final querySnapshot = await _db
          .collection('bayiler')
          .where('il', isEqualTo: sehir)
          .where('aktif_mi', isEqualTo: true)
          .get();

      double sehirToplamCiro = 0.0;
      int kritikBayiSayisi = 0;
      List<Map<String, dynamic>> riskliBayiler = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        
        // Ciro hesaplama (Hem aylik_ciro hem de toplam_kazanc alanlarına bakar)
        double bayiCiro = (data['aylik_ciro'] ?? data['toplam_kazanc'] ?? 0).toDouble();
        sehirToplamCiro += bayiCiro;

        // İtibar Analizi (Şikayet 5'ten fazlaysa veya Yıldız 1'e düştüyse risklidir)
        int sikayet = data['sikayet_sayisi'] ?? 0;
        int yildiz = data['yildiz_puani'] ?? 5;
        
        if (sikayet >= 5 || yildiz <= 1) {
          kritikBayiSayisi++;
          riskliBayiler.add({
            'firma_adi': data['firma_adi'] ?? 'Gizli Bayi',
            'sikayet': sikayet,
            'id': doc.id
          });
        }
      }

      return {
        'basarili': true,
        'sehir': sehir,
        'aktif_bayi_sayisi': querySnapshot.docs.length,
        'toplam_ciro': sehirToplamCiro,
        'kurumsal_pay': sehirToplamCiro * 0.12, // Kurumsal Hizmet Bedeli
        'kritik_bayi_sayisi': kritikBayiSayisi,
        'riskli_bayiler': riskliBayiler,
      };
    } catch (e) {
      developer.log("OTODNA HATA: Bölge analizi yapılamadı!", error: e);
      throw Exception("Bölge taraması başarısız. Lütfen bağlantınızı kontrol edin.");
    }
  }

  /// Bir bayinin durumunu Karaliste'ye alır (Sistemi Dondurur) veya tekrar Aktif eder.
  /// İşlem veritabanında ACID (WriteBatch) kullanılarak güvenlikli yapılır.
  Future<void> bayiDurumunuGuncelle(String bayiId, bool karaListe) async {
    try {
      WriteBatch batch = _db.batch();

      DocumentReference bayiRef = _db.collection('bayiler').doc(bayiId);
      batch.update(bayiRef, {
        'is_active': !karaListe,
        'aktif_mi': !karaListe,
        'status': karaListe ? 'BLACKLIST' : 'ACTIVE',
        'last_update': FieldValue.serverTimestamp(),
      });

      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': karaListe ? 'BAYİ_DONDURULDU' : 'BAYİ_AKTİF_EDİLDİ',
        'islem_detayi': 'KURUMSAL KARAR: $bayiId numaralı bayinin erişim durumu güncellendi.',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      developer.log("OTODNA BİLGİ: Bayi ($bayiId) kara liste durumu: $karaListe");
    } catch (e) {
      developer.log("OTODNA HATA: Karaliste işlemi başarısız!", error: e);
      throw Exception("Bayi erişim durumu güncellenemedi.");
    }
  }

  /// Bir kullanıcıyı belirli bir bölgenin "Bölge Yöneticisi" olarak atar.
  Future<void> bolgeYoneticisiAta({
    required String kullaniciId,
    required String isim,
    required String bolge
  }) async {
    try {
      WriteBatch batch = _db.batch();

      // 1. Kullanıcı rolünü yükselt
      DocumentReference userRef = _db.collection('kullanicilar').doc(kullaniciId);
      batch.set(userRef, {
        'rol': 'bolge_yoneticisi',
        'sorumlu_bolge': bolge,
        'rutbe_guncelleme_tarihi': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 2. Yöneticiler Listesine Ekle
      BolgeYoneticisi yeni = BolgeYoneticisi(
        id: kullaniciId,
        isim: isim,
        sorumluOlduguBolge: bolge,
        rutbe: 'Bölge Yöneticisi',
      );
      DocumentReference yoneticiRef = _db.collection('bolge_yoneticileri').doc(kullaniciId);
      batch.set(yoneticiRef, yeni.toMap());

      // 3. Logla
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'ATAMA_BASARILI',
        'islem_detayi': 'KURUMSAL ATAMA: $isim, $bolge yöneticisi olarak atandı.',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      throw Exception("Atama işlemi başarısız oldu.");
    }
  }

  /// Mevcut bir bölge yöneticisini görevden alır ve yetkilerini sıfırlar.
  Future<void> yoneticiliktenIhracEt(String kullaniciId, String isim) async {
    try {
      WriteBatch batch = _db.batch();

      batch.update(_db.collection('kullanicilar').doc(kullaniciId), {
        'rol': 'kullanici',
        'sorumlu_bolge': FieldValue.delete(),
      });

      batch.update(_db.collection('bolge_yoneticileri').doc(kullaniciId), {
        'aktif': false,
        'gorevden_alinma_tarihi': FieldValue.serverTimestamp(),
      });

      batch.set(_db.collection('sistem_loglari').doc(), {
        'islem_turu': 'IHRAC_EDILDI',
        'islem_detayi': 'KURUMSAL İHRAÇ: $isim adlı yöneticinin yetkileri sıfırlandı.',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      throw Exception("Personel yetkileri sıfırlanamadı.");
    }
  }
}
