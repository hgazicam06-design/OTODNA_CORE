import 'dart:developer' as developer;

/// 🛡️ KUANTUM FİNANS VE HESAPLAMA MOTORU (FinanceService)
/// OtoDNA Ağındaki para akışını, Karargah kesintilerini ve Murat Plaza marjlarını otonom yönetir.
class FinanceService {
  // ── 💰 SİBER ORANLAR ────────────────────────────────────────────────────────
  // Karargahın (OtoDNA) standart bayi satışlarından aldığı vergi dahil toplam oran: %12
  static const double _toplamKesintiOrani = 0.12;
  static const double _otodnaNetPayOrani = 0.10;  // Net %10 Bizim

  // Murat Plaza'ya özel tanımlanmış kâr marjı: %30
  static const double _muratPlazaMarjOrani = 0.30;

  // ── 📊 STANDART BAYİ HESAPLAMASI (%12 KESİNTİ) ─────────────────────────────
  /// Dış bayilerin (Ostim, İskitler vb.) yaptığı işlemlerde Karargaha aktarılacak payı hesaplar.
  static Map<String, double> bayiSatisHesapla(double satisFiyati) {
    if (satisFiyati <= 0) {
      developer.log("SİBER HATA: Finans motoruna geçersiz/sıfır tutar girildi!");
      return {};
    }

    double toplamKesinti = satisFiyati * _toplamKesintiOrani; // 100 TL'de 12 TL
    double otodnaNetPay = satisFiyati * _otodnaNetPayOrani;   // 100 TL'de 10 TL
    double kdvPayi = toplamKesinti - otodnaNetPay;            // 100 TL'de 2 TL
    double esnafaKalan = satisFiyati - toplamKesinti;         // 100 TL'de 88 TL

    developer.log("SİBER FİNANS: ₺$satisFiyati tutarındaki standart bayi işlemi mühürlendi. Karargah Payı: ₺$otodnaNetPay");

    return {
      'satis_fiyati': satisFiyati,
      'otodna_net_pay': otodnaNetPay,
      'kdv_tutari': kdvPayi,
      'toplam_kesinti': toplamKesinti,
      'esnafa_kalan_net': esnafaKalan,
    };
  }

  // ── 🏢 MURAT PLAZA ÖZEL HESAPLAMASI (%30 KÂR) ──────────────────────────────
  /// Diğer firmalardan gelen ürünlerin Murat Plaza üzerinden satışı sırasındaki net kârı hesaplar.
  static Map<String, double> muratPlazaSatisHesapla(double urunGelisFiyati) {
    if (urunGelisFiyati <= 0) {
      developer.log("SİBER HATA: Murat Plaza finans motoruna sıfır tutar girildi!");
      return {};
    }

    // Geliş fiyatının üzerine %30 kâr koyarak nihai satış fiyatını belirler
    double netKar = urunGelisFiyati * _muratPlazaMarjOrani;
    double satisFiyati = urunGelisFiyati + netKar;

    developer.log("SİBER FİNANS: Murat Plaza için ₺$urunGelisFiyati gelişli ürüne %30 marj eklendi. Yeni Satış: ₺$satisFiyati");

    return {
      'gelis_fiyati': urunGelisFiyati,
      'murat_plaza_net_kar': netKar,
      'satis_fiyati': satisFiyati,
    };
  }
}