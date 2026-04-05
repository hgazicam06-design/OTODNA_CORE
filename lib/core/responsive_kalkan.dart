import 'package:flutter/material.dart';

// 🔥 SİBER KÖPRÜ
import 'siber_tema.dart';

class ResponsiveKalkan extends StatelessWidget {
  final Widget child;
  final bool isOledBackground;

  const ResponsiveKalkan({
    super.key,
    required this.child,
    this.isOledBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Arka planı Container yönetecek
      body: Container(
        // 🔥 YENİ: Yorucu radar grid silindi, 3D Derinlik Gradienti eklendi!
        decoration: isOledBackground ? SiberTema.siberArkaPlan : null,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}