import 'package:cloud_firestore/cloud_firestore.dart';

/// 🦅 OTODNA KUANTUM FİRMA KİMLİK KARTI VE SİBER SİCİL MOTORU
/// Bu model, tedarikçi ve paydaş firmaların sicilini ve %12 mutlak finans kuralını yönetir.
class Firm {
  final String? id; // Firebase Document ID
  final String name;
  final double rating; // 1 ile 5 arası Kuantum Yıldızı

  // 🛡️ SİBER GÜVENLİK VE FİNANS MOTORU
  final bool isBlacklisted;
  final String? blacklistReason; // Kara liste sebebi (Siber Mahkeme Kaydı)

  // 💰 GAİ MUTLAK FİNANS PROTOKOLÜ
  // Tüm firmalar: %10 Kâr + %2 Vergi = %12 (0.12)
  final double komisyonOrani;
  final DateTime kayitTarihi;

  Firm({
    this.id,
    required this.name,
    required this.rating,
    this.isBlacklisted = false,
    this.blacklistReason,
    this.komisyonOrani = 0.12, // Standart protokol
    DateTime? kayitTarihi,
  }) : kayitTarihi = kayitTarihi ?? DateTime.now();

  // ⭐ Yıldız sayısına ve karaliste durumuna göre rozet (Kuantum Mührü)
  String get badgeType {
    if (isBlacklisted || rating <= 1.0) return "BLACK STAR (KARA LİSTE)";
    if (rating >= 4.8) return "ALTIN";
    if (rating >= 4.0) return "GÜMÜŞ";
    if (rating >= 3.0) return "BRONZ";
    return "STANDART";
  }

  // 📥 FİREBASE'DEN ANALİTİK OKUMA MOTORU
  factory Firm.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Firm(
      id: doc.id,
      name: data['name'] ?? 'İSİMSİZ FİRMA',
      rating: (data['rating'] ?? 5.0).toDouble(),
      isBlacklisted: data['is_blacklisted'] ?? false,
      blacklistReason: data['blacklist_reason'],
      // 🛡️ SİBER FİNANS ZIRHI: Veritabanında ne yazarsa yazsın kod %12'yi dayatır.
      komisyonOrani: 0.12,
      kayitTarihi: (data['kayit_tarihi'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // 🔥 FİREBASE'E ATOMİK YAZMA MOTORU
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'rating': rating,
      'is_blacklisted': isBlacklisted,
      'blacklist_reason': blacklistReason,
      // 💰 SİBER FİNANS KALKANI: Tüm istisnalar temizlendi, kural %12!
      'komisyon_orani': 0.12,
      'rozet_tipi': badgeType, // O anki hesaplanan rozeti de veritabanına mühürle
      'kayit_tarihi': FieldValue.serverTimestamp(),
    };
  }
}