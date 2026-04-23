// lib/core/otodna_hizmet_kutuphanesi.dart
import 'dart:developer' as developer;

/// 🛡️ KUANTUM OTODNA HİZMET KÜTÜPHANESİ (SiberHizmetKutuphanesi)
/// Karargahın tüm otomotiv branşlarını, ustalarını ve kategorilerini barındıran siber matris.
class SiberHizmetKutuphanesi {

  // ── 🧠 KARARGAH MASTER LİSTESİ (DEĞİŞTİRİLEMEZ ANA VERİ) ──
  static const Map<String, List<String>> masterListe = {
    "OTO MEKANİK & REVİZYON": [
      "Periyodik Bakım",
      "Motor Rektefiye",
      "Şanzıman Tamiri (Manuel)",
      "Otomatik Şanzıman Tamiri",
      "Direksiyon Kutusu Tamiri",
      "Şaft & Diferansiyel Tamiri",
      "Torsiyon Tamiri",
      "Kapakçı İşlemleri",
      "Tornacı İşlemleri"
    ],
    "OTO ELEKTRİK & ELEKTRONİK": [
      "Genel Oto Elektrik",
      "ECU (Beyin) Tamiri",
      "Sigorta Kutusu Tamiri",
      "Far Ayarı & Restorasyonu",
      "Akü Satış & Servis",
      "Alarm Sistemleri",
      "Park Sensörü Montajı",
      "Multimedya & Ses Sistemleri",
      "Gizli Özellik Açma",
      "Yazılım Güncelleme (Chiptuning/Remap)"
    ],
    "İKLİMLENDİRME": [
      "Klima Gaz Dolumu",
      "Klima Kompresör Tamiri",
      "Kalorifer Petek Temizliği (Makinalı)",
      "Klima Dezenfeksiyonu"
    ],
    "KAPORTA, BOYA & ESTETİK": [
      "Fırın Boya",
      "Mikron (Lokal) Boya",
      "Boyasız Göçük Düzeltme (PDR)",
      "Şasi Düzeltme (Şaseci)",
      "Ziftleme & Alt Koruma",
      "Araç Kaplama (PPF/Folyolama)",
      "Karlık & Body Kit (Karlıkçı)"
    ],
    "GÜVENLİK & KİLİT": [
      "İmmobilizer Çözümleri",
      "Anahtar Kodlama & Yedekleme",
      "Oto Kilit Tamiri",
      "Cam Tamiri & Değişimi"
    ],
    "EGZOZ & EMİSYON": [
      "Egzoz Tamiri & Manifold",
      "Partikül Filtresi (DPF) Temizliği",
      "Katalizör Değişimi",
      "Egzoz Emisyon Ölçüm İstasyonu"
    ],
    "LASTİK & ALT TAKIM": [
      "Rot Ayarı",
      "Balans Ayarı",
      "Lastik Tamiri & Değişimi",
      "Jant Düzeltme & Boyama",
      "Fren Testi & Tamiri"
    ],
    "KURUMSAL & LOJİSTİK": [
      "Oto Ekspertiz",
      "Yol Yardım & Çekici",
      "Ahtapot Çekici (Özel Tahliye)",
      "Rent A Car (Oto Kiralama)",
      "Sigorta & Kasko Aracılık"
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

  // ── 🏷️ SİBER ETİKET (TAG) ÜRETİCİ MOTOR ──
  /// Seçilen kategori ve branştan Firestore aramaları için optimize edilmiş etiketler üretir.
  /// Örn: "İKLİMLENDİRME" ve "Klima Gaz Dolumu" -> ["iklimlendirme", "klima_gaz_dolumu"]
  static List<String> etiketUret(String kategori, String brans) {
    List<String> etiketler = [];
    
    String turkceKarakterTemizle(String metin) {
      return metin.toLowerCase()
          .replaceAll('ı', 'i')
          .replaceAll('ğ', 'g')
          .replaceAll('ü', 'u')
          .replaceAll('ş', 's')
          .replaceAll('ö', 'o')
          .replaceAll('ç', 'c')
          .replaceAll(' & ', '_')
          .replaceAll(',', '')
          .replaceAll(RegExp(r'[()/]'), '')
          .trim()
          .replaceAll(RegExp(r'\s+'), '_')
          .replaceAll('__', '_');
    }

    String formatliKategori = turkceKarakterTemizle(kategori);
    String formatliBrans = turkceKarakterTemizle(brans);

    if (!etiketler.contains(formatliKategori)) etiketler.add(formatliKategori);
    if (!etiketler.contains(formatliBrans)) etiketler.add(formatliBrans);

    // Kuantum Parçalama: Eğer branş "klima_gaz_dolumu" ise sadece "klima" yı da ekle
    List<String> kelimeler = formatliBrans.split('_');
    for (String kelime in kelimeler) {
      if (kelime.length > 2 && !etiketler.contains(kelime)) {
        etiketler.add(kelime);
      }
    }

    return etiketler;
  }
}