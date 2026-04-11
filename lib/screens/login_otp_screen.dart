import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 🦅 OTODNA SİBER GİRİŞ PROTOKOLÜ (OTP)
/// [2026-03-28] GÜNCELLEME: Firebase Gerçek Zamanlı SMS Doğrulama Motoru
class LoginOTPScreen extends StatefulWidget {
  const LoginOTPScreen({super.key});

  @override
  State<LoginOTPScreen> createState() => _LoginOTPScreenState();
}

class _LoginOTPScreenState extends State<LoginOTPScreen> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  static const Color bgColor = Color(0xFF000000);
  static const Color surfaceColor = Color(0xFF111111);
  static const Color primaryCyan = Color(0xFF00FFC2);
  static const Color dangerColor = Colors.redAccent;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();

  bool _otpGonderildi = false;
  bool _isProcessing = false;
  String _verificationId = "";

  @override
  void dispose() {
    _phoneController.dispose();
    _smsController.dispose();
    super.dispose();
  }

  // 🚀 FİREBASE: SİBER SMS GÖNDERME MOTORU
  Future<void> _kodGonder() async {
    String telNo = _phoneController.text.trim();
    if (telNo.isEmpty || telNo.length < 10) {
      _uyariGoster("SİBER İHLAL: GEÇERLİ BİR TELEFON NUMARASI GİRİN (+90...)", isError: true);
      return;
    }

    // Ülke kodu yoksa otomatik ekle
    if (!telNo.startsWith('+')) {
      telNo = '+90$telNo';
    }

    setState(() => _isProcessing = true);

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: telNo,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Kuantum Ağı SMS'i otomatik yakalarsa (Siber Hız)
          await FirebaseAuth.instance.signInWithCredential(credential);
          _girisBasarili();
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _isProcessing = false);
          _uyariGoster("SİNYAL HATASI: ${e.message}", isError: true);
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _otpGonderildi = true;
            _isProcessing = false;
          });
          _uyariGoster("KUANTUM SİNYALİ GÖNDERİLDİ! LÜTFEN KODU GİRİN.");
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      setState(() => _isProcessing = false);
      _uyariGoster("AĞ ÇÖKTÜ: $e", isError: true);
    }
  }

  // 🚀 FİREBASE: SİBER KOD DOĞRULAMA MOTORU
  Future<void> _koduDogrula() async {
    final smsCode = _smsController.text.trim();
    if (smsCode.length != 6) {
      _uyariGoster("SİBER İHLAL: KOD 6 HANELİ OLMALIDIR!", isError: true);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: smsCode,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      _girisBasarili();
    } on FirebaseAuthException catch (e) {
      setState(() => _isProcessing = false);
      _uyariGoster("HATALI SİNYAL: Şifre Yanlış veya Süresi Dolmuş!", isError: true);
    } catch (e) {
      setState(() => _isProcessing = false);
      _uyariGoster("AĞ ÇÖKTÜ: $e", isError: true);
    }
  }

  void _girisBasarili() {
    if (!mounted) return;
    setState(() => _isProcessing = false);
    _uyariGoster("KİMLİK DOĞRULANDI! KARARGAHA GİRİLİYOR 🦅");
    // Gelecekteki rota: Navigator.pushReplacementNamed(context, '/home');
  }

  void _uyariGoster(String mesaj, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, color: Colors.black, fontSize: 11)),
        backgroundColor: isError ? dangerColor : primaryCyan,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryCyan, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 🛡️ SİBER LOGO
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: surfaceColor,
                        border: Border.all(color: primaryCyan.withOpacity(0.5), width: 2),
                        boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.15), blurRadius: 40, spreadRadius: 10)],
                      ),
                      child: const Icon(Icons.security, color: primaryCyan, size: 72),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text("SİBER GÜVENLİK", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 4)),
                  const SizedBox(height: 8),
                  const Text("ANKARA MERKEZ DİSTRİBÜTÖRLÜK ONAYI", textAlign: TextAlign.center, style: TextStyle(color: primaryCyan, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  const SizedBox(height: 48),

                  // 📞 TELEFON GİRİŞ ALANI
                  _buildSiberTextField(
                    controller: _phoneController,
                    icon: Icons.phone_android,
                    hint: "+90 5XX XXX XX XX",
                    isNumber: true,
                    enabled: !_otpGonderildi,
                  ),

                  // 💬 SMS KODU GİRİŞ ALANI
                  if (_otpGonderildi) ...[
                    const SizedBox(height: 16),
                    _buildSiberTextField(
                      controller: _smsController,
                      icon: Icons.vibration,
                      hint: "6 HANELİ KUANTUM KODU",
                      isNumber: true,
                      isCentered: true,
                    ),
                  ],

                  const SizedBox(height: 40),

                  // 🚀 ATEŞLEME BUTONU
                  SizedBox(
                    height: 64,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryCyan,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _isProcessing
                          ? null
                          : (_otpGonderildi ? _koduDogrula : _kodGonder),
                      icon: _isProcessing
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                          : Icon(_otpGonderildi ? Icons.verified_user : Icons.send, size: 24),
                      label: Text(
                          _isProcessing
                              ? "AĞA BAĞLANILIYOR..."
                              : (_otpGonderildi ? "MÜHRÜ AÇ VE GİRİŞ YAP" : "OTP SİNYALİ GÖNDER"),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)
                      ),
                    ),
                  ),

                  if (_otpGonderildi && !_isProcessing) ...[
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => setState(() => _otpGonderildi = false),
                      child: const Text("SİNYAL ALINAMADI (YENİDEN GÖNDER)", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    )
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSiberTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isNumber = false,
    bool enabled = true,
    bool isCentered = false,
  }) {
    return Container(
      decoration: BoxDecoration(
          color: enabled ? surfaceColor : bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: enabled ? Colors.white.withOpacity(0.05) : dangerColor.withOpacity(0.3))
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
        textAlign: isCentered ? TextAlign.center : TextAlign.start,
        style: TextStyle(color: enabled ? Colors.white : Colors.white38, fontSize: isCentered ? 20 : 14, letterSpacing: isCentered ? 8 : 1, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          prefixIcon: isCentered ? null : Icon(icon, color: Colors.white38, size: 20),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primaryCyan, width: 1.5)),
        ),
      ),
    );
  }
}