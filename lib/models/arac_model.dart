import 'package:cloud_firestore/cloud_firestore.dart';

/// 🦅 OTODNA ARAC MODELİ - KUANTUM DİJİTAL KİMLİK
/// Bu sınıf aracın siber dünyadaki tüm geçmişini ve DNA skorunu taşır.
class AracModel {
  final String? id;
  final String sahibiUid;

  // 👤 KULLANICI / SAHİP BİLGİLERİ
  final String kullaniciAdi;
  final String ad;
  final String soyad;
  final DateTime dogumTarihi;

  // 🚘 ARAÇ KİMLİK (SİBER GENETİK) BİLGİLERİ
  final String plaka;
  final String il;
  final String ilce;
  final String postaKodu;
  final String marka;
  final String model;
  final String renk;
  final String saseNo; // VIN — 17 Karakterlik Dijital Parmak İzi

  // 📅 KRİTİK TAKİP TARİHLERİ
  final DateTime? muayeneBitis;
  final DateTime? emisyonBitis;
  final DateTime? sigortaBitis;
  final DateTime? kaskoBitis;

  // ⏳ OPERASYONEL PARAMETRELER
  final int muayenePeriyodu;
  final bool saseOnaylandi;
  final String? fcmToken;
  final DateTime kayitTarihi;

  // 🚀 OTODNA KUANTUM ÖZEL DEĞERLERİ
  final int dnaSkoru; // 0-100 arası sağlık puanı
  final bool kritikHataVarMi; // Trafiğe çıkış riski (Kırmızı X tetikleyici)
  final String muayeneDurumu; // "OtoDNA Onaylı", "Riskli", "Beklemede"
  final String ilanDurumu; // "Yayında", "Arşivde", "Satıldı"
  final double fiyat;
  final String resimUrl;

  AracModel({
    this.id,
    required this.sahibiUid,
    required this.kullaniciAdi,
    required this.ad,
    required this.soyad,
    required this.dogumTarihi,
    required this.plaka,
    required this.il,
    required this.ilce,
    required this.postaKodu,
    required this.marka,
    required this.model,
    required this.renk,
    required this.saseNo,
    this.muayeneBitis,
    this.emisyonBitis,
    this.sigortaBitis,
    this.kaskoBitis,
    this.muayenePeriyodu = 2,
    this.saseOnaylandi = false,
    this.fcmToken,
    DateTime? kayitTarihi,
    this.dnaSkoru = 100,
    this.kritikHataVarMi = false,
    this.muayeneDurumu = "Değerlendirme Bekliyor",
    this.ilanDurumu = "Yayında Değil",
    this.fiyat = 0.0,
    this.resimUrl = "",
  }) : kayitTarihi = kayitTarihi ?? DateTime.now();

  // 🔥 FİREBASE'E ATOMİK YAZMA MOTORU (SİBER MÜHÜR)
  Map<String, dynamic> toMap() => {
    'sahibiUid': sahibiUid,
    'kullaniciAdi': kullaniciAdi,
    'ad': ad,
    'soyad': soyad,
    'dogumTarihi': Timestamp.fromDate(dogumTarihi),
    'plaka': plaka.toUpperCase().replaceAll(' ', ''),
    'il': il,
    'ilce': ilce,
    'postaKodu': postaKodu,
    'marka': marka,
    'model': model,
    'renk': renk,
    'saseNo': saseNo.toUpperCase(),
    'muayeneBitis': muayeneBitis != null ? Timestamp.fromDate(muayeneBitis!) : null,
    'emisyonBitis': emisyonBitis != null ? Timestamp.fromDate(emisyonBitis!) : null,
    'sigortaBitis': sigortaBitis != null ? Timestamp.fromDate(sigortaBitis!) : null,
    'kaskoBitis': kaskoBitis != null ? Timestamp.fromDate(kaskoBitis!) : null,
    'muayenePeriyodu': muayenePeriyodu,
    'saseOnaylandi': saseOnaylandi,
    'fcmToken': fcmToken,
    'kayitTarihi': Timestamp.fromDate(kayitTarihi),
    'dna_skoru': dnaSkoru,
    'kritik_hata_var_mi': kritikHataVarMi,
    'muayene_durumu': muayeneDurumu,
    'ilan_durumu': ilanDurumu,
    'fiyat': fiyat,
    'resim_url': resimUrl,
  };

  // 📥 FİREBASE'DEN ANALİTİK OKUMA MOTORU
  factory AracModel.fromMap(Map<String, dynamic> m, String docId) => AracModel(
    id: docId,
    sahibiUid: m['sahibiUid'] ?? '',
    kullaniciAdi: m['kullaniciAdi'] ?? '',
    ad: m['ad'] ?? '',
    soyad: m['soyad'] ?? '',
    dogumTarihi: (m['dogumTarihi'] as Timestamp?)?.toDate() ?? DateTime(1990),
    plaka: m['plaka'] ?? '',
    il: m['il'] ?? '',
    ilce: m['ilce'] ?? '',
    postaKodu: m['postaKodu'] ?? '',
    marka: m['marka'] ?? '',
    model: m['model'] ?? '',
    renk: m['renk'] ?? '',
    saseNo: m['saseNo'] ?? '',
    muayeneBitis: (m['muayeneBitis'] as Timestamp?)?.toDate(),
    emisyonBitis: (m['emisyonBitis'] as Timestamp?)?.toDate(),
    sigortaBitis: (m['sigortaBitis'] as Timestamp?)?.toDate(),
    kaskoBitis: (m['kaskoBitis'] as Timestamp?)?.toDate(),
    muayenePeriyodu: m['muayenePeriyodu'] ?? 2,
    saseOnaylandi: m['saseOnaylandi'] ?? false,
    fcmToken: m['fcmToken'],
    kayitTarihi: (m['kayitTarihi'] as Timestamp?)?.toDate() ?? DateTime.now(),
    dnaSkoru: m['dna_skoru'] ?? 100,
    kritikHataVarMi: m['kritik_hata_var_mi'] ?? false,
    muayeneDurumu: m['muayene_durumu'] ?? "Değerlendirme Bekliyor",
    ilanDurumu: m['ilan_durumu'] ?? "Yayında Değil",
    fiyat: (m['fiyat'] ?? 0).toDouble(),
    resimUrl: m['resim_url'] ?? "",
  );
}