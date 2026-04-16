// lib/screens/kullanici/forum_sayfasi.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI VE MERKEZİ TEMA BAĞLANTISI (Yollar 2 kat yukarı çıkacak şekilde ayarlandı)
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

/// 🛡️ KUANTUM CLUB VE SİBER FORUM PANELİ (SiberForumSayfasi)
class SiberForumSayfasi extends StatelessWidget {
  final String kullaniciId;

  const SiberForumSayfasi({super.key, required this.kullaniciId});

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("OTODNA SİBER CLUB", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: SiberTema.kuantumCyan),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('kullanicilar').doc(kullaniciId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text("SİBER İHLAL: Kullanıcı verisi Karargahta bulunamadı.", style: TextStyle(color: SiberTema.kanKirmizi, fontWeight: FontWeight.w900, letterSpacing: 1.5)));
            }

            var userData = snapshot.data!.data() as Map<String, dynamic>;
            String currentUserRole = userData['kulup_rolu'] ?? "Uye";

            bool isAdmin = (currentUserRole == "Baskan" || currentUserRole == "Yardimci");

            return Column(
              children: [
                _buildGenelKulupAlani(currentUserRole),
                const Spacer(),
                if (isAdmin)
                  _buildAdminAraclari(context, currentUserRole),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGenelKulupAlani(String rol) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SiberTema.matGrey.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: SiberTema.kuantumCyan, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("SİBER AĞA HOŞ GELDİNİZ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                const SizedBox(height: 4),
                Text("AKTİF RÜTBE: ${rol.toUpperCase()}", style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminAraclari(BuildContext context, String rol) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SiberTema.kanKirmizi.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SiberTema.kanKirmizi.withOpacity(0.5), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.admin_panel_settings, color: SiberTema.kanKirmizi, size: 28),
              const SizedBox(width: 12),
              Text("KARARGAH YÖNETİM MERKEZİ ($rol)", style: const TextStyle(color: SiberTema.kanKirmizi, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12)),
            ],
          ),
          const Divider(color: Colors.white24, height: 24),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.heavyImpact();
                developer.log("🚨 YETKİLİ İŞLEMİ: $rol tarafından admin araçları tetiklendi!");
              },
              icon: const Icon(Icons.gavel, color: Colors.white),
              label: const Text("SİBER YETKİLERİ KULLAN", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              style: ElevatedButton.styleFrom(
                backgroundColor: SiberTema.kanKirmizi,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 10,
                shadowColor: SiberTema.kanKirmizi.withOpacity(0.5),
              ),
            ),
          )
        ],
      ),
    );
  }
}