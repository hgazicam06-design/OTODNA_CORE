import 'package:cloud_firestore/cloud_firestore.dart';

/// 🦅 OTODNA KUANTUM CÜZDAN, BİLANÇO VE HAKEDİŞ MOTORU
/// Bu model, esnafın siber kasasını ve sistemin %12 (veya %30) payını yönetir.

// ---------------------------------------------------------
// 1. İŞLEM KALEMİ (CÜZDAN GEÇMİŞİ - SİBER MAKBUZ)
// ---------------------------------------------------------
class OtoDNA_Islem {
  final String islemId;
  final DateTime tarih;
  final double tutar;
  final String aciklama; // Örn: "Fiat Egea Balata Satışı"
  final bool gelirMi; // Esnafa para girdiyse true, biz komisyon kestiysek false

  OtoDNA_Islem({
    required this.islemId,
    required this.tarih,
    required this.tutar,
    required this.aciklama,
    this.gelirMi = true,
  });

  // 🚀 FİREBASE'E MÜHÜRLEME
  Map<String, dynamic> toMap() {
    return {
      'islem_id': islemId,
      'tarih': Timestamp.fromDate(tarih),
      'tutar': tutar,
      'aciklama': aciklama,
      'gelir_mi': gelirMi,
    };
  }

  // 📥 ANALİTİK OKUMA
  factory OtoDNA_Islem.fromMap(Map<String, dynamic> map) {
    return OtoDNA_Islem(
      islemId: map['islem_id'] ?? '',
      tarih: (map['tarih'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tutar: (map['tutar'] ?? 0).toDouble(),
      aciklama: map['aciklama'] ?? 'Belirtilmedi',
      gelirMi: map['gelir_mi'] ?? true,
    );
  }
}

// ---------------------------------------------------------
// 2. ANA CÜZDAN (ESNAF BİLANÇOSU VE GAZİ KASASI)
// ---------------------------------------------------------
class OtoDNA_Wallet {
  final String? id; // Firebase Document ID (Dükkan ID ile eşleşir)
  final String dukkanId;

  // 🕸️ KUANTUM İSTİHBARAT AĞI (4 KATMANLI ADLİ KONUM)
  // Bu cüzdan/esnaf nerede faaliyet gösteriyor? Finansal bölge analizleri için zorunlu.
  final String countryId;
  final String regionId;
  final String cityId;
  final String districtId;

  // 💰 BİLANÇO VE MUHASEBE (Siber Zırhlı)
  final double toplamBakiye;    // Sisteme giren brüt para
  final double netKarPayi;      // Bizim %10'luk net kısmımız
  final double vergiPayi;       // Devlet için ayrılan %2'lik kısım
  final double esnafHakedis;    // Esnafa kalan net hakediş

  final List<OtoDNA_Islem> gecmisIslemler;

  OtoDNA_Wallet({
    this.id,
    required this.dukkanId,
    required this.countryId,
    required this.regionId,
    required this.cityId,
    required this.districtId,
    this.toplamBakiye = 0.0,
    this.netKarPayi = 0.0,
    this.vergiPayi = 0.0,
    this.esnafHakedis = 0.0,
    this.gecmisIslemler = const [],
  });

  // 🛡️ SİSTEMİN TOPLAM PAYI (%12 Kuralı: %10 Kâr + %2 Vergi)
  double get toplamKesinti => netKarPayi + vergiPayi;

  // 🚀 FİREBASE'E YAZMA MOTORU (Atomik Güncelleme İçin)
  Map<String, dynamic> toMap() {
    return {
      'dukkan_id': dukkanId,
      'country_id': countryId,
      'region_id': regionId,
      'city_id': cityId,
      'district_id': districtId,
      'toplam_bakiye': toplamBakiye,
      'net_kar_payi': netKarPayi,
      'vergi_payi': vergiPayi,
      'esnaf_hakedis': esnafHakedis,
      'gecmis_islemler': gecmisIslemler.map((islem) => islem.toMap()).toList(),
      'son_guncellenme': FieldValue.serverTimestamp(),
    };
  }

  // 📥 FİREBASE'DEN OKUMA MOTORU
  factory OtoDNA_Wallet.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    var islemListesi = (data['gecmis_islemler'] as List<dynamic>?) ?? [];

    return OtoDNA_Wallet(
      id: doc.id,
      dukkanId: data['dukkan_id'] ?? '',
      countryId: data['country_id'] ?? 'TR',
      regionId: data['region_id'] ?? '',
      cityId: data['city_id'] ?? '',
      districtId: data['district_id'] ?? '',
      toplamBakiye: (data['toplam_bakiye'] ?? 0).toDouble(),
      netKarPayi: (data['net_kar_payi'] ?? 0).toDouble(),
      vergiPayi: (data['vergi_payi'] ?? 0).toDouble(),
      esnafHakedis: (data['esnaf_hakedis'] ?? 0).toDouble(),
      gecmisIslemler: islemListesi
          .map((item) => OtoDNA_Islem.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}