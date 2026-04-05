import 'package:cloud_firestore/cloud_firestore.dart';

class SmartCycleManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. ARACA ÖZEL "SAĞLIK VE DEĞER" ANALİZİ (GERÇEK FİREBASE BAĞLANTISI)
  Future<void> analizEt({required String plakaID}) async {
    try {
      WriteBatch batch = _firestore.batch(); // 🔥 Kuantum Mührü

      // 1. Kuantum Ağından Aracın Gerçek Verilerini Çek
      DocumentReference aracRef = _firestore.collection('araclar').doc(plakaID);
      DocumentSnapshot aracSnap = await aracRef.get();

      if (!aracSnap.exists) return;

      var data = aracSnap.data() as Map<String, dynamic>;
      double mevcutDeger = (data['fiyat'] ?? 0).toDouble();
      bool hasKritikHata = data['kritik_hata_var_mi'] ?? false;

      if (hasKritikHata) {
        // 📉 Kırmızı X varsa: Aracın değerini %15 düşür ve veritabanını güncelle
        double yeniDeger = mevcutDeger * 0.85;

        batch.update(aracRef, {
          'fiyat': yeniDeger, // Fiyatı revize ettik
          'deger_durumu': 'Kritik Hata Nedeniyle Revize Edildi',
          'statu': 'Riskli - Onarım Bekliyor',
          'son_analiz_tarihi': FieldValue.serverTimestamp(),
        });

        // 🔥 SİBER KALKAN: Bu değer kaybını Karargahın Kara Kutusuna raporla!
        DocumentReference logRef = _firestore.collection('sistem_loglari').doc();
        batch.set(logRef, {
          'islem_turu': 'sos', // Sarı/Turuncu alarm
          'islem_detayi': 'DEĞER KAYBI: $plakaID plakalı araç Kırmızı X (Kritik Hata) sebebiyle %15 değer kaybetti.',
          'bayi_isim': 'SİBER ANALİZ MOTORU',
          'tarih': FieldValue.serverTimestamp(),
        });

        // Burada OtoDnaEcoSystem içindeki parcaOner() motorunu tetikleyerek
        // Karargah Paylı (%12) parçayı anında sisteme düşürebiliriz.

      } else {
        // 💎 Kusursuzsa: OtoDNA Gold statüsüne yükselt
        batch.update(aracRef, {
          'statu': 'OtoDNA Gold',
          'deger_durumu': 'Korunuyor (Kusursuz)',
          'dna_skoru': 100,
          'son_analiz_tarihi': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit(); // Tüm işlemleri tek seferde Kuantum Ağına ateşle!

    } catch (e) {
      // Print yerine Karargah Loglarına yazıyoruz
      await _firestore.collection('sistem_loglari').add({
        'islem_turu': 'hata',
        'islem_detayi': 'ANALİZ ÇÖKTÜ: $plakaID plakalı aracın siber değer analizi yapılamadı! Hata: $e',
        'bayi_isim': 'SİBER ANALİZ MOTORU',
        'tarih': FieldValue.serverTimestamp(),
      });
    }
  }

  // 2. KOMUTAN GAZİ FİNANSAL İSTİHBARAT ÖZETİ (CANLI VERİ ÇEKİMİ)
  // Bu fonksiyon UI ekranına (Siber Cüzdan) gerçek rakamları döndürür.
  Future<Map<String, double>> gunlukTicariOzet() async {
    double parcaKari = 0;
    double galeriKari = 0;
    double toplamGaziPayi = 0; // Evrensel Kural: Her İşlemden Toplam %12

    try {
      // 📦 Yedek Parça Satışlarından Gelen Gazi Payını Topla
      QuerySnapshot parcaSnap = await _firestore
          .collection('yedek_parca_onerileri')
          .where('durum', isEqualTo: 'Satıldı')
          .get();

      for (var doc in parcaSnap.docs) {
        var data = doc.data() as Map<String, dynamic>;

        // 🔥 SİBER FİNANS KURALI: Tüm bayilerden istisnasız %12 Karargah Payı gelir! (Murat Plaza imtiyazı silindi)
        toplamGaziPayi += (data['gazi_komisyon_vergi_payi'] ?? 0).toDouble();

        // Parça kârını hesapla (Satış Fiyatı - Orijinal Alış Fiyatı)
        double satisFiyati = (data['musteri_satis_fiyati'] ?? 0).toDouble();
        double alisFiyati = (data['orijinal_alis_fiyati'] ?? 0).toDouble();
        parcaKari += (satisFiyati - alisFiyati);
      }

      // 💎 Aynı mantıkla Galeri satış komisyonlarını 'galeri_satislar' tablosundan toplayabiliriz
      // ... (Gelecekte buraya eklenecek)

    } catch (e) {
      await _firestore.collection('sistem_loglari').add({
        'islem_turu': 'hata',
        'islem_detayi': 'FİNANSAL İSTİHBARAT ÇÖKTÜ: Günlük ticari özet çekilemedi! Hata: $e',
        'bayi_isim': 'FİNANS MOTORU',
        'tarih': FieldValue.serverTimestamp(),
      });
    }

    // Arayüze (Ekrana) basılması için verileri paketleyip gönderiyoruz
    return {
      "parca_kari": parcaKari,
      "galeri_kari": galeriKari,
      "toplam_gazi_payi": toplamGaziPayi,
    };
  }
}