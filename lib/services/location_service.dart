import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM KONUM VE RADAR MOTORU (LocationService)
/// Araçların bayiye yaklaşmasını izler, 50 metre menziline girdiğinde Siber Çiti (Geofence) tetikler.
class LocationService {
  // Radarı istediğimiz zaman kapatabilmek için hafızaya alıyoruz (Batarya koruması)
  StreamSubscription<Position>? _konumRadari;

  // ── 🔐 1. GPS İZİN VE GÜVENLİK PROTOKOLÜ ──────────────────────────────────
  Future<bool> _izinleriDogrula() async {
    bool servisAcik = await Geolocator.isLocationServiceEnabled();
    if (!servisAcik) {
      developer.log("SİBER İHLAL: Cihazın GPS modülü kapalı!");
      return false;
    }

    LocationPermission izin = await Geolocator.checkPermission();
    if (izin == LocationPermission.denied) {
      izin = await Geolocator.requestPermission();
      if (izin == LocationPermission.denied) {
        developer.log("SİBER İHLAL: Konum izni reddedildi!");
        return false;
      }
    }

    if (izin == LocationPermission.deniedForever) {
      developer.log("SİBER İHLAL: Konum izni kalıcı olarak engellenmiş!");
      return false;
    }

    return true; // Tüm zırhlar aşıldı, GPS aktif!
  }

  // ── 📡 2. KESİNTİSİZ ARAÇ İZLEME RADARI ───────────────────────────────────
  Future<void> izlemeyiBaslat({
    required String bayiId,
    required String bayiKonumLat,
    required String bayiKonumLong
  }) async {
    try {
      // 1. İzinleri Kontrol Et
      bool izinVarMi = await _izinleriDogrula();
      if (!izinVarMi) throw Exception("GPS erişimi sağlanamadı.");

      // 2. Hedef Koordinatları Siber Formata Çevir
      double hedefLat = double.parse(bayiKonumLat);
      double hedefLong = double.parse(bayiKonumLong);

      developer.log("SİBER RADAR: $bayiId kodlu bayi için 50 metrelik Kuantum Çiti aktif edildi!");

      // 3. Arka Planda Taramayı Başlat
      _konumRadari = Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10, // Sadece araç 10 metre hareket ettiğinde tetiklen (Batarya tasarrufu)
          )
      ).listen((Position position) {

        // Araç ile bayi arasındaki mesafeyi ölç (Metre cinsinden)
        double mesafe = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            hedefLat,
            hedefLong
        );

        developer.log("RADAR SİNYALİ: Hedefe kalan mesafe -> ${mesafe.toStringAsFixed(1)} metre");

        // 4. Araç 50 metre menzile (Dükkana) girdiyse vur!
        if (mesafe < 50) {
          _konumDogrula(bayiId);
        }
      });

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Radar başlatılamadı!", error: e);
    }
  }

  // ── 🎯 3. HEDEFİ VURMA VE RADARI KAPATMA ──────────────────────────────────
  void _konumDogrula(String bayiId) {
    developer.log("🚨 HEDEF MENZİLDE! Araç $bayiId kodlu dükkana giriş yaptı.");

    // İleride buraya eklenecek Karargah API Komutları:
    // ApiService.sendArrivalStatus(bayiId, "Araç dükkana giriş yaptı!");
    // LocalNotification.show("Hoş geldiniz! OtoDNA Pasaportunuz ustaya iletildi.");

    // GÖREV TAMAMLANDI: Bataryayı sömürmemek için radarı kapat!
    izlemeyiDurdur();
  }

  // ── 🛑 4. SİBER FREN (RADAR İPTALİ) ───────────────────────────────────────
  void izlemeyiDurdur() {
    if (_konumRadari != null) {
      _konumRadari!.cancel();
      _konumRadari = null;
      developer.log("SİBER BİLGİ: GPS Radarı başarıyla kapatıldı. Batarya güvende.");
    }
  }
}