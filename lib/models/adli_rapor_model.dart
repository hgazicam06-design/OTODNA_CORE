import 'package:cloud_firestore/cloud_firestore.dart';

/// ⚖️ OTODNA ADLİ RAPOR MODELİ
/// Mahkemelerde ve uzlaşmalarda kullanılacak dijital delil dosyası.
class AdliRaporModel {
  final String? id;
  final String davaTuru; // "Kusur Hakemliği" veya "Değer Kaybı Davası"
  final String aracSaseNo;
  final String ustaUid;
  final String tedarikciKodu; // QR veya Parça Numarası
  final DateTime olayTarihi;
  
  // Dijital Kanıtlar (Resim/Video URL'leri)
  final List<String> montajOncesiFotolar;
  final List<String> montajAniVideolar;
  final List<String> testVerileri; // Isı, Basınç, Tork sensör verileri
  
  // AI (Siber Bilirkişi) Hükmü
  final String aiHukmu; // AI'ın verdiği detaylı teknik analiz ve karar
  final int kusurOraniUsta; // % (örn: %0)
  final int kusurOraniParca; // % (örn: %80)
  final int kusurOraniKullanici; // % (örn: %20)
  
  // 🛡️ Yasal Uyarı Zırhı
  final bool yasalUyariOkundu;
  
  static String yasalUyariMetni = "DİKKAT: Bu rapor OtoDNA Siber Bilirkişi (Yapay Zeka) motoru tarafından oluşturulmuş teknik bir ön tespittir. Algoritmaların hata payı bulunabilir. Nihai ve bağlayıcı karar için OtoDNA Merkez Karargahı ile uzman onayı (görüşme) sağlanması zorunludur.";

  AdliRaporModel({
    this.id,
    required this.davaTuru,
    required this.aracSaseNo,
    required this.ustaUid,
    required this.tedarikciKodu,
    required this.olayTarihi,
    this.montajOncesiFotolar = [],
    this.montajAniVideolar = [],
    this.testVerileri = [],
    required this.aiHukmu,
    this.kusurOraniUsta = 0,
    this.kusurOraniParca = 0,
    this.kusurOraniKullanici = 0,
    this.yasalUyariOkundu = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'dava_turu': davaTuru,
      'arac_sase_no': aracSaseNo,
      'usta_uid': ustaUid,
      'tedarikci_kodu': tedarikciKodu,
      'olay_tarihi': olayTarihi,
      'montaj_oncesi_fotolar': montajOncesiFotolar,
      'montaj_ani_videolar': montajAniVideolar,
      'test_verileri': testVerileri,
      'ai_hukmu': aiHukmu,
      'kusur_orani_usta': kusurOraniUsta,
      'kusur_orani_parca': kusurOraniParca,
      'kusur_orani_kullanici': kusurOraniKullanici,
      'yasal_uyari_okundu': yasalUyariOkundu,
      'yasal_metin': yasalUyariMetni, // Mahkeme zırhı veritabanına da kazınır
      'olusturulma_tarihi': FieldValue.serverTimestamp(),
    };
  }
}
