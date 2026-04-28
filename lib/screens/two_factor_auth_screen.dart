import 'package:otodna/core/siber_tema.dart';
import 'package:flutter/material.dart';
import 'dart:async';

// 🔥 SİBER KÖPRÜLER VE TEMA
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

class TwoFactorAuthScreen extends StatefulWidget {
  TwoFactorAuthScreen({super.key});

  @override
  State<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends State<TwoFactorAuthScreen> {
  final TextEditingController _anahtarController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _anahtarController.dispose();
    super.dispose();
  }

  // 🚀 FİREBASE: 2FA SİBER ONAY MOTORU
  Future<void> _koduDogrula() async {
    String kod = _anahtarController.text.trim();

    if (kod.isEmpty || kod.length < 4) {
      _siberUyariVer("SİBER İHLAL: Lütfen 4 haneli Kuantum Anahtarını girin!", isError: true);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // 1. Karargah Ağına Bağlantı Simülasyonu (İleride Firebase SMS Verify buraya gelecek)
      await Future.delayed(Duration(seconds: 2));

      if (!mounted) return;

      // 2. Kurucu Master Anahtar Kontrolü
      if (kod == "1923") {
        _siberUyariVer("KUANTUM KİLİDİ AÇILDI! KARARGAHA GİRİLİYOR... 🦅", isError: false);

        Future.delayed(Duration(seconds: 1), () {
          // TODO: Kendi klasör yapına göre Dashboard veya Home ekranına fırlat:
          // Navigator.pushReplacementNamed(context, '/home');
        });
      } else {
        _siberUyariVer("SİBER ERİŞİM REDDEDİLDİ: Geçersiz Güvenlik Anahtarı!", isError: true);
        setState(() => _isProcessing = false);
      }
    } catch (e) {
      _siberUyariVer("AĞ ÇÖKTÜ: Doğrulama sunucusuna ulaşılamıyor!", isError: true);
      setState(() => _isProcessing = false);
    }
  }

  void _siberUyariVer(String mesaj, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: TextStyle(fontWeight: FontWeight.w900, color: isError ? Colors.white : SiberTema.oledBlack, letterSpacing: 1, fontFamily: 'Avenir')),
        backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.altinSari,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                physics: BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. SİBER KİLİT İKONU
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: SiberTema.matGrey,
                          shape: BoxShape.circle,
                          border: Border.all(color: SiberTema.altinSari.withOpacity(0.5), width: 2),
                          boxShadow: [BoxShadow(color: SiberTema.altinSari.withOpacity(0.15), blurRadius: 40, spreadRadius: 10)],
                        ),
                        child: Icon(Icons.vps_line, color: SiberTema.altinSari, size: 72),
                      ),
                    ),
                    SizedBox(height: 40),

                    // 2. BAŞLIK VE İSTİHBARAT METNİ
                    Text(
                        "İKİ AŞAMALI DOĞRULAMA",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: SiberTema.textMain, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 3, fontFamily: 'Avenir')
                    ),
                    SizedBox(height: 16),
                    Text(
                        "Ankara Merkez Güvenlik Protokolü gereği lütfen size SMS ile iletilen 4 haneli Kuantum anahtarını giriniz.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: SiberTema.textMain.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.bold, height: 1.5, letterSpacing: 1, fontFamily: 'Avenir')
                    ),
                    SizedBox(height: 48),

                    // 3. ŞİFRE GİRİŞ TERMİNALİ
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: SiberTema.matGrey,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: SiberTema.altinSari.withOpacity(0.3), width: 2),
                        boxShadow: [BoxShadow(color: SiberTema.altinSari.withOpacity(0.05), blurRadius: 20)],
                      ),
                      child: TextField(
                        controller: _anahtarController,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        textAlign: TextAlign.center,
                        style: TextStyle(letterSpacing: 24, fontSize: 32, fontWeight: FontWeight.w900, color: SiberTema.altinSari, fontFamily: 'Avenir'),
                        decoration: InputDecoration(
                          counterText: "",
                          hintText: "••••",
                          hintStyle: TextStyle(color: SiberTema.altinSari.withOpacity(0.2), letterSpacing: 24),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _isProcessing ? null : _koduDogrula(),
                      ),
                    ),
                    SizedBox(height: 48),

                    // 4. ATEŞLEME BUTONU
                    SizedBox(
                      height: 64,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SiberTema.altinSari,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          disabledBackgroundColor: SiberTema.altinSari.withOpacity(0.2),
                        ),
                        onPressed: _isProcessing ? null : _koduDogrula,
                        icon: _isProcessing
                            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: SiberTema.oledBlack, strokeWidth: 2))
                            : Icon(Icons.fingerprint, size: 28),
                        label: Text(
                            _isProcessing ? "AĞ DOĞRULANIYOR..." : "SİSTEME GİRİŞİ MÜHÜRLE",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}