import 'package:cloud_firestore/cloud_firestore.dart';

class OtoDnaEcoSystem {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. GALERİ VE PARÇA ENTEGRASYONU (GERÇEK FİREBASE MOTORU)
  // Usta muayenede Kırmızı X (❌) bastığı an bu motor tetiklenir.
  Future<void> parcaOner({
    required String plakaID,
    required String sorunluParca,
    required double parcaAlisFiyati,
    required String saticiBayiAdi,
  }) async {
    try {
      double musteriSatisFiyati = 0;
      double komutanGaziPayi = 0;

      // ⚙️ TİCARET MOTORU: Kâr Marjı ve Komisyon Hesaplaması
      if (saticiBayiAdi == "Murat Plaza") {
        // Murat Plaza özel anlaşması: %30 Kâr Marjı
        musteriSatisFiyati = parcaAlisFiyati * 1.30;
        komutanGaziPayi = musteriSatisFiyati - parcaAlisFiyati;
      } else {
        // Diğer Tüm Bayiler: Komutan Gazi için %10 Kâr + %2 Vergi = Toplam %12 Sistem Payı
        musteriSatisFiyati = parcaAlisFiyati * 1.12;
        komutanGaziPayi = parcaAlisFiyati * 0.12;
      }

      // ⚙️ GİZLİLİK PROTOKOLÜ: Orijinal şirket isimleri gizlenir, ürün bayinin kendi adıyla sunulur.
      String gorunenTedarikci = saticiBayiAdi;

      // 🚀 FİREBASE'E GERÇEK KAYIT BAŞLIYOR
      await _firestore.collection('yedek_parca_onerileri').add({
        'arac_plaka': plakaID,
        'sorunlu_parca': sorunluParca,
        'orijinal_alis_fiyati': parcaAlisFiyati, // Sadece Admin Görebilir
        'gazi_komisyon_vergi_payi': komutanGaziPayi, // Sadece Admin Görebilir
        'musteri_satis_fiyati': musteriSatisFiyati, // Kullanıcının Uygulamada Göreceği Fiyat
        'sunan_bayi': gorunenTedarikci,
        'garanti': '1 Yıl OtoDNA Garantili',
        'durum': 'Müşteri Onayı Bekliyor',
        'olusturulma_tarihi': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      print("Kritik Ağ Hatası (Parça Önerisi): $e");
    }
  }

  // 2. DİJİTAL REFERANS PROTOKOLÜ (OtoDNA Mührü)
  // Araç testten geçip Galeriye eklendiğinde mühür vurulur.
  Future<void> ilanaKoy(String plakaID) async {
    try {
      // Aracın Kuantum DNA Kaydını Veritabanından Çek
      DocumentSnapshot aracDoc = await _firestore.collection('araclar').doc(plakaID).get();

      if (aracDoc.exists) {
        int dnaSkoru = aracDoc.get('dna_skoru') ?? 0;

        // Eğer usta Kırmızı X atmamışsa ve skor yüksekse Mühürle!
        if (dnaSkoru >= 80) {
          await _firestore.collection('araclar').doc(plakaID).update({
            'otodna_onayli': true,
            'ilan_durumu': 'Yayında',
            'dijital_muhur_tarihi': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      print("Kritik Ağ Hatası (Mühürleme): $e");
    }
  }
}