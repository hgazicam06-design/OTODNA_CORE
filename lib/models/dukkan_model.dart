import 'package:cloud_firestore/cloud_firestore.dart';

/// 🦅 OTODNA KUANTUM ESNAF ABONELİK VE LİMİT MOTORU
/// Bu model, esnafların (dükkanların) sisteme katılımını, limitlerini, puanlamasını,
/// resmi evraklarını, harita konumlarını ve YAPAY ZEKA RİSK SKORUNU yönetir.
class Dukkan {
  final String? id; // Firebase Document ID
  final String ad;
  
  // 🕸️ KUANTUM İSTİHBARAT AĞI (4 KATMANLI LOKASYON)
  final String countryId;
  final String regionId;
  final String cityId;
  final String districtId;
  
  // 📍 SİBER HARİTA KONUMU
  final GeoPoint? konum; // Haritada işaretlenen tam koordinat (Latitude, Longitude)

  // 👤 FİRMA YETKİLİSİ BİLGİLERİ
  final String? firmaYetkilisiAdSoyad;
  final String? profilFotoUrl;
  final String? isTelefonu;
  final String? cepTelefonu;
  final String? whatsappNumarasi;

  // ⚖️ TRENDYOL USULÜ GÜVENLİ EVRAK ONAY SİSTEMİ (Müşterilere Gizli)
  final String? vergiLevhasiUrl;
  final String? ustalikBelgesiUrl;
  final String evrakOnayDurumu; // 'bekliyor', 'onaylandi', 'reddedildi'
  final String? evrakRedNedeni; // Reddedilirse admin açıklaması
  
  // 🎯 SİBER UZMANLIK AĞI (ÇOKLU ETİKET MOTORU)
  final List<String> verilenHizmetler; // Örn: ['Şanzıman', 'Petek Temizliği']
  final List<String> hizmetAracTipleri; // Örn: ['Otomobil', 'Kamyon']
  final List<String> uzmanMarkaGruplari; // Örn: ['Alman Grubu', 'Japon Grubu']

  // 🚀 OTODNA KUANTUM GÜVENLİK VE ABONELİK ÖZELLİKLERİ
  final double puan;
  final bool aktifMi;
  final String rozet; // "Bronz", "Gümüş", "Altın", "Black Star"
  final bool isVip; // VIP (Kuantum Sınırsızlık) yetkisi

  // 🤖 YAPAY ZEKA DENETİM MOTORU (SİBER MÜFETTİŞ)
  final double aiRiskSkoru; // Firmanın hatalı iş/kötü niyet potansiyeli (0-100).
  final bool siberIhlalDurumu; // AI tarafından mimlenip Karargaha bildirilen firma.

  // 📊 LİMİT VE KULLANIM TAKİBİ
  final int kullanilanIlanSayisi;

  // 💰 STANDART FİNANS: %12 Kuralı
  final double komisyonOrani;
  final DateTime kayitTarihi;

  Dukkan({
    this.id,
    required this.ad,
    required this.countryId,
    required this.regionId,
    required this.cityId,
    required this.districtId,
    this.konum,
    this.firmaYetkilisiAdSoyad,
    this.profilFotoUrl,
    this.isTelefonu,
    this.cepTelefonu,
    this.whatsappNumarasi,
    this.vergiLevhasiUrl,
    this.ustalikBelgesiUrl,
    this.evrakOnayDurumu = 'bekliyor',
    this.evrakRedNedeni,
    this.verilenHizmetler = const ["Genel Servis"],
    this.hizmetAracTipleri = const [],
    this.uzmanMarkaGruplari = const [],
    this.puan = 5.0,
    this.aktifMi = true,
    this.rozet = "Bronz",
    this.isVip = false,
    this.aiRiskSkoru = 0.0,
    this.siberIhlalDurumu = false,
    this.kullanilanIlanSayisi = 0,
    this.komisyonOrani = 0.12,
    DateTime? kayitTarihi,
  }) : kayitTarihi = kayitTarihi ?? DateTime.now();

