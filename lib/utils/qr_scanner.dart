import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

/// 👁️ OTODNA SİBER GÖZ (QR Tarayıcı)
/// Aracın DNA'sını saniyeler içinde çözen, Karargaha loglayan ve sisteme bağlayan terminal.
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  // 🎨 Siber Tasarım Parametreleri
  static const Color _primaryCyan = Color(0xFF00FFC2);
  static const Color _cyberBlack = Color(0xFF0A0A0B);

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  bool _isScanned = false;
  MobileScannerController controller = MobileScannerController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cyberBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("SİBER GÖZ AKTİF", style: TextStyle(color: _primaryCyan, fontWeight: FontWeight.w900, letterSpacing: 2)),
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
                    setState(() => _isScanned = true);
                    _qrKodunuIsle(code);
                  }
                }
              }
            },
          ),

          // 🏗️ SİBER KATMAN (Gerçek Kuantum Hedefleyici)
          _buildKuantumHedefleyici(),

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

  // 🛡️ SİBER HEDEFLEYİCİ MASKESİ (ColorFiltered ile Kusursuz Görüş)
  Widget _buildKuantumHedefleyici() {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        Colors.black.withOpacity(0.8),
        BlendMode.srcOut,
      ),
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.black, // Bu kısım srcOut blend mode ile şeffaf (delik) olacak
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          // Neon Çerçeve ve Radar İkonu
          Align(
            alignment: Alignment.center,
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
              child: _isScanned
                  ? const Center(child: CircularProgressIndicator(color: _primaryCyan))
                  : const Center(child: Icon(Icons.qr_code_scanner, color: Colors.white24, size: 100)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: const Color(0xFF111111),
                shape: BoxShape.circle,
                border: Border.all(color: _primaryCyan.withOpacity(0.5), width: 1.5),
                boxShadow: [BoxShadow(color: _primaryCyan.withOpacity(0.1), blurRadius: 10)]
            ),
            child: Icon(icon, color: _primaryCyan, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        ],
      ),
    );
  }

  // 🚀 QR VERİ İŞLEME VE KARARGAH İSTİHBARAT MERKEZİ
  Future<void> _qrKodunuIsle(String code) async {
    developer.log("SİBER RADAR: QR Kod Algılandı -> $code");

    // 🛡️ Siber Kontrol: Kod bir OtoDNA kimliği mi?
    if (code.startsWith("OTODNA-")) {
      String raporId = code.replaceFirst("OTODNA-", "");
      _siberBildirim("ERİŞİM ONAYLANDI: DNA Kaydı Çekiliyor...");

      // ⛓️ Karargaha Başarılı Taramayı Mühürle
      await _taramaIstihbaratiniLogla(code, true);

      // Doğrudan Servis Detayına (DNA Raporuna) ışınla
      if(mounted) context.push('/service-detail/$raporId');
    } else {
      _siberBildirim("GEÇERSİZ KOD: OtoDNA Mührü Bulunamadı!", isError: true);

      // ⛓️ Karargaha Sahte Kod Denemesini (İhlali) Mühürle
      await _taramaIstihbaratiniLogla(code, false);

      Future.delayed(const Duration(seconds: 2), () {
        if(mounted) setState(() => _isScanned = false);
      });
    }
  }

  // 📡 SİBER İÇ PROTOKOL: İSTİHBARATI KARA KUTUYA YAZ
  Future<void> _taramaIstihbaratiniLogla(String taramaVerisi, bool gecerliMi) async {
    try {
      String tarayanId = _currentUser?.uid ?? "ANONİM_TARAYICI";

      await _db.collection('sistem_loglari').add({
        'islem_turu': gecerliMi ? 'QR_BASARILI_TARAMA' : 'QR_GECERSIZ_TARAMA_DENEMESİ',
        'islem_detayi': gecerliMi
            ? 'SİBER BİLGİ: $tarayanId kimliği ile "$taramaVerisi" DNA raporu başarıyla tarandı.'
            : 'SİBER İHLAL: $tarayanId kimliği geçersiz bir QR kodu ($taramaVerisi) taramaya çalıştı!',
        'kullanici_id': tarayanId,
        'tarih': FieldValue.serverTimestamp(),
      });

      developer.log("SİBER İSTİHBARAT: Tarama işlemi Karargahın Kara Kutusuna işlendi.");
    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: İstihbarat loglanamadı!", error: e);
    }
  }

  void _siberBildirim(String mesaj, {bool isError = false}) {
    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
      backgroundColor: isError ? Colors.redAccent : _primaryCyan,
      behavior: SnackBarBehavior.floating,
    ));
  }
}