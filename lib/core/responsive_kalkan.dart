import 'package:otodna/core/siber_tema.dart';
// lib/core/responsive_kalkan.dart
import 'package:flutter/material.dart';

// 🔥 SİBER KÖPRÜ: Karargahın renk ve stil protokolleri
import 'siber_tema.dart';

/// 🛡️ RESPONSIVE KALKAN: OtoDNA Uygulamasının Evrensel Koruyucu Zırhı.
/// Bu widget, tüm sayfaları siber tema ile sarar ve ekran boyutuna göre
/// içeriği optimize ederek "Kuantum Uyumluluk" sağlar.
class ResponsiveKalkan extends StatelessWidget {
  final Widget child;
  final bool isOledBackground;

  ResponsiveKalkan({
    super.key,
    required this.child,
    this.isOledBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold arka planı şeffaf bırakıldı; derinlik Container tarafından yönetiliyor.
      backgroundColor: Colors.transparent,
      body: Container(
        // 🔥 STRATEJİK GÜNCELLEME: Tüm kurumsal ekranlara otomatik Sedef Kaplama uygula
        decoration: SiberTema.siberArkaPlan,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              // 📐 DİSİPLİN KURALI: Ekran ne kadar büyük olursa olsun,
              // içerik 600px genişliği aşarak görsel hiyerarşiyi bozamaz.
              constraints: BoxConstraints(maxWidth: 600),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}