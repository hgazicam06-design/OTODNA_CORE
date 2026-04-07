import 'package:cloud_firestore/cloud_firestore.dart';

/// OTODNA KUANTUM MATEMATİK VE PAY DAĞITIM MOTORU (ÇEKİRDEK)
class GaziPayiHesaplayici {
  static Future<Map<String, double>> hesaplaVeDenetle({
    required double sonSatisFiyati,
    required String bayiId,
    required String bayiAdi,
  }) async {
    // 🛡️ 1. AŞAMA: Negatif Tutar Engelleme
    if (sonSatisFiyati <= 0) {
      await _logHata(bayiId, 'SİBER İHLAL: Negatif veya sıfır tutar! Tutar: $sonSatisFiyati');
      throw Exception("Kuantum İhlali: Tutar 0 veya negatif olamaz!");
    }

    // 💰 2. GAZİ KOMUTAN STRATEJİSİ
    // Murat Plaza %30 (Net %28 + Vergi %2), Diğerleri %12 (Net %10 + Vergi %2)
    double vergi = sonSatisFiyati * 0.02;
    double gaziNet = 0.0;

    if (bayiAdi.toUpperCase().contains('MURAT PLAZA')) {
      gaziNet = sonSatisFiyati * 0.28;
    } else {
      gaziNet = sonSatisFiyati * 0.10;
    }

    double toplamKesinti = gaziNet + vergi;
    double bayiHakedis = sonSatisFiyati - toplamKesinti;

    // 🚨 3. ANOMALİ TARAMASI (100 TL altı işlemler)
    if (sonSatisFiyati < 100) {
      await _logHata(bayiId, 'ŞÜPHELİ İŞLEM: Düşük tutarlı satış! Tutar: $sonSatisFiyati', isSos: true);
    }

    return {
      "brut_satis": _kusursuzYuvarla(sonSatisFiyati),
      "gazi_net": _kusursuzYuvarla(gaziNet),
      "vergi": _kusursuzYuvarla(vergi),
      "bayi_hakedis": _kusursuzYuvarla(bayiHakedis),
    };
  }

  static Future<void> _logHata(String bayiId, String mesaj, {bool isSos = false}) async {
    await FirebaseFirestore.instance.collection('sistem_loglari').add({
      'islem_turu': isSos ? 'sos' : 'hata',
      'islem_detayi': mesaj,
      'bayi_isim': 'Bayi ID: $bayiId',
      'tarih': FieldValue.serverTimestamp(),
    });
  }

  static double _kusursuzYuvarla(double deger) => double.parse(deger.toStringAsFixed(2));
}