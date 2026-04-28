import 'package:otodna/core/siber_tema.dart';
import 'package:flutter/material.dart';
import 'siber_dijital_torpido_screen.dart';

class SiberGarajScreen extends StatefulWidget {
  SiberGarajScreen({super.key});

  @override
  State<SiberGarajScreen> createState() => _SiberGarajScreenState();
}

class _SiberGarajScreenState extends State<SiberGarajScreen> with SingleTickerProviderStateMixin {
  late AnimationController _kalkanController;

  final Color primaryTeal = Colors.teal.shade700;
  final Color textColor = Color(0xFF1E293B);
  final Color bgColor = Color(0xFFFAFAFC);
  final Color surfaceColor = Colors.white;

  @override
  void initState() {
    super.initState();
    // Plaza kalitesinde hafif, nefes alan (breathing) bir gölge efekti
    _kalkanController = AnimationController(vsync: this, duration: Duration(milliseconds: 2000))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _kalkanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: primaryTeal, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text("P L A Z A   G A R A J", style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 3, fontFamily: 'Avenir')),
        centerTitle: true,
        actions: [
          IconButton(
              icon: Icon(Icons.folder_shared_outlined, color: primaryTeal),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SiberDijitalTorpidoScreen()))
          ),
          SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 0. DİJİTAL GARAJ BANNER GÖRSELİ
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Image.asset('assets/images/dijital_garaj_banner.jpg', width: double.infinity, height: 180, fit: BoxFit.cover),
            ),
            SizedBox(height: 24),

            // 1. ARAÇ GÖRÜNÜMÜ VE PLAZA ZEMİN EFEKTİ
            Center(
              child: AnimatedBuilder(
                animation: _kalkanController,
                builder: (context, child) {
                  return Container(
                    width: double.infinity,
                    height: 220,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
                        boxShadow: [
                          BoxShadow(color: primaryTeal.withValues(alpha: 0.05 + (0.1 * _kalkanController.value)), blurRadius: 40, spreadRadius: 10, offset: Offset(0, 10))
                        ]
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Ağ Bağlantı Sinyali
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: 8, height: 8, decoration: BoxDecoration(color: primaryTeal, shape: BoxShape.circle, boxShadow: [BoxShadow(color: primaryTeal.withValues(alpha: 0.5), blurRadius: 6)])),
                            SizedBox(width: 8),
                            Text("SİSTEME BAĞLI (ONLİNE)", style: TextStyle(color: primaryTeal, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
                          ],
                        ),
                        SizedBox(height: 24),
                        Icon(Icons.directions_car_outlined, color: textColor.withValues(alpha: 0.5), size: 72),
                        SizedBox(height: 24),
                        // Premium Plaka Tasarımı (Gerçekçi TR Plaka Görünümü)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white, 
                            borderRadius: BorderRadius.circular(8), 
                            border: Border.all(color: Colors.white70, width: 2),
                            boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.1), blurRadius: 5, offset: Offset(0, 2))]
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.blue.shade700, borderRadius: BorderRadius.circular(4)),
                                child: Text("TR", style: TextStyle(color: SiberTema.textMain, fontSize: 10, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                              ),
                              SizedBox(width: 12),
                              Text("34 DNA 2026", style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 32),

            // 2. ARAÇ KİMLİĞİ VE DURUMU
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Tesla Model Y", style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Avenir')),
                    SizedBox(height: 4),
                    Text("Long Range • 2024 • Elektrikli", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5, fontFamily: 'Avenir')),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.withValues(alpha: 0.3))),
                  child: Row(
                    children: [
                      Icon(Icons.shield_outlined, color: Colors.green.shade700, size: 16),
                      SizedBox(width: 6),
                      Text("KUSURSUZ", style: TextStyle(color: Colors.green.shade700, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 40),

            // 3. ANLIK SENSÖR VERİLERİ (Kurumsal Kartlar)
            Row(
              children: [
                _buildSensorKarti(Icons.speed_outlined, "Kilometre", "15.420", primaryTeal),
                SizedBox(width: 12),
                _buildSensorKarti(Icons.health_and_safety_outlined, "Motor Sağlığı", "%98", Colors.green),
                SizedBox(width: 12),
                _buildSensorKarti(Icons.calendar_month_outlined, "Muayene", "45 Gün", Colors.orange),
              ],
            ),
            SizedBox(height: 40),

            // 4. DİJİTAL TORPİDO BUTONU
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SiberDijitalTorpidoScreen())),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 20, offset: Offset(0, 5))],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(color: primaryTeal.withValues(alpha: 0.1), shape: BoxShape.circle, border: Border.all(color: primaryTeal.withValues(alpha: 0.3))),
                      child: Icon(Icons.folder_shared_outlined, color: primaryTeal, size: 28),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Dijital Torpido", style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Avenir')),
                          SizedBox(height: 6),
                          Text("Ruhsat, sigorta ve resmi evraklar", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.white.withValues(alpha: 0.2), size: 16),
                  ],
                ),
              ),
            ),
            SizedBox(height: 40),

            // 5. DİĞER GARAJ AKSİYONLARI (Flat Minimalist Butonlar)
            Text("Hızlı Komutlar", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
            SizedBox(height: 16),
            Row(
              children: [
                _buildAksiyonButonu(Icons.sell_outlined, "SATIŞA ÇIKAR", Colors.blue.shade700, () {
                  _plazaUyariGoster("SATIŞ AĞI", "Araç İkinci El Ağına Yükleniyor...", Colors.blue.shade700);
                }),
                SizedBox(width: 16),
                _buildAksiyonButonu(Icons.science_outlined, "DNA RAPORU", Colors.purple.shade700, () {
                  _plazaUyariGoster("DNA ANALİZİ", "Genetik Rapor Açılıyor...", Colors.purple.shade700);
                }),
              ],
            ),
            SizedBox(height: 80), // Alt menü boşluğu
          ],
        ),
      ),
    );
  }

  // 💎 KURUMSAL SENSÖR KARTLARI
  Widget _buildSensorKarti(IconData ikon, String baslik, String deger, Color renk) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 10, offset: Offset(0, 4))]),
        child: Column(
          children: [
            Icon(ikon, color: renk, size: 28),
            SizedBox(height: 16),
            Text(deger, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Avenir')),
            SizedBox(height: 6),
            Text(baslik.toUpperCase(), style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir'), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // 💎 BEYAZ AKSİYON BUTONLARI
  Widget _buildAksiyonButonu(IconData ikon, String baslik, Color renk, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: renk.withValues(alpha: 0.3)), boxShadow: [BoxShadow(color: renk.withValues(alpha: 0.05), blurRadius: 10, offset: Offset(0, 4))]),
          child: Column(
            children: [
              Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: renk.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(ikon, color: renk, size: 24)),
              SizedBox(height: 16),
              Text(baslik, style: TextStyle(color: renk, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
            ],
          ),
        ),
      ),
    );
  }

  void _plazaUyariGoster(String baslik, String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: renk, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
            SizedBox(height: 4),
            Text(mesaj, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
          ],
        ),
      ),
    );
  }
}