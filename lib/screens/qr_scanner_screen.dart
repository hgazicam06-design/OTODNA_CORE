import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
// import 'qr_public_screen.dart'; // 🚀 Siber yönlendirme için kapı (Kendi klasör yoluna göre ayarla)

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> with SingleTickerProviderStateMixin {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  static const Color bgColor = Color(0xFF000000);
  static const Color primaryCyan = Color(0xFF00FFC2);
  static const Color dangerColor = Colors.redAccent;

  // 🚀 SİBER TARAYICI KONTROLCÜSÜ (Çift okumayı engelleyen kalkan aktif)
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );

  bool _isScanCompleted = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // 🔴 Kuantum Lazeri için döngüsel radar animasyonu
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // 🎯 HEDEF KİLİTLENME MOTORU
  void _onDetect(BarcodeCapture capture) {
    if (_isScanCompleted) return; // Ağ kilitliyse yeni sinyal alma

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String code = barcodes.first.rawValue ?? '';

      setState(() {
        _isScanCompleted = true; // 🛡️ Siber kalkanı kapat, çift okumayı engelle
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: primaryCyan,
          content: Text(
            'HEDEF KİLİTLENDİ! İSTİHBARAT AĞINA BAĞLANILIYOR... 🦅',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
          duration: Duration(seconds: 1),
        ),
      );

      // 1 Saniye radar gecikmesi ve gerçek hedefe (QrPublicScreen) Kuantum Sıçraması
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          // 🚀 BURASI ÇOK KRİTİK: Okunan kodu doğrudan İstihbarat Ekranına fırlatıyoruz!
          // TODO: Kendi klasör yoluna göre import edip alttaki satırı aktif et:
          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => QrPublicScreen(vehicleId: code)));

          Navigator.pop(context); // TODO Aktif olana kadar geçici kapatıcı
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // 1. KAMERA KATMANI (Arka planda dünyayı izleyen göz)
          MobileScanner(
            controller: _cameraController,
            onDetect: _onDetect,
          ),

          // 2. FÜTÜRİSTİK KARARTMA VE ODAK ÇERÇEVESİ (Holografik Overlay)
          _buildScannerOverlay(),

          // 3. ÜST BAR VE TAKTİKSEL BUTONLAR
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // İptal / Geri Butonu
                  Container(
                    decoration: BoxDecoration(color: bgColor.withOpacity(0.5), shape: BoxShape.circle, border: Border.all(color: Colors.white12)),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  // Taktiksel Fener ve Lens Çevirme
                  Container(
                    decoration: BoxDecoration(color: bgColor.withOpacity(0.5), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white12)),
                    child: Row(
                      children: [
                        ValueListenableBuilder(
                          valueListenable: _cameraController.torchState,
                          builder: (context, state, child) {
                            final isOn = state == TorchState.on;
                            return IconButton(
                              icon: Icon(isOn ? Icons.flash_on : Icons.flash_off, color: isOn ? primaryCyan : Colors.white),
                              onPressed: () => _cameraController.toggleTorch(),
                            );
                          },
                        ),
                        Container(width: 1, height: 24, color: Colors.white12),
                        IconButton(
                          icon: const Icon(Icons.cameraswitch, color: Colors.white),
                          onPressed: () => _cameraController.switchCamera(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. ALT HUD BİLGİLENDİRME PANOSU
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.qr_code_scanner, color: primaryCyan, size: 32),
                ),
                const SizedBox(height: 24),
                const Text(
                  'HEDEF ARACIN QR KODUNU TARAYIN',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2),
                ),
                const SizedBox(height: 8),
                Text(
                  'OtoDNA Güvenlik Çemberi Aktif',
                  style: TextStyle(color: primaryCyan.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: SİBER HUD VİZÖRÜ VE LAZER
  Widget _buildScannerOverlay() {
    final scanAreaSize = MediaQuery.of(context).size.width * 0.7;

    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        bgColor.withOpacity(0.85), // Matrix Karartması
        BlendMode.srcOut,
      ),
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(color: Colors.transparent),
            child: Center(
              child: Container(
                width: scanAreaSize,
                height: scanAreaSize,
                decoration: BoxDecoration(
                  color: Colors.black, // Bu kısım kameranın dünyayı gördüğü "delik"
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          // 🔴 Animasyonlu Kuantum Lazer Çizgisi
          Center(
            child: SizedBox(
              width: scanAreaSize,
              height: scanAreaSize,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Stack(
                    children: [
                      Positioned(
                        top: _animationController.value * (scanAreaSize - 4),
                        left: 10,
                        right: 10,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: primaryCyan,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [BoxShadow(color: primaryCyan, blurRadius: 15, spreadRadius: 2)],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}