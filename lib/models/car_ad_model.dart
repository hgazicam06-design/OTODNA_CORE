import 'package:cloud_firestore/cloud_firestore.dart';

// car_ad_model.dart - Kuantum İlan Kimlik Kartı
class CarAd {
  final String? id; // Firebase Document ID
  final String ownerId;
  final String saticiAdi; // Serbest Piyasa kuralı: Gerçek satıcı veya firma adı

  final String brandModel; // Fabrika verisinden çekilecek (Örn: Volkswagen Golf 1.5 TSI)
  final double price;
  final List<String> images;

  // 🛡️ SİBER KASA VE GÜVENLİK ÖZELLİKLERİ
  final bool isSecureDeposit; // Güvenli Kapora aktif mi?
  final double kaporaBedeli; // Siber havuzda tutulacak miktar
  final bool otodnaReferansliMi; // Usta onayından geçmiş, Kırmızı X'i olmayan araçlar

  final String description; // Kullanıcı beyanı
  final String ilanDurumu; // Yayında, Satıldı, İptal
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

  // 🚀 FİREBASE'E YAZMA MOTORU (İlan Verildiğinde Çalışır)
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
      'ilan_tarihi': FieldValue.serverTimestamp(),
    };
  }

  // 📥 FİREBASE'DEN OKUMA MOTORU (Galeride Listelerken Çalışır)
  factory CarAd.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return CarAd(
      id: doc.id,
      ownerId: data['owner_id'] ?? '',
      saticiAdi: data['satici_adi'] ?? 'Bilinmeyen Satıcı',
      brandModel: data['brand_model'] ?? 'Bilinmeyen Model',
      price: (data['price'] ?? 0).toDouble(),
      // Firebase'den gelen listeyi güvenli bir şekilde Dart Listesine çeviriyoruz
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