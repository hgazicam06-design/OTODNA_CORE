import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class CanliRadarScreen extends StatefulWidget {
  CanliRadarScreen({super.key});

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
    {'tip': 'radar', 'mesafe': '1.2 km', 'baslik': 'Hız Radarı / Çevirme', 'renk': Colors.orange, 'ikon': Icons.radar},
    {'tip': 'kaza', 'mesafe': '3.5 km', 'baslik': 'Sağ Şeritte Kaza', 'renk': Colors.redAccent, 'ikon': Icons.car_crash},
    {'tip': 'otodna', 'mesafe': '5.0 km', 'baslik': 'OtoDNA Nöbetçi Usta (Açık)', 'renk': Colors.teal.shade700, 'ikon': Icons.build_circle},
    {'tip': 'sarj', 'mesafe': '8.2 km', 'baslik': 'ZES Hızlı Şarj (2 Soket Boş)', 'renk': Colors.green, 'ikon': Icons.ev_station},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: Duration(seconds: 2))..repeat(reverse: true);
    _sistemiBaslat();
  }

  void _sistemiBaslat() async {
    await _flutterTts.setLanguage("tr-TR");
    await _flutterTts.setSpeechRate(0.5);
    await Future.delayed(Duration(milliseconds: 500));
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
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: Colors.white, // Plaza Kart Rengi
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: Colors.teal.shade700.withValues(alpha: 0.3)),
            boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.1), blurRadius: 20)]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.teal.shade700.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(10))),
            SizedBox(height: 24),
            Text("AĞA BİLDİRİM YAP", style: TextStyle(color: Color(0xFF1E293B), fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBildirimButonu(Icons.radar, "Çevirme", Colors.orange),
                _buildBildirimButonu(Icons.car_crash, "Kaza", Colors.redAccent),
                _buildBildirimButonu(Icons.warning, "Tehlike", Colors.amber.shade700),
              ],
            ),
            SizedBox(height: 20),
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
        width: 100, padding: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withValues(alpha: 0.3)), boxShadow: [BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 15)]),
        child: Column(
            children: [
              Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 28)),
              SizedBox(height: 12),
              Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1, fontFamily: 'Avenir'))
            ]
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🏢 PLAZA KALİTESİ PALET
    final primaryTeal = Colors.teal.shade700;
    const bgColor = Color(0xFFFAFAFC); // Sedefli Fil Dişi
    const cardColor = Colors.white; // Saf Beyaz
    const textColor = Color(0xFF1E293B); // Koyu Lacivert

    return Scaffold(
      backgroundColor: bgColor,
      // 🗺️ ARKA PLAN (Siber Harita Simülasyonu -> Plaza Temiz Zemin)
      body: Stack(
        children: [
          // Rota Çizgisi (Teal Efekti)
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 3,
            top: 150, bottom: 200,
            child: Container(
                width: 6,
                decoration: BoxDecoration(
                    color: primaryTeal.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: primaryTeal.withValues(alpha: 0.3), blurRadius: 15)] // Işıma Efekti
                )
            ),
          ),

          // Kullanıcı Aracı (Nabız Animasyonlu Hedef Gözü)
          Positioned(
            bottom: 220, left: MediaQuery.of(context).size.width / 2 - 30,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: cardColor, border: Border.all(color: primaryTeal.withValues(alpha: 0.5), width: 2), boxShadow: [BoxShadow(color: primaryTeal.withValues(alpha: 0.2 * _pulseController.value), blurRadius: 25, spreadRadius: 5)]),
                  child: Icon(Icons.navigation, color: primaryTeal, size: 32),
                );
              },
            ),
          ),

          // Olay İşaretçileri (Markers)
          Positioned(top: 200, left: MediaQuery.of(context).size.width / 2 - 20, child: _buildHaritaMarker(Icons.radar, Colors.orange)),
          Positioned(top: 300, left: MediaQuery.of(context).size.width / 2 + 30, child: _buildHaritaMarker(Icons.build_circle, primaryTeal)),
          Positioned(top: 450, left: MediaQuery.of(context).size.width / 2 - 60, child: _buildHaritaMarker(Icons.car_crash, Colors.redAccent)),

          // -----------------------------------------------------
          // 📲 ARAYÜZ (HUD) KATMANI (Plaza Cam Tasarımı)
          // -----------------------------------------------------
          SafeArea(
            child: Column(
              children: [
                // ÜST BAR: Hedef ve Arama
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Container(decoration: BoxDecoration(color: cardColor, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.05), blurRadius: 8)]), child: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: primaryTeal, size: 20), onPressed: () => Navigator.pop(context))),
                      SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(color: cardColor.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.05), blurRadius: 10)]),
                          child: Row(
                            children: [
                              Icon(Icons.radar, color: primaryTeal, size: 18),
                              SizedBox(width: 12),
                              Expanded(child: Text(_hedef, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1, fontFamily: 'Avenir'), overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          _flutterTts.speak("Sizi dinliyorum. Nereye gitmek istersiniz?");
                        },
                        child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(color: cardColor, shape: BoxShape.circle, border: Border.all(color: primaryTeal.withValues(alpha: 0.2)), boxShadow: [BoxShadow(color: primaryTeal.withValues(alpha: 0.1), blurRadius: 10)]),
                            child: Icon(Icons.mic, color: primaryTeal, size: 22)
                        ),
                      )
                    ],
                  ),
                ),

                // YAKLAŞAN OLAYLAR BİLDİRİM PANELİ (Sağ Üst)
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 220, margin: EdgeInsets.only(right: 16, top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: _rotaOlaylari.map((olay) => _buildKucukOlayKarti(olay)).toList(),
                    ),
                  ),
                ),

                Spacer(),

                // BİLDİRİM YAP BUTONU (Waze Mantığı - Orange/Teal)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 20, bottom: 20),
                    child: FloatingActionButton(
                      backgroundColor: cardColor,
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.orange.withValues(alpha: 0.5))),
                      heroTag: "bildir",
                      onPressed: _olayBildir,
                      child: Icon(Icons.add_alert, color: Colors.orange, size: 28),
                    ),
                  ),
                ),

                // ALT PANEL: Hız Göstergesi ve Varış Bilgileri (Plaza Camı)
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                      border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
                      boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.05), blurRadius: 20, offset: Offset(0, -5))]
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Hız Göstergesi (Plaza Temiz Çember)
                      Column(
                        children: [
                          Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.redAccent, width: 2.5), color: cardColor), child: Text("$_hizSiniri", style: TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold))),
                          SizedBox(height: 8),
                          Text("$_anlikHiz", style: TextStyle(color: _anlikHiz > _hizSiniri ? Colors.redAccent : primaryTeal, fontSize: 42, fontWeight: FontWeight.w900, height: 1, fontFamily: 'Avenir')),
                          Text("KM/S", style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
                        ],
                      ),

                      // Rota Bilgileri
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("VARIŞ SÜRESİ", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontFamily: 'Avenir')),
                          Text(_kalanSure, style: TextStyle(color: Colors.green, fontSize: 28, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                          SizedBox(height: 4),
                          Text("Mesafe: $_kalanMesafe", style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                          SizedBox(height: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.withValues(alpha: 0.1), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)))),
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close, color: Colors.redAccent, size: 16),
                            label: Text("ROTADAN ÇIK", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1, fontFamily: 'Avenir')),
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

  // Harita Üzerindeki İkonlar (Temiz Beyaz Arka Plan)
  Widget _buildHaritaMarker(IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: color, width: 2), boxShadow: [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 10)]),
      child: Icon(icon, color: color, size: 20),
    );
  }

  // Sağ Üstte Çıkan Yaklaşan Olay Kartları (Plaza Beyazı)
  Widget _buildKucukOlayKarti(Map<String, dynamic> olay) {
    return Container(
      margin: EdgeInsets.only(bottom: 8), padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.95), borderRadius: BorderRadius.circular(12), border: Border.all(color: olay['renk'].withValues(alpha: 0.3)), boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.05), blurRadius: 8)]),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(olay['ikon'], color: olay['renk'], size: 18),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(olay['baslik'], style: TextStyle(color: Color(0xFF1E293B), fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
              SizedBox(height: 2),
              Text(olay['mesafe'], style: TextStyle(color: olay['renk'], fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
            ],
          )
        ],
      ),
    );
  }
}