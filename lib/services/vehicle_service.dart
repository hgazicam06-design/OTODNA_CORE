import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

// ── 💎 ARAÇ KAMU KİMLİĞİ (MODEL) ──────────────────────────────────────────
class VehiclePublicInfo {
  final String plaka;
  final String sahibiAdi;
  final String sahibiSoyadi;
  final String fcmToken;
  final List<String> engelliIpler;

  VehiclePublicInfo({
    required this.plaka,
    required this.sahibiAdi,
    required this.sahibiSoyadi,
    required this.fcmToken,
    required this.engelliIpler,
  });

  factory VehiclePublicInfo.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return VehiclePublicInfo(
      plaka: d['plaka'] ?? 'PLAKASIZ',
      sahibiAdi: d['sahibiAdi'] ?? 'Gizli',
      sahibiSoyadi: d['sahibiSoyadi'] ?? 'Kullanıcı',
      fcmToken: d['fcmToken'] ?? '',
      engelliIpler: List<String>.from(d['engelliIpler'] ?? []),
    );
  }
}

/// 🛡️ KUANTUM ARAÇ KİMLİK VE SİBER SAVUNMA MOTORU (VehicleService)
/// Araçların kamuya açık DNA'sını çeker, iletişim radarını kurar ve IP bazlı siber saldırganları kara listeye alır.
class VehicleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 🔍 1. KİMLİK İSTİHBARATI ÇEKME ───────────────────────────────────────
  Future<VehiclePublicInfo?> getPublicInfo(String saseNo) async {
    try {
      String muhurluSase = saseNo.toUpperCase();
      developer.log("SİBER RADAR: $muhurluSase şaseli aracın kamuya açık kimliği taranıyor...");

      final doc = await _db.collection('araclar').doc(muhurluSase).get(); // 'vehicles' yerine Karargah dili!

      if (!doc.exists) {
        developer.log("SİBER İHLAL: Radarda böyle bir araç (DNA) bulunamadı!");
        return null;
      }

      developer.log("SİBER BİLGİ: Araç kimliği başarıyla çekildi.");
      return VehiclePublicInfo.fromDoc(doc);
    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Araç veritabanına ulaşılamadı!", error: e);
      return null;
    }
  }

  // ── 🛑 2. SİBER SAVUNMA (IP KARA LİSTESİ) ───────────────────────────────
  Future<void> engelleIp(String saseNo, String ip) async {
    try {
      await _db.collection('araclar').doc(saseNo.toUpperCase()).update({
        'engelliIpler': FieldValue.arrayUnion([ip]),
      });
      developer.log("SİBER SAVUNMA: $ip adresi Kuantum Kara Listesine eklendi! Sinyalleri engellendi.");
    } catch (e) {
      developer.log("SAVUNMA HATASI: Tehdit unsuru (IP) kara listeye alınamadı!", error: e);
    }
  }

  Future<void> engelKaldir(String saseNo, String ip) async {
    try {
      await _db.collection('araclar').doc(saseNo.toUpperCase()).update({
        'engelliIpler': FieldValue.arrayRemove([ip]),
      });
      developer.log("SİBER BİLGİ: $ip adresinin Kara Liste kısıtlaması Karargah tarafından kaldırıldı.");
    } catch (e) {
      developer.log("SAVUNMA HATASI: IP engeli kaldırılamadı!", error: e);
    }
  }

  // ── 📡 3. CANLI SİNYAL RADARI (STREAM) ──────────────────────────────────
  Stream<QuerySnapshot> bildirimlerStream(String saseNo) {
    developer.log("SİBER RADAR: ${saseNo.toUpperCase()} için Canlı Bildirim Ağı aktif edildi.");
    return _db
        .collection('araclar')
        .doc(saseNo.toUpperCase())
        .collection('bildirimler')
        .orderBy('tarih', descending: true)
        .snapshots();
  }

  // ── 👁️ 4. SİNYAL ONAY VE OKUNMA MÜHRÜ ───────────────────────────────────
  Future<void> okunduIsaretle(String saseNo, String bildirimId) async {
    try {
      await _db
          .collection('araclar')
          .doc(saseNo.toUpperCase())
          .collection('bildirimler')
          .doc(bildirimId)
          .update({'okundu': true});

      developer.log("SİBER ONAY: Gelen sinyal ($bildirimId) 'okundu' olarak mühürlendi.");
    } catch (e) {
      developer.log("AĞ HATASI: Sinyal durumu mühürlenemedi!", error: e);
    }
  }
}import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

