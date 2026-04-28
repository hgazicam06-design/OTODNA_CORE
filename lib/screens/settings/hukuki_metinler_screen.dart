import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:otodna/core/siber_tema.dart';
import 'package:otodna/core/responsive_kalkan.dart';

/// ⚖️ SİBER HUKUK TERMİNALİ (Hukuki Metinler ve Sözleşmeler)
class HukukiMetinlerScreen extends StatelessWidget {
  const HukukiMetinlerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.pop();
            },
          ),
          title: Text(
            "YASAL SÖZLEŞMELER",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              fontFamily: 'Avenir',
              letterSpacing: 2.0,
            ),
          ),
          centerTitle: true,
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            _buildSozlesmeKarti(
              context,
              baslik: "Kullanım Koşulları",
              tarih: "Güncellenme: 01.05.2026",
              icon: Icons.description_outlined,
            ),
            _buildSozlesmeKarti(
              context,
              baslik: "Gizlilik Politikası",
              tarih: "Güncellenme: 01.05.2026",
              icon: Icons.privacy_tip_outlined,
            ),
            _buildSozlesmeKarti(
              context,
              baslik: "KVKK Aydınlatma Metni",
              tarih: "Güncellenme: 01.05.2026",
              icon: Icons.policy_outlined,
            ),
            _buildSozlesmeKarti(
              context,
              baslik: "Mesafeli Satış Sözleşmesi",
              tarih: "OtoMarket İşlemleri İçin Geçerli",
              icon: Icons.shopping_bag_outlined,
            ),
            _buildSozlesmeKarti(
              context,
              baslik: "Siber İade Şartları",
              tarih: "Garanti ve İade Protokolü",
              icon: Icons.autorenew,
            ),
            
            const SizedBox(height: 40),
            Icon(Icons.gavel, color: Colors.white12, size: 50),
            const SizedBox(height: 16),
            Text(
              "Bu platformda gerçekleştirilen tüm eylemler OtoDNA Kuantum Ağı Hukuk Motoru tarafından korunmaktadır.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white30, fontSize: 10, letterSpacing: 1.5, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSozlesmeKarti(BuildContext context, {required String baslik, required String tarih, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: SiberTema.siberKutuZirhi,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Icon(icon, color: SiberTema.kuantumCyan, size: 28),
        title: Text(
          baslik,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(
            tarih,
            style: const TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1.0),
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
        onTap: () {
          HapticFeedback.lightImpact();
          // Gelecekte her sözleşmenin kendi PDF/Metin detayı açılabilir.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("$baslik yükleniyor..."),
              backgroundColor: SiberTema.oledBlack,
            ),
          );
        },
      ),
    );
  }
}
