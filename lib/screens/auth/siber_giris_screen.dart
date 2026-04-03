import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// KAYIT EKRANI BAĞLANTISI (Aynı klasörde oldukları için doğrudan çağırıyoruz)
import 'siber_kayit_screen.dart';

class SiberGirisScreen extends StatefulWidget {
  const SiberGirisScreen({super.key});

  @override
  State<SiberGirisScreen> createState() => _SiberGirisScreenState();
}

class _SiberGirisScreenState extends State<SiberGirisScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _beniHatirla = true;
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
    _loginController.dispose();
    _passwordController.dispose();
    _radarController.dispose();
    super.dispose();
  }

  // --- 🔴 GERÇEK FİREBASE GİRİŞ MOTORU (ZIRHLANDI) ---
  Future<void> _kuantumGirisBaslat() async {
    final String inputText = _loginController.text.trim();
    final String password = _passwordController.text.trim();

    if (inputText.isEmpty || password.isEmpty) {
      _siberUyariVer("EKSİK VERİ: Lütfen giriş bilgilerini doldurun.", isError: true);
      return;
    }

    setState(() { _isLoading = true; });

    try {
      if (inputText.contains('@')) {
        // 1. Firebase Auth üzerinden şifre doğrulaması
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: inputText,
          password: password,
        );

        // 🔥 SİBER KALKAN: Eğer giriş başarılıysa, AuthGate bizi zaten başka ekrana atacak.
        // Bu yüzden bu ekranda işlem yapmayı veya mesaj göstermeyi BURADA KESİYORUZ.
        if (!mounted) return;

      } else {
        // Telefon ile giriş için ileride OTP (SMS) protokolü yazılacak.
        if (!mounted) return;
        _siberUyariVer("SİBER PROTOKOL: Telefon ile giriş SMS entegrasyonu bekliyor. Lütfen E-Posta kullanın.", isError: true);
        setState(() { _isLoading = false; });
        return;
      }

      // Not: Karaliste (Blacklist) kontrolü zaten OtoDnaAuthGate (Ana Kapı) içinde yapılıyor.
      // Çift kontrol yapıp sistemi yormaya veya çökmeye mahal vermeye gerek yok.
      // Giriş başarılı olduğu an bu ekran görevini tamamlar ve AuthGate devreye girer.

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _siberUyariVer("SİBER GÜVENLİK İHLALİ: Geçersiz kimlik bilgileri.", isError: true);
      setState(() { _isLoading = false; });
    } catch (e) {
      if (!mounted) return;
      _siberUyariVer("SİSTEM HATASI: Beklenmeyen bir anomali oluştu.", isError: true);
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _sifreSifirla() async {
    final email = _loginController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _siberUyariVer("HATA: Şifre sıfırlamak için önce E-Posta adresinizi girmelisiniz.", isError: true);
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _siberUyariVer("PROTOKOL AKTİF: Şifre sıfırlama bağlantısı gönderildi.", isError: false);
    } on FirebaseAuthException catch (e) {
      _siberUyariVer("BAĞLANTI HATASI: İşlem başarısız.", isError: true);
    }
  }

  void _qrSiberGozuAc() {
    _siberUyariVer("SİBER GÖZ AKTİF EDİLİYOR...", isError: false);
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
    const Color bayrakKirmizi = Color(0xFFE30A17);

    return Scaffold(
      backgroundColor: bgKaranlik,
      body: Stack(
        children: [
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
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 🔥 ZARİF ÜST BAR: BAYRAK VE QR
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 36,
                          height: 24,
                          decoration: BoxDecoration(
                            color: bayrakKirmizi,
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(color: bayrakKirmizi.withOpacity(0.3), blurRadius: 8),
                            ],
                          ),
                          child: const Center(
                            child: Text("☪", style: TextStyle(color: Colors.white, fontSize: 16, height: 1.1)),
                          ),
                        ),

                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.qr_code_scanner, color: neonCyan, size: 28),
                          onPressed: _qrSiberGozuAc,
                        ),
                      ],
                    ),

                    const SizedBox(height: 50),

                    // 🔥 SADE LOGO ALANI
                    SizedBox(
                      width: 130,
                      height: 130,
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.directions_car_outlined, color: neonCyan, size: 80);
                        },
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      "OtoDNA",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 6,
                        fontFamily: 'Avenir',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "SİBER GİRİŞ TERMİNALİ",
                      style: TextStyle(
                        color: neonCyan.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 3,
                        fontFamily: 'Avenir',
                      ),
                    ),
                    const SizedBox(height: 50),

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
                          _buildPremiumInput(
                            controller: _loginController,
                            icon: Icons.person_outline,
                            hint: "E-Posta / Telefon",
                            isObscure: false,
                          ),
                          const SizedBox(height: 20),
                          _buildPremiumInput(
                            controller: _passwordController,
                            icon: Icons.lock_outline,
                            hint: "Güvenlik Şifresi",
                            isObscure: true,
                          ),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Theme(
                                      data: ThemeData(unselectedWidgetColor: Colors.white54),
                                      child: Checkbox(
                                        value: _beniHatirla,
                                        activeColor: neonCyan,
                                        checkColor: bgKaranlik,
                                        onChanged: (value) => setState(() => _beniHatirla = value!),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text("Beni Hatırla", style: TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Avenir')),
                                ],
                              ),
                              Flexible(
                                child: TextButton(
                                  onPressed: _sifreSifirla,
                                  style: TextButton.styleFrom(padding: EdgeInsets.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                  child: const Text(
                                    "Şifremi Unuttum?",
                                    style: TextStyle(color: neonCyan, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Avenir'),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 35),

                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: _isLoading
                                ? const Center(child: CircularProgressIndicator(color: neonCyan, strokeWidth: 3))
                                : ElevatedButton(
                              onPressed: _kuantumGirisBaslat,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: neonCyan,
                                foregroundColor: bgKaranlik,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const Text(
                                "AĞA BAĞLAN",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 2, fontFamily: 'Avenir'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // 🔥 BAĞLANTI BURADA KURULDU: ÜYE OLUN BUTONU
                    TextButton(
                      onPressed: () {
                        // SiberKayıtScreen'e Yönlendirme Motoru
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SiberKayitScreen()),
                        );
                      },
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          text: "OtoDNA Ağına Dahil Değil Misin? ",
                          style: TextStyle(color: Colors.white54, fontSize: 13, fontFamily: 'Avenir'),
                          children: [
                            TextSpan(
                              text: "ÜYE OLUN",
                              style: TextStyle(color: neonCyan, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                          ],
                        ),
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