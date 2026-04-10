import 'package:cloud_firestore/cloud_firestore.dart';

/// 🦅 OTODNA KUANTUM FORUM VERİ MODELİ
/// Kullanıcıların kronik sorunları paylaştığı ve siber veri topladığı çekirdek yapı.
class ForumPost {
  final String? id;
  final String yazarId;
  final String yazarAdi;
  final String aracModeli;
  final String baslik;
  final String icerik;
  final int ayniDertSayisi;
  final DateTime tarih;

  ForumPost({
    this.id,
    required this.yazarId,
    required this.yazarAdi,
    required this.aracModeli,
    required this.baslik,
    required this.icerik,
    this.ayniDertSayisi = 0,
    DateTime? tarih,
  }) : tarih = tarih ?? DateTime.now();

  // 🔥 FİREBASE'E ATOMİK YAZMA MOTORU
  Map<String, dynamic> toMap() {
    return {
      'yazar_id': yazarId,
      'yazar_adi': yazarAdi,
      'arac_modeli': aracModeli,
      'baslik': baslik,
      'icerik': icerik,
      'ayni_dert_sayisi': ayniDertSayisi,
      'tarih': FieldValue.serverTimestamp(),
    };
  }

  // 📥 FİREBASE'DEN ANALİTİK OKUMA MOTORU
  factory ForumPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ForumPost(
      id: doc.id,
      yazarId: data['yazar_id'] ?? '',
      yazarAdi: data['yazar_adi'] ?? 'Gizli Kullanıcı',
      aracModeli: data['arac_modeli'] ?? 'Bilinmeyen Araç',
      baslik: data['baslik'] ?? '',
      icerik: data['icerik'] ?? '',
      ayniDertSayisi: (data['ayni_dert_sayisi'] ?? 0).toInt(),
      tarih: (data['tarih'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}