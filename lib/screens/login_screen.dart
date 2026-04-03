import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  static const Color bgColor = Color(0xFF000000);
  static const Color surfaceColor = Color(0xFF111111);
  static const Color primaryCyan = Color(0xFF00FFC2);
  static const Color dangerColor = Colors.redAccent;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();

  bool _isProcessing = false;

  @override
  void dispose() {
    _emailController.dispose();
    _sifreController.dispose();
    super.dispose();
  }

  // 🚀 FİREBASE SİBER GİRİŞ MOTORU
  Future<void> _girisYap() async {
    final email = _emailController.text.trim();
    final sifre = _sifreController.text.trim();

    if (email.isEmpty || sifre.isEmpty) {
      _uyariGoster("SİBER İHLAL: E-POSTA VE ŞİFRE BOŞ BIRAKILAMAZ!", isError: true);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Kuantum Ağına Kimlik Doğrulaması
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: sifre,
      );

      if (!mounted) return;
      _uyariGoster("KİMLİK DOĞRULANDI: MERKEZ KARARGAHA GİRİLİYOR... 🦅");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String hataMesaji = "AĞ ERİŞİMİ REDDEDİLDİ.";
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        hataMesaji = "GEÇERSİZ KİMLİK VEYA SİBER ŞİFRE!";
      }
      _uyariGoster(hataMesaji, isError: true);
    } catch (e) {
      if (!mounted) return;
      _uyariGoster("SİSTEM HATASI: Kuantum bağlantısı koptu.", isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _uyariGoster(String mesaj, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, color: Colors.black)),
        backgroundColor: isError ? dangerColor : primaryCyan,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450), // 🖥️ Web & Double Teyp Kalkanı
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. OTODNA SİBER LOGO
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryCyan.withOpacity(0.5), width: 2),
                        boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.15), blurRadius: 40, spreadRadius: 10)],
                      ),
                      child: const Icon(Icons.fingerprint, color: primaryCyan, size: 72),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text("OTODNA", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 8)),
                  const SizedBox(height: 8),
                  const Text("SİBER KARARGAHA GİRİŞ PROTOKOLÜ", textAlign: TextAlign.center, style: TextStyle(color: primaryCyan, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 48),

                  // 2. EMAİL GİRİŞ ALANI
                  _buildSiberTextField(
                    controller: _emailController,
                    icon: Icons.alternate_email,
                    hint: "SİBER E-POSTA ADRESİ",
                  ),
                  const SizedBox(height: 16),

                  // 3. ŞİFRE GİRİŞ ALANI
                  _buildSiberTextField(
                    controller: _sifreController,
                    icon: Icons.lock_outline,
                    hint: "KUANTUM ŞİFRESİ",
                    isPassword: true,
                  ),
                  const SizedBox(height: 16),

                  // 4. ŞİFREMİ UNUTTUM
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        _uyariGoster("ŞİFRE SIFIRLAMA PROTOKOLÜ BAŞLATILIYOR...");
                      },
                      child: const Text("ŞİFREMİ UNUTTUM", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 5. ATEŞLEME (GİRİŞ YAP) BUTONU
                  SizedBox(
                    height: 64,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryCyan,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        disabledBackgroundColor: primaryCyan.withOpacity(0.3),
                      ),
                      onPressed: _isProcessing ? null : _girisYap,
                      icon: _isProcessing
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                          : const Icon(Icons.login, size: 24),
                      label: Text(
                          _isProcessing ? "AĞA BAĞLANILIYOR..." : "SİSTEME GİRİŞ YAP",
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5)
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 6. KAYIT OL EKRANINA GEÇİŞ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("AĞA HENÜZ KAYITLI DEĞİL MİSİN? ", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                        },
                        child: const Text("KAYIT OL", style: TextStyle(color: primaryCyan, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: SİBER TEXTFIELD
  Widget _buildSiberTextField({required TextEditingController controller, required IconData icon, required String hint, bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05))
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isPassword ? TextInputType.text : TextInputType.emailAddress,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white38, size: 20),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: primaryCyan, width: 1.5),
          ),
        ),
      ),
    );
  }
}