// lib/services/smart_cycle_manager.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ OTODNA AKILLI ARA-MUAYENE, DEĞER ANALİZİ VE FİNANSAL RADAR MOTORU
class SmartCycleManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. ARACA ÖZEL "SAĞLIK VE DEĞER" ANALİZİ (GERÇEK FİREBASE BAĞLANTISI)
  Future<void> analizEt({required String plakaID}) async {
    try {
      WriteBatch batch = _firestore.batch(); // 🔥 Kuantum Mührü

      // 1. Kuantum Ağından Aracın Gerçek Verilerini Çek
      DocumentReference aracRef = _firestore.collection('araclar').doc(plakaID);
      DocumentSnapshot aracSnap = await aracRef.get();

      if (!aracSnap.exists) {
        developer.log("SİBER İHBAR: $plakaID plakalı araç Kuantum Ağında bulunamadı.");
        return;
      }

      var data = aracSnap.data() as Map<String, dynamic>;
      double mevcutDeger = (data['fiyat'] ?? 0).toDouble();
      bool hasKritikHata = data['kritik_hata_var_mi'] ?? false;

      if (hasKritikHata) {
        // 📉 Kırmızı X varsa: Aracın değerini %15 düşür ve veritabanını güncelle
        double yeniDeger = mevcutDeger * 0.85;

        batch.update(aracRef, {
          'fiyat': yeniDeger, // Fiyat revize edildi
          'deger_durumu': 'Kritik Hata Nedeniyle Revize Edildi',
          'statu': 'Riskli - Onarım Bekliyor',
          'dna_skoru': FieldValue.increment(-20), // DNA puanı düşürülür
          'son_analiz_tarihi': FieldValue.serverTimestamp(),
        });

        // 🔥 SİBER KALKAN: Bu değer kaybını Karargahın Kara Kutusuna mühürle!
        DocumentReference logRef = _firestore.collection('sistem_loglari').doc();
        batch.set(logRef, {
          'islem_turu': 'KRITIK_ALARM',
          'islem_detayi': 'DEĞER KAYBI: $plakaID plakalı araç Kırmızı X sebebiyle %15 değer kaybetti.',
          'birim': 'SİBER ANALİZ MOTORU',
          'tarih': FieldValue.serverTimestamp(),
        });

      } else {
        // 💎 Kusursuzsa: OtoDNA Gold statüsüne yükselt ve DNA'yı mühürle
        batch.update(aracRef, {
          'statu': 'OtoDNA Gold',
          'deger_durumu': 'Korunuyor (Kusursuz)',
          'dna_skoru': 100,
          'son_analiz_tarihi': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit(); // Tüm işlemleri tek seferde Kuantum Ağına ateşle!
      developer.log("ANALİZ TAMAMLANDI: $plakaID plakalı aracın DNA'sı mühürlendi.");

    } catch (e) {
      developer.log("ANALİZ ÇÖKTÜ: $plakaID siber değer analizi yapılamadı! Hata: $e");
      await _firestore.collection('sistem_loglari').add({
        'islem_turu': 'HATA',
        'islem_detayi': 'ANALİZ ÇÖKTÜ: $plakaID plakalı aracın siber değer analizi yapılamadı! Hata: $e',
        'bayi_isim': 'SİBER ANALİZ MOTORU',
        'tarih': FieldValue.serverTimestamp(),
      });
    }
  }

  // 2. KOMUTAN GAZİ FİNANSAL İSTİHBARAT ÖZETİ (CANLI VERİ ÇEKİMİ)
  Future<Map<String, double>> gunlukTicariOzet() async {
    double toplamBayiHakedisi = 0;
    double toplamGaziPayi = 0; // Evrensel Kural: Her İşlemden Toplam %12

    try {
      // 📦 Yedek Parça Satışlarından Gelen Verileri Topla
      QuerySnapshot parcaSnap = await _firestore
          .collection('parca_teklifleri')
          .get();

      for (var doc in parcaSnap.docs) {
        var data = doc.data() as Map<String, dynamic>;

        // 🔥 SİBER FİNANS KURALI: Tüm işlemlerden %12 Karargah Payı mühürlenir.
        double komisyon = (data['karargah_payi'] ?? 0).toDouble();
        toplamGaziPayi += komisyon;

        // Bayinin Eline Geçen Net Hakediş
        double hakedis = (data['bayi_hakedis'] ?? 0).toDouble();
        toplamBayiHakedisi += hakedis;
      }

    } catch (e) {
      developer.log("FİNANSAL İSTİHBARAT ÇÖKTÜ: Günlük ticari özet çekilemedi! Hata: $e");
    }

    return {
      "bayi_kazanci": toplamBayiHakedisi,
      "toplam_gazi_payi": toplamGaziPayi,
    };
  }
}