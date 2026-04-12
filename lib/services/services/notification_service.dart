import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM İLETİŞİM VE BİLDİRİM MOTORU (V2.2 - ZIRHLI VE GÜNCEL)
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
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ
      throw Exception("SİBER İHLAL: Bildirim izinleri reddedildi, iletişim modülü başlatılamıyor!");
    }
  }

  // Cihazın hedef kimliğini (Token) alır
  Future<String> getToken() async {
    try {
      String? token = await _fcm.getToken();
      if (token == null) {
        throw Exception("Kuantum mühürü (Token) boş döndü!");
      }
      return token;
    } catch (e) {
      developer.log("İLETİŞİM HATASI: Cihaz mühürü (Token) okunamadı!", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ
      throw Exception("RADAR HATASI: Cihazın hedef kimliği alınamadı, sinyal fırlatılamaz!");
    }
  }

  // ── 🚀 2. SİNYAL FIRLATMA VE SPAM KALKANI ──────────────────────────────────
  Future<Map<String, dynamic>> sendNotification({
    required String saseNo,
    required String tur,
    required String mesaj,
    required String gonderenIp,
    required List<String> engelliIpler,
    String? fcmToken,
  }) async {
    try {
      // 🛡️ SİBER GÜVENLİK: IP Kara Liste (Spam/Taciz) Kontrolü
      if (engelliIpler.contains(gonderenIp)) {
        developer.log("SİBER ENGEL: $gonderenIp numaralı IP Kara Listede! Sinyal reddedildi.");
        return {'success': false, 'reason': 'blocked'};
      }

      String muhurluSase = saseNo.toUpperCase();

      // 🚨 KRİTİK: Koleksiyon adı 'araclar' Kuantum standardına uygun
      final ref = await _db
          .collection('araclar')
          .doc(muhurluSase)
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

      developer.log("SİBER SİNYAL: $muhurluSase şaseli araca '$tur' kodlu bildirim fırlatıldı.");
      return {'success': true, 'bildirimId': ref.id};

    } catch (e) {
      developer.log("SİNYAL KOPTU: Bildirim veritabanına mühürlenemedi!", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ
      throw Exception("SİNYAL KOPTU: Bildirim Kuantum Ağına işlenemedi. Bağlantınızı kontrol edin!");
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
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ
      throw Exception("VERİTABANI İHLALİ: Sinyal durumu ağa mühürlenemedi!");
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
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ
      throw Exception("İLETİŞİM KOPTU: Cevabınız Karargaha iletilemedi. Lütfen tekrar deneyin!");
    }
  }

  // ── 🏷️ 5. SİBER BİLDİRİM ETİKETLERİ VE İKONLARI (YENİ EKLENTİLER) ─────────

  // Bildirim türüne göre Kuantum İkonları
  String turIcon(String tur) {
    switch (tur.toLowerCase()) {
      case 'kaza':
        return '💥';
      case 'park':
        return '🅿️';
      case 'acil':
        return '🚨';
      case 'sistem':
        return '⚙️';
      case 'guvenlik':
        return '🛡️';
      default:
        return '📩';
    }
  }

  // Bildirim türüne göre Askeri Başlıklar
  String turLabel(String tur) {
    switch (tur.toLowerCase()) {
      case 'kaza':
        return 'Kaza / Temas İhtimali';
      case 'park':
        return 'Hatalı Park İhlali';
      case 'acil':
        return 'Acil Durum Sinyali';
      case 'sistem':
        return 'OtoDNA Sistem Mesajı';
      case 'guvenlik':
        return 'Kuantum Ağ Güvenliği';
      default:
        return 'Genel Bildirim';
    }
  }
}