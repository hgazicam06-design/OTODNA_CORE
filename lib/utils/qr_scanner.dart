import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';

/// 👁️ OTODNA SİBER GÖZ (QR Tarayıcı)
/// Aracın DNA'sını saniyeler içinde çözen ve sisteme bağlayan terminal.
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  // 🎨 Siber Tasarım Parametreleri
  static const Color _primaryCyan = Color(0xFF00FFC2);
  static const Color _cyberBlack = Color(0xFF0A0A0B);

  bool _isScanned = false;
  MobileScannerController controller = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cyberBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("SİBER GÖZ AKTİF", style: TextStyle(color: _primaryCyan, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primaryCyan),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          // 📷 CANLI TARAMA MOTORU
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              if (!_isScanned) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  final String? code = barcode.rawValue;
                  if (code != null) {
                    _isScanned = true;
                    _qrKodunuIsle(code);
                  }
                }
              }
            },
          ),

          // 🏗️ SİBER KATMAN (Overlay)
          _buildScannerOverlay(),

          // 🔦 KONTROLLER
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(Icons.flashlight_on, "FENER", () => controller.toggleTorch()),
                _buildActionButton(Icons.cameraswitch, "DÖNDÜR", () => controller.switchCamera()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🛡️ SİBER KATMAN TASARIMI
  Widget _buildScannerOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
      ),
      child: Center(
        child: Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(color: _primaryCyan, width: 2),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: _primaryCyan.withOpacity(0.2), blurRadius: 20, spreadRadius: 5)
            ],
          ),
          child: Stack(
            children: [
              // Radar Animasyonu Etkisi (Simüle)
              const Center(child: Icon(Icons.qr_code_2, color: Colors.white10, size: 150)),
              _buildCorner(0, 0), // Sol Üst
              _buildCorner(null, 0), // Sağ Üst
              _buildCorner(0, null), // Sol Alt
              _buildCorner(null, null), // Sağ Alt
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCorner(double? left, double? top) {
    return Positioned(
      left: left,
      top: top,
      right: left == null ? 0 : null,
      bottom: top == null ? 0 : null,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: _primaryCyan,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(left == 0 && top == 0 ? 10 : 0),
            topRight: Radius.circular(left == null && top == 0 ? 10 : 0),
            bottomLeft: Radius.circular(left == 0 && top == null ? 10 : 0),
            bottomRight: Radius.circular(left == null && top == null ? 10 : 0),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white10, shape: BoxShape.circle, border: Border.all(color: _primaryCyan.withOpacity(0.3))),
            child: Icon(icon, color: _primaryCyan),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // 🚀 QR VERİ İŞLEME MERKEZİ
  void _qrKodunuIsle(String code) {
    // 🛡️ Siber Kontrol: Kod bir OtoDNA kimliği mi yoksa dış link mi?
    if (code.startsWith("OTODNA-")) {
      String raporId = code.replaceFirst("OTODNA-", "");
      _siberBildirim("ERİŞİM ONAYLANDI: DNA Kaydı Çekiliyor...");
      // Doğrudan Servis Detayına ışınla
      context.push('/service-detail/$raporId');
    } else {
      _siberBildirim("GEÇERSİZ KOD: OtoDNA Mührü Bulunamadı!", isError: true);
      Future.delayed(const Duration(seconds: 2), () {
        setState(() => _isScanned = false);
      });
    }
  }

  void _siberBildirim(String mesaj, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      backgroundColor: isError ? Colors.redAccent : _primaryCyan,
    ));
  }
}