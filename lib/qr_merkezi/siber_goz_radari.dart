// lib/qr_merkezi/siber_goz_radari.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI VE TEMALARI
import '../core/siber_tema.dart';

/// 👁️ SİBER GÖZ: Otonom Evrensel QR Tarayıcı
/// Kodu okur, parçalar ve "Kargo mu Araç mı?" otonom karar verip yönlendirir.
class SiberGozRadari extends StatefulWidget {
  const SiberGozRadari({super.key});

  @override
  State<SiberGozRadari> createState() => _SiberGozRadariState();
}

class _SiberGozRadariState extends State<SiberGozRadari> with SingleTickerProviderStateMixin {
  final MobileScannerController _radarMotoru = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _islemSuruyor = false;
  late AnimationController _taramaAnimasyonu;

  @override
  void initState() {
    super.initState();
    // 📡 Kuantum Tarama Efekti
    _taramaAnimasyonu = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _radarMotoru.dispose();
    _taramaAnimasyonu.dispose();
    super.dispose();
  }

  // 🧠 KUANTUM VERİ PARÇALAYICI VE YÖNLENDİRİCİ
  void _veriyiAnalizEt(String qrVerisi) async {
    if (_islemSuruyor) return;
    setState(() => _islemSuruyor = true);

    // Çoklu okumayı engellemek için radarı dondur
    _radarMotoru.stop();
    developer.log("👁️ SİBER GÖZ: QR Tespit Edildi -> Kripto Veri: $qrVerisi");

    // Matrix Tarama Simülasyonu (Güvenlik hissi için ufak bir bekleme)
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      // 📦 DURUM 1: KARGO TESLİMAT KODU MU?
      // Örn format: "KARGO:12345678"
      if (qrVerisi.startsWith("KARGO:")) {
        String kargoID = qrVerisi.split(":")[1];
        developer.log("📦 HEDEF TESPİTİ: Bu bir Kargo Mührü! Kargo ID: $kargoID");
        _siberUyariGoster("KARGO MÜHRÜ ONAYLANDI", "Teslimat protokolü başlatılıyor...", SiberTema.kuantumCyan);

        // SİBER NOT: Burada Kargo Teslimat Ekranına Yönlendirme Yapılacak
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => KargoTeslimatEkrani(kargoId: kargoID)));
      }
      // 🧬 DURUM 2: ARAÇ DNA (ŞASE) KODU MU?
      // Örn format: "DNA:WVWZZZ..." veya direkt 17 haneli şase numarası
      else if (qrVerisi.startsWith("DNA:") || qrVerisi.length == 17) {
        String saseNo = qrVerisi.startsWith("DNA:") ? qrVerisi.split(":")[1] : qrVerisi;
        developer.log("🧬 HEDEF TESPİTİ: Bu bir Araç DNA'sı! Şase: $saseNo");
        _siberUyariGoster("ARAÇ DNA'SI TESPİT EDİLDİ", "Siber sicil dosyası açılıyor...", SiberTema.kuantumCyan);

        // SİBER NOT: Burada Araç DNA Sorgulama/Profil Ekranına Yönlendirme Yapılacak
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AracProfilEkrani(saseNo: saseNo)));
      }
      // 🚨 DURUM 3: SİVİL VEYA SAHTE KOD İHLALİ (Karargah Dışı)
      else {
        developer.log("🚨 İHLAL: Tanımsız veya sivil QR kod okutuldu!");
        _siberUyariGoster("SİBER İHLAL!", "Okutulan kod Karargah protokollerine ait değil (Cips barkodu olabilir).", SiberTema.kanKirmizi);

        // Radarı tekrar aktif et
        await Future.delayed(const Duration(seconds: 2));
        _radarMotoru.start();
        setState(() => _islemSuruyor = false);
      }
    } catch (e) {
      developer.log("🚨 RADAR HATASI", error: e);
      _radarMotoru.start();
      setState(() => _islemSuruyor = false);
    }
  }

  void _siberUyariGoster(String baslik, String mesaj, Color renk) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SiberTema.matGrey,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: renk, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            const SizedBox(height: 4),
            Text(mesaj, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SiberTema.oledBlack,
      appBar: AppBar(
        title: const Text("SİBER GÖZ RADARI"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: SiberTema.kuantumCyan),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Flaş Kontrol Kalkanı
          IconButton(
            icon: const Icon(Icons.flashlight_on, color: SiberTema.kuantumCyan),
            onPressed: () => _radarMotoru.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 📡 1. KAMERA RADARI
          MobileScanner(
            controller: _radarMotoru,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                _veriyiAnalizEt(barcodes.first.rawValue!);
              }
            },
          ),

          // 🛡️ 2. SİBER CAM GÖSTERGE PANELİ (Arayüz Zırhı)
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: SiberTema.siberCamKalkan(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.qr_code_scanner, color: SiberTema.kuantumCyan, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    _islemSuruyor
                        ? "HEDEF ANALİZ EDİLİYOR..."
                        : "SİBER GÖZ AKTİF\nKargo veya Araç DNA Kodunu Okutun",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5, height: 1.4),
                  ),
                  if (_islemSuruyor) ...[
                    const SizedBox(height: 20),
                    const LinearProgressIndicator(color: SiberTema.kuantumCyan, backgroundColor: SiberTema.matGrey),
                  ]
                ],
              ),
            ),
          ),

          // 🎯 3. MERKEZİ ODAKLAMA RADARI (Animasyonlu Kuantum Çizgisi)
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5), width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: AnimatedBuilder(
                animation: _taramaAnimasyonu,
                builder: (context, child) {
                  return Stack(
                    children: [
                      Positioned(
                        top: 240 * _taramaAnimasyonu.value,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: SiberTema.kuantumCyan,
                            boxShadow: [BoxShadow(color: SiberTema.kuantumCyan, blurRadius: 10, spreadRadius: 2)],
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