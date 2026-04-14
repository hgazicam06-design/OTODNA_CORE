// lib/widgets/siber_reklam_karti.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import '../models/ad_campaign_model.dart';
import '../core/siber_tema.dart';

class SiberReklamKarti extends StatelessWidget {
  final OtoDNACampaign kampanya;

  const SiberReklamKarti({super.key, required this.kampanya});

  @override
  Widget build(BuildContext context) {
    if (!kampanya.aktifMi) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: SiberTema.siberCamZirh(renk: Colors.black),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📡 SPONSORLU MÜHÜRÜ (NEON)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.verified, color: SiberTema.kuantumCyan, size: 14),
                const SizedBox(width: 6),
                Text(
                  "SPONSORLU DİSTRİBÜTÖR",
                  style: TextStyle(
                      color: SiberTema.kuantumCyan.withOpacity(0.8),
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5
                  ),
                ),
              ],
            ),
          ),

          // 🖼️ KUANTUM GÖRSELİ
          if (kampanya.gorselUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  kampanya.gorselUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                      height: 150,
                      color: Colors.white10,
                      child: const Icon(Icons.wifi_off, color: Colors.white24)
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(kampanya.kampanyaBaslik.toUpperCase(), style: SiberTema.kuantumBaslik.copyWith(fontSize: 16)),
                const SizedBox(height: 4),
                Text(kampanya.sirketAd, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // 💰 ETKİLEŞİM BUTONU
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: SiberTema.kuantumButonStili(renk: SiberTema.kuantumCyan),
                    onPressed: () => _reklamTiklamaMotoru(context),
                    child: const Text("FIRSATI YAKALA", style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 GERÇEK ZAMANLI TIKLAMA VE FİNANSAL KAYIT MOTORU (ZIRHLI)
  Future<void> _reklamTiklamaMotoru(BuildContext context) async {
    developer.log("📡 SİBER REKLAM: Tıklama algılandı. Karargah mühürlemesi başlıyor...");

    try {
      // ⛓️ ATOMİK ZIRH: Tıklama ve Log aynı anda kilitlenir!
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // 1. Kampanya İstatistiklerini Güncelle
      DocumentReference kampanyaRef = FirebaseFirestore.instance.collection('reklam_kampanyalari').doc(kampanya.id);
      batch.update(kampanyaRef, {
        'tiklanma_sayisi': FieldValue.increment(1),
        'son_tiklanma_tarihi': FieldValue.serverTimestamp(),
      });

      // 2. Kara Kutuya (Sistem Logları) Tıklamayı Mühürle
      DocumentReference logRef = FirebaseFirestore.instance.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'SPONSOR_ETKILESIMI',
        'kampanya_id': kampanya.id,
        'sirket_adi': kampanya.sirketAd,
        'islem_detayi': 'SİBER ETKİLEŞİM: Kullanıcı reklamı tıkladı. Otonom faturalandırma tetiklendi.',
        'tarih': FieldValue.serverTimestamp(),
      });

      // Füzeleri ateşle!
      await batch.commit();
      developer.log("✅ SİBER ONAY: Reklam etkileşimi Karargaha ATOMİK olarak işlendi.");

      // Kullanıcıya hissettir
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF111111),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Color(0xFF00FFC2), width: 1.5)),
              content: const Text("YÖNLENDİRİLİYOR...", style: TextStyle(color: Color(0xFF00FFC2), fontWeight: FontWeight.bold, letterSpacing: 1)),
              duration: const Duration(seconds: 2),
            )
        );
      }

    } catch (e) {
      developer.log("🚨 AĞ ÇÖKTÜ: Etkileşim kaydedilemedi!", error: e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.redAccent.withOpacity(0.9),
              content: const Text("BAĞLANTI HATASI: Kuantum Ağına ulaşılamıyor.", style: TextStyle(fontWeight: FontWeight.bold)),
            )
        );
      }
    }
  }
}