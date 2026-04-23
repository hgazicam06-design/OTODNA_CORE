import 'package:cloud_firestore/cloud_firestore.dart';

/// 🦅 OTODNA ÇELİK ÇEKİRDEK: KUANTUM SERVİS GEÇMİŞİ VE DNA RADARI
/// Aracın bakım loglarını, 4 katmanlı istihbarat konumunu ve yapay zeka tabanlı "Gelecek Bakım Radarı"nı (Kestirimci Bakım) yönetir.
class ServiceRecord {
  final String? id; // Firebase Document ID
  
  // 🚗 ARAÇ KİMLİĞİ
  final String saseNo; // DNA Anahtarı
  final String plaka;
  
  // 🏢 İŞLEMİ YAPAN TİCARİ BİRİM
  final String dukkanId; // Sistemdeki kayıtlı esnaf ID'si
  final String dukkanAdi; // Ekranda gösterilecek isim

  // 🕸️ KUANTUM İSTİHBARAT AĞI (4 KATMANLI ADLİ KONUM)
  // Bu servis işlemi nerede yapıldı? Sigorta kütüphanesini beslemek için zorunlu alan.
  final String countryId;
  final String regionId;
  final String cityId;
  final String districtId;

  // 🛠️ TEKNİK DETAYLAR (İŞ EMRİ)
  final int kilometre; // İşlem anındaki KM
  final List<String> yapilanIslemler; // Örn: ["Triger Seti", "Fren Balatası"]
  final String ustaNotu; // Esnafın kişisel notu
  final double toplamTutar; // Müşterinin şeffaf şekilde göreceği fatura bedeli

  // 📅 ZAMAN ÇİZELGESİ VE RADAR SENSÖRLERİ
  final DateTime islemTarihi; // Mühürlenme tarihi
  
  // SİBER RADAR DEĞİŞKENLERİ (İki modelin birleşimi)
  final int maintenanceIntervalKm; // Bir sonraki bakım periyodu (Örn: 10000 KM)
  final int reminderPeriodMonths; // Kaç ay sonra uyarılacak (Örn: 12 ay)

  ServiceRecord({
    this.id,
    required this.saseNo,
    required this.plaka,
    required this.dukkanId,
    required this.dukkanAdi,
    required this.countryId,
    required this.regionId,
    required this.cityId,
    required this.districtId,
    required this.kilometre,
    required this.yapilanIslemler,
    required this.toplamTutar,
    this.ustaNotu = '',
    this.maintenanceIntervalKm = 10000, // Varsayılan radar periyodu
    this.reminderPeriodMonths = 12, // Varsayılan süre
    DateTime? islemTarihi,
  }) : islemTarihi = islemTarihi ?? DateTime.now();

  // --- 🧠 KUANTUM RADAR SENSÖRLERİ (HESAPLANAN VERİLER) ---
  
  // 1. Bir sonraki bakımın gerçekleşeceği tahmini kilometre
  int get nextServiceKm => kilometre + maintenanceIntervalKm;

  // 2. Bir sonraki bakımın gerçekleşeceği son tarih (Aylık periyot eklenmiş hali)
  DateTime get nextReminderDate => islemTarihi.add(Duration(days: reminderPeriodMonths * 30));

  // 🚀 FİREBASE'E ATOMİK YAZMA MOTORU
  // Usta işlemi bitirdiği an, aracın siber defterine bu döküman mühürlenir.
  Map<String, dynamic> toMap() {
    return {
      'sase_no': saseNo.trim().toUpperCase(),
      'plaka': plaka.trim().toUpperCase(),
      'dukkan_id': dukkanId,
      'dukkan_adi': dukkanAdi,
      'country_id': countryId,
      'region_id': regionId,
      'city_id': cityId,
      'district_id': districtId,
      
      'kilometre': kilometre,
      'yapilan_islemler': yapilanIslemler,
      'usta_notu': ustaNotu,
      'toplam_tutar': toplamTutar,

      'maintenance_interval_km': maintenanceIntervalKm,
      'reminder_period_months': reminderPeriodMonths,

      // 📡 SİBER RADAR VERİLERİ (Cloud Functions ve CRM için)
      'next_service_km': nextServiceKm,
      'next_reminder_date': Timestamp.fromDate(nextReminderDate),

      'islem_tarihi': FieldValue.serverTimestamp(), // Bulut Saati
    };
  }

  // 📥 FİREBASE'DEN ANALİTİK OKUMA MOTORU
  // Kullanıcı "Siber Bakım Karnesi" ekranını açtığında verileri atomik olarak çeker.
  factory ServiceRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return ServiceRecord(
      id: doc.id,
      saseNo: data['sase_no'] ?? 'Bilinmiyor',
      plaka: data['plaka'] ?? 'PLAKA YOK',
      dukkanId: data['dukkan_id'] ?? '',
      dukkanAdi: data['dukkan_adi'] ?? 'Gizli Servis',
      countryId: data['country_id'] ?? 'TR',
      regionId: data['region_id'] ?? '',
      cityId: data['city_id'] ?? '',
      districtId: data['district_id'] ?? '',
      kilometre: (data['kilometre'] ?? 0).toInt(),
      yapilanIslemler: List<String>.from(data['yapilan_islemler'] ?? []),
      ustaNotu: data['usta_notu'] ?? '',
      toplamTutar: (data['toplam_tutar'] ?? 0).toDouble(),
      maintenanceIntervalKm: (data['maintenance_interval_km'] ?? 10000).toInt(),
      reminderPeriodMonths: (data['reminder_period_months'] ?? 12).toInt(),
      islemTarihi: (data['islem_tarihi'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}