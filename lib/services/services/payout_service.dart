// Kapora Hesaplama Fonksiyonu
Map<String, double> calculateDeposit(double carPrice) {
  double totalDeposit = carPrice * 0.02; // %2 Kapora
  double ourServiceFee = totalDeposit * 0.10; // Kaporanın %10'u bizim
  double refundableAmount = totalDeposit - ourServiceFee; // İade edilebilir/Satıcıya geçecek tutar

  return {
    'total_deposit': totalDeposit,
    'otodna_fee': ourServiceFee,
    'seller_payout': refundableAmount,
  };
}