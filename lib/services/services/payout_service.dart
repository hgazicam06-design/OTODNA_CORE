import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM KAPORA VE TAHSİLAT MOTORU (PayoutService)
/// Araç alım-satım işlemlerinde kaporayı hesaplar, Karargahın mutlak %12 payını keser ve kasaya mühürler.
class PayoutService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 💰 SİBER KAPORA MÜHÜRLEME VE DAĞITIM ─────────────────────────────────
  static Future<Map<String, double>> kaporaMuhurle({
    required String islemId,
    required String saseNo,
    required String saticiId,
    required String aliciId,
    required double aracFiyati,
  }) async {
    try {
      if (aracFiyati <= 0) {
        throw Exception("SİBER İHLAL: Araç fiyatı sıfır veya negatif olamaz!");
      }

      developer.log("SİBER RADAR: ₺$aracFiyati değerindeki araç ($saseNo) için Kapora Protokolü başlatıldı.");

      // 1. Kapora Hesaplamaları (Kuantum Matematiği)
      double toplamKapora = aracFiyati * 0.02; // Sistemin kuralı: %2 Kapora

      // 🚨 KARARGAH KURALI: Toplam kaporanın üzerinden %10 Kâr + %2 Vergi = %12 Kesinti!
      double karargahPayi = toplamKapora * 0.12;
      double saticiPausout = toplamKapora - karargahPayi; // Satıcıya geçecek / İade edilecek tutar

      developer.log("SİBER FİNANS: Toplam Kapora: ₺$toplamKapora | OtoDNA Payı: ₺$karargahPayi | Satıcıya Kalan: ₺$saticiPausout");

      // ⛓️ ATOMİK ZIRH: WriteBatch Başlatıldı (Parayı Havada Bırakma!)
      WriteBatch batch = _db.batch();

      // 2. Kapora Kaydını Kuantum Ağına Kilitle
      DocumentReference kaporaRef = _db.collection('kaporalar').doc(islemId);
      batch.set(kaporaRef, {
        'sase_no': saseNo.toUpperCase(),
        'alici_id': aliciId,
        'satici_id': saticiId,
        'arac_fiyati': aracFiyati,
        'toplam_kapora': toplamKapora,
        'karargah_payi': karargahPayi,
        'satici_payi': saticiPausout,
        'durum': 'GÜVENCEYE ALINDI', // Para Karargah havuzunda
        'islem_tarihi': FieldValue.serverTimestamp(),
      });

      // 3. Kara Kutuya (Sistem Logları) Fişi Kes
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'KAPORA_TAHSİLATI',
        'islem_detayi': 'SİBER FİNANS: $saseNo şaseli araç için ₺$toplamKapora güvence bedeli Kuantum Kasasına alındı.',
        'tarih': FieldValue.serverTimestamp(),
      });

      // Tüm Füzeleri Aynı Anda Ateşle!
      await batch.commit();

      developer.log("SİBER KASA: ✅ Kapora işlemi başarıyla mühürlendi ve Karargahın %12 payı ayrıldı!");

      return {
        'total_deposit': toplamKapora,
        'otodna_fee': karargahPayi,
        'seller_payout': saticiPausout,
      };

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Kapora motoru arızalandı!", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ: UI'a Kırmızı Alarm Fırlat!
      throw Exception("SİBER FİNANS HATASI: Kapora işlemi Karargah kasasına kilitlenemedi. Lütfen bağlantınızı kontrol edin!");
    }
  }
}