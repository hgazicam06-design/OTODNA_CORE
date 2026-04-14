// lib/admin_merkez.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

// 🚨 KARARGAH ZIRHLARI VE TEMASI
import 'package:otodna/core/responsive_kalkan.dart';
// import 'package:otodna/core/siber_tema.dart'; // Sizin projenizdeki tema dosyanız

class AdminMerkezScreen extends StatefulWidget {
  const AdminMerkezScreen({super.key});

  @override
  State<AdminMerkezScreen> createState() => _AdminMerkezScreenState();
}

class _AdminMerkezScreenState extends State<AdminMerkezScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _cikisYapiliyor = false;

  // Siber Renk Paleti
  static const Color _oledBlack = Color(0xFF000000);
  static const Color _matGrey = Color(0xFF111111);
  static const Color _kuantumCyan = Color(0xFF00FFC2);
  static const Color _alertRed = Color(0xFFFF4D4D);

  // ── 🔒 SİBER ÇIKIŞ PROTOKOLÜ (LOGLAMALI) ──
  Future<void> _guvenliAgaVeda() async {
    setState(() => _cikisYapiliyor = true);
    developer.log("🚨 SİBER KOMUTA: Karargahtan çıkış protokolü başlatıldı.");

    try {
      // 1. Çıkışı Kara Kutuya Mühürle
      await _db.collection('sistem_loglari').add({
        'islem_turu': 'ADMIN_CIKIS',
        'islem_detayi': 'SİBER HAREKAT: Yüksek Yetkili (Komutan) sistemden güvenli çıkış yaptı.',
        'kullanici_id': FirebaseAuth.instance.currentUser?.uid ?? 'BILINMEYEN_KOMUTAN',
        'tarih': FieldValue.serverTimestamp(),
      });

      // 2. Kuantum Ağ Bağlantısını Kes
      await FirebaseAuth.instance.signOut();
      developer.log("✅ ONAY: Çıkış yapıldı ve Kara Kutuya işlendi.");

      // Çıkış yapıldığında AuthGate otomatik olarak Login ekranına atacaktır.
    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Çıkış yapılamadı!", error: e);
      if (mounted) setState(() => _cikisYapiliyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
              "SİBER KOMUTA MERKEZİ",
              style: TextStyle(color: _alertRed, fontWeight: FontWeight.w900, letterSpacing: 2)
          ),
          centerTitle: true,
          actions: [
            if (_cikisYapiliyor)
              const Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: _alertRed, strokeWidth: 2))),
              )
            else
              IconButton(
                icon: const Icon(Icons.power_settings_new, color: _alertRed),
                onPressed: _guvenliAgaVeda,
                tooltip: "Karargahtan Çık",
              )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 🛡️ İSTİHBARAT ÖZETİ (HEADER) ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _alertRed.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _alertRed.withOpacity(0.3), width: 1.5),
                  boxShadow: [BoxShadow(color: _alertRed.withOpacity(0.1), blurRadius: 20)],
                ),
                child: const Column(
                  children: [
                    Icon(Icons.admin_panel_settings, color: _alertRed, size: 60),
                    SizedBox(height: 16),
                    Text("BÜTÜN YETKİLER SİZDE KOMUTANIM", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    SizedBox(height: 4),
                    Text("SİSTEM ÇEVRİMİÇİ | MERKEZ: ANKARA HQ", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              const Text("AKTİF CEPHELER", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
              const SizedBox(height: 16),

              // ── 🚀 KUANTUM GEÇİTLERİ (YÖNLENDİRME MENÜSÜ) ──
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildSiberGecit(
                        baslik: "GLOBAL SİBER AĞ",
                        detay: "Ülke ve bölge distribütörlüklerini yönetin.",
                        ikon: Icons.radar,
                        renk: _kuantumCyan,
                        onTap: () {
                          // Navigator.pushNamed(context, '/admin_global_panel');
                          developer.log("GEÇİŞ: Global Siber Ağ");
                        }
                    ),
                    _buildSiberGecit(
                        baslik: "YÜKSEK KONSEY TERMİNALİ",
                        detay: "Finansal onaylar, hakem kararları ve Blacklist.",
                        ikon: Icons.gavel_rounded,
                        renk: Colors.amberAccent,
                        onTap: () {
                          // Navigator.pushNamed(context, '/super_admin_dashboard');
                          developer.log("GEÇİŞ: Yüksek Konsey");
                        }
                    ),
                    _buildSiberGecit(
                        baslik: "KARA KUTU (SİSTEM LOGLARI)",
                        detay: "Ağdaki her atomik işlemi anlık takip edin.",
                        ikon: Icons.terminal,
                        renk: Colors.white,
                        onTap: () {
                          // Navigator.pushNamed(context, '/kara_kutu_loglari');
                          developer.log("GEÇİŞ: Kara Kutu");
                        }
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 🔧 ARAYÜZ YARDIMCISI: SİBER BUTON ──
  Widget _buildSiberGecit({required String baslik, required String detay, required IconData ikon, required Color renk, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _matGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: renk.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: renk.withOpacity(0.5))),
          child: Icon(ikon, color: renk, size: 24),
        ),
        title: Text(baslik, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(detay, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white24),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        splashColor: renk.withOpacity(0.1),
      ),
    );
  }
}