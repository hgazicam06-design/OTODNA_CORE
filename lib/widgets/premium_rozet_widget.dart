// lib/widgets/premium_rozet_widget.dart
import 'package:flutter/material.dart';

class PremiumRozet extends StatelessWidget {
  final String rozetTipi; // "Altın", "Gümüş", "Bronz", "Blacklist", "Boş"
  final double boyut;
  final bool pariltiAktif;

  PremiumRozet({
    super.key,
    required this.rozetTipi,
    this.boyut = 48.0,
    this.pariltiAktif = true,
  });

  @override
  Widget build(BuildContext context) {
    List<Color> gradientColors;
    IconData merkezIkon = Icons.workspace_premium; // Varsayılan Kalkan Ikonu (Gerçekçi ve Premium hisli)

    // ── ROZET RENK PALETİ VE KADEMELER ──
    switch (rozetTipi) {
      case "Altın":
        gradientColors = [Color(0xFFF9D423), Color(0xFFFF4E50)]; // Parlak Altın - Bakır Altın geçişi
        merkezIkon = Icons.verified;
        break;
      case "Gümüş":
        gradientColors = [Color(0xFFE0EAFC), Color(0xFFCFDEF3)]; // Gümüş Platin
        merkezIkon = Icons.workspace_premium;
        break;
      case "Bronz":
        gradientColors = [Color(0xFFCD7F32), Color(0xFF8B4513)]; // Paslı/Oksit Bronz
        merkezIkon = Icons.shield;
        break;
      case "Blacklist":
        gradientColors = [Color(0xFF111111), Color(0xFF434343)]; // Karbon Siyah
        merkezIkon = Icons.gpp_bad; // Çarpı Kalkan
        break;
      default: // "Boş"
        gradientColors = [Colors.white24, Colors.white10];
        merkezIkon = Icons.shield_outlined;
        break;
    }

    // Blacklist için kırmızı bir glow (gölge) veya Altın için sarı glow
    Color glowColor = rozetTipi == "Blacklist" 
        ? Colors.redAccent.withOpacity(0.5)
        : gradientColors.first.withOpacity(0.6);

    return Container(
      width: boyut * 1.5,
      height: boyut * 1.5,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Dış glow efekti
        boxShadow: pariltiAktif && rozetTipi != "Boş"
            ? [BoxShadow(color: glowColor, blurRadius: boyut / 2, spreadRadius: 2)]
            : [],
        border: Border.all(
          color: rozetTipi == "Boş" ? Colors.white12 : Colors.transparent,
          width: 2,
        ),
      ),
      child: Center(
        // GERÇEKÇİ SHADER MASK: Ikonu düz bir renk yerine Gradient ile kaplıyoruz (Metalik hissiyat)
        child: ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ).createShader(bounds);
          },
          child: Icon(
            merkezIkon,
            size: boyut,
            color: Colors.white, // ShaderMask rengi bunun üzerine bindirir
          ),
        ),
      ),
    );
  }
}
