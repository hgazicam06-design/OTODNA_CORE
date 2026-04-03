import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SifreSifirlamaScreen extends StatefulWidget {
  const SifreSifirlamaScreen({super.key});

  @override
  State<SifreSifirlamaScreen> createState() => _SifreSifirlamaScreenState();
}

class _SifreSifirlamaScreenState extends State<SifreSifirlamaScreen> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  static const Color bgColor = Color(0xFF000000);
  static const Color surfaceColor = Color(0xFF111111);
  static const Color primaryCyan = Color(0xFF00FFC2);
  static const Color dangerColor = Colors.redAccent;

  final TextEditingController _emailController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // 🚀 FİREBASE: SİBER SIFIRLAMA MOTORU
  Future<void> _sifreSifirlamaGonder() async {
    String email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      _uyariGoster('SİBER İHLAL: Lütfen geçerli bir Kuantum E-Posta adresi girin!', isError: true);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // 💥 Firebase Doğrudan Şifre Sıfırlama Tetikleyicisi
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;
      _uyariGoster('SİBER SIFIRLAMA SİNYALİ E-POSTANIZA FIRLATILDI! 🦅', isError: false);

      // Sinyal gönderildikten 2 saniye sonra Karargah kapısına (Login) fırlat
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });

    } on FirebaseAuthException catch (e) {
      String hataMesaji = 'AĞ ÇÖKTÜ: Sinyal iletilemedi.';
      if (e.code == 'user-not-found') {
        hataMesaji = 'HATA: Bu e-posta adresine ait bir OtoDNA kimliği bulunamadı!';
      }
      _uyariGoster(hataMesaji, isError: true);
    } catch (e) {
      _uyariGoster('SİSTEM HATASI: Beklenmeyen bir ağ sorunu oluştu.', isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _uyariGoster(String mesaj, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1)),
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
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryCyan, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("ŞİFRE SIFIRLAMA PROTOKOLÜ", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500), // 🖥️ Web / Double Teyp Kalkanı
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 🛡️ SİBER KİLİT İKONU
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryCyan.withOpacity(0.5), width: 2),
                        boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.15), blurRadius: 40, spreadRadius: 10)],
                      ),
                      child: const Icon(Icons.lock_reset, color: primaryCyan, size: 72),
                    ),
                  ),
                  const SizedBox(height: 32),

                  const Text('KUANTUM KİLİDİ AÇ', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 4)),
                  const SizedBox(height: 16),

                  Text(
                    'Kayıtlı siber e-posta adresinizi girin. Sisteme yeniden sızmanız için size şifreli bir doğrulama sinyali fırlatacağız.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.bold, height: 1.6, letterSpacing: 1),
                  ),
                  const SizedBox(height: 48),

                  // ✉️ E-POSTA GİRİŞ KUTUSU
                  Container(
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.alternate_email, color: Colors.white38, size: 20),
                        hintText: 'SİBER E-POSTA ADRESİ',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: primaryCyan, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 🚀 ATEŞLEME BUTONU
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
                      onPressed: _isProcessing ? null : _sifreSifirlamaGonder,
                      icon: _isProcessing
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                          : const Icon(Icons.send_rounded, size: 24),
                      label: Text(
                          _isProcessing ? "SİNYAL FIRLATILIYOR..." : "SIFIRLAMA SİNYALİ GÖNDER",
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}