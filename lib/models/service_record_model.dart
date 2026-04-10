import 'package:cloud_firestore/cloud_firestore.dart';

/// 🦅 OTODNA KUANTUM BAKIM VE TAKİP RADARI MOTORU
/// Bu model, aracın bakım periyotlarını hesaplar ve siber bildirimler için veri üretir.
class ServiceRecordModel {
  final String? id; // Firebase Document ID
  final String saseNo;
  final String plaka;
  final String dukkanId; // İşlemi yapan dükkanın sistem ID'si
  final String dukkanAdi;

  // 🛠️ TEKNİK BAKIM VERİLERİ (RADAR YAKITI)
  final int currentKm;
  final int maintenanceInterval; // Örn: 10000, 15000 KM
  final String productsUsed; // Yağ, filtre markaları vb.
  final int reminderPeriodMonths; // Örn: 6 ay sonra uyar

  // 💰 FİNANS PROTOKOLÜ: Bu bir CV kaydıdır, sistem payı randevuda alınmıştır.
  final double toplamTutar; // Müşterinin şeffaf şekilde görmesi için

  // 📅 ZAMAN ÇİZELGESİ
  final DateTime serviceDate;

  ServiceRecordModel({
    this.id,
    required this.saseNo,
    required this.plaka,
    this.dukkanId = '',
    required this.dukkanAdi,
    required this.currentKm,
    required this.maintenanceInterval,
    required this.productsUsed,
    required this.reminderPeriodMonths,
    required this.toplamTutar,
    DateTime? serviceDate,
  }) : serviceDate = serviceDate ?? DateTime.now();

  // --- 🧠 KUANTUM RADAR SENSÖRLERİ (HESAPLANAN VERİLER) ---

  // Bir sonraki bakımın gerçekleşeceği tahmini kilometre
  int get nextServiceKm => currentKm + maintenanceInterval;

  // Bir sonraki bakımın gerçekleşeceği son tarih (Aylık periyot eklenmiş hali)
  DateTime get nextReminderDate => serviceDate.add(Duration(days: reminderPeriodMonths * 30));

  // 🚀 FİREBASE'E ATOMİK YAZMA MOTORU
  // Usta işlemi bitirdiği an, aracın siber defterine bu döküman mühürlenir.
  Map<String, dynamic> toMap() {
    return {
      'sase_no': saseNo.trim().toUpperCase(),
      'plaka': plaka.trim().toUpperCase(),
      'dukkan_id': dukkanId,
      'dukkan_adi': dukkanAdi,
      'current_km': currentKm,
      'maintenance_interval': maintenanceInterval,
      'products_used': productsUsed,
      'reminder_period_months': reminderPeriodMonths,

      // 📡 SİBER RADAR VERİLERİ: Sunucu taraflı tetikleyiciler (Cloud Functions) için hazır.
      'next_service_km': nextServiceKm,
      'next_reminder_date': Timestamp.fromDate(nextReminderDate),

      // 💰 Sadece kayıt amaçlı tutulur.
      'toplam_tutar': toplamTutar,
      'service_date': Timestamp.fromDate(serviceDate),
      'islem_kayit_tarihi': FieldValue.serverTimestamp(),
    };
  }

  // 📥 FİREBASE'DEN ANALİTİK OKUMA MOTORU
  factory ServiceRecordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return ServiceRecordModel(
      id: doc.id,
      saseNo: data['sase_no'] ?? 'Bilinmiyor',
      plaka: data['plaka'] ?? 'PLAKA YOK',
      dukkanId: data['dukkan_id'] ?? '',
      dukkanAdi: data['dukkan_adi'] ?? 'Gizli Servis',
      currentKm: (data['current_km'] ?? 0).toInt(),
      maintenanceInterval: (data['maintenance_interval'] ?? 10000).toInt(),
      productsUsed: data['products_used'] ?? '',
      reminderPeriodMonths: (data['reminder_period_months'] ?? 6).toInt(),
      toplamTutar: (data['toplam_tutar'] ?? 0).toDouble(),
      serviceDate: (data['service_date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}