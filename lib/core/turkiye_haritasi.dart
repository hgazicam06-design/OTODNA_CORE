class TurkiyeHaritasi {
  // 🇹🇷 OLAN BİTEN HER ŞEYİN MERKEZİ
  static const String genelMerkez = "Ankara";

  // 🌍 7 STRATEJİK BÖLGE
  static const List<String> bolgeler = [
    "İç Anadolu Bölgesi",
    "Marmara Bölgesi",
    "Ege Bölgesi",
    "Akdeniz Bölgesi",
    "Karadeniz Bölgesi",
    "Doğu Anadolu Bölgesi",
    "Güneydoğu Anadolu Bölgesi"
  ];

  // 🏙️ 81 İL (BÖLGELERE GÖRE KATEGORİZE EDİLMİŞ TAM LİSTE)
  static const Map<String, List<String>> bolgeIlleri = {
    "İç Anadolu Bölgesi": ["Ankara", "Konya", "Kayseri", "Eskişehir", "Sivas", "Kırıkkale", "Aksaray", "Karaman", "Kırşehir", "Niğde", "Nevşehir", "Yozgat", "Çankırı"],
    "Marmara Bölgesi": ["İstanbul", "Bursa", "Kocaeli", "Balıkesir", "Sakarya", "Tekirdağ", "Çanakkale", "Edirne", "Kırklareli", "Yalova", "Bilecik"],
    "Ege Bölgesi": ["İzmir", "Manisa", "Aydın", "Denizli", "Muğla", "Afyonkarahisar", "Kütahya", "Uşak"],
    "Akdeniz Bölgesi": ["Antalya", "Adana", "Mersin", "Hatay", "Kahramanmaraş", "Osmaniye", "Isparta", "Burdur"],
    "Karadeniz Bölgesi": ["Samsun", "Trabzon", "Ordu", "Giresun", "Zonguldak", "Tokat", "Çorum", "Amasya", "Kastamonu", "Rize", "Artvin", "Sinop", "Bartın", "Karabük", "Düzce", "Bolu", "Gümüşhane", "Bayburt"],
    "Doğu Anadolu Bölgesi": ["Erzurum", "Malatya", "Van", "Elazığ", "Erzincan", "Kars", "Ağrı", "Muş", "Bitlis", "Bingöl", "Hakkari", "Iğdır", "Ardahan", "Tunceli"],
    "Güneydoğu Anadolu Bölgesi": ["Gaziantep", "Şanlıurfa", "Diyarbakır", "Batman", "Adıyaman", "Mardin", "Şırnak", "Siirt", "Kilis"]
  };

  // ---------------------------------------------------------
  // 🧠 KUANTUM ŞEHİR BULUCU (Arayüz ve Arama Motorları İçin)
  // ---------------------------------------------------------
  /// Verilen bölgeye ait illeri döndürür. Eğer bölge belirtilmezse tüm 81 ili alfabetik sırayla döndürür.
  static List<String> illeriGetir({String? bolgeAdi}) {
    if (bolgeAdi != null && bolgeIlleri.containsKey(bolgeAdi)) {
      return bolgeIlleri[bolgeAdi]!;
    }

    // Bölge belirtilmediyse, haritadaki tüm illeri tek bir listeye topla ve sırala
    List<String> tumIller = bolgeIlleri.values.expand((iller) => iller).toList();
    tumIller.sort(); // A-Z alfabetik sıralama
    return tumIller;
  }

  // ---------------------------------------------------------
  // 🎯 MERKEZ ÜS (HQ) KONTROLÜ
  // ---------------------------------------------------------
  /// Seçilen şehrin "Ankara" (Genel Merkez) olup olmadığını kontrol eder.
  /// (Admin panelinde veya lojistik hesaplamalarında kullanılabilir).
  static bool isMerkezUs(String sehirAdi) {
    return sehirAdi == genelMerkez;
  }
}