import 'package:cloud_firestore/cloud_firestore.dart';

/// 🦅 OTODNA KUANTUM FORUM VERİ MODELİ
/// Otomotiv dünyasının kronik sorunlarını, teşhislerini ve çözümlerini
/// global ölçekte (4 Katmanlı Konum ile) depolayan "Siber Bilgi Ansiklopedisi".
class ForumPost {
  final String? id;
  final String yazarId;
  final String yazarAdi;
  final String aracModeli;
  
  // 🕸️ KUANTUM İSTİHBARAT AĞI (4 KATMANLI LOKASYON)
  // Bir sorunun spesifik olarak hangi ilçe veya şehirde yaşandığını hedefler.
  final String countryId; 
  final String regionId; 
  final String cityId; 
  final String districtId; 

  final String kategori; // Örn: 'Motor', 'Şanzıman', 'Elektronik'

  final String baslik;
  final String icerik;

  // 📸 MEDYATİK KANITLAR
  final List<String> medyaUrlListesi; // Fotoğraf veya video (kronik ses) linkleri

  // ⚖️ ADALETLİ OYLAMA SİSTEMİ (Upvote Array)
  final List<String> ayniDertBendeDeVarIds; // Oy verenlerin ID'leri (Çift oyu engeller)
  
  // 💡 ÇÖZÜM ALGORİTMASI (StackOverflow Mantığı)
  final bool cozulduMu;
  final String? cozumIcerigi;
  final String? cozenUstaId; // Eğer bir yetkili garaj çözdüyse referans

  // 🤖 YAPAY ZEKA ANALİZİ
  final double aiKronikSkoru; // AI bu sorunun ne kadar yaygın olduğunu hesaplar (Örn: 88.5)

  final DateTime tarih;

  ForumPost({
    this.id,
    required this.yazarId,
    required this.yazarAdi,
    required this.aracModeli,
    required this.countryId,
    required this.regionId,
    required this.cityId,
    required this.districtId,
    this.kategori = 'Genel',
    required this.baslik,
    required this.icerik,
    this.medyaUrlListesi = const [],
    this.ayniDertBendeDeVarIds = const [],
    this.cozulduMu = false,
    this.cozumIcerigi,
    this.cozenUstaId,
    this.aiKronikSkoru = 0.0,
    DateTime? tarih,
  }) : tarih = tarih ?? DateTime.now();

  // 🧮 GÜVENLİ SAYAÇ OKUYUCU (Getter)
  int get ayniDertSayisi => ayniDertBendeDeVarIds.length;

  // 🔥 FİREBASE'E ATOMİK YAZMA MOTORU
  Map<String, dynamic> toMap() {
    return {
      'yazar_id': yazarId,
      'yazar_adi': yazarAdi,
      'arac_modeli': aracModeli,
      'country_id': countryId,
      'region_id': regionId,
      'city_id': cityId,
      'district_id': districtId,
      'kategori': kategori,
      'baslik': baslik,
      'icerik': icerik,
      'medya_url_listesi': medyaUrlListesi,
      'ayni_dert_bende_de_var_ids': ayniDertBendeDeVarIds,
      'cozuldu_mu': cozulduMu,
      'cozum_icerigi': cozumIcerigi,
      'cozen_usta_id': cozenUstaId,
      'ai_kronik_skoru': aiKronikSkoru,
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
      countryId: data['country_id'] ?? '',
      regionId: data['region_id'] ?? '',
      cityId: data['city_id'] ?? '',
      districtId: data['district_id'] ?? '',
      kategori: data['kategori'] ?? 'Genel',
      baslik: data['baslik'] ?? '',
      icerik: data['icerik'] ?? '',
      medyaUrlListesi: List<String>.from(data['medya_url_listesi'] ?? []),
      ayniDertBendeDeVarIds: List<String>.from(data['ayni_dert_bende_de_var_ids'] ?? []),
      cozulduMu: data['cozuldu_mu'] ?? false,
      cozumIcerigi: data['cozum_icerigi'],
      cozenUstaId: data['cozen_usta_id'],
      aiKronikSkoru: (data['ai_kronik_skoru'] ?? 0.0).toDouble(),
      tarih: (data['tarih'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}