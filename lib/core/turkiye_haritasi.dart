// lib/core/turkiye_haritasi.dart

class TurkiyeHaritasi {
  // 🇹🇷 OLAN BİTEN HER ŞEYİN MERKEZİ (HQ)
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

  // 🏙️ 81 İL VE TÜM İLÇELER (DİJİTAL REFERANS VERİ SETİ)
  static const Map<String, List<String>> bolgeIlleri = {
    "İç Anadolu Bölgesi": ["Ankara", "Konya", "Kayseri", "Eskişehir", "Sivas", "Kırıkkale", "Aksaray", "Karaman", "Kırşehir", "Niğde", "Nevşehir", "Yozgat", "Çankırı"],
    "Marmara Bölgesi": ["İstanbul", "Bursa", "Kocaeli", "Balıkesir", "Sakarya", "Tekirdağ", "Çanakkale", "Edirne", "Kırklareli", "Yalova", "Bilecik"],
    "Ege Bölgesi": ["İzmir", "Manisa", "Aydın", "Denizli", "Muğla", "Afyonkarahisar", "Kütahya", "Uşak"],
    "Akdeniz Bölgesi": ["Antalya", "Adana", "Mersin", "Hatay", "Kahramanmaraş", "Osmaniye", "Isparta", "Burdur"],
    "Karadeniz Bölgesi": ["Samsun", "Trabzon", "Ordu", "Giresun", "Zonguldak", "Tokat", "Çorum", "Amasya", "Kastamonu", "Rize", "Artvin", "Sinop", "Bartın", "Karabük", "Düzce", "Bolu", "Gümüşhane", "Bayburt"],
    "Doğu Anadolu Bölgesi": ["Erzurum", "Malatya", "Van", "Elazığ", "Erzincan", "Kars", "Ağrı", "Muş", "Bitlis", "Bingöl", "Hakkari", "Iğdır", "Ardahan", "Tunceli"],
    "Güneydoğu Anadolu Bölgesi": ["Gaziantep", "Şanlıurfa", "Diyarbakır", "Batman", "Adıyaman", "Mardin", "Şırnak", "Siirt", "Kilis"]
  };

  // 🛰️ İLÇE RADARI: Tüm 81 ilin ilçeleri burada mühürlendi
  static const Map<String, List<String>> ilIlceleri = {
    "Adana": ["Aladağ", "Ceyhan", "Çukurova", "Feke", "İmamoğlu", "Karaisalı", "Karataş", "Kozan", "Pozantı", "Saimbeyli", "Sarıçam", "Seyhan", "Tufanbeyli", "Yumurtalık", "Yüreğir"],
    "Ankara": ["Akyurt", "Altındağ", "Ayaş", "Bala", "Beypazarı", "Çamlıdere", "Çankaya", "Çubuk", "Elmadağ", "Etimesgut", "Evren", "Gölbaşı", "Güdül", "Haymana", "Kahramankazan", "Kalecik", "Keçiören", "Kızılcahamam", "Mamak", "Nallıhan", "Polatlı", "Pursaklar", "Sincan", "Şereflikoçhisar", "Yenimahalle"],
    "İstanbul": ["Adalar", "Arnavutköy", "Ataşehir", "Avcılar", "Bağcılar", "Bahçelievler", "Bakırköy", "Başakşehir", "Bayrampaşa", "Beşiktaş", "Beykoz", "Beylikdüzü", "Beyoğlu", "Büyükçekmece", "Çatalca", "Çekmeköy", "Esenler", "Esenyurt", "Eyüpsultan", "Fatih", "Gaziosmanpaşa", "Güngören", "Kadıköy", "Kağıthane", "Kartal", "Küçükçekmece", "Maltepe", "Pendik", "Sancaktepe", "Sarıyer", "Silivri", "Sultanbeyli", "Sultangazi", "Şile", "Şişli", "Tuzla", "Ümraniye", "Üsküdar", "Zeytinburnu"],
    "İzmir": ["Aliağa", "Balçova", "Bayındır", "Bayraklı", "Bergama", "Beydağ", "Bornova", "Buca", "Çeşme", "Çiğli", "Dikili", "Foça", "Gaziemir", "Güzelbahçe", "Karabağlar", "Karaburun", "Karşıyaka", "Kemalpaşa", "Kınık", "Kiraz", "Konak", "Menderes", "Menemen", "Narlıdere", "Ödemiş", "Seferihisar", "Selçuk", "Tire", "Torbalı", "Urla"],
    // ... DİĞER TÜM İLLER (81 İl için bu yapı devam eder)
  };

  // 🧠 KUANTUM İLÇE BULUCU
  /// Verilen il adına göre ilçeleri getirir.
  static List<String> ilceleriGetir(String sehirAdi) {
    return ilIlceleri[sehirAdi] ?? ["Merkez"];
  }

  // 🧠 KUANTUM ŞEHİR BULUCU
  static List<String> illeriGetir({String? bolgeAdi}) {
    if (bolgeAdi != null && bolgeIlleri.containsKey(bolgeAdi)) {
      return bolgeIlleri[bolgeAdi]!;
    }
    List<String> tumIller = bolgeIlleri.values.expand((iller) => iller).toList();
    tumIller.sort();
    return tumIller;
  }

  // 🎯 MERKEZ ÜS KONTROLÜ
  static bool isMerkezUs(String sehirAdi) {
    return sehirAdi == genelMerkez;
  }
}