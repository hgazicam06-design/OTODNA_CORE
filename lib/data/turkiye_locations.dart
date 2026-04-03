// turkiye_locations.dart - 81 İl ve 7 Bölge İskeleti (Kuantum Uyumlu)

class LocationData {
  static final Map<String, List<String>> regionsAndCities = {
    "İç Anadolu": [
      "Ankara (Merkez)", "Konya", "Kayseri", "Eskişehir", "Sivas",
      "Kırıkkale", "Aksaray", "Karaman", "Kırşehir", "Niğde", "Nevşehir", "Yozgat", "Çankırı"
    ],
    "Marmara": [
      "İstanbul", "Bursa", "Kocaeli", "Balıkesir", "Tekirdağ",
      "Sakarya", "Çanakkale", "Edirne", "Kırklareli", "Yalova", "Bilecik"
    ],
    "Ege": [
      "İzmir", "Manisa", "Aydın", "Denizli", "Muğla", "Afyonkarahisar", "Kütahya", "Uşak"
    ],
    "Akdeniz": [
      "Antalya", "Adana", "Mersin", "Hatay", "Kahramanmaraş", "Osmaniye", "Isparta", "Burdur"
    ],
    "Karadeniz": [
      "Samsun", "Trabzon", "Ordu", "Zonguldak", "Tokat", "Çorum", "Giresun", "Düzce",
      "Kastamonu", "Rize", "Amasya", "Artvin", "Bolu", "Sinop", "Bartın", "Bayburt", "Gümüşhane", "Karabük"
    ],
    "Güneydoğu Anadolu": [
      "Gaziantep", "Şanlıurfa", "Diyarbakır", "Mardin", "Adıyaman", "Batman", "Siirt", "Kilis"
    ],
    "Doğu Anadolu": [
      "Erzurum", "Malatya", "Van", "Elazığ", "Ağrı", "Erzincan", "Bitlis", "Kars",
      "Muş", "Hakkari", "Iğdır", "Ardahan", "Bingöl", "Tunceli"
    ],
  };

  // ---------------------------------------------------------
  // 🧠 1. TÜM ŞEHİRLERİ GETİR (Arama ve Dropdown İçin)
  // ---------------------------------------------------------
  static List<String> getAllCities() {
    List<String> allCities = [];
    for (var cities in regionsAndCities.values) {
      allCities.addAll(cities);
    }
    allCities.sort(); // Kullanıcı kolay bulsun diye A-Z alfabetik sıralama
    return allCities;
  }

  // ---------------------------------------------------------
  // 🎯 2. ŞEHRİN BÖLGESİNİ OTOMATİK BULMA MOTORU (YENİ)
  // ---------------------------------------------------------
  /// Kullanıcı arayüzde sadece "İstanbul" seçtiğinde, Firebase'e kaydederken
  /// "Marmara" bölgesini de arka planda otomatik bulup veritabanına eklemek için kullanılır.
  static String getRegionForCity(String cityName) {
    for (var entry in regionsAndCities.entries) {
      if (entry.value.contains(cityName)) {
        return entry.key; // Örn: "Marmara" döndürür
      }
    }
    return "Bilinmeyen Bölge";
  }

  // ---------------------------------------------------------
  // 🚨 3. ANA KARARGAH (HQ) KONTROLÜ
  // ---------------------------------------------------------
  /// Lojistik, SOS müdahaleleri veya kargo hesaplamaları için
  /// hedefin Ankara Merkez olup olmadığını saniyesinde teyit eder.
  static bool isHQ(String cityName) {
    return cityName == "Ankara (Merkez)";
  }
}