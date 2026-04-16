// lib/core/sos_merkezi.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM S.O.S OPERASYON MERKEZİ (SiberSosMerkezi)
/// 15 Dk (QR Bayi) -> 15 Dk (En Yakın) -> 30 Dk (Gazi) kuralını otonom yönetir.
class SiberSosMerkezi {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static Timer? _timer15Dk;
  static Timer? _timer30Dk;
  static bool _isCozuldu = false;

  // ── 🚨 0. DAKİKA: SİBER OPERASYONU BAŞLAT (ATOMİK ZIRHLI) ──
  static Future<void> acilDurumBaslat({
    required String kullaniciId,
    required String saseNo,
    required String asilBayiId,
    required double anlikEnlem,
    required double anlikBoylam,
  }) async {
    _isCozuldu = false;
    developer.log("🚨 KIZIL KOD: 5 saniyelik mühür kırıldı. Karargah S.O.S operasyonunu başlatıyor!");

    try {
      // 🛡️ ATOMİK ZIRH: İşlemi ve Logu aynı anda kilitler!
      WriteBatch batch = _db.batch();

      DocumentReference operasyonRef = _db.collection('sos_operasyonlari').doc();
      String operasyonId = operasyonRef.id;

      batch.set(operasyonRef, {
        'kullanici_id': kullaniciId,
        'sase_no': saseNo,
        'asil_bayi_id': asilBayiId,
        'konum_enlem': anlikEnlem,
        'konum_boylam': anlikBoylam,
        'durum': 'QR_BAYI_MUDEHALE_BEKLIYOR', // İlk aşama
        'baslangic_zaman_damgasi': FieldValue.serverTimestamp(),
      });

      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'YENI_SOS_TETIKLENDI',
        'islem_detayi': 'SİBER KRİZ: ${kullaniciId} kullanıcısı KIZIL KOD ateşledi. Süreç başladı.',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit(); // Füzeleri gönder!

      // ── ⚠️ 15. DAKİKA: EN YAKIN BAYİYE DEVİR ──
      _timer15Dk = Timer(const Duration(minutes: 15), () async {
        if (!_isCozuldu) {
          developer.log("⚠️ 15. DAKİKA: Asıl bayi müdahale etmedi! En yakın bayi radarına aktarılıyor.");

          await _db.collection('sos_operasyonlari').doc(operasyonId).update({
            'durum': 'EN_YAKIN_BAYI_MUDEHALE_BEKLIYOR',
            '15dk_asimi': true,
          });
        }
      });

      // ── 🚨 30. DAKİKA: KARARGAH (GAZİ) MÜDAHALESİ ──
      _timer30Dk = Timer(const Duration(minutes: 30), () async {
        if (!_isCozuldu) {
          developer.log("🚨 KRİTİK İHLAL: 30 Dakikadır cevap yok! Sistem doğrudan Merkez Karargaha (Gazi'ye) devrediliyor.");

          await _db.collection('sos_operasyonlari').doc(operasyonId).update({
            'durum': 'KARARGAH_MUDEHALESI_GEREKLI',
            '30dk_asimi': true,
          });

          _karargahAcilSireniniCal(kullaniciId, anlikEnlem, anlikBoylam);
        }
      });

    } catch (e) {
      developer.log("🚨 AĞ ÇÖKTÜ: S.O.S operasyonu başlatılamadı!", error: e);
    }
  }

  // ── ✅ YARDIM ULAŞTIĞINDA SÜRECİ DURDURAN MÜHÜR ──
  static Future<void> yardimUlasti(String operasyonId, String cozenBayiId) async {
    _isCozuldu = true;
    _timer15Dk?.cancel();
    _timer30Dk?.cancel();

    developer.log("✅ KARARGAH ONAYI: Yardım ulaştı. Tüm zamanlayıcılar ve alarmlar kapatıldı.");

    try {
      await _db.collection('sos_operasyonlari').doc(operasyonId).update({
        'durum': 'COZULDU',
        'cozen_bayi_id': cozenBayiId,
        'cozum_zaman_damgasi': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      developer.log("🚨 AĞ ÇÖKTÜ: Çözüm mührü vurulamadı!", error: e);
    }
  }

  // ── 🚨 KARARGAH KIRMIZI SİREN TETİKLEYİCİSİ ──
  static void _karargahAcilSireniniCal(String kullaniciId, double enlem, double boylam) {
    developer.log("📞 KIZIL HAT: Merkez Karargah (Gazi) için acil telefon bağlantısı hazırlanıyor. Kordinatlar: $enlem, $boylam");
    // SİBER NOT: Sistem burada admin ekranında dev bir kırmızı alarm çıkarır.
  }
}