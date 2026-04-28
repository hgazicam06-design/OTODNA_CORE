import 'package:otodna/core/siber_tema.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SiberAsistanSohbetScreen extends StatefulWidget {
  SiberAsistanSohbetScreen({super.key});

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
  final double _sesHizi = 1.2;

  // SOHBET GEÇMİŞİ
  final List<Map<String, dynamic>> _mesajlar = [];

  // PLAZA RENKLERİ
  final Color primaryTeal = Colors.teal.shade700;
  final Color textColor = Color(0xFF1E293B);
  final Color bgColor = Color(0xFFFAFAFC);
  final Color surfaceColor = Colors.white;

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
          localeId: 'tr_TR',
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
        Future.delayed(Duration(seconds: 2), () {
          if (!mounted) return;
          setState(() {
            _yaziyor = false;
            _mesajlar.add({
              "metin": "Bu görüntüyü işledim. Bu bir Fren Diski. Orijinal OEM numarasını veri tabanından eşleştireyim mi?",
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

      String aiCevabi = "Merkez ağı tarandı. İşlem tamamlandı.";
      if (metin.toLowerCase().contains("fren") || metin.toLowerCase().contains("balata")) {
        aiCevabi = "Aracınıza uyumlu fren diskleri Global Market'te mevcut. Sizi oraya yönlendireyim mi?";
      }

      setState(() {
        _yaziyor = false;
        _mesajlar.add({"metin": aiCevabi, "kullaniciMi": false, "saat": "Şimdi"});
      });
      _asagiKaydir();
    });
  }

  void _asagiKaydir() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  // 💎 PLAZA AYARLAR MENÜSÜ
  void _asistanAyarlariniAc() {
    TextEditingController isimController = TextEditingController(text: _asistanAdi);
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: EdgeInsets.all(32),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.1), blurRadius: 20, offset: Offset(0, -5))]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)))),
              SizedBox(height: 32),
              Text("Asistan Yapılandırması", style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Avenir')),
              SizedBox(height: 24),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
                  child: TextField(
                      controller: isimController,
                      style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Avenir'),
                      decoration: InputDecoration(labelText: "Akıllı Asistan Adı", labelStyle: TextStyle(color: Colors.white54, fontSize: 12, fontFamily: 'Avenir', fontWeight: FontWeight.bold), border: InputBorder.none, floatingLabelBehavior: FloatingLabelBehavior.always)
                  )
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: () {
                    setState(() => _asistanAdi = isimController.text);
                    Navigator.pop(context);
                  },
                  child: Text("KİMLİĞİ GÜNCELLE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1, fontFamily: 'Avenir')),
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
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: primaryTeal, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text(_asistanAdi.toUpperCase(), style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 4, fontFamily: 'Avenir')),
        centerTitle: true,
        actions: [IconButton(icon: Icon(Icons.tune_outlined, color: primaryTeal), onPressed: _asistanAyarlariniAc)],
      ),
      body: Column(
        children: [
          // 1. SOHBET ALANI
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              itemCount: _mesajlar.length + (_yaziyor ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _mesajlar.length && _yaziyor) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: primaryTeal, strokeWidth: 2)),
                            SizedBox(width: 12),
                            Text("Asistan İşliyor...", style: TextStyle(color: primaryTeal.withValues(alpha: 0.8), fontSize: 12, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
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
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                        color: isUser ? primaryTeal : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20), topRight: Radius.circular(20),
                          bottomLeft: isUser ? Radius.circular(20) : Radius.circular(4),
                          bottomRight: isUser ? Radius.circular(4) : Radius.circular(20),
                        ),
                        border: isUser ? null : Border.all(color: Colors.white.withValues(alpha: 0.05)),
                        boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 10, offset: Offset(0, 2))]
                    ),
                    child: Column(
                      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        if (mesaj['gorsel'] != null)
                          Padding(
                            padding: EdgeInsets.only(bottom: 12.0),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(File(mesaj['gorsel']), height: 180, width: double.infinity, fit: BoxFit.cover)
                            ),
                          ),
                        Text(mesaj['metin'], style: TextStyle(color: isUser ? Colors.white : textColor, fontSize: 14, height: 1.5, fontWeight: FontWeight.w600, fontFamily: 'Avenir')),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. MİNİMALİST DONANIM GİRDİ ALANI
          Container(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 24),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
                boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 10, offset: Offset(0, -5))]
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // KAMERA BUTONU
                  GestureDetector(
                    onTap: _kamerayiAc,
                    child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
                        child: Icon(Icons.camera_alt_outlined, color: primaryTeal, size: 22)
                    ),
                  ),
                  SizedBox(width: 12),
              
                  // TEXT KUTUSU
                  Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
                        child: TextField(
                          controller: _mesajController,
                          style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
                          decoration: InputDecoration(
                            hintText: "Asistana mesaj yaz...",
                            hintStyle: TextStyle(color: Colors.white38, fontSize: 13, fontFamily: 'Avenir', fontWeight: FontWeight.bold),
                            border: InputBorder.none,
                          ),
                          onSubmitted: _mesajGonder,
                        ),
                      )
                  ),
                  SizedBox(width: 12),
              
                  // MİKROFON BUTONU
                  GestureDetector(
                    onTap: _sesiDinle,
                    child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                            color: _dinliyor ? Colors.redAccent : primaryTeal,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: (_dinliyor ? Colors.redAccent : primaryTeal).withValues(alpha: 0.3), blurRadius: 10, offset: Offset(0, 4))]
                        ),
                        child: Icon(_dinliyor ? Icons.graphic_eq : Icons.mic_none_outlined, color: SiberTema.kuantumCyan, size: 22)
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}