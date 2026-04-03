import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM İLETİŞİM VE BİLDİRİM MOTORU (NotificationService)
/// Araçlara QR okutulduğunda fırlatılan S.O.S ve uyarı sinyallerini Karargah standartlarıyla yönetir.
class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // ── 📡 1. İLETİŞİM MODÜLÜNÜ ATEŞLEME ──────────────────────────────────────
  Future<void> initialize() async {
    try {
      await _fcm.requestPermission(alert: true, badge: true, sound: true);
      developer.log("SİBER BİLGİ: Kuantum İletişim Modülü (FCM) izni başarıyla alındı.");
    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: İletişim izni alınamadı!", error: e);
    }
  }

  // Cihazın hedef kimliğini (Token) alır
  Future<String?> getToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      developer.log("İLETİŞİM HATASI: Cihaz mühürü (Token) okunamadı!", error: e);
      return null;
    }
  }

  // ── 🚀 2. SİNYAL FIRLATMA VE SPAM KALKANI ──────────────────────────────────
  Future<Map<String, dynamic>> sendNotification({
    required String saseNo,
    required String tur,
    required String mesaj,
    required String gonderenIp,
    required List<String> engelliIpler,
    required String fcmToken,
  }) async {
    try {
      // 🛡️ SİBER GÜVENLİK: IP Kara Liste (Spam/Taciz) Kontrolü
      if (engelliIpler.contains(gonderenIp)) {
        developer.log("SİBER ENGEL: $gonderenIp numaralı IP Kara Listede! Sinyal reddedildi.");
        return {'success': false, 'reason': 'blocked'};
      }

      String mühürlüSase = saseNo.toUpperCase();

    final ref = await _db
        .collection('araclar') // İngilizce 'vehicles' yerine Karargah dili!
        .doc(mühürlüSase)
        .collection('bildirimler')
        .add({
    'tur': tur,
    'mesaj': mesaj,
    'gonderenIp': gonderenIp,
    'tarih': FieldValue.serverTimestamp(),
    'okundu': false,
    'durum': 'gonderildi',
    'cevap': '',
    });

    developer.log("SİBER SİNYAL: $mühürlüSase şaseli araca '$tur' kodlu bildirim fırlatıldı.");
    return {'success': true, 'bildirimId': ref.id};

    } catch (e) {
    developer.log("SİNYAL KOPTU: Bildirim veritabanına mühürlenemedi!", error: e);
    return {'success': false, 'reason': 'error'};
    }
  }

  // ── 📡 3. CANLI SİNYAL RADARI (STREAM) ─────────────────────────────────────
  Stream<DocumentSnapshot<Map<String, dynamic>>> bildirimStream(String saseNo, String bildirimId) {
    return _db
        .collection('araclar')
        .doc(saseNo.toUpperCase())
        .collection('bildirimler')
        .doc(bildirimId)
        .snapshots();
  }

  // ── 📝 4. SİNYAL DURUM VE CEVAP MÜHÜRLEME ──────────────────────────────────
  Future<void> updateDurum(String saseNo, String bildirimId, String durum) async {
    try {
      final updates = <String, dynamic>{'durum': durum};
      if (durum == 'okundu') updates['okundu'] = true;

      await _db
          .collection('araclar')
          .doc(saseNo.toUpperCase())
          .collection('bildirimler')
          .doc(bildirimId)
          .update(updates);

      developer.log("SİBER BİLGİ: Sinyal durumu '$durum' olarak Karargaha işlendi.");
    } catch (e) {
      developer.log("AĞ HATASI: Sinyal durumu güncellenemedi!", error: e);
    }
  }

  Future<void> saveCevap(String saseNo, String bildirimId, String cevap) async {
    try {
      await _db
          .collection('araclar')
          .doc(saseNo.toUpperCase())
          .collection('bildirimler')
          .doc(bildirimId)
          .update({'cevap': cevap});

      developer.log("SİBER CEVAP: Araç sahibinin cevabı mühürlendi: '$cevap'");
    } catch (e) {
      developer.log("AĞ HATASI: Müşteri cevabı mühürlenemedi!", error: e);
    }
  }

  // ── 🏷️ 5. SİBER BİLDİRİM ETİKETLERİ VE İKONLARI ───────────────────────────
  String turLabel(String tur) {
    switch (tur) {
      case 'yanlis_park': return 'Yanlış Park İhlali';
      case 'kaza':        return 'Araç Kazaya Karıştı';
      case 'cam_acik':    return 'Araç Camı Açık';
      case 'far_acik':    return 'Far / Işık Açık Kaldı';
      default:            return 'Siber Sinyal (Diğer)';
    }
  }

  String turIcon(String tur) {
    switch (tur) {
      case 'yanlis_park': return '🅿️';
      case 'kaza':        return '💥';
      case 'cam_acik':    return '🪟';
      case 'far_acik':    return '🔦';
      default:            return '🚨'; // Karargah alarmı
    }
  }
}