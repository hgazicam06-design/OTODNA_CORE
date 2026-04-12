import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM S.O.S MOTORU
/// OtoDNA Acil Durum, 30 Dakika Karargah Müdahalesi ve Asılsız İhbar Ceza Protokolleri
class EmergencyProtocolService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 🚨 1. ANA S.O.S TETİKLEYİCİ PROTOKOL ──────────────────────────────────
  Future<void> triggerEmergencySOS({
    required String userId,
    required String vehicleId,
    required String originalDealerId, // QR'ı veren asıl mühürlü bayi
    required double latitude,
    required double longitude,
  }) async {
    try {
      developer.log("SİBER BİLGİ: S.O.S Sinyali ateşlendi! Hedef Koordinatlar: [$latitude, $longitude]");

      // ⛓️ SİBER ZIRH: Atomik WriteBatch Başlatıldı
      WriteBatch batch = _db.batch();

      // 1. Acil durum raporunu Karargah veritabanına mühürle
      DocumentReference sosRef = _db.collection('emergencies').doc();
      batch.set(sosRef, {
        'userId': userId,
        'vehicleId': vehicleId,
        'location': GeoPoint(latitude, longitude),
        'status': 'BEKLIYOR', // Siber Karargah Dili (Eski: PENDING)
        'timestamp': FieldValue.serverTimestamp(),
        'assignedDealer': originalDealerId, // İlk hedef QR'ı veren bayi
        'falseAlarm': false,
      });

      // 2. Admin Kara Kutusuna (Sistem Logları) anında kayıt düş
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'KIRMIZI_ALARM_SOS',
        'islem_detayi': 'SİBER ALARM: $userId numaralı kullanıcı S.O.S fırlattı!',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit(); // Füzeleri ateşle!

      // 3. Admin ve İlgili Bayi ekranlarına kırmızı alarm sinyali fırlat
      await _dispatchNotifications(sosRef.id, originalDealerId);

      // 4. 30 Dakikalık Karargah Müdahale Sayacını Başlat
      _startAdminEscalationTimer(sosRef.id, userId);

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: S.O.S Sinyali iletilemedi!", error: e);
      throw Exception("SİBER HATA: Acil durum sinyali gönderilemedi.");
    }
  }

  // ── 📡 2. SİBER BİLDİRİM DAĞITICI ─────────────────────────────────────────
  Future<void> _dispatchNotifications(String sosId, String targetDealerId) async {
    // TODO: Firebase Cloud Messaging (FCM) entegrasyonu buraya gelecek.
    developer.log('SİBER ALARM: Bayi ($targetDealerId) ve Ankara Merkez ekranlarına KIRMIZI SİNYAL fırlatıldı. S.O.S ID: $sosId');
  }

  // ── ⏱️ 3. 30 DAKİKA KONTROLÜ VE KARARGAH (ADMİN) MÜDAHALESİ ───────────────
  void _startAdminEscalationTimer(String sosId, String userId) {
    // SİBER NOT: Gerçek ve devasa bir ekosistemde bu işlem Firebase Cloud Functions (Sunucu) ile yapılmalıdır.
    // MVP aşaması için istemci (client) tarafında 30 dakikalık Kuantum Sayacı başlatılıyor.
    Timer(const Duration(minutes: 30), () async {
      try {
        final docSnapshot = await _db.collection('emergencies').doc(sosId).get();

        if (docSnapshot.exists) {
          final data = docSnapshot.data()!;
          // Eğer 30 dakika geçtiği halde bayi müdahale etmediyse...
          if (data['status'] == 'BEKLIYOR') {
            developer.log('KRİTİK İHLAL: 30 dakika doldu! Bayi teması yok. Karargah (Admin) doğrudan müdahale protokolüne geçiyor!');

            await _db.collection('emergencies').doc(sosId).update({
              'escalatedToAdmin': true,
              'status': 'KARARGAH_MUDAHALESI', // Eski: ADMIN_INTERVENTION
            });
          }
        }
      } catch (e) {
        developer.log("SİSTEMSEL ANOMALİ: 30 dakikalık zaman aşımı kontrolü başarısız oldu!", error: e);
      }
    });
  }

  // ── ⚖️ 4. ASILSIZ İHBAR VE SARI LİSTE CEZA SİSTEMİ (TRANSACTION ZIRHI) ───
  Future<void> markAsFalseAlarm(String sosId, String userId) async {
    try {
      // ⛓️ SİBER ZIRH: Transaction (Canlı Kalkan) Protokolü
      // İşlem yarıda kesilirse (Örn: İnternet kopması) hiçbir veriyi kaydetmez, sistemi korur.
      await _db.runTransaction((transaction) async {
        DocumentReference userRef = _db.collection('kullanicilar').doc(userId);
        DocumentReference sosRef = _db.collection('emergencies').doc(sosId);

        // 1. Kullanıcının mevcut sicilini Kuantum hızında oku
        DocumentSnapshot userDoc = await transaction.get(userRef);
        int falseAlarmCount = (userDoc.data() as Map<String, dynamic>?)?['falseAlarmCount'] ?? 0;

        // Cezasini arttir
        falseAlarmCount += 1;

        // 2. Acil Durum kaydını Asılsız olarak işaretle
        transaction.update(sosRef, {
          'status': 'ASILSIZ_IHBAR',
          'falseAlarm': true,
        });

        // 3. Kullanıcının siciline göre cezasını kes
        if (falseAlarmCount == 1) {
          // İLK İHLAL: Üyelik sarıya döner, uyarı sinyali
          transaction.update(userRef, {
            'falseAlarmCount': falseAlarmCount,
            'membershipStatus': 'SARI_UYARI',
          });
          developer.log('SİBER CEZA: Asılsız ihbar tespit edildi! Kullanıcı SARI LİSTEYE alındı.');
        } else if (falseAlarmCount >= 2) {
          // İKİNCİ İHLAL: SOS özelliği kalıcı olarak mühürlenir (kapatılır)
          transaction.update(userRef, {
            'falseAlarmCount': falseAlarmCount,
            'sosFeatureEnabled': false,
            'membershipStatus': 'MEN_EDILDI',
          });
          developer.log('SİBER MEN: 2. Asılsız ihbar! Kullanıcının S.O.S özelliği kalıcı olarak DEVRE DIŞI bırakıldı.');
        }

        // 4. Kara Kutuya ceza logunu mühürle
        DocumentReference logRef = _db.collection('sistem_loglari').doc();
        transaction.set(logRef, {
          'islem_turu': 'SİBER_CEZA',
          'islem_detayi': 'Kullanıcıya asılsız ihbar cezası kesildi. İhlal Sayısı: $falseAlarmCount',
          'tarih': FieldValue.serverTimestamp(),
        });
      });

    } catch (e) {
      developer.log("VERİTABANI HATASI: Asılsız ihbar cezası uygulanamadı!", error: e);
      // Ekranda sonsuz yüklemeyi durdurmak için Kırmızı Alarm fırlatıyoruz!
      throw Exception("SİBER HATA: Ceza protokolü Kuantum Ağına işlenemedi.");
    }
  }
}