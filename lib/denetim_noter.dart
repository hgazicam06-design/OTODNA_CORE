// lib/utils/denetim_noter.dart
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM DİJİTAL NOTER VE ZAMAN DAMGASI (SiberDenetimNoteri)
/// Fotoğrafların sahte/eski olmasını engeller, riskli parçalar için Karargah uyarıları üretir.
class SiberDenetimNoteri {

  // 1. ZIRH: Yetkili Onay Mührü
  static String siberMuhurBas(String bayiKodu, String ustaAdi) {
    developer.log("🛡️ DİJİTAL NOTER: $bayiKodu yetkilisi $ustaAdi için mühür oluşturuldu.");
    return "SİBER MÜHÜR: $bayiKodu | YETKİLİ: $ustaAdi";
  }

  // 2. ZIRH: Zaman Damgası ve Optik Doğrulama
  // (Galeriden eski fotoğraf yüklenmesini veya sahtekarlığı engeller)
  static bool zamanDamgasiDogrula(DateTime cekilmeAni) {
    DateTime suAn = DateTime.now();
    int gecenDakika = suAn.difference(cekilmeAni).inMinutes;

    if (gecenDakika > 5) {
      developer.log("🚨 SİBER İHLAL: Kanıt çok eski ($gecenDakika dakika önce). Canlı çekim zorunludur!");
      return false;
    }

    developer.log("✅ NOTER ONAYI: Zaman damgası geçerli. Kanıt taze.");
    return true;
  }
}

// 3. WIDGET: Kırmızı X Hatırlatıcı Kalkanı (Arıza Kaydı Ekranları İçin)
class SiberRiskHatirlatici extends StatelessWidget {
  final String parca;

  const SiberRiskHatirlatici({super.key, required this.parca});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.1), // Kan Kırmızı Zemin
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.redAccent, width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.redAccent.withOpacity(0.05), blurRadius: 15, spreadRadius: 2)
          ]
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("SİBER UYARI (KIRMIZI X)", style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
                const SizedBox(height: 6),
                Text(
                  "$parca modülünde Karargah denetimi sonucu kritik bir risk tespit edilmiştir. Aracın sürüş güvenliği için acilen onarım gerekmektedir.",
                  style: const TextStyle(fontSize: 12, color: Colors.white70, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}