import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import '../core/responsive_kalkan.dart';

// Yeni Plaza Kalitesi Ekranlarımız (Yerlerine Bağlandı)
import 'kullanici/arac_kayit_screen.dart';
import 'kullanici/dijital_servis_screen.dart';
import 'kullanici/canli_radar_screen.dart';
import 'kullanici/ariza_bildirim_screen.dart';
import 'kullanici/dijital_lpg_ruhsati_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    // 🏢 PLAZA KALİTESİ PALET
    final primaryTeal = Colors.teal.shade700;
    const bgColor = Color(0xFFFAFAFC);
    const textColor = Color(0xFF1E293B);

    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
          title: Text("PLAZA YÖNETİM MERKEZİ",
              style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 3, fontFamily: 'Avenir')),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.power_settings_new, color: Colors.redAccent),
              onPressed: () => FirebaseAuth.instance.signOut(),
              tooltip: "Sistemden Çıkış Yap",
            )
          ],
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('kullanicilar').doc(user?.uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: primaryTeal));
            }

            var data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
            String eposta = (data['eposta'] ?? 'V.I.P MÜŞTERİ').toString().toUpperCase();

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🛡️ KİMLİK KARTI (Plaza Kalitesi)
                  _buildKimlikKarti(eposta, primaryTeal, textColor),
                  
                  const SizedBox(height: 32),
                  
                  Text("HIZLI ERİŞİM", style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 1)),
                  const SizedBox(height: 16),

                  // 📡 TERMİNALLER (GRID YAPISI İLE ŞIK DİZİLİM)
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _buildGridButon(
                        context, "Dijital Garaj", Icons.directions_car_filled_rounded, primaryTeal, textColor,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AracKayitScreen()))
                      ),
                      _buildGridButon(
                        context, "Servis & Bakım", Icons.build_circle_outlined, primaryTeal, textColor,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DijitalServisScreen()))
                      ),
                      _buildGridButon(
                        context, "Kalıcı Mühür", Icons.verified_user_outlined, primaryTeal, textColor,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ArizaBildirimScreen()))
                      ),
                      _buildGridButon(
                        context, "Küresel Pazar", Icons.language_rounded, primaryTeal, textColor,
                        onTap: () => context.push('/market')
                      ),
                      _buildGridButon(
                        context, "Dijital Ruhsat", Icons.assignment_turned_in_outlined, primaryTeal, textColor,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DijitalLpgRuhsatiScreen()))
                      ),
                      _buildGridButon(
                        context, "Canlı Radar", Icons.emergency_share, Colors.redAccent, textColor,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CanliRadarScreen()))
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  // 🔐 GÜVENLİK DURUMU
                  Center(child: _buildGuvenlikRadari(primaryTeal)),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildKimlikKarti(String eposta, Color primaryTeal, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))]
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: primaryTeal.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.shield_outlined, color: primaryTeal, size: 48),
          ),
          const SizedBox(height: 24),
          const Text("SİSTEME HOŞ GELDİNİZ",
              style: TextStyle(color: Colors.black54, fontSize: 10, letterSpacing: 3, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
          const SizedBox(height: 8),
          Text(eposta,
              style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
        ],
      ),
    );
  }

  Widget _buildGridButon(BuildContext context, String baslik, IconData ikon, Color renk, Color textColor, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 5))]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: renk.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(ikon, color: renk, size: 32),
            ),
            const SizedBox(height: 16),
            Text(baslik, style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 12, fontFamily: 'Avenir')),
          ],
        ),
      ),
    );
  }

  Widget _buildGuvenlikRadari(Color primaryTeal) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)]
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: primaryTeal, shape: BoxShape.circle, boxShadow: [BoxShadow(color: primaryTeal.withValues(alpha: 0.5), blurRadius: 8)]),
          ),
          const SizedBox(width: 12),
          Text("AĞ BAĞLANTISI: GÜVENLİ",
              style: TextStyle(color: primaryTeal, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
        ],
      ),
    );
  }
}