import 'package:cloud_firestore/cloud_firestore.dart';

/// 🦅 OTODNA KUANTUM BAYİ KİMLİK VE FİNANS MOTORU
/// Bu model, Gazi'nin %12 (10+2) mutlak finans kuralına göre modernize edilmiştir.
class Dealer {
  final String? id; // Firebase Document ID
  final String dealerName;
  final String city;
  final String taxNumber;
  final String region;

  // 💰 OTODNA MUTLAK FİNANS PROTOKOLÜ
  // Tüm bayiler (İstisnasız): %10 Kâr + %2 Vergi = %12 (0.12)
  final double komisyonOrani;
  final bool aktifMi; // Karaliste kalkanı
  final String rozet; // Altın, Gümüş, Bronz, Black Star
  final DateTime kayitTarihi;

  Dealer({
    this.id,
    required this.dealerName,
    required this.city,
    required this.taxNumber,
    required this.region,
    this.komisyonOrani = 0.12, // Varsayılan Gazi Protokolü
    this.aktifMi = true,
    this.rozet = "Bronz",
    DateTime? kayitTarihi,
  }) : kayitTarihi = kayitTarihi ?? DateTime.now();

  // 🔥 FİREBASE'E ATOMİK YAZMA MOTORU (SİBER MÜHÜR)
  Map<String, dynamic> toMap() {
    return {
      'dealer_name': dealerName,
      'city': city,
      'tax_number': taxNumber,
      'region': region,
      // 🛡️ SİBER FİNANS ZIRHI: Murat Plaza dahil tüm bayiler %12'ye sabitlendi.
      'komisyon_orani': 0.12,
      'aktif_mi': aktifMi,
      'rozet': rozet,
      'kayit_tarihi': FieldValue.serverTimestamp(),
    };
  }

  // 📥 FİREBASE'DEN ANALİTİK OKUMA MOTORU
  factory Dealer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Dealer(
      id: doc.id,
      dealerName: data['dealer_name'] ?? 'İSİMSİZ OPERATÖR',
      city: data['city'] ?? 'BELİRTİLMEDİ',
      taxNumber: data['tax_number'] ?? '0000000000',
      region: data['region'] ?? 'BİLİNMEYEN BÖLGE',
      // Veritabanında hatalı veri olsa dahi kod seviyesinde %12 güvenliği sağla
      komisyonOrani: 0.12,
      aktifMi: data['aktif_mi'] ?? false,
      rozet: data['rozet'] ?? 'Black Star', // Güvenli mod: Karaliste
      kayitTarihi: (data['kayit_tarihi'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // --- 🖨️ SİBER MÜHÜRLER (RESMİ DÖKÜMANLAR İÇİN) ---

  String get officialHeader => "${dealerName.toUpperCase()} - OTODNA SİBER SERVİS FORMU";
  String get offerHeader => "${dealerName.toUpperCase()} - OTODNA KUANTUM FİYAT TEKLİFİ";

  String get dealerInfoSummary {
    return "$dealerName | $city | $region | Vergi No: $taxNumber | ROZET: $rozet";
  }
}