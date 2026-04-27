import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

// 🔥 SİBER KÖPRÜLER
import '../../../core/siber_tema.dart';

/// 🦅 SİBER GÖZ RADARI
/// Kuantum Ağındaki QR kodlarını (Araç DNA, Kargo, Bayi) tarayan ve otonom karar veren ünite.
class SiberGozRadari extends StatefulWidget {
  const SiberGozRadari({super.key});

  @override
  State<SiberGozRadari> createState() => _SiberGozRadariState();
}

class _SiberGozRadariState extends State<SiberGozRadari> with SingleTickerProviderStateMixin {
  // 🏢 FİLDİŞİ SEDEF PALET
  final Color bgColor = const Color(0xFFFDFBF7);
  final Color surfaceColor = Colors.white;
  final Color primaryTeal = Colors.teal.shade700;
  final Color textMain = const Color(0xFF1E293B);
  final Color textMuted = const Color(0xFF64748B);
  final Color dangerColor = SiberTema.kanKirmizi;

  late MobileScannerController _cameraController;
  late AnimationController _animationController;

  bool _isScanned = false;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    _cameraController = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back
    );
    // Radar tarama çizgisi animasyonu
    _animationController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2)
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // 🧠 OTONOM KARAR MOTORU: Okunan kodun türüne göre rotayı belirler
  void _onDetect(BarcodeCapture capture) {
    if (_isScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      setState(() => _isScanned = true);
      HapticFeedback.heavyImpact(); // Siber geri bildirim

      final String tarananKod = barcodes.first.rawValue!;

      // PROTOKOL ANALİZİ (Web Linklerine Uygun Güncellendi)
      if (tarananKod.contains("/qr/") || tarananKod.contains("OTODNA_TAG_")) {
        _siberUyari("ARAÇ DNA'SI TESPİT EDİLDİ 🦅", primaryTeal, Colors.white);
        // TODO: Vatandaş Ekranına (Araç Detay) yönlendir
      } else if (tarananKod.contains("/kargo/") || tarananKod.contains("KARGO_")) {
        _siberUyari("KARGO MÜHRÜ ONAYLANDI 📦", Colors.amber.shade700, Colors.white);
        // TODO: Kargo Teslimat Ekranına yönlendir
      } else if (tarananKod.contains("/bayi/") || tarananKod.contains("BAYI_")) {
        _siberUyari("BAYİ KİMLİĞİ DOĞRULANDI 🏢", Colors.blueAccent, Colors.white);
      } else {
        _siberUyari("SİBER İHLAL! GEÇERSİZ KOD 🛑", dangerColor, Colors.white);
      }

      // İşlemden sonra otonom olarak önceki ekrana kodu döndürür
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) context.pop(tarananKod);
      });
    }
  }

  void _siberUyari(String mesaj, Color bgRenk, Color metinRenk) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: bgRenk,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Text(
          mesaj,
          style: TextStyle(color: metinRenk, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')
      ),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final double scanWindowSize = MediaQuery.of(context).size.width * 0.75;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 📸 SİBER KAMERA KATMANI
          MobileScanner(controller: _cameraController, onDetect: _onDetect),

          // 🛡️ SİBER MASKELEME (Kamera çevresini sedef tonunda yarı saydam yapar)
          ColorFiltered(
            colorFilter: ColorFilter.mode(bgColor.withOpacity(0.9), BlendMode.srcOut),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(color: Colors.transparent),
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                        width: scanWindowSize,
                        height: scanWindowSize,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(40))
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 📡 RADAR ÇERÇEVESİ VE TARAMA ÇİZGİSİ
          SizedBox(
            width: scanWindowSize,
            height: scanWindowSize,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                        color: _isScanned ? primaryTeal : primaryTeal.withOpacity(0.3),
                        width: _isScanned ? 4.0 : 2.0
                    ),
                    boxShadow: _isScanned ? [BoxShadow(color: primaryTeal.withOpacity(0.4), blurRadius: 40)] : [],
                  ),
                ),
                // Hareketli Radar Çizgisi
                if (!_isScanned)
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Positioned(
                        top: _animationController.value * (scanWindowSize - 10),
                        left: 10, right: 10,
                        child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                                color: primaryTeal,
                                boxShadow: [BoxShadow(color: primaryTeal.withOpacity(0.8), blurRadius: 20, spreadRadius: 4)]
                            )
                        ),
                      );
                    },
                  ),
                if (_isScanned)
                  Center(child: Icon(Icons.qr_code_scanner_rounded, color: primaryTeal, size: 100))
              ],
            ),
          ),

          // 🛠️ ÜST KONTROL PANELİ
          Positioned(
            top: 60, left: 24, right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    icon: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: surfaceColor, shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.05)), boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.05), blurRadius: 10)]),
                        child: Icon(Icons.arrow_back_ios_new, color: textMain, size: 18)
                    ),
                    onPressed: () => context.pop()
                ),
                Text('SİBER GÖZ AKTİF', style: TextStyle(color: textMain, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 3)),
                IconButton(
                    icon: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: _isTorchOn ? primaryTeal.withOpacity(0.1) : surfaceColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: _isTorchOn ? primaryTeal : Colors.black.withOpacity(0.05)),
                            boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.05), blurRadius: 10)]
                        ),
                        child: Icon(Icons.bolt_rounded, color: _isTorchOn ? primaryTeal : textMain, size: 20)
                    ),
                    onPressed: () {
                      setState(() => _isTorchOn = !_isTorchOn);
                      _cameraController.toggleTorch();
                    }
                ),
              ],
            ),
          ),

          // 📜 ALT DURUM PANELİ
          Positioned(
            bottom: 80,
            child: Column(
              children: [
                Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: surfaceColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: _isScanned ? primaryTeal : Colors.black.withOpacity(0.05)),
                        boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.05), blurRadius: 10)]
                    ),
                    child: Icon(Icons.center_focus_strong_outlined, color: _isScanned ? primaryTeal : textMuted, size: 36)
                ),
                const SizedBox(height: 24),
                Text(
                    _isScanned ? 'HEDEF ANALİZ EDİLİYOR...' : 'SİBER GENETİK KODU (QR) HİZALAYIN',
                    style: TextStyle(color: _isScanned ? primaryTeal : textMuted, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}