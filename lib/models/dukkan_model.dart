import 'package:cloud_firestore/cloud_firestore.dart';

/// 🦅 OTODNA KUANTUM ESNAF ABONELİK VE LİMİT MOTORU
/// Bu model, esnafların (dükkanların) sisteme katılımını, limitlerini ve puanlamasını yönetir.
class Dukkan {
  final String? id; // Firebase Document ID
  final String ad;
  final String sehir;
  final String bolge;
  
  // 🎯 SİBER UZMANLIK AĞI (ÇOKLU ETİKET MOTORU)
  final List<String> verilenHizmetler; // Örn: ['Şanzıman', 'Petek Temizliği']
  final List<String> hizmetAracTipleri; // Örn: ['Otomobil', 'Kamyon']
  final List<String> uzmanMarkaGruplari; // Örn: ['Alman Grubu', 'Japon Grubu']

  // 🚀 OTODNA KUANTUM GÜVENLİK VE ABONELİK ÖZELLİKLERİ
  final double puan;
  final bool onayliMi;
  final bool aktifMi;
  final String rozet; // "Bronz", "Gümüş", "Altın", "Black Star"
  final bool isVip; // VIP (Kuantum Sınırsızlık) yetkisi

  // 📊 LİMİT VE KULLANIM TAKİBİ
  final int kullanilanIlanSayisi; // Aktif yayındaki parça/araç sayısı

  // 💰 STANDART FİNANS: %12 Kuralı
  final double komisyonOrani;
  final DateTime kayitTarihi;

  Dukkan({
    this.id,
    required this.ad,
    required this.sehir,
    required this.bolge,
    this.verilenHizmetler = const ["Genel Servis"],
    this.hizmetAracTipleri = const [],
    this.uzmanMarkaGruplari = const [],
    this.puan = 5.0,
    this.onayliMi = false,
    this.aktifMi = true,
    this.rozet = "Bronz",
    this.isVip = false,
    this.kullanilanIlanSayisi = 0,
    this.komisyonOrani = 0.12,
    DateTime? kayitTarihi,
  }) : kayitTarihi = kayitTarihi ?? DateTime.now();

  // 🧠 KUANTUM LİMİT HESAPLAYICI (SaaS Zekası)
  int get maxIlanSiniri {
    if (isVip) return -1; // -1: Kuantum Sınırsızlık Kodu

    switch (rozet) {
      case "Altın":
      case "Gold":
        return 50;
      case "Gümüş":
      case "Silver":
        return 25;
      case "Bronz":
        return 10;
      default:
        return 5; // Blacklist veya Tanımsızlar için minimum limit
    }
  }

  // 🛡️ SİBER ŞALTER: Yeni ürün/ilan girişi yapılabilir mi?
  bool get yeniIlanEklenebilirMi {
    if (maxIlanSiniri == -1) return true;
    return kullanilanIlanSayisi < maxIlanSiniri;
  }

  // 🚀 FİREBASE'E ATOMİK YAZMA MOTORU
  Map<String, dynamic> toMap() {
    return {
      'ad': ad,
      'sehir': sehir,
      'bolge': bolge,
      'verilen_hizmetler': verilenHizmetler,
      'hizmet_arac_tipleri': hizmetAracTipleri,
      'uzman_marka_gruplari': uzmanMarkaGruplari,
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

  // 📥 FİREBASE'DEN ANALİTİK OKUMA MOTORU
  factory Dukkan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Dukkan(
      id: doc.id,
      ad: data['ad'] ?? 'İSİMSİZ İŞLETME',
      sehir: data['sehir'] ?? 'BELİRTİLMEDİ',
      bolge: data['bolge'] ?? 'BELİRTİLMEDİ',
      verilenHizmetler: List<String>.from(data['verilen_hizmetler'] ?? ["Genel Servis"]),
      hizmetAracTipleri: List<String>.from(data['hizmet_arac_tipleri'] ?? []),
      uzmanMarkaGruplari: List<String>.from(data['uzman_marka_gruplari'] ?? []),
      puan: (data['puan'] ?? 5.0).toDouble(),
      onayliMi: data['onayli_mi'] ?? false,
      aktifMi: data['aktif_mi'] ?? false,
      rozet: data['rozet'] ?? 'Bronz',
      isVip: data['is_vip'] ?? false,
      kullanilanIlanSayisi: (data['kullanilan_ilan_sayisi'] ?? 0).toInt(),
      komisyonOrani: (data['komisyon_orani'] ?? 0.12).toDouble(),
      kayitTarihi: (data['kayit_tarihi'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}