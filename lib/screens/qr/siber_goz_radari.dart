import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart';

// 🔥 SİBER KÖPRÜLER
import '../../../core/siber_tema.dart';

class SiberGozRadari extends StatefulWidget {
  const SiberGozRadari({super.key});

  @override
  State<SiberGozRadari> createState() => _SiberGozRadariState();
}

class _SiberGozRadariState extends State<SiberGozRadari> with SingleTickerProviderStateMixin {
  late MobileScannerController _cameraController;
  late AnimationController _animationController;

  bool _isScanned = false;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    _cameraController = MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates, facing: CameraFacing.back);
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      setState(() => _isScanned = true);
      HapticFeedback.heavyImpact();

      final String tarananKod = barcodes.first.rawValue!;

      // 🧠 OTONOM KARAR MOTORU
      if (tarananKod.contains("OTODNA_TAG_")) {
        _siberUyari("ARAÇ DNA'SI TESPİT EDİLDİ 🦅", SiberTema.kuantumCyan);
        // İleride Vatandaş Ekranına Yönlendirilecek
      } else if (tarananKod.contains("KARGO_")) {
        _siberUyari("KARGO MÜHRÜ ONAYLANDI 📦", Colors.orangeAccent);
        // İleride Kargo Teslimat Ekranına Yönlendirilecek
      } else {
        _siberUyari("SİBER İHLAL! GEÇERSİZ KOD 🛑", SiberTema.kanKirmizi);
      }

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) Navigator.pop(context, tarananKod); // Kodu okuyup önceki ekrana döner
      });
    }
  }

  void _siberUyari(String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: renk,
      content: Text(mesaj, style: const TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final scanWindowSize = MediaQuery.of(context).size.width * 0.7;

    return Scaffold(
      backgroundColor: SiberTema.oledBlack,
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(controller: _cameraController, onDetect: _onDetect),

          ColorFiltered(
            colorFilter: ColorFilter.mode(SiberTema.oledBlack.withOpacity(0.85), BlendMode.srcOut),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(color: Colors.transparent),
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(width: scanWindowSize, height: scanWindowSize, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(32))),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            width: scanWindowSize, height: scanWindowSize,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: _isScanned ? SiberTema.kuantumCyan : Colors.white.withOpacity(0.3), width: _isScanned ? 4.0 : 1.5),
                    boxShadow: _isScanned ? [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.5), blurRadius: 40)] : [],
                  ),
                ),
                if (!_isScanned)
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Positioned(
                        top: _animationController.value * (scanWindowSize - 4), left: 0, right: 0,
                        child: Container(height: 2, decoration: BoxDecoration(color: SiberTema.kuantumCyan, boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.8), blurRadius: 15, spreadRadius: 3)])),
                      );
                    },
                  ),
                if (_isScanned) const Center(child: Icon(Icons.qr_code_scanner_outlined, color: SiberTema.kuantumCyan, size: 80))
              ],
            ),
          ),

          Positioned(
            top: 60, left: 24, right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: SiberTema.oledBlack.withOpacity(0.5), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.1))), child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16)), onPressed: () => Navigator.pop(context)),
                const Text('SİBER GÖZ AKTİF', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 3, fontFamily: 'Avenir')),
                IconButton(icon: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: _isTorchOn ? SiberTema.kuantumCyan.withOpacity(0.2) : SiberTema.oledBlack.withOpacity(0.5), shape: BoxShape.circle, border: Border.all(color: _isTorchOn ? SiberTema.kuantumCyan : Colors.white.withOpacity(0.1))), child: Icon(Icons.bolt, color: _isTorchOn ? SiberTema.kuantumCyan : Colors.white, size: 18)), onPressed: () { setState(() => _isTorchOn = !_isTorchOn); _cameraController.toggleTorch(); }),
              ],
            ),
          ),

          Positioned(
            bottom: 60,
            child: Column(
              children: [
                Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: SiberTema.oledBlack.withOpacity(0.5), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.05))), child: Icon(Icons.center_focus_weak_outlined, color: _isScanned ? SiberTema.kuantumCyan : Colors.white54, size: 32)),
                const SizedBox(height: 24),
                Text(_isScanned ? 'HEDEF KİLİTLENDİ. SİSTEME YÖNLENDİRİLİYOR...' : 'SİBER GENETİK KODU (QR) HİZALAYIN', style: TextStyle(color: _isScanned ? SiberTema.kuantumCyan : Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}