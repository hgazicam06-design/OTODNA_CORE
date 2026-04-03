// central_management_service.dart - Ankara Merkez Kontrol Sistemi

class CentralManagementService {
  // 81 İldeki Bayilerin Listesi (Örnek Veri Yapısı)
  final List<Map<String, dynamic>> dealers = [
    {
      "name": "GAZİ OTOMOTİV",
      "city": "Ankara",
      "region": "İç Anadolu",
      "rating": 5, // GOLD
      "status": "Aktif"
    },
    {
      "name": "İSTANBUL GARAGE",
      "city": "İstanbul",
      "region": "Marmara",
      "rating": 4, // SILVER (Gümüş)
      "status": "Aktif"
    },
    {
      "name": "XYZ SERVİS",
      "city": "İstanbul",
      "region": "Marmara",
      "rating": 1, // BLACKLIST
      "status": "Engellendi"
    },
  ];

  // Kara Listeye Alma Fonksiyonu (Senin Talimatınla)
  void blacklistDealer(String dealerName) {
    print("OtoDNA UYARI: $dealerName firması negatif yorumlar nedeniyle BLACKLIST'e alındı!");
    // Burada firma puanı 1'e düşürülür ve siyah yıldız çakılır.
  }
}