import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> with SingleTickerProviderStateMixin {
  late MobileScannerController cameraController;
  late AnimationController _animationController;

  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  final Color bgColor = const Color(0xFF000000);
  final Color primaryCyan = const Color(0xFF00FFC2);

  bool _isScanned = false;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );

    // Kuantum Tarama Lazer Animasyonu
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    cameraController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // 💎 SİBER MÜHÜRLEME MOTORU
  void _onDetect(BarcodeCapture capture) {
    if (_isScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      setState(() => _isScanned = true);
      HapticFeedback.heavyImpact(); // Cihazı titret (Hedef Kilitlendi!)

      final String tarananKod = barcodes.first.rawValue!;

      // Tarama başarılı oldu, terminal efekti için kısa bir bekleme
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        // Kodu al ve şimşek hızında Ana Üs'se fırlat
        Navigator.pop(context, tarananKod);
      });
    }
  }

  void _toggleTorch() {
    setState(() => _isTorchOn = !_isTorchOn);
    cameraController.toggleTorch();
  }

  @override
  Widget build(BuildContext context) {
    final scanWindowSize = MediaQuery.of(context).size.width * 0.7;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // =================================================================
          // 1. KATMAN: CANLI KAMERA AKIŞI
          // =================================================================
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),

          // =================================================================
          // 2. KATMAN: SİBER KARARTMA MASKESİ
          // =================================================================
          ColorFiltered(
            colorFilter: ColorFilter.mode(bgColor.withOpacity(0.85), BlendMode.srcOut),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: scanWindowSize,
                      height: scanWindowSize,
                      decoration: BoxDecoration(
                        color: Colors.black, // Maskenin delik kısmı
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // =================================================================
          // 3. KATMAN: FÜTÜRİSTİK ÇERÇEVELER VE KUANTUM LAZERİ
          // =================================================================
          SizedBox(
            width: scanWindowSize,
            height: scanWindowSize,
            child: Stack(
              children: [
                // Köşe Çerçeveleri (Sniper Scope Etkisi)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                        color: _isScanned ? primaryCyan : Colors.white.withOpacity(0.3),
                        width: _isScanned ? 4.0 : 1.5
                    ),
                    boxShadow: _isScanned ? [BoxShadow(color: primaryCyan.withOpacity(0.5), blurRadius: 40)] : [],
                  ),
                ),

                // Aşağı-Yukarı Giden Tarama Lazeri
                if (!_isScanned)
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Positioned(
                        top: _animationController.value * (scanWindowSize - 4),
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            color: primaryCyan,
                            boxShadow: [
                              BoxShadow(color: primaryCyan.withOpacity(0.8), blurRadius: 15, spreadRadius: 3)
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                // Hedef Kilitlendi İkonu
                if (_isScanned)
                  const Center(
                    child: Icon(Icons.qr_code_scanner_outlined, color: primaryCyan, size: 80),
                  )
              ],
            ),
          ),

          // =================================================================
          // 4. KATMAN: ÜST KONTROL PANELİ
          // =================================================================
          Positioned(
            top: 60,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: bgColor.withOpacity(0.5), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.1))),
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'SİBER GÖZ AKTİF',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 3),
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: _isTorchOn ? primaryCyan.withOpacity(0.2) : bgColor.withOpacity(0.5), shape: BoxShape.circle, border: Border.all(color: _isTorchOn ? primaryCyan : Colors.white.withOpacity(0.1))),
                    child: Icon(Icons.bolt, color: _isTorchOn ? primaryCyan : Colors.white, size: 18),
                  ),
                  onPressed: _toggleTorch,
                ),
              ],
            ),
          ),

          // =================================================================
          // 5. KATMAN: ALT DURUM EKRANI
          // =================================================================
          Positioned(
            bottom: 60,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: bgColor.withOpacity(0.5), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.05))),
                  child: Icon(Icons.center_focus_weak_outlined, color: _isScanned ? primaryCyan : Colors.white54, size: 32),
                ),
                const SizedBox(height: 24),
                Text(
                  _isScanned ? 'HEDEF KİLİTLENDİ. VERİLER ÇEKİLİYOR...' : 'SİBER GENETİK KODU (QR) HİZALAYIN',
                  style: TextStyle(color: _isScanned ? primaryCyan : Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}