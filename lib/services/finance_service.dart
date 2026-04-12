import 'dart:developer' as developer;

/// 🛡️ KUANTUM FİNANS VE HESAPLAMA MOTORU (FinanceService)
/// OtoDNA Ağındaki para akışını ve Karargahın %12'lik mutlak payını otonom yönetir.
/// SİBER KURAL: İstisna yoktur. Tüm bayiler ve işlemler için kesinti %12'dir.
class FinanceService {
  // ── 💰 SİBER ORANLAR (MUTLAK KURAL: %12) ──────────────────────────────────
  // Karargahın (OtoDNA) tüm bayi satışlarından aldığı vergi dahil toplam oran: %12
  static const double _toplamKesintiOrani = 0.12;
  static const double _otodnaNetPayOrani = 0.10;  // Net %10 Bizim (Karargah Kârı)

  // ── 📊 TEK VE MUTLAK BAYİ HESAPLAMASI (%12 KESİNTİ) ──────────────────────
  /// Tüm bayilerin (İstisnasız) yaptığı işlemlerde Karargaha aktarılacak payı hesaplar.
  static Map<String, double> bayiSatisHesapla(double satisFiyati) {
    if (satisFiyati <= 0) {
      developer.log("SİBER İHLAL: Finans motoruna geçersiz/sıfır tutar girildi!");
      // 🚨 Sessiz Çöküş Engellendi: UI'ın boş Map okuyup çökmemesi için Kırmızı Alarm fırlatıyoruz!
      throw Exception("FİNANSAL HATA: Satış fiyatı 0 veya negatif olamaz!");
    }

    double toplamKesinti = satisFiyati * _toplamKesintiOrani; // 100 TL'de 12 TL
    double otodnaNetPay = satisFiyati * _otodnaNetPayOrani;   // 100 TL'de 10 TL
    double kdvPayi = toplamKesinti - otodnaNetPay;            // 100 TL'de 2 TL
    double esnafaKalan = satisFiyati - toplamKesinti;         // 100 TL'de 88 TL

    developer.log("SİBER FİNANS: ₺$satisFiyati tutarındaki işlem mühürlendi. Karargah Payı: ₺$otodnaNetPay, KDV: ₺$kdvPayi");

    return {
      'satis_fiyati': satisFiyati,
      'otodna_net_pay': otodnaNetPay,
      'kdv_tutari': kdvPayi,
      'toplam_kesinti': toplamKesinti,
      'esnafa_kalan_net': esnafaKalan,
    };
  }
}