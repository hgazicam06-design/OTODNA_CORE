import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../core/siber_tema.dart';

/// 🏢 VIP PLAZA GİRİŞ TERMİNALİ
/// Somun tasarımı iptal edilmiş, yerine "Marble & Gold" (Mermer ve Altın) 
/// kurumsal/bankacılık stili entegre edilmiştir. Yazı tipleri "Sert ve Kurumsal"dır.
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
      _uyariGoster("Lütfen E-Posta ve Kuantum Şifrenizi giriniz.", isError: true);
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

  void _uyariGoster(String mesaj, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13, fontFamily: 'Avenir', letterSpacing: 1.0)),
        backgroundColor: isError ? SiberTema.kanKirmizi : const Color(0xFFC5A059), // Gold error/success
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC), // Fildişi/Krem zemin
      body: Stack(
        children: [
          // ── ARKA PLAN (Mermer Dokusu Simülasyonu) ──
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFFFFFFF),
                    const Color(0xFFF0F0F5),
                    const Color(0xFFE8E8EE),
                  ],
                ),
              ),
              // İnce mermer çatlaklarını simüle etmek için hafif bir noise/pattern eklenebilir,
              // Şimdilik lüks bir gradient kullanıyoruz.
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                // ── ÜST BAŞLIK (HEADER & LOGO) ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "OtoDNA",
                            style: TextStyle(
                              color: const Color(0xFF2C2519), // Koyu Kahve/Gold
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                              fontFamily: 'Avenir', // Sert ve Keskin
                            ),
                          ),
                          Text(
                            "Siber Karargah",
                            style: TextStyle(
                              color: const Color(0xFF8B7355), // Orta Kahve
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              fontFamily: 'Avenir',
                            ),
                          ),
                        ],
                      ),
                      // Dil Seçimi
                      Row(
                        children: [
                          const Text("TR", style: TextStyle(color: Color(0xFF8B7355), fontWeight: FontWeight.w900, fontSize: 13, fontFamily: 'Avenir')),
                          const SizedBox(width: 4),
                          const Icon(Icons.language, color: Color(0xFF8B7355), size: 18),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // ── MERKEZ VIP GİRİŞ KARTI ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFEBE3D5), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B7355).withOpacity(0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Karşılama Metni
                        const Text(
                          "İyi Günler, Siber Komutan\nGazi Çam",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF2C2519), // Sert ve koyu
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            fontFamily: 'Avenir',
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // E-Posta Alanı
                        _buildGoldTextField(
                          controller: _emailController,
                          icon: Icons.person_outline,
                          hint: "E-Posta / Sicil No",
                        ),
                        const SizedBox(height: 16),

                        // Şifre Alanı
                        _buildGoldTextField(
                          controller: _sifreController,
                          icon: Icons.lock_outline,
                          hint: "Kuantum Şifre",
                          isPassword: true,
                          sifreGizli: _sifreGizli,
                          onVisibilityToggle: () => setState(() => _sifreGizli = !_sifreGizli),
                        ),
                        const SizedBox(height: 24),

                        // Şifremi Unuttum & Beni Hatırla
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => _uyariGoster("Şifre sıfırlama yakında aktif edilecek."),
                              child: const Text(
                                "Şifremi Unuttum",
                                style: TextStyle(
                                  color: Color(0xFF8B7355),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Color(0xFF8B7355),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _beniHatirla = !_beniHatirla),
                              child: Row(
                                children: [
                                  Text(
                                    "Beni Hatırla",
                                    style: const TextStyle(
                                      color: Color(0xFF8B7355),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: const Color(0xFF8B7355), width: 2),
                                      borderRadius: BorderRadius.circular(4),
                                      color: _beniHatirla ? const Color(0xFF8B7355) : Colors.transparent,
                                    ),
                                    child: _beniHatirla
                                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // ALTIN / GOLD GİRİŞ BUTONU
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFE2C485), // Açık Altın
                                  Color(0xFFC5A059), // Orta Altın
                                  Color(0xFFA57D36), // Koyu Altın
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFC5A059).withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: _isProcessing ? null : _kapiyiZorla,
                                child: Center(
                                  child: _isProcessing
                                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              "Giriş Yap",
                                              style: TextStyle(
                                                color: Colors.white, // Zıtlık için bembeyaz
                                                fontSize: 16,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 2.0,
                                                fontFamily: 'Avenir',
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Icon(Icons.lock, color: Colors.white, size: 18),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // ── 5 İKONLU ALT MENÜ (BOTTOM BAR) ──
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildBottomMenuIcon(Icons.settings_outlined, "Parça\nTedarik"),
                      _buildBottomMenuIcon(Icons.build_outlined, "Siber\nServis"),
                      
                      // Merkez Büyük QR İkonu
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.heavyImpact();
                          _uyariGoster("Kuantum Radar Başlatılıyor...");
                          // Navigator.push(context, MaterialPageRoute(builder: (context) => QrPublicScreen()));
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF9EDD6), Color(0xFFDCC8A9)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(color: const Color(0xFFC5A059), width: 2),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFFC5A059).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5)),
                            ],
                          ),
                          child: const Icon(Icons.qr_code_scanner, color: Color(0xFF8B7355), size: 32),
                        ),
                      ),

                      _buildBottomMenuIcon(Icons.pie_chart_outline, "Kuantum\nAnalizler"),
                      _buildBottomMenuIcon(Icons.checklist_rtl_outlined, "Operasyon\nKontrol"),
                    ],
                  ),
                ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
  }

  // ── YARDIMCI WIDGETLAR (ALTIN ÇERÇEVELİ) ──
  Widget _buildGoldTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isPassword = false,
    bool sifreGizli = false,
    VoidCallback? onVisibilityToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCC8A9), width: 1.5), // Altın/Kahve Border
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && sifreGizli,
        style: const TextStyle(
          color: Color(0xFF2C2519), // Sert siyah/kahve
          fontSize: 15,
          fontWeight: FontWeight.w900,
          fontFamily: 'Avenir',
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF8B7355), size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(sifreGizli ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF8B7355), size: 20),
                  onPressed: onVisibilityToggle,
                )
              : null,
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFBCAAA4), fontSize: 14, fontWeight: FontWeight.bold),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildBottomMenuIcon(IconData icon, String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF8B7355), size: 28),
        const SizedBox(height: 6),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF2C2519),
            fontSize: 10,
            fontWeight: FontWeight.w900, // Sert font
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}