import 'package:cloud_firestore/cloud_firestore.dart';

/// 🌍 OTODNA GLOBAL KUANTUM KULÜP VERİ MODELİ
/// Milyonlarca kullanıcının marka/model bazlı birleştiği,
/// uluslararası ve çoklu yönetici destekli dijital klan yapısı.
class VehicleClub {
  final String? id;
  final String modelName;
  final String kurucuId;
  final List<String> adminIds;
  final List<String> moderatorIds;
  final List<String> yasakliUyeler;
  final String ulkeKodu; // Global sorgular için (örn: "TR", "EN", "GLOBAL")
  final int uyeSayisi;

  VehicleClub({
    this.id,
    required this.modelName,
    required this.kurucuId,
    required this.adminIds,
    this.moderatorIds = [],
    this.yasakliUyeler = [],
    this.ulkeKodu = "TR",
    this.uyeSayisi = 0,
  });

  // 🚀 FİREBASE'E ATOMİK YAZMA MOTORU (YENİ KULÜP KURULUŞU)
  Map<String, dynamic> toMap() {
    return {
      'model_name': modelName,
      'kurucu_id': kurucuId,
      'admin_ids': adminIds,
      'moderator_ids': moderatorIds,
      'yasakli_uyeler': yasakliUyeler,
      'ulke_kodu': ulkeKodu,
      'uye_sayisi': uyeSayisi,
      'kurulus_tarihi': FieldValue.serverTimestamp(),
    };
  }

  // 📥 FİREBASE'DEN ANALİTİK OKUMA MOTORU
  factory VehicleClub.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return VehicleClub(
      id: doc.id,
      modelName: data['model_name'] ?? 'BİLİNMEYEN KLAN',
      kurucuId: data['kurucu_id'] ?? '',
      adminIds: List<String>.from(data['admin_ids'] ?? []),
      moderatorIds: List<String>.from(data['moderator_ids'] ?? []),
      yasakliUyeler: List<String>.from(data['yasakli_uyeler'] ?? []),
      ulkeKodu: data['ulke_kodu'] ?? 'TR',
      uyeSayisi: (data['uye_sayisi'] ?? 0).toInt(),
    );
  }

  // 🛡️ SİBER YETKİ KONTROL MOTORU (SCALABLE)
  bool isUserAuthorized(String userId) {
    // Kurucu veya Admin listesindeyse tam yetkili
    return userId == kurucuId || adminIds.contains(userId);
  }

  // 🛡️ MODERATÖR KONTROL MOTORU
  bool isUserModerator(String userId) {
    // Moderatör ise kısıtlı yetkili
    return moderatorIds.contains(userId);
  }

  // 🚨 İHRAÇ KONTROLÜ
  bool isUserBanned(String userId) {
    return yasakliUyeler.contains(userId);
  }
}