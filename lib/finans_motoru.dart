// lib/core/finans_motoru.dart  (Siber Not: Bu dosyayı uygulamanın her yerinden çekebilmek için core veya utils klasöründe tut!)
import 'dart:developer' as developer;

/// 🛡️ KUANTUM FİNANS VE FİYATLANDIRMA MOTORU (FinansMotoru)
/// YENİ DOKTRİN: İşçilik %100 bayinin. Karargah sadece B2B Parça satışından %12 (veya %30) otonom kesinti yapar.
class FinansMotoru {
  // ── ⚖️ KARARGAH FİNANS KURALLARI ──
  static const double _standartKesinti = 0.12; // %10 Net + %2 Vergi
  static const double _muratPlazaKesinti = 0.30; // Dış Veri Aktarım Merkezi İstisnası

  // ── 💰 YENİ DOKTRİN: AYRIŞTIRILMIŞ SATIŞ VE KOMİSYON HESAPLAYICI ──
  static Map<String, double> satisHesapla({
    required double iscilikTutari,
    required double parcaTutari,
    required String bayiId
  }) {
    double toplamFiyat = iscilikTutari + parcaTutari;

    // Zırh 1: Negatif veya Sıfır Koruması
    if (toplamFiyat <= 0) {
      developer.log("🚨 SİBER İHLAL: Finans motoruna sıfır veya negatif tutar gönderildi!");
      return {
        "Toplam_Fiyat": 0.0,
        "Iscilik_Geliri": 0.0,
        "Parca_Satis": 0.0,
        "Karargah_Payi": 0.0,
        "Bayi_Net_Hakedis": 0.0,
        "Kesinti_Orani": 0.0,
      };
    }

    // Zırh 2: Murat Plaza Otonom Tespiti
    double uygulananOran = (bayiId == "MURAT_PLAZA") ? _muratPlazaKesinti : _standartKesinti;

    // 🛡️ MUTLAK TİCARET DOKTRİNİ MÜHRÜ: Sadece parçadan kesinti yap!
    double sistemPayi = parcaTutari * uygulananOran;
    double netHakedis = toplamFiyat - sistemPayi; // Bayi işçiliği tam alır, parçanın da kalanını alır.

    developer.log("💎 FİNANS MÜHRÜ: Toplam: ₺$toplamFiyat (İşçilik: ₺$iscilikTutari, Parça: ₺$parcaTutari) | Bayi: $bayiId | Karargah Kesintisi: ₺$sistemPayi");

    return {
      "Toplam_Fiyat": toplamFiyat,
      "Iscilik_Geliri": iscilikTutari,
      "Parca_Satis": parcaTutari,
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

    developer.log("🚀 HİZMET TARİFESİ: '$tur' işlemi için bedel ₺$bedel olarak Karargaha mühürlendi.");
    return bedel;
  }
}