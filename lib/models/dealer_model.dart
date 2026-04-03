import 'package:cloud_firestore/cloud_firestore.dart';

// dealer_model.dart - OtoDNA Kuantum Bayi Kimlik ve Finans Motoru

class Dealer {
  final String? id; // Firebase Document ID
  final String dealerName; // Örn: Gazi Otomotiv veya Murat Plaza
  final String city;       // Şehir (Ankara, İstanbul vb.)
  final String taxNumber;  // Vergi Numarası (Resmiyet için)
  final String region;     // 7 Bölgeden hangisi?

  // 🚀 OTODNA KUANTUM FİNANS VE GÜVENLİK VERİLERİ
  final double komisyonOrani; // Murat Plaza için %30 (0.30), diğerleri için %12 (0.12)
  final bool aktifMi; // Karalisteye alınan bayileri anında sistemden atmak için
  final String rozet; // Altın, Gümüş, Bronz, Black Star (Karaliste)
  final DateTime kayitTarihi;

  Dealer({
    this.id,
    required this.dealerName,
    required this.city,
    required this.taxNumber,
    required this.region,
    this.komisyonOrani = 0.12, // Varsayılan: %10 Kar + %2 Vergi
    this.aktifMi = true,
    this.rozet = "Bronz", // Yeni başlayan bayi Bronz başlar
    DateTime? kayitTarihi,
  }) : kayitTarihi = kayitTarihi ?? DateTime.now();

  // 🚀 FİREBASE'E YAZMA MOTORU (Admin panelinden yeni bayi eklendiğinde)
  Map<String, dynamic> toMap() {
    return {
      'dealer_name': dealerName,
      'city': city,
      'tax_number': taxNumber,
      'region': region,
      // 💰 SİBER FİNANS KALKANI: İsmi Murat Plaza olanın komisyonunu otomatik %30'a çivile!
      'komisyon_orani': dealerName == "Murat Plaza" ? 0.30 : komisyonOrani,
      'aktif_mi': aktifMi,
      'rozet': rozet,
      'kayit_tarihi': FieldValue.serverTimestamp(),
    };
  }

  // 📥 FİREBASE'DEN OKUMA MOTORU (Bayi uygulamaya giriş yaptığında)
  factory Dealer.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Dealer(
      id: doc.id,
      dealerName: data['dealer_name'] ?? 'İsimsiz Bayi',
      city: data['city'] ?? 'Belirtilmedi',
      taxNumber: data['tax_number'] ?? '0000000000',
      region: data['region'] ?? 'Bilinmeyen Bölge',
      komisyonOrani: (data['komisyon_orani'] ?? 0.12).toDouble(),
      aktifMi: data['aktif_mi'] ?? false,
      rozet: data['rozet'] ?? 'Black Star', // Hata varsa güvenli mod: Karaliste say
      kayitTarihi: (data['kayit_tarihi'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // --- 🖨️ ÇIKTILARDA (PDF) GÖRÜNECEK RESMİ MÜHÜRLER ---

  // Örn: GAZİ OTOMOTİV - OTODNA SERVİS FORMU
  String get officialHeader {
    return "${dealerName.toUpperCase()} - OTODNA SİBER SERVİS FORMU";
  }

  // Örn: GAZİ OTOMOTİV - OTODNA FİYAT TEKLİFİ
  String get offerHeader {
    return "${dealerName.toUpperCase()} - OTODNA KUANTUM FİYAT TEKLİFİ";
  }

  // Bayi Bilgi Özeti (PDF Alt Bilgisi ve Faturalar için)
  String get dealerInfoSummary {
    return "$dealerName | $city | $region | Vergi No: $taxNumber | Kuantum Rozet: $rozet";
  }
}