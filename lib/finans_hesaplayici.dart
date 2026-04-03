// lib/finans_hesaplayici.dart
import 'dart:developer' as developer;

/// 🛡️ KUANTUM FİNANS MOTORU (SiberFinansHesaplayici)
/// Karargahın acımasız komisyon kurallarını (%12 Standart, %30 Murat Plaza) otonom hesaplar.
class SiberFinansHesaplayici {
  // ── ⚖️ KARARGAH FİNANS KURALLARI ──
  static const double standartKesinti = 0.12; // %10 Net Pay + %2 Vergi
  static const double muratPlazaKesinti = 0.30; // Dış Veri Aktarım Merkezi İstisnası

  static Map<String, dynamic> bayiHakedisHesapla(double girilenFiyat, String bayiId) {
    // Zırh 1: Negatif veya sıfır fiyat koruması
    if (girilenFiyat <= 0) {
      developer.log("🚨 SİBER İHLAL: Sıfır veya negatif tutarlı işlem denemesi engellendi!");
      return {
        "Toplam_Satis": "0.00",
        "OtoDNA_Payi": "0.00",
        "Bayi_Net_Kasa": "0.00",
        "Kesinti_Orani": "%0"
      };
    }

    // Zırh 2: Murat Plaza Otonom Tespiti
    double uygulananOran = (bayiId == "MURAT_PLAZA") ? muratPlazaKesinti : standartKesinti;

    double sistemPayi = girilenFiyat * uygulananOran;
    double bayiNetHakedis = girilenFiyat - sistemPayi;

    developer.log("💰 FİNANS MÜHRÜ: İşlem Hacmi: ₺$girilenFiyat | Bayi: $bayiId | Kesinti: %${(uygulananOran * 100).toInt()}");

    // Küsüratları koruyarak (2 hane) Karargah formatına çeviriyoruz
    return {
      "Toplam_Satis": girilenFiyat.toStringAsFixed(2),
      "OtoDNA_Payi": sistemPayi.toStringAsFixed(2),
      "Bayi_Net_Kasa": bayiNetHakedis.toStringAsFixed(2),
      "Kesinti_Orani": "%${(uygulananOran * 100).toInt()}"
    };
  }
}