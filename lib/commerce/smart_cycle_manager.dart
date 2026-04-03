import 'package:cloud_firestore/cloud_firestore.dart';

class SmartCycleManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. ARACA ÖZEL "SAĞLIK VE DEĞER" ANALİZİ (GERÇEK FİREBASE BAĞLANTISI)
  Future<void> analizEt({required String plakaID}) async {
    try {
      // 1. Kuantum Ağından Aracın Gerçek Verilerini Çek
      DocumentReference aracRef = _firestore.collection('araclar').doc(plakaID);
      DocumentSnapshot aracSnap = await aracRef.get();

      if (!aracSnap.exists) return;

      double mevcutDeger = (aracSnap.get('fiyat') ?? 0).toDouble();
      bool hasKritikHata = aracSnap.get('kritik_hata_var_mi') ?? false;

      if (hasKritikHata) {
        // 📉 Kırmızı X varsa: Aracın değerini %15 düşür ve veritabanını güncelle
        double yeniDeger = mevcutDeger * 0.85;

        await aracRef.update({
          'fiyat': yeniDeger, // Fiyatı revize ettik
          'deger_durumu': 'Kritik Hata Nedeniyle Revize Edildi',
          'statu': 'Riskli - Onarım Bekliyor',
          'son_analiz_tarihi': FieldValue.serverTimestamp(),
        });

        // Burada OtoDnaEcoSystem içindeki parcaOner() motorunu tetikleyerek
        // %30 kâr marjlı parçayı anında sisteme düşürebiliriz.

      } else {
        // 💎 Kusursuzsa: OtoDNA Gold statüsüne yükselt
        await aracRef.update({
          'statu': 'OtoDNA Gold',
          'deger_durumu': 'Korunuyor (Kusursuz)',
          'dna_skoru': 100,
          'son_analiz_tarihi': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print("Kritik Analiz Hatası: $e");
    }
  }

  // 2. KOMUTAN GAZİ FİNANSAL İSTİHBARAT ÖZETİ (CANLI VERİ ÇEKİMİ)
  // Bu fonksiyon UI ekranına (Siber Cüzdan) gerçek rakamları döndürür.
  Future<Map<String, double>> gunlukTicariOzet() async {
    double parcaKari = 0;
    double galeriKari = 0;
    double toplamGaziPayi = 0; // %10 Kâr + %2 Vergi = %12

    try {
      // 📦 Yedek Parça Satışlarından Gelen Gazi Payını Topla
      QuerySnapshot parcaSnap = await _firestore
          .collection('yedek_parca_onerileri')
          .where('durum', isEqualTo: 'Satıldı')
          .get();

      for (var doc in parcaSnap.docs) {
        var data = doc.data() as Map<String, dynamic>;
        toplamGaziPayi += (data['gazi_komisyon_vergi_payi'] ?? 0).toDouble();

        // Eğer Murat Plaza ise %30 kârın toplamını da ayrıca hesaplayabiliriz
        if (data['sunan_bayi'] == 'Murat Plaza') {
          parcaKari += (data['musteri_satis_fiyati'] - data['orijinal_alis_fiyati']);
        }
      }

      // 💎 Aynı mantıkla Galeri satış komisyonlarını 'galeri_satislar' tablosundan toplayabiliriz
      // ... (Gelecekte buraya eklenecek)

    } catch (e) {
      print("Finans İstihbarat Hatası: $e");
    }

    // Arayüze (Ekrana) basılması için verileri paketleyip gönderiyoruz
    return {
      "parca_kari": parcaKari,
      "galeri_kari": galeriKari,
      "toplam_gazi_payi": toplamGaziPayi,
    };
  }
}