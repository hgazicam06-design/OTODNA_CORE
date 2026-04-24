import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🔥 SİBER KÖPRÜLER VE TEMA (Zırh v2.0)
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

import '../bayi_yonetim_merkezi_screen.dart';
import '../kullanici_yonetim_screen.dart';
import '../bayi_paneli.dart';
import 'admin_control_center.dart';

class AmiralGemisi extends StatefulWidget {
  const AmiralGemisi({super.key});

  @override
  _AmiralGemisiState createState() => _AmiralGemisiState();
}

class _AmiralGemisiState extends State<AmiralGemisi> {
  bool _isLocked = true;
  String _masterKey = "";
  bool _isChecking = false;

  @override
  Widget build(BuildContext context) {
    // 🛡️ SİBER KİLİT EKRANI (MASTER KEY PROTOKOLÜ)
    if (_isLocked) {
      return _buildSiberKilitEkrani();
    }

    // 🚀 AMİRAL GEMİSİ ANA KONTROL PANELİ
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: SiberTema.siberArkaPlan,
          child: Row(
            children: [
              _buildSiberYanMenu(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildKuantumBaslik("AMİRAL GEMİSİ FİNANSAL RADARI", Icons.account_balance, SiberTema.altinSari),
                      _ustFinansalBant(),

                      const SizedBox(height: 35),

                      _buildKuantumBaslik("HIZLI OPERASYON KAPILARI", Icons.api, SiberTema.kuantumCyan),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          double cardWidth = (constraints.maxWidth - 48) / 4;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSinematikDonanimKarti("BAYİ AĞI\nMERKEZİ", Icons.business, SiberTema.kuantumCyan, cardWidth,
                                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BayiYonetimMerkeziScreen()))),
                              _buildSinematikDonanimKarti("BAYİ\nKOKPİTİ", Icons.store_mall_directory, SiberTema.kuantumCyan, cardWidth,
                                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => BayiPaneliScreen(bayiId: FirebaseAuth.instance.currentUser?.uid ?? 'ADMIN_BYPASS')))),
                              _buildSinematikDonanimKarti("KULLANICI\nYETKİ", Icons.people_alt, SiberTema.altinSari, cardWidth,
                                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KullaniciYonetimScreen()))),
                              _buildSinematikDonanimKarti("KARARGAH\n(ADMİN)", Icons.admin_panel_settings, SiberTema.kanKirmizi, cardWidth,
                                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminControlCenter()))),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildKuantumBaslik("SİBER GÜVENLİK", Icons.security, SiberTema.kanKirmizi),
                                _teknikSistemSagligi(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildKuantumBaslik("ELİT BAYİ MATRİSİ", Icons.leaderboard, SiberTema.kuantumCyan),
                                _bayiPerformansMatrisi(),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                      _buildKuantumBaslik("CANLI OPERASYON HARİTASI", Icons.map, Colors.white),
                      _canliHaritaKatmani(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 🔴 FİREBASE MOTORLARI ---

  Widget _ustFinansalBant() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('finansal_islemler').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return _buildKuantumLoader(SiberTema.kuantumCyan);

        double gunlukSatis = 0.0;
        double gaziNetPay = 0.0;
        double devletVergi = 0.0;

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            var data = doc.data() as Map<String, dynamic>;
            gunlukSatis += (data['brut_tutar'] ?? 0).toDouble();
            gaziNetPay += (data['komutan_payi'] ?? ((data['brut_tutar'] ?? 0) * 0.10)).toDouble();
            devletVergi += (data['vergi_payi'] ?? ((data['brut_tutar'] ?? 0) * 0.02)).toDouble();
          }
        }

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: _sinematikKutuDekoru(SiberTema.altinSari),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _finansVeri("TOPLAM İŞLEM HACMİ", "₺${gunlukSatis.toStringAsFixed(2)}", Colors.white),
              Container(height: 60, width: 1, color: Colors.white24),
              _finansVeri("KOMUTAN NET PAY (%10)", "₺${gaziNetPay.toStringAsFixed(2)}", SiberTema.kuantumCyan),
              Container(height: 60, width: 1, color: Colors.white24),
              _finansVeri("DEVLET VERGİSİ (%2)", "₺${devletVergi.toStringAsFixed(2)}", SiberTema.altinSari),
            ],
          ),
        );
      },
    );
  }

  Widget _teknikSistemSagligi() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('siber_istihbarat_loglari').where('kategori', isEqualTo: 'GÜVENLİK').limit(5).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return _buildKuantumLoader(SiberTema.kanKirmizi);

        int ihlalSayisi = snapshot.hasData ? snapshot.data!.docs.length : 0;
        bool guvendeMi = ihlalSayisi == 0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: _sinematikKutuDekoru(guvendeMi ? SiberTema.kuantumCyan : SiberTema.kanKirmizi),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: _buildNeonIkon(guvendeMi ? Icons.shield : Icons.warning_amber_rounded, guvendeMi ? SiberTema.kuantumCyan : SiberTema.kanKirmizi),
            title: const Text("Kuantum Ağ Güvenliği", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
            subtitle: Text(
                guvendeMi ? "Saldırı Girişimi: 0 | Kalkanlar Aktif ✅" : "DİKKAT! $ihlalSayisi İhlal Tespit Edildi!",
                style: TextStyle(color: guvendeMi ? SiberTema.kuantumCyan : SiberTema.kanKirmizi, fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'Avenir')
            ),
          ),
        );
      },
    );
  }

  Widget _bayiPerformansMatrisi() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bayiler').where('aktif_mi', isEqualTo: true).orderBy('aylik_ciro', descending: true).limit(3).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return _buildKuantumLoader(SiberTema.kuantumCyan);
        final docs = snapshot.data?.docs ?? [];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: _sinematikKutuDekoru(SiberTema.kuantumCyan),
          child: docs.isEmpty
              ? const Center(child: Text("Veri Yok", style: TextStyle(color: Colors.white24)))
              : Column(
            children: docs.asMap().entries.map((entry) {
              var data = entry.value.data() as Map<String, dynamic>;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Text("#${entry.key + 1}", style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 18, fontWeight: FontWeight.w900)),
                title: Text(data['firma_adi'] ?? 'Bilinmeyen Bayi', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                trailing: Text("₺${(data['aylik_ciro'] ?? 0).toStringAsFixed(0)}", style: const TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900)),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // --- 🎨 SİBER UI BİLEŞENLERİ ---

  Widget _buildSiberKilitEkrani() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: SiberTema.siberArkaPlan,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: _sinematikKutuDekoru(SiberTema.kanKirmizi),
            width: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.fingerprint, size: 80, color: SiberTema.kanKirmizi, shadows: [Shadow(color: SiberTema.kanKirmizi, blurRadius: 20)]),
                const SizedBox(height: 24),
                const Text("AMİRAL GEMİSİ", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 4)),
                const SizedBox(height: 8),
                const Text("DERİN DEVLET YETKİSİ GEREKLİ", style: TextStyle(color: SiberTema.kanKirmizi, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                const SizedBox(height: 35),
                TextField(
                  obscureText: true,
                  textAlign: TextAlign.center,
                  onChanged: (v) => _masterKey = v,
                  style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 24, letterSpacing: 10, fontWeight: FontWeight.w900),
                  decoration: InputDecoration(
                    hintText: "MASTER KEY",
                    hintStyle: TextStyle(color: SiberTema.kuantumCyan.withOpacity(0.2), letterSpacing: 5),
                    filled: true, fillColor: Colors.black.withOpacity(0.8),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: SiberTema.kuantumCyan.withOpacity(0.3))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: SiberTema.kanKirmizi, width: 2)),
                  ),
                ),
                const SizedBox(height: 35),
                SizedBox(
                  width: double.infinity, height: 55,
                  child: ElevatedButton(
                    style: SiberTema.kuantumButonStili().copyWith(backgroundColor: WidgetStateProperty.all(SiberTema.kanKirmizi)),
                    onPressed: () async {
                      setState(() => _isChecking = true);
                      await Future.delayed(const Duration(seconds: 1));
                      if (_masterKey == "GAZI1923") {
                        setState(() { _isLocked = false; _isChecking = false; });
                      } else {
                        setState(() => _isChecking = false);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ERİŞİM REDDEDİLDİ!", style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: SiberTema.kanKirmizi));
                      }
                    },
                    child: _isChecking ? const CircularProgressIndicator(color: Colors.black) : const Text("MÜHRÜ ONAYLA", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSinematikDonanimKarti(String baslik, IconData ikon, Color neonRenk, double genislik, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: genislik, height: 140,
        decoration: _sinematikKutuDekoru(neonRenk),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(ikon, color: neonRenk, size: 34, shadows: [Shadow(color: neonRenk, blurRadius: 15)]),
            const SizedBox(height: 12),
            Text(baslik, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  BoxDecoration _sinematikKutuDekoru(Color anaRenk) {
    return BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1E2026), Color(0xFF0A0B0E)]),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 15), BoxShadow(color: anaRenk.withOpacity(0.05), blurRadius: 20)]
    );
  }

  Widget _buildKuantumBaslik(String metin, IconData icon, Color renk) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Row(
      children: [
        Icon(icon, color: renk, size: 20),
        const SizedBox(width: 10),
        Text(metin, style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 11)),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: renk.withOpacity(0.2))),
      ],
    ),
  );

  Widget _finansVeri(String baslik, String deger, Color renk) => Column(
    children: [
      Text(baslik, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text(deger, style: TextStyle(color: renk, fontSize: 22, fontWeight: FontWeight.w900, shadows: [Shadow(color: renk, blurRadius: 10)]))
    ],
  );

  Widget _buildSiberYanMenu() => Container(
    width: 80,
    decoration: BoxDecoration(color: Colors.black, border: Border(right: BorderSide(color: Colors.white.withOpacity(0.05)))),
    child: Column(
      children: [
        const SizedBox(height: 60),
        _buildNeonIkon(Icons.remove_red_eye, SiberTema.kuantumCyan),
        const SizedBox(height: 30),
        _buildNeonIkon(Icons.language, SiberTema.kuantumCyan),
        const Spacer(),
        IconButton(icon: const Icon(Icons.power_settings_new, color: SiberTema.kanKirmizi, size: 28), onPressed: () => setState(() => _isLocked = true)),
        const SizedBox(height: 40),
      ],
    ),
  );

  Widget _canliHaritaKatmani() => Container(
    height: 200, width: double.infinity,
    decoration: _sinematikKutuDekoru(Colors.white).copyWith(
      image: const DecorationImage(image: AssetImage('assets/images/radar_grid.png'), fit: BoxFit.cover, opacity: 0.1),
    ),
    child: const Center(
      child: Icon(Icons.radar, color: SiberTema.kuantumCyan, size: 40, shadows: [Shadow(color: SiberTema.kuantumCyan, blurRadius: 20)]),
    ),
  );

  Widget _buildNeonIkon(IconData icon, Color renk) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: renk.withOpacity(0.05), shape: BoxShape.circle, border: Border.all(color: renk.withOpacity(0.2))),
    child: Icon(icon, color: renk, size: 22),
  );

  Widget _buildKuantumLoader(Color renk) => Center(child: CircularProgressIndicator(color: renk));
}