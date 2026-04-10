import 'package:cloud_firestore/cloud_firestore.dart';

/// 🦅 OTODNA KUANTUM FİYAT TEKLİFİ VE FATURA SATIRI MOTORU
/// Bu model, her bir kalem ürün/hizmetin finansal analizini ve Gazi Payı hesaplamasını yapar.
class OfferItem {
  final String? id; // Firebase alt koleksiyon ID'si
  final String saticiAdi; // Murat Plaza veya Diğerleri
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

  // --- 💰 DİNAMİK KUANTUM HESAPLAMALARI ---

  // 1. KDV'siz net toplam (İndirim düşülmüş)
  double get totalPrice => (quantity * unitPrice) - indirim;

  // 2. Müşterinin ödeyeceği KDV dahil son rakam
  double get totalWithTax => totalPrice * (1 + taxRate);

  // 3. 🛡️ GAZİ FİNANS PROTOKOLÜ: Murat Plaza %30, Diğerleri %12 (10+2)
  double get komisyonOrani {
    // İsim kontrolü yapılırken boşluk ve büyük/küçük harf toleransı eklendi
    return saticiAdi.trim().toLowerCase() == "murat plaza" ? 0.30 : 0.12;
  }

  // 4. 👑 SİBER KOMUTAN PAYI (Net Sistem Geliri)
  double get gaziPayi => totalWithTax * komisyonOrani;

  // 5. 🛠️ BAYİ HAKEDİŞİ (Esnafın Cebine Kalan)
  double get bayiHakedisi => totalWithTax - gaziPayi;


  // 🚀 FİREBASE'E ATOMİK YAZMA MOTORU
  Map<String, dynamic> toMap() {
    return {
      'satici_adi': saticiAdi,
      'description': description,
      'quantity': quantity,
      'unit_price': unitPrice,
      'tax_rate': taxRate,
      'indirim': indirim,

      // 📊 ANALİTİK VERİ MÜHÜRLERİ: Sorgu hızını artırmak için hesaplanmış değerleri kaydediyoruz.
      'toplam_tutar_kdvli': totalWithTax,
      'gazi_payi_hesaplanan': gaziPayi,
      'bayi_hakedisi_hesaplanan': bayiHakedisi,
      'komisyon_orani_uygulanan': komisyonOrani,
      'islem_tarihi': FieldValue.serverTimestamp(),
    };
  }

  // 📥 FİREBASE'DEN ANALİTİK OKUMA MOTORU
  factory OfferItem.fromMap(Map<String, dynamic> map, [String? docId]) {
    return OfferItem(
      id: docId,
      saticiAdi: map['satici_adi'] ?? 'Bilinmeyen Satıcı',
      description: map['description'] ?? 'Belirtilmemiş Ürün/Hizmet',
      quantity: (map['quantity'] ?? 1).toInt(),
      unitPrice: (map['unit_price'] ?? 0).toDouble(),
      taxRate: (map['tax_rate'] ?? 0.20).toDouble(),
      indirim: (map['indirim'] ?? 0.0).toDouble(),
    );
  }
}