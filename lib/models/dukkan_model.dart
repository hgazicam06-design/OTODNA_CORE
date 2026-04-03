import 'package:cloud_firestore/cloud_firestore.dart';

// dukkan_model.dart - Kuantum Esnaf Abonelik ve Limit Motoru

class Dukkan {
  final String? id; // Firebase Document ID
  final String ad;
  final String sehir;
  final String bolge;
  final String hizmetKategorisi;

  // 🚀 OTODNA KUANTUM GÜVENLİK VE ABONELİK ÖZELLİKLERİ
  final double puan;
  final bool onayliMi;
  final bool aktifMi;
  final String rozet; // Standart, Gümüş, Gold, Black Star vb.
  final bool isVip; // VIP (Sınırsız) yetkisi var mı?

  // 📊 YENİ STRATEJİ: İLAN LİMİTİ VE KULLANIM TAKİBİ
  final int kullanilanIlanSayisi; // O an vitrinde olan parça/araç sayısı

  // 💰 STANDART FİNANS: %12 Kuralı
  final double komisyonOrani;
  final DateTime kayitTarihi;

  Dukkan({
    this.id,
    required this.ad,
    required this.sehir,
    required this.bolge,
    this.hizmetKategorisi = "Genel Servis",
    this.puan = 5.0,
    this.onayliMi = false,
    this.aktifMi = true,
    this.rozet = "Standart",
    this.isVip = false,
    this.kullanilanIlanSayisi = 0, // Başlangıçta 0 ilanı var
    this.komisyonOrani = 0.12,
    DateTime? kayitTarihi,
  }) : kayitTarihi = kayitTarihi ?? DateTime.now();

  // 🧠 KUANTUM LİMİT HESAPLAYICI (SaaS Zekası)
  // Firmanın rozetine göre ekleyebileceği MAKSİMUM ürün sayısını belirler
  int get maxIlanSiniri {
    if (isVip) return -1; // -1: Kuantum Sınırsızlık Kodu (Limitsiz)
    if (rozet == "Gold" || rozet == "Altın") return 50; // Gold Paket
    return 10; // Standart Firma Paketi
  }

  // Usta yeni ilan eklerken buton bu şaltere bakar!
  bool get yeniIlanEklenebilirMi {
    if (maxIlanSiniri == -1) return true; // VIP ise geç
    return kullanilanIlanSayisi < maxIlanSiniri; // Limiti dolmadıysa geç
  }

  // 📥 FİREBASE'DEN OKUMA MOTORU
  factory Dukkan.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Dukkan(
      id: doc.id,
      ad: data['ad'] ?? 'İsimsiz Dükkan',
      sehir: data['sehir'] ?? 'Bilinmeyen Şehir',
      bolge: data['bolge'] ?? 'Bilinmeyen Bölge',
      hizmetKategorisi: data['hizmet_kategorisi'] ?? 'Genel Servis',
      puan: (data['puan'] ?? 5.0).toDouble(),
      onayliMi: data['onayli_mi'] ?? false,
      aktifMi: data['aktif_mi'] ?? false,
      rozet: data['rozet'] ?? 'Standart',
      isVip: data['is_vip'] ?? false,
      kullanilanIlanSayisi: data['kullanilan_ilan_sayisi'] ?? 0,
      komisyonOrani: (data['komisyon_orani'] ?? 0.12).toDouble(),
      kayitTarihi: (data['kayit_tarihi'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // 🚀 FİREBASE'E YAZMA MOTORU
  Map<String, dynamic> toMap() {
    return {
      'ad': ad,
      'sehir': sehir,
      'bolge': bolge,
      'hizmet_kategorisi': hizmetKategorisi,
      'puan': puan,
      'onayli_mi': onayliMi,
      'aktif_mi': aktifMi,
      'rozet': rozet,
      'is_vip': isVip,
      'kullanilan_ilan_sayisi': kullanilanIlanSayisi,
      'komisyon_orani': komisyonOrani,
      'kayit_tarihi': FieldValue.serverTimestamp(),
    };
  }
}