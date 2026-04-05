import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🔥 SİBER KÖPRÜLER VE TEMA (Zırh v2.0)
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // GERÇEK FİREBASE KAYIT VE ATOMİK VERİTABANI YAZMA MOTORU (WRITEBATCH)
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

      // 2. Firestore'a Kullanıcı Profilini Çak (Atomik İşlem - WriteBatch)
      if (userCredential.user != null) {
        WriteBatch batch = FirebaseFirestore.instance.batch();
        DocumentReference userRef = FirebaseFirestore.instance.collection('kullanicilar').doc(userCredential.user!.uid);

        batch.set(userRef, {
          'uid': userCredential.user!.uid,
          'fullName': name,
          'email': email,
          'rol': 'user', // Başlangıç seviyesi: Kullanıcı
          'rating': 5, // OtoDNA 5 Yıldız Kuralı
          'is_blacklisted': false, // Karaliste (Black Star) durumu başlangıçta temiz
          'kayit_tarihi': FieldValue.serverTimestamp(),
        });

        // Füzeyi ateşle
        await batch.commit();

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
        backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
        content: Text(
          mesaj,
          style: TextStyle(
            color: isError ? Colors.white : SiberTema.oledBlack,
            fontWeight: FontWeight.w900,
            fontSize: 14,
            fontFamily: SiberTema.siberFont,
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
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent, // Arka plan Zırhtan geliyor
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🛡️ SİBER 3D YENİ YETKİLİ İKONU
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: SiberTema.matGrey,
                    border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3), width: 1.5),
                    boxShadow: SiberTema.siberGolgeDerin, // 🔥 3D Derinlik
                  ),
                  child: const Center(
                    child: Icon(Icons.person_add_alt_1_rounded, color: SiberTema.kuantumCyan, size: 40, shadows: [Shadow(color: SiberTema.kuantumCyan, blurRadius: 10)]),
                  ),
                ),

                const SizedBox(height: 25),
                const Text(
                  "AĞA KATIL",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    fontFamily: SiberTema.siberFont,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "YENİ YETKİLİ PROTOKOLÜ",
                  style: TextStyle(
                    color: SiberTema.kuantumCyan.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                    fontFamily: SiberTema.siberFont,
                  ),
                ),
                const SizedBox(height: 40),

                // 🔥 3D SADE VE PREMIUM KAYIT FORM ALANI
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: SiberTema.matGrey.withOpacity(0.5),
                    border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: SiberTema.siberGolgeKatmanli, // 🔥 Derinlik
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
                            ? const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan, strokeWidth: 3))
                            : ElevatedButton(
                          onPressed: _kuantumKayitBaslat,
                          style: SiberTema.kuantumButonStili(), // 🔥 3D Buton
                          child: const Text(
                            "PROTOKOLÜ TAMAMLA",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: SiberTema.siberFont, color: SiberTema.oledBlack),
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

  Widget _buildPremiumInput({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    required bool isObscure,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(color: Colors.white, fontSize: 15, fontFamily: SiberTema.siberFont, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white54, size: 22),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30, fontSize: 14, fontFamily: SiberTema.siberFont),
        filled: true,
        fillColor: SiberTema.oledBlack, // Derin siyah giriş alanı
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: SiberTema.kuantumCyan, width: 2),
        ),
      ),
    );
  }
}