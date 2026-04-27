// lib/core/siber_tema.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SiberTema {
  // 🌑 KUANTUM RENK PALETİ (TESLA STANDARTLARINDA)
  static const Color oledBlack = Color(0xFFF4F6F8); // Fildişi Arka Plan
  static const Color kuantumCyan = Color(0xFF005A64); // Kurumsal Zümrüt (Primary) // Neon Turkuaz
  static const Color neonPurple = Color(0xFF9D00FF);
  static const Color siberGold = Color(0xFFFFD700);
  static const Color kritikRed = Color(0xFFFF003C);

  // 🚨 EKLENEN EKSİK RENKLER (Kırmızı çizgileri engeller)
  static const Color kanKirmizi = Color(0xFFD32F2F); // Profesyonel Kırmızı
  static const Color textMain = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color matGrey = Colors.white; // Surface / Kart Rengi
  static const Color altinSari = Color(0xFFFFD700);
  static const Color geceMavisi = Color(0xFF0A0E1A); // 🛡️ Kurumsal Gece Mavisi

  // ── 🛡️ ESKİ KODLARIN ÇÖKMESİNİ ENGELLEYEN KÖPRÜLER (ZAFİYET KAPATICILAR) ──
  // responsive_kalkan.dart "decoration" beklediği için bunu BoxDecoration yaptık!
  // 💎 KURUMSAL SEDEF KAPLAMA (Fildişi Sedef Parlaması)
  static BoxDecoration get siberArkaPlan => BoxDecoration(
    gradient: RadialGradient(
      center: const Alignment(-0.5, -0.6), // Sol üstten vuran sedef parlaması
      radius: 1.5,
      colors: [
        const Color(0xFFFFFFFF), // Parlak Bembeyaz Işık Noktası
        const Color(0xFFF8FAFC), // Sedefli Açık Mavi/Beyaz Kırılma
        oledBlack, // Ana Fildişi Sedef Zemin (0xFFF4F6F8)
        const Color(0xFFE2E8F0), // Sedefin koyu gölge kırılması
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    ),
  );

  // 🏗️ 7D SİBER CAM EFEKTİ (GLASSMORPHISM) - Sadece Dekorasyon İsteyenler İçin
  static BoxDecoration siberCamZirh({Color? renk}) {
    return BoxDecoration(
      color: (renk ?? Colors.white).withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
    );
  }

  // 💎 SİBER KUTU ZIRHI (Premium Glassmorphism)
  static BoxDecoration get siberKutuZirhi => BoxDecoration(
    color: Colors.white.withValues(alpha: 0.05), // Hafif şeffaf iç dolgu
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.white.withValues(alpha: 0.1), // İnce kurumsal çerçeve
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.5),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // 🛡️ ESKİ EKRANLAR İÇİN WIDGET KÖPRÜSÜ (Child ve Padding hatalarını kökünden çözer!)
  static Widget siberCamKalkan({Widget? child, EdgeInsetsGeometry? padding, Color? renk}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: siberCamZirh(renk: renk),
      child: child,
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

  // 📡 SİBER METİN STİLLERİ (Hata vermemesi için Getter yapıldı)
  static TextStyle get kuantumBaslik => GoogleFonts.orbitron(
    color: kuantumCyan,
    fontSize: 22,
    fontWeight: FontWeight.w900,
    letterSpacing: 2,
  );

  // 📡 STANDART FONT SİSTEMİ
  static ThemeData kuantumTemasi() {
    return ThemeData(
      scaffoldBackgroundColor: oledBlack,
      primaryColor: kuantumCyan,
      fontFamily: 'Avenir',
    );
  }

  // 🛡️ SİBER INPUT DECORATOR (Diğer dosyalardaki altı kırmızı çizen siberInputDecor hatasını çözer)
  static InputDecoration siberInputDecor(String hint, IconData icon) {
    return InputDecoration(
      labelText: hint,
      labelStyle: TextStyle(color: kuantumCyan.withOpacity(0.5), fontSize: 12, fontFamily: 'Avenir'),
      prefixIcon: Icon(icon, color: kuantumCyan, size: 20),
      filled: true,
      fillColor: Colors.black,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kuantumCyan, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}