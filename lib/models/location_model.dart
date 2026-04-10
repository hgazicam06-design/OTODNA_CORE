import 'package:cloud_firestore/cloud_firestore.dart';

/// 🦅 OTODNA KUANTUM GLOBAL GENİŞLEME VE KONUM MOTORU
/// Bu model, global hiyerarşiyi (Ülke > Bölge > Şehir) ve operasyonel yetki alanlarını yönetir.

// ---------------------------------------------------------
// 1. ŞEHİR BİRİMİ (EN ALT KATMAN)
// ---------------------------------------------------------
class City {
  final String name; // Ankara, İstanbul vb.
  final int plateCode; // 06, 34 vb.
  final List<String> districts; // İlçeler
  final bool merkezUsMu; // "Ankara" için Ana Karargah (HQ) bayrağı

  City({
    required this.name,
    required this.plateCode,
    required this.districts,
    this.merkezUsMu = false,
  });

  // 🔥 SİBER MÜHÜR: Veriyi Firebase formatına çevirir
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'plate_code': plateCode,
      'districts': districts,
      // 🛡️ STRATEJİK KORUMA: Eğer şehir Ankara ise, sistemin merkez üssü olduğunu otomatik mühürler!
      'merkez_us_mu': name.trim().toLowerCase() == "ankara" ? true : merkezUsMu,
    };
  }

  // 📥 ANALİTİK OKUMA: Map verisini City nesnesine dönüştürür
  factory City.fromMap(Map<String, dynamic> map) {
    return City(
      name: map['name'] ?? 'Bilinmeyen Şehir',
      plateCode: map['plate_code'] ?? 0,
      districts: List<String>.from(map['districts'] ?? []),
      merkezUsMu: map['merkez_us_mu'] ?? false,
    );
  }
}

// ---------------------------------------------------------
// 2. BÖLGE BİRİMİ (ORTA KATMAN)
// ---------------------------------------------------------
class Region {
  final String name; // İç Anadolu, Marmara, Bavaria vb.
  final List<City> cities;

  Region({required this.name, required this.cities});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'cities': cities.map((c) => c.toMap()).toList(),
    };
  }

  factory Region.fromMap(Map<String, dynamic> map) {
    var cityList = (map['cities'] as List<dynamic>?) ?? [];
    return Region(
      name: map['name'] ?? 'Bilinmeyen Bölge',
      cities: cityList.map((c) => City.fromMap(c as Map<String, dynamic>)).toList(),
    );
  }
}

// ---------------------------------------------------------
// 3. ÜLKE BİRİMİ (EN ÜST KATMAN - FİREBASE ANA DÖKÜMANI)
// ---------------------------------------------------------
class Country {
  final String? id; // Firebase Document ID
  final String name; // Türkiye, Almanya, Azerbaycan vb.
  final String code; // TR, DE, AZ
  final List<Region> regions;

  // 🚀 OTODNA KUANTUM OPERASYON DURUMU (KILL SWITCH)
  final bool operasyonaAcikMi; // Eğer false ise o ülkede ticaret/komisyon motoru durur!
  final DateTime guncellemeTarihi;

  Country({
    this.id,
    required this.name,
    required this.code,
    required this.regions,
    this.operasyonaAcikMi = true,
    DateTime? guncellemeTarihi,
  }) : guncellemeTarihi = guncellemeTarihi ?? DateTime.now();

  // 🚀 FİREBASE'E ATOMİK YAZMA MOTORU
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code.toUpperCase(),
      'regions': regions.map((r) => r.toMap()).toList(),
      'operasyona_acik_mi': operasyonaAcikMi,
      'guncelleme_tarihi': FieldValue.serverTimestamp(),
    };
  }

  // 📥 FİREBASE'DEN ANALİTİK OKUMA MOTORU
  factory Country.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    var regionList = (data['regions'] as List<dynamic>?) ?? [];

    return Country(
      id: doc.id,
      name: data['name'] ?? 'Bilinmeyen Ülke',
      code: data['code'] ?? 'XX',
      regions: regionList.map((r) => Region.fromMap(r as Map<String, dynamic>)).toList(),
      operasyonaAcikMi: data['operasyona_acik_mi'] ?? false,
      guncellemeTarihi: (data['guncelleme_tarihi'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}