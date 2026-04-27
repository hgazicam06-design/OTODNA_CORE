import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SosProtokoluScreen extends StatefulWidget {
  const SosProtokoluScreen({super.key});

  @override
  State<SosProtokoluScreen> createState() => _SosProtokoluScreenState();
}

class _SosProtokoluScreenState extends State<SosProtokoluScreen> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // SİBER RENK PALETİ
  final Color _bgKaranlik = const Color(0xFF050505);
  final Color _neonCyan = const Color(0xFF00F0FF);
  final Color _kanKirmizi = const Color(0xFFFF2A2A);

  // 5 SANİYE KURALI DEĞİŞKENLERİ
  Timer? _sinyalZamanlayici;
  double _dolumOrani = 0.0;
  bool _sinyalGonderildi = false;
  final int _gerekliSaniye = 5;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(_pulseController);
  }

  @override
  void dispose() {
    _sinyalZamanlayici?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  // --- SİBER GÖZ ATEŞLEME PROTOKOLÜ ---
  void _sinyalBaslat(TapDownDetails details) {
    if (_sinyalGonderildi) return;

    _sinyalZamanlayici = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _dolumOrani += 100 / (_gerekliSaniye * 1000);
        if (_dolumOrani >= 1.0) {
          _dolumOrani = 1.0;
          timer.cancel();
          _matrikseSosGonder();
        }
      });
    });
  }

  void _sinyalIptal() {
    if (_sinyalGonderildi) return;
    _sinyalZamanlayici?.cancel();
    setState(() => _dolumOrani = 0.0);
  }

  Future<void> _matrikseSosGonder() async {
    setState(() => _sinyalGonderildi = true);

    try {
      // SİBER KARARGAHA CANLI YAZMA İŞLEMİ (MOCKUP YOK!)
      await _db.collection('sos_sinyalleri').add({
        'kullanici_id': _currentUser?.uid ?? 'BİLİNMEYEN_KULLANICI',
        'tarih': FieldValue.serverTimestamp(),
        'durum': 'aktif_alarm',
        // İleride buraya Geolocator paketi ile gerçek enlem/boylam gelecek
        'konum': const GeoPoint(39.92077, 32.85411), // Ankara Merkez (Karargah)
        'hasar_fotografi_url': null,
        'karsi_plaka_url': null,
      });

      _siberUyariVer("S.O.S SİNYALİ KARARGAHA ULAŞTI! 50KM RADAR AKTİF.");
    } catch (e) {
      _siberUyariVer("AĞ HATASI: Sinyal iletilemedi!");
    }
  }

  void _siberUyariVer(String mesaj) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: const TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 1)),
      backgroundColor: _kanKirmizi,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgKaranlik,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text("ACİL MÜDAHALE AĞI", style: TextStyle(color: _kanKirmizi, fontWeight: FontWeight.w900, letterSpacing: 3, fontFamily: 'Avenir', fontSize: 16)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // ARKA PLAN KAN KIRMIZISI RADAR
          Positioned.fill(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _sinyalGonderildi ? 0.2 : 0.0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [_kanKirmizi.withOpacity(0.5), _bgKaranlik],
                    stops: const [0.1, 0.8],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_sinyalGonderildi) ...[
                    Text("5 SANİYE BASILI TUT", style: TextStyle(color: SiberTema.textMain.withOpacity(0.5), fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 4, fontFamily: 'Avenir')),
                    const SizedBox(height: 40),

                    // 5 SANİYE KURALI BUTONU
                    GestureDetector(
                      onTapDown: _sinyalBaslat,
                      onTapUp: (_) => _sinyalIptal(),
                      onTapCancel: _sinyalIptal,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _dolumOrani > 0 ? 1.1 : _pulseAnimation.value,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // DIŞ DOLUM HALKASI
                                SizedBox(
                                  width: 220,
                                  height: 220,
                                  child: CircularProgressIndicator(
                                    value: _dolumOrani,
                                    strokeWidth: 10,
                                    backgroundColor: Colors.white.withOpacity(0.05),
                                    color: _kanKirmizi,
                                  ),
                                ),
                                // İÇ KIRMIZI ÇEKİRDEK
                                Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _kanKirmizi.withOpacity(0.2 + (_dolumOrani * 0.8)),
                                    border: Border.all(color: _kanKirmizi, width: 4),
                                    boxShadow: [
                                      BoxShadow(color: _kanKirmizi.withOpacity(0.5), blurRadius: 30, spreadRadius: 10 * _dolumOrani)
                                    ],
                                  ),
                                  child: Center(
                                    child: Icon(Icons.sos_rounded, color: Colors.white, size: 80, shadows: [Shadow(color: Colors.white.withOpacity(0.5), blurRadius: 10)]),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Text("Asılsız ihbarlar OtoDNA Karargahı tarafından tespit edilir ve sistemden ihracınıza neden olabilir.", textAlign: TextAlign.center, style: TextStyle(color: SiberTema.textMain.withOpacity(0.3), fontSize: 10, fontFamily: 'Avenir', height: 1.5)),
                    ),
                  ] else ...[
                    // SİNYAL GÖNDERİLDİKTEN SONRA AÇILAN PANİK GEÇİRMEZ MENÜ
                    const Icon(Icons.radar, color: SiberTema.kuantumCyan, size: 60),
                    const SizedBox(height: 20),
                    const Text("SİNYAL YAYINDA", style: TextStyle(color: SiberTema.textMain, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 4, fontFamily: 'Avenir')),
                    const SizedBox(height: 8),
                    Text("Bölge bayileri konumunuza yönlendiriliyor.", style: TextStyle(color: _neonCyan, fontSize: 12, fontFamily: 'Avenir')),
                    const SizedBox(height: 50),

                    _buildSiberAksiyonButonu(Icons.camera_alt, "HASARI ÇEK", "Zaman damgalı fotoğraf yükle"),
                    const SizedBox(height: 16),
                    _buildSiberAksiyonButonu(Icons.pin_outlined, "KARŞI PLAKAYI ÇEK", "Tutanak için OCR taraması"),
                    const SizedBox(height: 16),
                    _buildSiberAksiyonButonu(Icons.phone_in_talk, "MERKEZİ ARA", "Karargah ile sesli bağlantı kur", isPrimary: true),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SİBER CAM EFEKTLİ AKSİYON BUTONLARI
  Widget _buildSiberAksiyonButonu(IconData icon, String baslik, String altBaslik, {bool isPrimary = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: InkWell(
            onTap: () {
              // İleride kamera/arama servislerine bağlanacak
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isPrimary ? _neonCyan.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isPrimary ? _neonCyan : Colors.white.withOpacity(0.1), width: isPrimary ? 2 : 1),
              ),
              child: Row(
                children: [
                  Icon(icon, color: isPrimary ? _neonCyan : Colors.white, size: 32),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(baslik, style: TextStyle(color: isPrimary ? _neonCyan : Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                        const SizedBox(height: 4),
                        Text(altBaslik, style: TextStyle(color: SiberTema.textMain.withOpacity(0.5), fontSize: 10, fontFamily: 'Avenir')),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}