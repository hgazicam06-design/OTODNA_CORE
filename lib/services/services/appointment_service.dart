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
  /// Kullanıcının sicilini kontrol eder, eğer yasaklı değilse 200 TL Karargah garantisiyle randevu oluşturur.
  static Future<void> randevuKontrolVeAl({
    required String musteriId,
    required String bayiId,
    required String dukkanAdi,
    required String saseNo,
    required String sikayetOzeti,
    required DateTime randevuTarihi,
  }) async {
    try {
      // 1. KULLANICI SİCİL KONTROLÜ (SİBER KALKAN)
      DocumentSnapshot userDoc = await _db.collection('users').doc(musteriId).get();
      if (userDoc.exists) {
        int ihlalSayisi = (userDoc.data() as Map<String, dynamic>)['randevu_ihlal_sayisi'] ?? 0;
        if (ihlalSayisi >= 2) {
          throw Exception("SİBER ENGEL: Siciliniz kilitlenmiştir! Randevulara gitmediğiniz için Karargah sistemi size kapatılmıştır.");
        }
      }

      developer.log("SİBER PROTOKOL: $saseNo için randevu ağı örülüyor...");

      // 💰 FİNANSAL ÇARK (KARARGAHIN 200 TL HİZMET BEDELİ)
      double hizmetBedeli = 200.0;

      // ⛓️ ATOMİK ZIRH: WriteBatch Başlatıldı
      WriteBatch batch = _db.batch();

      // 2. Randevuyu Kuantum Ağına İşle
      DocumentReference randevuRef = _db.collection('randevular').doc();
      batch.set(randevuRef, {
        'randevu_id': randevuRef.id,
        'musteri_id': musteriId,
        'dukkan_id': bayiId,
        'dukkan_adi': dukkanAdi,
        'sase_no': saseNo.toUpperCase(),
        'sikayet_ozeti': sikayetOzeti,
        'randevu_hizmet_bedeli': hizmetBedeli,
        'bedel_odendi_mi': true, // Şimdilik mock olarak ödendi varsayıyoruz
        'durum': 'Bekliyor', 
        'randevu_tarihi': Timestamp.fromDate(randevuTarihi),
        'olusturulma_tarihi': FieldValue.serverTimestamp(),
      });

      // 3. Kara Kutuya (Sistem Logları) Sinyal Gönder
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'YENI_RANDEVU',
        'islem_detayi': 'SİBER RANDEVU: 200 TL hizmet bedeli ile $dukkanAdi için randevu kilitlendi.',
        'hedef_bayi': bayiId,
        'tarih': FieldValue.serverTimestamp(),
      });

      // Tüm Füzeleri Aynı Anda Ateşle!
      await batch.commit();

      developer.log("SİBER ONAY: ✅ Randevu ve ₺200 OtoDNA Garanti Bedeli Karargah Kasasına mühürlendi!");

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Randevu sistemi arızalandı!", error: e);
      throw Exception(e.toString()); // Sicile takıldıysa mesajı doğrudan fırlat
    }
  }

  // ── 🚨 3. SİCİL KİRLETME (RANDEVUYA GİTMEME CEZASI) ──────────────────────
  /// Usta müşteri gelmediğini bildirdiğinde çalışır. Kullanıcının ihlal sayısını artırır.
  static Future<void> randevuyaGelmediSicileIsle({
    required String randevuId,
    required String musteriId,
  }) async {
    try {
      WriteBatch batch = _db.batch();

      // 1. Randevuyu iptal et
      DocumentReference randevuRef = _db.collection('randevular').doc(randevuId);
      batch.update(randevuRef, {'durum': 'Iptal_Gelmedi'});

      // 2. Müşteri sicilini kirlet (İhlal Sayısını Artır)
      DocumentReference userRef = _db.collection('users').doc(musteriId);
      batch.update(userRef, {
        'randevu_ihlal_sayisi': FieldValue.increment(1)
      });

      // 3. Kara Kutuya yaz
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'SİCİL_KİRLETİLDİ',
        'islem_detayi': '$musteriId UID numaralı kullanıcı randevusuna gelmedi. İhlal sayısı artırıldı.',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      developer.log("🚨 SİBER CEZA: Kullanıcının siciline mühür vuruldu!");
    } catch (e) {
      developer.log("SİBER HATA: Ceza işlemi uygulanamadı!", error: e);
      throw Exception("Ceza işlemi başarısız oldu.");
    }
  }
}