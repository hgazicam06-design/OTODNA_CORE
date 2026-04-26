import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'siber_bakim_karnesi_screen.dart'; // Karnesi için geçiş
import 'siber_arac_kayit_terminali.dart'; // Kayıt terminaline geçiş

class SiberDnaRadarScreen extends StatefulWidget {
  const SiberDnaRadarScreen({super.key});

  @override
  State<SiberDnaRadarScreen> createState() => _SiberDnaRadarScreenState();
}

class _SiberDnaRadarScreenState extends State<SiberDnaRadarScreen> {
  final Color primaryTeal = Colors.teal.shade700;
  final Color dangerColor = Colors.redAccent;
  final Color warningColor = Colors.orange;
  final Color textColor = const Color(0xFF1E293B);
  final Color bgColor = const Color(0xFFFAFAFC);

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    User? currentUser = _auth.currentUser;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: primaryTeal, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text('D N A   R A D A R I', style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 3, fontFamily: 'Avenir')),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: primaryTeal.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.radar, color: primaryTeal, size: 18)
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: currentUser == null 
                ? Center(child: Text("Sistem Kimlik Doğrulanamadı!", style: TextStyle(color: dangerColor, fontWeight: FontWeight.bold, fontFamily: 'Avenir')))
                : _buildRadarEkrani(currentUser.uid),
            ),
            _buildAltTerminal(),
          ],
        ),
      ),
    );
  }

  Widget _buildRadarEkrani(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('vehicles').where('sahibiUid', isEqualTo: uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: primaryTeal));
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
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.black.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20)]),
            child: const Icon(Icons.blur_on, color: Colors.black26, size: 64),
          ),
          const SizedBox(height: 24),
          Text("GARAJ BOŞ", style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
          const SizedBox(height: 8),
          const Text("Sisteme kayıtlı bir aracınız bulunmuyor.", style: TextStyle(color: Colors.black45, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
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

    Color skorRengi = primaryTeal;
    if (dnaSkoru < 50) skorRengi = dangerColor;
    else if (dnaSkoru < 80) skorRengi = warningColor;

    return GestureDetector(
      onTap: () {
        // Siber Bakım Karnesine Geçiş (O da güncellenecek)
        Navigator.push(context, MaterialPageRoute(builder: (_) => SiberBakimKarnesiScreen(plaka: plaka, markaModel: "$marka $model", saseNo: saseNo)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: kritikHataVarMi ? dangerColor.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.05), width: 2),
          boxShadow: [
            BoxShadow(
              color: kritikHataVarMi ? dangerColor.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.02), 
              blurRadius: 20, 
              spreadRadius: kritikHataVarMi ? 5 : 0,
              offset: const Offset(0, 5)
            )
          ]
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  // DNA SKORU
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
                            backgroundColor: Colors.black.withValues(alpha: 0.05),
                            valueColor: AlwaysStoppedAnimation<Color>(skorRengi),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(dnaSkoru.toString(), style: TextStyle(color: skorRengi, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'Avenir', height: 1)),
                            const Text("DNA", style: TextStyle(color: Colors.black38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
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
                        Text(plaka, style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
                        const SizedBox(height: 4),
                        Text("$marka $model".toUpperCase(), style: const TextStyle(color: Colors.black45, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: skorRengi.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: skorRengi.withValues(alpha: 0.3))),
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
              Positioned(
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
      decoration: BoxDecoration(
        color: Colors.white, 
        border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, -5))]
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            backgroundColor: primaryTeal.withValues(alpha: 0.05),
            foregroundColor: primaryTeal,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            side: BorderSide(color: primaryTeal.withValues(alpha: 0.5)),
            elevation: 0,
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SiberAracKayitTerminali()));
          },
          icon: const Icon(Icons.add, size: 20),
          label: const Text("YENİ ARAÇ KAYDET", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
        ),
      ),
    );
  }
}
