import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM ADALET KİLİDİ VE YORUM MOTORU (ReviewService)
/// Sahte yorumları engeller, kötü niyetli bayileri otonom olarak Siyah Yıldız (Blacklist) ile cezalandırır.
class ReviewService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 🔒 1. SİBER YORUM YETKİSİ SORGULAMASI (MAKET YIKILDI) ───────────────
  static Future<bool> yorumYetkisiDogrula({
    required String musteriId,
    required String bayiId,
  }) async {
    try {
      developer.log("SİBER RADAR: Kullanıcı ($musteriId) için adalet kilidi taranıyor...");

      // Kuantum Ağı Kuralı: Kullanıcının bu bayide bitmiş / onaylanmış bir işlemi var mı?
      QuerySnapshot islemSorgusu = await _db.collection('islemler')
          .where('musteri_id', isEqualTo: musteriId)
          .where('bayi_id', isEqualTo: bayiId)
          .where('islem_durumu', isEqualTo: 'TAMAMLANDI') // Karargah standart işlem durumu
          .limit(1)
          .get();

      if (islemSorgusu.docs.isEmpty) {
        developer.log("SİBER İHLAL: Sahte yorum girişimi tespit edildi ve engellendi!");
        // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ: UI'a Kırmızı Alarm Fırlat!
        throw Exception("ADALET KİLİDİ: Bu bayiden hizmet almadan veya check-in yapmadan yorum yapamazsınız!");
      }

      developer.log("SİBER ONAY: ✅ Kullanıcının yorum yetkisi doğrulandı.");
      return true;

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Adalet kilidi sorgulanamadı!", error: e);
      throw Exception("SİSTEMSEL HATA: Yorum yetkisi doğrulanamıyor. Lütfen bağlantınızı kontrol edin.");
    }
  }

  // ── 🛑 2. OTONOM KARA LİSTE (BLACKLIST) YARGI MOTORU ────────────────────
  static Future<void> karaListeDenetimi(String bayiId) async {
    try {
      developer.log("SİBER YARGI: $bayiId ID'li bayi için performans ve şikayet radarı devrede...");

      // Bayinin son 10 yorumunu Karargahtan çek
      QuerySnapshot sonYorumlar = await _db.collection('yorumlar')
          .where('bayi_id', isEqualTo: bayiId)
          .orderBy('tarih', descending: true)
          .limit(10)
          .get();

      if (sonYorumlar.docs.isEmpty) return; // Henüz yeterli veri yok

      // Ortalamayı otonom hesapla
      double toplamPuan = 0;
      for (var doc in sonYorumlar.docs) {
        toplamPuan += (doc.data() as Map<String, dynamic>)['puan'] ?? 5;
      }

      double ortalama = toplamPuan / sonYorumlar.docs.length;
      developer.log("SİBER İSTİHBARAT: Bayinin güncel memnuniyet ortalaması -> $ortalama");

      // ⚖️ KARARGAH KURALI: Ortalama 2.0'ın altındaysa acıma, Siyah Yıldızı çak!
      if (ortalama < 2.0) {
        developer.log("🔥 KIZIL ALARM: Sınır aşıldı! Bayi için BLACKLIST (İdam) Protokolü başlatılıyor!");

        // ⛓️ ATOMİK ZIRH: WriteBatch Başlatıldı
        WriteBatch batch = _db.batch();

        // 1. Bayiyi Kuantum Ağında Yok Et (1 Yıldız / Black Star)
        DocumentReference bayiRef = _db.collection('bayiler').doc(bayiId);
        batch.update(bayiRef, {
          'rating': 1, // Siyah Yıldız (Black Star) Karargah Etiketi
          'status': 'BLACKLIST', // Ağdan tecrit edildi
          'blacklist_sebebi': 'Otonom Adalet: Çok sayıda negatif yorum (Ortalama: $ortalama)',
          'guncelleme_tarihi': FieldValue.serverTimestamp(),
        });

        // 2. Kara Kutuya (Sistem Logları) İdamı Mühürle
        DocumentReference logRef = _db.collection('sistem_loglari').doc();
        batch.set(logRef, {
          'islem_turu': 'OTONOM_BLACKLIST_CEZASI',
          'islem_detayi': 'SİBER YARGI: $bayiId ID\'li bayi ortalaması $ortalama olduğu için Adalet Motoru tarafından KARA LİSTEYE gömüldü.',
          'tarih': FieldValue.serverTimestamp(),
        });

        // Füzeleri Ateşle!
        await batch.commit();

        developer.log("SİBER ONAY: 🛑 ADALET SAĞLANDI! Bayi acımasızca Blacklist'e alındı ve 1 Yıldız'a düşürüldü.");
      }

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Otonom Yargı Motoru arızalandı!", error: e);
      // Bu arka plan işlemi olduğu için sistemi çökertmeyebiliriz ama Kara Kutuya mutlaka düşmeli.
    }
  }
}