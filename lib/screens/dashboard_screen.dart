import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';
import '../tests/sistem_test_motoru.dart';
import 'catalog_screen.dart';
import 'appointment_screen.dart';

/// 🦅 OTODNA ANKARA KARARGAH KOMUTA MERKEZİ
/// Bu ekran, sistemin tüm alt modüllerine erişim sağlayan ana siber portaldır.
class OtoDNADashboard extends StatelessWidget {
  const OtoDNADashboard({super.key});

  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  static const Color bgColor = Color(0xFF000000);
  static const Color surfaceColor = Color(0xFF111111);
  static const Color primaryCyan = Color(0xFF00FFC2);
  static const Color dangerColor = Colors.redAccent;

  @override
  Widget build(BuildContext context) {
    // 💻 Web Responsive (Duyarlı) Kalkanı
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 1200 ? 4 : (screenWidth > 800 ? 3 : 2);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'O T O D N A   A N K A R A   K A R A R G A H I',
          style: TextStyle(
              color: SiberTema.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
              fontFamily: 'Avenir'
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("SİBER TARAMA BAŞLATILIYOR...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        backgroundColor: primaryCyan
                    )
                );
                SistemTestMotoru.tumSistemiTestEt(context);
              },
              icon: const Icon(Icons.radar, color: Colors.orangeAccent, size: 18),
              label: const Text("SİSTEMİ TARA", style: TextStyle(color: Colors.orangeAccent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.orangeAccent.withOpacity(0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🛰️ SİBER BAŞLIK
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Row(
                  children: [
                    Icon(Icons.dashboard_customize_outlined, color: primaryCyan, size: 24),
                    const SizedBox(width: 12),
                    const Text(
                        "SİBER KOMUTA MODÜLLERİ",
                        style: TextStyle(color: SiberTema.textMain, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2)
                    ),
                  ],
                ),
              ),

              // 📦 MODÜLER IZGARA
              Expanded(
                child: GridView.count(
                  crossAxisCount: crossAxisCount,
                  padding: const EdgeInsets.all(24),
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: 1.2,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildSiberMenuTile(
                        context,
                        "SİBER KATALOG",
                        "Oto Market Ağı",
                        Icons.view_list_rounded,
                        const CatalogScreen()
                    ),
                    _buildSiberMenuTile(
                        context,
                        "AKILLI SÖZLEŞME",
                        "Randevu Mühürleme",
                        Icons.event_available_rounded,
                        const AppointmentScreen()
                    ),
                    // Finans Modülü: Burası %12 payımızı takip edeceğimiz terminale bağlanacak
                    _buildSiberMenuTile(
                        context,
                        "FİNANS & HAVUZ",
                        "Kasa ve %12 Kesintiler",
                        Icons.account_balance_wallet_rounded,
                        _dummyScreen("SİBER FİNANS TERMİNALİ")
                    ),
                    _buildSiberMenuTile(
                        context,
                        "MERKEZ DESTEK",
                        "İstihbarat ve Yardım",
                        Icons.support_agent_rounded,
                        _dummyScreen("KARARGAH DESTEK HATTI")
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: SİBER MODÜL KARTI
  Widget _buildSiberMenuTile(BuildContext context, String title, String subtitle, IconData icon, Widget page) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(color: primaryCyan.withOpacity(0.02), blurRadius: 20, spreadRadius: 2)
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // İkon için neon çerçeveli Kuantum kutusu
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: Border.all(color: primaryCyan.withOpacity(0.3), width: 1.5),
                boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.1), blurRadius: 15)],
              ),
              child: Icon(icon, size: 36, color: primaryCyan),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: SiberTema.textMain, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dummyScreen(String title) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(title, style: const TextStyle(color: primaryCyan, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        leading: const BackButton(color: Colors.white),
      ),
      body: const Center(
        child: Text("SİBER PROTOKOLLER YÜKLENİYOR...", style: TextStyle(color: SiberTema.textMuted, fontWeight: FontWeight.bold)),
      ),
    );
  }
}