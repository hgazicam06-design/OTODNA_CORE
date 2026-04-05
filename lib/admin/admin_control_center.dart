import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

// 🔥 SİBER KÖPRÜLER
import 'admin_onay_havuzu_screen.dart';
import 'admin_dash_ui.dart';
import '../screens/bayi_itibar_merkezi_screen.dart';
import '../screens/bayi_yonetim_merkezi_screen.dart';
import '../screens/bolge_komuta_merkezi_screen.dart';
import '../screens/mega_revizyon_screen.dart';
import '../screens/bayi_paneli.dart';
import '../screens/kullanici_yonetim_screen.dart';
import '../screens/bayi_ekosistemi_screen.dart';

class AdminControlCenter extends StatelessWidget {
  const AdminControlCenter({super.key});

  Future<void> _siberCikisYap() async {
    await FirebaseAuth.instance.signOut();
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
          title: Text("OTODNA MERKEZ KARARGAHI", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1.5, fontFamily: 'Avenir')),
          centerTitle: true,
          actions: [IconButton(icon: const Icon(Icons.power_settings_new, color: SiberTema.kanKirmizi), onPressed: _siberCikisYap, tooltip: "Ağdan Çıkış Yap")],
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            _buildPanelBaslik("SİBER FİNANS (KARARGAH)"),
            const SizedBox(height: 12),
            _canliFinansRadari(),
            const SizedBox(height: 30),

            _buildPanelBaslik("SİSTEM KONTROL MODÜLLERİ"),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.85,
              children: [
                _buildSiberMenuKarti(context, "BÖLGE\nRADARI", Icons.radar, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BolgeKomutaMerkeziScreen()))),
                _buildSiberMenuKarti(context, "BAYİ\nAĞI", Icons.add_business, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BayiYonetimMerkeziScreen()))),
                _buildSiberMenuKarti(context, "İTİBAR\nSİCİL", Icons.shield, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BayiItibarMerkeziScreen()))),
                _buildSiberMenuKarti(context, "BAYİ\nKOKPİTİ", Icons.store_mall_directory, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BayiPaneliScreen(bayiId: "TEST_BAYI_001")))),
                _buildSiberMenuKarti(context, "KULLANICI\nYETKİ", Icons.people_alt, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KullaniciYonetimScreen()))),
                _buildSiberMenuKarti(context, "ONAY\nHAVUZU", Icons.verified_user, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminOnayHavuzuScreen()))),
                // ✅ HATA ÇÖZÜLDÜ: MegaRevizyonScreen plaka parametresi alıyor!
                _buildSiberMenuKarti(context, "MEGA\nREVİZYON", Icons.build_circle, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MegaRevizyonScreen(plaka: "KARARGAH-GİRİŞİ")))),
                _buildSiberMenuKarti(context, "EKSPERTİZ\nDNA", Icons.fact_check, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BayiEkosistemiScreen()))),
                _buildSiberMenuKarti(context, "KASA\n& SOS", Icons.dashboard_customize, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashUI()))),
              ],
            ),
            const SizedBox(height: 30),

            _buildPanelBaslik("CANLI AĞ HAREKETLERİ"),
            const SizedBox(height: 12),
            Container(
              height: 220,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [SiberTema.oledBlack, SiberTema.matGrey.withOpacity(0.5)]), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5), boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.05), blurRadius: 15, spreadRadius: -2, offset: const Offset(0, 5))]),
              child: _canliHareketListesi(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelBaslik(String baslik) {
    return Row(
      children: [
        const Icon(Icons.memory, color: SiberTema.kuantumCyan, size: 18),
        const SizedBox(width: 8),
        Text(baslik, style: TextStyle(color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w800, letterSpacing: 1.5, fontSize: 12, fontFamily: 'Avenir')),
      ],
    );
  }

  Widget _buildSiberMenuKarti(BuildContext context, String baslik, IconData ikon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [SiberTema.matGrey.withOpacity(0.8), SiberTema.oledBlack]), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.1), width: 1), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 10, spreadRadius: 1, offset: const Offset(0, 5))]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.05), shape: BoxShape.circle, border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.2))), child: Icon(ikon, color: SiberTema.kuantumCyan, size: 24)),
            const SizedBox(height: 12),
            Text(baslik, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.0, fontFamily: 'Avenir')),
          ],
        ),
      ),
    );
  }

  Widget _canliFinansRadari() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('islem_kayitlari').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return _buildKuantumLoader();
        final islemler = snapshot.data?.docs ?? [];
        double siberKomutanPayi = 0;
        for (var islem in islemler) {
          final data = islem.data() as Map<String, dynamic>;
          siberKomutanPayi += (data['komutan_payi'] ?? 0).toDouble();
        }
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [SiberTema.oledBlack, SiberTema.matGrey.withOpacity(0.5)]), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("NET KARARGAH PAYI (%12)", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                  const SizedBox(height: 8),
                  Text("₺${siberKomutanPayi.toStringAsFixed(2)}", style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 26, fontWeight: FontWeight.w900, fontFamily: 'Avenir', shadows: [Shadow(color: SiberTema.kuantumCyan, blurRadius: 10)])),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _canliHareketListesi() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('sistem_loglari').orderBy('tarih', descending: true).limit(20).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return _buildKuantumLoader();
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return Center(child: Text("Radar Temiz.", style: TextStyle(color: Colors.white.withOpacity(0.4), fontFamily: 'Avenir', fontWeight: FontWeight.bold)));
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            String bayi = data['bayi_isim'] ?? 'Sistem Merkezi';
            String islem = data['islem_detayi'] ?? 'Bilinmeyen İşlem';
            String tur = data['islem_turu'] ?? 'bilgi';

            IconData icon = Icons.info_outline;
            Color renk = Colors.white54;
            if (tur == 'basarili') { icon = Icons.security; renk = SiberTema.kuantumCyan; }
            else if (tur == 'hata') { icon = Icons.warning_amber_rounded; renk = SiberTema.kanKirmizi; }
            else if (tur == 'sos') { icon = Icons.radar; renk = SiberTema.altinSari; }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: renk.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: renk.withOpacity(0.3))), child: Icon(icon, color: renk, size: 18)),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(bayi, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w900, fontFamily: 'Avenir')), const SizedBox(height: 4), Text(islem, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, fontFamily: 'Avenir'))])),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildKuantumLoader() => const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan, strokeWidth: 3));
}