  // 🧠 TRENDYOL İŞ KURALI: Dükkanın vitrine çıkabilmesi için evrakların onaylanmış olması ŞARTTIR.
  bool get onayliMi => evrakOnayDurumu == 'onaylandi';

  // 🧠 SİBER KARARGAH KİLİDİ: AI risk skoru 80'i aşarsa dükkan otomatik kilitlenir.
  bool get guvenilirMi => aiRiskSkoru < 80.0 && !siberIhlalDurumu;

  // 🧠 KUANTUM LİMİT HESAPLAYICI (SaaS Zekası)
  int get maxIlanSiniri {
    if (isVip) return -1;

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
        return 5;
    }
  }

  // 🛡️ SİBER ŞALTER: Yeni ürün/ilan girişi yapılabilir mi?
  bool get yeniIlanEklenebilirMi {
    if (!onayliMi || !guvenilirMi) return false; // Evrak onayı yoksa VEYA AI mimlediyse şalter iniktir.
    if (maxIlanSiniri == -1) return true;
    return kullanilanIlanSayisi < maxIlanSiniri;
  }

  // 🚀 FİREBASE'E ATOMİK YAZMA MOTORU
  Map<String, dynamic> toMap() {
    return {
      'ad': ad,
      'country_id': countryId,
      'region_id': regionId,
      'city_id': cityId,
      'district_id': districtId,
      'konum': konum,
      'firma_yetkilisi_ad_soyad': firmaYetkilisiAdSoyad,
      'profil_foto_url': profilFotoUrl,
      'is_telefonu': isTelefonu,
      'cep_telefonu': cepTelefonu,
      'whatsapp_numarasi': whatsappNumarasi,
      'vergi_levhasi_url': vergiLevhasiUrl,
      'ustalik_belgesi_url': ustalikBelgesiUrl,
      'evrak_onay_durumu': evrakOnayDurumu,
      'evrak_red_nedeni': evrakRedNedeni,
      'verilen_hizmetler': verilenHizmetler,
      'hizmet_arac_tipleri': hizmetAracTipleri,
      'uzman_marka_gruplari': uzmanMarkaGruplari,
      'puan': puan,
      'aktif_mi': aktifMi,
      'rozet': rozet,
      'is_vip': isVip,
      'ai_risk_skoru': aiRiskSkoru,
      'siber_ihlal_durumu': siberIhlalDurumu,
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
      countryId: data['country_id'] ?? '',
      regionId: data['region_id'] ?? '',
      cityId: data['city_id'] ?? '',
      districtId: data['district_id'] ?? '',
      konum: data['konum'] as GeoPoint?,
      firmaYetkilisiAdSoyad: data['firma_yetkilisi_ad_soyad'],
      profilFotoUrl: data['profil_foto_url'],
      isTelefonu: data['is_telefonu'],
      cepTelefonu: data['cep_telefonu'],
      whatsappNumarasi: data['whatsapp_numarasi'],
      vergiLevhasiUrl: data['vergi_levhasi_url'],
      ustalikBelgesiUrl: data['ustalik_belgesi_url'],
      evrakOnayDurumu: data['evrak_onay_durumu'] ?? 'bekliyor',
      evrakRedNedeni: data['evrak_red_nedeni'],
      verilenHizmetler: List<String>.from(data['verilen_hizmetler'] ?? ["Genel Servis"]),
      hizmetAracTipleri: List<String>.from(data['hizmet_arac_tipleri'] ?? []),
      uzmanMarkaGruplari: List<String>.from(data['uzman_marka_gruplari'] ?? []),
      puan: (data['puan'] ?? 5.0).toDouble(),
      aktifMi: data['aktif_mi'] ?? false,
      rozet: data['rozet'] ?? 'Bronz',
      isVip: data['is_vip'] ?? false,
      aiRiskSkoru: (data['ai_risk_skoru'] ?? 0.0).toDouble(),
      siberIhlalDurumu: data['siber_ihlal_durumu'] ?? false,
      kullanilanIlanSayisi: (data['kullanilan_ilan_sayisi'] ?? 0).toInt(),
      komisyonOrani: (data['komisyon_orani'] ?? 0.12).toDouble(),
      kayitTarihi: (data['kayit_tarihi'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}