import 'package:cloud_firestore/cloud_firestore.dart';

/// 🦅 OTODNA KUANTUM SERVİS GEÇMİŞİ VE İŞ EMRİ MOTORU
/// Bu model, aracın dijital servis defterini oluşturur ve "Takip Radarı"nı besler.
class ServiceRecord {
  final String? id; // Firebase Document ID
  final String saseNo; // Hangi araca işlem yapıldı? (DNA Anahtarı)
  final String plaka;
  final String dukkanId; // İşlemi yapan esnafın sistem ID'si
  final String dukkanAdi;

  // 🛠️ TEKNİK DETAYLAR
  final int kilometre;
  final List<String> yapilanIslemler; // Örn: ["Yağ değişimi", "Fren balatası"]
  final String ustaNotu;
  final double toplamTutar; // Müşterinin ödediği toplam fatura

  // 📅 ZAMAN ÇİZELGESİ VE RADAR
  final DateTime islemTarihi;
  final DateTime? sonrakiBakimTarihi; // Takip Radarı'nı tetikleyecek kritik tarih

  ServiceRecord({
    this.id,
    required this.saseNo,
    required this.plaka,
    required this.dukkanId,
    required this.dukkanAdi,
    required this.kilometre,
    required this.yapilanIslemler,
    required this.toplamTutar,
    required this.ustaNotu,
    DateTime? islemTarihi,
    this.sonrakiBakimTarihi,
  }) : islemTarihi = islemTarihi ?? DateTime.now();

  // 🚀 FİREBASE'E ATOMİK YAZMA MOTORU
  // Usta "İşlemi Bitir" dediği an dijital servis defterine kalıcı olarak mühürlenir.
  Map<String, dynamic> toMap() {
    return {
      'sase_no': saseNo.trim().toUpperCase(),
      'plaka': plaka.trim().toUpperCase(),
      'dukkan_id': dukkanId,
      'dukkan_adi': dukkanAdi,
      'kilometre': kilometre,
      'yapilan_islemler': yapilanIslemler,
      'usta_notu': ustaNotu,
      'toplam_tutar': toplamTutar,

      // 🛡️ TİCARET PROTOKOLÜ: Ustanın emeğinden %12 kesinti YAPILMAZ!
      // Bu kayıt, aracın şeffaflık puanını (DNA Skoru) artırır.
      // Komisyon motoru "Randevu" ve "Ekspertiz" üzerinden Gazi Kasası'na çalışır.

      'islem_tarihi': FieldValue.serverTimestamp(),
      'sonraki_bakim_tarihi': sonrakiBakimTarihi != null ? Timestamp.fromDate(sonrakiBakimTarihi!) : null,
    };
  }

  // 📥 FİREBASE'DEN ANALİTİK OKUMA MOTORU
  // Kullanıcı "Servis Geçmişim" ekranını açtığında verileri atomik olarak çeker.
  factory ServiceRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return ServiceRecord(
      id: doc.id,
      saseNo: data['sase_no'] ?? 'Bilinmiyor',
      plaka: data['plaka'] ?? 'PLAKA YOK',
      dukkanId: data['dukkan_id'] ?? '',
      dukkanAdi: data['dukkan_adi'] ?? 'Gizli Servis',
      kilometre: (data['kilometre'] ?? 0).toInt(),
      yapilanIslemler: List<String>.from(data['yapilan_islemler'] ?? []),
      toplamTutar: (data['toplam_tutar'] ?? 0).toDouble(),
      ustaNotu: data['usta_notu'] ?? '',
      islemTarihi: (data['islem_tarihi'] as Timestamp?)?.toDate() ?? DateTime.now(),
      sonrakiBakimTarihi: (data['sonraki_bakim_tarihi'] as Timestamp?)?.toDate(),
    );
  }
}