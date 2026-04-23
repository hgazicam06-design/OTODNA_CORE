import 'package:cloud_firestore/cloud_firestore.dart';

/// 🌍 OTODNA GLOBAL KONUM VE SİGORTA İSTİHBARAT MİMARİSİ
/// Bu dosya, 1MB limitini aşmamak için "Flat (Parçalanmış)" mimariyle yazılmıştır.
/// Ülke > Bölge > Şehir > İlçe olmak üzere 4 katmanlı mikro-istihbarat içerir.

// ---------------------------------------------------------
// 1. ÜLKE BİRİMİ (FİNANS VE OPERASYON MERKEZİ)
// Koleksiyon: /countries/{countryId}
// ---------------------------------------------------------
class Country {
  final String? id;
  final String name; // Türkiye, Germany vb.
  final String code; // TR, DE
  
  // 💰 GLOBAL FİNANS VE VERGİ SİSTEMİ
  final String paraBirimi; // TRY, EUR, USD
  final String zamanDilimi; // Europe/Istanbul
  final double varsayilanKomisyonOrani; // Ülkeye özel komisyon (Örn: Türkiye için 0.12)

  // 🚀 KILL SWITCH
  final bool operasyonaAcikMi;
  final DateTime guncellemeTarihi;

  Country({
    this.id,
    required this.name,
    required this.code,
    this.paraBirimi = 'TRY',
    this.zamanDilimi = 'Europe/Istanbul',
    this.varsayilanKomisyonOrani = 0.12,
    this.operasyonaAcikMi = true,
    DateTime? guncellemeTarihi,
  }) : guncellemeTarihi = guncellemeTarihi ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code.toUpperCase(),
      'para_birimi': paraBirimi,
      'zaman_dilimi': zamanDilimi,
      'varsayilan_komisyon_orani': varsayilanKomisyonOrani,
      'operasyona_acik_mi': operasyonaAcikMi,
      'guncelleme_tarihi': FieldValue.serverTimestamp(),
    };
  }

  factory Country.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Country(
      id: doc.id,
      name: data['name'] ?? 'Bilinmeyen Ülke',
      code: data['code'] ?? 'XX',
      paraBirimi: data['para_birimi'] ?? 'TRY',
      zamanDilimi: data['zaman_dilimi'] ?? 'Europe/Istanbul',
      varsayilanKomisyonOrani: (data['varsayilan_komisyon_orani'] ?? 0.12).toDouble(),
      operasyonaAcikMi: data['operasyona_acik_mi'] ?? false,
      guncellemeTarihi: (data['guncelleme_tarihi'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

// ---------------------------------------------------------
// 2. BÖLGE BİRİMİ (BAĞIMSIZ KOLEKSİYON)
// Koleksiyon: /regions/{regionId} VEYA /countries/{cId}/regions/{rId}
// ---------------------------------------------------------
class Region {
  final String? id;
  final String countryId; // İlişkisel Bağlantı (Foreign Key)
  final String name;

  Region({this.id, required this.countryId, required this.name});

  Map<String, dynamic> toMap() {
    return {
      'country_id': countryId,
      'name': name,
    };
  }

  factory Region.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Region(
      id: doc.id,
      countryId: data['country_id'] ?? '',
      name: data['name'] ?? 'Bilinmeyen Bölge',
    );
  }
}

// ---------------------------------------------------------
// 3. ŞEHİR BİRİMİ (GENEL İSTİHBARAT)
// Koleksiyon: /cities/{cityId}
// ---------------------------------------------------------
class City {
  final String? id;
  final String countryId; // Foreign Key
  final String regionId; // Foreign Key
  final String name;
  final int plateCode;
  final bool merkezUsMu;

  final GeoPoint? merkezKonum;

  // 📊 SİGORTA VE KAZA İSTİHBARAT KÜTÜPHANESİ (ŞEHİR GENEL TOPLAMI)
  final List<String> enCokBozulanParcalar;
  final List<String> kronikSorunlar;
  final List<GeoPoint> kazaKritikNoktalari;
  final int toplamArizaKaydi;
  final int toplamKazaKaydi;

  City({
    this.id,
    required this.countryId,
    required this.regionId,
    required this.name,
    required this.plateCode,
    this.merkezUsMu = false,
    this.merkezKonum,
    this.enCokBozulanParcalar = const [],
    this.kronikSorunlar = const [],
    this.kazaKritikNoktalari = const [],
    this.toplamArizaKaydi = 0,
    this.toplamKazaKaydi = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'country_id': countryId,
      'region_id': regionId,
      'name': name,
      'plate_code': plateCode,
      'merkez_us_mu': merkezUsMu,
      'merkez_konum': merkezKonum,
      'sigorta_istihbarati': {
        'en_cok_bozulan_parcalar': enCokBozulanParcalar,
        'kronik_sorunlar': kronikSorunlar,
        'kaza_kritik_noktalari': kazaKritikNoktalari,
        'toplam_ariza_kaydi': toplamArizaKaydi,
        'toplam_kaza_kaydi': toplamKazaKaydi,
      }
    };
  }

  factory City.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final istihbarat = data['sigorta_istihbarati'] as Map<String, dynamic>? ?? {};

    return City(
      id: doc.id,
      countryId: data['country_id'] ?? '',
      regionId: data['region_id'] ?? '',
      name: data['name'] ?? 'Bilinmeyen Şehir',
      plateCode: (data['plate_code'] ?? 0).toInt(),
      merkezUsMu: data['merkez_us_mu'] ?? false,
      merkezKonum: data['merkez_konum'] as GeoPoint?,
      enCokBozulanParcalar: List<String>.from(istihbarat['en_cok_bozulan_parcalar'] ?? []),
      kronikSorunlar: List<String>.from(istihbarat['kronik_sorunlar'] ?? []),
      kazaKritikNoktalari: List<GeoPoint>.from(istihbarat['kaza_kritik_noktalari'] ?? []),
      toplamArizaKaydi: (istihbarat['toplam_ariza_kaydi'] ?? 0).toInt(),
      toplamKazaKaydi: (istihbarat['toplam_kaza_kaydi'] ?? 0).toInt(),
    );
  }
}

// ---------------------------------------------------------
// 4. İLÇE BİRİMİ (MİKRO-İSTİHBARAT VE HEDEF ODAKLI BIG DATA)
// Koleksiyon: /districts/{districtId}
// ---------------------------------------------------------
class District {
  final String? id;
  final String countryId; // Saniyeler içinde global sorgu için Foreign Key
  final String regionId; // Bölge çapında sorgu için Foreign Key
  final String cityId; // Şehre özel sorgu için Foreign Key
  
  final String name; // Örn: 'Maslak', 'Beşiktaş'
  
  // 📍 MİKRO HARİTA DESTEĞİ
  final GeoPoint? merkezKonum; // İlçenin tam koordinatı

  // 🎯 SİGORTA ŞİRKETLERİ İÇİN NOKTA ATIŞI MİKRO-İSTİHBARAT
  final List<String> enCokBozulanParcalar; // "Maslak'ta en çok X bozuluyor"
  final List<String> kronikSorunlar;
  final List<GeoPoint> kazaKritikNoktalari; // Keskin virajlar, kör noktalar
  final int toplamArizaKaydi;
  final int toplamKazaKaydi;

  District({
    this.id,
    required this.countryId,
    required this.regionId,
    required this.cityId,
    required this.name,
    this.merkezKonum,
    this.enCokBozulanParcalar = const [],
    this.kronikSorunlar = const [],
    this.kazaKritikNoktalari = const [],
    this.toplamArizaKaydi = 0,
    this.toplamKazaKaydi = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'country_id': countryId,
      'region_id': regionId,
      'city_id': cityId,
      'name': name,
      'merkez_konum': merkezKonum,
      'sigorta_istihbarati': {
        'en_cok_bozulan_parcalar': enCokBozulanParcalar,
        'kronik_sorunlar': kronikSorunlar,
        'kaza_kritik_noktalari': kazaKritikNoktalari,
        'toplam_ariza_kaydi': toplamArizaKaydi,
        'toplam_kaza_kaydi': toplamKazaKaydi,
      }
    };
  }

  factory District.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final istihbarat = data['sigorta_istihbarati'] as Map<String, dynamic>? ?? {};

    return District(
      id: doc.id,
      countryId: data['country_id'] ?? '',
      regionId: data['region_id'] ?? '',
      cityId: data['city_id'] ?? '',
      name: data['name'] ?? 'Bilinmeyen İlçe',
      merkezKonum: data['merkez_konum'] as GeoPoint?,
      enCokBozulanParcalar: List<String>.from(istihbarat['en_cok_bozulan_parcalar'] ?? []),
      kronikSorunlar: List<String>.from(istihbarat['kronik_sorunlar'] ?? []),
      kazaKritikNoktalari: List<GeoPoint>.from(istihbarat['kaza_kritik_noktalari'] ?? []),
      toplamArizaKaydi: (istihbarat['toplam_ariza_kaydi'] ?? 0).toInt(),
      toplamKazaKaydi: (istihbarat['toplam_kaza_kaydi'] ?? 0).toInt(),
    );
  }
}