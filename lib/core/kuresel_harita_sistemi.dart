class KureselHaritaSistemi {
  // 🇹🇷 OLAN BİTEN HER ŞEYİN KÜRESEL MERKEZİ
  static const String globalMerkezUlkemiz = "Türkiye";
  static const String globalMerkezSehir = "Ankara";

  // 🌍 1. AŞAMA: KÜRESEL PAZAR (Aktif Ülkeler İskeleti)
  static const List<String> aktifUlkeler = [
    "Türkiye",
    "Almanya",
    "Azerbaycan",
    "Hollanda",
    "Katar",
    "Birleşik Arap Emirlikleri"
  ];

  // ---------------------------------------------------------
  // 🇹🇷 TÜRKİYE (MERKEZ ÜS) ALTYAPISI (7 BÖLGE VE 81 İL)
  // ---------------------------------------------------------
  static const List<String> turkiyeBolgeleri = [
    "İç Anadolu Bölgesi", "Marmara Bölgesi", "Ege Bölgesi",
    "Akdeniz Bölgesi", "Karadeniz Bölgesi", "Doğu Anadolu Bölgesi", "Güneydoğu Anadolu Bölgesi"
  ];

  static const Map<String, List<String>> turkiyeIlleri = {
    "İç Anadolu Bölgesi": ["Ankara", "Konya", "Kayseri", "Eskişehir", "Sivas", "Kırıkkale", "Aksaray", "Karaman", "Kırşehir", "Niğde", "Nevşehir", "Yozgat", "Çankırı"],
    "Marmara Bölgesi": ["İstanbul", "Bursa", "Kocaeli", "Balıkesir", "Sakarya", "Tekirdağ", "Çanakkale", "Edirne", "Kırklareli", "Yalova", "Bilecik"],
    "Ege Bölgesi": ["İzmir", "Manisa", "Aydın", "Denizli", "Muğla", "Afyonkarahisar", "Kütahya", "Uşak"],
    "Akdeniz Bölgesi": ["Antalya", "Adana", "Mersin", "Hatay", "Kahramanmaraş", "Osmaniye", "Isparta", "Burdur"],
    "Karadeniz Bölgesi": ["Samsun", "Trabzon", "Ordu", "Giresun", "Zonguldak", "Tokat", "Çorum", "Amasya", "Kastamonu", "Rize", "Artvin", "Sinop", "Bartın", "Karabük", "Düzce", "Bolu", "Gümüşhane", "Bayburt"],
    "Doğu Anadolu Bölgesi": ["Erzurum", "Malatya", "Van", "Elazığ", "Erzincan", "Kars", "Ağrı", "Muş", "Bitlis", "Bingöl", "Hakkari", "Iğdır", "Ardahan", "Tunceli"],
    "Güneydoğu Anadolu Bölgesi": ["Gaziantep", "Şanlıurfa", "Diyarbakır", "Batman", "Adıyaman", "Mardin", "Şırnak", "Siirt", "Kilis"]
  };

  // ---------------------------------------------------------
  // ✈️ YURT DIŞI (GLOBAL) İSKELETİ (EYALET / ŞEHİR BAZLI)
  // ---------------------------------------------------------
  static const Map<String, List<String>> dunyaSehirleri = {
    "Almanya": ["Berlin", "Münih", "Frankfurt", "Köln", "Hamburg", "Stuttgart", "Düsseldorf"],
    "Azerbaycan": ["Bakü", "Gence", "Sumgayıt", "Şeki", "Lankaran"],
    "Hollanda": ["Amsterdam", "Rotterdam", "Lahey", "Utrecht", "Eindhoven"],
    "Katar": ["Doha", "El Vakra", "El Havr", "Duhan"],
    "Birleşik Arap Emirlikleri": ["Dubai", "Abu Dabi", "Şarika", "Acman"]
  };

  // ---------------------------------------------------------
  // 🧠 KUANTUM AKILLI FİLTRELEME MOTORU (GÖRSEL ARAYÜZ İÇİN)
  // ---------------------------------------------------------
  static List<String> sehirleriGetir(String seciliUlke, {String? seciliBolge}) {
    if (seciliUlke == "Türkiye") {
      if (seciliBolge != null && turkiyeIlleri.containsKey(seciliBolge)) {
        return turkiyeIlleri[seciliBolge]!;
      }
      // Bölge seçilmemişse tüm Türkiye illerini tek bir listede birleştir (Arama motorları için)
      return turkiyeIlleri.values.expand((iller) => iller).toList();
    } else {
      return dunyaSehirleri[seciliUlke] ?? [];
    }
  }

  // ---------------------------------------------------------
  // 🔥 FİREBASE UYUMLU KAYIT YARDIMCISI (YENİ EKLENDİ)
  // ---------------------------------------------------------
  // Kullanıcı kaydolurken veya bayi eklerken bu veriyi Firebase'e hatasız yazmak için
  static Map<String, dynamic> firebaseKonumPaketi({
    required String ulke,
    String? bolge,
    required String sehir
  }) {
    return {
      "ulke": ulke,
      "bolge": ulke == "Türkiye" ? (bolge ?? "Belirtilmemiş") : "Yurt Dışı / Global",
      "sehir": sehir,
      "merkez_mesafe": ulke == globalMerkezUlkemiz && sehir == globalMerkezSehir ? "HQ (Merkez Üs)" : "Uzak Birim",
    };
  }
}