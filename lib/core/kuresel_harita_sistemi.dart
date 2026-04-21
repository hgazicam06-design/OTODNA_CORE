// lib/core/kuresel_harita_sistemi.dart

/// 🗺️ OTODNA KÜRESEL COĞRAFİ VERİ VE KONUM PROTOKOLÜ (V4 - ZIRHLI)
/// 4 Kademeli (Ülke -> Bölge/Eyalet -> Şehir -> İlçe) İstihbarat Motoru.
/// Ankara/Türkiye merkez üssü üzerinden tüm dünya operasyonlarını yönetir.
class KureselHaritaSistemi {
  // 🇹🇷 KARARGAH MERKEZ ÜSSÜ (HQ)
  static const String globalMerkezUlkemiz = "Türkiye";
  static const String globalMerkezSehir = "Ankara";

  // ---------------------------------------------------------
  // 🧠 KÜRESEL KUANTUM MATRİSİ (4 KADEMELİ VERİ AĞI)
  // ---------------------------------------------------------
  static const Map<String, Map<String, Map<String, List<String>>>> _kureselMatris = {
    "Türkiye": {
      "İç Anadolu Bölgesi": {
        "Ankara": ["Akyurt", "Altındağ", "Çankaya", "Keçiören", "Yenimahalle", "Mamak", "Sincan", "Etimesgut", "Gölbaşı"],
        "Konya": ["Karatay", "Meram", "Selçuklu", "Akşehir", "Ereğli"],
        "Kayseri": ["Kocasinan", "Melikgazi", "Talas", "Develi"],
        "Eskişehir": ["Odunpazarı", "Tepebaşı"],
        // SİBER NOT: Diğer İç Anadolu illeri...
      },
      "Marmara Bölgesi": {
        "İstanbul": ["Kadıköy", "Beşiktaş", "Şişli", "Bakırköy", "Üsküdar", "Maltepe", "Pendik", "Esenyurt"],
        "Bursa": ["Nilüfer", "Osmangazi", "Yıldırım", "Gemlik"],
        "Kocaeli": ["İzmit", "Gebze", "Gölcük"],
        // SİBER NOT: Diğer Marmara illeri...
      },
      "Ege Bölgesi": {
        "İzmir": ["Bornova", "Karşıyaka", "Konak", "Buca", "Çeşme", "Karabağlar"],
        "Manisa": ["Yunusemre", "Şehzadeler", "Akhisar", "Salihli"],
        // SİBER NOT: Diğer Ege illeri...
      },
      // SİBER NOT: Akdeniz, Karadeniz, Doğu ve G.Doğu Anadolu bölgeleri buraya eklenecek.
    },
    "Almanya": {
      "Bavyera Eyaleti": {
        "Münih": ["Altstadt", "Schwabing", "Maxvorstadt"],
        "Nürnberg": ["Mitte", "Süd", "Nord"]
      },
      "Kuzey Ren-Vestfalya": {
        "Köln": ["Innenstadt", "Rodenkirchen"],
        "Düsseldorf": ["Stadtbezirk 1", "Stadtbezirk 2"]
      },
      "Hessen": {
        "Frankfurt": ["Innenstadt", "Sachsenhausen", "Westend"]
      }
    },
    "Azerbaycan": {
      "Abşeron-Hızı Bölgesi": {
        "Bakü": ["Binagadi", "Karadağ", "Nizami", "Sabail"],
        "Sumgayıt": ["Merkez"]
      },
      "Gence-Daşkesen Bölgesi": {
        "Gence": ["Nizami", "Kepez"]
      }
    },
    "Hollanda": {
      "Kuzey Hollanda": {
        "Amsterdam": ["Centrum", "Noord", "Zuid", "Oost"]
      },
      "Güney Hollanda": {
        "Rotterdam": ["Centrum", "Delfshaven", "Kralingen"],
        "Lahey": ["Centrum", "Scheveningen"]
      }
    },
    "Katar": {
      "Doha Belediyesi": {
        "Doha": ["Al Dafna", "West Bay", "The Pearl"]
      },
      "El Vakra Belediyesi": {
        "El Vakra": ["Merkez"]
      }
    },
    "Birleşik Arap Emirlikleri": {
      "Dubai Emirliği": {
        "Dubai": ["Downtown", "Deira", "Jumeirah", "Marina"]
      },
      "Abu Dabi Emirliği": {
        "Abu Dabi": ["Corniche", "Yas Island", "Saadiyat"]
      }
    }
  };

