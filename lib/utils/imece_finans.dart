// lib/utils/imece_finans.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM İMECE VE MAHSUPLAŞMA MOTORU (SiberImeceFinansMotoru)
/// Hatalı bayiyi borçlandırıp, sorunu çözen bayiye anında ödeme çıkaran ACID Transaction zırhlı havuz sistemi.
class SiberImeceFinansMotoru {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── ⚖️ MAHSUPLAŞMA ALGORİTMASI (ACID PROTOKOLÜ) ──
  // Bu işlem tek bir atomik blokta çalışır. İnternet koparsa tüm işlem iptal olur, Karargahın parası kaybolmaz.
  static Future<void> mahsuplasmaIsle({
    required String hataliBayiId,
    required String cozenBayiId,
    required double tutar,
    required String islemRaporId,
  }) async {
    developer.log("🚀 SİBER İMECE: $hataliBayiId kodlu bayinin hatası, $cozenBayiId tarafından çözüldü. Mahsuplaşma başlıyor...");

    try {
      // 🛡️ SİBER ZIRH: Eğer 2 işlem aynı anda gelirse ACID protokolü veriyi kilitler, çakışmayı (Race Condition) önler!
      await _db.runTransaction((transaction) async {
        // 1. İlgili Veritabanı Koordinatları
        DocumentReference hataliBayiRef = _db.collection('finans_havuzu').doc(hataliBayiId);
        DocumentReference cozenBayiRef = _db.collection('finans_havuzu').doc(cozenBayiId);
        DocumentReference imeceHavuzRef = _db.collection('merkez_kasa').doc('IMECE_HAVUZU');
        DocumentReference logRef = _db.collection('imece_loglari').doc();

        // 2. OTONOM FİNANSAL AKTARIMLAR (FieldValue.increment ile sıfır veri kaybı)

        // A) Çözen bayiye parasını Karargah (İmece Havuzu) anında aktarır
        transaction.set(cozenBayiRef, {
          'bekleyen_hakedis': FieldValue.increment(tutar),
          'son_islem_tarihi': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // B) Hatalı bayiyi borçlandırırız (Bir sonraki hakedişten kesilecek)
        transaction.set(hataliBayiRef, {
          'imece_borcu': FieldValue.increment(tutar),
          'son_islem_tarihi': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // C) Merkez İmece Havuzundan para çıkışı
        transaction.set(imeceHavuzRef, {
          'aktif_bakiye': FieldValue.increment(-tutar),
          'son_islem_tarihi': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // D) Operasyonu Karargah Loglarına Mühürle (Siber Fiş)
        transaction.set(logRef, {
          'hatali_bayi': hataliBayiId,
          'cozen_bayi': cozenBayiId,
          'tutar': tutar,
          'rapor_id': islemRaporId,
          'zaman_damgasi': FieldValue.serverTimestamp(),
          'durum': 'MAHSUPLASMA_TAMAMLANDI'
        });
      });

      developer.log("✅ İMECE ONAYI: ₺$tutar tutarındaki mahsuplaşma Karargah veritabanına ACID (kırılmaz) protokolüyle işlendi.");

    } catch (e) {
      developer.log("🚨 AĞ ÇÖKTÜ: İmece mahsuplaşma işlemi güvenlik amacıyla iptal edildi (Rollback)!", error: e);
      throw Exception("Kuantum İmece işlemi başarısız: $e");
    }
  }
}