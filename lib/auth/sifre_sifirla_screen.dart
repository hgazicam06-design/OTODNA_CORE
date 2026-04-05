import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SifreSifirlaScreen extends StatefulWidget {
  const SifreSifirlaScreen({super.key});

  @override
  State<SifreSifirlaScreen> createState() => _SifreSifirlaScreenState();
}

class _SifreSifirlaScreenState extends State<SifreSifirlaScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  // 🚀 FİREBASE: SİBER ŞİFRE KURTARMA MOTORU
  Future<void> _sifirlamaProtokolunuBaslat() async {
    final email = _emailCtrl.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      _siberUyariVer("EKSİK VERİ: Lütfen geçerli bir Kuantum E-Posta adresi girin.", isError: true);
      return;
    }

    setState(() { _isLoading = true; });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      _siberUyariVer("SİBER PROTOKOL AKTİF: Şifre sıfırlama bağlantısı e-postanıza ateşlendi!", isError: false);

      // Füze hedefini bulduysa, ekranı kapat ve giriş terminaline dön
      if (mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      _siberUyariVer("AĞ HATASI: İşlem başarısız oldu. ${e.message}", isError: true);
    } catch (e) {
      _siberUyariVer("SİSTEM ÇÖKMESİ: Beklenmeyen bir anomali oluştu.", isError: true);
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  void _siberUyariVer(String mesaj, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? Colors.redAccent.shade700 : const Color(0xFF00FFC2), // Kuantum Turkuazı
        content: Text(
          mesaj,
          style: TextStyle(
            color: isError ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            fontFamily: 'Avenir',
          ),
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🌑 TESLA MİMARİSİ: %100 OLED Siyah
    const Color neonCyan = Color(0xFF00FFC2);
    const Color bgKaranlik = Color(0xFF000000);

    return Scaffold(
      backgroundColor: bgKaranlik,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: neonCyan),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "ŞİFRE KURTARMA",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 2, fontFamily: 'Avenir', fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔥 Siber Kilit İkonu
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: neonCyan.withOpacity(0.05),
                  border: Border.all(color: neonCyan.withOpacity(0.3), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: neonCyan.withOpacity(0.15), blurRadius: 30, spreadRadius: 2),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.lock_reset_outlined, color: neonCyan, size: 50),
                ),
              ),
              const SizedBox(height: 30),

              const Text(
                "SİBER KİLİT KIRILIYOR",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                  fontFamily: 'Avenir',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Karargaha kayıtlı yetkili e-posta adresinizi girin. Kuantum sıfırlama protokolü anında başlatılacaktır.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                  height: 1.5,
                  fontFamily: 'Avenir',
                ),
              ),
              const SizedBox(height: 40),

              // 🔥 SADE VE PREMIUM FORM ALANI
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Avenir', letterSpacing: 1.0),
                      decoration: InputDecoration(
                        hintText: "Siber E-Posta Adresi",
                        hintStyle: const TextStyle(color: Colors.white30, fontSize: 14, fontFamily: 'Avenir'),
                        prefixIcon: const Icon(Icons.alternate_email, color: Colors.white54, size: 22),
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.2),
                        contentPadding: const EdgeInsets.symmetric(vertical: 18),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: neonCyan, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator(color: neonCyan, strokeWidth: 3))
                          : ElevatedButton(
                        onPressed: _sifirlamaProtokolunuBaslat,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: neonCyan,
                          foregroundColor: bgKaranlik,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text(
                          "BAĞLANTIYI GÖNDER",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 2, fontFamily: 'Avenir'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}