import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SiberAiAyarlariScreen extends StatefulWidget {
  const SiberAiAyarlariScreen({super.key});

  @override
  State<SiberAiAyarlariScreen> createState() => _SiberAiAyarlariScreenState();
}

class _SiberAiAyarlariScreenState extends State<SiberAiAyarlariScreen> {
  final TextEditingController _isimController = TextEditingController(text: "Asena");
  String _seciliSes = "KADIN";
  double _konusmaHizi = 1.0;
  String _cozumTarzi = "HIZLI";

  final FlutterTts _flutterTts = FlutterTts();

  final Color primaryTeal = Colors.teal.shade700;
  final Color textColor = const Color(0xFF1E293B);
  final Color bgColor = const Color(0xFFFAFAFC);
  final Color surfaceColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _siberSesiHazirla();
  }

  Future<void> _siberSesiHazirla() async {
    await _flutterTts.setLanguage("tr-TR");
    await _flutterTts.setSpeechRate(_konusmaHizi);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(_seciliSes == "KADIN" ? 1.2 : 0.5);
  }

  @override
  void dispose() {
    _isimController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  void _ayarlariKaydet() {
    FocusScope.of(context).unfocus();
    String asistanIsmi = _isimController.text.trim().isEmpty ? "Asistan" : _isimController.text.trim();

    _flutterTts.speak("Ayarlarım güncellendi.");

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$asistanIsmi: 'Ayarlarım güncellendi.'", style: const TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, fontFamily: 'Avenir')), 
          backgroundColor: primaryTeal, 
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        )
    );
    Future.delayed(const Duration(seconds: 2), () => Navigator.pop(context));
  }

  void _sesiTestEt() async {
    FocusScope.of(context).unfocus();

    String asistanIsmi = _isimController.text.trim().isEmpty ? "Plaza Asistanı" : _isimController.text.trim();
    String mesaj = "Merhaba, ben $asistanIsmi. OtoDNA sistemleri hizmetinize hazır.";

    await _flutterTts.setSpeechRate(_konusmaHizi);
    await _flutterTts.setPitch(_seciliSes == "KADIN" ? 1.2 : 0.5);
    await _flutterTts.speak(mesaj);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
        title: Row(
          children: [
            Icon(Icons.record_voice_over_outlined, color: _seciliSes == "KADIN" ? Colors.purpleAccent.shade400 : Colors.blueAccent.shade400, size: 24),
            const SizedBox(width: 12),
            const Text("SES AKTİF", style: TextStyle(color: Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
          ],
        ),
        content: Text("Oynatma Hızı: ${_konusmaHizi.toStringAsFixed(2)}x\n\n\"$mesaj\"", style: const TextStyle(color: Colors.white87, fontSize: 13, fontStyle: FontStyle.italic, height: 1.5, fontFamily: 'Avenir')),
        actions: [
          TextButton(onPressed: () {
            _flutterTts.stop();
            Navigator.pop(context);
          }, child: const Text("SUSTUR VE KAPAT", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')))
        ],
      ),
    );
  }

  void _sesDegistir(String yeniSes) {
    setState(() {
      _seciliSes = yeniSes;
      if (_isimController.text == "Asena" && yeniSes == "ERKEK") {
        _isimController.text = "Alperen";
      } else if (_isimController.text == "Alperen" && yeniSes == "KADIN") {
        _isimController.text = "Asena";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: primaryTeal, size: 20), onPressed: () => Navigator.pop(context)),
          title: Text("A I   K O N F İ G Ü R A S Y O N", style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 3, fontFamily: 'Avenir')),
          centerTitle: true
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BAŞLIK ALANI
            Text("Akıllı Asistan", style: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1, fontFamily: 'Avenir')),
            const SizedBox(height: 8),
            const Text("Yapay zeka asistanınızın ismini, sesini, hızını ve müdahale tarzını kişiselleştirin.", style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
            const SizedBox(height: 40),

            // 1. İSİM ALANI
            const Text("1. Asistan Kimliği", style: TextStyle(color: Colors.white45, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 10)]),
              child: TextField(
                  controller: _isimController,
                  style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Avenir'),
                  decoration: const InputDecoration(
                      hintText: "Örn: Cuma, Jarvis, Asena...",
                      hintStyle: TextStyle(color: Colors.white26, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Avenir'),
                      icon: Icon(Icons.smart_toy_outlined, color: Colors.white38, size: 22),
                      border: InputBorder.none
                  )
              ),
            ),
            const SizedBox(height: 40),

            // 2. SES SEÇİMİ
            const Text("2. Ses Profili", style: TextStyle(color: Colors.white45, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
            const SizedBox(height: 16),
            Row(
                children: [
                  Expanded(child: GestureDetector(onTap: () => _sesDegistir("KADIN"), child: _buildSecimKarti(aktifMi: _seciliSes == "KADIN", renk: Colors.purpleAccent.shade400, icon: Icons.face_3_outlined, baslik: "Kadın Sesi", aciklama: "Net ve profesyonel."))),
                  const SizedBox(width: 16),
                  Expanded(child: GestureDetector(onTap: () => _sesDegistir("ERKEK"), child: _buildSecimKarti(aktifMi: _seciliSes == "ERKEK", renk: Colors.blueAccent.shade400, icon: Icons.face_6_outlined, baslik: "Erkek Sesi", aciklama: "Tok ve resmi.")))
                ]
            ),
            const SizedBox(height: 40),

            // 3. KONUŞMA HIZI
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("3. Yanıt Hızı", style: TextStyle(color: Colors.white45, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')), Text("${_konusmaHizi.toStringAsFixed(2)}x", style: TextStyle(color: primaryTeal, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Avenir'))]),
            const SizedBox(height: 12),
            Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 10)]),
                child: Column(
                    children: [
                      SliderTheme(
                          data: SliderTheme.of(context).copyWith(activeTrackColor: primaryTeal, inactiveTrackColor: Colors.black.withValues(alpha: 0.05), thumbColor: primaryTeal, overlayColor: primaryTeal.withValues(alpha: 0.2), trackHeight: 4),
                          child: Slider(value: _konusmaHizi, min: 0.5, max: 1.5, divisions: 20, onChanged: (val) => setState(() => _konusmaHizi = val))
                      ),
                      const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Yavaş (0.5x)", style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.bold, fontFamily: 'Avenir')), Text("Hızlı (1.5x)", style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.bold, fontFamily: 'Avenir'))])
                      )
                    ]
                )
            ),
            const SizedBox(height: 40),

            // 4. MÜDAHALE TARZI
            const Text("4. Müdahale Tarzı", style: TextStyle(color: Colors.white45, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
            const SizedBox(height: 16),
            GestureDetector(
                onTap: () => setState(() => _cozumTarzi = "HIZLI"),
                child: Container(
                    padding: const EdgeInsets.all(20), margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(color: _cozumTarzi == "HIZLI" ? Colors.orange.withValues(alpha: 0.05) : surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: _cozumTarzi == "HIZLI" ? Colors.orange.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.05)), boxShadow: _cozumTarzi == "HIZLI" ? null : [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 10)]),
                    child: Row(
                        children: [
                          Icon(Icons.bolt_outlined, color: _cozumTarzi == "HIZLI" ? Colors.orange : Colors.black26, size: 28),
                          const SizedBox(width: 16),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Acil ve Hızlı Çözüm (Önerilen)", style: TextStyle(color: _cozumTarzi == "HIZLI" ? Colors.orange : textColor, fontWeight: FontWeight.w900, fontSize: 14, fontFamily: 'Avenir')), const SizedBox(height: 6), const Text("Kaza/arıza anında laf kalabalığı yapmaz, doğrudan kolluk kuvveti veya çekici menüsünü açar.", style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.4, fontWeight: FontWeight.bold, fontFamily: 'Avenir'))]))
                        ]
                    )
                )
            ),
            GestureDetector(
                onTap: () => setState(() => _cozumTarzi = "DETAYLI"),
                child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: _cozumTarzi == "DETAYLI" ? primaryTeal.withValues(alpha: 0.05) : surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: _cozumTarzi == "DETAYLI" ? primaryTeal.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.05)), boxShadow: _cozumTarzi == "DETAYLI" ? null : [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 10)]),
                    child: Row(
                        children: [
                          Icon(Icons.menu_book_outlined, color: _cozumTarzi == "DETAYLI" ? primaryTeal : Colors.black26, size: 28),
                          const SizedBox(width: 16),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Sakin ve Detaylı Anlatım", style: TextStyle(color: _cozumTarzi == "DETAYLI" ? primaryTeal : textColor, fontWeight: FontWeight.w900, fontSize: 14, fontFamily: 'Avenir')), const SizedBox(height: 6), const Text("İşlemleri adım adım açıklar. Prosedürleri detaylı dinlemek isteyen kullanıcılar için idealdir.", style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.4, fontWeight: FontWeight.bold, fontFamily: 'Avenir'))]))
                        ]
                    )
                )
            ),
            const SizedBox(height: 48),

            // BUTONLAR (Test Et ve Kaydet)
            Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 56,
                        child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: textColor, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), side: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                            onPressed: _sesiTestEt,
                            icon: const Icon(Icons.volume_up_outlined, size: 18),
                            label: const Text("SESİ TEST ET", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir'))
                        ),
                      )
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                            onPressed: _ayarlariKaydet,
                            icon: const Icon(Icons.save_outlined, size: 18),
                            label: const Text("KAYDET", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1, fontFamily: 'Avenir'))
                        ),
                      )
                  )
                ]
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // 💎 ŞIK SEÇİM KARTLARI
  Widget _buildSecimKarti({required bool aktifMi, required Color renk, required IconData icon, required String baslik, required String aciklama}) {
    return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        decoration: BoxDecoration(
            color: aktifMi ? renk.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: aktifMi ? renk.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.05)),
            boxShadow: aktifMi ? null : [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 10)]
        ),
        child: Column(
            children: [
              Icon(icon, color: aktifMi ? renk : Colors.black26, size: 40),
              const SizedBox(height: 16),
              Text(baslik, textAlign: TextAlign.center, style: TextStyle(color: aktifMi ? renk : textColor, fontWeight: FontWeight.w900, fontSize: 13, fontFamily: 'Avenir')),
              const SizedBox(height: 6),
              Text(aciklama, textAlign: TextAlign.center, style: TextStyle(color: aktifMi ? Colors.black87 : Colors.black45, fontSize: 10, height: 1.4, fontWeight: FontWeight.bold, fontFamily: 'Avenir'))
            ]
        )
    );
  }
}