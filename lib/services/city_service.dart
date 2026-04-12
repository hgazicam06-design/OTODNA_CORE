import 'dart:developer' as developer;

/// 🛡️ KUANTUM COĞRAFİ İSTİHBARAT MOTORU (CityService)
/// Ankara Merkezli 7 Bölge, 81 İl, İlçeler ve Küresel Genişleme İskeleti
class CityService {
  // 🇹🇷 TÜRKİYE: 7 BÖLGE VE 81 İL (Eksiksiz Siber Harita)
  static const Map<String, List<String>> _turkiyeIller = {
    'İÇ ANADOLU (MERKEZ KARARGAH)': ['ANKARA', 'KONYA', 'KAYSERİ', 'ESKİŞEHİR', 'SİVAS', 'KIRIKKALE', 'AKSARAY', 'KARAMAN', 'KIRŞEHİR', 'NİĞDE', 'NEVŞEHİR', 'YOZGAT', 'ÇANKIRI'],
    'MARMARA': ['İSTANBUL', 'BURSA', 'KOCAELİ', 'BALIKESİR', 'TEKİRDAĞ', 'EDİRNE', 'KIRKLARELİ', 'ÇANAKKALE', 'YALOVA', 'SAKARYA', 'BİLECİK'],
    'EGE': ['İZMİR', 'MANİSA', 'AYDIN', 'DENİZLİ', 'MUĞLA', 'AFYONKARAHİSAR', 'KÜTAHYA', 'UŞAK'],
    'AKDENİZ': ['ANTALYA', 'ADANA', 'MERSİN', 'HATAY', 'OSMANİYE', 'KAHRAMANMARAŞ', 'BURDUR', 'ISPARTA'],
    'KARADENİZ': ['SAMSUN', 'TRABZON', 'ORDU', 'RİZE', 'BOLU', 'AMASYA', 'ARTVİN', 'BARTIN', 'BAYBURT', 'ÇORUM', 'DÜZCE', 'GİRESUN', 'GÜMÜŞHANE', 'KARABÜK', 'KASTAMONU', 'SİNOP', 'TOKAT', 'ZONGULDAK'],
    'GÜNEYDOĞU ANADOLU': ['GAZİANTEP', 'DİYARBAKIR', 'ŞANLIURFA', 'ADIYAMAN', 'BATMAN', 'KİLİS', 'MARDİN', 'SİİRT', 'ŞIRNAK'],
    'DOĞU ANADOLU': ['ERZURUM', 'MALATYA', 'ELAZIĞ', 'VAN', 'AĞRI', 'ARDAHAN', 'BİNGÖL', 'BİTLİS', 'ERZİNCAN', 'HAKKARİ', 'IĞDIR', 'KARS', 'MUŞ', 'TUNCELİ'],
  };

  // 🎯 SİBER İLÇE RADARI
  // Not: Sistemin hantallaşmaması için temel iskelet kurulmuştur.
  // İleride tüm ilçeler buraya veya Firebase'e eklenebilir.
  static const Map<String, List<String>> _turkiyeIlceler = {
    'ANKARA': ['ÇANKAYA', 'KEÇİÖREN', 'YENİMAHALLE', 'MAMAK', 'ETİMESGUT', 'SİNCAN', 'ALTINDAĞ', 'GÖLBAŞI', 'PURSAKLAR', 'POLATLI'],
    'İSTANBUL': ['KADIKÖY', 'ŞİŞLİ', 'BEŞİKTAŞ', 'ÜSKÜDAR', 'MALTEPE', 'PENDİK', 'ÜMRANİYE', 'KARTAL', 'BAKIRKÖY', 'ESENYURT', 'BEYLİKDÜZÜ'],
    'İZMİR': ['KONAK', 'KARŞIYAKA', 'BORNOVA', 'BUCA', 'ÇİĞLİ', 'GAZİEMİR', 'BALÇOVA', 'KARABAĞLAR', 'BAYRAKLI', 'ALİAĞA'],
    'BURSA': ['OSMANGAZİ', 'NİLÜFER', 'YILDIRIM', 'İNEGÖL', 'GEMLİK', 'MUDANYA', 'KESTEL', 'GÜRSU'],
    'ANTALYA': ['MURATPAŞA', 'KONYAALTI', 'KEPEZ', 'ALANYA', 'MANAVGAT', 'KEMER', 'SERİK', 'KAŞ'],
    // ... Diğer illerin ilçeleri bu listeye eklenecek
  };

  // 🌍 KÜRESEL GENİŞLEME İSKELETİ (Uluslararası Operasyonlar İçin)
  static const Map<String, Map<String, List<String>>> _kureselAg = {
    'TÜRKİYE': _turkiyeIller,
    // İleride 'ALMANYA' vb. eklenecek.
  };

  // ── 📡 İSTİHBARAT RADAR SORGULARI ──────────────────────────────────────────

  /// Hedef ülkedeki tüm illeri/eyaletleri alfabetik olarak radara yükler
  static List<String> tumIlleriGetir({String ulke = 'TÜRKİYE'}) {
    try {
      if (!_kureselAg.containsKey(ulke)) {
        developer.log("SİBER UYARI: $ulke Kuantum Ağında bulunamadı!");
        return [];
      }

      List<String> tumIller = _kureselAg[ulke]!.values.expand((il) => il).toList();
      tumIller.sort(); // Karargah düzeni için alfabetik mühür
      return tumIller;
    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Şehir istihbaratı çekilemedi!", error: e);
      // Hata fırlatılmaz, boş liste döner ki UI (Arayüz) çökmesin
      return [];
    }
  }

  /// 🎯 BELİRLİ BİR İLİN TÜM İLÇELERİNİ GETİRİR (YENİ SİBER PROTOKOL)
  static List<String> ilceleriGetir(String sehir) {
    try {
      String arananSehir = sehir.trim().toUpperCase();

      if (_turkiyeIlceler.containsKey(arananSehir)) {
        List<String> ilceler = List.from(_turkiyeIlceler[arananSehir]!);
        ilceler.sort(); // Harf sırasına sok
        return ilceler;
      } else {
        developer.log("SİBER BİLGİ: $arananSehir için ilçe detayı Kuantum Ağında (henüz) yok, merkez olarak atanıyor.");
        return ['MERKEZ']; // Eğer ilçe listesi henüz girilmediyse varsayılan döner
      }
    } catch (e) {
      developer.log("SİBER İHLAL: İlçe radarı çöktü!", error: e);
      return ['MERKEZ'];
    }
  }

  /// Sadece belirli bir bölgenin şehirlerini tarar (Örn: Sadece Ege bölgesi)
  static List<String> bolgeRadari(String bolge, {String ulke = 'TÜRKİYE'}) {
    if (!_kureselAg.containsKey(ulke)) return [];
    return _kureselAg[ulke]![bolge] ?? [];
  }

  /// Şehir arama motoru (Oto-Tamamlama ve filtreleme için Kuantum Tarayıcı)
  static List<String> sehirAra(String sorgu, {String ulke = 'TÜRKİYE'}) {
    if (sorgu.isEmpty) return tumIlleriGetir(ulke: ulke);

    String aranan = sorgu.trim().toUpperCase();
    return tumIlleriGetir(ulke: ulke)
        .where((il) => il.contains(aranan))
        .toList();
  }
}