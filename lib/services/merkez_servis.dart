import 'dart:developer' as developer;
import 'city_service.dart';
import 'finance_service.dart';

/// 🛡️ KUANTUM MERKEZ KARARGAH MOTORU (MerkezServis)
/// Ankara Merkezli sistemin genel onay, yargı (ceza) ve denetim mekanizmalarını yönetir.
class MerkezServis {

  // ── 🗺️ 01. SİBER COĞRAFİ ONAY (RADAR DENETİMİ) ──────────────────────────
  /// Şehrin Karargahın Kuantum Radarına (CityService) kayıtlı olup olmadığını denetler.
  static bool sehirOnayla(String sehir) {
    try {
      String formatliSehir = sehir.trim().toUpperCase();
      List<String> tumIller = CityService.tumIlleriGetir();

      bool onayli = tumIller.contains(formatliSehir);

      if (onayli) {
        developer.log("SİBER ONAY: $formatliSehir, Karargah ağına başarıyla bağlandı.");
      } else {
        developer.log("SİBER İHLAL (SAHTE KONUM): $formatliSehir tanımlanamayan bir bölge!");
      }
      return onayli;
    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Şehir doğrulama motoru arızalandı!", error: e);
      return false; // Güvenlik için sistem çökerse onayı reddet
    }
  }

  // ── 💰 02. MERKEZ KAZANÇ DENETİMİ (FİNANS ENTEGRASYONU) ─────────────────
  /// Karargahın sarsılmaz Net Payını (%10) standart finans motorundan doğrular.
  static double netKazancGetir(double brut) {
    if (brut <= 0) return 0.0;

    // 🚀 SİBER MİMARİ: Hesaplama burada yapılmaz, uzmanı olan FinanceService'e sorulur!
    Map<String, double> finansRaporu = FinanceService.bayiSatisHesapla(brut);

    // Otonom olarak %10 net payı çeker, bulamazsa güvenli kalkan olarak %10'u manuel hesaplar
    return finansRaporu['otodna_net_pay'] ?? (brut * 0.10);
  }

  // ── ⚖️ 03. RANDEVU VE CEZA YARGI SİSTEMİ ────────────────────────────────
  /// Randevuya gelmeyen müşterinin kaporasına el koyma ve paylaştırma algoritması.
  static Map<String, dynamic> cezaHesapla({required bool gelmedi, double kaporaTutari = 200.0}) {
    try {
      if (!gelmedi) {
        return {
          "durum": "TEMİZ",
          "mesaj": "Müşteri mühürlü randevusuna sadık kaldı. Ceza yok.",
          "kesinti": 0.0
        };
      }

      // ⚖️ Karargah Yargısı: Kapora yanar.
      // Mağduriyet bedeli olarak %50 Usta'ya, Siber ağ bedeli olarak %50 Merkez'e!
      double ustaPayi = kaporaTutari * 0.50;
      double merkezPayi = kaporaTutari * 0.50;

      developer.log("SİBER YARGI: Müşteri randevuya gelmedi! ₺$kaporaTutari kaporaya el konuldu.");
      developer.log("İSTİHBARAT: ₺$ustaPayi Ustaya, ₺$merkezPayi Karargaha aktarıldı.");

      return {
        "durum": "CEZALI_IHLAL",
        "mesaj": "Randevu ihlali tespit edildi. Kaporaya el konuldu.",
        "usta_payi": ustaPayi,
        "merkez_payi": merkezPayi,
        "toplam_ceza": kaporaTutari
      };
    } catch (e) {
      developer.log("SİSTEMSEL ANOMALİ: Ceza yargı motoru çöktü!", error: e);
      return {"durum": "HATA", "mesaj": "Yargı protoklü çalıştırılamadı."};
    }
  }
}