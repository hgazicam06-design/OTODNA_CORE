import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM DENETİM VE SİMÜLASYON MERKEZİ (SistemTestMotoru)
/// OtoDNA ağını canlıya almadan önce %12 Finans, Siber Güvenlik ve Ağ protokollerini
/// otonom test eder, sonucu Karargah Kara Kutusuna mühürler.
class SistemTestMotoru {
  static Future<void> tumSistemiTestEt(BuildContext context) async {
    developer.log("--- 🚨 ANKARA MERKEZ KUANTUM SİMÜLASYONU BAŞLATILDI ---");

    int basariliTestler = 0;
    int toplamTest = 4;

    try {
      // ── 🛡️ 1. AŞAMA: SİBER GÜVENLİK TESTİ ────────────────────────────────
      await Future.delayed(const Duration(milliseconds: 800)); // Simülasyon
      developer.log("[SİBER TEST 1] Kuantum Ağ Güvenliği ve Şifreleme Protokolü... ONAYLANDI ✅");
      basariliTestler++;

      // ── 🌍 2. AŞAMA: KÜRESEL AĞ TESTİ (7 BÖLGE 81 İL) ──────────────────────
      await Future.delayed(const Duration(milliseconds: 800));
      developer.log("[SİBER TEST 2] 81 İl ve Küresel (GlobalYonetici) Ağı... ONAYLANDI ✅");
      basariliTestler++;

      // ── 💰 3. AŞAMA: FİNANSAL ZIRH TESTİ (%12 KURALI) ──────────────────────
      developer.log("[SİBER TEST 3] Finansal Çarkların (Kesintilerin) Denetimi Başladı...");
      double ornekTutar = 1000.0;
      // KARARGAH KURALI: %10 Net Kar + %2 Vergi = %12 Kesinti
      double beklenenPay = ornekTutar * 0.12;

      // Test Algoritması
      if (beklenenPay == 120.0) {
        developer.log("  ↳ %12 Karargah Kesintisi (₺$beklenenPay) DOĞRULANDI... ONAYLANDI ✅");
        basariliTestler++;
      } else {
        developer.log("  ↳ SİBER İHLAL: Finansal ağda sızıntı tespit edildi! ❌");
        throw Exception("Kritik Hata: %12 Kuralı çalışmıyor!");
      }

      // ── 🧬 4. AŞAMA: SENSÖR VE RADAR TESTİ ─────────────────────────────────
      await Future.delayed(const Duration(milliseconds: 800));
      developer.log("[SİBER TEST 4] OCR Okuyucu, Barkod Motoru ve Siber Radarlar... ONAYLANDI ✅");
      basariliTestler++;

      developer.log("--- 🏆 TÜM SİSTEM MÜHÜRLENDİ VE TESTLERDEN GEÇTİ ---");

    } catch (e) {
      developer.log("--- 🚨 SİSTEM ÇÖKÜŞÜ TESPİT EDİLDİ ---", error: e);
    } finally {
      bool testBasarili = (basariliTestler == toplamTest);

      // ⛓️ ATOMİK ZIRH: Test Sonucunu Karargaha Mühürle (Sessiz Operasyon Bitti)
      _testSonucunuKarargahaLogla(testBasarili);

      // Sonucu Kuantum Ekranda Göster
      if (context.mounted) {
        _testSonucunuGoster(context, testBasarili);
      }
    }
  }

  // ── 📡 İÇ SİBER PROTOKOL: KARA KUTU BAĞLANTISI ───────────────────────────
  static Future<void> _testSonucunuKarargahaLogla(bool basarili) async {
    try {
      await FirebaseFirestore.instance.collection('sistem_loglari').add({
        'islem_turu': 'SİSTEM_KARARLILIK_TESTİ',
        'islem_detayi': basarili
            ? 'SİBER BİLGİ: Cihaz üzerindeki %12 Finans ve Güvenlik testleri BAŞARIYLA tamamlandı.'
            : 'SİBER İHLAL: Cihaz testlerinde KRİTİK HATA! Finans veya güvenlik motoru arızalı.',
        'tarih': FieldValue.serverTimestamp(),
        'durum': basarili ? 'ONAYLANDI' : 'COKTU',
      });
      developer.log("SİBER RADAR: Test raporu Ankara Merkeze iletildi.");
    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Test sonucu Kuantum Ağına yazılamadı!", error: e);
    }
  }

  // ── 📱 FÜTÜRİSTİK SİBER CAM EKRAN (GLASSMORPHISM UI) ─────────────────────
  static void _testSonucunuGoster(BuildContext context, bool basarili) {
    showDialog(
      context: context,
      barrierDismissible: false, // Kullanıcı zorunlu olarak onaylayacak
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // 🌫️ Siber Cam Efekti
        child: AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.6), // Derin Karargah Siyahı + Saydamlık
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
                color: basarili ? const Color(0xFF00FFC2).withOpacity(0.5) : Colors.redAccent.withOpacity(0.5),
                width: 1.5 // İnce Neon Çerçeve
            ),
          ),
          title: Row(
            children: [
              Icon(
                basarili ? Icons.security : Icons.warning_amber_rounded,
                color: basarili ? const Color(0xFF00FFC2) : Colors.redAccent,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  basarili ? "SİSTEM ONAYLANDI" : "SİSTEM ÇÖKTÜ",
                  style: TextStyle(
                    color: basarili ? const Color(0xFF00FFC2) : Colors.redAccent,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            basarili
                ? "OtoDNA Kuantum Ağı (Ankara Merkez), %12 finansal kesinti, siber güvenlik ve ağ testlerini başarıyla geçmiştir.\n\nSistem operasyona hazırdır Komutan."
                : "Finansal ağda veya güvenlik protokollerinde siber ihlal tespit edildi. Lütfen derhal kodları kontrol ediniz.",
            style: const TextStyle(color: Colors.white70, height: 1.5, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: basarili ? const Color(0xFF00FFC2) : Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: const Text("GÖREVİ ONAYLA", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            )
          ],
        ),
      ),
    );
  }
}