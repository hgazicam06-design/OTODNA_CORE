import 'package:flutter/material.dart';
import 'siber_dijital_torpido_screen.dart';

class SiberGarajScreen extends StatefulWidget {
  const SiberGarajScreen({super.key});

  @override
  State<SiberGarajScreen> createState() => _SiberGarajScreenState();
}

class _SiberGarajScreenState extends State<SiberGarajScreen> with SingleTickerProviderStateMixin {
  late AnimationController _kalkanController;

  @override
  void initState() {
    super.initState();
    // Kalkan animasyonu daha akıcı ve siber bir nabız (pulse) efekti verecek
    _kalkanController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _kalkanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
    const primaryCyan = Color(0xFF00FFC2);
    const bgColor = Color(0xFF000000);
    const surfaceColor = Color(0xFF111111);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text("K U A N T U M   G A R A J", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 3)),
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(Icons.folder_shared_outlined, color: primaryCyan),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SiberDijitalTorpidoScreen()))
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. ARAÇ GÖRÜNÜMÜ VE NEON SİBER KALKAN EFEKTİ
            Center(
              child: AnimatedBuilder(
                animation: _kalkanController,
                builder: (context, child) {
                  return Container(
                    width: double.infinity,
                    height: 220,
                    decoration: BoxDecoration(
                        color: surfaceColor,
                        gradient: RadialGradient(
                          colors: [primaryCyan.withOpacity(0.08 * _kalkanController.value), Colors.transparent],
                          radius: 0.8,
                        ),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: primaryCyan.withOpacity(0.1 + (0.3 * _kalkanController.value)), width: 1),
                        boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.05 * _kalkanController.value), blurRadius: 30, spreadRadius: 5)]
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Ağ Bağlantı Sinyali
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: 8, height: 8, decoration: BoxDecoration(color: primaryCyan, shape: BoxShape.circle, boxShadow: [BoxShadow(color: primaryCyan, blurRadius: 6)])),
                            const SizedBox(width: 8),
                            const Text("AĞA BAĞLI (ONLİNE)", style: TextStyle(color: primaryCyan, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Icon(Icons.directions_car_outlined, color: Colors.white, size: 72),
                        const SizedBox(height: 24),
                        // Premium Plaka Tasarımı
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(color: const Color(0xFF000000), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white24, width: 1.5)),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("TR", style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.w900)),
                              SizedBox(width: 12),
                              Text("34 DNA 2026", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 3)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            // 2. ARAÇ KİMLİĞİ VE DURUMU
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Tesla Model Y", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.5)),
                    SizedBox(height: 4),
                    Text("Long Range • 2024 • Elektrikli", style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 0.5)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.greenAccent.withOpacity(0.3))),
                  child: const Row(
                    children: [
                      Icon(Icons.shield_outlined, color: Colors.greenAccent, size: 16),
                      SizedBox(width: 6),
                      Text("KUSURSUZ", style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 40),

            // 3. ANLIK SENSÖR VERİLERİ (Holografik Kartlar)
            Row(
              children: [
                _buildSensorKarti(Icons.speed_outlined, "Kilometre", "15.420", primaryCyan),
                const SizedBox(width: 12),
                _buildSensorKarti(Icons.health_and_safety_outlined, "Motor Sağlığı", "%98", Colors.greenAccent),
                const SizedBox(width: 12),
                _buildSensorKarti(Icons.calendar_month_outlined, "Muayene", "45 Gün", Colors.orangeAccent),
              ],
            ),
            const SizedBox(height: 40),

            // 4. İŞTE O DEVASA DİJİTAL TORPİDO BUTONU! (Neon Şeffaf Vurgu)
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SiberDijitalTorpidoScreen())),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: primaryCyan.withOpacity(0.5), width: 1.5),
                  boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.05), blurRadius: 20)],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle, border: Border.all(color: primaryCyan.withOpacity(0.3))),
                      child: const Icon(Icons.folder_shared_outlined, color: primaryCyan, size: 28),
                    ),
                    const SizedBox(width: 20),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Dijital Torpido", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                          SizedBox(height: 4),
                          Text("Ruhsat, sigorta ve resmi evraklar", style: TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.3), size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // 5. DİĞER GARAJ AKSİYONLARI (Flat Minimalist Butonlar)
            const Text("Hızlı Komutlar", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildAksiyonButonu(Icons.sell_outlined, "SATIŞA ÇIKAR", Colors.blueAccent, () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Araç İkinci El Ağına Yükleniyor...", style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.blueAccent));
                }),
                const SizedBox(width: 16),
                _buildAksiyonButonu(Icons.science_outlined, "DNA RAPORU", Colors.purpleAccent, () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Genetik Rapor Açılıyor...", style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.purpleAccent));
                }),
              ],
            ),
            const SizedBox(height: 80), // Alt menü boşluğu
          ],
        ),
      ),
    );
  }

  // 💎 TESLA MİMARİSİ: HOLOGRAFİK SENSÖR KARTLARI
  Widget _buildSensorKarti(IconData ikon, String baslik, String deger, Color renk) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
        child: Column(
          children: [
            Icon(ikon, color: renk.withOpacity(0.8), size: 28),
            const SizedBox(height: 12),
            Text(deger, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5, shadows: [BoxShadow(color: renk.withOpacity(0.3), blurRadius: 10)])),
            const SizedBox(height: 4),
            Text(baslik.toUpperCase(), style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // 💎 TESLA MİMARİSİ: FLAT AKSİYON BUTONLARI
  Widget _buildAksiyonButonu(IconData ikon, String baslik, Color renk, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(20), border: Border.all(color: renk.withOpacity(0.3))),
          child: Column(
            children: [
              Icon(ikon, color: renk, size: 28),
              const SizedBox(height: 12),
              Text(baslik, style: TextStyle(color: renk, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ],
          ),
        ),
      ),
    );
  }
}