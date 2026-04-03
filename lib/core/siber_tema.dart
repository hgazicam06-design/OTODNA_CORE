import 'dart:ui';
import 'package:flutter/material.dart';

class SiberTema {
  // KARARGAH RENK PALETİ
  static const Color oledBlack = Color(0xFF050505);
  static const Color kuantumCyan = Color(0xFF00F0FF);
  static const Color kanKirmizi = Color(0xFFFF2A2A);
  static const Color matGrey = Color(0xFF1A1A1A);
  static const Color altinSari = Color(0xFFFFD700); // 🟢 EKLENDİ: Altın Sarı Zırhı

  // SİBER CAM KALKANI (GLASSMORPHISM)
  // 🟢 EKLENDİ: bgImagePath parametresi
  static Widget siberCamKalkan({required Widget child, double sigma = 10.0, EdgeInsetsGeometry? padding, String? bgImagePath}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kuantumCyan.withOpacity(0.2), width: 1),
            // 🟢 EKLENDİ: Arka plan resmi varsa siber ızgarayı bas
            image: bgImagePath != null ? DecorationImage(image: AssetImage(bgImagePath), fit: BoxFit.cover, opacity: 0.2) : null,
            boxShadow: [
              BoxShadow(color: kuantumCyan.withOpacity(0.05), blurRadius: 30, spreadRadius: -5)
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  // KUANTUM BUTON STİLİ
  static ButtonStyle kuantumButonStili({bool isKirmizi = false}) {
    Color anaRenk = isKirmizi ? kanKirmizi : kuantumCyan;
    return ElevatedButton.styleFrom(
      backgroundColor: anaRenk,
      foregroundColor: oledBlack,
      elevation: 10,
      shadowColor: anaRenk.withOpacity(0.5),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  // ANA TEMA MOTORU
  static ThemeData get tema {
    return ThemeData(
      scaffoldBackgroundColor: oledBlack,
      primaryColor: kuantumCyan,
      fontFamily: 'Avenir', // Profesyonel font
      colorScheme: const ColorScheme.dark(
        primary: kuantumCyan,
        secondary: kuantumCyan,
        error: kanKirmizi,
        background: oledBlack,
        surface: matGrey,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}