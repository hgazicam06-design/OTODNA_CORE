import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart'; // Karargah ana ekranı
import 'register_screen.dart'; // Kayıt protokolü
import 'dart:ui'; // Siber-cam efekti için gerekli

/// 🦅 OTODNA SİBER GİRİŞ KALKANI - V2
/// [2026-03-28] GÜNCELLEME: Firebase Gerçek Zamanlı Kimlik Doğrulama ve Glassmorphism
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 🌑 KURUMSAL ZIRH: TRUE BLACK & KUANTUM TURKUAZI
  static const Color bgColor = Color(0xFF000000); // Dipsiz Siyah
  static const Color primaryCyan = Color(0xFF00FFC2); // Kuantum Turkuazı
  static const Color dangerColor = Colors.redAccent;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();

  bool _isProcessing = false;
  bool _sifreGizli = true; // Siber Göz (Şifre Görünürlüğü)
  bool _isKullaniciGirisi = true; // Segmented Control Durumu

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
      _uyariGoster("SİBER İHLAL: GİRİŞ BİLGİLERİ EKSİK!", isError: true);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Kuantum Ağına Bağlantı Kuruluyor
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: sifre,
      );

      if (!mounted) return;
      _uyariGoster("KİMLİK DOĞRULANDI: MERKEZ KARARGAHA GİRİLİYOR... 🦅");

      // Başarılı Giriş: Ana Karargaha Yönlendir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String hataMesaji = "AĞ ERİŞİMİ REDDEDİLDİ.";
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        hataMesaji = "GEÇERSİZ KİMLİK VEYA ŞİFRE!";
      }
      _uyariGoster(hataMesaji, isError: true);
    } catch (e) {
      if (!mounted) return;
      _uyariGoster("SİSTEM HATASI: Bağlantı koptu.", isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _uyariGoster(String mesaj, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5, color: Colors.black, fontSize: 11)),
        backgroundColor: isError ? dangerColor : primaryCyan,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- ÜST KOMUTA MERKEZİ ---
            _buildHeader(),

            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- SİBER CAM PANEL ---
                        _buildGlassCard(),
                        const SizedBox(height: 32),
                        // --- KAYIT OL BAĞLANTISI ---
                        _buildRegisterLink(),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // --- ALT KOMUTA MERKEZİ (QR VE ANALİZLER) ---
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.notifications_none, color: primaryCyan, size: 28),
          const Column(
            children: [
              Text("OtoDNA", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              Text("Siber Karargah", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 2)),
            ],
          ),
          Icon(Icons.security, color: primaryCyan.withOpacity(0.5), size: 28),
        ],
      ),
    );
  }

  Widget _buildGlassCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
          ),
          child: Column(
            children: [
              // Segmented Control (Kullanıcı / Bayi)
              _buildSegmentedControl(),
              const SizedBox(height: 32),
              const Text("HOŞ GELDİNİZ\nKOMUTAN GAZİ", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)),
              const SizedBox(height: 32),
              _buildSiberTextField(controller: _emailController, icon: Icons.alternate_email, hint: "AĞ ADRESİ (E-POSTA)"),
              const SizedBox(height: 16),
              _buildSiberTextField(
                controller: _sifreController,
                icon: Icons.vpn_key_outlined,
                hint: "SİBER ŞİFRE",
                isPassword: true,
                sifreGizli: _sifreGizli,
                onVisibilityToggle: () => setState(() => _sifreGizli = !_sifreGizli),
              ),
              const SizedBox(height: 40),
              _buildAteslemeButonu(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      height: 44,
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white10)),
      child: Row(
        children: [
          _buildSegmentTab("Kullanıcı", _isKullaniciGirisi, () => setState(() => _isKullaniciGirisi = true)),
          _buildSegmentTab("Yetkili Bayi", !_isKullaniciGirisi, () => setState(() => _isKullaniciGirisi = false)),
        ],
      ),
    );
  }

  Widget _buildSegmentTab(String title, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isActive ? primaryCyan : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          alignment: Alignment.center,
          child: Text(title, style: TextStyle(color: isActive ? Colors.black : Colors.white38, fontSize: 12, fontWeight: FontWeight.w900)),
        ),
      ),
    );
  }

  Widget _buildAteslemeButonu() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: primaryCyan,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: primaryCyan, width: 2)),
          elevation: 0,
        ),
        onPressed: _isProcessing ? null : _girisYap,
        child: _isProcessing
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: primaryCyan, strokeWidth: 2))
            : const Text("AĞI AKTİFLEŞTİR", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2)),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Henüz kayıtlı değil misin? ", style: TextStyle(color: Colors.white38, fontSize: 12)),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
          child: const Text("YENİ KAYIT AÇ", style: TextStyle(color: primaryCyan, fontSize: 12, fontWeight: FontWeight.w900)),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.01), border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavIcon(Icons.dashboard_customize_outlined, "Panel"),
          _buildNavIcon(Icons.analytics_outlined, "Analiz"),
          // Jet QR Merkezi
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
              border: Border.all(color: primaryCyan, width: 2),
              boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.2), blurRadius: 15)],
            ),
            child: const Icon(Icons.qr_code_scanner, color: primaryCyan, size: 28),
          ),
          _buildNavIcon(Icons.settings_input_component, "Servis"),
          _buildNavIcon(Icons.admin_panel_settings_outlined, "Kontrol"),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white24, size: 24),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white24, fontSize: 8, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSiberTextField({required TextEditingController controller, required IconData icon, required String hint, bool isPassword = false, bool sifreGizli = false, VoidCallback? onVisibilityToggle}) {
    return Container(
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
      child: TextField(
        controller: controller,
        obscureText: isPassword && sifreGizli,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: primaryCyan.withOpacity(0.5), size: 20),
          suffixIcon: isPassword ? IconButton(icon: Icon(sifreGizli ? Icons.visibility_off : Icons.visibility, color: primaryCyan, size: 20), onPressed: onVisibilityToggle) : null,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white12, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryCyan, width: 1.5)),
        ),
      ),
    );
  }
}