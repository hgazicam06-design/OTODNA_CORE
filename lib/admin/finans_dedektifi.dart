import 'package:cloud_firestore/cloud_firestore.dart';

/// OTODNA FİNANSAL İSTİHBARAT VE DENETİM SERVİSİ (KARA KASA)
class FinansDedektifiServisi {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- 💰 SİBER RÖNTGEN: FİREBASE CANLI SATIŞ VE PAY ANALİZİ ---
  Future<Map<String, dynamic>> derinSatisAnaliziYap() async {
    try {
      // 1. Kuantum Ağındaki son 100 finansal işlemi (veya o günkü işlemleri) çek
      QuerySnapshot snap = await _db
          .collection('finansal_islemler')
          .orderBy('islem_tarihi', descending: true)
          .limit(100)
          .get();

      double toplamHacim = 0.0;
      double toplamGaziPayi = 0.0;
      List<Map<String, dynamic>> supheliIslemler = [];
      List<Map<String, dynamic>> analizDozumu = [];

      // 2. Her bir işlemi ilmek ilmek tara
      for (var doc in snap.docs) {
        var data = doc.data() as Map<String, dynamic>;

        String bayiAdi = data['bayi_adi'] ?? 'Bilinmeyen Bayi';
        String hizmetTipi = data['hizmet_tipi'] ?? 'Tanımsız Hizmet';
        double tutar = (data['tutar'] ?? 0).toDouble();

        // Gazi Komutan Anlaşması: Net %12 Pay
        double gaziPayi = tutar * 0.12;

        toplamHacim += tutar;
        toplamGaziPayi += gaziPayi;

        analizDozumu.add({
          'islem_id': doc.id,
          'bayi': bayiAdi,
          'hizmet': hizmetTipi,
          'tutar': tutar,
          'komutan_payi': gaziPayi,
          'tarih': data['islem_tarihi'],
        });

        // 🚨 SİBER DENETİM: Vergi kaçırma veya usulsüzlük ihtimaline karşı çok düşük tutarlı işlemleri tespit et (Örn: 50 TL altı)
        if (tutar > 0 && tutar < 50) {
          supheliIslemler.add({
            'bayi': bayiAdi,
            'tutar': tutar,
            'hizmet': hizmetTipi,
          });
        }
      }

      // 3. Şüpheli durum varsa Amiral Gemisi loglarına (Kara Kutu) kırmızı alarm olarak yaz
      if (supheliIslemler.isNotEmpty) {
        await _db.collection('sistem_loglari').add({
          'islem_turu': 'hata', // Kırmızı alarm tetikleyici
          'islem_detayi': 'FİNANSAL RİSK: ${supheliIslemler.length} adet şüpheli/düşük tutarlı işlem tespit edildi!',
          'bayi_isim': 'SİSTEM DENETİM MERKEZİ',
          'tarih': FieldValue.serverTimestamp(),
        });
      }

      // 4. Analiz raporunu amiral gemisine fırlat
      return {
        'basarili': true,
        'islem_sayisi': snap.docs.length,
        'toplam_hacim': toplamHacim,
        'toplam_komutan_payi': toplamGaziPayi,
        'supheli_islem_sayisi': supheliIslemler.length,
        'detayli_rapor': analizDozumu,
      };

    } catch (e) {
      // Hata durumunda sistemi çökertme, log fırlat
      return {
        'basarili': false,
        'hata': 'Siber Finans Ağına Bağlanılamadı: $e'
      };
    }
  }
}