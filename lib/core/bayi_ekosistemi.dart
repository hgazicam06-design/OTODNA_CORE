import 'package:cloud_firestore/cloud_firestore.dart';

class BayiEkosistemi {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. BAYİ ÇIKARINI KOLLAYAN İŞLEM MODELİ (GERÇEK FİNANS VE İSTİHBARAT)
  Future<void> islemBaslat({
    required String bayiId,
    required String bayiAdi,
    required double islemTutari
  }) async {
    double bayiPayi = 0;
    double gaziPayi = 0;

    // ⚙️ TİCARİ PROTOKOL: Murat Plaza %30, Diğer Bayiler %12 (Kâr + Vergi)
    if (bayiAdi == "Murat Plaza") {
      gaziPayi = islemTutari * 0.30;
      bayiPayi = islemTutari * 0.70;
    } else {
      gaziPayi = islemTutari * 0.12;
      bayiPayi = islemTutari * 0.88;
    }

    try {
      // Kuantum Defterine (Finansal Kayıtlara) İşlemi Yaz
      await _db.collection('finansal_islemler').add({
        "bayi_id": bayiId,
        "bayi_adi": bayiAdi,
        "toplam_tutar": islemTutari,
        "bayi_kazanci": bayiPayi,
        "sistem_kesintisi": gaziPayi, // Komutan Gazi Payı
        "tarih": FieldValue.serverTimestamp(),
      });

      // Bayinin cüzdan bakiyesini ve itibar puanını artır
      await _db.collection('bayiler').doc(bayiId).update({
        "toplam_kazanc": FieldValue.increment(bayiPayi),
        "itibar_puani": FieldValue.increment(10), // Dürüst işlem ödülü
        "son_islem_tarihi": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Kritik Finansal Hata: $e");
      throw Exception("Kuantum İşlem Başarısız: $e");
    }
  }

  // 2. ORTAK HAVUZDA GİZLİ ÜRÜN LİSTELEME (GİZLİLİK PROTOKOLÜ)
  Future<void> urunListele({
    required String asilSaticiId,
    required String asilSaticiAdi,
    required String urunAd,
    required double orijinalFiyat,
    required String kategori
  }) async {

    try {
      await _db.collection('yedek_parcalar').add({
        "isim": urunAd,
        "orijinal_fiyat": orijinalFiyat,
        "kategori": kategori,
        "asil_satici_id": asilSaticiId,
        "asil_satici_adi": asilSaticiAdi, // Arka planda paranın kime gideceği belli
        "satici_goster": false, // Vitrinde ASLA gösterilmez!
        "vitrin_etiketi": "Murat Plaza", // Herkes ürünleri Murat Plaza'nın sanacak
        "eklenme_tarihi": FieldValue.serverTimestamp(),
        "statu": "Aktif"
      });
    } catch (e) {
      print("Kritik Ürün Ekleme Hatası: $e");
    }
  }
}