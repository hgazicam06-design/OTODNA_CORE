import 'package:cloud_firestore/cloud_firestore.dart';

/// 🦅 OTODNA KUANTUM İLAN KİMLİK KARTI
/// Bu model, galerideki ve pazaryerindeki araçların finansal ve güvenlik verilerini taşır.
class CarAd {
  final String? id; // Firebase Document ID
  final String ownerId;
  final String saticiAdi; // Serbest Piyasa: Bireysel satıcı veya Murat Plaza gibi bayiler

  final String brandModel; // Fabrika verisinden çekilen ana kimlik
  final double price;
  final List<String> images;

  // 🛡️ SİBER KASA VE GÜVENLİK ÖZELLİKLERİ
  final bool isSecureDeposit; // Güvenli Kapora (Siber Havuzda Blokaj)
  final double kaporaBedeli; // Havuzda tutulacak miktar
  final bool otodnaReferansliMi; // Usta onaylı, Kırmızı X'siz, Dijital DNA'sı temiz araç

  final String description; // Kullanıcı beyanı
  final String ilanDurumu; // "Yayında", "Satıldı", "İptal Edildi"
  final DateTime ilanTarihi;

  CarAd({
    this.id,
    required this.ownerId,
    required this.saticiAdi,
    required this.brandModel,
    required this.price,
    required this.images,
    this.isSecureDeposit = true,
    required this.kaporaBedeli,
    this.otodnaReferansliMi = false,
    required this.description,
    this.ilanDurumu = "Yayında",
    DateTime? ilanTarihi,
  }) : ilanTarihi = ilanTarihi ?? DateTime.now();

  // 🚀 FİREBASE'E ATOMİK YAZMA MOTORU (SİBER MÜHÜR)
  Map<String, dynamic> toMap() {
    return {
      'owner_id': ownerId,
      'satici_adi': saticiAdi,
      'brand_model': brandModel,
      'price': price,
      'images': images,
      'is_secure_deposit': isSecureDeposit,
      'kapora_bedeli': kaporaBedeli,
      'otodna_referansli_mi': otodnaReferansliMi,
      'description': description,
      'ilan_durumu': ilanDurumu,
      'ilan_tarihi': FieldValue.serverTimestamp(), // Sunucu saati ile mühürleme
    };
  }

  // 📥 FİREBASE'DEN ANALİTİK OKUMA MOTORU
  factory CarAd.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return CarAd(
      id: doc.id,
      ownerId: data['owner_id'] ?? '',
      saticiAdi: data['satici_adi'] ?? 'Bilinmeyen Operatör',
      brandModel: data['brand_model'] ?? 'Bilinmeyen Model',
      price: (data['price'] ?? 0).toDouble(),
      images: List<String>.from(data['images'] ?? []),
      isSecureDeposit: data['is_secure_deposit'] ?? true,
      kaporaBedeli: (data['kapora_bedeli'] ?? 0).toDouble(),
      otodnaReferansliMi: data['otodna_referansli_mi'] ?? false,
      description: data['description'] ?? '',
      ilanDurumu: data['ilan_durumu'] ?? 'Yayında',
      ilanTarihi: (data['ilan_tarihi'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}