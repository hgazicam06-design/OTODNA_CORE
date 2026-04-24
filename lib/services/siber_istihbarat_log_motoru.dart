import 'package:cloud_firestore/cloud_firestore.dart';

class SiberIstihbaratLogMotoru {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Karargah'ın "Her Şeyi Gören Göz" Fonksiyonu
  /// [kategori]: FINANS, GUVENLIK, KULLANICI, BAYI, YAPAY_ZEKA
  static Future<void> kayitDus({
    required String kategori,
    required String islemBasligi,
    required String detay,
    required String failId,
    required String failAdi,
  }) async {
    try {
      await _db.collection('siber_istihbarat_loglari').add({
        'kategori': kategori,
        'islem_basligi': islemBasligi,
        'detay': detay,
        'fail_id': failId,
        'fail_adi': failAdi,
        'tarih': FieldValue.serverTimestamp(),
      });
      // Not: Performans için WriteBatch veya Asenkron background task olarak bırakılır.
      // Sistemin geri kalanını bloklamaması için await kullanılsa da ana thread'i yormaz.
    } catch (e) {
      print("SİBER İSTİHBARAT ÇÖKTÜ: Log yazılamadı -> $e");
    }
  }

  // --- KISA YOLLAR ---
  static void logFinans(String islem, String detay, String failId, String failAdi) {
    kayitDus(kategori: 'FINANS', islemBasligi: islem, detay: detay, failId: failId, failAdi: failAdi);
  }

  static void logGuvenlik(String islem, String detay, String failId, String failAdi) {
    kayitDus(kategori: 'GUVENLIK', islemBasligi: islem, detay: detay, failId: failId, failAdi: failAdi);
  }

  static void logKullanici(String islem, String detay, String failId, String failAdi) {
    kayitDus(kategori: 'KULLANICI', islemBasligi: islem, detay: detay, failId: failId, failAdi: failAdi);
  }
}
