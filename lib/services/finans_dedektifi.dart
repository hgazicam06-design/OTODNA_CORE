import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ OTODNA FİNANSAL İSTİHBARAT VE DENETİM SERVİSİ (KARA KASA)
/// Tüm finansal işlemleri %12 (Mutlak Pay) kuralına göre otonom denetler.
class FinansDedektifiServisi {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- 💰 SİBER RÖNTGEN: FİREBASE CANLI SATIŞ VE PAY ANALİZİ ---
  Future<Map<String, dynamic>> derinSatisAnaliziYap() async {
    try {
      developer.log("SİBER RADAR: Finansal röntgen başlatıldı. Son 100 işlem Kuantum Ağından çekiliyor...");

      // 1. Kuantum Ağındaki son 100 finansal işlemi çek
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

        // 🔥 SİBER FİNANS KURALI: İSTİSNA YOK! Her işlem için Karargah Payı Mutlak %12'dir.
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
        developer.log("SİBER İHLAL: ${supheliIslemler.length} adet şüpheli/düşük tutarlı işlem tespit edildi. Kara Kutuya mühürleniyor!");

        WriteBatch batch = _db.batch(); // 🔥 İşlemi Atomik Mühürle Yap
        DocumentReference logRef = _db.collection('sistem_loglari').doc();

        batch.set(logRef, {
          'islem_turu': 'KRİTİK_HATA', // Kırmızı alarm tetikleyici
          'islem_detayi': 'FİNANSAL RİSK: ${supheliIslemler.length} adet şüpheli/düşük tutarlı işlem tespit edildi!',
          'bayi_isim': 'SİSTEM DENETİM MERKEZİ',
          'tarih': FieldValue.serverTimestamp(),
        });

        await batch.commit(); // Mührü ateşle
      }

      developer.log("SİBER BİLGİ: Finansal röntgen tamamlandı. Toplam Hacim: ₺$toplamHacim, Karargah Payı: ₺$toplamGaziPayi");

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
      developer.log("AĞ ÇÖKTÜ: Siber Finans Ağına Bağlanılamadı!", error: e);
      // Hata durumunda sistemi sessizce çökertme, Arayüze KIRMIZI ALARM fırlat!
      throw Exception("FİNANSAL RÖNTGEN HATASI: Kuantum Ağına erişilemiyor!");
    }
  }
}