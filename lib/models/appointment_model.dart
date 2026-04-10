import 'package:cloud_firestore/cloud_firestore.dart';

/// 🦅 OTODNA KUANTUM RANDEVU VE MÜŞTERİ YÖNLENDİRME MOTORU
/// Bu model, ustanın emeğinden kesinti yapmadan sistem hizmet bedeli üzerinden çalışır.
class RandevuModel {
  final String? id; // Firebase Document ID
  final String musteriId;
  final String dukkanId;
  final String dukkanAdi;

  // 📅 RANDEVU VE OPERASYON DETAYLARI
  final DateTime randevuTarihi;
  final String sikayetOzeti;
  final String durum; // Bekliyor, Onaylandı, Tamamlandı, İptal
  final DateTime? olusturulmaTarihi;

  // 💰 FİNANSAL PROTOKOL
  // Sistemin (OtoDNA) kasasına giren net hizmet bedeli
  final double randevuHizmetBedeli;
  final bool bedelOdendiMi;

  RandevuModel({
    this.id,
    required this.musteriId,
    required this.dukkanId,
    required this.dukkanAdi,
    required this.randevuTarihi,
    required this.sikayetOzeti,
    this.durum = "Bekliyor",
    required this.randevuHizmetBedeli,
    this.bedelOdendiMi = false,
    this.olusturulmaTarihi,
  });

  // 🚀 FİREBASE'E YAZMA MOTORU (ATOMİK KAYIT İÇİN)
  Map<String, dynamic> toMap() {
    return {
      'musteri_id': musteriId,
      'dukkan_id': dukkanId,
      'dukkan_adi': dukkanAdi,
      'randevu_tarihi': Timestamp.fromDate(randevuTarihi),
      'sikayet_ozeti': sikayetOzeti,
      'durum': durum,
      'randevu_hizmet_bedeli': randevuHizmetBedeli,
      'bedel_odendi_mi': bedelOdendiMi,
      'olusturulma_tarihi': olusturulmaTarihi != null
          ? Timestamp.fromDate(olusturulmaTarihi!)
          : FieldValue.serverTimestamp(),
    };
  }

  // 📥 FİREBASE'DEN OKUMA MOTORU (SİBER ANALİZ)
  factory RandevuModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return RandevuModel(
      id: doc.id,
      musteriId: data['musteri_id'] ?? '',
      dukkanId: data['dukkan_id'] ?? '',
      dukkanAdi: data['dukkan_adi'] ?? 'Gizli Karargah Servisi',
      randevuTarihi: (data['randevu_tarihi'] as Timestamp?)?.toDate() ?? DateTime.now(),
      sikayetOzeti: data['sikayet_ozeti'] ?? 'Arıza özeti belirtilmedi.',
      durum: data['durum'] ?? 'Bekliyor',
      randevuHizmetBedeli: (data['randevu_hizmet_bedeli'] ?? 0).toDouble(),
      bedelOdendiMi: data['bedel_odendi_mi'] ?? false,
      olusturulmaTarihi: (data['olusturulma_tarihi'] as Timestamp?)?.toDate(),
    );
  }
}