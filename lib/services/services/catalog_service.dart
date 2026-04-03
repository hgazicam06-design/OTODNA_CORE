class CatalogService {
  // Türkiye'nin En Çok Satan Araçları (03_Urun_Katalogu klasöründen gelen veri)
  static const Map<String, List<String>> aracModelleri = {
    'Fiat': ['Egea', 'Doblo', 'Fiorino', 'Panda'],
    'Renault': ['Clio', 'Megane', 'Taliant', 'Austral'],
    'Toyota': ['Corolla', 'Yaris', 'C-HR', 'Hilux'],
    'Volkswagen': ['Golf', 'Passat', 'Polo', 'Tiguan'],
    'Hyundai': ['i20', 'i10', 'Tucson', 'Bayon'],
  };

  // En Çok İhtiyaç Duyulan Yedek Parça Kategorileri
  static const List<String> parcaKategorileri = [
    'Periyodik Bakım (Yağ, Filtre)',
    'Fren Sistemi (Balata, Disk)',
    'Aydınlatma (Far, Stop)',
    'Süspansiyon (Amortisör)',
    'Motor Aksamı',
  ];

  static List<String> markalariGetir() => aracModelleri.keys.toList();
  
  static List<String> modellereGoreGetir(String marka) {
    return aracModelleri[marka] ?? [];
  }
}