import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🌊 SİBER MEGA PARÇA MOTORU (Şelale Arama Sistemi)
/// Ustanın el yazısı listesini okuyan, ardından tüm Kuantum ağında
/// Orijinal -> Yan Sanayi -> Çıkma -> Hurdacı İhalesi şelale sırasıyla 
/// parçaları arayıp müşteriye sepet sunan Kuantum Backend Servisi.
class SiberMegaParcaMotoru {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =======================================================================
  // 1. YAPAY ZEKA GÖRÜNTÜ İŞLEME (OCR) SİMÜLASYONU
  // =======================================================================
  /// Kameradan gelen fotoğrafı tarayıp içindeki yedek parça listesini çıkarır.
  Future<List<String>> ocrIleListeyiCikar(String imagePath) async {
    // Gerçekte burada Google ML Kit Text Recognition veya Cloud Vision API kullanılır.
    await Future.delayed(Duration(seconds: 2)); // AI analiz süresi simülasyonu
    
    return [
      "Ön Fren Disk Takımı",
      "Sağ Ön Çamurluk",
      "Krank Mili",
      "Hava Filtresi",
      "Triger Kayış Seti"
    ];
  }

  // =======================================================================
  // 2. KADEMELİ ŞELALE ARAMA MOTORU
  // =======================================================================
  /// 50 kalem listeyi alır. Orijinal -> Yan Sanayi -> Çıkma sırasıyla tarar.
  /// Bulamadıklarını 'ihaleBekliyor' listesine atar.
  Future<Map<String, dynamic>> selaleTaramasiBaslat(List<String> parcaListesi, String uyumluMarka) async {
    List<Map<String, dynamic>> sepeteEklenenler = [];
    List<String> bulunamayanParcalar = [];

    // Gerçek senaryoda bu döngü `Future.wait` ile paralel veya `whereIn` ile toplu atılır.
    for (String parcaAdi in parcaListesi) {
      bool parcaBulundu = false;

      // KADEME 1: SIFIR (ORİJİNAL) ARAMASI
      var orijinalSorgu = await _db.collection('yedek_parcalar')
          .where('urun_ad', isEqualTo: parcaAdi)
          .where('marka', isEqualTo: uyumluMarka)
          .where('urun_durumu', isEqualTo: 'Sıfır (Orijinal)')
          .limit(1).get();

      if (orijinalSorgu.docs.isNotEmpty) {
        sepeteEklenenler.add(_dokumanMapYap(orijinalSorgu.docs.first, 'Sıfır (Orijinal)'));
        parcaBulundu = true;
      }

      // KADEME 2: SIFIR (YAN SANAYİ) ARAMASI
      if (!parcaBulundu) {
        var yanSanayiSorgu = await _db.collection('yedek_parcalar')
            .where('urun_ad', isEqualTo: parcaAdi)
            .where('marka', isEqualTo: uyumluMarka)
            .where('urun_durumu', isEqualTo: 'Sıfır (Yan Sanayi / Muadil)')
            .limit(1).get();

        if (yanSanayiSorgu.docs.isNotEmpty) {
          sepeteEklenenler.add(_dokumanMapYap(yanSanayiSorgu.docs.first, 'Sıfır (Yan Sanayi / Muadil)'));
          parcaBulundu = true;
        }
      }

      // KADEME 3: ÇIKMA (İKİNCİ EL) ARAMASI
      if (!parcaBulundu) {
        var cikmaSorgu = await _db.collection('yedek_parcalar')
            .where('urun_ad', isEqualTo: parcaAdi)
            .where('marka', isEqualTo: uyumluMarka)
            .where('urun_durumu', isEqualTo: 'Çıkma / İkinci El')
            .limit(1).get();

        if (cikmaSorgu.docs.isNotEmpty) {
          sepeteEklenenler.add(_dokumanMapYap(cikmaSorgu.docs.first, 'Çıkma / İkinci El'));
          parcaBulundu = true;
        }
      }

      // KADEME 4: HİÇBİR YERDE YOK (HURDACI İHALESİNE GİDECEK)
      if (!parcaBulundu) {
        bulunamayanParcalar.add(parcaAdi);
      }
    }

    // TOPLAM TUTAR HESAPLAMA
    double toplamTutar = sepeteEklenenler.fold(0, (totalSum, item) => totalSum + (item['liste_fiyati'] as double));

    return {
      'bulunanlar': sepeteEklenenler,
      'eksikler': bulunamayanParcalar,
      'toplamTutar': toplamTutar,
    };
  }

  // =======================================================================
  // 3. İKİNCİ EL / HURDACI İHALESİ (B2B TEKLİF AĞI)
  // =======================================================================
  /// Bulunamayan parçalar için sistemdeki çıkmacılara (hurdacılara) 
  /// "Müşteri x parçasını arıyor, teklif verin" diye yayın atar.
  Future<void> hurdaciIhalesiBaslat(List<String> eksikParcalar, String musteriUid, String aracMarkasi) async {
    try {
      WriteBatch batch = _db.batch();

      for (String parcaAdi in eksikParcalar) {
        DocumentReference ihaleRef = _db.collection('siber_ihaleler').doc();
        batch.set(ihaleRef, {
          'musteri_uid': musteriUid,
          'aranan_parca': parcaAdi,
          'arac_markasi': aracMarkasi,
          'ihale_durumu': 'Açık (Teklif Bekleniyor)',
          'olusturulma_tarihi': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      developer.log("🚨 HURDACI İHALESİ BAŞLATILDI: ${eksikParcalar.length} parça için teklif toplanıyor.");
    } catch (e) {
      developer.log("İhale Başlatma Hatası: $e");
    }
  }

  /// Firestore dökümanını UI'ın okuyabileceği formata çevirir.
  Map<String, dynamic> _dokumanMapYap(QueryDocumentSnapshot doc, String bulunanDurum) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return {
      'id': doc.id,
      'urun_ad': data['urun_ad'],
      'liste_fiyati': data['liste_fiyati'],
      'bayi_adi': data['bayi_adi'],
      'bulunan_durum': bulunanDurum // Orjinal mi Çıkma mı olduğu
    };
  }
}
