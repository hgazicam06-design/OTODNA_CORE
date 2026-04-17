// lib/screens/auth/siber_kayit_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

// 🔥 SİBER KÖPRÜLER VE TEMA (Zırh v3.0)
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

class SiberKayitScreen extends StatefulWidget {
  const SiberKayitScreen({super.key});

  @override
  State<SiberKayitScreen> createState() => _SiberKayitScreenState();
}

class _SiberKayitScreenState extends State<SiberKayitScreen> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _sifreGizli1 = true;
  bool _sifreGizli2 = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 🚀 GERÇEK FİREBASE KAYIT VE ATOMİK VERİTABANI YAZMA MOTORU (WRITEBATCH)
  Future<void> _kuantumKayitBaslat() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // 1. SİBER GÜVENLİK KONTROLLERİ
    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      HapticFeedback.heavyImpact();
      _siberUyariVer("EKSİK VERİ: Lütfen tüm siber kayıt protokollerini doldurun.", isError: true);
      return;
    }

    if (password != confirmPassword) {
      HapticFeedback.heavyImpact();
      _siberUyariVer("GÜVENLİK İHLALİ: Şifreler eşleşmiyor.", isError: true);
      return;
    }

    if (password.length < 6) {
      HapticFeedback.heavyImpact();
      _siberUyariVer("GÜVENLİK İHLALİ: Şifre en az 6 karakter olmalıdır.", isError: true);
      return;
    }

    setState(() { _isLoading = true; });
    HapticFeedback.lightImpact();
    developer.log("📡 SİBER KAPI: Yeni yetkili ($email) için Karargah sicili oluşturuluyor...");

    try {
      // 2. Firebase Auth Üzerinde Kimlik Yarat
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 3. Firestore'a Kullanıcı Profilini ve Logu Çak (Atomik İşlem - WriteBatch)
      if (userCredential.user != null) {
        WriteBatch batch = _db.batch();

        // Kullanıcı Profili
        DocumentReference userRef = _db.collection('kullanicilar').doc(userCredential.user!.uid);
        batch.set(userRef, {
          'uid': userCredential.user!.uid,
          'ad_soyad': name, // Merkezi standardizasyon
          'email': email,
          'rol': 'USER', // Auth Gate'in Sivil Kokpit'e fırlatması için BÜYÜK HARF
          'kuantum_puan': 100, // OtoDNA Başlangıç Puanı
          'kara_liste': false,
          'kayit_tarihi': FieldValue.serverTimestamp(),
        });

        // Karargah Kara Kutusu (Sistem Logu)
        DocumentReference logRef = _db.collection('sistem_loglari').doc();
        batch.set(logRef, {
          'islem_turu': 'YENI_ASKER_KAYDI',
          'islem_detayi': 'SİBER AĞ: $name ($email) Karargaha Sivil rütbeyle katıldı.',
          'tarih': FieldValue.serverTimestamp(),
        });

        // Füzeleri ateşle!
        await batch.commit();

        developer.log("✅ GÖREV TAMAM: Yeni asker sisteme mühürlendi!");
        _siberUyariVer("OTODNA AĞINA HOŞ GELDİNİZ! Kuantum Kaydı Başarılı.", isError: false);

        // Kayıt başarılı olunca giriş ekranına geri dön
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } on FirebaseAuthException catch (e) {
      HapticFeedback.heavyImpact();
      developer.log("🚨 KAYIT REDDEDİLDİ: ${e.code}");
      if (e.code == 'email-already-in-use') {
        _siberUyariVer("SİBER İHLAL: Bu e-posta zaten Kuantum Ağında kayıtlı.", isError: true);
      } else {
        _siberUyariVer("SİBER HATA: İşlem reddedildi.", isError: true);
      }
    } catch (e) {
      developer.log("🚨 SİSTEM HATASI", error: e);
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
            fontSize: 13,
            letterSpacing: 1,
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
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🛡️ SİBER 3D YENİ YETKİLİ İKONU
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: SiberTema.matGrey.withOpacity(0.8),
                    border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5), width: 2),
                    boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.2), blurRadius: 40, spreadRadius: 5)],
                  ),
                  child: const Center(
                    child: Icon(Icons.person_add_alt_1_rounded, color: SiberTema.kuantumCyan, size: 40),
                  ),
                ),

                const SizedBox(height: 30),
                const Text(
                  "AĞA KATIL",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 6,
                    fontFamily: 'Avenir',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "YENİ YETKİLİ PROTOKOLÜ",
                  style: TextStyle(
                    color: SiberTema.kuantumCyan,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                    fontFamily: 'Avenir',
                  ),
                ),
                const SizedBox(height: 40),

                // 🔥 3D SADE VE PREMIUM KAYIT FORM ALANI (Siber Cam)
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: SiberTema.matGrey.withOpacity(0.5),
                    border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10))],
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
                        icon: Icons.alternate_email,
                        hint: "Yetkili E-Posta",
                        isObscure: false,
                      ),
                      const SizedBox(height: 16),
                      _buildPremiumInput(
                        controller: _passwordController,
                        icon: Icons.lock_outline,
                        hint: "Güvenlik Şifresi",
                        isObscure: true,
                        gizlilikDurumu: _sifreGizli1,
                        onGizlilikDegistir: () => setState(() => _sifreGizli1 = !_sifreGizli1),
                      ),
                      const SizedBox(height: 16),
                      _buildPremiumInput(
                        controller: _confirmPasswordController,
                        icon: Icons.lock_reset_outlined,
                        hint: "Şifreyi Doğrula",
                        isObscure: true,
                        gizlilikDurumu: _sifreGizli2,
                        onGizlilikDegistir: () => setState(() => _sifreGizli2 = !_sifreGizli2),
                      ),
                      const SizedBox(height: 35),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan, strokeWidth: 3))
                            : ElevatedButton.icon(
                          onPressed: _kuantumKayitBaslat,
                          style: SiberTema.kuantumButonStili(), // 🔥 3D Kuantum Buton
                          icon: const Icon(Icons.rocket_launch, color: SiberTema.oledBlack, size: 20),
                          label: const Text(
                            "PROTOKOLÜ TAMAMLA",
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir', color: SiberTema.oledBlack),
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
    bool? gizlilikDurumu,
    VoidCallback? onGizlilikDegistir,
  }) {
    bool gizle = isObscure && (gizlilikDurumu ?? true);

    return TextField(
      controller: controller,
      obscureText: gizle,
      keyboardType: hint.contains("Posta") ? TextInputType.emailAddress : TextInputType.text,
      style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Avenir', fontWeight: FontWeight.w900, letterSpacing: 1),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: SiberTema.kuantumCyan.withOpacity(0.7), size: 22),
        suffixIcon: isObscure
            ? IconButton(
          icon: Icon(gizle ? Icons.visibility_off : Icons.visibility, color: Colors.white38, size: 20),
          onPressed: onGizlilikDegistir,
        )
            : null,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 13, fontFamily: 'Avenir'),
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