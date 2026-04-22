// lib/core/otodna_hizmet_kutuphanesi.dart
import 'dart:developer' as developer;

/// 🛡️ KUANTUM OTODNA HİZMET KÜTÜPHANESİ (SiberHizmetKutuphanesi)
/// Karargahın tüm otomotiv branşlarını, ustalarını ve kategorilerini barındıran siber matris.
class SiberHizmetKutuphanesi {

  // ── 🧠 KARARGAH MASTER LİSTESİ (DEĞİŞTİRİLEMEZ ANA VERİ) ──
  static const Map<String, List<String>> masterListe = {
    "Sanayi İşleme & İmalat": [
      "Torna & Freze (CNC)",
      "Motor Kapak Taşlama",
      "Özel Parça Üretimi",
      "Krank Taşlama & Dengeleme",
      "Piston & Gömlek Çakma"
    ],
    "Yedek Parça & Tedarik": [
      "Sıfır Orijinal / Yan Sanayi Parça",
      "Çıkma Parça & Geri Dönüşüm",
      "Oto Hurda & Parçalanmış Araç",
      "Yağ & Filtre & Sarf Malzeme",
      "Madeni Yağ Distribütörü"
    ],
    "Mekanik & Motor": [
      "Genel Mekanik Bakım",
      "Motor Revizyon (Rektefiye)",
      "Şanzıman Tamiri (Otomatik/Manuel)",
      "Turbo Revizyon & Onarım",
      "Pompa & Enjektör Servisi",
      "Radyatör & Isı Sistemleri",
      "Egzoz & Emisyon & DPF Temizliği"
    ],
    "Şase & Alt Takım": [
      "Şase Düzeltme & Doğrultma",
      "Makasçı & Ağır Vasıta Süspansiyon",
      "Rot-Balans & Jant Düzeltme",
      "Amortisör & Helezon Tamiri",
      "Diferansiyel Onarım",
      "Lastik & Jant Satış / Tamir"
    ],
    "Elektrik & Yazılım": [
      "Oto Elektrik Genel",
      "Beyin (ECU) Tamiri & Yazılım",
      "Chip Tuning & Performans",
      "Akü & Marş & Şarj Sistemleri",
      "Dijital Gösterge & Multimedya",
      "Kilit & Alarm & Sunroof Tamiri",
      "Otonom Sürüş & Radar Kalibrasyonu" // Yeni Nesil Kalkan
    ],
    "Kaporta & Estetik": [
      "Kaporta Onarım & Şase İskelet",
      "Fırın Boya & Renk Mikseri",
      "PDR (Boyasız Göçük Düzeltme)",
      "Oto Cam Değişimi & Film",
      "Döşeme & Tavan & İç Restorasyon",
      "Pasta Cila & Seramik Kaplama",
      "Oto Kuaför & Detaylı Temizlik"
    ],
    "Özel Araçlar & Lojistik": [
      "Kurtarıcı & 7/24 Yol Yardım",
      "Rent a Car (Araç Kiralama)",
      "Ağır Vasıta (Kamyon/Tır) Servisi",
      "Motosiklet Tamir & Bakım",
      "İş Makinesi Onarım & Hidrolik",
      "Ekspertiz & Oto Test Merkezi"
    ],
    "Yeni Nesil (Kuantum) Sistemler": [
      "Elektrikli Araç (EV) Servisi",
      "EV Batarya Onarım & Değişim", // Yeni Nesil Karargah Hedefi
      "Hibrit (Hybrid) Sistem Onarımı",
      "LPG & Doğalgaz Dönüşüm Merkezi",
      "Klima & İklimlendirme Uzmanı",
      "Off-Road & 4x4 Modifiye"
    ]
  };

  // ── 🚀 KÜTÜPHANE OPERASYON MOTORLARI ──

  /// Sistemi UI (Arayüz) tarafında kullanmak için tüm branşları tek bir düz liste olarak fırlatır.
  static List<String> tumHizmetleriGetir() {
    developer.log("📡 SİBER KÜTÜPHANE: Tüm branşlar sisteme yükleniyor...");
    List<String> tumu = [];
    masterListe.forEach((kategori, altBasliklar) {
      tumu.addAll(altBasliklar);
    });
    return tumu;
  }

  /// Sadece belirli bir kategoriye ait branşları fırlatır.
  static List<String> kategoriyeGoreHizmetleriGetir(String kategoriAdi) {
    if (masterListe.containsKey(kategoriAdi)) {
      return masterListe[kategoriAdi]!;
    } else {
      developer.log("🚨 SİBER İHLAL: '$kategoriAdi' adında bir kategori Kuantum Ağında bulunamadı!");
      return []; // Sistem çökmesini önlemek için boş liste döner
    }
  }

  /// Karargah UI tasarımları için sadece ana kategorilerin isimlerini fırlatır.
  static List<String> anaKategorileriGetir() {
    return masterListe.keys.toList();
  }
}