class OnluYuklemeMotoru {
  
  // PDF'den gelen veriyi 10'arlı paketlere böler
  Future<void> paketleyipIsle(List<dynamic> tumVeriler) async {
    int paketBoyutu = 10;
    
    print("📦 Toplam ${tumVeriler.length} ürün bulundu. 10'arlı paketler hazırlanıyor...");

    for (var i = 0; i < tumVeriler.length; i += paketBoyutu) {
      var paket = tumVeriler.skip(i).take(paketBoyutu).toList();
      
      // Bu 10'lu paket ustanın ekranına "Onay Bekliyor" olarak düşer
      await _ustayaOnayaGonder(paket);
      
      print("✅ ${i + paket.length}. ürüne kadar olan paket işleme alındı.");
      
      // Her paketten sonra sistemi ve ustayı yormamak için kısa bir ara
      if (i + paketBoyutu < tumVeriler.length) {
        print("⏳ Sonraki 10 ürün için onay bekleniyor...");
        break; // Bir kerede sadece bir paket (10 ürün) işlensin kuralı
      }
    }
  }

  Future<void> _ustayaOnayaGonder(List<dynamic> paket) async {
    // Ustanın mobil panelindeki "Hızlı Onay" ekranını tetikler
    print("🛠️ Usta Paneli: 10 yeni ürün onayı bekliyor.");
  }
}