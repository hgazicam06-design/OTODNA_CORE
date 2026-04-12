import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM DİSTRİBÜTÖR VE MERKEZ YÖNETİM MOTORU (DistributorService)
/// Ankara Merkez (Ana Karargah) yetkisiyle yeni bayileri onaylar, il ve İLÇE bazlı atamaları mühürler.
class DistributorService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 🏢 1. YENİ BAYİ YETKİLENDİRME (ANKARA MERKEZ ONAYI) ───────────────
  static Future<void> authorizeNewDealer({
    required String dealerId,
    required String il,
    required String ilce, // 🚀 İSTİHBARAT GELİŞTİRİLDİ: İlçe Eklendi!
  }) async {
    try {
      developer.log("SİBER RADAR: Ankara Merkez İstihbaratı $il / $ilce bölgesi için bayi onayı başlatıyor...");

      // ⛓️ ATOMİK ZIRH: WriteBatch Başlatıldı
      WriteBatch batch = _db.batch();

      // 1. Bayinin Yetki Mührünü Veritabanına Çak
      DocumentReference bayiRef = _db.collection('bayiler').doc(dealerId);
      batch.update(bayiRef, {
        'yetki_durumu': 'ONAYLANDI',
        'il': il.trim().toUpperCase(),
        'ilce': ilce.trim().toUpperCase(), // Kuantum Standardı (Büyük Harf)
        'onay_tarihi': FieldValue.serverTimestamp(),
        'onaylayan_merkez': 'ANK-MERKEZ',
      });

      // 2. Kara Kutuya (Sistem Logları) Yetkilendirmeyi Mühürle
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'YENI_BAYI_ONAYI',
        'islem_detayi': 'SİBER ONAY: $dealerId ID\'li bayi $il / $ilce bölgesinde Ankara Merkez tarafından yetkilendirildi.',
        'birim': 'ANK-MERKEZ',
        'tarih': FieldValue.serverTimestamp(),
      });

      // Füzeleri Ateşle!
      await batch.commit();

      developer.log("SİBER ONAY: ✅ $il - $ilce bölgesindeki $dealerId nolu bayiye Karargah yetkisi mühürlendi!");

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Bayi yetkilendirmesi başarısız!", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ: UI'a Kırmızı Alarm Fırlat!
      throw Exception("KARARGAH HATASI: Bayi yetkisi mühürlenemedi. Lütfen Kuantum Ağınızı kontrol edin!");
    }
  }

  // ── 📊 2. BÖLGE BAZLI SİBER PERFORMANS RADARI ──────────────────────────
  static Future<Map<String, dynamic>> getRegionPerformance(String regionName) async {
    try {
      developer.log("SİBER RADAR: $regionName bölgesi için performans ve hacim verileri taranıyor...");

      // 🚀 MAKET İMHA EDİLDİ: Gerçek Firestore İstihbarat Sorgusu!
      QuerySnapshot bayiler = await _db.collection('bayiler')
          .where('bolge', isEqualTo: regionName.trim().toUpperCase())
          .where('yetki_durumu', isEqualTo: 'ONAYLANDI')
          .get();

      int aktifBayiSayisi = bayiler.docs.length;

      developer.log("SİBER İSTİHBARAT: $regionName bölgesinde $aktifBayiSayisi aktif bayi tespit edildi.");

      return {
        'bolge': regionName,
        'aktif_bayi_sayisi': aktifBayiSayisi,
        'rapor_tarihi': DateTime.now().toIso8601String(),
      };

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Bölge performansı hesaplanamadı!", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ
      throw Exception("İSTİHBARAT HATASI: Bölge verileri Karargahtan çekilemedi!");
    }
  }
}