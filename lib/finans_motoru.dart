// lib/finans_motoru.dart
import 'dart:developer' as developer;

/// 🛡️ KUANTUM FİNANS VE FİYATLANDIRMA MOTORU (FinansMotoru)
/// Karargahın ürün ve hizmet bedellerini, kesinti oranlarını (%12 veya %30) otonom hesaplar.
class FinansMotoru {
  // ── ⚖️ KARARGAH FİNANS KURALLARI ──
  static const double _standartKesinti = 0.12; // %10 Net + %2 Vergi
  static const double _muratPlazaKesinti = 0.30; // Dış Veri Aktarım Merkezi İstisnası

  // ── 💰 ÜRÜN SATIŞ VE KOMİSYON HESAPLAYICI ──
  static Map<String, double> satisHesapla(double firmaFiyati, String bayiId) {
    // Zırh 1: Negatif veya Sıfır Koruması
    if (firmaFiyati <= 0) {
      developer.log("🚨 SİBER İHLAL: Finans motoruna sıfır veya negatif tutar gönderildi!");
      return {
        "Toplam_Fiyat": 0.0,
        "Karargah_Payi": 0.0,
        "Bayi_Net_Hakedis": 0.0,
        "Kesinti_Orani": 0.0,
      };
    }

    // Zırh 2: Murat Plaza Otonom Tespiti
    double uygulananOran = (bayiId == "MURAT_PLAZA") ? _muratPlazaKesinti : _standartKesinti;

    double sistemPayi = firmaFiyati * uygulananOran;
    double netHakedis = firmaFiyati - sistemPayi;

    developer.log("💎 FİNANS MÜHRÜ: Tutar: ₺$firmaFiyati | Bayi: $bayiId | Kesinti Oranı: %${(uygulananOran * 100).toInt()}");

    return {
      "Toplam_Fiyat": firmaFiyati,
      "Karargah_Payi": sistemPayi,
      "Bayi_Net_Hakedis": netHakedis,
      "Kesinti_Orani": uygulananOran,
    };
  }

  // ── 🏷️ RANDEVU VE HİZMET BEDELİ (DİNAMİK TARİFE) ──
  static double randevuBedeli(String tur) {
    double bedel = 0.0;
    switch (tur) {
      case "VIP Muayene":
        bedel = 500.0;
        break;
      case "Egzoz Emisyon":
        bedel = 150.0;
        break;
      case "Kapsamlı Ekspertiz": // Sisteme yeni eklendi
        bedel = 1500.0;
        break;
      default:
        bedel = 100.0;
    }

    developer.log("🚀 HİZMET TARİFESİ: '$tur' işlemi için bedel ₺$bedel olarak belirlendi.");
    return bedel;
  }
}