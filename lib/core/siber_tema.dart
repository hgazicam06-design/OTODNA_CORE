import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SiberTema {
  // 🌑 KUANTUM RENK PALETİ (TESLA STANDARTLARINDA)
  static const Color oledBlack = Color(0xFF000000);
  static const Color kuantumCyan = Color(0xFF00FFC2); // Neon Turkuaz
  static const Color neonPurple = Color(0xFF9D00FF);
  static const Color siberGold = Color(0xFFFFD700);
  static const Color kritikRed = Color(0xFFFF003C);

  // 🏗️ 7D SİBER CAM EFEKTİ (GLASSMORPHISM)
  static BoxDecoration siberCamZirh({Color? renk}) {
    return BoxDecoration(
      color: (renk ?? Colors.white).withOpacity(0.05),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
    );
  }

  // ⚡ KUANTUM BUTON STİLİ
  static ButtonStyle kuantumButonStili({Color renk = kuantumCyan}) {
    return ElevatedButton.styleFrom(
      backgroundColor: renk,
      foregroundColor: oledBlack,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      elevation: 8,
      shadowColor: renk.withOpacity(0.5),
    );
  }

  // 📡 SİBER METİN STİLLERİ
  static TextStyle kuantumBaslik = GoogleFonts.orbitron(
    color: kuantumCyan,
    fontSize: 22,
    fontWeight: FontWeight.w900,
    letterSpacing: 2,
  );
}