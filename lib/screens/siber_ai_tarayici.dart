// lib/screens/siber_ai_tarayici.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:developer' as developer;

import '../core/siber_tema.dart';

/// 🛡️ SİBER AI PLAKA VE ŞASE TARAYICI (ML Kit)
/// Kameradan okunan metinleri anlık analiz edip plaka/şase formatında olanları yakalar.
class SiberAiTarayici extends StatefulWidget {
  const SiberAiTarayici({super.key});

  @override
  State<SiberAiTarayici> createState() => _SiberAiTarayiciState();
}

class _SiberAiTarayiciState extends State<SiberAiTarayici> {
  CameraController? _cameraController;
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  bool _isBusy = false;
  bool _isInitialized = false;

  final TextEditingController _manuelPlakaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _hataVer("Kamera bulunamadı!");
        return;
      }
      
      _cameraController = CameraController(
        cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();
      if (!mounted) return;

      setState(() => _isInitialized = true);
      _cameraController!.startImageStream(_processCameraImage);
    } catch (e) {
      developer.log("KAMERA HATASI", error: e);
      _hataVer("Kamera başlatılamadı!");
    }
  }

  void _hataVer(String mesaj) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: SiberTema.kanKirmizi, content: Text(mesaj, style: const TextStyle(fontWeight: FontWeight.bold))));
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isBusy) return;
    _isBusy = true;

    try {
      // 1. Görüntüyü ML Kit'in anlayacağı formata çevirme
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
      final camera = _cameraController!.description;
      final imageRotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation) ?? InputImageRotation.rotation0deg;
      final inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21;

      final planeData = image.planes.map(
        (Plane plane) {
          return InputImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width,
          );
        },
      ).toList();

      final inputImageData = InputImageData(
        size: imageSize,
        imageRotation: imageRotation,
        inputImageFormat: inputImageFormat,
        planeData: planeData,
      );

      final inputImage = InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

      // 2. Metni Okuma
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      // 3. Siber Algoritma: Plaka (örn: 34ABC123) veya Şase (17 Hane) formatı arama
      String text = recognizedText.text.replaceAll(' ', '').toUpperCase();
      
      // Basit Plaka RegEx: (2 Rakam)(1-3 Harf)(2-4 Rakam) -> Örn: 34AAA111
      RegExp plakaRegEx = RegExp(r"^(0[1-9]|[1-7][0-9]|8[0-1])[A-Z]{1,3}[0-9]{2,4}$");

      for (TextBlock block in recognizedText.blocks) {
        String blockText = block.text.replaceAll(' ', '').toUpperCase();
        if (plakaRegEx.hasMatch(blockText)) {
          developer.log("SİBER TARAMA: Plaka Yakalandı -> $blockText");
          _kabulEtVeKapat(blockText);
          break; // İlk bulduğunda dur
        } else if (blockText.length == 17) {
          // 17 Hane Şase İhtimali
          developer.log("SİBER TARAMA: Şase Yakalandı -> $blockText");
          _kabulEtVeKapat(blockText);
          break;
        }
      }
    } catch (e) {
      // Hata sessizce yutulur, kamera akışı devam eder
    } finally {
      _isBusy = false;
    }
  }

  void _kabulEtVeKapat(String veri) {
    if (!_cameraController!.value.isStreamingImages) return;
    HapticFeedback.heavyImpact();
    _cameraController!.stopImageStream();
    
    // Yönlendirme (Plaka/Şase bilgisiyle Servis Paneline geri dön)
    if (mounted) {
      Navigator.pop(context, veri);
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("AI OTONOM TARAYICI", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 13, fontFamily: 'Avenir')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: SiberTema.kuantumCyan),
      ),
      body: Column(
        children: [
          // 📸 KAMERA AKIŞI
          Expanded(
            flex: 3,
            child: _isInitialized
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      CameraPreview(_cameraController!),
                      // SİBER HEDEF NİŞANGAHI
                      Container(
                        width: 250,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5), width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text("PLAKA VEYA ŞASEYİ\nBURAYA HİZALAYIN", textAlign: TextAlign.center, style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, shadows: [Shadow(color: Colors.black, blurRadius: 4)])),
                        ),
                      )
                    ],
                  )
                : const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan)),
          ),
          
          // ⌨️ MANUEL GİRİŞ YEDEĞİ
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: SiberTema.matGrey,
                border: Border(top: BorderSide(color: SiberTema.kuantumCyan, width: 2)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("VEYA MANUEL GİRİŞ YAPIN", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontFamily: 'Avenir')),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _manuelPlakaCtrl,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2),
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: "34ABC123 VEYA ŞASE",
                            hintStyle: const TextStyle(color: Colors.white24),
                            filled: true,
                            fillColor: Colors.black,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: SiberTema.kuantumCyan, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        onPressed: () {
                          if (_manuelPlakaCtrl.text.isNotEmpty) {
                            _kabulEtVeKapat(_manuelPlakaCtrl.text.trim().toUpperCase());
                          }
                        },
                        child: const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 18),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
