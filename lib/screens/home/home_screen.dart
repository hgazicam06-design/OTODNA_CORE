import 'package:flutter/material.dart';
import '../kullanici/siber_profil_screen.dart'; // SİBER PROFİL KÖPRÜSÜ
import '../kullanici/siber_dna_radar_screen.dart'; // SİBER ARAÇ RADARI
import '../market/siber_ikinci_el_market.dart'; // İKİNCİ EL MARKET VİTRİNİ
import '../../models/ad_campaign_model.dart';
import '../../widgets/siber_hedefli_reklam_panosu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _seciliSekme = 0;

  // TEST TIKLAMA MOTORU (Sadece çalışıp çalışmadığını test etmek için)
  void _testTiklama(String modulAdi) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$modulAdi Açılıyor...', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF00FFC2),
          duration: const Duration(seconds: 1),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🌑 TESLA / APPLE ULTRA-MİNİMALİST PALET
    const bgColor = Color(0xFF000000); // Saf OLED Siyahı
    const surfaceColor = Color(0xFF111111); // Çok Koyu Gri (Kartlar)
    const accentColor = Colors.white; // Vurgular Saf Beyaz
    const textMuted = Colors.white54; // Sönük Yazılar

    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.menu, color: accentColor), onPressed: () => _testTiklama("Yan Menü")),
        title: const Text('O T O D N A', style: TextStyle(color: accentColor, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 6)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.person_outline, color: accentColor), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SiberProfilScreen()))),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Gazi", style: TextStyle(color: accentColor, fontSize: 32, fontWeight: FontWeight.w600, letterSpacing: -1)),
              const SizedBox(height: 32),

              const Text("Aktif Araç", style: TextStyle(color: textMuted, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.directions_car_outlined, color: accentColor, size: 40),
                    const SizedBox(width: 20),
                    const Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("34 DNA 001", style: TextStyle(color: accentColor, fontSize: 22, fontWeight: FontWeight.w700)),
                              SizedBox(height: 4),
                              Text("Kusursuz Durum • %98", style: TextStyle(color: textMuted, fontSize: 13))
                            ]
                        )
                    ),
                    Icon(Icons.arrow_forward_ios, color: accentColor.withOpacity(0.3), size: 16),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SiberHedefliReklamPanosu(
                kampanya: OtoDNACampaign(
                  id: "cmp_test_001",
                  sirketAd: "Kuantum Yedek Parça A.Ş.",
                  kampanyaBaslik: "10.000 KM Bakım Seti - %15 İndirim (Sizin Aracınıza Özel)",
                  gorselUrl: "https://via.placeholder.com/600x200/000000/FFD700?text=BAKIM+SETI",
                  hedefLink: "https://otodna.com/kampanyalar/bakim-seti",
                  tiklanmaSayisi: 1240,
                  aktifMi: true,
                ),
              ),
              const SizedBox(height: 32),

              const Text("Ağ Modülleri", style: TextStyle(color: textMuted, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3,
                children: [
                  _buildTeslaCard("Araç Kaydet", Icons.add_to_photos_outlined),
                  _buildTeslaCard("İkinci El Market", Icons.storefront_outlined),
                  _buildTeslaCard("Usta Paneli", Icons.engineering_outlined),
                  _buildTeslaCard("Dijital Servis", Icons.build_circle_outlined),
                  _buildTeslaCard("Yedek Parça", Icons.settings_outlined),
                  _buildTeslaCard("Kripto Cüzdan", Icons.account_balance_wallet_outlined),
                  _buildTeslaCard("QR Doğrulama", Icons.qr_code_scanner_outlined),
                  _buildTeslaCard("Değer Kaybı", Icons.gavel_outlined),
                ],
              ),

              const SizedBox(height: 40),

              Row(
                children: [
                  Expanded(child: _buildSadeButon("Akıllı Tarama", Icons.camera_alt_outlined, false)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSadeButon("Acil Durum", Icons.sos_outlined, true)),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: bgColor,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedItemColor: accentColor,
        unselectedItemColor: Colors.white24,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        currentIndex: _seciliSekme,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SiberDnaRadarScreen()));
          } else if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SiberProfilScreen()));
          } else {
            setState(() => _seciliSekme = index);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.home_filled)), label: "Ana Sayfa"),
          BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.directions_car_outlined)), label: "Araçlarım"),
          BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.grid_view_outlined)), label: "Hizmetler"),
          BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.person_outline)), label: "Profil"),
        ],
      ),
    );
  }

  Widget _buildTeslaCard(String baslik, IconData ikon) {
    return InkWell(
      onTap: () {
        if (baslik == "İkinci El Market") {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SiberIkinciElMarket()));
        } else {
          _testTiklama(baslik);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(ikon, color: Colors.white, size: 28),
            Text(baslik, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildSadeButon(String text, IconData icon, bool isDanger) {
    return InkWell(
      onTap: () => _testTiklama(text),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDanger ? Colors.redAccent.withOpacity(0.1) : const Color(0xFF111111),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isDanger ? Colors.redAccent : Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(text, style: TextStyle(color: isDanger ? Colors.redAccent : Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}