import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

// 🔥 ROTALAR
import 'admin_onay_havuzu_screen.dart'; // 🟢 SİBER KÖPRÜ: Onay Havuzu Bağlandı!

class AdminControlCenter extends StatelessWidget {
  const AdminControlCenter({super.key});

  Future<void> _siberCikisYap() async {
    await FirebaseAuth.instance.signOut();
  }

  void _rotaUyari(BuildContext context, String modulAdi) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SiberTema.kuantumCyan,
        content: Text("$modulAdi BAĞLANTISI BEKLENİYOR...", style: const TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
          title: Text(
            "OTODNA MERKEZ KARARGAHI",
            style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                fontFamily: 'Avenir'
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.power_settings_new, color: SiberTema.kanKirmizi),
              onPressed: _siberCikisYap,
              tooltip: "Ağdan Çıkış Yap",
            )
          ],
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // ── 1. FİREBASE CANLI FİNANS MOTORU (%12 KESİNTİ İZLEME) ──
            _buildPanelBaslik("SİBER FİNANS (KARARGAH)"),
            const SizedBox(height: 12),
            _canliFinansRadari(),
            const SizedBox(height: 30),

            // ── 2. YÖNETİM VE YAPILANDIRMA MODÜLLERİ (3D GÖRSELLİ) ──
            _buildPanelBaslik("SİSTEM KONTROL MODÜLLERİ"),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
              children: [
                _buildSiberMenuKarti(
                  context,
                  "BAYİ PANELİ",
                  Icons.store_mall_directory,
                      () => _rotaUyari(context, "BAYİ PANELİ"),
                ),
                _buildSiberMenuKarti(
                  context,
                  "KULLANICI PANELİ",
                  Icons.people_alt,
                      () => _rotaUyari(context, "KULLANICI PANELİ"),
                ),
                _buildSiberMenuKarti(
                    context,
                    "SİSTEM AYARLARI",
                    Icons.settings_suggest,
                        () => _rotaUyari(context, "SİSTEM AYARLARI")
                ),
                _buildSiberMenuKarti(
                  context,
                  "YAPILANDIRMA",
                  Icons.architecture,
                  // 🟢 SİBER HAREKAT: Yapılandırma butonuna basınca Onay Havuzuna git!
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminOnayHavuzuScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // ── 3. CANLI AĞ HAREKETLERİ ──
            _buildPanelBaslik("CANLI AĞ HAREKETLERİ"),
            const SizedBox(height: 12),
            Container(
              height: 220,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // 3D İçeri Çökük (Emboss) Ekran Hissi
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [SiberTema.oledBlack, SiberTema.matGrey.withOpacity(0.5)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
                boxShadow: [
                  BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.05), blurRadius: 15, spreadRadius: -2, offset: const Offset(0, 5)),
                ],
              ),
              child: _canliHareketListesi(),
            ),
            const SizedBox(height: 40),

            // ── 4. 3D ACİL DURUM (SOS) MERKEZİ BUTONU ──
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.white),
                        SizedBox(width: 12),
                        Expanded(child: Text("SİBER AĞ: SOS Protokolü Tetiklendi!", style: TextStyle(fontFamily: 'Avenir', fontWeight: FontWeight.bold))),
                      ],
                    ),
                    backgroundColor: SiberTema.kanKirmizi,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: double.infinity,
                height: 65,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [SiberTema.kanKirmizi.withOpacity(0.9), SiberTema.kanKirmizi.withOpacity(0.6)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: SiberTema.kanKirmizi.withOpacity(0.4), offset: const Offset(0, 8), blurRadius: 15),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 28, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      "SOS MERKEZİNİ TETİKLE",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5, fontFamily: 'Avenir', shadows: [Shadow(color: Colors.black54, blurRadius: 2, offset: Offset(0, 1))]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- 🔴 3D VE SİBER ARAYÜZ PARÇALARI ---

  Widget _buildPanelBaslik(String baslik) {
    return Row(
      children: [
        const Icon(Icons.memory, color: SiberTema.kuantumCyan, size: 18),
        const SizedBox(width: 8),
        Text(
            baslik,
            style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                fontSize: 12,
                fontFamily: 'Avenir'
            )
        ),
      ],
    );
  }

  Widget _buildSiberMenuKarti(BuildContext context, String baslik, IconData ikon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          // 3D Dışa Çıkık Buton Hissi
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [SiberTema.matGrey.withOpacity(0.8), SiberTema.oledBlack],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 10, spreadRadius: 1, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SiberTema.kuantumCyan.withOpacity(0.05),
                shape: BoxShape.circle,
                border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.2)),
              ),
              child: Icon(ikon, color: SiberTema.kuantumCyan, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              baslik,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.95),
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.0,
                  fontFamily: 'Avenir'
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _canliFinansRadari() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('finans_islemleri').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return _buildKuantumLoader();

        final islemler = snapshot.data?.docs ?? [];
        double toplamCiro = 0;

        for (var islem in islemler) {
          final data = islem.data() as Map<String, dynamic>;
          toplamCiro += (data['tutar'] ?? 0).toDouble();
        }

        double siberKomutanPayi = toplamCiro * 0.12;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            // 3D İçeri Çökük Gösterge Paneli
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [SiberTema.oledBlack, SiberTema.matGrey.withOpacity(0.5)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
            boxShadow: [
              BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.05), blurRadius: 15, spreadRadius: -2, offset: const Offset(0, 5)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("AĞ CİROSU", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                  const SizedBox(height: 8),
                  Text("₺${toplamCiro.toStringAsFixed(2)}", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                ],
              ),
              Container(width: 2, height: 50, color: Colors.white.withOpacity(0.1)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("KOMUTAN PAYI (%12)", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                  const SizedBox(height: 8),
                  Text("₺${siberKomutanPayi.toStringAsFixed(2)}", style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Avenir', shadows: [Shadow(color: SiberTema.kuantumCyan, blurRadius: 10)])),
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
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: renk.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: renk.withOpacity(0.3)),
                        boxShadow: [BoxShadow(color: renk.withOpacity(0.2), blurRadius: 10)]
                    ),
                    child: Icon(icon, color: renk, size: 18),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(bayi, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                        const SizedBox(height: 4),
                        Text(islem, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, fontFamily: 'Avenir', fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
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