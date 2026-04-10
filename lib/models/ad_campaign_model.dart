import 'package:cloud_firestore/cloud_firestore.dart';

/// 🦅 OTODNA KUANTUM REKLAM VERİ MODELİ
/// Reklam tıklamaları doğrudan finansal raporlara %12 kuralıyla işlenir.
class OtoDNACampaign {
  final String id;
  final String sirketAd;
  final String kampanyaBaslik;
  final String gorselUrl;
  final String hedefLink;
  final int tiklanmaSayisi;
  final bool aktifMi;
  final DateTime? sonTiklanmaTarihi;

  OtoDNACampaign({
    required this.id,
    required this.sirketAd,
    required this.kampanyaBaslik,
    required this.gorselUrl,
    required this.hedefLink,
    required this.tiklanmaSayisi,
    required this.aktifMi,
    this.sonTiklanmaTarihi,
  });

  // 🛡️ FİREBASE'DEN GELEN VERİYİ MOLEKÜLLERİNE AYIRAN KALKAN
  factory OtoDNACampaign.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return OtoDNACampaign(
      id: doc.id,
      sirketAd: data['sirket_ad'] ?? 'Bilinmeyen Distribütör',
      kampanyaBaslik: data['kampanya_baslik'] ?? 'Kuantum Fırsatı',
      gorselUrl: data['gorsel_url'] ?? '',
      hedefLink: data['hedef_link'] ?? '',
      tiklanmaSayisi: data['tiklanma_sayisi'] ?? 0,
      aktifMi: data['aktif_mi'] ?? true,
      sonTiklanmaTarihi: (data['son_tiklanma_tarihi'] as Timestamp?)?.toDate(),
    );
  }

  // 📝 VERİ TABANINA YAZMAK İÇİN SİBER PAKETLEME
  Map<String, dynamic> toMap() {
    return {
      'sirket_ad': sirketAd,
      'kampanya_baslik': kampanyaBaslik,
      'gorsel_url': gorselUrl,
      'hedef_link': hedefLink,
      'tiklanma_sayisi': tiklanmaSayisi,
      'aktif_mi': aktifMi,
      'son_tiklanma_tarihi': sonTiklanmaTarihi != null ? Timestamp.fromDate(sonTiklanmaTarihi!) : null,
    };
  }
}