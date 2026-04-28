// lib/core/siber_sasi.dart
import 'package:flutter/material.dart';

/// 🏗️ SİBER ŞASİ: Cihazın ekran boyutuna göre formu değiştiren adaptif zırh.
/// Mobil, Tablet (Araç İçi Terminal) ve Desktop (Karargah) arasında
/// kesintisiz geçiş sağlar.
class SiberSasi extends StatelessWidget {
  final Widget mobile; // Akıllı Telefonlar için
  final Widget tablet; // Araç İçi Double Teyp & Tabletler için
  final Widget desktop; // Karargah Merkez (Bilgisayar / Web) için

  SiberSasi({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

  // 🚀 RADAR: Ekran boyutunu anlık analiz eden Kuantum Sensörleri
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650 &&
          MediaQuery.of(context).size.width < 1100;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1100) {
          // 🖥️ BİLGİSAYAR / WEB: Karargah yönetim ekranı
          return desktop;
        } else if (constraints.maxWidth >= 650) {
          // 📟 TABLET / DOUBLE TEYP: Araç içi operasyon terminali
          return tablet;
        } else {
          // 📱 AKILLI TELEFON: Sahadaki personelin hızlı erişim cihazı
          return mobile;
        }
      },
    );
  }
}