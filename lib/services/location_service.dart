import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM KONUM VE RADAR MOTORU (LocationService)
/// Araçların bayiye yaklaşmasını izler, 50 metre menziline girdiğinde Siber Çiti (Geofence) tetikler.
class LocationService {
  // Radarı istediğimiz zaman kapatabilmek için hafızaya alıyoruz (Batarya koruması)
  StreamSubscription<Position>? _konumRadari;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
    required String bayiKonumLong,
    required String aracPlaka, // Mühürleme için plaka verisi eklendi
  }) async {
    try {
      // 1. İzinleri Kontrol Et
      bool izinVarMi = await _izinleriDogrula();
      if (!izinVarMi) throw Exception("GPS erişimi sağlanamadı. Konum ayarlarınızı açın.");

      // 2. Hedef Koordinatları Siber Formata Çevir
      double hedefLat = double.parse(bayiKonumLat);
      double hedefLong = double.parse(bayiKonumLong);

      developer.log("SİBER RADAR: $bayiId kodlu bayi için 50 metrelik Kuantum Çiti aktif edildi!");

      // 3. Arka Planda Taramayı Başlat
      _konumRadari = Geolocator.getPositionStream(
          locationSettings: LocationSettings(
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
          _konumDogrula(bayiId, aracPlaka);
        }
      });

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Radar başlatılamadı!", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ: UI tarafına kırmızı alarm fırlatılır.
      throw Exception("RADAR HATASI: GPS bağlantısı kurulamadı. Hedefe kilitlenilemiyor!");
    }
  }

  // ── 🎯 3. HEDEFİ VURMA VE RADARI KAPATMA (MAKET DEĞİL, GERÇEK SİSTEM) ────
  Future<void> _konumDogrula(String bayiId, String aracPlaka) async {
    try {
      developer.log("🚨 HEDEF MENZİLDE! $aracPlaka plakalı araç $bayiId kodlu dükkana giriş yaptı.");

      // 🚀 MAKET YOK: Doğrudan Karargaha (Firebase) aracın giriş yaptığını mühürle
      await _db.collection('sistem_loglari').add({
        'islem_turu': 'RADAR_TESPIT',
        'islem_detayi': 'SİBER ÇİT TETİKLENDİ: $aracPlaka plakalı araç dükkana (Menzil < 50m) giriş yaptı.',
        'bayi_isim': bayiId,
        'tarih': FieldValue.serverTimestamp(),
      });

      developer.log("SİBER BİLGİ: Araç girişi Kuantum Ağına mühürlendi!");
    } catch (e) {
      developer.log("SİBER İHLAL: Radar tespiti ağa yazılamadı!", error: e);
    } finally {
      // GÖREV TAMAMLANDI: Bataryayı sömürmemek için radarı kapat! (Hata olsa bile kapanır)
      izlemeyiDurdur();
    }
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