// lib/screens/sesli_servis.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:developer' as developer;

/// 🛡️ KUANTUM SESLİ ONAY VE MÜHÜR MOTORU (SiberSesliOnayMerkezi)
/// Ustanın sesli komutunu dinler, onaylarsa Karargaha (Firebase) zaman damgalı kripto mühür atar.
class SiberSesliOnayMerkezi extends StatefulWidget {
  final String ustaId; // İşlemi yapan ustanın kimliği
  final String ustaAdi; // Sesli asistanın hitap edeceği isim
  final String islemId; // Onaylanacak işlemin kimliği

  const SiberSesliOnayMerkezi({
    super.key,
    required this.ustaId,
    required this.ustaAdi,
    required this.islemId
  });

  @override
  State<SiberSesliOnayMerkezi> createState() => _SiberSesliOnayMerkeziState();
}

class _SiberSesliOnayMerkeziState extends State<SiberSesliOnayMerkezi> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  FlutterTts _flutterTts = FlutterTts();
  stt.SpeechToText _speech = stt.SpeechToText();

  bool _isListening = false;
  bool _islemSuruyor = false;
  String _ustaYaniti = "SİBER AĞ: Yanıt bekleniyor...";

  // ── 🎨 KARARGAH TASARIM DOKTRİNİ ──
  static const Color _oledBlack = Color(0xFF000000);
  static const Color _matGrey = Color(0xFF111111);
  static const Color _kuantumCyan = Color(0xFF00FFC2);

  @override
  void initState() {
    super.initState();
    _siberAsistanKonus();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _speech.stop();
    super.dispose();
  }

  // ── 🗣️ SİBER ASİSTAN MOTORU ──
  Future<void> _siberAsistanKonus() async {
    await _flutterTts.setLanguage("tr-TR");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5); // Daha ağır ve otoriter bir ton

    // Ustanın adını otonom olarak okur
    await _flutterTts.speak("${widget.ustaAdi} Usta, sistemi dinliyorum. Bu teknik işlemi mühürlüyor musun?");
  }

  // ── 🎙️ DİNLEME VE YAPAY ZEKA ONAY MOTORU ──
  Future<void> _dinlemeyeBasla() async {
    if (_islemSuruyor) return;

    HapticFeedback.lightImpact();
    bool available = await _speech.initialize(
      onStatus: (val) => developer.log('🎙️ SES RADARI: $val'),
      onError: (val) => developer.log('🚨 SES HATASI: $val'),
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
          localeId: "tr_TR",
          onResult: (val) {
            setState(() {
              _ustaYaniti = val.recognizedWords;
              String kucukHarfYanit = _ustaYaniti.toLowerCase();

              // 🔥 KARARGAH ONAY KELİMELERİ
              if (kucukHarfYanit.contains("onay") ||
                  kucukHarfYanit.contains("evet") ||
                  kucukHarfYanit.contains("mühürle")) {

                _speech.stop();
                _isListening = false;
                _karargahaMuhurle(); // Firebase ateşlemesi
              }
            });
          }
      );
    } else {
      _siberUyariGoster("SİBER İHLAL", "Mikrofon erişimi reddedildi veya cihaz desteklemiyor.", Colors.redAccent);
    }
  }

  // ── 🚀 FİREBASE MÜHÜRLEME PROTOKOLÜ ──
  Future<void> _karargahaMuhurle() async {
    if (_islemSuruyor) return;
    setState(() => _islemSuruyor = true);
    HapticFeedback.heavyImpact();

    developer.log("🚀 SİBER ONAY: Sesli komut doğrulandı. İşlem Karargaha mühürleniyor!");

    try {
      await _db.collection('yapilan_islemler').doc(widget.islemId).set({
        'sesli_onay_durumu': 'ONAYLANDI',
        'onaylayan_usta_id': widget.ustaId,
        'onaylayan_usta_adi': widget.ustaAdi,
        'okunan_sesli_komut': _ustaYaniti,
        'muhur_zaman_damgasi': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _flutterTts.speak("İşlem onaylandı ve mühürlendi.");
      HapticFeedback.vibrate();
      developer.log("✅ İŞLEM MÜHÜRLENDİ: Matriks'e kazındı.");

      if (mounted) {
        _siberUyariGoster("SESLİ MÜHÜR ONAYLANDI", "İşlem başarıyla Karargah veritabanına işlendi.", _kuantumCyan);
        // SİBER NOT: Burada rapor sayfasına veya ana ekrana dönülür
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      }

    } catch (e) {
      HapticFeedback.heavyImpact();
      developer.log("🚨 AĞ ÇÖKTÜ: Mühürleme başarısız!", error: e);
      _siberUyariGoster("BAĞLANTI HATASI", "Sesli onay Karargaha iletilemedi.", Colors.redAccent);
      setState(() => _islemSuruyor = false);
    }
  }

  // ── 🚨 ARAYÜZ YARDIMCILARI ──
  void _siberUyariGoster(String baslik, String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _matGrey,
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
      backgroundColor: _oledBlack,
      appBar: AppBar(
        title: const Text("SİBER SESLİ ONAY", style: TextStyle(color: _kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 14)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kuantumCyan),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🎙️ RADAR ANİMASYONU VE İKON
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isListening ? Colors.redAccent.withOpacity(0.1) : _kuantumCyan.withOpacity(0.05),
                      border: Border.all(color: _isListening ? Colors.redAccent : _kuantumCyan.withOpacity(0.5), width: 3),
                      boxShadow: [
                        BoxShadow(color: _isListening ? Colors.redAccent.withOpacity(0.3) : _kuantumCyan.withOpacity(0.1), blurRadius: 40, spreadRadius: 10)
                      ]
                  ),
                  child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: _isListening ? Colors.redAccent : _kuantumCyan,
                      size: 80
                  ),
                ),
                const SizedBox(height: 40),

                // 🗣️ ALGILANAN SES EKRANI
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _matGrey,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    children: [
                      const Text("ALINAN SİBER KOMUT:", style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text(
                          _ustaYaniti,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: _isListening ? Colors.white : Colors.white54,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic
                          )
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // 🚀 ATEŞLEME BUTONU VEYA YÜKLENİYOR
                if (_islemSuruyor)
                  const Column(
                    children: [
                      CircularProgressIndicator(color: _kuantumCyan),
                      SizedBox(height: 16),
                      Text("KARARGAHA MÜHÜRLENİYOR...", style: TextStyle(color: _kuantumCyan, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    ],
                  )
                else
                  SizedBox(
                    height: 60,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isListening ? () {
                        _speech.stop();
                        setState(() => _isListening = false);
                      } : _dinlemeyeBasla,
                      icon: Icon(_isListening ? Icons.stop : Icons.settings_voice, color: Colors.black, size: 24),
                      label: Text(_isListening ? "DİNLEMEYİ DURDUR" : "YANIT VERMEK İÇİN BASIN", style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isListening ? Colors.redAccent : _kuantumCyan,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 10,
                        shadowColor: (_isListening ? Colors.redAccent : _kuantumCyan).withOpacity(0.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}