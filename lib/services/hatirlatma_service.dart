import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:developer' as developer;
import '../models/arac_model.dart'; // Model dosyanın yolu doğru kalmalı

/// 🛡️ KUANTUM UYARI VE HATIRLATMA MOTORU (HatirlatmaService)
/// Araçların muayene, sigorta ve emisyon sürelerini otonom takip edip Karargaha sinyal yollar.
class HatirlatmaService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── ⏱️ SİBER ZAMANLAYICI ALGORİTMASI ──────────────────────────────────────
  /// Karargah Kuralı: Bitişe 15 gün, 7 gün ve 0 gün (aynı gün) kala radar sinyali fırlatılır.
  static List<DateTime> _hatirlatmaZamanlari(DateTime bitis) => [
    bitis.subtract(const Duration(days: 15)),
    bitis.subtract(const Duration(days: 7)),
    bitis,
  ];

  // ── 📝 KUANTUM MÜHÜR: HATIRLATMALARI FİREBASE'E KİLİTLEME ──────────────────
  /// Tüm bitiş tarihlerini hesaplar ve gelecekteki uyarıları Karargah veritabanına mühürler.
  static Future<void> hatirlatmalariKaydet(AracModel arac) async {
    try {
      developer.log("SİBER BİLGİ: ${arac.saseNo} şaseli araç için Erken Uyarı Radarı başlatıldı...");

      final ref = _db
          .collection('araclar') // İngilizce 'vehicles' yerine Türkçe Karargah dili
          .doc(arac.saseNo.toUpperCase())
          .collection('hatirlatmalar');

      final batch = _db.batch();
      int eklenenSinyalSayisi = 0;

      // İç otonom fonksiyon: Eğer tarih geçmişse kaydetmez, gelecekse Kuantum ağına mühürler
      void ekle(DateTime? bitis, String tur) {
        if (bitis == null) return;

        for (final zaman in _hatirlatmaZamanlari(bitis)) {
          // Eğer hatırlatma zamanı henüz gelmediyse (gelecekteyse) radara ekle
          if (zaman.isAfter(DateTime.now())) {
            final doc = ref.doc();
            batch.set(doc, {
              'tur': tur.toUpperCase(),
              'zamanlanmis': Timestamp.fromDate(zaman),
              'bitis': Timestamp.fromDate(bitis),
              'gonderildi': false, // Sinyal fırlatıldığında (Cloud Function ile) true olacak
              'saseNo': arac.saseNo.toUpperCase(),
              'plaka': (arac.plaka ?? 'PLAKASIZ').toUpperCase(),
              'sahibiUid': arac.sahibiUid,
              'olusturulma_tarihi': FieldValue.serverTimestamp(),
            });
            eklenenSinyalSayisi++;
          }
        }
      }

      ekle(arac.muayeneBitis, 'MUAYENE');
      ekle(arac.emisyonBitis, 'EMİSYON');
      ekle(arac.sigortaBitis, 'SİGORTA');
      ekle(arac.kaskoBitis, 'KASKO');

      if (eklenenSinyalSayisi > 0) {
        await batch.commit();
        developer.log("SİBER MÜHÜR: Toplam $eklenenSinyalSayisi adet erken uyarı sinyali ağa kilitlendi!");
      } else {
        developer.log("SİBER UYARI: Eklenecek geleceğe dönük bir sinyal bulunamadı.");
      }
    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Hatırlatma mühürleri veritabanına yazılamadı!", error: e);
      throw Exception("SİBER İHLAL: Uyarı radarı kurulamadı.");
    }
  }

  // ── 📡 İLETİŞİM SİNYALİ GÜNCELLEME (FCM TOKEN) ────────────────────────────
  /// Araca anlık (Push) bildirim atabilmek için cihazın kimliğini (Token) günceller.
  static Future<void> fcmTokenGuncelle(String saseNo) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;

      await _db.collection('araclar').doc(saseNo.toUpperCase()).set(
          {'fcmToken': token, 'son_sinyal_tarihi': FieldValue.serverTimestamp()},
          SetOptions(merge: true) // Diğer verileri ezmemek için 'merge' kullanıldı
      );
      developer.log("SİBER BİLGİ: Cihazın hedef kilit (FCM) sinyali güncellendi.");
    } catch (e) {
      developer.log("İLETİŞİM HATASI: FCM Token alınamadı veya yazılamadı!", error: e);
    }
  }

  // ── ⏱️ ZAMAN SENSÖRLERİ ──────────────────────────────────────────────────

  /// Kalan gün sayısını net bir şekilde hesaplar
  static int kalanGun(DateTime? bitis) {
    if (bitis == null) return -1;
    // Sadece gün farkını almak için saatleri sıfırlayan siber mantık:
    final simdi = DateTime.now();
    final bugun = DateTime(simdi.year, simdi.month, simdi.day);
    final bitisGunu = DateTime(bitis.year, bitis.month, bitis.day);

    return bitisGunu.difference(bugun).inDays;
  }

  /// Kalan güne göre Karargah durum etiketini (KIRMIZI, SARI, YEŞİL) verir
  static String durumEtiketi(DateTime? bitis) {
    final gun = kalanGun(bitis);
    if (gun < 0) return 'GEÇMİŞ SİBER İHLAL (KIRMIZI)';
    if (gun <= 15) return 'ACİL KOD (KIRMIZI)';
    if (gun <= 30) return 'YAKLAŞIYOR (SARI)';
    return 'GÜVENLİ (YEŞİL)';
  }
}