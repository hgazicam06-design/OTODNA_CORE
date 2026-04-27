// lib/screens/sifre_sifirla_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🔥 SİBER KÖPRÜLER VE TEMA
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

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
        backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
        content: Text(
          mesaj,
          style: TextStyle(
            color: isError ? Colors.white : SiberTema.oledBlack,
            fontWeight: FontWeight.w900,
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
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent, // Arka plan Zırhtan geliyor
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "ŞİFRE KURTARMA",
            style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir', fontSize: 16),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🔥 3D SİBER KİLİT İKONU
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: SiberTema.matGrey,
                    border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3), width: 1.5),
                    boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.2), blurRadius: 20, spreadRadius: 2)],
                  ),
                  child: const Center(
                    child: Icon(Icons.lock_reset_rounded, color: SiberTema.kuantumCyan, size: 50, shadows: [Shadow(color: SiberTema.kuantumCyan, blurRadius: 10)]),
                  ),
                ),
                const SizedBox(height: 30),

                const Text(
                  "SİBER KİLİT KIRILIYOR",
                  style: TextStyle(
                    color: SiberTema.textMain,
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
                    color: SiberTema.textMain.withOpacity(0.6),
                    fontSize: 14,
                    height: 1.5,
                    fontFamily: 'Avenir',
                  ),
                ),
                const SizedBox(height: 40),

                // 🔥 3D SİBER FORM ALANI
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: SiberTema.matGrey.withOpacity(0.5),
                    border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [BoxShadow(color: Colors.white54, blurRadius: 20, offset: Offset(0, 10))],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: SiberTema.textMain, fontSize: 16, fontFamily: 'Avenir', letterSpacing: 1.5, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          hintText: "Siber E-Posta Adresi",
                          hintStyle: const TextStyle(color: Colors.white30, fontSize: 14, fontFamily: 'Avenir', letterSpacing: 1),
                          prefixIcon: const Icon(Icons.alternate_email, color: SiberTema.textMuted, size: 22),
                          filled: true,
                          fillColor: SiberTema.oledBlack, // Derin Siyah
                          contentPadding: const EdgeInsets.symmetric(vertical: 20),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.05), width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: SiberTema.kuantumCyan, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan, strokeWidth: 3))
                            : ElevatedButton(
                          onPressed: _sifirlamaProtokolunuBaslat,
                          style: SiberTema.kuantumButonStili(), // 🔥 3D Kuantum Butonu
                          child: const Text(
                            "BAĞLANTIYI GÖNDER",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir', color: SiberTema.oledBlack),
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
      ),
    );
  }
}