import 'package:cloud_firestore/cloud_firestore.dart';

/// 🛡️ OTODNA BAYİ VE FİNANSAL YÖNETİM MERKEZİ
/// Tüm bayiler için %12 (10+2) komisyon protokolü burada işletilir.
class BayiEkosistemi {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- 1. BAYİ İŞLEM MOTORU (EŞİTLİK VE ADALET PROTOKOLÜ) ---
  Future<void> islemBaslat({
    required String bayiId,
    required String bayiAdi,
    required double islemTutari, // Müşterinin ödediği nihai (KDV Dahil) tutar
  }) async {
    // 🔥 SİBER KURAL: Tüm bayiler için net %12 OtoDNA payı kesilir.
    double gaziPayi = islemTutari * 0.12;
    double bayiHakedis = islemTutari - gaziPayi;

    try {
      // ⛓️ SİBER ZIRH: Atomik WriteBatch Başlatıldı
      WriteBatch batch = _db.batch();

      // Kuantum Defterine (Finansal Kayıtlara) İşlemi Mühürle
      DocumentReference finansRef = _db.collection('finansal_islemler').doc();
      batch.set(finansRef, {
        "bayi_id": bayiId,
        "bayi_adi": bayiAdi,
        "toplam_tutar": islemTutari,
        "bayi_hesabina_yatacak": bayiHakedis,
        "otodna_kesintisi": gaziPayi, // Komutan Gazi Payı (%12)
        "tarih": FieldValue.serverTimestamp(),
        "islem_statu": "Tamamlandı",
      });

      // Bayinin Cüzdan Bakiyesini ve İtibar Puanını Kuantum Seviyesinde Güncelle
      DocumentReference bayiRef = _db.collection('bayiler').doc(bayiId);
      batch.update(bayiRef, {
        "toplam_kazanc": FieldValue.increment(bayiHakedis),
        "itibar_puani": FieldValue.increment(10), // Her dürüst işlem +10 Puan
        "son_islem_tarihi": FieldValue.serverTimestamp(),
      });

      // Füzeleri aynı anda ateşle!
      await batch.commit();

    } catch (e) {
      // Karargahın Kara Kutusuna (Sistem Logları) Hatayı Raporla
      await _db.collection('sistem_loglari').add({
        'islem_turu': 'KRITIK_HATA',
        'islem_detayi': 'FİNANSAL MOTOR ARIZASI: $bayiAdi işlemi başarısız! Hata: $e',
        'tarih': FieldValue.serverTimestamp(),
      });
    }
  }

  // --- 2. ŞEFFAF ÜRÜN LİSTELEME MOTORU (VİTRİN PROTOKOLÜ) ---
  Future<void> urunListele({
    required String saticiId,
    required String saticiAdi,
    required String urunAd,
    required double girilenFiyat,
    required bool kdvDahilMi, // UI'dan gelen KDV tercihi
    required String kategori
  }) async {
    try {
      // ⚙️ KDV HESAPLAMA: Hariç girildiyse %20 KDV ekle
      double satisFiyati = kdvDahilMi ? girilenFiyat : girilenFiyat * 1.20;

      // ⚙️ OTODNA PAYI: Satış anında kesilecek olan %12 pay
      double otodnaBedeli = satisFiyati * 0.12;

      // Satıcıya kalacak olan net tutar
      double netKazanc = satisFiyati - otodnaBedeli;

      // Ürünü Kuantum Vitrinine (Yedek Parçalar) Ekle
      await _db.collection('yedek_parcalar').add({
        "isim": urunAd,
        "kategori": kategori,
        "ham_fiyat": girilenFiyat,
        "kdv_dahil_mi": kdvDahilMi,
        "satis_fiyati": satisFiyati, // Müşterinin göreceği son fiyat
        "otodna_komisyonu": otodnaBedeli,
        "saticiya_yatacak_tutar": netKazanc,
        "satici_id": saticiId,
        "satici_adi": saticiAdi, // 🔥 ARTIK HERKES KENDİ İSMİYLE SAHADA!
        "eklenme_tarihi": FieldValue.serverTimestamp(),
        "statu": "Aktif",
        "stok_durumu": true
      });

    } catch (e) {
      await _db.collection('sistem_loglari').add({
        'islem_turu': 'HATA',
        'islem_detayi': 'VİTRİN ARIZASI: $urunAd listelenemedi! Hata: $e',
        'tarih': FieldValue.serverTimestamp(),
      });
    }
  }
}