import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ OTODNA KUANTUM MATEMATİK VE PAY DAĞITIM MOTORU (ÇEKİRDEK)
/// Karargahın Mutlak %12 (10+2) kuralını milimetrik hesaplayan ana sistem.
class GaziPayiHesaplayici {
  static Future<Map<String, double>> hesaplaVeDenetle({
    required double sonSatisFiyati,
    required String bayiId,
    required String bayiAdi,
  }) async {
    developer.log("SİBER MATEMATİK: $bayiAdi ($bayiId) için ₺$sonSatisFiyati tutarında hesaplama başlatıldı...");

    // 🛡️ 1. AŞAMA: Negatif Tutar Engelleme Kalkanı
    if (sonSatisFiyati <= 0) {
      await _logHata(bayiId, 'SİBER İHLAL: Negatif veya sıfır tutar girildi! Tutar: $sonSatisFiyati');
      developer.log("KRİTİK İHLAL: Sıfır veya negatif tutarla Karargah kasası açılamaz!");
      throw Exception("KUANTUM İHLALİ: İşlem tutarı 0 veya negatif olamaz!");
    }

    // 💰 2. GAZİ KOMUTAN STRATEJİSİ (MUTLAK KURAL)
    // İSTİSNA YOK! Tüm işlemlerden %12 (%10 Net Kâr + %2 Devlet Vergisi) kesilir.
    double vergi = sonSatisFiyati * 0.02;
    double gaziNet = sonSatisFiyati * 0.10;

    double toplamKesinti = gaziNet + vergi;
    double bayiHakedis = sonSatisFiyati - toplamKesinti;

    // 🚨 3. ANOMALİ TARAMASI (100 TL altı şüpheli işlemler)
    if (sonSatisFiyati < 100) {
      developer.log("SİBER UYARI: Çok düşük tutarlı işlem tespit edildi. Kara Kutuya S.O.S gönderiliyor!");
      await _logHata(bayiId, 'ŞÜPHELİ İŞLEM: Düşük tutarlı satış tespit edildi! Tutar: $sonSatisFiyati', isSos: true);
    }

    developer.log("SİBER HESAP TAMAM: Brüt: ₺$sonSatisFiyati | Karargah: ₺$gaziNet | Vergi: ₺$vergi | Bayi: ₺$bayiHakedis");

    return {
      "brut_satis": _kusursuzYuvarla(sonSatisFiyati),
      "gazi_net": _kusursuzYuvarla(gaziNet),
      "vergi": _kusursuzYuvarla(vergi),
      "bayi_hakedis": _kusursuzYuvarla(bayiHakedis),
    };
  }

  // ── 📡 KARA KUTU SİNYAL MOTORU ───────────────────────────────────────────
  static Future<void> _logHata(String bayiId, String mesaj, {bool isSos = false}) async {
    try {
      await FirebaseFirestore.instance.collection('sistem_loglari').add({
        'islem_turu': isSos ? 'SÜPHELİ_İŞLEM_SOS' : 'KRİTİK_HATA',
        'islem_detayi': mesaj,
        'bayi_isim': 'Bayi ID: $bayiId',
        'tarih': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Hata günlüğü Karargaha iletilemedi!", error: e);
    }
  }

  // Virgülden sonraki küsuratları milimetrik tıraşlayan Kuantum Bıçağı
  static double _kusursuzYuvarla(double deger) => double.parse(deger.toStringAsFixed(2));
}