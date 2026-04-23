import 'package:cloud_firestore/cloud_firestore.dart';

/// 🦅 OTODNA KUANTUM FİYAT TEKLİFİ VE FATURA SATIRI MOTORU
/// Bu model, hem PDF üzerinden taranan hem de manuel girilen ürünlerin
/// Alış/Satış fiyatlarını analiz edip Gazi Payını otomatik keser.
class OfferItem {
  final String? id; 
  final String saticiAdi; // Murat Plaza veya Diğerleri
  final String description; // Örn: Mobil 1 5W-30 Yağ, Triger Seti
  final int quantity;       // Adet
  
  // 💰 TİCARİ METRİKLER (ZORUNLU)
  final double alisFiyati;  // Ürünün esnafa geliş fiyatı (KDV Hariç)
  final double satisFiyati; // Müşteriye sunulan son rakam (KDV Hariç)
  
  final double taxRate;     // KDV Oranı (Genelde %20 yani 0.20)
  final double indirim;     // Satıra özel indirim miktarı (TL bazında)

  OfferItem({
    this.id,
    required this.saticiAdi,
    required this.description,
    this.quantity = 1,
    this.alisFiyati = 0.0, // AI faturadan sökemezse sıfır kalır
    required this.satisFiyati,
    this.taxRate = 0.20,
    this.indirim = 0.0,
  });

  // --- 💰 DİNAMİK KUANTUM HESAPLAMALARI ---

  // 1. KDV'siz net satış toplamı (İndirim düşülmüş)
  double get totalSatisPrice => (quantity * satisFiyati) - indirim;

  // 2. KDV'siz net alış toplamı
  double get totalAlisPrice => quantity * alisFiyati;

  // 3. Müşterinin ödeyeceği KDV dahil son rakam (Ekranda Müşteri Bunu Görür)
  double get totalWithTax => totalSatisPrice * (1 + taxRate);

  // 4. 🛡️ GAZİ FİNANS PROTOKOLÜ: Murat Plaza %30, Diğerleri %12 (10+2)
  double get komisyonOrani {
    return saticiAdi.trim().toLowerCase() == "murat plaza" ? 0.30 : 0.12;
  }

  // 5. 👑 SİBER KOMUTAN PAYI (Net Sistem Geliri)
  // "Direkt satış fiyatı yazılsa bile OtoDNA payı düşülerek yayınlanır" kuralı gereği,
  // Komisyon, KDV DAHİL veya HARİÇ (kullanıcı tercihine göre değişir ama KDV dahil genelde alınır)
  // son tutar üzerinden hesaplanır.
  double get gaziPayi => totalWithTax * komisyonOrani;

  // 6. 🛠️ BAYİ HAKEDİŞİ (Esnafın Cebine Kalan Net Para)
  double get bayiHakedisi => totalWithTax - gaziPayi;

  // 7. 📈 TİCARİ KARZLIK (Esnaf bu satırdan ne kadar net kâr etti?)
  double get esnafNetKari => bayiHakedisi - (totalAlisPrice * (1 + taxRate));


  // 🚀 FİREBASE'E ATOMİK YAZMA MOTORU
  Map<String, dynamic> toMap() {
    return {
      'satici_adi': saticiAdi,
      'description': description,
      'quantity': quantity,
      'alis_fiyati': alisFiyati,
      'satis_fiyati': satisFiyati,
      'tax_rate': taxRate,
      'indirim': indirim,

      // 📊 ANALİTİK VERİ MÜHÜRLERİ: Sorgu hızını artırmak için hesaplanmış değerleri kaydediyoruz.
      'toplam_satis_kdvli': totalWithTax,
      'toplam_alis_kdvli': totalAlisPrice * (1 + taxRate),
      'gazi_payi_hesaplanan': gaziPayi,
      'bayi_hakedisi_hesaplanan': bayiHakedisi,
      'esnaf_net_kari': esnafNetKari,
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
      alisFiyati: (map['alis_fiyati'] ?? 0).toDouble(),
      satisFiyati: (map['satis_fiyati'] ?? 0).toDouble(),
      taxRate: (map['tax_rate'] ?? 0.20).toDouble(),
      indirim: (map['indirim'] ?? 0.0).toDouble(),
    );
  }
}