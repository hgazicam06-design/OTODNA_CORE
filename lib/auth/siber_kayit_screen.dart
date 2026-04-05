import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SiberKayitScreen extends StatefulWidget {
  const SiberKayitScreen({super.key});

  @override
  State<SiberKayitScreen> createState() => _SiberKayitScreenState();
}

class _SiberKayitScreenState extends State<SiberKayitScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _radarController.dispose();
    super.dispose();
  }

  // GERÇEK FİREBASE KAYIT VE ATOMİK VERİTABANI YAZMA MOTORU
  Future<void> _kuantumKayitBaslat() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _siberUyariVer("EKSİK VERİ: Lütfen tüm siber kayıt protokollerini doldurun.", isError: true);
      return;
    }

    if (password != confirmPassword) {
      _siberUyariVer("GÜVENLİK İHLALİ: Şifreler eşleşmiyor.", isError: true);
      return;
    }

    if (password.length < 6) {
      _siberUyariVer("GÜVENLİK İHLALİ: Şifre en az 6 karakter olmalıdır.", isError: true);
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // 1. Firebase Auth Üzerinde Kimlik Yarat
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Firestore'a Kullanıcı Profilini ve OtoDNA Kurallarını Çak (Atomik İşlem)
      if (userCredential.user != null) {
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'fullName': name,
          'email': email,
          'role': 'user', // Başlangıç seviyesi: Kullanıcı
          'rating': 5, // OtoDNA 5 Yıldız Kuralı
          'isBlacklisted': false, // Karaliste (Black Star) durumu başlangıçta temiz
          'createdAt': FieldValue.serverTimestamp(),
        });

        _siberUyariVer("OTODNA AĞINA HOŞ GELDİNİZ! Kuantum Kaydı Başarılı.", isError: false);

        // Kayıt başarılı olunca giriş ekranına geri dön
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _siberUyariVer("SİBER İHLAL: Bu e-posta zaten Kuantum Ağında kayıtlı.", isError: true);
      } else {
        _siberUyariVer("SİBER HATA: ${e.message}", isError: true);
      }
    } catch (e) {
      _siberUyariVer("SİSTEM HATASI: Kayıt sırasında anomali oluştu.", isError: true);
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  void _siberUyariVer(String mesaj, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? Colors.redAccent.shade700 : const Color(0xFF00F0FF),
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
    const Color neonCyan = Color(0xFF00F0FF);
    const Color bgKaranlik = Color(0xFF050505);

    return Scaffold(
      backgroundColor: bgKaranlik,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Sade ve Şık Arka Plan Aydınlatması
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _radarController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [neonCyan.withOpacity(0.04), bgKaranlik],
                      stops: [_radarController.value, _radarController.value + 0.8],
                      radius: 1.2,
                    ),
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Siber Yeni Yetkili İkonu
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.02),
                        border: Border.all(color: neonCyan.withOpacity(0.3), width: 1.5),
                        boxShadow: [
                          BoxShadow(color: neonCyan.withOpacity(0.15), blurRadius: 30, spreadRadius: 2),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.person_add_alt_1_outlined, color: neonCyan, size: 45),
                      ),
                    ),

                    const SizedBox(height: 25),
                    const Text(
                      "AĞA KATIL",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4,
                        fontFamily: 'Avenir',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "YENİ YETKİLİ PROTOKOLÜ",
                      style: TextStyle(
                        color: neonCyan.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 3,
                        fontFamily: 'Avenir',
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 🔥 SADE VE PREMIUM KAYIT FORM ALANI
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.02),
                        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          _buildPremiumInput(
                            controller: _nameController,
                            icon: Icons.badge_outlined,
                            hint: "Ad Soyad / Firma Adı",
                            isObscure: false,
                          ),
                          const SizedBox(height: 16),
                          _buildPremiumInput(
                            controller: _emailController,
                            icon: Icons.email_outlined,
                            hint: "Yetkili E-Posta",
                            isObscure: false,
                          ),
                          const SizedBox(height: 16),
                          _buildPremiumInput(
                            controller: _passwordController,
                            icon: Icons.lock_outline,
                            hint: "Güvenlik Şifresi",
                            isObscure: true,
                          ),
                          const SizedBox(height: 16),
                          _buildPremiumInput(
                            controller: _confirmPasswordController,
                            icon: Icons.lock_reset_outlined,
                            hint: "Şifreyi Doğrula",
                            isObscure: true,
                          ),
                          const SizedBox(height: 35),

                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: _isLoading
                                ? const Center(child: CircularProgressIndicator(color: neonCyan, strokeWidth: 3))
                                : ElevatedButton(
                              onPressed: _kuantumKayitBaslat,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: neonCyan,
                                foregroundColor: bgKaranlik,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const Text(
                                "PROTOKOLÜ TAMAMLA",
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 1.5, fontFamily: 'Avenir'),
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
        ],
      ),
    );
  }

  Widget _buildPremiumInput({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    required bool isObscure,
  }) {
    const Color neonCyan = Color(0xFF00F0FF);
    return TextField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'Avenir'),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white54, size: 22),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30, fontSize: 14, fontFamily: 'Avenir'),
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
    );
  }
}