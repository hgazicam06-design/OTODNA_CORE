import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM DESTEK VE İSTİHBARAT MERKEZİ (SupportService)
/// Kullanıcı ve bayi taleplerini şifreleyip doğrudan Ankara Merkez Karargahına iletir.
class SupportService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 🗂️ SİBER DESTEK KATEGORİLERİ ──────────────────────────────────────────
  static List<String> kategoriler = [
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
      developer.log("SİBER BİLGİ: [$kategori] kategorisinde yeni bir destek talebi şifreleniyor...");

      // 🛡️ SİBER KALKAN 1: Boş rapor gönderimi engellendi!
      if (mesaj.trim().isEmpty) {
        throw Exception("SİBER İHLAL: Boş bir istihbarat raporu Karargaha gönderilemez!");
      }

      // 🛡️ SİBER KALKAN 2: Kategori Manipülasyonu Engellendi!
      if (!kategoriler.contains(kategori)) {
        developer.log("SİBER İHLAL: Tanımlanmayan kategori tespit edildi -> $kategori");
        throw Exception("SİBER İHLAL: Sahte veya yetkisiz bir destek kategorisi seçilemez!");
      }

      // ⛓️ SİBER ZIRH: ATOMİK WRITEBATCH BAŞLATILDI
      WriteBatch batch = _db.batch();

      // 1. Bilet verisini Karargah veritabanına mühürle
      DocumentReference biletRef = _db.collection('destek_biletleri').doc();
      batch.set(biletRef, {
        'kullanici_id': userId, // Bileti kimin açtığı artık belli
        'kategori': kategori,
        'mesaj': mesaj.trim(),
        'durum': 'BEKLIYOR', // Karargah (Admin) henüz incelemedi
        'olusturulma_tarihi': FieldValue.serverTimestamp(),
        'hedef_merkez': 'ANK-MERKEZ', // Tüm biletlerin ana hedefi
      });

      // 2. Kara Kutuya (Sistem Logları) Alarm Sinyali Gönder
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'DESTEK_TALEBI',
        'islem_detayi': 'SİBER DESTEK: Bir kullanıcı "$kategori" kategorisinde merkeze yeni bir bilet açtı.',
        'birim': 'ANK-MERKEZ',
        'tarih': FieldValue.serverTimestamp(),
      });

      // Tüm Füzeleri Aynı Anda Ateşle!
      await batch.commit();

      developer.log("SİBER İLETİM: ✅ Destek bileti doğrudan Ankara Merkez Admin Paneline atomik olarak mühürlendi!");

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Destek bileti Karargaha iletilemedi!", error: e);
      throw Exception("SİSTEMSEL HATA: Destek talebiniz şu an iletilemiyor, lütfen Kuantum Ağınızı kontrol edin.");
    }
  }
}