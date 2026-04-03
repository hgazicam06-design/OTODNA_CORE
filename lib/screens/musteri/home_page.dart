import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🚨 DİKKAT: Sayfaları oluşturdukça buradaki yorumları kaldırabilirsin.
// import 'musteri_harita_screen.dart';

class HomePageDesign extends StatefulWidget {
  const HomePageDesign({super.key});

  @override
  State<HomePageDesign> createState() => _HomePageDesignState();
}

class _HomePageDesignState extends State<HomePageDesign> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  final Color bgColor = const Color(0xFF000000);
  final Color surfaceColor = const Color(0xFF111111);
  final Color primaryCyan = const Color(0xFF00FFC2);

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 💎 SİBER RADAR YÖNLENDİRME MOTORU
  void _radaraGit(String aramaKelimesi) {
    /* Navigator.push(context, MaterialPageRoute(builder: (context) => MusteriHaritaScreen(
      ilkAramaKelimesi: aramaKelimesi,
    )));
    */
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Siber Radarda Aranıyor: $aramaKelimesi', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: primaryCyan,
          duration: const Duration(seconds: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: const Text("K E Ş F E T", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 3)),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: surfaceColor, shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.05))),
            child: const Icon(Icons.notifications_none_outlined, color: Colors.white54, size: 20),
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildCategoryGrid(),
            const SizedBox(height: 40),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text("SİBER AĞ VİTRİNİ", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
            ),
            const SizedBox(height: 16),
            _buildFeaturedFirms(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // 💎 1. MİNİMALİST ARAMA ÇUBUĞU
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Container(
        decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
            boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.05), blurRadius: 20)]
        ),
        child: TextField(
          style: const TextStyle(color: Colors.white, fontSize: 14),
          textInputAction: TextInputAction.search,
          onSubmitted: (value) => _radaraGit(value),
          decoration: InputDecoration(
            hintText: "Siber Ağda Usta, Parça veya Plaka Ara...",
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 13),
            prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
            suffixIcon: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.qr_code_scanner_outlined, color: Color(0xFF00FFC2), size: 18)
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  // 💎 2. KATEGORİ İKONLARI (Glow Efektli Çipler)
  Widget _buildCategoryGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _categoryIcon(Icons.tire_repair_outlined, "LASTİK", Colors.blueGrey, "Lastik"),
        _categoryIcon(Icons.battery_charging_full_outlined, "AKÜ / EV", primaryCyan, "Akü"),
        _categoryIcon(Icons.build_outlined, "MEKANİK", Colors.orangeAccent, "Mekanik"),
        _categoryIcon(Icons.format_paint_outlined, "KAPORTA", Colors.purpleAccent, "Kaporta"),
      ],
    );
  }

  Widget _categoryIcon(IconData icon, String label, Color color, String aramaKelimesi) {
    return GestureDetector(
      onTap: () => _radaraGit(aramaKelimesi),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: surfaceColor,
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.3)),
                boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 15)]
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ],
      ),
    );
  }

  // 💎 3. ALTIN ROZETLİ USTALAR (Firebase Canlı Radar - Premium Kartlar)
  Widget _buildFeaturedFirms() {
    return SizedBox(
      height: 240, // Kartları biraz daha uzun ve zarif yaptık
      child: StreamBuilder<QuerySnapshot>(
          stream: _db.collection('kullanicilar').where('rol', isEqualTo: 'bayi').where('is_vip', isEqualTo: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF00FFC2)));
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("Siber ağda şu an aktif VIP istasyon bulunmuyor.", style: TextStyle(color: Colors.white38, fontSize: 12)));

            var vipUstalar = snapshot.data!.docs;

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: vipUstalar.length,
              itemBuilder: (context, index) {
                var ustaData = vipUstalar[index].data() as Map<String, dynamic>;
                String firmaAdi = ustaData['ad'] ?? 'İsimsiz İstasyon';
                double puan = (ustaData['puan'] ?? 5.0).toDouble();
                String rozet = ustaData['rozet'] ?? 'Altın';

                // VIP rengi (Altın veya Kuantum Turkuazı)
                Color kartRengi = rozet == "Murat Plaza" ? primaryCyan : Colors.amber;

                return Container(
                  width: 170,
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: kartRengi.withOpacity(0.4), width: 1.5),
                      boxShadow: [BoxShadow(color: kartRengi.withOpacity(0.05), blurRadius: 20)]
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: kartRengi.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: kartRengi.withOpacity(0.5))),
                        child: Icon(Icons.storefront_outlined, color: kartRengi, size: 28),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        firmaAdi.toUpperCase(),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
                      ),
                      const Spacer(),

                      // Puan ve Rozet Çipleri
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFF000000), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: kartRengi, size: 12),
                            const SizedBox(width: 4),
                            Text(puan.toStringAsFixed(1), style: TextStyle(color: kartRengi, fontWeight: FontWeight.w900, fontSize: 11)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text("$rozet İSTASYON".toUpperCase(), style: TextStyle(color: kartRengi.withOpacity(0.8), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    ],
                  ),
                );
              },
            );
          }
      ),
    );
  }
}