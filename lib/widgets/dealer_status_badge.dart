// lib/widgets/dealer_status_badge.dart
import 'package:flutter/material.dart';

/// 🛡️ KUANTUM LİYAKAT VE RÜTBE ROZETİ (SiberBayiRozeti)
/// Ustanın puanına göre 5 farklı (Gold, Silver, Bronze, Standart, Blacklist) Siber Rozet üretir.
class SiberBayiRozeti extends StatelessWidget {
  final int rating; // 1 ile 5 arası Karargah Puanı

  const SiberBayiRozeti({super.key, required this.rating});

  // ── 🎨 KARARGAH TASARIM DOKTRİNİ ──
  static const Color _oledBlack = Color(0xFF000000);
  static const Color _matGrey = Color(0xFF111111);

  @override
  Widget build(BuildContext context) {
    // 🚨 1 YILDIZ: KARA LİSTE (BLACKLIST) PROTOKOLÜ
    if (rating <= 1) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _matGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.redAccent, width: 2), // Kan Kırmızı Çerçeve
          boxShadow: [
            BoxShadow(color: Colors.redAccent.withOpacity(0.4), blurRadius: 15) // Kırmızı Parlama
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.gpp_bad_rounded, color: Colors.redAccent, size: 18),
            SizedBox(width: 6),
            Text(
              "KARA LİSTE (BLACKLIST)",
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5),
            ),
          ],
        ),
      );
    }

    // 🏆 2-5 YILDIZ ARASI: LİYAKAT RÜTBELERİ
    switch (rating) {
      case 5: // 🥇 ALTIN ROZET (KUSURSUZ)
        return _buildSiberRozet(Icons.workspace_premium_outlined, Colors.amberAccent, "GOLD BAYİ");
      case 4: // 🥈 GÜMÜŞ ROZET (GÜVENİLİR)
        return _buildSiberRozet(Icons.shield_outlined, Colors.grey.shade300, "SILVER BAYİ");
      case 3: // 🥉 BRONZ ROZET (ORTALAMA)
        return _buildSiberRozet(Icons.military_tech_outlined, Colors.orangeAccent, "BRONZE BAYİ");
      default: // ⚪ STANDART (2 YILDIZ)
        return _buildSiberRozet(Icons.account_circle_outlined, Colors.white30, "STANDART");
    }
  }

  // ── 🔧 ARAYÜZ YARDIMCISI (SİBER ÇERÇEVE ÜRETİCİ) ──
  Widget _buildSiberRozet(IconData ikon, Color renk, String rutbe) {
    // Sadece Gold ve Silver rozetlerde parlama (Glow) efekti aktiftir
    bool isPremium = rating >= 4;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _oledBlack,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: renk.withOpacity(0.5), width: 1.5),
        boxShadow: isPremium ? [BoxShadow(color: renk.withOpacity(0.2), blurRadius: 10)] : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikon, color: renk, size: 16),
          const SizedBox(width: 6),
          Text(
            rutbe,
            style: TextStyle(color: renk, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5),
          ),
        ],
      ),
    );
  }
}