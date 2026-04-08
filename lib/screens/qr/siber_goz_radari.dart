import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart';

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

      // PROTOKOL ANALİZİ
      if (tarananKod.contains("OTODNA_TAG_")) {
        _siberUyari("ARAÇ DNA'SI TESPİT EDİLDİ 🦅", SiberTema.kuantumCyan);
        // TODO: Vatandaş Ekranına (Araç Detay) yönlendir
      } else if (tarananKod.contains("KARGO_")) {
        _siberUyari("KARGO MÜHRÜ ONAYLANDI 📦", Colors.orangeAccent);
        // TODO: Kargo Teslimat Ekranına yönlendir
      } else if (tarananKod.contains("BAYI_")) {
        _siberUyari("BAYİ KİMLİĞİ DOĞRULANDI 🏢", Colors.blueAccent);
      } else {
        _siberUyari("SİBER İHLAL! GEÇERSİZ KOD 🛑", SiberTema.kanKirmizi);
      }

      // İşlemden sonra otonom olarak önceki ekrana kodu döndürür
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) Navigator.pop(context, tarananKod);
      });
    }
  }

  void _siberUyari(String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: renk,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Text(
          mesaj,
          style: const TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')
      ),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final double scanWindowSize = MediaQuery.of(context).size.width * 0.75;

    return Scaffold(
      backgroundColor: SiberTema.oledBlack,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 📸 SİBER KAMERA KATMANI
          MobileScanner(controller: _cameraController, onDetect: _onDetect),

          // 🛡️ SİBER MASKELEME (Kamera çevresini karartır)
          ColorFiltered(
            colorFilter: ColorFilter.mode(SiberTema.oledBlack.withOpacity(0.8), BlendMode.srcOut),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(color: Colors.transparent),
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                        width: scanWindowSize,
                        height: scanWindowSize,
                        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(40))
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
                        color: _isScanned ? SiberTema.kuantumCyan : Colors.white.withOpacity(0.2),
                        width: _isScanned ? 4.0 : 2.0
                    ),
                    boxShadow: _isScanned ? [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.4), blurRadius: 40)] : [],
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
                                color: SiberTema.kuantumCyan,
                                boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.8), blurRadius: 20, spreadRadius: 4)]
                            )
                        ),
                      );
                    },
                  ),
                if (_isScanned)
                  const Center(child: Icon(Icons.qr_code_scanner_rounded, color: SiberTema.kuantumCyan, size: 100))
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
                        decoration: BoxDecoration(color: SiberTema.oledBlack.withOpacity(0.6), shape: BoxShape.circle, border: Border.all(color: Colors.white12)),
                        child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18)
                    ),
                    onPressed: () => Navigator.pop(context)
                ),
                const Text('SİBER GÖZ AKTİF', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 3)),
                IconButton(
                    icon: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: _isTorchOn ? SiberTema.kuantumCyan.withOpacity(0.2) : SiberTema.oledBlack.withOpacity(0.6),
                            shape: BoxShape.circle,
                            border: Border.all(color: _isTorchOn ? SiberTema.kuantumCyan : Colors.white12)
                        ),
                        child: Icon(Icons.bolt_rounded, color: _isTorchOn ? SiberTema.kuantumCyan : Colors.white, size: 20)
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
                        color: SiberTema.oledBlack.withOpacity(0.6),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.05))
                    ),
                    child: Icon(Icons.center_focus_strong_outlined, color: _isScanned ? SiberTema.kuantumCyan : Colors.white54, size: 36)
                ),
                const SizedBox(height: 24),
                Text(
                    _isScanned ? 'HEDEF ANALİZ EDİLİYOR...' : 'SİBER GENETİK KODU (QR) HİZALAYIN',
                    style: TextStyle(color: _isScanned ? SiberTema.kuantumCyan : Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}