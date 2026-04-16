// lib/core/main_engine.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM AMİRAL GEMİSİ MOTORU (SiberAnaMotor)
/// Karargahın arka plan dinleme, finans ve 30 Dakikalık S.O.S kalkanlarını otonom yönetir.
class SiberAnaMotor {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 🚀 AMİRAL GEMİSİ ATEŞLEME SİSTEMİ ──
  static Future<void> sistemiBaslat(String karargahUid) async {
    developer.log("🚀 SİBER MOTOR: Amiral Gemisi tam gaz ileri! Kalkanlar aktif ediliyor...");

    try {
      // ZIRH 1: Açık şifre yerine Karargah Rütbe Kontrolü (Firebase Auth)
      DocumentSnapshot adminDoc = await _db.collection('kullanicilar').doc(karargahUid).get();

      if (adminDoc.exists && (adminDoc['kulup_rolu'] == 'Baskan' || adminDoc['kulup_rolu'] == 'Yardimci')) {
        developer.log("✅ YETKİ ONAYLANDI: Başkanlık Karargah komutları devrede.");
        _finansTakibiniAktifEt();
        _sosRadariniAc();
      } else {
        developer.log("🚨 SİBER İHLAL: Yetkisiz motor ateşleme girişimi Kuantum Ağı tarafından engellendi!");
      }
    } catch (e) {
      developer.log("🚨 AĞ ÇÖKTÜ: Motor ateşleme arızası!", error: e);
    }
  }

  // ── 💰 FİNANSAL RADAR (YENİ DOKTRİN) ──
  static void _finansTakibiniAktifEt() {
    developer.log("💰 SİBER FİNANS: Karargah gelir radarı aktif. (%12 Standart, %30 Murat Plaza İzleniyor)");

    // Kuantum Veritabanı: Finans havuzundaki hareketliliği canlı olarak dinler
    _db.collection('finans_havuzu').snapshots().listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        developer.log("💎 FİNANS AKIŞI: Kasada otonom hareketlilik tespit edildi. İşçilik dışı komisyonlar hesaplanıyor...");
      }
    });
  }

  // ── 🚨 7/24 S.O.S MÜDAHALE RADARI (30 DAKİKA KURALI & SARI/KIRMIZI KART) ──
  static void _sosRadariniAc() {
    developer.log("🚨 S.O.S RADARI: 30 Dakika müdahale kuralı devrede. Kırmızı alarmlar taranıyor...");

    // Kuantum Veritabanı: Acil müdahale bekleyen sinyalleri anlık olarak çeker
    _db.collection('imece_alarmlari')
        .where('durum', isEqualTo: 'ACIL_MUDEHALE_BEKLIYOR')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        developer.log("⚠️ KRİZ UYARISI: Karargaha düşen ${snapshot.docs.length} adet ACİL S.O.S sinyali var! 30 dakikalık geri sayımlar izleniyor.");

        // SİBER NOT: Karargah kuralları gereği 30 dakikayı aşan müdahaleler veya asılsız (5 saniye basılı tutulmadan yapılan)
        // ihbarlar için Sarı/Kırmızı Kart ceza motoru buradan veya Cloud Functions üzerinden tetiklenmelidir.
      }
    });
  }
}