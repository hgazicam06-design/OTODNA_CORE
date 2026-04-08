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

  // 🧠 1. TÜM ŞEHİRLERİ GETİR
  static List<String> getAllCities() {
    List<String> allCities = [];
    for (var cities in regionsAndCities.values) {
      allCities.addAll(cities);
    }
    allCities.sort();
    return allCities;
  }

  // 🎯 2. ŞEHRİN BÖLGESİNİ OTOMATİK BULMA MOTORU
  static String getRegionForCity(String cityName) {
    for (var entry in regionsAndCities.entries) {
      if (entry.value.contains(cityName)) {
        return entry.key;
      }
    }
    return "Bilinmeyen Bölge";
  }

  // 🚨 3. ANA KARARGAH (HQ) KONTROLÜ
  static bool isHQ(String cityName) {
    return cityName == "Ankara (Merkez)";
  }
}