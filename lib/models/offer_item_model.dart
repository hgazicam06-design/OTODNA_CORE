import 'package:cloud_firestore/cloud_firestore.dart';

// offer_item_model.dart - Kuantum Fiyat Teklifi ve Fatura Satırı

class OfferItem {
  final String? id; // Firebase alt koleksiyon ID'si
  final String saticiAdi; // Kuantum Kuralı: Murat Plaza veya Diğerleri
  final String description; // Örn: Mobil 1 5W-30 Yağ, Triger Seti
  final int quantity;       // Adet
  final double unitPrice;   // Birim Fiyat (KDV Hariç)
  final double taxRate;     // KDV Oranı (Genelde %20 yani 0.20)

  // 🚀 OTODNA FİNANS MOTORU İÇİN İNDİRİM GİRİŞİ
  final double indirim;     // Satıra özel indirim miktarı (TL bazında)

  OfferItem({
    this.id,
    required this.saticiAdi,
    required this.description,
    this.quantity = 1,
    required this.unitPrice,
    this.taxRate = 0.20,
    this.indirim = 0.0,
  });

  // --- 💰 DİNAMİK FİNANS HESAPLAMALARI ---

  // 1. KDV'siz net toplam (İndirim düşülmüş)
  double get totalPrice => (quantity * unitPrice) - indirim;

  // 2. Müşterinin göreceği ve ödeyeceği KDV'li son rakam
  double get totalWithTax => totalPrice * (1 + taxRate);

  // 3. KUANTUM KURALI: Murat Plaza %30, Diğer Esnaflar %12 Kesinti!
  double get komisyonOrani => saticiAdi == "Murat Plaza" ? 0.30 : 0.12;

  // 4. Komutan Gazi'nin (Sistemin) Kasasına Girecek Net Pay
  double get gaziPayi => totalWithTax * komisyonOrani;

  // 5. Bayinin (Ustaların) Cebine Girecek Net Hakediş
  double get bayiHakedisi => totalWithTax - gaziPayi;


  // 🚀 FİREBASE'E YAZMA MOTORU (Fatura/Teklif Müşteriye Atıldığı An Çalışır)
  Map<String, dynamic> toMap() {
    return {
      'satici_adi': saticiAdi,
      'description': description,
      'quantity': quantity,
      'unit_price': unitPrice,
      'tax_rate': taxRate,
      'indirim': indirim,

      // RAPORLAMA İÇİN HAYATİ ÖNEM: Hesaplanmış verileri de Firebase'e mühürlüyoruz.
      // Böylece ay sonunda "Gazi Payı ne kadar birikti?" sorgusunu saniyesinde çekeriz.
      'toplam_tutar': totalWithTax,
      'gazi_payi': gaziPayi,
      'bayi_hakedisi': bayiHakedisi,
    };
  }

  // 📥 FİREBASE'DEN OKUMA MOTORU (Müşteri PDF'i veya Teklif Ekranını Açtığında)
  factory OfferItem.fromMap(Map<String, dynamic> map, [String? docId]) {
    return OfferItem(
      id: docId,
      saticiAdi: map['satici_adi'] ?? 'Bilinmeyen Satıcı',
      description: map['description'] ?? 'Belirtilmemiş Ürün',
      quantity: map['quantity'] ?? 1,
      unitPrice: (map['unit_price'] ?? 0).toDouble(),
      taxRate: (map['tax_rate'] ?? 0.20).toDouble(),
      indirim: (map['indirim'] ?? 0.0).toDouble(),
    );
  }
}