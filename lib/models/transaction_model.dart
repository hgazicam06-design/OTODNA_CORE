import 'package:cloud_firestore/cloud_firestore.dart';

/// 🦅 OTODNA KUANTUM SİBER KASA VE MUHASEBE MOTORU
/// Bu model, her finansal işlemin (Parça satışı, Randevu, Abonelik) dijital kaydını tutar.
class TransactionRecord {
  final String? id; // Firebase Document ID
  final String firmId;
  final String firmAdi;
  final String islemTipi; // Örn: "Yedek Parça Satışı", "Randevu Bedeli", "VIP Abonelik"

  // 🕸️ KUANTUM İSTİHBARAT AĞI (4 KATMANLI ADLİ KONUM)
  // Bu finansal işlem nerede gerçekleşti? Finansal ısı haritası için zorunlu.
  final String countryId;
  final String regionId;
  final String cityId;
  final String districtId;

  // 💰 FİNANSAL BÖLÜNME (MUHASEBE MÜHRÜ)
  final double toplamTutar; // Müşterinin ödediği brüt miktar
  final double otodnaPayi; // Bizim payımız (%12 Standart veya %30 Murat Plaza / Sabit Bedel)
  final double esnafHakedisi; // Esnafın hesabına aktarılacak net miktar

  final String durum; // 'Bekliyor', 'Onaylandı', 'Tamamlandı', 'İptal'
  final DateTime tarih;

  TransactionRecord({
    this.id,
    required this.firmId,
    required this.firmAdi,
    required this.islemTipi,
    required this.countryId,
    required this.regionId,
    required this.cityId,
    required this.districtId,
    required this.toplamTutar,
    required this.otodnaPayi,
    required this.esnafHakedisi,
    this.durum = 'Bekliyor',
    DateTime? tarih,
  }) : tarih = tarih ?? DateTime.now();

  // 🚀 FİREBASE'E ATOMİK YAZMA MOTORU
  // İşlem gerçekleştiği an veritabanına geri dönülemez şekilde mühürlenir.
  Map<String, dynamic> toMap() {
    return {
      'firm_id': firmId,
      'firm_adi': firmAdi,
      'islem_tipi': islemTipi,
      'country_id': countryId,
      'region_id': regionId,
      'city_id': cityId,
      'district_id': districtId,
      'toplam_tutar': toplamTutar,
      'otodna_payi': otodnaPayi,
      'esnaf_hakedisi': esnafHakedisi,
      'durum': durum,
      'tarih': FieldValue.serverTimestamp(), // Sunucu saati ile kesin kayıt
    };
  }

  // 📥 FİREBASE'DEN ANALİTİK OKUMA MOTORU
  // Admin veya Esnaf cüzdanını açtığında veriler siber hızla dökülür.
  factory TransactionRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return TransactionRecord(
      id: doc.id,
      firmId: data['firm_id'] ?? '',
      firmAdi: data['firm_adi'] ?? 'Gizli Firma',
      islemTipi: data['islem_tipi'] ?? 'Bilinmeyen İşlem',
      countryId: data['country_id'] ?? 'TR',
      regionId: data['region_id'] ?? '',
      cityId: data['city_id'] ?? '',
      districtId: data['district_id'] ?? '',
      toplamTutar: (data['toplam_tutar'] ?? 0).toDouble(),
      otodnaPayi: (data['otodna_payi'] ?? 0).toDouble(),
      esnafHakedisi: (data['esnaf_hakedisi'] ?? 0).toDouble(),
      durum: data['durum'] ?? 'Bekliyor',
      tarih: (data['tarih'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}