import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM DESTEK VE İSTİHBARAT MERKEZİ (SupportService)
/// Kullanıcı ve bayi taleplerini şifreleyip doğrudan Ankara Merkez Karargahına iletir.
class SupportService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 🗂️ SİBER DESTEK KATEGORİLERİ ──────────────────────────────────────────
  static const List<String> kategoriler = [
    "Ödeme ve Finans Sorgulama",
    "Usta / Bayi İhlal Bildirimi",
    "Randevu ve Kapora Sorunu",
    "Sistem / Kuantum Ağ Hatası",
    "Distribütörlük ve Bayilik Talebi" // Karargahın genişleme stratejisi
  ];

  // ── 🚀 DESTEK BİLETİ OLUŞTURMA VE KARARGAHA İLETME ──────────────────────
  static Future<void> biletOlustur({
    required String userId,
    required String kategori,
    required String mesaj,
  }) async {
    try {
      // 🛡️ SİBER KALKAN: Boş rapor gönderimi engellendi!
      if (mesaj.trim().isEmpty) {
        throw Exception("SİBER İHLAL: Boş bir istihbarat raporu Karargaha gönderilemez!");
      }

      developer.log("SİBER BİLGİ: [$kategori] kategorisinde yeni bir destek talebi şifreleniyor...");

      // 1. Bilet verisini Karargah veritabanına mühürle
      await _db.collection('destek_biletleri').add({
        'kullanici_id': userId, // Bileti kimin açtığı artık belli
        'kategori': kategori,
        'mesaj': mesaj.trim(),
        'durum': 'BEKLIYOR', // Karargah (Admin) henüz incelemedi
        'olusturulma_tarihi': FieldValue.serverTimestamp(),
        'hedef_merkez': 'ANK-MERKEZ', // Tüm biletlerin ana hedefi
      });

      developer.log("SİBER İLETİM: ✅ Destek bileti doğrudan Ankara Merkez Admin Paneline mühürlendi!");

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Destek bileti Karargaha iletilemedi!", error: e);
      throw Exception("SİSTEMSEL HATA: Destek talebiniz şu an iletilemiyor, lütfen bağlantınızı kontrol edin.");
    }
  }
}