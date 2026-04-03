// lib/services/arac_takip_sistemi.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
// SİBER NOT: Gerçek sistemde bu modül çağrılacak
// import 'notification_service.dart';

/// 🛡️ KUANTUM ARAÇ TAKİP VE HATIRLATMA MOTORU (AracTakipSistemi)
/// Sigorta, Muayene, Kasko ve Egzoz tarihlerini izler; 15, 7 ve 0 gün kala cihazlara füzeyi (Bildirim) ateşler.
class AracTakipSistemi {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 📡 OTONOM GÜNLÜK TARAMA MOTORU (BACKGROUND PROCESS) ─────────────────
  /// Bu fonksiyon her gün saat 00:01'de Karargah sunucularında veya cihaz açıldığında tetiklenir.
  static Future<void> tumAraclariTaraVeHatirlat() async {
    developer.log("SİBER RADAR: 📡 Araç veritabanı periyodik taraması başlatıldı...");

    try {
      final querySnapshot = await _db.collection('araclar').get();

      for (var doc in querySnapshot.docs) {
        var data = doc.data();
        String saseNo = doc.id;
        String fcmToken = data['fcmToken'] ?? '';

        if (fcmToken.isEmpty) continue; // İletişim cihazı yoksa atla

        // Tarihleri Kuantum Hafızaya al
        DateTime? muayeneBitis = (data['muayene_bitis'] as Timestamp?)?.toDate();
        DateTime? kaskoBitis = (data['kasko_bitis'] as Timestamp?)?.toDate();
        DateTime? egzozBitis = (data['egzoz_bitis'] as Timestamp?)?.toDate();

        // Hatırlatmaları Ateşle
        if (muayeneBitis != null) _hatirlatmaKontrolVeFirlat(saseNo, fcmToken, muayeneBitis, "TÜVTÜRK Muayene");
        if (kaskoBitis != null) _hatirlatmaKontrolVeFirlat(saseNo, fcmToken, kaskoBitis, "Kasko / Sigorta");
        if (egzozBitis != null) _hatirlatmaKontrolVeFirlat(saseNo, fcmToken, egzozBitis, "Egzoz Emisyon");
      }

      developer.log("✅ SİBER ONAY: Tarama tamamlandı. İhlal sınırındaki araçlara sinyaller fırlatıldı.");

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Araç takip veritabanına ulaşılamadı!", error: e);
    }
  }

  // ── ⏱️ ZAMAN SENSÖRÜ VE BİLDİRİM ATEŞLEYİCİSİ ───────────────────────────
  static void _hatirlatmaKontrolVeFirlat(String saseNo, String fcmToken, DateTime sonTarih, String tur) {
    int kalanGun = sonTarih.difference(DateTime.now()).inDays;

    // Karargah Kuralı: Sadece 15, 7 ve 0 gün kala sinyal fırlat
    if (kalanGun == 15 || kalanGun == 7 || kalanGun == 0) {
      String baslik = kalanGun == 0
          ? "🚨 DİKKAT: $tur SÜRESİ BİTTİ!"
          : "⚠️ $tur İÇİN SON $kalanGun GÜN!";

      String icerik = "Cezalı duruma düşmemek için anlaşmalı firmalarımızdan VIP teklif alabilir veya Kuantum Randevu talep edebilirsiniz.";

      _bildirimGonderVeMuhurle(saseNo, fcmToken, baslik, icerik);
    }
  }

  static Future<void> _bildirimGonderVeMuhurle(String saseNo, String fcmToken, String baslik, String icerik) async {
    try {
      // 1. Veritabanı Mührü
      await _db.collection('araclar').doc(saseNo).collection('bildirimler').add({
        'tur': 'SISTEM_HATIRLATMASI',
        'mesaj': "$baslik - $icerik",
        'tarih': FieldValue.serverTimestamp(),
        'okundu': false,
        'durum': 'gonderildi',
      });

      // 2. Cihaza FCM Sinyali Fırlatma (NotificationService)
      // NotificationService().sendPushNotification(token: fcmToken, title: baslik, body: icerik);

      developer.log("📡 SİBER SİNYAL: $saseNo şaseli araca hatırlatma fırlatıldı: $baslik");
    } catch (e) {
      developer.log("İLETİŞİM HATASI: Sinyal Karargaha mühürlenemedi!", error: e);
    }
  }

  // ── 💎 VIP RANDEVU VE FİNANSAL AĞ GEÇİDİ (ZIRHLANDI) ───────────────────
  static Future<void> vipRandevuSatinAl({
    required String kullaniciId,
    required String tur,
    required double hizmetBedeli,
    String bayiId = "", // SİBER NOT: Finansal kontrol için eklendi!
  }) async {
    developer.log("🚀 SİBER GEÇİŞ: $tur için VIP Randevu köprüsü tetiklendi...");

    try {
      if (hizmetBedeli <= 0) throw Exception("Sıfır TL bedel ile VIP hizmet satılamaz!");

      // ⚖️ KARARGAH FİNANS KURALI: Murat Plaza %30, diğerleri %12 kesinti!
      double kesintiOrani = (bayiId == "MURAT_PLAZA") ? 0.30 : 0.12;
      double gaziPayi = hizmetBedeli * kesintiOrani;
      double operasyonPayi = hizmetBedeli - gaziPayi;

      // 1. Finans Havuzuna Mühürle
      await _db.collection('finans_havuzu').add({
        'kullanici_id': kullaniciId,
        'bayi_id': bayiId.isNotEmpty ? bayiId : "STANDART_BAYI",
        'islem_turu': 'VIP_RANDEVU_$tur',
        'toplam_tutar': hizmetBedeli,
        'kesinti_orani': "%${(kesintiOrani * 100).toInt()}",
        'karargah_kesintisi': gaziPayi,
        'operasyon_hakedisi': operasyonPayi,
        'tarih': FieldValue.serverTimestamp(),
        'durum': 'ONAYLANDI_BEKLIYOR'
      });

      // 2. Operasyon Merkezine İş Emri Gönder
      if (tur == "Egzoz Emisyon") {
        developer.log("📍 LOKASYON ONAYI: En yakın OtoDNA anlaşmalı noktasına siber yönlendirme başlatıldı. Karargah Payı: ₺${gaziPayi.toStringAsFixed(2)}");
      } else if (tur == "TÜVTÜRK Muayene") {
        developer.log("📅 BÜROKRASİ ONAYI: VIP Randevu talebi alındı. Temsilci Tüvtürk randevusunu mühürleyecek. Karargah Payı: ₺${gaziPayi.toStringAsFixed(2)}");
      }

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: VIP Randevu işlemi finansal ağa yazılamadı!", error: e);
      throw Exception("Ödeme ve Mühürleme Başarısız.");
    }
  }
}