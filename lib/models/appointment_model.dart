import 'package:cloud_firestore/cloud_firestore.dart';

// appointment_model.dart - Kuantum Randevu ve Müşteri Yönlendirme Motoru

class RandevuModel {
  final String? id; // Firebase Document ID
  final String musteriId;
  final String dukkanId;
  final String dukkanAdi;

  // 📅 RANDEVU DETAYLARI
  final DateTime randevuTarihi;
  final String sikayetOzeti; // Müşterinin geliş sebebi
  final String durum; // Bekliyor, Onaylandı, Tamamlandı, İptal

  // 💰 YENİ FİNANS STRATEJİSİ: Ustanın emeğinden kesinti YOK!
  // Sistem, garantili randevu oluşturduğu için müşteriden hizmet bedeli alır.
  final double randevuHizmetBedeli; // Sistemin (OtoDNA) kasasına giren net para
  final bool bedelOdendiMi;

  RandevuModel({
    this.id,
    required this.musteriId,
    required this.dukkanId,
    required this.dukkanAdi,
    required this.randevuTarihi,
    required this.sikayetOzeti,
    this.durum = "Bekliyor",
    required this.randevuHizmetBedeli, // Örn: 99 TL
    this.bedelOdendiMi = false,
  });

  // 🚀 FİREBASE'E YAZMA MOTORU (Müşteri Randevu Aldığında)
  Map<String, dynamic> toMap() {
    return {
      'musteri_id': musteriId,
      'dukkan_id': dukkanId,
      'dukkan_adi': dukkanAdi,
      'randevu_tarihi': Timestamp.fromDate(randevuTarihi),
      'sikayet_ozeti': sikayetOzeti,
      'durum': durum,
      // OtoDNA Ana Kasasına aktarılacak miktar
      'randevu_hizmet_bedeli': randevuHizmetBedeli,
      'bedel_odendi_mi': bedelOdendiMi,
      'olusturulma_tarihi': FieldValue.serverTimestamp(),
    };
  }

  // 📥 FİREBASE'DEN OKUMA MOTORU (Usta Paneline Düşen Randevular)
  factory RandevuModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return RandevuModel(
      id: doc.id,
      musteriId: data['musteri_id'] ?? '',
      dukkanId: data['dukkan_id'] ?? '',
      dukkanAdi: data['dukkan_adi'] ?? 'Gizli Servis',
      randevuTarihi: (data['randevu_tarihi'] as Timestamp?)?.toDate() ?? DateTime.now(),
      sikayetOzeti: data['sikayet_ozeti'] ?? 'Belirtilmedi',
      durum: data['durum'] ?? 'Bekliyor',
      randevuHizmetBedeli: (data['randevu_hizmet_bedeli'] ?? 0).toDouble(),
      bedelOdendiMi: data['bedel_odendi_mi'] ?? false,
    );
  }
}