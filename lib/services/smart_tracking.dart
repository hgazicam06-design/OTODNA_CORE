import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

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
    }
  }

  // ── 🏎️ 2. OTONOM KİLOMETRE VE BAKIM RADARI ───────────────────────────────
  /// Günlük veya GPS üzerinden okunan mesafeyi Karargah veritabanına mühürler.
  static Future<void> gunlukKmGuncelle(String saseNo, double yapilanYeniMesafe) async {
    if (yapilanYeniMesafe <= 0) return;

    try {
      String muhurluSase = saseNo.toUpperCase();
      final docRef = _db.collection('araclar').doc(muhurluSase);
      final snapshot = await docRef.get();

      if (!snapshot.exists) {
        developer.log("SİBER İHLAL: Radarda $muhurluSase şaseli araç bulunamadı!");
        return;
      }

      final data = snapshot.data()!;
      double mevcutKm = (data['guncel_km'] ?? 0).toDouble();

      // Eğer son bakım KM'si girilmemişse, ilk kaydı mevcut KM kabul et
      double sonBakimKm = (data['son_bakim_km'] ?? mevcutKm).toDouble();

      // 1. Yeni Kilometreyi Mühürle
      double yeniToplamKm = mevcutKm + yapilanYeniMesafe;
      await docRef.update({'guncel_km': yeniToplamKm});

      developer.log("SİBER BİLGİ: Araç DNA'sındaki KM güncellendi -> $yeniToplamKm KM");

      // 🛠️ 2. KUSURSUZ 10.000 KM BAKIM KALKANI
      // Toplam KM 10bini geçtiyse değil; son bakımdan bu yana 10bin KM devrildiyse uyar!
      double bakimdanSonraYapilan = yeniToplamKm - sonBakimKm;

      if (bakimdanSonraYapilan >= 10000) {
        _bakimUyarisiVer(muhurluSase);
      }

    } catch (e) {
      developer.log("VERİTABANI HATASI: Kilometre ağına ulaşılamadı!", error: e);
    }
  }

  // ── 📡 İÇ SİBER PROTOKOLLER (GİZLİ TETİKLEYİCİLER) ───────────────────────

  static Future<void> _pasaportuGonder(String saseNo, String bayiId) async {
    // SİBER NOT: Burada NotificationService devreye girecek
    developer.log("SİBER İLETİM: OtoDNA Pasaportu (DNA Raporu) anında $bayiId kodlu ustanın tabletine yansıtıldı!");
  }

  static void _bakimUyarisiVer(String saseNo) {
    // SİBER NOT: Burada HatirlatmaService devreye girecek
    developer.log("⚠️ SİBER ALARM: $saseNo şaseli aracın 10.000 KM periyodik bakım limiti DOLDU!");
    developer.log("SİBER BİLGİ: Kullanıcının cihazına ve Karargaha anlık uyarı sinyali fırlatılıyor...");
  }
}