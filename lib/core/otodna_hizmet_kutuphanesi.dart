// lib/core/otodna_hizmet_kutuphanesi.dart
import 'dart:developer' as developer;

/// 🛡️ KUANTUM OTODNA HİZMET KÜTÜPHANESİ (SiberHizmetKutuphanesi)
/// Karargahın tüm otomotiv branşlarını, ustalarını ve kategorilerini barındıran siber matris.
class SiberHizmetKutuphanesi {

  // ── 🧠 KARARGAH MASTER LİSTESİ (DEĞİŞTİRİLEMEZ ANA VERİ) ──
  static const Map<String, List<String>> masterListe = {
    "Mekanik & Motor": [
      "Genel Mekanik Bakım",
      "Motor Revizyon (Rektefiye)",
      "Şanzıman Tamiri (Otomatik/Manuel)",
      "Turbo Revizyon & Onarım",
      "Pompa & Enjektör Servisi",
      "Radyatör & Isı Sistemleri",
      "Torna & Kapak Taşlama"
    ],
    "Şase & Alt Takım": [
      "Şase Düzeltme & Doğrultma",
      "Makas Tamiri & Değişimi",
      "Rot-Balans & Jant Düzeltme",
      "Amortisör & Süspansiyon Sistemleri",
      "Diferansiyel Onarım"
    ],
    "Elektrik & Yazılım": [
      "Oto Elektrik Genel",
      "Beyin (ECU) Tamiri & Yazılım",
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
    "Lojistik & Ticari": [
      "Kurtarıcı & 7/24 Yol Yardım",
      "Rent a Car (Araç Kiralama)",
      "Sürücü Kursu & Eğitim",
      "Ağır Vasıta (Kamyon/Tır) Servisi",
      "İş Makinesi Onarım & Hidrolik"
    ],
    "Özel Sistemler & Yeni Nesil": [
      "Ekspertiz & Oto Test Merkezi",
      "Elektrikli Araç (EV) & Hibrit Servisi",
      "EV Batarya Onarım & Değişim", // Yeni Nesil Karargah Hedefi
      "LPG & Doğalgaz Dönüşüm",
      "Egzoz & Emisyon & DPF Temizliği",
      "Klima & İklimlendirme",
      "Modifiye, Off-Road & Aksesuar Montaj"
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