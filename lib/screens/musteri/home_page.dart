import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart'; // YENİ: GoRouter entegrasyonu

class HomePageDesign extends StatefulWidget {
  const HomePageDesign({super.key});

  @override
  State<HomePageDesign> createState() => _HomePageDesignState();
}

class _HomePageDesignState extends State<HomePageDesign> {
  // 🏢 FİLDİŞİ SEDEF PALET
  final Color bgColor = const Color(0xFFFDFBF7);
  final Color surfaceColor = Colors.white;
  final Color primaryTeal = Colors.teal.shade700;
  final Color textMain = const Color(0xFF1E293B);
  final Color textMuted = const Color(0xFF64748B);

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 💎 SİBER RADAR YÖNLENDİRME MOTORU
  void _radaraGit(String aramaKelimesi) {
    context.push('/musteri_harita', extra: {'ilkAramaKelimesi': aramaKelimesi});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: Text("K E Ş F E T", style: TextStyle(color: textMain, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 3, fontFamily: 'Avenir')),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: surfaceColor, shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.05))),
            child: Icon(Icons.notifications_none_outlined, color: textMuted, size: 20),
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text("SİBER AĞ VİTRİNİ", style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
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
            boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.02), blurRadius: 10)]
        ),
        child: TextField(
          style: TextStyle(color: textMain, fontSize: 14),
          textInputAction: TextInputAction.search,
          onSubmitted: (value) => _radaraGit(value),
          decoration: InputDecoration(
            hintText: "Siber Ağda Usta, Parça veya Plaka Ara...",
            hintStyle: TextStyle(color: textMuted.withOpacity(0.5), fontSize: 13),
            prefixIcon: Icon(Icons.search, color: textMuted, size: 20),
            suffixIcon: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: primaryTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.qr_code_scanner_outlined, color: primaryTeal, size: 18)
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
        _categoryIcon(Icons.battery_charging_full_outlined, "AKÜ / EV", primaryTeal, "Akü"),
        _categoryIcon(Icons.build_outlined, "MEKANİK", Colors.orange.shade700, "Mekanik"),
        _categoryIcon(Icons.format_paint_outlined, "KAPORTA", Colors.purple.shade700, "Kaporta"),
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
          Text(label, style: TextStyle(color: textMuted, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
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
            if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: primaryTeal));
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Text("Siber ağda şu an aktif VIP istasyon bulunmuyor.", style: TextStyle(color: textMuted, fontSize: 12)));

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
                Color kartRengi = rozet == "Murat Plaza" ? primaryTeal : Colors.amber.shade700;

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
                        style: TextStyle(color: textMain, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
                      ),
                      const Spacer(),

                      // Puan ve Rozet Çipleri
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: kartRengi.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: kartRengi.withOpacity(0.3))),
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