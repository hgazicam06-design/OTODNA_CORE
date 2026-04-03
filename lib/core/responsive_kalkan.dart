// lib/core/responsive_kalkan.dart
import 'package:flutter/material.dart';
import 'siber_tema.dart';

/// 🛡️ OTONOM EKRAN ZIRHI (ResponsiveKalkan)
/// Uygulama devasa bir araç ekranında (Double-Din) veya Tablette açıldığında,
/// içeriğin sünüp iğrenç görünmesini engeller. Tüm sistemi tam ortaya Kilitler!
class ResponsiveKalkan extends StatelessWidget {
  final Widget child;
  final bool isOledBackground; // Sayfanın arka planı simsiyah mı olsun?

  const ResponsiveKalkan({
    super.key,
    required this.child,
    this.isOledBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isOledBackground ? SiberTema.oledBlack : Colors.transparent,
      body: SafeArea(
        child: Center(
          // Kuantum Sınırı: İçerik 600 pikselden daha fazla genişleyemez!
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: child, // Senin tasarladığın asıl ekran bu zırhın içinde çalışır
          ),
        ),
      ),
    );
  }
}