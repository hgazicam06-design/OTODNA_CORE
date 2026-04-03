class RegionAnalytics {
  // 7 Bölgeye Göre Parça Talep Yoğunluğu (0-100 arası puanlama)
  static const Map<String, Map<String, int>> bolgeselTalep = {
    'İç Anadolu': {'Fren Sistemi': 95, 'Periyodik Bakım': 88, 'Aydınlatma': 70},
    'Marmara': {'Fren Sistemi': 98, 'Periyodik Bakım': 99, 'Süspansiyon': 90},
    'Ege': {'Aydınlatma': 85, 'Süspansiyon': 75, 'Motor Aksamı': 60},
    'Karadeniz': {'Süspansiyon': 95, 'Fren Sistemi': 92, 'Motor Aksamı': 80},
    'Akdeniz': {'Klima Sistemi': 100, 'Aydınlatma': 80, 'Periyodik Bakım': 70},
    'Doğu Anadolu': {'Motor Aksamı': 90, 'Isıtma Sistemi': 95, 'Süspansiyon': 85},
    'Güneydoğu Anadolu': {'Klima Sistemi': 90, 'Motor Aksamı': 85, 'Fren Sistemi': 80},
  };

  static String tavsiyeGetir(String bolge, String kategori) {
    int yogunluk = bolgeselTalep[bolge]?[kategori] ?? 50;
    if (yogunluk > 90) return "🔥 BU BÖLGEDE ÇOK YÜKSEK TALEP!";
    if (yogunluk > 70) return "✅ Düzenli Satış Potansiyeli.";
    return "ℹ️ Standart Talep Seviyesi.";
  }
}