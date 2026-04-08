import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🔥 SİBER KÖPRÜLER - YENİ YOL HİYERARŞİSİNE GÖRE AYARLANDI
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

class AdminGlobalPanel extends StatefulWidget {
  const AdminGlobalPanel({super.key});

  @override
  State<AdminGlobalPanel> createState() => _AdminGlobalPanelState();
}

class _AdminGlobalPanelState extends State<AdminGlobalPanel> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Siber Renk Paleti - Merkezi Temadan Çekiliyor
  final Color _primaryCyan = SiberTema.kuantumCyan;
  final Color _cyberBlack = SiberTema.oledBlack;
  final Color _surfaceColor = SiberTema.matGrey.withOpacity(0.2);

  // 🌍 YENİ DİSTRİBÜTÖR AĞI OLUŞTURMA
  Future<void> _yeniUlkeAgaEkle() async {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              "YENİ DİSTRİBÜTÖR AĞI OLUŞTURULUYOR... 🌍",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')
          ),
          backgroundColor: _primaryCyan,
        )
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
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context)
          ),
          title: const Text(
              'G L O B A L   S İ B E R   A Ğ',
              style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 3, fontFamily: 'Avenir')
          ),
          centerTitle: true,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRadarHeader(),
            _buildSectionTitle(),
            const SizedBox(height: 16),
            _buildGlobalNetworkList(),
          ],
        ),
        bottomNavigationBar: _buildBottomAction(),
      ),
    );
  }

  Widget _buildRadarHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _primaryCyan.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: _cyberBlack, shape: BoxShape.circle, border: Border.all(color: _primaryCyan.withOpacity(0.5))),
              child: Icon(Icons.radar, color: _primaryCyan, size: 32),
            ),
            const SizedBox(width: 24),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("OTODNA KÜRESEL UYDU BAĞLANTISI", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                  SizedBox(height: 8),
                  Text("SİSTEM ÇEVRİMİÇİ | MERKEZ: ANKARA HQ", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Text("AKTİF ÜLKE VE BÖLGELER", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
    );
  }

  Widget _buildGlobalNetworkList() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('global_aglari').orderBy('oncelik', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: _primaryCyan));

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _buildUlkeKarti("TR", "TÜRKİYE (MERKEZ)", "81 İl / 7 Bölge Kuantum Ağı", "AKTİF", _primaryCyan),
                _buildUlkeKarti("AZ", "AZERBAYCAN (BAKÜ)", "Siber Görüşmeler Devam Ediyor", "PASİF", Colors.blueAccent),
              ],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var veri = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return _buildUlkeKarti(
                  veri['kod'] ?? 'XX',
                  veri['ulke'] ?? 'Bilinmeyen',
                  veri['detay'] ?? '',
                  veri['durum'] ?? 'PASİF',
                  _primaryCyan
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBottomAction() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(color: _surfaceColor, border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05)))),
        child: SizedBox(
          height: 60,
          child: ElevatedButton.icon(
            style: SiberTema.kuantumButonStili(outlined: true),
            onPressed: _yeniUlkeAgaEkle,
            icon: const Icon(Icons.add_location_alt_outlined, size: 20),
            label: const Text("YENİ ÜLKE / BÖLGE İSKELETİ OLUŞTUR", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
          ),
        ),
      ),
    );
  }

  Widget _buildUlkeKarti(String kod, String ulke, String detay, String durum, Color renk) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: _cyberBlack, borderRadius: BorderRadius.circular(16), border: Border.all(color: renk.withOpacity(0.3))),
            child: Text(kod.toUpperCase(), style: TextStyle(color: renk, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ulke.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                Text(detay, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: renk.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: renk.withOpacity(0.5))),
            child: Text(durum, style: TextStyle(color: renk, fontSize: 9, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
          ),
        ],
      ),
    );
  }
}