import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

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
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: SiberTema.oledBlack.withOpacity(0.9),
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: SiberTema.kuantumCyan), onPressed: () => Navigator.pop(context)),
          title: Text("GLOBAL SİBER PAZAR", style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2, fontFamily: 'Avenir')),
          centerTitle: true,
        ),
        body: Container(
          decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/radar_grid.png'), fit: BoxFit.cover, opacity: 0.05)),
          child: Column(
            children: [
              // ── 1. KUANTUM ARAMA MOTORU ──
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SiberTema.siberCamKalkan(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextField(
                    style: const TextStyle(color: Colors.white, fontFamily: 'Avenir', fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: "Parça Kodu, OEM veya İsim ile Kuantum Arama...",
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                      border: InputBorder.none,
                      icon: const Icon(Icons.radar, color: SiberTema.kuantumCyan),
                    ),
                    onChanged: (deger) {
                      setState(() {
                        _aramaMetni = deger.trim().toLowerCase();
                      });
                    },
                  ),
                ),
              ),

              // ── 2. KATEGORİ RADARI ──
              SizedBox(
                height: 50,
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
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? SiberTema.kuantumCyan.withOpacity(0.2) : SiberTema.matGrey.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? SiberTema.kuantumCyan : Colors.transparent, width: 1.5),
                          boxShadow: isSelected ? [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.4), blurRadius: 10)] : [],
                        ),
                        child: Text(
                            kat,
                            style: TextStyle(color: isSelected ? SiberTema.kuantumCyan : Colors.white54, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'Avenir', letterSpacing: 1)
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              // ── 3. CANLI İLAN AĞI (Filtreli Veri Çekimi) ──
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _db.collection('ilanlar').where('aktif_mi', isEqualTo: true).orderBy('yayin_tarihi', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));

                    if (snapshot.hasError) {
                      return Center(child: Text("SİBER AĞ HATASI: ${snapshot.error}", style: const TextStyle(color: SiberTema.kanKirmizi)));
                    }

                    // FİLTRELEME MOTORU (Kategori ve Arama Metni)
                    final tumIlanlar = snapshot.data?.docs ?? [];
                    final filtrelenmisIlanlar = tumIlanlar.where((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      String baslik = (data['baslik'] ?? '').toString().toLowerCase();
                      String parcaKodu = (data['parca_kodu'] ?? '').toString().toLowerCase();
                      String kategori = data['kategori'] ?? '';

                      bool kategoriUygun = _seciliKategori == 'TÜMÜ' || kategori == _seciliKategori;
                      bool aramaUygun = _aramaMetni.isEmpty || baslik.contains(_aramaMetni) || parcaKodu.contains(_aramaMetni);

                      return kategoriUygun && aramaUygun;
                    }).toList();

                    if (filtrelenmisIlanlar.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.travel_explore, size: 64, color: SiberTema.kuantumCyan.withOpacity(0.2)),
                            const SizedBox(height: 16),
                            Text("RADARDA SONUÇ BULUNAMADI", style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.bold, letterSpacing: 2, fontFamily: 'Avenir')),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.70, // Dikey İlan Kartı
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filtrelenmisIlanlar.length,
                      itemBuilder: (context, index) {
                        var ilan = filtrelenmisIlanlar[index].data() as Map<String, dynamic>;
                        String baslik = ilan['baslik'] ?? 'İlan Başlığı';
                        double fiyat = (ilan['fiyat'] ?? 0).toDouble();
                        String gorsel = ilan['gorsel_url'] ?? '';
                        String kategori = ilan['kategori'] ?? 'Kategori';
                        String parcaKodu = ilan['parca_kodu'] ?? '';

                        return _buildGlobalIlanKarti(baslik, fiyat, gorsel, kategori, parcaKodu);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- SİBER İLAN KARTI (Global Pazar İçin Özelleştirildi) ---
  Widget _buildGlobalIlanKarti(String baslik, double fiyat, String gorsel, String kategori, String parcaKodu) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [SiberTema.matGrey.withOpacity(0.8), SiberTema.oledBlack]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. İLAN GÖRSELİ
                Expanded(
                  flex: 5,
                  child: Container(
                    width: double.infinity,
                    color: SiberTema.oledBlack,
                    child: gorsel.isNotEmpty
                        ? Image.network(gorsel, fit: BoxFit.cover)
                        : const Center(child: Icon(Icons.image_not_supported, color: Colors.white24, size: 40)),
                  ),
                ),
                // 2. İLAN DETAYLARI VE FİYAT
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(baslik, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withOpacity(0.95), fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir', height: 1.2)),
                        if (parcaKodu.isNotEmpty)
                          Text("OEM: $parcaKodu", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: SiberTema.altinSari.withOpacity(0.8), fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                        Text("₺${fiyat.toStringAsFixed(2)}", style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // KATEGORİ ETİKETİ (Siber Cam Efekti)
            Positioned(
              top: 8,
              left: 8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: SiberTema.oledBlack.withOpacity(0.6), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white.withOpacity(0.1))),
                    child: Text(kategori, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                  ),
                ),
              ),
            ),

            // SİBER ONAY (Karargah Güvencesi İkonu)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.2), shape: BoxShape.circle, border: Border.all(color: SiberTema.kuantumCyan)),
                child: const Icon(Icons.verified, color: SiberTema.kuantumCyan, size: 12),
              ),
            )
          ],
        ),
      ),
    );
  }
}