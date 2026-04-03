import 'package:flutter/material.dart';

class SiberSasi extends StatelessWidget {
  final Widget mobile; // Telefonlar için
  final Widget tablet; // Araç İçi Double Teyp & Tabletler için (Yatay Büyük Ekran)
  final Widget desktop; // Karargah Merkez (Bilgisayar / Web) için

  const SiberSasi({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

  // 🚀 RADAR: Cihazın boyutunu anında tespit eden Kuantum Sensörleri
  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 650;
  static bool isTablet(BuildContext context) => MediaQuery.of(context).size.width >= 650 && MediaQuery.of(context).size.width < 1100;
  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1100) {
          // Genişlik 1100 pikselden büyükse -> BİLGİSAYAR WEB EKRANI
          return desktop;
        } else if (constraints.maxWidth >= 650) {
          // Genişlik 650 - 1100 piksel arasıysa -> ARAÇ İÇİ DOUBLE TEYP VEYA TABLET
          return tablet;
        } else {
          // Genişlik 650 pikselden küçükse -> AKILLI TELEFON
          return mobile;
        }
      },
    );
  }
}