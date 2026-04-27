import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';
import '../core/otodna_mega_protocol.dart'; // 🦅 PROTOKOL ENTEGRASYONU

class GlobalSiberPazarScreen extends StatefulWidget {
  const GlobalSiberPazarScreen({super.key});

  @override
  State<GlobalSiberPazarScreen> createState() => _GlobalSiberPazarScreenState();
}

class _GlobalSiberPazarScreenState extends State<GlobalSiberPazarScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String _seciliKategori = 'TÜMÜ';
  String _aramaMetni = '';

  final List<String> _kategoriler = ['TÜMÜ', 'Yedek Parça', 'Oto Aksesuar', 'Elektronik / Beyin', 'Kaporta', 'Hasarlı Araç'];

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: SiberTema.oledBlack.withOpacity(0.9),
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: SiberTema.kuantumCyan), onPressed: () => Navigator.pop(context)),
          title: const Text("GLOBAL SİBER PAZAR",
              style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 4, fontFamily: 'monospace')),
          centerTitle: true,
        ),
        body: Container(
          decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/radar_grid.png'), fit: BoxFit.cover, opacity: 0.05)),
          child: Column(
            children: [
              _buildAramaMotoru(),
              _buildKategoriRadari(),
              const SizedBox(height: 10),
              _buildIlanListesi(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAramaMotoru() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SiberTema.siberCamKalkan(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: TextField(
          style: const TextStyle(color: SiberTema.textMain, fontFamily: 'monospace', fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: "OEM, Parça Kodu veya İsim İle Tara...",
            hintStyle: TextStyle(color: SiberTema.textMain.withOpacity(0.3), fontSize: 10, letterSpacing: 1),
            border: InputBorder.none,
            icon: const Icon(Icons.radar, color: SiberTema.kuantumCyan, size: 20),
          ),
          onChanged: (deger) => setState(() => _aramaMetni = deger.trim().toLowerCase()),
        ),
      ),
    );
  }

  Widget _buildKategoriRadari() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _kategoriler.length,
        itemBuilder: (context, index) {
          String kat = _kategoriler[index];
          bool isSelected = _seciliKategori == kat;
          return GestureDetector(
            onTap: () => setState(() => _seciliKategori = kat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                color: isSelected ? SiberTema.kuantumCyan.withOpacity(0.1) : Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? SiberTema.kuantumCyan : Colors.white10),
                boxShadow: isSelected ? [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.2), blurRadius: 10)] : [],
              ),
              alignment: Alignment.center,
              child: Text(kat.toUpperCase(),
                  style: TextStyle(color: isSelected ? SiberTema.kuantumCyan : Colors.white38, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIlanListesi() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('ilanlar').where('aktif_mi', isEqualTo: true).orderBy('yayin_tarihi', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));

          final docs = snapshot.data?.docs.where((doc) {
            var data = doc.data() as Map<String, dynamic>;
            bool katUygun = _seciliKategori == 'TÜMÜ' || data['kategori'] == _seciliKategori;
            bool aramaUygun = _aramaMetni.isEmpty ||
                data['baslik'].toString().toLowerCase().contains(_aramaMetni) ||
                data['parca_kodu'].toString().toLowerCase().contains(_aramaMetni);
            return katUygun && aramaUygun;
          }).toList() ?? [];

          if (docs.isEmpty) return _buildBosDurum();

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 15, mainAxisSpacing: 15),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var ilan = docs[index].data() as Map<String, dynamic>;
              return _buildGlobalIlanKarti(ilan);
            },
          );
        },
      ),
    );
  }

  Widget _buildGlobalIlanKarti(Map<String, dynamic> ilan) {
    // 💰 GAZİ PROTOKOLÜ: %12 Fiyatlandırma Zırhı
    double hamFiyat = (ilan['fiyat'] ?? 0).toDouble();
    double sonFiyat = hamFiyat * (1 + OtodnaMegaProtocol.karargahPayi);

    return Container(
      decoration: BoxDecoration(
        color: SiberTema.matGrey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
            Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: ilan['gorsel_url'] != null
                      ? Image.network(ilan['gorsel_url'], fit: BoxFit.cover)
                      : const Icon(Icons. Dionysus, color: SiberTema.textMuted), // Kuantum İkon
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(ilan['baslik']?.toUpperCase() ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: SiberTema.textMain, fontSize: 10, fontWeight: FontWeight.w900)),
                      Text("OEM: ${ilan['parca_kodu'] ?? 'YOK'}", style: const TextStyle(color: SiberTema.textMuted, fontSize: 8, fontFamily: 'monospace')),
                      Text("₺${sonFiyat.toStringAsFixed(2)}",
                          style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(top: 8, right: 8, child: _buildMühür()),
      ],
    ),
    ),
    );
  }

  Widget _buildMühür() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: SiberTema.kuantumCyan, width: 0.5)),
      child: const Icon(Icons.verified, color: SiberTema.kuantumCyan, size: 10),
    );
  }

  Widget _buildBosDurum() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.radar, size: 50, color: SiberTema.textMuted),
          const SizedBox(height: 16),
          Text("RADAR TEMİZ: VERİ BULUNAMADI",
              style: TextStyle(color: SiberTema.textMain.withOpacity(0.2), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
        ],
      ),
    );
  }
}