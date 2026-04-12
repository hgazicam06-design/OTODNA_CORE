import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM FİNANS VE TAHSİLAT MOTORU (PaymentService)
/// %12 (10+2) Karargah kuralını uygular ve ödemeleri atomik olarak kasaya kilitler.
class PaymentService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 💎 SİBER FİNANS KURALI (MUTLAK PAY) ─────────────────────────────────
  // Senin payın %10, Vergi %2 -> Toplam kesinti %12 (İMTİYAZ YOK!)
  static const double partnerSharePercent = 0.10;
  static const double taxPercent = 0.02;
  static const double totalCommission = partnerSharePercent + taxPercent;

  // ── 💰 1. SİBER ÖDEME DAĞILIMI VE KASAYA MÜHÜRLEME ──────────────────────
  static Future<Map<String, double>> odemeyiMuhurle({
    required String islemId,
    required String bayiId,
    required double toplamTutar,
  }) async {
    try {
      if (toplamTutar <= 0) {
        throw Exception("SİBER İHLAL: Tahsil edilecek tutar 0 veya negatif olamaz!");
      }

      developer.log("SİBER FİNANS: ₺$toplamTutar için Karargah tahsilat çarkı dönüyor...");

      // Kuantum Hesaplamaları
      double totalDeduction = toplamTutar * totalCommission;
      double partnerProfit = toplamTutar * partnerSharePercent;
      double taxAmount = toplamTutar * taxPercent;
      double vendorAmount = toplamTutar - totalDeduction;

      // ⛓️ ATOMİK ZIRH: WriteBatch Başlatıldı (Parayı Havada Bırakma, Kasaya Kilitle!)
      WriteBatch batch = _db.batch();

      // 1. İşlem Kaydına Finansal Dağılımı Mühürle
      DocumentReference islemRef = _db.collection('islemler').doc(islemId);
      batch.update(islemRef, {
        'finans_dagilimi': {
          'toplam_tutar': toplamTutar,
          'bayi_net': vendorAmount,
          'karargah_kar': partnerProfit,
          'vergi': taxAmount,
        },
        'finans_durumu': 'TAHSİL EDİLDİ',
        'finans_guncelleme_tarihi': FieldValue.serverTimestamp(),
      });

      // 2. Karargah Ana Kasasına (Loglara) Fişi Kes
      DocumentReference kasaRef = _db.collection('karargah_kasasi').doc();
      batch.set(kasaRef, {
        'islem_id': islemId,
        'bayi_id': bayiId,
        'islem_turu': 'HİZMET_TAHSİLATI',
        'brut_tutar': toplamTutar,
        'net_kar': partnerProfit,
        'vergi': taxAmount,
        'tarih': FieldValue.serverTimestamp(),
      });

      // Füzeleri Ateşle!
      await batch.commit();

      developer.log("SİBER KASA: ✅ Tahsilat mühürlendi! Karargah Payı: ₺$partnerProfit, Vergi: ₺$taxAmount");

      return {
        'vendor_amount': vendorAmount,
        'partner_profit': partnerProfit,
        'tax_amount': taxAmount,
      };

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Finans motoru arızalandı!", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ: UI'a Kırmızı Alarm Fırlat!
      throw Exception("SİBER FİNANS HATASI: Ödeme işlemi Karargah kasasına işlenemedi. Lütfen ağı kontrol edin!");
    }
  }

  // ── 💳 2. DİNAMİK RANDEVU BEDELİ (MAKET YIKILDI) ────────────────────────
  static Future<double> randevuBedeliSorgula() async {
    try {
      developer.log("SİBER FİNANS: Randevu hizmet bedeli Kuantum Ağından çekiliyor...");

      // 🚀 MAKET İMHA EDİLDİ: Sabit 50 TL yerine Karargah merkezinden canlı çekilir.
      DocumentSnapshot ayarDoc = await _db.collection('sistem_ayarlari').doc('finans').get();

      // Eğer Kuantum Ağında veri henüz yoksa (Siber Çöküş Kalkanı) Taktiksel 50 TL döner
      double hizmetBedeli = 50.0;

      if (ayarDoc.exists && ayarDoc.data() != null) {
        hizmetBedeli = (ayarDoc.data() as Map<String, dynamic>)['randevu_sabit_bedeli']?.toDouble() ?? 50.0;
      }

      developer.log("SİBER KASA: Güncel randevu hizmet bedeli ₺$hizmetBedeli olarak okundu.");
      return hizmetBedeli;

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Finans ayarları çekilemedi!", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ
      throw Exception("SİBER FİNANS HATASI: Randevu bedeli sorgulanamadı. Kuantum ağınızı kontrol edin!");
    }
  }
}