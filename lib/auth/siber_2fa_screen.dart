import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Siber2FAScreen extends StatefulWidget {
  final MultiFactorResolver resolver;

  const Siber2FAScreen({super.key, required this.resolver});

  @override
  State<Siber2FAScreen> createState() => _Siber2FAScreenState();
}

class _Siber2FAScreenState extends State<Siber2FAScreen> {
  final TextEditingController _smsController = TextEditingController();

  String? _verificationId;
  bool _isLoading = false;
  bool _smsSent = false;

  @override
  void initState() {
    super.initState();
    // Ekran açılır açılmaz SMS Kuantum Roketini ateşle
    _smsGonder();
  }

  @override
  void dispose() {
    _smsController.dispose();
    super.dispose();
  }

  // GERÇEK FİREBASE SMS GÖNDERİM MOTORU
  Future<void> _smsGonder() async {
    setState(() { _isLoading = true; });

    try {
      final phoneInfo = widget.resolver.hints.first as PhoneMultiFactorInfo;

      await FirebaseAuth.instance.verifyPhoneNumber(
        multiFactorSession: widget.resolver.session,
        multiFactorInfo: phoneInfo,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Android cihazlarda SMS otomatik yakalanırsa doğrudan giriş yap
          _koduDogrulaVeGirisYap(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          _siberUyariVer("SMS HATASI: ${e.message}", isError: true);
          setState(() { _isLoading = false; });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _smsSent = true;
            _isLoading = false;
          });
          _siberUyariVer("SİBER KALKAN: Güvenlik kodu telefonuna gönderildi.", isError: false);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _siberUyariVer("BEKLENMEYEN HATA: $e", isError: true);
      setState(() { _isLoading = false; });
    }
  }

  // KULLANICININ GİRDİĞİ KODU FİREBASE'DE DOĞRULAMA
  Future<void> _manuelKodDogrula() async {
    if (_smsController.text.trim().isEmpty || _verificationId == null) {
      _siberUyariVer("EKSİK VERİ: Lütfen SMS kodunu girin.", isError: true);
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _smsController.text.trim(),
      );

      await _koduDogrulaVeGirisYap(credential);
    } catch (e) {
      _siberUyariVer("YANLIŞ KOD: Siber güvenlik zırhı kırılamadı.", isError: true);
      setState(() { _isLoading = false; });
    }
  }

  // SMS DOĞRULANDIKTAN SONRA OTO-GİRİŞ VE AĞA BAĞLANMA
  Future<void> _koduDogrulaVeGirisYap(PhoneAuthCredential credential) async {
    try {
      final assertion = PhoneMultiFactorGenerator.getAssertion(credential);
      await widget.resolver.resolveSignIn(assertion);

      // Giriş Başarılı, auth_gate.dart bizi otomatik içeri çekecek!
      if (mounted) {
        Navigator.pop(context); // 2FA ekranını kapat, karargaha dön
      }
    } on FirebaseAuthException catch (e) {
      _siberUyariVer("2FA DOĞRULAMA BAŞARISIZ: ${e.message}", isError: true);
      setState(() { _isLoading = false; });
    }
  }

  void _siberUyariVer(String mesaj, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? Colors.redAccent.shade700 : const Color(0xFF00FFC2),
        content: Text(
          mesaj,
          style: TextStyle(color: isError ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Courier'),
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF000000), // Tam OLED Siyah!
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFF00FFC2)),
          title: const Text(
            "SİBER KALKAN: 2FA",
            style: TextStyle(color: Color(0xFF00FFC2), fontFamily: 'Courier', fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
        ),
        body: Center(
            child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    const Icon(Icons.shield_outlined, size: 100, color: Color(0xFF00FFC2)),
                const SizedBox(height: 24),
                const Text(
                  "KUANTUM DOĞRULAMA",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 3),
                ),
                const SizedBox(height: 12),
                Text(
                  "Hesabın yüksek güvenlik protokolü ile korunuyor. Operasyonlarına devam etmek için operatöründen gelen SMS kodunu gir.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                ),
                const SizedBox(height: 40),

                ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            border: Border.all(color: const Color(0xFF00FFC2).withOpacity(0.3), width: 1.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                            TextField(
                            controller: _smsController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Color(0xFF00FFC2), fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 10),
                            decoration: InputDecoration(
                              hintText: "000000",
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), letterSpacing: 10),
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.3),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: const Color(0xFF00FFC2).withOpacity(0.3))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00FFC2), width: 2)),
                            ),
                          ),
                          const SizedBox(height: 30),

                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: _isLoading
                                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00FFC2)))
                                : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00FFC2).withOpacity(0.8),
                                foregroundColor: Colors.black,
                                elevation: 10,
                                shadowColor: const Color(0xFF00FFC2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _smsSent ? _manuelKodDogrula : _smsGonder,
                              child: Text(
                                _smsSent ? "ZIRHI AÇ" : "SMS GÖNDER",
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                              ),
                            ),
                          ),