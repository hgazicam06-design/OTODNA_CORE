import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/siber_tema.dart';
import 'core/responsive_kalkan.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent, // Zırhın arkasını görmeliyiz
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            "S İ V İ L   T E R M İ N A L",
            style: TextStyle(
              color: SiberTema.kuantumCyan,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              fontSize: 14,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.power_settings_new_rounded, color: SiberTema.kanKirmizi),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🚀 SİBER KARŞILAMA KARTI
                _buildSiberKarsilama(),

                const SizedBox(height: 30),

                const Text(
                  "HIZLI ERİŞİM PROTOKOLLERİ",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),

                // 🛡️ MODÜLER MENÜ GRİDİ
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildMenuKart(
                      "ARAÇLARIM",
                      Icons.directions_car_filled_rounded,
                      SiberTema.kuantumCyan,
                    ),
                    _buildMenuKart(
                      "DNA SORGULA",
                      Icons.qr_code_scanner_rounded,
                      SiberTema.altinSari,
                    ),
                    _buildMenuKart(
                      "RANDEVULAR",
                      Icons.calendar_today_rounded,
                      Colors.blueAccent,
                    ),
                    _buildMenuKart(
                      "SİBER DESTEK",
                      Icons.support_agent_rounded,
                      Colors.purpleAccent,
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // 📡 SİSTEM DURUM RADARI
                _buildSistemDurum(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSiberKarsilama() {
    return SiberTema.siberCamKalkan(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SiberTema.kuantumCyan.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3)),
            ),
            child: const Icon(Icons.shield_rounded, color: SiberTema.kuantumCyan, size: 32),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "HOŞ GELDİNİZ",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
                Text(
                  "Kuantum Ağına Bağlısınız ✅",
                  style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuKart(String baslik, IconData ikon, Color renk) {
    return SiberTema.siberCamKalkan(
      child: InkWell(
        onTap: () {}, // TODO: Sayfa yönlendirmeleri eklenecek
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(ikon, color: renk, size: 36),
            const SizedBox(height: 12),
            Text(
              baslik,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSistemDurum() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.radar, color: Colors.greenAccent, size: 14),
          SizedBox(width: 8),
          Text(
            "SİSTEM ÇALIŞMA SÜRESİ: 99.9% | GLOBAL AĞ AKTİF",
            style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}