  // ---------------------------------------------------------
  // 🚀 İSTİHBARAT ÇEKİCİLERİ (GÜVENLİ VE ZIRHLI GET METOTLARI)
  // ---------------------------------------------------------

  /// 1. AKTİF ÜLKELERİ GETİRİR
  static List<String> ulkeleriGetir() {
    return List.from(_kureselMatris.keys.toList()..sort());
  }

  /// 2. SEÇİLEN ÜLKENİN BÖLGE/EYALETLERİNİ GETİRİR
  static List<String> bolgeleriGetir(String ulke) {
    if (_kureselMatris.containsKey(ulke)) {
      return List.from(_kureselMatris[ulke]!.keys.toList()..sort());
    }
    return ["Bölge Bulunamadı"];
  }

  /// 3. SEÇİLEN BÖLGENİN ŞEHİRLERİNİ GETİRİR
  static List<String> sehirleriGetir(String ulke, String bolge) {
    if (_kureselMatris.containsKey(ulke) && _kureselMatris[ulke]!.containsKey(bolge)) {
      return List.from(_kureselMatris[ulke]![bolge]!.keys.toList()..sort());
    }
    return ["Şehir Bulunamadı"];
  }

  /// 4. SEÇİLEN ŞEHRİN İLÇELERİNİ GETİRİR
  static List<String> ilceleriGetir(String ulke, String bolge, String sehir) {
    if (_kureselMatris.containsKey(ulke) &&
        _kureselMatris[ulke]!.containsKey(bolge) &&
        _kureselMatris[ulke]![bolge]!.containsKey(sehir)) {
      return List.from(_kureselMatris[ulke]![bolge]![sehir]!..sort());
    }
    return ["Merkez"];
  }

  // ---------------------------------------------------------
  // 🎯 TERS İSTİHBARAT RADARI
  // ---------------------------------------------------------
  static String hangiBolgede(String ulke, String sehir) {
    if (!_kureselMatris.containsKey(ulke)) return "TANIMSIZ_ÜLKE";

    var bolgeler = _kureselMatris[ulke]!;
    for (var bolgeAdi in bolgeler.keys) {
      if (bolgeler[bolgeAdi]!.keys.contains(sehir)) {
        return bolgeAdi;
      }
    }
    return "TANIMSIZ_BÖLGE";
  }

  // ---------------------------------------------------------
  // 🔥 FİREBASE KONUM MÜHÜRLEYİCİ (ATOMİK PAKET)
  // ---------------------------------------------------------
  static Map<String, dynamic> firebaseKonumPaketi({
    required String ulke,
    String? bolge,
    required String sehir,
    String? ilce, // Yeni 4. Kademe Eklendi!
  }) {
    // Bölge girilmediyse otonom olarak bul
    String kesinBolge = bolge ?? hangiBolgede(ulke, sehir);

    return {
      "ulke": ulke,
      "bolge": kesinBolge,
      "sehir": sehir,
      "ilce": ilce ?? "Merkez",
      "merkez_durumu": (ulke == globalMerkezUlkemiz && sehir == globalMerkezSehir)
          ? "KARARGAH (HQ)"
          : "DIŞ BİRİM",
      "koordinat_guncelleme_tarihi": DateTime.now().toIso8601String(),
    };
  }
}