import 'package:cloud_firestore/cloud_firestore.dart';

// service_model.dart - Kuantum Servis Geçmişi ve İş Emri Motoru

class ServiceRecord {
  final String? id; // Firebase Document ID
  final String saseNo; // Hangi araca işlem yapıldı?
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
  final DateTime? sonrakiBakimTarihi; // Takip Radarı'nı tetikleyecek tarih

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

  // 🚀 FİREBASE'E YAZMA MOTORU (Usta "İşlemi Bitir" dediği an dijital servis defterine düşer)
  Map<String, dynamic> toMap() {
    return {
      'sase_no': saseNo,
      'plaka': plaka.toUpperCase(),
      'dukkan_id': dukkanId,
      'dukkan_adi': dukkanAdi,
      'kilometre': kilometre,
      'yapilan_islemler': yapilanIslemler,
      'usta_notu': ustaNotu,
      'toplam_tutar': toplamTutar,

      // 🌟 YENİ TİCARET KURALI: Ustanın emeğinden %12 kesinti YOK!
      // Komisyonu Randevu'dan alıyoruz. Burası sadece aracın resmi CV'sini oluşturur.

      'islem_tarihi': FieldValue.serverTimestamp(),
      'sonraki_bakim_tarihi': sonrakiBakimTarihi != null ? Timestamp.fromDate(sonrakiBakimTarihi!) : null,
    };
  }

  // 📥 FİREBASE'DEN OKUMA MOTORU (Kullanıcı "Servis Geçmişim" ekranını açtığında)
  factory ServiceRecord.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return ServiceRecord(
      id: doc.id,
      saseNo: data['sase_no'] ?? 'Bilinmiyor',
      plaka: data['plaka'] ?? 'PLAKA YOK',
      dukkanId: data['dukkan_id'] ?? '',
      dukkanAdi: data['dukkan_adi'] ?? 'Gizli Servis',
      kilometre: data['kilometre'] ?? 0,
      yapilanIslemler: List<String>.from(data['yapilan_islemler'] ?? []),
      toplamTutar: (data['toplam_tutar'] ?? 0).toDouble(),
      ustaNotu: data['usta_notu'] ?? '',
      islemTarihi: (data['islem_tarihi'] as Timestamp?)?.toDate() ?? DateTime.now(),
      sonrakiBakimTarihi: (data['sonraki_bakim_tarihi'] as Timestamp?)?.toDate(),
    );
  }
}