class UrunYuklemeServisi {
  static const int MAKS_URUN_SINIRI = 10;

  // PDF'den Ürün Ayıklama (OCR)
  Future<void> pdfIleUrunYukle(String bayiId, File pdfFile) async {
    // 1. Bayinin mevcut ürün sayısını kontrol et
    int mevcutUrunSayisi = await Database.getBayiUrunCount(bayiId);
    
    if (mevcutUrunSayisi >= MAKS_URUN_SINIRI) {
      throw Exception("⚠️ Limit Aşımı: Sistemde zaten $MAKS_URUN_SINIRI ürününüz var. Yeni eklemek için eskileri silmelisiniz.");
    }

    // 2. AI OCR devreye girer
    print("🤖 AI PDF'i tarıyor... Veriler ayıklanıyor...");
    var ayiklananUrunler = await AiService.processPdf(pdfFile);

    // 3. Limit kontrolüyle sisteme işle
    for (var urun in ayiklananUrunler.take(MAKS_URUN_SINIRI - mevcutUrunSayisi)) {
      Database.urunEkle(bayiId, urun);
      print("✅ Ürün eklendi: ${urun.ad}");
    }
  }
}