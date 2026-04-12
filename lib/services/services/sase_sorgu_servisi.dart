import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM ŞASE SORGULAMA VE DNA MOTORU (SaseSorguServisi)
/// Araçların 17 haneli DNA'sını (Şase) Karargahta tarar. Yoksa yeni bir dijital pasaport (DNA) mühürler.
class SaseSorguServisi {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 🔍 SİBER DNA TARAMASI VE PASAPORT OLUŞTURMA (MAKET YIKILDI) ────────
  static Future<Map<String, dynamic>> saseIleSorgula(String saseNo, String bayiId) async {
    try {
      String muhurluSase = saseNo.trim().toUpperCase();

      // 🛡️ SİBER KALKAN: 17 Haneli DNA Standardı Zırhı!
      if (muhurluSase.isEmpty || muhurluSase.length != 17) {
        throw Exception("SİBER İHLAL: Şase numarası (DNA) tam 17 haneli Karargah standardında olmalıdır!");
      }

      developer.log("SİBER RADAR: 🔍 $muhurluSase numaralı şase OtoDNA Kuantum Ağı'nda taranıyor...");

      // 1. Karargah Veritabanından Araç Geçmişini (DNA) Çek
      DocumentSnapshot doc = await _db.collection('araclar').doc(muhurluSase).get();

      if (doc.exists) {
        developer.log("SİBER ONAY: ✅ Araç bulundu! Dijital mühürler, videolar ve Karargah raporları hazır.");
        return doc.data() as Map<String, dynamic>;
      } else {
        developer.log("SİBER BİLGİ: ℹ️ Bu araç ilk kez OtoDNA ile tanışıyor. Otonom Pasaport oluşturuluyor...");

        // Araç yoksa maket değil, GERÇEK kayıt oluştur!
        await _yeniKayitAc(muhurluSase, bayiId);

        return {
          'sase_no': muhurluSase,
          'dna_skoru': 100.0, // Karargahın fabrikasyon tam skoru
          'durum': 'YENI_KAYIT',
          'mesaj': 'Yeni Siber Pasaport Oluşturuldu.'
        };
      }
    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Şase sorgulama motoru arızalandı!", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ: UI'a Kırmızı Alarm Fırlat!
      throw Exception("İSTİHBARAT HATASI: Şase sorgulama başarısız oldu. Lütfen Kuantum Ağınızı kontrol edin!");
    }
  }

  // ── 🧬 SİBER PASAPORT OLUŞTURMA (YENİ ARAÇ MÜHRÜ) ───────────────────────
  static Future<void> _yeniKayitAc(String muhurluSase, String bayiId) async {
    try {
      // ⛓️ ATOMİK ZIRH: WriteBatch Başlatıldı (Kayıt Dışılık Engellendi!)
      WriteBatch batch = _db.batch();

      // 1. Yeni Dijital Pasaportu Oluştur
      DocumentReference aracRef = _db.collection('araclar').doc(muhurluSase);
      batch.set(aracRef, {
        'sase_no': muhurluSase,
        'ilk_kayit_bayi': bayiId, // Hangi bayi Karargaha soktu? (İz Sürümü)
        'kayit_tarihi': FieldValue.serverTimestamp(),
        'dna_skoru': 100.0, // Temiz bir sayfa
        'trafik_riski': false,
        'otodna_onayi': false, // Usta işlem yapana kadar mühür vurulmaz!
        'durum': 'AKTİF',
      });

      // 2. Kara Kutuya (Sistem Logları) Yeni Kaydı Mühürle
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'YENI_ARAC_KAYDI',
        'islem_detayi': 'SİBER BİLGİ: $muhurluSase şaseli araç OtoDNA Kuantum Ağına ilk kez $bayiId yetkilisi tarafından kaydedildi.',
        'tarih': FieldValue.serverTimestamp(),
      });

      // Füzeleri Ateşle!
      await batch.commit();

      developer.log("SİBER MÜHÜR: ✅ Araç Kuantum Ağına kilitlendi ve dijital pasaportu oluşturuldu!");
    } catch (e) {
      developer.log("VERİTABANI HATASI: Yeni araç kaydı oluşturulamadı!", error: e);
      throw Exception("KARARGAH HATASI: Yeni araç pasaportu mühürlenemedi! Ağ bağlantısını kontrol edin.");
    }
  }
}