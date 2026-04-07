import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home/home_screen.dart';
import 'register_screen.dart';
import 'dart:ui'; // Siber-cam efekti için gerekli

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
  bool _sifreGizli = true; // Şifre görünürlüğü için siber göz kontrolü
  bool _isKullaniciGirisi = true; // Segmented Control (Kullanıcı/Bayi) durumu

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
      // Kuantum Ağına Kimlik Doğrulaması (Kullanıcı ve Bayi ayrımı Firestore tarafında HomeScreen'de yapılacak)
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
        hataMesaji = "GEÇERSİZ KİMLİK VEYA SİFRE!";
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
        content: Text(mesaj, style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5, color: Colors.black)),
        backgroundColor: isError ? dangerColor : primaryCyan,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
            // --- ÜST KOMUTA MERKEZİ (HEADER) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.notifications_none, color: primaryCyan, size: 28),
                  Column(
                    children: [
                      const Text(
                        "OtoDNA",
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                      ),
                      Text(
                        "Siber Karargah",
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 1),
                      ),
                    ],
                  ),
                  const Icon(Icons.account_circle_outlined, color: primaryCyan, size: 28),
                ],
              ),
            ),

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
                        // --- SİBER CAM PANEL İÇİNDE GİRİŞ ZIRHI ---
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0), // Glassmorphism efekti
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                              ),
                              child: Column(
                                children: [
                                  // --- 1. İKİLİ GİRİŞ SİSTEMİ (SEGMENTED CONTROL) ---
                                  Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(25),
                                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => setState(() => _isKullaniciGirisi = true),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: _isKullaniciGirisi ? Colors.transparent : Colors.transparent,
                                                borderRadius: BorderRadius.circular(25),
                                                border: _isKullaniciGirisi ? Border.all(color: primaryCyan, width: 1.5) : null,
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                "Kullanıcı",
                                                style: TextStyle(
                                                  color: _isKullaniciGirisi ? primaryCyan : Colors.white54,
                                                  fontWeight: _isKullaniciGirisi ? FontWeight.w800 : FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => setState(() => _isKullaniciGirisi = false),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: !_isKullaniciGirisi ? Colors.transparent : Colors.transparent,
                                                borderRadius: BorderRadius.circular(25),
                                                border: !_isKullaniciGirisi ? Border.all(color: primaryCyan, width: 1.5) : null,
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                "Yetkili Bayi",
                                                style: TextStyle(
                                                  color: !_isKullaniciGirisi ? primaryCyan : Colors.white54,
                                                  fontWeight: !_isKullaniciGirisi ? FontWeight.w800 : FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 32),

                                  // --- SİBER KİMLİK HİTABI ---
                                  const Text(
                                    "İyi Günler,\nSiber Komutan Gazi Çam",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, height: 1.3),
                                  ),
                                  const SizedBox(height: 32),

                                  // --- 2. GİRİŞ KUTULARI (EMAİL VE ŞİFRE) ---
                                  _buildSiberTextField(
                                    controller: _emailController,
                                    icon: Icons.person_outline,
                                    hint: _isKullaniciGirisi ? "E-Posta Adresi" : "Bayi Kodu / E-Posta",
                                  ),
                                  const SizedBox(height: 16),

                                  // Siber Göz (Şifre Göster/Gizle) içeren Şifre Kutusu
                                  _buildSiberTextField(
                                    controller: _sifreController,
                                    icon: Icons.lock_outline,
                                    hint: "Kuantum Şifre",
                                    isPassword: true,
                                    sifreGizli: _sifreGizli,
                                    onVisibilityToggle: () {
                                      setState(() {
                                        _sifreGizli = !_sifreGizli;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 24),

                                  // --- 3. ŞİFREMİ UNUTTUM / BENİ HATIRLA ---
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          _uyariGoster("ŞİFRE SIFIRLAMA PROTOKOLÜ BAŞLATILIYOR...");
                                        },
                                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                        child: const Text("Şifremi Unuttum", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w500)),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          _uyariGoster("CİHAZ HAFIZAYA ALINIYOR...");
                                        },
                                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                        child: const Text("Beni Hatırla", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w500)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 32),

                                  // --- 4. ATEŞLEME (GİRİŞ YAP) BUTONU ---
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: primaryCyan,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            side: const BorderSide(color: primaryCyan, width: 1.5)
                                        ),
                                      ),
                                      onPressed: _isProcessing ? null : _girisYap,
                                      child: _isProcessing
                                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: primaryCyan, strokeWidth: 2))
                                          : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text("Giriş Yap", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                          SizedBox(width: 8),
                                          Icon(Icons.lock_open, size: 18),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                        // --- KAYIT OL BAĞLANTISI ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Ağa henüz kayıtlı değil misin? ", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w500)),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                              },
                              child: const Text("Kayıt Ol", style: TextStyle(color: primaryCyan, fontSize: 12, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // --- ALT KOMUTA MERKEZİ (SADE, KURUMSAL, JET QR) ---
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBottomNavIcon(Icons.build_circle_outlined, "Parça\nTedarik"),
                  _buildBottomNavIcon(Icons.home_repair_service_outlined, "Siber\nServis"),

                  // Merkez Jet QR
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: primaryCyan, width: 1.5),
                          boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.3), blurRadius: 15, spreadRadius: 1)],
                        ),
                        child: const Icon(Icons.qr_code_scanner, color: primaryCyan, size: 28),
                      ),
                      const SizedBox(height: 4),
                      const Text("Jet QR", style: TextStyle(color: primaryCyan, fontSize: 10, fontWeight: FontWeight.w700)),
                    ],
                  ),

                  _buildBottomNavIcon(Icons.pie_chart_outline, "Kuantum\nAnalizler"),
                  _buildBottomNavIcon(Icons.touch_app_outlined, "Operasyon\nKontrol"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: SİBER TEXTFIELD (Siber Göz ile)
  Widget _buildSiberTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isPassword = false,
    bool sifreGizli = false,
    VoidCallback? onVisibilityToggle
  }) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1))
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && sifreGizli,
        keyboardType: isPassword ? TextInputType.text : TextInputType.emailAddress,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white54, size: 20),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(sifreGizli ? Icons.visibility_off : Icons.visibility, color: primaryCyan, size: 20), // Kurumsal Siber Göz
            onPressed: onVisibilityToggle,
          )
              : null,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13, fontWeight: FontWeight.w400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryCyan, width: 1.5),
          ),
        ),
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: ALT MENÜ İKONLARI
  Widget _buildBottomNavIcon(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white54, size: 24),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w500, height: 1.2),
        ),
      ],
    );
  }
}