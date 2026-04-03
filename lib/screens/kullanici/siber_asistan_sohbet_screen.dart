import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SiberAsistanSohbetScreen extends StatefulWidget {
  const SiberAsistanSohbetScreen({super.key});

  @override
  State<SiberAsistanSohbetScreen> createState() => _SiberAsistanSohbetScreenState();
}

class _SiberAsistanSohbetScreenState extends State<SiberAsistanSohbetScreen> {
  final TextEditingController _mesajController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _yaziyor = false;

  // GERÇEK DONANIM BİLEŞENLERİ
  final ImagePicker _picker = ImagePicker();
  late stt.SpeechToText _speech;
  bool _dinliyor = false;

  // YAPAY ZEKA AYARLARI
  String _asistanAdi = "Asena";
  double _sesHizi = 1.2;
  String _hitapSekli = "Samimi (Dostum)";

  // SOHBET GEÇMİŞİ
  final List<Map<String, dynamic>> _mesajlar = [];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _mesajlar.add({
      "metin": "Sistemler devrede Komutan! Ben $_asistanAdi. Kamerayı açıp bir parça okutabilir veya mikrofona basarak konuşabilirsin.",
      "kullaniciMi": false,
      "saat": "Şimdi"
    });
  }

  // --- GERÇEK MİKROFON (SESE DUYARLI) MODÜLÜ ---
  void _sesiDinle() async {
    if (!_dinliyor) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('Ses Durumu: $val'),
        onError: (val) => print('Ses Hatası: $val'),
      );
      if (available) {
        setState(() => _dinliyor = true);
        _speech.listen(
          localeId: 'tr_TR', // Türkçe dinleme
          onResult: (val) => setState(() {
            _mesajController.text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _dinliyor = false);
      _speech.stop();
      if (_mesajController.text.isNotEmpty) {
        _mesajGonder(_mesajController.text);
      }
    }
  }

  // --- GERÇEK KAMERA MODÜLÜ ---
  Future<void> _kamerayiAc() async {
    try {
      final XFile? foto = await _picker.pickImage(source: ImageSource.camera);
      if (foto != null) {
        setState(() {
          _mesajlar.add({
            "metin": "Görsel kanıt eklendi.",
            "kullaniciMi": true,
            "gorsel": foto.path,
            "saat": "Şimdi"
          });
          _yaziyor = true;
        });
        _asagiKaydir();

        // AI Görüntü İşleme Simülasyonu
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          setState(() {
            _yaziyor = false;
            _mesajlar.add({
              "metin": "Bu görüntüyü işledim dostum. Bu bir Fren Diski. Orijinal OEM numarasını veri tabanından eşleştireyim mi?",
              "kullaniciMi": false,
              "saat": "Şimdi"
            });
          });
          _asagiKaydir();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Kamera başlatılamadı: $e"), backgroundColor: Colors.redAccent));
    }
  }

  void _mesajGonder(String metin) {
    if (metin.trim().isEmpty) return;

    setState(() {
      _mesajlar.add({"metin": metin, "kullaniciMi": true, "saat": "Şimdi"});
      _mesajController.clear();
      _yaziyor = true;
    });
    _asagiKaydir();

    Future.delayed(Duration(milliseconds: (1500 / _sesHizi).round()), () {
      if (!mounted) return;

      String aiCevabi = "Kuantum ağı tarandı. İşlem tamamlandı.";
      if (metin.toLowerCase().contains("fren") || metin.toLowerCase().contains("balata")) {
        aiCevabi = "Aracına uyumlu fren diskleri OtoMarket'te mevcut. Seni oraya yönlendireyim mi?";
      }

      setState(() {
        _yaziyor = false;
        _mesajlar.add({"metin": aiCevabi, "kullaniciMi": false, "saat": "Şimdi"});
      });
      _asagiKaydir();
    });
  }

  void _asagiKaydir() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  // 💎 TESLA MİMARİSİ: ŞIK AYARLAR MENÜSÜ
  void _asistanAyarlariniAc() {
    TextEditingController isimController = TextEditingController(text: _asistanAdi);
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: Colors.white.withOpacity(0.05))
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 24),
              const Text("AI Kimlik Yapılandırması", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
              const SizedBox(height: 16),
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF000000), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
                  child: TextField(
                      controller: isimController,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(labelText: "Siber Asistan Adı", labelStyle: TextStyle(color: Colors.white38, fontSize: 12), border: InputBorder.none, floatingLabelBehavior: FloatingLabelBehavior.always)
                  )
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FFC2), foregroundColor: Colors.black, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    setState(() => _asistanAdi = isimController.text);
                    Navigator.pop(context);
                  },
                  child: const Text("KİMLİĞİ GÜNCELLE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🌑 TESLA / APPLE ULTRA-MİNİMALİST PALET
    const primaryCyan = Color(0xFF00FFC2);
    const bgColor = Color(0xFF000000); // Saf Siyah
    const surfaceColor = Color(0xFF111111); // Mat Gri

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text(_asistanAdi.toUpperCase(), style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 4)),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.tune_outlined, color: Colors.white), onPressed: _asistanAyarlariniAc)],
      ),
      body: Column(
        children: [
          // 1. SOHBET ALANI
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: _mesajlar.length + (_yaziyor ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _mesajlar.length && _yaziyor) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: primaryCyan, strokeWidth: 2)),
                            const SizedBox(width: 12),
                            Text("Siber Ağda İşleniyor...", style: TextStyle(color: primaryCyan.withOpacity(0.8), fontSize: 12, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold)),
                          ],
                        )
                    ),
                  );
                }

                var mesaj = _mesajlar[index];
                bool isUser = mesaj['kullaniciMi'];

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                        color: isUser ? surfaceColor : Colors.transparent,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
                          bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                          bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                        ),
                        border: Border.all(color: isUser ? Colors.white.withOpacity(0.05) : primaryCyan.withOpacity(0.3), width: 1)
                    ),
                    child: Column(
                      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        if (mesaj['gorsel'] != null) // GERÇEK KAMERA FOTOĞRAFI
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(File(mesaj['gorsel']), height: 180, width: double.infinity, fit: BoxFit.cover)
                            ),
                          ),
                        Text(mesaj['metin'], style: TextStyle(color: isUser ? Colors.white : primaryCyan, fontSize: 14, height: 1.4)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. MİNİMALİST DONANIM GİRDİ ALANI
          Container(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24), // SafeArea yerine alt boşluk
            decoration: const BoxDecoration(
                color: bgColor,
                border: Border(top: BorderSide(color: Colors.white12))
            ),
            child: Row(
              children: [
                // GERÇEK KAMERA BUTONU
                GestureDetector(
                  onTap: _kamerayiAc,
                  child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: surfaceColor, shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.05))),
                      child: const Icon(Icons.camera_alt_outlined, color: Colors.white54, size: 22)
                  ),
                ),
                const SizedBox(width: 12),

                // TEXT KUTUSU
                Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
                      child: TextField(
                        controller: _mesajController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "Komut girin...",
                          hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
                          border: InputBorder.none,
                        ),
                        onSubmitted: _mesajGonder,
                      ),
                    )
                ),
                const SizedBox(width: 12),

                // GERÇEK MİKROFON BUTONU (Animasyonlu)
                GestureDetector(
                  onTap: _sesiDinle,
                  child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: _dinliyor ? Colors.redAccent : primaryCyan,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: (_dinliyor ? Colors.redAccent : primaryCyan).withOpacity(0.3), blurRadius: 15)]
                      ),
                      child: Icon(_dinliyor ? Icons.graphic_eq : Icons.mic_none_outlined, color: Colors.black, size: 22)
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}