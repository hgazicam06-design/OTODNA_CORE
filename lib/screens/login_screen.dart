// lib/screens/login_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import '../core/siber_tema.dart';

/// 🏢 PLAZA KALİTESİNDE GİRİŞ TERMİNALİ (Lüks ve Ferah)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();

  bool _isProcessing = false;
  bool _sifreGizli = true;
  bool _beniHatirla = true;
  final String _seciliDil = "TR";

  @override
  void dispose() {
    _emailController.dispose();
    _sifreController.dispose();
    super.dispose();
  }

  Future<void> _kapiyiZorla() async {
    final email = _emailController.text.trim();
    final sifre = _sifreController.text.trim();

    if (email.isEmpty || sifre.isEmpty) {
      HapticFeedback.heavyImpact();
      _uyariGoster("Lütfen E-Posta ve Şifrenizi giriniz.", isError: true);
      return;
    }

    setState(() => _isProcessing = true);
    HapticFeedback.lightImpact();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: sifre);
      await _db.collection('sistem_loglari').add({
        'islem_turu': 'SİSTEM_GİRİŞİ',
        'islem_detayi': 'PLAZA GİRİŞ: $email sisteme bağlandı.',
        'tarih': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      HapticFeedback.heavyImpact();
      String hataMesaji = "Giriş Başarısız.";
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        hataMesaji = "Geçersiz E-Posta veya Şifre!";
      }
      _uyariGoster(hataMesaji, isError: true);
    } catch (e) {
      _uyariGoster("Bağlantı Hatası: İnternetinizi kontrol edin.", isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _yeniKayit() async {
    final email = _emailController.text.trim();
    final sifre = _sifreController.text.trim();

    if (email.isEmpty || sifre.isEmpty) {
      HapticFeedback.heavyImpact();
      _uyariGoster("Kayıt olmak için E-Posta ve Şifre giriniz.", isError: true);
      return;
    }

    setState(() => _isProcessing = true);
    HapticFeedback.lightImpact();

    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: sifre);
      
      await _db.collection('kullanicilar').doc(cred.user!.uid).set({
        'email': email,
        'rol': 'USER',
        'kayit_tarihi': FieldValue.serverTimestamp(),
      });

      await _db.collection('sistem_loglari').add({
        'islem_turu': 'YENİ_KAYIT',
        'islem_detayi': 'YENİ ÜYE: $email sisteme katıldı.',
        'tarih': FieldValue.serverTimestamp(),
      });
      _uyariGoster("Kayıt Başarılı! Sisteme yönlendiriliyorsunuz.");
      
    } on FirebaseAuthException catch (e) {
      HapticFeedback.heavyImpact();
      String hataMesaji = "Kayıt Başarısız.";
      if (e.code == 'email-already-in-use') {
        hataMesaji = "Bu E-Posta adresi zaten kayıtlı!";
      } else if (e.code == 'weak-password') {
        hataMesaji = "Şifre çok zayıf! En az 6 karakter olmalı.";
      } else if (e.code == 'invalid-email') {
        hataMesaji = "Geçersiz E-Posta formatı!";
      }
      _uyariGoster(hataMesaji, isError: true);
    } catch (e) {
      _uyariGoster("Bağlantı Hatası: İnternetinizi kontrol edin.", isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _uyariGoster(String mesaj, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: const TextStyle(fontWeight: FontWeight.w600, color: SiberTema.textMain, fontSize: 13, fontFamily: 'Avenir')),
        backgroundColor: isError ? SiberTema.kanKirmizi : Colors.teal.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC), // Sedefli Fil Dişi Arka Plan
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildUstBar(),
              const SizedBox(height: 60),
              
              // ── GÖRSEL VE KARŞILAMA ALANI ──
              Center(
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.white.withValues(alpha: 0.1), blurRadius: 20, spreadRadius: 5),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/images/otodna_acilis.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "OtoDNA kuantum ağına hoşgeldiniz",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  fontFamily: 'Avenir',
                ),
              ),
              const SizedBox(height: 40),

              // ── GİRİŞ FORMU ──
              _buildTextField(
                controller: _emailController,
                icon: Icons.person_outline,
                hint: "E-Posta Adresiniz",
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _sifreController,
                icon: Icons.lock_outline,
                hint: "Şifreniz",
                isPassword: true,
                sifreGizli: _sifreGizli,
                onVisibilityToggle: () => setState(() => _sifreGizli = !_sifreGizli),
              ),
              const SizedBox(height: 24),

              // ── ALT AKSİYONLAR ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _beniHatirla = !_beniHatirla),
                    child: Row(
                      children: [
                        Icon(_beniHatirla ? Icons.check_circle : Icons.radio_button_unchecked, color: _beniHatirla ? Colors.teal.shade700 : Colors.black38, size: 22),
                        const SizedBox(width: 8),
                        const Text("Beni Hatırla", style: TextStyle(color: Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Avenir')),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _uyariGoster("Şifre sıfırlama bağlantısı yakında eklenecek."),
                    child: const Text("Şifremi Unuttum", style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Avenir', decoration: TextDecoration.underline)),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // ── GİRİŞ BUTONU ──
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B), // Koyu Şık Renk
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: Colors.black.withValues(alpha: 0.2),
                ),
                onPressed: _isProcessing ? null : _kapiyiZorla,
                child: _isProcessing
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : const Text("GİRİŞ YAP", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontFamily: 'Avenir')),
              ),
              const SizedBox(height: 24),

              // ── KAYIT OL BUTONU ──
              TextButton(
                onPressed: _isProcessing ? null : _yeniKayit,
                child: RichText(
                  text: TextSpan(
                    text: "Hesabınız yok mu? ",
                    style: const TextStyle(color: Colors.white54, fontSize: 14, fontFamily: 'Avenir'),
                    children: [
                      TextSpan(
                        text: "Kayıt Olun",
                        style: TextStyle(color: Colors.teal.shade800, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUstBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.05), blurRadius: 10)],
          ),
          child: Row(
            children: [
              Text(_seciliDil, style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(width: 4),
              const Icon(Icons.language, color: Colors.white45, size: 16),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.help_outline, color: Colors.white54),
          onPressed: () => _uyariGoster("OtoDNA Destek Hattı yakında eklenecektir."),
        )
      ],
    );
  }

  Widget _buildTextField({required TextEditingController controller, required IconData icon, required String hint, bool isPassword = false, bool sifreGizli = false, VoidCallback? onVisibilityToggle}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.white.withValues(alpha: 0.03), blurRadius: 15, spreadRadius: 1, offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && sifreGizli,
        style: const TextStyle(color: Color(0xFF1E293B), fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'Avenir'),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white45, size: 22),
          suffixIcon: isPassword ? IconButton(icon: Icon(sifreGizli ? Icons.visibility_off : Icons.visibility, color: Colors.white38, size: 20), onPressed: onVisibilityToggle) : null,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 14, fontFamily: 'Avenir'),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        ),
      ),
    );
  }
}