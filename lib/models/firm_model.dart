import 'package:cloud_firestore/cloud_firestore.dart';

// firm_model.dart - Kuantum Firma Kimlik Kartı ve Siber Sicil Motoru

class Firm {
  final String? id; // Firebase Document ID
  final String name;
  final double rating; // 1 ile 5 arası yıldız

  // 🛡️ SİBER GÜVENLİK VE FİNANS MOTORU
  final bool isBlacklisted;
  final String? blacklistReason; // Kara liste sebebi (Siber Mahkeme Kaydı)
  final double komisyonOrani; // Murat Plaza %30, diğerleri %12
  final DateTime kayitTarihi;

  Firm({
    this.id,
    required this.name,
    required this.rating,
    this.isBlacklisted = false,
    this.blacklistReason,
    this.komisyonOrani = 0.12,
    DateTime? kayitTarihi,
  }) : kayitTarihi = kayitTarihi ?? DateTime.now();

  // Yıldız sayısına ve karaliste durumuna göre rozet (Kuantum Mührü)
  String get badgeType {
    if (isBlacklisted || rating <= 1.0) return "BLACK STAR (KARA LİSTE)";
    if (rating >= 4.8) return "ALTIN";
    if (rating >= 4.0) return "GÜMÜŞ";
    if (rating >= 3.0) return "BRONZ";
    return "STANDART";
  }

  // 📥 FİREBASE'DEN OKUMA MOTORU (Firmaları listelerken çalışır)
  factory Firm.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Firm(
      id: doc.id,
      name: data['name'] ?? 'İsimsiz Firma',
      rating: (data['rating'] ?? 5.0).toDouble(),
      isBlacklisted: data['is_blacklisted'] ?? false,
      blacklistReason: data['blacklist_reason'],
      komisyonOrani: (data['komisyon_orani'] ?? 0.12).toDouble(),
      kayitTarihi: (data['kayit_tarihi'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // 🚀 FİREBASE'E YAZMA MOTORU (Admin panelinden veya kayıttan firma eklendiğinde)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'rating': rating,
      'is_blacklisted': isBlacklisted,
      'blacklist_reason': blacklistReason,
      // 💰 SİBER FİNANS KALKANI: İsim Murat Plaza ise komisyonu saniyesinde %30'a çivile!
      'komisyon_orani': name == "Murat Plaza" ? 0.30 : komisyonOrani,
      'rozet_tipi': badgeType, // O anki hesaplanan rozeti de veritabanına mühürle
      'kayit_tarihi': FieldValue.serverTimestamp(),
    };
  }
}