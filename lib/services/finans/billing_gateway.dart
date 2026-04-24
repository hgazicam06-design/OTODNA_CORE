import 'dart:math';

class BillingGateway {
  // Satış işlemi sonrası otomatik e-Fatura oluşturur
  Future<Map<String, dynamic>> generateEInvoice({
    required String transactionId,
    required double grossPrice,
    required String itemDetails,
    required String buyerEmail,
  }) async {
    // KDV Ayrıştırması (%20)
    const double kdvOrani = 0.20;
    final double kdvHaricTutar = grossPrice / (1 + kdvOrani);
    final double kdvTutari = grossPrice - kdvHaricTutar;
    
    final String faturaNo = "OTODNA-${Random().nextInt(999999).toString().padLeft(6, '0')}";
    
    final eInvoiceData = {
      'fatura_no': faturaNo,
      'transaction_id': transactionId,
      'tarih': DateTime.now().toIso8601String(),
      'urun': itemDetails,
      'brut_tutar': grossPrice,
      'matrah': kdvHaricTutar,
      'kdv_tutari': kdvTutari,
      'status': 'GİB Onaylı - e-Arşiv / e-Fatura',
      'qr_kodu': 'OTODNA-INV-$transactionId',
    };
    
    // Gerçekte burada Paraşüt / Logo / EDM Bilişim API'sine istek atılır.
    print("Siber Karargah: Otonom e-Fatura oluşturuldu -> $faturaNo");
    
    return eInvoiceData;
  }
}
