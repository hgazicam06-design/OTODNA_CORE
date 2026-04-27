// lib/screens/kullanici/forum_sayfasi.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

import '../../core/responsive_kalkan.dart';

/// 🏢 OTODNA PLAZA CLUB PANELİ
class SiberForumSayfasi extends StatelessWidget {
  final String kullaniciId;

  const SiberForumSayfasi({super.key, required this.kullaniciId});

  @override
  Widget build(BuildContext context) {
    // 🏢 PLAZA KALİTESİ PALET
    final Color primaryTeal = Colors.teal.shade700;
    const Color bgColor = Color(0xFFFAFAFC);
    const Color textColor = Color(0xFF1E293B);
    const Color dangerColor = Colors.redAccent;

    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text("OTODNA PLAZA CLUB", style: TextStyle(color: textColor, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14, fontFamily: 'Avenir')),
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
          iconTheme: IconThemeData(color: primaryTeal),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('kullanicilar').doc(kullaniciId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: primaryTeal));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text("SİSTEM UYARISI: Kullanıcı verisi bulunamadı.", style: TextStyle(color: dangerColor, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')));
            }

            var userData = snapshot.data!.data() as Map<String, dynamic>;
            String currentUserRole = userData['kulup_rolu'] ?? "Üye";

            bool isAdmin = (currentUserRole == "Baskan" || currentUserRole == "Yardimci");

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildGenelKulupAlani(currentUserRole, primaryTeal, textColor),
                  const Spacer(),
                  if (isAdmin)
                    _buildAdminAraclari(context, currentUserRole, dangerColor, textColor),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGenelKulupAlani(String rol, Color primaryTeal, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: primaryTeal.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.shield_outlined, color: primaryTeal, size: 40),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("PLAZA AĞINA HOŞ GELDİNİZ", style: TextStyle(color: textColor, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: primaryTeal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text("AKTİF RÜTBE: ${rol.toUpperCase()}", style: TextStyle(color: primaryTeal, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminAraclari(BuildContext context, String rol, Color dangerColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dangerColor.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [BoxShadow(color: dangerColor.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: dangerColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(Icons.admin_panel_settings, color: dangerColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("MERKEZ YÖNETİM", style: TextStyle(color: dangerColor, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13, fontFamily: 'Avenir')),
                    Text("Yetki Seviyesi: $rol", style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 10, fontFamily: 'Avenir')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.heavyImpact();
                developer.log("🚨 YETKİLİ İŞLEMİ: $rol tarafından admin araçları tetiklendi!");
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Yönetim Terminali Başlatılıyor...'), backgroundColor: dangerColor));
              },
              icon: const Icon(Icons.gavel),
              label: const Text("YÖNETİM YETKİLERİNİ KULLAN", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
              style: ElevatedButton.styleFrom(
                backgroundColor: dangerColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          )
        ],
      ),
    );
  }
}