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

  @override
  void initState() {
    super.initState();
    _siberSesiHazirla();
  }

  Future<void> _siberSesiHazirla() async {
    await _flutterTts.setLanguage("tr-TR");
    await _flutterTts.setSpeechRate(_konusmaHizi);
    await _flutterTts.setVolume(1.0);
    // KADIN İÇİN 1.2 (İnce), ERKEK İÇİN 0.5 (Çok daha kalın, robotik ve tok bir ses)
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

    _flutterTts.speak("Ayarlarım güncellendi Komutan.");

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$asistanIsmi: 'Ayarlarım güncellendi Komutan.' 🧠", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: const Color(0xFF00FFC2), duration: const Duration(seconds: 2))
    );
    Future.delayed(const Duration(seconds: 2), () => Navigator.pop(context));
  }

  void _sesiTestEt() async {
    FocusScope.of(context).unfocus();

    String asistanIsmi = _isimController.text.trim().isEmpty ? "Siber Asistan" : _isimController.text.trim();
    String mesaj = "Merhaba Komutan, ben $asistanIsmi. Oto DNA sistemleri emrine amade.";

    await _flutterTts.setSpeechRate(_konusmaHizi);
    // PITCH AYARI BURADA DA GÜNCELLENDİ (0.5 Terminatör Tonu)
    await _flutterTts.setPitch(_seciliSes == "KADIN" ? 1.2 : 0.5);
    await _flutterTts.speak(mesaj);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111111), // Tesla Mat Gri
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
        title: Row(
          children: [
            Icon(Icons.record_voice_over_outlined, color: _seciliSes == "KADIN" ? Colors.purpleAccent : Colors.blueAccent, size: 24),
            const SizedBox(width: 12),
            const Text("SİBER SES AKTİF", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          ],
        ),
        content: Text("Oynatma Hızı: ${_konusmaHizi.toStringAsFixed(2)}x\n\n\"$mesaj\"", style: const TextStyle(color: Colors.white54, fontSize: 13, fontStyle: FontStyle.italic, height: 1.5)),
        actions: [
          TextButton(onPressed: () {
            _flutterTts.stop();
            Navigator.pop(context);
          }, child: const Text("SUSTUR VE KAPAT", style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)))
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
    // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
    const bgColor = Color(0xFF000000);
    const surfaceColor = Color(0xFF111111);
    const primaryCyan = Color(0xFF00FFC2);
    const accentColor = Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: accentColor, size: 20), onPressed: () => Navigator.pop(context)),
          title: const Text("A I   K O N F İ G Ü R A S Y O N", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 3)),
          centerTitle: true
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BAŞLIK ALANI
            const Text("Siber Asistan", style: TextStyle(color: accentColor, fontSize: 32, fontWeight: FontWeight.w600, letterSpacing: -1)),
            const SizedBox(height: 8),
            const Text("Yapay zeka yoldaşınızın ismini, sesini, hızını ve müdahale tarzını genetik profiline işleyin.", style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5)),
            const SizedBox(height: 40),

            // 1. İSİM ALANI (Tesla Flat Input)
            const Text("1. Asistan Kimliği", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
              child: TextField(
                  controller: _isimController,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                      hintText: "Örn: Cuma, Jarvis, Asena...",
                      hintStyle: TextStyle(color: Colors.white24, fontWeight: FontWeight.normal, fontSize: 14),
                      icon: Icon(Icons.smart_toy_outlined, color: Colors.white38, size: 22),
                      border: InputBorder.none
                  )
              ),
            ),
            const SizedBox(height: 40),

            // 2. SES SEÇİMİ
            const Text("2. Ses Profili", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 16),
            Row(
                children: [
                  Expanded(child: GestureDetector(onTap: () => _sesDegistir("KADIN"), child: _buildSecimKarti(aktifMi: _seciliSes == "KADIN", renk: Colors.purpleAccent, icon: Icons.face_3_outlined, baslik: "Kadın Sesi", aciklama: "Net ve profesyonel."))),
                  const SizedBox(width: 16),
                  Expanded(child: GestureDetector(onTap: () => _sesDegistir("ERKEK"), child: _buildSecimKarti(aktifMi: _seciliSes == "ERKEK", renk: Colors.blueAccent, icon: Icons.face_6_outlined, baslik: "Erkek Sesi", aciklama: "Tok ve robotik.")))
                ]
            ),
            const SizedBox(height: 40),

            // 3. KONUŞMA HIZI
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("3. Yanıt Hızı", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)), Text("${_konusmaHizi.toStringAsFixed(2)}x", style: const TextStyle(color: primaryCyan, fontSize: 16, fontWeight: FontWeight.w900))]),
            const SizedBox(height: 12),
            Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
                child: Column(
                    children: [
                      SliderTheme(
                          data: SliderTheme.of(context).copyWith(activeTrackColor: primaryCyan, inactiveTrackColor: Colors.white12, thumbColor: primaryCyan, overlayColor: primaryCyan.withOpacity(0.2), trackHeight: 2),
                          child: Slider(value: _konusmaHizi, min: 0.5, max: 1.5, divisions: 20, onChanged: (val) => setState(() => _konusmaHizi = val))
                      ),
                      const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Yavaş (0.5x)", style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1)), Text("Hızlı (1.5x)", style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1))])
                      )
                    ]
                )
            ),
            const SizedBox(height: 40),

            // 4. MÜDAHALE TARZI
            const Text("4. Olaylara Müdahale Tarzı", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 16),
            GestureDetector(
                onTap: () => setState(() => _cozumTarzi = "HIZLI"),
                child: Container(
                    padding: const EdgeInsets.all(20), margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(color: _cozumTarzi == "HIZLI" ? Colors.orangeAccent.withOpacity(0.05) : surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: _cozumTarzi == "HIZLI" ? Colors.orangeAccent.withOpacity(0.5) : Colors.white.withOpacity(0.05))),
                    child: Row(
                        children: [
                          Icon(Icons.bolt_outlined, color: _cozumTarzi == "HIZLI" ? Colors.orangeAccent : Colors.white24, size: 28),
                          const SizedBox(width: 16),
                          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Acil ve Hızlı Çözüm (Önerilen)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)), SizedBox(height: 6), Text("Kaza/arıza anında laf kalabalığı yapmaz, doğrudan kolluk kuvveti veya çekici menüsünü açar.", style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.4))]))
                        ]
                    )
                )
            ),
            GestureDetector(
                onTap: () => setState(() => _cozumTarzi = "DETAYLI"),
                child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: _cozumTarzi == "DETAYLI" ? Colors.greenAccent.withOpacity(0.05) : surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: _cozumTarzi == "DETAYLI" ? Colors.greenAccent.withOpacity(0.5) : Colors.white.withOpacity(0.05))),
                    child: Row(
                        children: [
                          Icon(Icons.menu_book_outlined, color: _cozumTarzi == "DETAYLI" ? Colors.greenAccent : Colors.white24, size: 28),
                          const SizedBox(width: 16),
                          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Sakin ve Detaylı Anlatım", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)), SizedBox(height: 6), Text("İşlemleri adım adım açıklar. Prosedürleri dinlemek isteyen kullanıcılar için idealdir.", style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.4))]))
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
                      child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: surfaceColor, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.white.withOpacity(0.1)))),
                          onPressed: _sesiTestEt,
                          icon: const Icon(Icons.volume_up_outlined, size: 18),
                          label: const Text("SESİ TEST ET", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1))
                      )
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                      flex: 1,
                      child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: primaryCyan, foregroundColor: Colors.black, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          onPressed: _ayarlariKaydet,
                          icon: const Icon(Icons.save_outlined, size: 18),
                          label: const Text("KAYDET", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1))
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

  // 💎 TESLA MİMARİSİ: ŞIK SEÇİM KARTLARI
  Widget _buildSecimKarti({required bool aktifMi, required Color renk, required IconData icon, required String baslik, required String aciklama}) {
    return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        decoration: BoxDecoration(
            color: aktifMi ? renk.withOpacity(0.05) : const Color(0xFF111111),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: aktifMi ? renk.withOpacity(0.5) : Colors.white.withOpacity(0.05))
        ),
        child: Column(
            children: [
              Icon(icon, color: aktifMi ? renk : Colors.white24, size: 40),
              const SizedBox(height: 16),
              Text(baslik, textAlign: TextAlign.center, style: TextStyle(color: aktifMi ? renk : Colors.white54, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              Text(aciklama, textAlign: TextAlign.center, style: TextStyle(color: aktifMi ? Colors.white70 : Colors.white38, fontSize: 10, height: 1.4))
            ]
        )
    );
  }
}