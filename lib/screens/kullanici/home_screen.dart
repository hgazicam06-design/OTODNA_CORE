// lib/screens/kullanici/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

import '../../../../core/responsive_kalkan.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🏢 PLAZA KALİTESİ PALET
    final Color primaryTeal = Colors.teal.shade700;
    const Color bgColor = Color(0xFFFAFAFC);
    const Color textColor = Color(0xFF1E293B);
    const Color dangerColor = Colors.redAccent;
    const Color premiumGold = Color(0xFFD4AF37);

    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
          title: Text(
            "O T O D N A   P L A Z A",
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              fontSize: 13,
              fontFamily: 'Avenir'
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.power_settings_new_rounded, color: dangerColor, size: 22),
              onPressed: () async {
                HapticFeedback.heavyImpact();
                developer.log("OTURUM KAPATMA: Plaza terminal bağlantısı kesiliyor...");
                await FirebaseAuth.instance.signOut();
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🏢 PLAZA KARŞILAMA KARTI
                _buildPlazaKarsilama(primaryTeal, textColor),

                const SizedBox(height: 40),

                const Text(
                  "HIZLI ERİŞİM PROTOKOLLERİ",
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    fontFamily: 'Avenir'
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
                        primaryTeal,
                        textColor,
                            () {
                          HapticFeedback.lightImpact();
                          developer.log("SİBER ROTA: Araçlarım paneline geçiş yapılıyor.");
                        }
                    ),
                    _buildMenuKart(
                        "DNA SORGULA",
                        Icons.qr_code_scanner_rounded,
                        premiumGold,
                        textColor,
                            () {
                          HapticFeedback.lightImpact();
                          developer.log("SİBER ROTA: DNA Sorgulama motoru tetiklendi.");
                        }
                    ),
                    _buildMenuKart(
                        "RANDEVULAR",
                        Icons.calendar_today_rounded,
                        Colors.blueAccent.shade700,
                        textColor,
                            () {
                          HapticFeedback.lightImpact();
                        }
                    ),
                    _buildMenuKart(
                        "MÜŞTERİ DESTEK",
                        Icons.support_agent_rounded,
                        Colors.purple.shade600,
                        textColor,
                            () {
                          HapticFeedback.lightImpact();
                        }
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // 📡 SİSTEM DURUM RADARI
                _buildSistemDurum(primaryTeal),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlazaKarsilama(Color primaryTeal, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 8))
        ]
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryTeal.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.shield_rounded, color: primaryTeal, size: 36),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "HOŞ GELDİNİZ",
                  style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir'),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: primaryTeal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    "OtoDNA Plaza Ağına Bağlısınız",
                    style: TextStyle(color: primaryTeal, fontSize: 10, fontWeight: FontWeight.w900, fontFamily: 'Avenir'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuKart(String baslik, IconData ikon, Color ikonRenk, Color textColor, VoidCallback onTapped) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTapped,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
            ]
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: ikonRenk.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(ikon, color: ikonRenk, size: 32)
              ),
              const SizedBox(height: 16),
              Text(
                baslik,
                style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSistemDurum(Color primaryTeal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.radar, color: Colors.green, size: 16),
          SizedBox(width: 8),
          Text(
            "SİSTEM ÇALIŞMA SÜRESİ: %99.9  |  PLAZA AĞI AKTİF",
            style: TextStyle(color: Colors.black54, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir'),
          ),
        ],
      ),
    );
  }
}