// ── 💎 ARAÇ KAMU KİMLİĞİ (MODEL) ──────────────────────────────────────────
class VehiclePublicInfo {
  final String plaka;
  final String sahibiAdi;
  final String sahibiSoyadi;
  final String fcmToken;
  final List<String> engelliIpler;

  VehiclePublicInfo({
    required this.plaka,
    required this.sahibiAdi,
    required this.sahibiSoyadi,
    required this.fcmToken,
    required this.engelliIpler,
  });

  factory VehiclePublicInfo.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return VehiclePublicInfo(
      plaka: d['plaka'] ?? 'PLAKASIZ',
      sahibiAdi: d['sahibiAdi'] ?? 'Gizli',
      sahibiSoyadi: d['sahibiSoyadi'] ?? 'Kullanıcı',
      fcmToken: d['fcmToken'] ?? '',
      engelliIpler: List<String>.from(d['engelliIpler'] ?? []),
    );
  }
}

/// 🛡️ KUANTUM ARAÇ KİMLİK VE SİBER SAVUNMA MOTORU (VehicleService)
/// Araçların kamuya açık DNA'sını çeker, iletişim radarını kurar ve IP bazlı siber saldırganları kara listeye alır.
class VehicleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 🔍 1. KİMLİK İSTİHBARATI ÇEKME ───────────────────────────────────────
  Future<VehiclePublicInfo?> getPublicInfo(String saseNo) async {
    try {
      String muhurluSase = saseNo.toUpperCase();
      developer.log("SİBER RADAR: $muhurluSase şaseli aracın kamuya açık kimliği taranıyor...");

      final doc = await _db.collection('araclar').doc(muhurluSase).get(); // 'vehicles' yerine Karargah dili!

      if (!doc.exists) {
        developer.log("SİBER İHLAL: Radarda böyle bir araç (DNA) bulunamadı!");
        return null;
      }

      developer.log("SİBER BİLGİ: Araç kimliği başarıyla çekildi.");
      return VehiclePublicInfo.fromDoc(doc);
    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Araç veritabanına ulaşılamadı!", error: e);
      return null;
    }
  }

  // ── 🛑 2. SİBER SAVUNMA (IP KARA LİSTESİ) ───────────────────────────────
  Future<void> engelleIp(String saseNo, String ip) async {
    try {
      await _db.collection('araclar').doc(saseNo.toUpperCase()).update({
        'engelliIpler': FieldValue.arrayUnion([ip]),
      });
      developer.log("SİBER SAVUNMA: $ip adresi Kuantum Kara Listesine eklendi! Sinyalleri engellendi.");
    } catch (e) {
      developer.log("SAVUNMA HATASI: Tehdit unsuru (IP) kara listeye alınamadı!", error: e);
    }
  }

  Future<void> engelKaldir(String saseNo, String ip) async {
    try {
      await _db.collection('araclar').doc(saseNo.toUpperCase()).update({
        'engelliIpler': FieldValue.arrayRemove([ip]),
      });
      developer.log("SİBER BİLGİ: $ip adresinin Kara Liste kısıtlaması Karargah tarafından kaldırıldı.");
    } catch (e) {
      developer.log("SAVUNMA HATASI: IP engeli kaldırılamadı!", error: e);
    }
  }

  // ── 📡 3. CANLI SİNYAL RADARI (STREAM) ──────────────────────────────────
  Stream<QuerySnapshot> bildirimlerStream(String saseNo) {
    developer.log("SİBER RADAR: ${saseNo.toUpperCase()} için Canlı Bildirim Ağı aktif edildi.");
    return _db
        .collection('araclar')
        .doc(saseNo.toUpperCase())
        .collection('bildirimler')
        .orderBy('tarih', descending: true)
        .snapshots();
  }

  // ── 👁️ 4. SİNYAL ONAY VE OKUNMA MÜHRÜ ───────────────────────────────────
  Future<void> okunduIsaretle(String saseNo, String bildirimId) async {
    try {
      await _db
          .collection('araclar')
          .doc(saseNo.toUpperCase())
          .collection('bildirimler')
          .doc(bildirimId)
          .update({'okundu': true});

      developer.log("SİBER ONAY: Gelen sinyal ($bildirimId) 'okundu' olarak mühürlendi.");
    } catch (e) {
      developer.log("AĞ HATASI: Sinyal durumu mühürlenemedi!", error: e);
    }
  }
}