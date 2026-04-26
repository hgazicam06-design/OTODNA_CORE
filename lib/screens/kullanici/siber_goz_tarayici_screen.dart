import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'arac_iletisim_screen.dart';

class SiberGozTarayiciScreen extends StatefulWidget {
  const SiberGozTarayiciScreen({super.key});

  @override
  State<SiberGozTarayiciScreen> createState() => _SiberGozTarayiciScreenState();
}

class _SiberGozTarayiciScreenState extends State<SiberGozTarayiciScreen> with SingleTickerProviderStateMixin {
  late MobileScannerController _scannerController;
  late AnimationController _laserController;
  final FlutterTts _flutterTts = FlutterTts();

  bool _isProcessing = false;
  bool _lazerKilitlendi = false;

  final Color primaryTeal = Colors.teal.shade700;
  final Color dangerColor = Colors.redAccent;
  final Color textColor = const Color(0xFF1E293B);

  // TEST İÇİN ROL SEÇİCİ
  String _aktifRol = "Vatandaş";

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(detectionSpeed: DetectionSpeed.normal);
    _laserController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _laserController.repeat(reverse: true);
    _asistaniBaslat();
  }

  Future<void> _asistaniBaslat() async {
    await _flutterTts.setLanguage("tr-TR");
    await _flutterTts.setPitch(1.2); 
    if (mounted) await _flutterTts.speak("Tarayıcı aktif. Lütfen QR kimliği taratın.");
  }

  Future<void> _qrTespitEdildi(String? rawValue) async {
    if (_isProcessing || rawValue == null) return;

    setState(() { _isProcessing = true; _lazerKilitlendi = true; });
    _laserController.stop();
    await _flutterTts.speak("Hedef kilitlendi.");

    // QR Formatını Kır
    String hedefID = rawValue;
    bool isParca = rawValue.contains("PART:");

    if (rawValue.contains("OTODNA:")) {
      hedefID = rawValue.split("OTODNA:")[1];
    } else if (rawValue.contains("/c/")) {
      hedefID = rawValue.split("/c/")[1];
    }

    try {
      if (isParca) {
        _taramaSifirla();
      } else {
        if (_aktifRol == "Vatandaş") {
          if (!mounted) return;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AracIletisimScreen(plaka: hedefID)));
        } else {
          _sonucuGoster(context, "KİMLİK DOĞRULANDI", "Plaka: $hedefID\nTüm Servis Kayıtları ve Değişen Parçalar Ağdan Çekiliyor...", primaryTeal);
        }
      }
    } catch (e) {
      _taramaSifirla();
    }
  }

  void _taramaSifirla() {
    setState(() { _isProcessing = false; _lazerKilitlendi = false; });
    _laserController.repeat(reverse: true);
  }

  // 💎 PLAZA KALİTESİ: ŞIK SONUÇ EKRANI (BOTTOM SHEET)
  void _sonucuGoster(BuildContext context, String baslik, String icerik, Color renk) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 40, offset: const Offset(0, -10))]
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: renk.withValues(alpha: 0.1), shape: BoxShape.circle, border: Border.all(color: renk.withValues(alpha: 0.3))),
                  child: Icon(Icons.verified_user_outlined, color: renk, size: 48),
                ),
                const SizedBox(height: 24),
                Text(baslik, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
                const SizedBox(height: 16),
                Text(icerik, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.5, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                const SizedBox(height: 40),
                SizedBox(
                    width: double.infinity, height: 56,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: renk, foregroundColor: Colors.white, elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                        ),
                        onPressed: () { Navigator.pop(context); _taramaSifirla(); },
                        child: const Text("ANALİZE DEVAM ET", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1, fontFamily: 'Avenir'))
                    )
                )
              ],
            ),
          );
        }
    );
  }

  @override
  void dispose() {
    _laserController.dispose(); _scannerController.dispose(); _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Plaza kalitesinde buzlu cam (frosted) veya koyu film efekti
    // Kamerayı net görmek için hala biraz koyu olması gerekebilir, ancak Plaza hissini bozmamalı.
    final overlayColor = Colors.black.withValues(alpha: 0.7);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. KAMERA (Sorunsuz Arkada Çalışır)
          MobileScanner(
              controller: _scannerController,
              onDetect: (capture) {
                for (final barcode in capture.barcodes) { _qrTespitEdildi(barcode.rawValue); }
              }
          ),

          // 2. HUD OVERLAY EKRANI
          Column(
            children: [
              Expanded(child: Container(color: overlayColor)),
              Row(
                children: [
                  Expanded(child: Container(height: 280, color: overlayColor)),
                  // 💎 ORTASI DELİK (ŞEFFAF TARAMA ALANI)
                  Container(
                    width: 280, height: 280,
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: _lazerKilitlendi ? dangerColor : Colors.white.withValues(alpha: 0.8), width: 3),
                        boxShadow: [BoxShadow(color: (_lazerKilitlendi ? dangerColor : primaryTeal).withValues(alpha: 0.15), blurRadius: 30, spreadRadius: 5)]
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: Stack(
                        children: [
                          // 💎 HAREKETLİ TARAMA ÇİZGİSİ
                          AnimatedBuilder(
                            animation: _laserController,
                            builder: (context, child) {
                              return Positioned(
                                top: _laserController.value * 270, left: 0, right: 0,
                                child: Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                        color: _lazerKilitlendi ? dangerColor : primaryTeal,
                                        boxShadow: [BoxShadow(color: _lazerKilitlendi ? dangerColor : primaryTeal, blurRadius: 15, spreadRadius: 3)]
                                    )
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(child: Container(height: 280, color: overlayColor)),
                ],
              ),
              Expanded(child: Container(color: overlayColor)),
            ],
          ),

          // 3. ROL SEÇİCİ VE GERİ BUTONU (ÜST BAR)
          Positioned(
            top: 60, left: 24, right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)]),
                    child: Icon(Icons.close, color: textColor, size: 20),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)]),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _aktifRol,
                      dropdownColor: Colors.white,
                      style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir'),
                      icon: Icon(Icons.keyboard_arrow_down, color: primaryTeal, size: 20),
                      items: ["Vatandaş", "Firma"].map((r) => DropdownMenuItem(value: r, child: Text(r.toUpperCase()))).toList(),
                      onChanged: (val) => setState(() => _aktifRol = val!),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. ALT BİLGİ PANELİ (DİNAMİK)
          Positioned(
            bottom: 80, left: 0, right: 0,
            child: Column(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    key: ValueKey(_lazerKilitlendi),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: (_lazerKilitlendi ? dangerColor : primaryTeal).withValues(alpha: 0.2), blurRadius: 20, spreadRadius: 5)]
                    ),
                    child: Icon(
                        _lazerKilitlendi ? Icons.lock_outline : Icons.qr_code_scanner_outlined,
                        color: _lazerKilitlendi ? dangerColor : primaryTeal,
                        size: 32
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)]
                  ),
                  child: Text(
                      _lazerKilitlendi ? "HEDEF KİLİTLENDİ" : "QR KİMLİĞİ HİZALAYIN",
                      style: TextStyle(color: _lazerKilitlendi ? dangerColor : textColor, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}