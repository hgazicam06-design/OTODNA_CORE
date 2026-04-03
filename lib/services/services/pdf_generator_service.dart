// pdf_generator_service.dart - OtoDNA PDF Motoru

class PdfGenerator {
  // 1. Araç Kontrol Formu Çıktısı (Çift Tikli)
  Future<void> createControlFormPDF(Map<String, ServiceAction> results) async {
    // PDF tasarımı: Hizmet Adı | Kontrol Edildi | Değiştirildi
    // Örn: Triger Seti | [EVET] | [HAYIR] şeklinde yazıya dökülür.
  }

  // 2. Fiyat Teklif Formu Çıktısı
  Future<void> createPriceOfferPDF(List<OfferItem> items, double total) async {
    // Tasarım: Gönderdiğin görsele uygun tablo yapısı
    // Alt Bilgi: "İşbu teklif 7 gün geçerlidir. Mali değeri yoktur."
  }
}