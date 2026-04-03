// pdf_offer_service.dart - Teklif PDF Oluşturucu

class PdfOfferService {
  void generateOffer(List<OfferItem> items, String plate) {
    double grandTotal = 0;
    
    print("--- OtoDNA FİYAT TEKLİFİ (TASLAK) ---");
    print("Araç Plakası: $plate");
    print("----------------------------------");
    
    for (var item in items) {
      print("${item.description} | Adet: ${item.quantity} | Toplam: ${item.totalPrice} TL");
      grandTotal += item.totalPrice;
    }
    
    print("----------------------------------");
    print("ARA TOPLAM: $grandTotal TL");
    print("KDV (%20): ${grandTotal * 0.20} TL");
    print("GENEL TOPLAM: ${grandTotal * 1.20} TL");
    print("\nUYARI: Bu belge mali değeri olmayan bir Fiyat Teklif Formudur.");
    print("OtoDNA Sistemi Üzerinden Hazırlanmıştır.");
  }
}