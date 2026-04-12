import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM ANKARA MERKEZ KONTROL SİSTEMİ (CentralManagementService)
/// 81 İl ve 7 Bölgedeki tüm bayileri denetler, Karargah kurallarına uymayanları Kara Listeye (Blacklist) alır.
class CentralManagementService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 🌍 1. CANLI BAYİ RADARI (MAKET YIKILDI) ──────────────────────────────
  static Future<List<Map<String, dynamic>>> tumBayileriGetir() async {
    try {
      developer.log("SİBER RADAR: Ankara Merkez İstihbaratı 81 ildeki bayileri tarıyor...");

      // Karargah kayıtlarındaki tüm bayileri otonom olarak çeker
      QuerySnapshot snapshot = await _db.collection('bayiler').get();

      if (snapshot.docs.isEmpty) {
        developer.log("SİBER UYARI: Kuantum Ağında kayıtlı bayi bulunamadı!");
        return [];
      }

      List<Map<String, dynamic>> bayiler = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Kuantum Kimliğini veriye göm
        return data;
      }).toList();

      developer.log("SİBER İSTİHBARAT: ${bayiler.length} adet bayi radara takıldı.");
      return bayiler;

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Merkez radar sistemi arızalandı!", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ: Arayüze kırmızı alarm fırlatılır.
      throw Exception("SİSTEMSEL HATA: Bayi listesi Karargahtan çekilemedi. Bağlantınızı kontrol edin!");
    }
  }

  // ── 🛑 2. ACIMASIZ SİBER YARGI (KARA LİSTE / BLACKLIST) ─────────────────
  /// Firmayı 1 yıldıza düşürür, Siyah Yıldız cezasını keser ve sistemi kilitler.
  static Future<void> blacklistDealer({
    required String bayiId,
    required String bayiAdi
  }) async {
    try {
      developer.log("SİBER YARGI: $bayiAdi firması için İDAM PROTOKOLÜ (Blacklist) başlatıldı!");

      // ⛓️ ATOMİK ZIRH: WriteBatch Başlatıldı
      WriteBatch batch = _db.batch();

      // 1. Bayinin DNA'sını Kirlet ve Kilitle (Siyah Yıldız Çak)
      DocumentReference bayiRef = _db.collection('bayiler').doc(bayiId);
      batch.update(bayiRef, {
        'rating': 1, // 1 Yıldız / Siyah Yıldız (Black Star) Karargah Kuralı
        'status': 'Engellendi', // Karargah kapılarını kapattı
        'blacklist_tarihi': FieldValue.serverTimestamp(),
      });

      // 2. Kara Kutuya (Sistem Logları) İdamı Mühürle
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'BLACKLIST_CEZASI',
        'islem_detayi': 'SİBER İHLAL: $bayiAdi firması çok sayıda negatif yorum/ihlal nedeniyle KARA LİSTEYE alındı!',
        'birim': 'ANK-MERKEZ',
        'tarih': FieldValue.serverTimestamp(),
      });

      // Füzeleri Ateşle!
      await batch.commit();

      developer.log("SİBER ONAY: 🛑 OtoDNA UYARI: $bayiAdi firması acımasızca BLACKLIST'e alındı ve ağdan tecrit edildi!");

    } catch (e) {
      developer.log("SİBER İHLAL: Kara Liste cezası mühürlenemedi!", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ
      throw Exception("YARGI MOTORU ARIZASI: Firmanın cezası kesilemedi! Kuantum Ağına erişilemiyor.");
    }
  }
}