import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatelessWidget {
  const QrScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SİBER GÖZ AKTİF"), backgroundColor: Colors.black),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            debugPrint('Siber Veri Bulundu: ${barcode.rawValue}');
            // Buraya okunan QR ile ne yapılacağı gelecek (Araç DNA çekme vb.)
          }
        },
      ),
    );
  }
}