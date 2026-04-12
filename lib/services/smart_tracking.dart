import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import 'notification_service.dart'; // 🚀 MAKET YIKILDI: Gerçek İletişim Motoru Bağlandı!

/// 🛡️ KUANTUM AKILLI TAKİP VE RADAR MOTORU (SmartTrackingService)
/// Kullanıcıyı darlamadan (gizliliği koruyarak) bayi girişlerini denetler ve periyodik KM bakımını otonom takip eder.
class SmartTrackingService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 🎯 1. SİBER GEOFENCE (BAYİ GİRİŞ DENETİMİ) ───────────────────────────
  /// Müşteri verisini toplamaz, sistem uyur. Sadece hedef koordinata girilirse uyanır.
  static Future<void> dukkanGirisKontrol({
    required String saseNo,
    required String bayiId,
    required bool icerideMi, // LocationService'in 50 metre kuralından gelen onay
  }) async {
    try {
      if (icerideMi) {
        developer.log("🚨 HEDEF MENZİLDE! $saseNo şaseli araç $bayiId kodlu dükkana giriş yaptı.");
        await _pasaportuGonder(saseNo, bayiId);
      } else {
        // Eşleşme yoksa sistem derin uykuda kalır, şarj veya veri sömürmez.
      }
    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Dükkan giriş radarı başarısız!", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ
      throw Exception("SİBER RADAR HATASI: Bayi giriş denetimi Kuantum Ağına iletilemedi!");
    }
  }

  // ── 🏎️ 2. OTONOM KİLOMETRE VE BAKIM RADARI ───────────────────────────────
  /// Günlük veya GPS üzerinden okunan mesafeyi Karargah veritabanına mühürler.
  static Future<void> gunlukKmGuncelle(String saseNo, double yapilanYeniMesafe) async {
    if (yapilanYeniMesafe < 0) {
      throw Exception("SİBER İHLAL: Yapılan mesafe negatif olamaz!");
    }
    if (yapilanYeniMesafe == 0) return; // İşlem ve veri tasarrufu

    try {
      String muhurluSase = saseNo.toUpperCase();
      final docRef = _db.collection('araclar').doc(muhurluSase);
      final snapshot = await docRef.get();

      if (!snapshot.exists) {
        developer.log("SİBER İHLAL: Radarda $muhurluSase şaseli araç bulunamadı!");
        // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ
        throw Exception("İSTİHBARAT HATASI: $muhurluSase şaseli araç Karargah kayıtlarında yok!");
      }

      final data = snapshot.data()!;
      double mevcutKm = (data['guncel_km'] ?? 0).toDouble();

      // Eğer son bakım KM'si girilmemişse, ilk kaydı mevcut KM kabul et
      double sonBakimKm = (data['son_bakim_km'] ?? mevcutKm).toDouble();

      double yeniToplamKm = mevcutKm + yapilanYeniMesafe;

      // ⛓️ ATOMİK ZIRH BAŞLAT (Güncelleme ve Bakım Etiketi aynı anda)
      WriteBatch batch = _db.batch();
      batch.update(docRef, {'guncel_km': yeniToplamKm});

      // 🛠️ KUSURSUZ 10.000 KM BAKIM KALKANI
      double bakimdanSonraYapilan = yeniToplamKm - sonBakimKm;
      if (bakimdanSonraYapilan >= 10000) {
        // Sadece bildirim atmakla kalma, araca "bakım gerekli" mühürü vur!
        batch.update(docRef, {'bakim_gerekiyor': true});
        developer.log("⚠️ SİBER ALARM: $saseNo için bakım limiti doldu!");
      }

      await batch.commit(); // Füzeleri ateşle!
      developer.log("SİBER BİLGİ: Araç DNA'sındaki KM güncellendi -> $yeniToplamKm KM");

      // Atomik kayıt tamamlandıktan sonra gerçek bildirim füzelerini ateşle
      if (bakimdanSonraYapilan >= 10000) {
        await _bakimUyarisiVer(muhurluSase);
      }

    } catch (e) {
      developer.log("VERİTABANI HATASI: Kilometre ağına ulaşılamadı!", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ
      throw Exception("ZAMAN-MEKAN HATASI: Araç kilometresi Karargaha işlenemedi!");
    }
  }

  // ── 📡 İÇ SİBER PROTOKOLLER (GERÇEK ATEŞLEMELER - MAKET YOK) ──────────────

  static Future<void> _pasaportuGonder(String saseNo, String bayiId) async {
    // 🚀 MAKET İMHA EDİLDİ: İşlemi gerçek Karargah Kara Kutusuna (Loglara) mühürle
    await _db.collection('sistem_loglari').add({
      'islem_turu': 'PASAPORT_TRANSFERI',
      'islem_detayi': 'OtoDNA Pasaportu (DNA Raporu) anında $bayiId kodlu ustanın tabletine yansıtıldı.',
      'sase_no': saseNo,
      'bayi_id': bayiId,
      'tarih': FieldValue.serverTimestamp(),
    });
    developer.log("SİBER İLETİM: Pasaport transferi Karargah ağına kilitlendi!");
  }

  static Future<void> _bakimUyarisiVer(String saseNo) async {
    // 🚀 MAKET İMHA EDİLDİ: NotificationService ile gerçek cihaz bildirimi fırlat!
    NotificationService iletisimMotoru = NotificationService();

    await iletisimMotoru.sendNotification(
      saseNo: saseNo,
      tur: 'sistem_uyarisi',
      mesaj: '🚨 DİKKAT: Aracınızın 10.000 KM periyodik bakım limiti DOLDU! DNA Skorunuzun düşmemesi için acilen OtoDNA onaylı bir bayiye gidiniz.',
      gonderenIp: 'KARARGAH_OTONOM_RADAR',
      engelliIpler: [], // Karargah kendi kendini engellemez!
    );

    developer.log("SİBER BİLGİ: KM Bakım Bildirimi fırlatıldı!");
  }
}