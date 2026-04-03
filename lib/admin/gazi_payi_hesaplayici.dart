import 'package:cloud_firestore/cloud_firestore.dart';

/// OTODNA KUANTUM MATEMATİK VE PAY DAĞITIM MOTORU (ÇEKİRDEK)
/// Bu sınıf sadece hesaplama yapmaz, aynı zamanda Siber Anomali taraması yapar.
class GaziPayiHesaplayici {

  // SİBER HESAPLAMA VE DENETİM ALGORİTMASI
  static Future<Map<String, double>> hesaplaVeDenetle({
    required double sonSatisFiyati,
    required String bayiId,
    required String bayiTipi
  }) async {

    // 🛡️ 1. AŞAMA KALKAN: Negatif veya sıfır tutar engellemesi!
    if (sonSatisFiyati <= 0) {
      // İhlal durumunda füzeyi ateşle ve doğrudan Kara Kutuya (Sistem Logları) mühürle
      await FirebaseFirestore.instance.collection('sistem_loglari').add({
        'islem_turu': 'hata', // Kırmızı Alarm
        'islem_detayi': 'SİBER İHLAL (KRİTİK): Sıfır veya negatif tutarlı işlem denemesi engellendi. Girilen Tutar: ₺$sonSatisFiyati',
        'bayi_isim': 'Bayi ID: $bayiId',
        'tarih': FieldValue.serverTimestamp(),
      });
      throw Exception("Kuantum İhlali: İşlem tutarı 0 veya negatif olamaz!");
    }

    // 💰 2. GAZİ KOMUTAN PAYI ALGORİTMASI (Değişmez Kural: Net %10 + Vergi %2)
    double toplamGaziPayi = sonSatisFiyati * 0.12;
    double gaziNet = sonSatisFiyati * 0.10;
    double vergi = sonSatisFiyati * 0.02;
    double bayiHakedis = sonSatisFiyati - toplamGaziPayi;

    // 🚨 3. ANOMALİ TARAMASI: Çok düşük tutarlı satış (Sistemi manipüle etme veya vergi kaçırma ihtimali)
    if (sonSatisFiyati > 0 && sonSatisFiyati < 100) {
      await FirebaseFirestore.instance.collection('sistem_loglari').add({
        'islem_turu': 'sos', // Turuncu/Mavi Uyarı
        'islem_detayi': 'ŞÜPHELİ İŞLEM: Çok düşük tutarlı şüpheli satış (₺$sonSatisFiyati). Vergi veya komisyon kaçırma şüphesi incelenmeli.',
        'bayi_isim': 'Bayi ID: $bayiId',
        'tarih': FieldValue.serverTimestamp(),
      });
    }

    // ⚙️ 4. HASSASİYET FİLTRESİ: Kuruş hanelerini sabitle (Örn: 10.54000000001 hatasını engelle)
    return {
      "brut_satis": _kusursuzYuvarla(sonSatisFiyati),
      "gazi_net": _kusursuzYuvarla(gaziNet),
      "vergi": _kusursuzYuvarla(vergi),
      "bayi_hakedis": _kusursuzYuvarla(bayiHakedis),
    };
  }

  // Finansal sistemlerde milimetrik sapmaları önleyen Kuantum Yuvarlama Metodu
  static double _kusursuzYuvarla(double deger) {
    return double.parse(deger.toStringAsFixed(2));
  }
}