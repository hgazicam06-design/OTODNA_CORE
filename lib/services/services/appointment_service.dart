import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM RANDEVU VE OPERASYON MERKEZİ (AppointmentService)
/// Randevuları Kuantum Ağında mühürler, Karargah payını (%12) otonom hesaplar ve Merkez Havuzunu canlı izler.
class AppointmentService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 📡 1. CANLI RANDEVU RADARI (MAKET YIKILDI!) ──────────────────────────
  /// Ankara Merkez Havuzunu sahte listelerle değil, doğrudan canlı Kuantum akışıyla besler.
  static Stream<QuerySnapshot> get randevuHavuzuStream {
    developer.log("SİBER RADAR: Ankara Merkez Randevu Havuzu canlı izlemeye alındı.");
    return _db.collection('randevular')
        .orderBy('olusturulma_tarihi', descending: true)
        .snapshots();
  }

  // ── 🎯 2. SİBER RANDEVU MÜHÜRLEME VE FİNANS MOTORU ──────────────────────
  static Future<void> randevuAl({
    required String musteriId,
    required String bayiId,
    required String saseNo,
    required String il,
    required double kapora,
    required DateTime randevuTarihi,
  }) async {
    try {
      if (kapora <= 0) {
        throw Exception("SİBER İHLAL: Kapora tutarı sıfır veya negatif olamaz!");
      }

      developer.log("SİBER PROTOKOL: $il bölgesinde yeni bir randevu ağı örülüyor...");

      // 💰 FİNANSAL ÇARK (KARARGAHIN MUTLAK %12 PAYI)
      double karargahPayi = kapora * 0.12;

      // ⛓️ ATOMİK ZIRH: WriteBatch Başlatıldı
      WriteBatch batch = _db.batch();

      // 1. Randevuyu Kuantum Ağına İşle
      DocumentReference randevuRef = _db.collection('randevular').doc();
      batch.set(randevuRef, {
        'randevu_id': randevuRef.id,
        'musteri_id': musteriId,
        'bayi_id': bayiId,
        'sase_no': saseNo.toUpperCase(),
        'il': il,
        'kapora_tutari': kapora,
        'karargah_payi': karargahPayi,
        'durum': 'Bekliyor', // Otonom durum
        'randevu_tarihi': Timestamp.fromDate(randevuTarihi),
        'olusturulma_tarihi': FieldValue.serverTimestamp(),
      });

      // 2. Kara Kutuya (Sistem Logları) Sinyal Gönder
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'YENI_RANDEVU',
        'islem_detayi': 'SİBER RANDEVU: $il bölgesinde ₺$kapora kaporalı randevu kilitlendi. Karargah Payı: ₺$karargahPayi',
        'hedef_bayi': bayiId,
        'tarih': FieldValue.serverTimestamp(),
      });

      // Tüm Füzeleri Aynı Anda Ateşle!
      await batch.commit();

      developer.log("SİBER ONAY: ✅ Randevu ve ₺$karargahPayi OtoDNA Payı Karargah Kasasına mühürlendi!");

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Randevu sistemi arızalandı!", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ: Sisteme yalan söyleme, UI'a Kırmızı Alarm fırlat!
      throw Exception("SİBER RANDEVU HATASI: İşlem Kuantum Ağına kilitlenemedi. Lütfen bağlantınızı kontrol edin!");
    }
  }
}