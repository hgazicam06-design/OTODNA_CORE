class DisVeriServisi {
  // Tramer ve Global VIN Hub Entegrasyonu
  Future<Map<String, dynamic>> tamSorgu(String saseNo) async {
    print("🌐 Dış veri kaynaklarına bağlanılıyor...");

    // 1. Tramer API Sorgusu (Hasar Kaydı)
    var tramerVerisi = await SbmApi.getHasarGecmisi(saseNo);

    // 2. Global VIN Hub (Fabrika Çıkış Özellikleri)
    var teknikVeri = await GoogleDataHub.getVehicleSpecs(saseNo);

    return {
      "tramer": tramerVerisi, // Kazalar, tutanaklar
      "teknik": teknikVeri,   // Orijinal beygir, paket, donanım
      "otodna": await LocalDb.getHistory(saseNo) // Bizim mühürlü kayıtlar
    };
  }
}