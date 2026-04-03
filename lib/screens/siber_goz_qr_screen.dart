import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// SİBER ZIRHLAR
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

class SiberGozQrScreen extends StatefulWidget {
  const SiberGozQrScreen({super.key});

  @override
  State<SiberGozQrScreen> createState() => _SiberGozQrScreenState();
}

class _SiberGozQrScreenState extends State<SiberGozQrScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;

  // --- 🔴 FİREBASE: QR KOD İLE KUANTUM AĞINDA ARAÇ SORGULAMA ---
  Future<void> _aracRontgeniCek(String qrData) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    _scannerController.stop(); // Taramayı durdur, veriyi işle

    try {
      // QR koddan gelen veri Aracın ID'si veya Plakası kabul edilir
      DocumentSnapshot aracDoc = await _db.collection('araclar').doc(qrData).get();

      if (!mounted) return;

      if (!aracDoc.exists) {
        _siberUyariVer("SİBER İHLAL: Kuantum ağında böyle bir araç bulunamadı!", isError: true);
        _sistemiSifirla();
        return;
      }

      final data = aracDoc.data() as Map<String, dynamic>;
      final bool isRiskli = data['trafik_riski'] ?? false;
      final num dnaSkoru = data['dna_skoru'] ?? 0;
      final String plaka = data['plaka'] ?? 'BİLİNMEYEN';

      _aracRaporunuGoster(plaka, dnaSkoru.toInt(), isRiskli);

    } catch (e) {
      if (!mounted) return;
      _siberUyariVer("AĞ HATASI: Veritabanı sorgusu çöktü.", isError: true);
      _sistemiSifirla();
    }
  }

  void _sistemiSifirla() {
    setState(() => _isProcessing = false);
    _scannerController.start();
  }

  void _siberUyariVer(String mesaj, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: TextStyle(color: isError ? Colors.white : SiberTema.oledBlack, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
      backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
      behavior: SnackBarBehavior.floating,
    ));
  }

  // --- SİBER CAM EFEKTLİ RAPOR EKRANI ---
  void _aracRaporunuGoster(String plaka, int dnaSkoru, bool isRiskli) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: SiberTema.oledBlack.withOpacity(0.9),
                border: Border(top: BorderSide(color: isRiskli ? SiberTema.kanKirmizi : SiberTema.kuantumCyan, width: 2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(isRiskli ? Icons.warning_amber_rounded : Icons.verified_user, color: isRiskli ? SiberTema.kanKirmizi : SiberTema.kuantumCyan, size: 64),
                  const SizedBox(height: 24),
                  Text("PLAKA: $plaka", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 3)),
                  const SizedBox(height: 12),

                  // RİSK DURUMU
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: isRiskli ? SiberTema.kanKirmizi : SiberTema.kuantumCyan, borderRadius: BorderRadius.circular(12)),
                    child: Text(isRiskli ? "TRAFİĞE ÇIKIŞI RİSKLİ" : "OTODNA ONAYLIDIR", style: const TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 1)),
                  ),
                  const SizedBox(height: 24),

                  // DNA SKORU
                  Text("GÜNCEL DNA SKORU: $dnaSkoru/100", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.1), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: () {
                        Navigator.pop(context);
                        _sistemiSifirla();
                      },
                      child: const Text("TARAMAYA DEVAM ET", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: SiberTema.kuantumCyan), onPressed: () => Navigator.pop(context)),
          title: Text("SİBER GÖZ / QR RADAR", style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2, fontFamily: 'Avenir')),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            MobileScanner(
              controller: _scannerController,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    _aracRontgeniCek(barcode.rawValue!);
                    break;
                  }
                }
              },
            ),

            // SİBER NİŞANGAH (Hedef Çerçevesi)
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5), width: 2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  children: [
                    Positioned(top: 0, left: 0, child: _buildKose(Alignment.topLeft)),
                    Positioned(top: 0, right: 0, child: _buildKose(Alignment.topRight)),
                    Positioned(bottom: 0, left: 0, child: _buildKose(Alignment.bottomLeft)),
                    Positioned(bottom: 0, right: 0, child: _buildKose(Alignment.bottomRight)),
                  ],
                ),
              ),
            ),

            if (_isProcessing)
              Container(
                color: Colors.black.withOpacity(0.8),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: SiberTema.kuantumCyan, strokeWidth: 3),
                      SizedBox(height: 24),
                      Text("KİMLİK DOĞRULANIYOR...", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.bold, letterSpacing: 3, fontFamily: 'Avenir')),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Nişangah köşeleri için dekoratif widget
  Widget _buildKose(Alignment hizalama) {
    return Container(
      width: 30, height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: (hizalama == Alignment.topLeft || hizalama == Alignment.topRight) ? const BorderSide(color: SiberTema.kuantumCyan, width: 4) : BorderSide.none,
          bottom: (hizalama == Alignment.bottomLeft || hizalama == Alignment.bottomRight) ? const BorderSide(color: SiberTema.kuantumCyan, width: 4) : BorderSide.none,
          left: (hizalama == Alignment.topLeft || hizalama == Alignment.bottomLeft) ? const BorderSide(color: SiberTema.kuantumCyan, width: 4) : BorderSide.none,
          right: (hizalama == Alignment.topRight || hizalama == Alignment.bottomRight) ? const BorderSide(color: SiberTema.kuantumCyan, width: 4) : BorderSide.none,
        ),
      ),
    );
  }
}