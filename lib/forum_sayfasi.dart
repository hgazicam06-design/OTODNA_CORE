// lib/screens/forum_sayfasi.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM CLUB VE SİBER FORUM PANELİ (SiberForumSayfasi)
/// Firebase'den anlık rol okur, sivil (maket) rolleri engeller ve sadece Baskan/Yardimci'ya Admin kalkanını açar.
class SiberForumSayfasi extends StatelessWidget {
  final String kullaniciId; // Firebase Auth'tan Karargaha bağlanan UID

  const SiberForumSayfasi({super.key, required this.kullaniciId});

  // ── 🎨 KARARGAH TASARIM DOKTRİNİ ──
  static const Color _oledBlack = Color(0xFF000000);
  static const Color _matGrey = Color(0xFF111111);
  static const Color _kuantumCyan = Color(0xFF00FFC2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _oledBlack,
      appBar: AppBar(
        title: const Text("OTODNA SİBER CLUB", style: TextStyle(color: _kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kuantumCyan),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        // SİBER NOT: Gerçek veritabanındaki kullanıcı belgesi dinleniyor
        stream: FirebaseFirestore.instance.collection('kullanicilar').doc(kullaniciId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _kuantumCyan));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("SİBER İHLAL: Kullanıcı verisi Karargahta bulunamadı.", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)));
          }

          // Kuantum Veri Çözümlemesi
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          String currentUserRole = userData['kulup_rolu'] ?? "Uye"; // Baskan, Yardimci veya Uye

          bool isAdmin = (currentUserRole == "Baskan" || currentUserRole == "Yardimci");

          return Column(
            children: [
              // 1. Genel Kulüp İletişim Alanı
              _buildGenelKulupAlani(currentUserRole),

              const Spacer(),

              // 2. KRİTİK ZIRH: Sadece Başkan ve Yardımcıya Açılan Karargah Kontrol Paneli
              if (isAdmin)
                _buildAdminAraclari(context, currentUserRole),
            ],
          );
        },
      ),
    );
  }

  // ── 🛡️ ARAYÜZ MOTORLARI ──

  Widget _buildGenelKulupAlani(String rol) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _matGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: _kuantumCyan, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("SİBER AĞA HOŞ GELDİNİZ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                const SizedBox(height: 4),
                Text("AKTİF RÜTBE: ${rol.toUpperCase()}", style: const TextStyle(color: _kuantumCyan, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
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
        color: Colors.redAccent.withOpacity(0.05), // Kan Kırmızısı Zemin
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent.withOpacity(0.5), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.admin_panel_settings, color: Colors.redAccent, size: 28),
              const SizedBox(width: 12),
              Text("KARARGAH YÖNETİM MERKEZİ ($rol)", style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12)),
            ],
          ),
          const Divider(color: Colors.white24, height: 24),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.heavyImpact(); // Kritik yetki titreşimi
                developer.log("🚨 YETKİLİ İŞLEMİ: $rol tarafından admin araçları tetiklendi!");
                // Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminYetkiPaneli()));
              },
              icon: const Icon(Icons.gavel, color: Colors.white),
              label: const Text("SİBER YETKİLERİ KULLAN", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 10,
                shadowColor: Colors.redAccent.withOpacity(0.5),
              ),
            ),
          )
        ],
      ),
    );
  }
}