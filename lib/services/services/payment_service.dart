// payment_service.dart - OtoDNA Finans Motoru

class PaymentService {
  // Senin payın %10, Vergi %2 -> Toplam kesinti %12
  static const double partnerSharePercent = 0.10;
  static const double taxPercent = 0.02;
  static const double totalCommission = partnerSharePercent + taxPercent;

  // Ödeme Dağılım Hesaplayıcı
  Map<String, double> calculatePayout(double totalAmount) {
    double totalDeduction = totalAmount * totalCommission;
    double partnerProfit = totalAmount * partnerSharePercent;
    double taxAmount = totalAmount * taxPercent;
    double vendorAmount = totalAmount - totalDeduction;

    return {
      'vendor_amount': vendorAmount,    // Esnafa gidecek net
      'partner_profit': partnerProfit,  // Senin cebine girecek (%10)
      'tax_amount': taxAmount,          // Vergiye ayrılan (%2)
    };
  }

  // Randevu ve Garanti Bedeli Tahsili
  // Kullanıcı randevuyu bizden alırsa ödeyeceği sembolik hizmet bedeli
  double calculateAppointmentFee(double servicePrice) {
    // Örnek: İşlem bedelinin küçük bir yüzdesi veya sabit bir bedel
    return 50.0; // Sabit 50 TL Garanti & Randevu bedeli gibi
  }
}