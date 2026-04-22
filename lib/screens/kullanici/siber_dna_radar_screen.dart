import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/siber_tema.dart';
import 'siber_bakim_karnesi_screen.dart'; // Karnesi için geçiş
import 'siber_arac_kayit_terminali.dart'; // Kayıt terminaline geçiş

class SiberDnaRadarScreen extends StatefulWidget {
  const SiberDnaRadarScreen({super.key});

  @override
  State<SiberDnaRadarScreen> createState() => _SiberDnaRadarScreenState();
}

class _SiberDnaRadarScreenState extends State<SiberDnaRadarScreen> {
  static const Color primaryCyan = SiberTema.kuantumCyan;
  static const Color dangerColor = SiberTema.kanKirmizi;
  static const Color siberGold = SiberTema.siberGold;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    User? currentUser = _auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: SiberTema.siberArkaPlan)),
          SafeArea(
            child: Column(
              children: [
                _buildSiberAppBar(),
                Expanded(
                  child: currentUser == null 
                    ? const Center(child: Text("Siber Kimlik Doğrulanamadı!", style: TextStyle(color: dangerColor)))
                    : _buildRadarEkrani(currentUser.uid),
                ),
                _buildAltTerminal(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiberAppBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), border: const Border(bottom: BorderSide(color: Colors.white10))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle), child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18)),
              ),
              const Text('D N A   R A D A R I', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 3, fontFamily: 'Avenir')),
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: siberGold.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: siberGold.withOpacity(0.5))), child: const Icon(Icons.radar, color: siberGold, size: 18)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadarEkrani(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('vehicles').where('sahibiUid', isEqualTo: uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: primaryCyan));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildBosGarajRadari();
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return _buildDnaAracKarti(data);
          },
        );
      },
    );
  }

  Widget _buildBosGarajRadari() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), shape: BoxShape.circle, border: Border.all(color: Colors.white10)),
            child: const Icon(Icons.blur_on, color: Colors.white38, size: 64),
          ),
          const SizedBox(height: 24),
          const Text("SİBER RADAR BOŞ", style: TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2, fontFamily: 'Avenir')),
          const SizedBox(height: 8),
          const Text("Karargaha kayıtlı bir aracınız bulunmuyor.", style: TextStyle(color: Colors.white38, fontSize: 12, fontFamily: 'Avenir')),
        ],
      ),
    );
  }

  Widget _buildDnaAracKarti(Map<String, dynamic> data) {
    int dnaSkoru = data['dna_skoru'] ?? 0;
    bool kritikHataVarMi = data['kritik_hata_var_mi'] ?? false;
    String plaka = data['plaka'] ?? 'BİLİNMİYOR';
    String marka = data['marka'] ?? '';
    String model = data['model'] ?? '';
    String saseNo = data['saseNo'] ?? '';
    String durum = data['muayene_durumu'] ?? 'Bekliyor';

    Color skorRengi = primaryCyan;
    if (dnaSkoru < 50) skorRengi = dangerColor;
    else if (dnaSkoru < 80) skorRengi = siberGold;

    return GestureDetector(
      onTap: () {
        // Siber Bakım Karnesine Geçiş
        Navigator.push(context, MaterialPageRoute(builder: (_) => SiberBakimKarnesiScreen(plaka: plaka, markaModel: "$marka $model", saseNo: saseNo)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: kritikHataVarMi ? dangerColor.withOpacity(0.5) : Colors.white10, width: 2),
        ),
        child: Stack(
          children: [
            // KRİTİK HATA ALARMI (ARKAPLAN GLOW)
            if (kritikHataVarMi)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: dangerColor.withOpacity(0.1), blurRadius: 30, spreadRadius: 5)],
                  ),
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  // DNA SKORU (Holografik Çember)
                  SizedBox(
                    height: 80,
                    width: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 80, width: 80,
                          child: CircularProgressIndicator(
                            value: dnaSkoru / 100,
                            strokeWidth: 6,
                            backgroundColor: Colors.white.withOpacity(0.05),
                            valueColor: AlwaysStoppedAnimation<Color>(skorRengi),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(dnaSkoru.toString(), style: TextStyle(color: skorRengi, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'Avenir', height: 1)),
                            const Text("DNA", style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),

                  // ARAÇ BİLGİLERİ
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plaka, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
                        const SizedBox(height: 4),
                        Text("$marka $model".toUpperCase(), style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: skorRengi.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: skorRengi.withOpacity(0.3))),
                          child: Text(durum.toUpperCase(), style: TextStyle(color: skorRengi, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // SAĞ ÜST KRİTİK İKON
            if (kritikHataVarMi)
              const Positioned(
                top: 16, right: 16,
                child: Icon(Icons.warning_amber_rounded, color: dangerColor, size: 24),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildAltTerminal() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), border: const Border(top: BorderSide(color: Colors.white10))),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryCyan.withOpacity(0.1),
            foregroundColor: primaryCyan,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            side: BorderSide(color: primaryCyan.withOpacity(0.5)),
            elevation: 0,
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SiberAracKayitTerminali()));
          },
          icon: const Icon(Icons.add, size: 20),
          label: const Text("YENİ ARAÇ KAYDET", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
        ),
      ),
    );
  }
}
