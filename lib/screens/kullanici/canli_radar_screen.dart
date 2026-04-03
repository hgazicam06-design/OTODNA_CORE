import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class CanliRadarScreen extends StatefulWidget {
  const CanliRadarScreen({super.key});

  @override
  State<CanliRadarScreen> createState() => _CanliRadarScreenState();
}

class _CanliRadarScreenState extends State<CanliRadarScreen> with TickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  late AnimationController _pulseController;

  // Anlık Simülasyon Verileri
  int _anlikHiz = 82;
  final int _hizSiniri = 90;
  final String _hedef = "Ankara Şehir Hastanesi";
  final String _kalanSure = "24 dk";
  final String _kalanMesafe = "18.5 km";

  // Rota Üzerindeki Uyarılar ve Noktalar
  final List<Map<String, dynamic>> _rotaOlaylari = [
    {'tip': 'radar', 'mesafe': '1.2 km', 'baslik': 'Hız Radarı / Çevirme', 'renk': Colors.orangeAccent, 'ikon': Icons.radar},
    {'tip': 'kaza', 'mesafe': '3.5 km', 'baslik': 'Sağ Şeritte Kaza', 'renk': Colors.redAccent, 'ikon': Icons.car_crash},
    {'tip': 'otodna', 'mesafe': '5.0 km', 'baslik': 'OtoDNA Nöbetçi Usta (Açık)', 'renk': const Color(0xFF00FFC2), 'ikon': Icons.build_circle},
    {'tip': 'sarj', 'mesafe': '8.2 km', 'baslik': 'ZES Hızlı Şarj (2 Soket Boş)', 'renk': Colors.greenAccent, 'ikon': Icons.ev_station},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _sistemiBaslat();
  }

  void _sistemiBaslat() async {
    await _flutterTts.setLanguage("tr-TR");
    await _flutterTts.setSpeechRate(0.5);
    await Future.delayed(const Duration(milliseconds: 500));
    _flutterTts.speak("Oto DNA canlı radar aktif. Hedefe 18 kilometre kaldı. İleride, 1 nokta 2 kilometre sonra hız radarı tespit edildi. Güvenli sürüşler komutan.");
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  // Yolda Olay Bildirimi (Waze Mantığı)
  void _olayBildir() {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: const Color(0xFF121B2B), // Dijital Kale Kart Rengi
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: const Color(0xFF00FFC2).withOpacity(0.3))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF00FFC2).withOpacity(0.5), borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 24),
            const Text("SİBER AĞA BİLDİRİM YAP", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBildirimButonu(Icons.radar, "Çevirme", Colors.orangeAccent),
                _buildBildirimButonu(Icons.car_crash, "Kaza", Colors.redAccent),
                _buildBildirimButonu(Icons.warning, "Tehlike", Colors.yellowAccent),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBildirimButonu(IconData icon, String text, Color color) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$text bildirimi merkeze iletildi! Teşekkürler.'), backgroundColor: color));
      },
      child: Container(
        width: 100, padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(color: const Color(0xFF070B14), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.3)), boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 15)]),
        child: Column(
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 28)),
              const SizedBox(height: 12),
              Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1))
            ]
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🌑 DİJİTAL KALE RENKLERİ GÜNCELLENDİ
    const primaryCyan = Color(0xFF00FFC2);
    const bgColor = Color(0xFF070B14); // Uzay Siyahı
    const cardColor = Color(0xFF121B2B); // Yarı Saydam Koyu Cam

    return Scaffold(
      backgroundColor: bgColor,
      // 🗺️ ARKA PLAN (Siber Harita Simülasyonu)
      body: Stack(
        children: [
          // Koyu Grid Arka Plan
          Positioned.fill(
            child: Opacity(
              opacity: 0.1, // Haritayı biraz daha karanlık yaptık
              child: Image.network(
                'https://img.freepik.com/free-vector/dark-hexagonal-background-with-gradient-color_79603-1409.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Rota Çizgisi (Neon Turkuaz Efekti)
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 3,
            top: 150, bottom: 200,
            child: Container(
                width: 6,
                decoration: BoxDecoration(
                    color: primaryCyan.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.5), blurRadius: 15)] // Işıma Efekti
                )
            ),
          ),

          // Kullanıcı Aracı (Nabız Animasyonlu Kuantum Gözü)
          Positioned(
            bottom: 220, left: MediaQuery.of(context).size.width / 2 - 30,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: primaryCyan.withOpacity(0.15), border: Border.all(color: primaryCyan.withOpacity(0.5), width: 2), boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.5 * _pulseController.value), blurRadius: 25, spreadRadius: 5)]),
                  child: const Icon(Icons.navigation, color: primaryCyan, size: 32),
                );
              },
            ),
          ),

          // Olay İşaretçileri (Markers)
          Positioned(top: 200, left: MediaQuery.of(context).size.width / 2 - 20, child: _buildHaritaMarker(Icons.radar, Colors.orangeAccent)),
          Positioned(top: 300, left: MediaQuery.of(context).size.width / 2 + 30, child: _buildHaritaMarker(Icons.build_circle, primaryCyan)),
          Positioned(top: 450, left: MediaQuery.of(context).size.width / 2 - 60, child: _buildHaritaMarker(Icons.car_crash, Colors.redAccent)),

          // -----------------------------------------------------
          // 📲 ARAYÜZ (HUD) KATMANI (Kuantum Cam Tasarımı)
          // -----------------------------------------------------
          SafeArea(
            child: Column(
              children: [
                // ÜST BAR: Hedef ve Arama
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Container(decoration: BoxDecoration(color: bgColor.withOpacity(0.5), shape: BoxShape.circle), child: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: primaryCyan, size: 20), onPressed: () => Navigator.pop(context))),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(color: cardColor.withOpacity(0.9), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
                          child: Row(
                            children: [
                              const Icon(Icons.radar, color: primaryCyan, size: 18),
                              const SizedBox(width: 12),
                              Expanded(child: Text(_hedef, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1), overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          _flutterTts.speak("Sizi dinliyorum. Nereye gitmek istersiniz?");
                        },
                        child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle, border: Border.all(color: primaryCyan.withOpacity(0.5)), boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.2), blurRadius: 10)]),
                            child: const Icon(Icons.mic, color: primaryCyan, size: 22)
                        ),
                      )
                    ],
                  ),
                ),

                // YAKLAŞAN OLAYLAR BİLDİRİM PANELİ (Sağ Üst)
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 220, margin: const EdgeInsets.only(right: 16, top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: _rotaOlaylari.map((olay) => _buildKucukOlayKarti(olay)).toList(),
                    ),
                  ),
                ),

                const Spacer(),

                // BİLDİRİM YAP BUTONU (Waze Mantığı - Neon Kırmızı)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20, bottom: 20),
                    child: FloatingActionButton(
                      backgroundColor: cardColor,
                      elevation: 10,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.orangeAccent.withOpacity(0.5))),
                      heroTag: "bildir",
                      onPressed: _olayBildir,
                      child: const Icon(Icons.add_alert, color: Colors.orangeAccent, size: 28),
                    ),
                  ),
                ),

                // ALT PANEL: Hız Göstergesi ve Varış Bilgileri (Kuantum Camı)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                      border: const Border(top: BorderSide(color: Colors.white12)),
                      boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -10))]
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Hız Göstergesi (Neon Halkalı)
                      Column(
                        children: [
                          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.redAccent, width: 2.5), color: bgColor), child: Text("$_hizSiniri", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))),
                          const SizedBox(height: 8),
                          Text("$_anlikHiz", style: TextStyle(color: _anlikHiz > _hizSiniri ? Colors.redAccent : primaryCyan, fontSize: 42, fontWeight: FontWeight.w900, height: 1)),
                          const Text("KM/S", style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        ],
                      ),

                      // Rota Bilgileri
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("VARIŞ SÜRESİ", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                          Text(_kalanSure, style: const TextStyle(color: Colors.greenAccent, fontSize: 28, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 4),
                          Text("Mesafe: $_kalanMesafe", style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.withOpacity(0.1), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.redAccent.withOpacity(0.5)))),
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: Colors.redAccent, size: 16),
                            label: const Text("ROTADAN ÇIK", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1)),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Harita Üzerindeki İkonlar (Işımalı)
  Widget _buildHaritaMarker(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: const Color(0xFF121B2B), shape: BoxShape.circle, border: Border.all(color: color, width: 2), boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 15)]),
      child: Icon(icon, color: color, size: 20),
    );
  }

  // Sağ Üstte Çıkan Yaklaşan Olay Kartları (Glassmorphism)
  Widget _buildKucukOlayKarti(Map<String, dynamic> olay) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFF121B2B).withOpacity(0.9), borderRadius: BorderRadius.circular(12), border: Border.all(color: olay['renk'].withOpacity(0.3))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(olay['ikon'], color: olay['renk'], size: 18),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(olay['baslik'], style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(olay['mesafe'], style: TextStyle(color: olay['renk'], fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ],
          )
        ],
      ),
    );
  }
}