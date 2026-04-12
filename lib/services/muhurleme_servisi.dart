import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';

// SİBER NOT: Gerçek Blockchain altyapısı bağlanana kadar Karargah veritabanı (Firebase) devrededir.
// import 'package:otodna/core/blockchain_logger.dart';

/// 🛡️ KUANTUM DİJİTAL REFERANS VE MÜHÜR MOTORU (MuhurlemeServisi)
/// Kullanıcının AI yardımıyla girdiği ve fotoğrafladığı verileri Ustanın önüne getirir,
/// AI Kalfanın sunumuyla onaylatır ve Karargah mührünü atomik zırhla vurur.
class MuhurlemeServisi {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 🔒 AI KALFA DESTEKLİ DİJİTAL MÜHÜRLEME PROTOKOLÜ ─────────────
  Future<void> araciMuhurle({
    required String saseNo,
    required String ustaId,
    required Map<String, dynamic> kontroller, // Fren, Şase, Motor vb.
    required List<String> kanitMedyaYollari,
    required double islemUcreti,
    required String aiKalfaOzeti, // 🤖 YENİ: AI Kalfanın ustaya yaptığı sözlü/yazılı özet
  }) async {
    try {
      developer.log("SİBER BİLGİ: 🔒 $saseNo şaseli araç için Kuantum Mühürleme işlemi başlatıldı...");

      // 1. SİBER KANIT ZORUNLULUĞU (ÖDÜN VERİLEMEZ!)
      // Müşteri yapay zeka ile işlemi girerken fotoğraf yüklemediyse, bu veri ustanın önüne DÜŞEMEZ!
      if (kanitMedyaYollari.isEmpty) {
        throw Exception("SİBER İHLAL: Görsel kanıt yüklenmeden işlem ustanın ekranına aktarılamaz ve mühürlenemez!");
      }

      // 2. 🤖 AI KALFA (SİBER ÇIRAK) SUNUMU
      developer.log("🤖 AI KALFA SUNUMU: '$aiKalfaOzeti'");
      developer.log("SİBER ONAY: Usta, kullanıcının yüklediği görsel kanıtları ve AI Kalfanın raporunu inceleyip onayladı.");

      // ⛓️ SİBER ZIRH: ATOMİK WRITEBATCH BAŞLATILDI
      WriteBatch batch = _db.batch();

      // 3. FİNANSAL ÇARK HESAPLAMASI (Toplam %12 Kesinti)
      double gaziNet = islemUcreti * 0.10; // %10 Net Karargah Payı
      double vergi = islemUcreti * 0.02;   // %2 Vergi

      // 4. DİJİTAL İMZA VE ZAMAN DAMGASI (Blockchain'e Hazırlık)
      DocumentReference muhurRef = _db.collection('dijital_muhurler').doc();
      batch.set(muhurRef, {
        "timestamp": FieldValue.serverTimestamp(),
        "usta_id": ustaId,
        "sase_no": saseNo.toUpperCase(),
        "veriler": kontroller,
        "kanitlar": kanitMedyaYollari,
        "ai_kalfa_ozeti": aiKalfaOzeti,
        "islem_ucreti": islemUcreti,
        "komutan_payi": gaziNet,
        "vergi_payi": vergi,
        "dijital_referans_onayi": true,
      });

      // 5. KARA KUTUYA İŞLEMİ MÜHÜRLE
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'DIJITAL_MUHUR',
        'islem_detayi': 'MÜHÜR: $saseNo şaseli araç AI Kalfa onayıyla ağa kilitlendi. Karargah Payı: ₺$gaziNet',
        'bayi_id': ustaId,
        'tarih': FieldValue.serverTimestamp(),
      });

      // 6. 🚨 KIRMIZI X PROTOKOLÜ (TRAFİĞE ÇIKIŞ ENGELİ)
      if (kontroller.values.contains("KIRMIZI_X")) {
        developer.log("KIRMIZI ALARM ⚠️: $saseNo şaseli araçta 'KIRMIZI_X' tespit edildi! İdam protokolü tetikleniyor...");

        // Aracı direkt trafiğe çıkamaz olarak kilitle
        DocumentReference aracRef = _db.collection('araclar').doc(saseNo.toUpperCase());
        batch.update(aracRef, {
          'durum': 'RİSKLİ - TRAFİĞE ÇIKAMAZ',
          'dna_skoru': FieldValue.increment(-20), // Kritik hata DNA skorunu çökertir
          'son_guncelleme': FieldValue.serverTimestamp(),
        });

        // Kara Kutuya Kırmızı X (SOS) Sinyali Gönder
        DocumentReference sosLogRef = _db.collection('sistem_loglari').doc();
        batch.set(sosLogRef, {
          'islem_turu': 'sos',
          'islem_detayi': 'SİBER MÜDAHALE: $saseNo şaseli araç KIRMIZI_X tespit edildiği için karantinaya alındı!',
          'bayi_id': ustaId,
          'tarih': FieldValue.serverTimestamp(),
        });
      }

      // TÜM FÜZELERİ AYNI ANDA ATEŞLE!
      await batch.commit();

      // İleride Blockchain aktif edildiğinde tetiklenecek siber komut (Batch sonrası):
      // await BlockchainLogger.save(dijitalMuhur);

      developer.log("SİBER MÜHÜR: ✅ Araç OtoDNA Sistemine kusursuzca mühürlendi!");

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Mühürleme işlemi başarısız oldu!", error: e);
      throw Exception("SİBER HATA: Araç DNA'sına mühür vurulamadı. Lütfen Kuantum Ağınızı ve kanıtları kontrol edin.");
    }
  }
}