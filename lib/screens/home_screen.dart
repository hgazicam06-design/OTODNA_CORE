import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return ResponsiveKalkan(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("S İ V İ L   K A R A R G A H",
              style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 4, fontFamily: 'monospace')),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.power_settings_new, color: SiberTema.kanKirmizi),
              onPressed: () => FirebaseAuth.instance.signOut(),
              tooltip: "Ağdan Çıkış Yap",
            )
          ],
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('kullanicilar').doc(user?.uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
            }

            var data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
            String eposta = (data['eposta'] ?? 'Siber Sürücü').toString().toUpperCase();

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🛡️ SİBER KİMLİK ÜNİTESİ
                  _buildSiberKimlik(eposta),

                  const SizedBox(height: 48),

                  // 📡 HIZLI ERİŞİM TERMİNALLERİ
                  _buildTerminalButon(
                      context,
                      "DİJİTAL GARAJ",
                      Icons.directions_car_filled_rounded,
                          () => Navigator.pushNamed(context, '/garaj')
                  ),
                  const SizedBox(height: 16),
                  _buildTerminalButon(
                      context,
                      "KÜRESEL PAZAR",
                      Icons.language_rounded,
                          () => Navigator.pushNamed(context, '/pazar')
                  ),
                  const SizedBox(height: 16),
                  _buildTerminalButon(
                      context,
                      "ACİL DURUM (SOS)",
                      Icons.emergency_share,
                          () => Navigator.pushNamed(context, '/sos'),
                      isCritical: true
                  ),

                  const SizedBox(height: 48),

                  // 🔐 GÜVENLİK DURUMU
                  _buildGuvenlikRadari(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSiberKimlik(String eposta) {
    return Column(
      children: [
        const Icon(Icons.shield_outlined, color: SiberTema.kuantumCyan, size: 80),
        const SizedBox(height: 24),
        const Text("SİSTEME HOŞ GELDİNİZ",
            style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 3, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(eposta,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'monospace')),
      ],
    );
  }

  Widget _buildTerminalButon(BuildContext context, String baslik, IconData ikon, VoidCallback onTap, {bool isCritical = false}) {
    return SiberTema.siberCamKalkan(
      padding: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: Icon(ikon, color: isCritical ? SiberTema.kanKirmizi : SiberTema.kuantumCyan),
        title: Text(baslik,
            style: TextStyle(color: isCritical ? SiberTema.kanKirmizi : Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2)),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildGuvenlikRadari() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
          color: SiberTema.kuantumCyan.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.2))
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8, height: 8,
            decoration: const BoxDecoration(color: SiberTema.kuantumCyan, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          const Text("DURUM: AKTİF VE GÜVENDE",
              style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ],
      ),
    );
  }
}