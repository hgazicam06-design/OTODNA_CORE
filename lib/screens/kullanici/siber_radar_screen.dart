import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';

class SiberRadarScreen extends StatefulWidget {
  const SiberRadarScreen({super.key});

  @override
  State<SiberRadarScreen> createState() => _SiberRadarScreenState();
}

class _SiberRadarScreenState extends State<SiberRadarScreen> with SingleTickerProviderStateMixin {
  late AnimationController _radarController;

  // SİBER RADAR VERİTABANI (Gerçek Ankara Koordinatları Eklendi)
  final List<Map<String, dynamic>> _radarHedefleri = [
    {
      "isim": "Murat Plaza (Merkez)", "tip": "Bayi", "seviye": "Altın", "mesafe": "3.2 km",
      "koordinatX": 0.7, "koordinatY": 0.3,
      "enlem": 39.92077, "boylam": 32.85411,
      "renk": Colors.amber, "ikon": Icons.storefront_outlined
    },
    {
      "isim": "S.O.S Acil Çağrı (Kaza)", "tip": "SOS", "seviye": "Acil", "mesafe": "4.1 km",
      "koordinatX": 0.2, "koordinatY": 0.4,
      "enlem": 39.91165, "boylam": 32.83965,
      "renk": Colors.redAccent, "ikon": Icons.warning_amber_rounded
    },
    {
      "isim": "İvedik OtoDNA Ekspertiz", "tip": "Bayi", "seviye": "Gümüş", "mesafe": "8.5 km",
      "koordinatX": 0.8, "koordinatY": 0.8,
      "enlem": 39.96788, "boylam": 32.77123,
      "renk": const Color(0xFFC0C0C0), "ikon": Icons.precision_manufacturing_outlined
    },
    {
      "isim": "Yenimahalle Çekici", "tip": "Bayi", "seviye": "Bronz", "mesafe": "12.0 km",
      "koordinatX": 0.3, "koordinatY": 0.8,
      "enlem": 39.96155, "boylam": 32.80582,
      "renk": const Color(0xFFCD7F32), "ikon": Icons.local_shipping_outlined
    },
  ];

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  // 🔥 İŞTE SENİN İSTEDİĞİN GERÇEK NAVİGASYON MOTORU 🔥
  void _gercekNavigasyonBaslat(double enlem, double boylam) async {
    final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$enlem,$boylam");

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Uydu bağlantısı kurulamadı (Google Haritalar açılamadı).", style: TextStyle(color: SiberTema.textMain)), backgroundColor: Colors.redAccent));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
    const bgColor = Color(0xFF000000);
    const surfaceColor = Color(0xFF111111);
    const primaryCyan = Color(0xFF00FFC2);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text("K U A N T U M   R A D A R", style: TextStyle(color: SiberTema.textMuted, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 3)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. ÜST PANEL (HUD)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Siber Ağ Taranıyor...", style: TextStyle(color: primaryCyan, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                    SizedBox(height: 6),
                    Text("Çap: 50 KM • Bölge: Ankara", style: TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.redAccent.withOpacity(0.5))),
                  child: const Row(children: [Icon(Icons.sensors, color: Colors.redAccent, size: 16), SizedBox(width: 6), Text("1 AKTİF ÇAĞRI", style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1))]),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. RADAR EKRANI (Tesla Glow Efekti)
          Expanded(
            flex: 5,
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: bgColor,
                      border: Border.all(color: primaryCyan.withOpacity(0.3), width: 1.5),
                      boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.1), blurRadius: 50, spreadRadius: 10)]
                  ),
                  child: ClipOval(
                    child: Stack(
                      children: [
                        Center(child: Container(width: MediaQuery.of(context).size.width * 0.6, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: primaryCyan.withOpacity(0.1), width: 1)))),
                        Center(child: Container(width: MediaQuery.of(context).size.width * 0.3, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: primaryCyan.withOpacity(0.2), width: 1)))),
                        Center(child: Container(width: 6, height: 6, decoration: BoxDecoration(color: primaryCyan, shape: BoxShape.circle, boxShadow: [BoxShadow(color: primaryCyan, blurRadius: 10)]))),
                        Center(child: Container(width: double.infinity, height: 1, color: primaryCyan.withOpacity(0.15))),
                        Center(child: Container(width: 1, height: double.infinity, color: primaryCyan.withOpacity(0.15))),

                        // Tarayıcı Işın
                        AnimatedBuilder(
                          animation: _radarController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _radarController.value * 2 * math.pi,
                              child: Container(decoration: BoxDecoration(shape: BoxShape.circle, gradient: SweepGradient(colors: [Colors.transparent, primaryCyan.withOpacity(0.1), primaryCyan.withOpacity(0.8)], stops: const [0.0, 0.9, 1.0]))),
                            );
                          },
                        ),

                        // Radar Hedefleri
                        ..._radarHedefleri.map((hedef) {
                          return Align(
                            alignment: FractionalOffset(hedef['koordinatX'], hedef['koordinatY']),
                            child: _buildRadarNoktasi(hedef['renk'], hedef['ikon'], hedef['tip'] == "SOS"),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 3. TESPİT EDİLEN HEDEFLER (ALT PANEL)
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(color: surfaceColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(32)), border: Border.all(color: Colors.white.withOpacity(0.05))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: SiberTema.textMuted, borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 24),
                  const Text("Sinyal Tespit Edilen Noktalar", style: TextStyle(color: SiberTema.textMain, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.5)),
                  const SizedBox(height: 16),

                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _radarHedefleri.length,
                      itemBuilder: (context, index) {
                        var hedef = _radarHedefleri[index];
                        bool isSOS = hedef['tip'] == "SOS";

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isSOS ? Colors.redAccent.withOpacity(0.3) : Colors.white.withOpacity(0.05)),
                              boxShadow: isSOS ? [BoxShadow(color: Colors.redAccent.withOpacity(0.05), blurRadius: 10)] : []
                          ),
                          child: Row(
                            children: [
                              Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(color: hedef['renk'].withOpacity(0.05), shape: BoxShape.circle, border: Border.all(color: hedef['renk'].withOpacity(0.3))),
                                  child: Icon(hedef['ikon'], color: hedef['renk'], size: 24)
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(hedef['isim'], style: TextStyle(color: isSOS ? Colors.redAccent : Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                                    const SizedBox(height: 6),
                                    Row(
                                        children: [
                                          if (!isSOS) ...[Icon(Icons.workspace_premium_outlined, color: hedef['renk'], size: 14), const SizedBox(width: 4)],
                                          Text("${hedef['seviye']} ${isSOS ? 'Sinyali' : 'Noktası'}", style: TextStyle(color: isSOS ? Colors.redAccent : Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                                        ]
                                    )
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(hedef['mesafe'], style: const TextStyle(color: primaryCyan, fontSize: 15, fontWeight: FontWeight.w900)),
                                  const SizedBox(height: 8),
                                  // 🔥 GERÇEK NAVİGASYON BURAYA BAĞLANDI 🔥
                                  GestureDetector(
                                    onTap: () => _gercekNavigasyonBaslat(hedef['enlem'], hedef['boylam']),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blueAccent.withOpacity(0.5))),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.navigation_outlined, color: Colors.blueAccent, size: 12),
                                          SizedBox(width: 4),
                                          Text("ROTA ÇİZ", style: TextStyle(color: Colors.blueAccent, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // 💎 TESLA MİMARİSİ: HOLOGRAFİK RADAR NOKTALARI
  Widget _buildRadarNoktasi(Color renk, IconData ikon, bool isSOS) {
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
          color: const Color(0xFF000000),
          shape: BoxShape.circle,
          border: Border.all(color: renk, width: 2),
          boxShadow: [BoxShadow(color: renk.withOpacity(0.8), blurRadius: 15, spreadRadius: isSOS ? 5 : 2)]
      ),
      child: Icon(ikon, color: renk, size: 14),
    );
  }
}