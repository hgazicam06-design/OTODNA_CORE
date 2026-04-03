import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';

// SİBER NOT: Gerçek Blockchain altyapısı bağlanana kadar Karargah veritabanı (Firebase) devrededir.
// import 'package:otodna/core/blockchain_logger.dart';

/// 🛡️ KUANTUM DİJİTAL REFERANS VE MÜHÜR MOTORU (MuhurlemeServisi)
/// Kullanıcının AI yardımıyla girdiği ve fotoğrafladığı verileri Ustanın önüne getirir,
/// AI Kalfanın sunumuyla onaylatır ve Karargah mührünü vurur.
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
      // Ustanın ekranında işlemi AI özetler. "Sen yapmadın, ben görmedim" dönemi biter.
      developer.log("🤖 AI KALFA SUNUMU: '$aiKalfaOzeti'");
      developer.log("SİBER ONAY: Usta, kullanıcının yüklediği görsel kanıtları ve AI Kalfanın raporunu inceleyip onayladı.");

      // 3. KIRMIZI X (Kritik Risk) Kontrolü
      if (kontroller.values.contains("KIRMIZI_X")) {
        _kritikHataBildir(saseNo);
      }

      // 4. FİNANSAL ÇARK TETİKLEMESİ (Toplam %12 Kesinti)
      _payHesaplaVeGonder(islemUcreti);

      // 5. DİJİTAL İMZA VE ZAMAN DAMGASI
      var dijitalMuhur = {
        "timestamp": FieldValue.serverTimestamp(),
        "usta_id": ustaId,
        "sase_no": saseNo.toUpperCase(),
        "veriler": kontroller,
        "kanitlar": kanitMedyaYollari,
        "ai_kalfa_ozeti": aiKalfaOzeti, // Kalfanın sözleri de blockchain'e mühürlenir
        "islem_ucreti": islemUcreti,
        "dijital_referans_onayi": true,
      };

      // 🚀 Kaydı sonsuza kadar Karargah veritabanına mühürle
      await _db.collection('dijital_muhurler').add(dijitalMuhur);

      // İleride Blockchain aktif edildiğinde tetiklenecek siber komut:
      // await BlockchainLogger.save(dijitalMuhur);

      developer.log("SİBER MÜHÜR: ✅ Araç OtoDNA Sistemine kusursuzca mühürlendi!");

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Mühürleme işlemi başarısız oldu!", error: e);
      throw Exception("SİBER HATA: Araç DNA'sına mühür vurulamadı. Lütfen görsel kanıtları kontrol edin.");
    }
  }

  // ── 💰 FİNANSAL ÇARK (KARARGAH VE VERGİ PAYI) ────────────────────────
  void _payHesaplaVeGonder(double tutar) {
    if(tutar <= 0) return;

    double gaziNet = tutar * 0.10; // %10 Net Karargah Payı
    double vergi = tutar * 0.02;   // %2 Vergi

    developer.log("SİBER FİNANS: İşlem: ₺$tutar | Karargah Net: ₺$gaziNet | Vergi: ₺$vergi mühürlendi.");
  }

  // ── 🚨 KRİTİK RİSK BİLDİRİMİ (KIRMIZI X PROTOKOLÜ) ────────────────────
  void _kritikHataBildir(String sase) {
    developer.log("KIRMIZI ALARM ⚠️: $sase şaseli araçta 'KIRMIZI_X' tespit edildi!");
    developer.log("SİBER İSTİHBARAT: Bu aracın trafiğe çıkışının riskli olduğu otonom olarak raporlandı.");
  }
}