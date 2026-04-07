// lib/core/kuresel_harita_sistemi.dart

/// 🗺️ OTODNA KÜRESEL COĞRAFİ VERİ VE KONUM PROTOKOLÜ
/// Ankara/Türkiye merkez üssü üzerinden tüm dünya operasyonlarını yönetir.
class KureselHaritaSistemi {
  // 🇹🇷 KARARGAH MERKEZ ÜSSÜ (HQ)
  static const String globalMerkezUlkemiz = "Türkiye";
  static const String globalMerkezSehir = "Ankara";

  // 🌍 AKTİF OPERASYON SAHALARI (Ülke İskeleti)
  static const List<String> aktifUlkeler = [
    "Türkiye",
    "Almanya",
    "Azerbaycan",
    "Hollanda",
    "Katar",
    "Birleşik Arap Emirlikleri"
  ];

  // ---------------------------------------------------------
  // 🇹🇷 TÜRKİYE ALTYAPISI (7 STRATEJİK BÖLGE VE 81 İL)
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
  // ✈️ GLOBAL OPERASYON BÖLGELERİ (Yurt Dışı Şehirleri)
  // ---------------------------------------------------------
  static const Map<String, List<String>> dunyaSehirleri = {
    "Almanya": ["Berlin", "Münih", "Frankfurt", "Köln", "Hamburg", "Stuttgart", "Düsseldorf"],
    "Azerbaycan": ["Bakü", "Gence", "Sumgayıt", "Şeki", "Lankaran"],
    "Hollanda": ["Amsterdam", "Rotterdam", "Lahey", "Utrecht", "Eindhoven"],
    "Katar": ["Doha", "El Vakra", "El Havr", "Duhan"],
    "Birleşik Arap Emirlikleri": ["Dubai", "Abu Dabi", "Şarika", "Acman"]
  };

  // ---------------------------------------------------------
  // 🧠 KUANTUM AKILLI FİLTRELEME MOTORU (UI Entegrasyonu)
  // ---------------------------------------------------------
  static List<String> sehirleriGetir(String seciliUlke, {String? seciliBolge}) {
    if (seciliUlke == "Türkiye") {
      if (seciliBolge != null && turkiyeIlleri.containsKey(seciliBolge)) {
        return turkiyeIlleri[seciliBolge]!;
      }
      return turkiyeIlleri.values.expand((iller) => iller).toList();
    } else {
      return dunyaSehirleri[seciliUlke] ?? [];
    }
  }

  // ---------------------------------------------------------
  // 🔥 FİREBASE KONUM MÜHÜRLEYİCİ
  // ---------------------------------------------------------
  static Map<String, dynamic> firebaseKonumPaketi({
    required String ulke,
    String? bolge,
    required String sehir
  }) {
    return {
      "ulke": ulke,
      "bolge": ulke == "Türkiye" ? (bolge ?? "Bölge Belirtilmedi") : "Yurt Dışı",
      "sehir": sehir,
      "merkez_durumu": (ulke == globalMerkezUlkemiz && sehir == globalMerkezSehir)
          ? "KARARGAH (HQ)"
          : "DIŞ BİRİM",
      "kayit_tarihi": DateTime.now().toIso8601String(),
    };
  }
}