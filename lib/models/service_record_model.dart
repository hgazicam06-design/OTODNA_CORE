import 'package:cloud_firestore/cloud_firestore.dart';

// service_record_model.dart - Kuantum Bakım ve Takip Radarı Motoru

class ServiceRecordModel {
  final String? id; // Firebase Document ID
  final String saseNo;
  final String plaka;
  final String dukkanId; // İşlemi yapan dükkanın sistem ID'si
  final String dukkanAdi;

  // 🛠️ TEKNİK BAKIM VERİLERİ
  final int currentKm;
  final int maintenanceInterval; // Örn: 10000, 15000 KM
  final String productsUsed; // Yağ, filtre markaları vb.
  final int reminderPeriodMonths; // Örn: 6 ay sonra uyar

  // 💰 FİNANS (SADECE KAYIT İÇİNDİR - ESNAFTAN KESİNTİ YAPILMAZ!)
  final double toplamTutar; // Müşterinin aracı için ne kadar harcadığını görmesi için

  // 📅 TARİHLER
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

  // 🧠 KUANTUM HATIRLATICI HESAPLAMALARI (Radar Sensörleri)
  int get nextServiceKm => currentKm + maintenanceInterval;
  DateTime get nextReminderDate => serviceDate.add(Duration(days: reminderPeriodMonths * 30));

  // 🚀 FİREBASE'E YAZMA MOTORU (Usta işlemi bitirdiğinde çalışır)
  Map<String, dynamic> toMap() {
    return {
      'sase_no': saseNo,
      'plaka': plaka.toUpperCase(),
      'dukkan_id': dukkanId,
      'dukkan_adi': dukkanAdi,
      'current_km': currentKm,
      'maintenance_interval': maintenanceInterval,
      'products_used': productsUsed,
      'reminder_period_months': reminderPeriodMonths,

      // 📡 RADAR İÇİN ÖZEL VERİ: Sunucu burayı tarayıp müşteriye bildirim atacak!
      'next_service_km': nextServiceKm,
      'next_reminder_date': Timestamp.fromDate(nextReminderDate),

      // 💰 Sadece defter kaydı, komisyon sıfır!
      'toplam_tutar': toplamTutar,
      'service_date': Timestamp.fromDate(serviceDate),
    };
  }

  // 📥 FİREBASE'DEN OKUMA MOTORU (Müşteri "Bakım Geçmişim" ekranını açtığında)
  factory ServiceRecordModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return ServiceRecordModel(
      id: doc.id,
      saseNo: data['sase_no'] ?? 'Bilinmiyor',
      plaka: data['plaka'] ?? 'PLAKA YOK',
      dukkanId: data['dukkan_id'] ?? '',
      dukkanAdi: data['dukkan_adi'] ?? 'Gizli Servis',
      currentKm: data['current_km'] ?? 0,
      maintenanceInterval: data['maintenance_interval'] ?? 10000,
      productsUsed: data['products_used'] ?? '',
      reminderPeriodMonths: data['reminder_period_months'] ?? 6,
      toplamTutar: (data['toplam_tutar'] ?? 0).toDouble(),
      serviceDate: (data['service_date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}