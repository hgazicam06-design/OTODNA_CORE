// lib/screens/login_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

// 🚀 KARARGAH ZIRHLARI VE TEMA
import '../core/siber_tema.dart';

/// 🏦 SİBER BANKA GİRİŞ TERMİNALİ (Yapı Kredi Vizyonu)
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
  String _seciliDil = "TR";

  // Profil fotoğrafı URL'si (Beni hatırla açıksa ve cache'te varsa buraya gelir)
  String? _kayitliProfilFoto;

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
      _uyariGoster("SİBER İHLAL: KİMLİK VE ŞİFRE GİRİLMELİ!", isError: true);
      return;
    }

    setState(() => _isProcessing = true);
    HapticFeedback.lightImpact();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: sifre);
      await _db.collection('sistem_loglari').add({
        'islem_turu': 'SİSTEM_GİRİŞİ',
        'islem_detayi': 'SİBER ONAY: $email Karargaha giriş yaptı.',
        'tarih': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      HapticFeedback.heavyImpact();
      String hataMesaji = "AĞ ERİŞİMİ REDDEDİLDİ.";
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        hataMesaji = "GEÇERSİZ KİMLİK VEYA ŞİFRE!";
      }
      _uyariGoster(hataMesaji, isError: true);
    } catch (e) {
      _uyariGoster("SİSTEM HATASI: Bağlantı koptu.", isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _uyariGoster(String mesaj, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5, color: isError ? Colors.white : SiberTema.oledBlack, fontSize: 11, fontFamily: 'Avenir')),
        backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _siberAgUyarisiGoster() {
    _uyariGoster("İçerikleri görmek için Kuantum Ağına giriş yapınız.", isError: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. ARKA PLAN (Gönderdiğiniz Devre/Araç Resmi veya Karanlık Zemin)
          Positioned.fill(
            child: Image.asset(
              'assets/images/siber_zemin_altin_kanalli.png', // Gönderdiğiniz resmi bu isimle assets içine atabilirsiniz
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(colors: [Color(0xFF1E1E2E), Colors.black], radius: 1.5),
                ),
              ),
            ),
          ),
          // Bulanıklık ve Karanlık Filtresi (Logo ve Form öne çıksın diye)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black.withOpacity(0.4)),
            ),
          ),

          // 2. ANA ARAYÜZ (GÜVENLİ ALAN)
          SafeArea(
            child: Column(
              children: [
                _buildSiberBankaUstBar(), // Dil ve Hızlı Menüler
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        _buildSomunAvatar(), // Merkezdeki 6 Köşeli Somun Logo
                        const SizedBox(height: 50),
                        _buildGirisFormu(), // Şifre ve E-Posta Alanı
                        const SizedBox(height: 24),
                        _buildAltinUcluAksiyon(), // Beni Hatırla - QR - Şifremi Unuttum
                        const SizedBox(height: 40),
                        _buildAteslemeButonu(), // GİRİŞ YAP
                        const SizedBox(height: 32),
                        GestureDetector(
                          onTap: () => _uyariGoster("Kayıt Portalı Henüz Aktif Değil"),
                          child: const Text("AĞA KATILIN (Yeni Kayıt)", style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ─── 1. SİBER BANKA ÜST BARI ───
  Widget _buildSiberBankaUstBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Sol Üst: Dil Seçimi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24)),
            child: Row(
              children: [
                Text(_seciliDil, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'Avenir')),
                const SizedBox(width: 4),
                const Icon(Icons.language, color: SiberTema.kuantumCyan, size: 14),
              ],
            ),
          ),
          // Sağ Üst: Radar İkonları
          Row(
            children: [
              _buildUstIkon(Icons.email_outlined, _siberAgUyarisiGoster),
              _buildUstIkon(Icons.notifications_none, _siberAgUyarisiGoster),
              _buildUstIkon(Icons.favorite_border, _siberAgUyarisiGoster),
              _buildUstIkon(Icons.local_offer_outlined, _siberAgUyarisiGoster),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildUstIkon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 12),
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  // ─── 2. MERKEZ ÜSSÜ: 6 KÖŞELİ SOMUN (HEXAGON) AVATAR ───
  Widget _buildSomunAvatar() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Dış Çerçeve (Parlayan Altın/Turkuaz Neon)
            ClipPath(
              clipper: _HexagonClipper(),
              child: Container(
                width: 130, height: 130,
                color: SiberTema.kuantumCyan.withOpacity(0.8),
              ),
            ),
            // İç Kısım (Resim veya İkon)
            ClipPath(
              clipper: _HexagonClipper(),
              child: Container(
                width: 124, height: 124,
                color: Colors.black,
                child: _kayitliProfilFoto != null && _beniHatirla
                    ? Image.network(_kayitliProfilFoto!, fit: BoxFit.cover)
                    : const Center(
                        child: Icon(Icons.precision_manufacturing_outlined, color: Colors.white, size: 60),
                      ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text("OtoDNA Kuantum Ağı", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
        const SizedBox(height: 4),
        Text(_kayitliProfilFoto != null && _beniHatirla ? "Siber Komutan" : "Giriş Bekleniyor...", style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
      ],
    );
  }

  // ─── 3. GİRİŞ FORMU (TİTANYUM CAM HİSSİ) ───
  Widget _buildGirisFormu() {
    return Column(
      children: [
        _buildSiberTextField(controller: _emailController, icon: Icons.phone_android, hint: "Telefon Numarası veya E-Posta"),
        const SizedBox(height: 16),
        _buildSiberTextField(
          controller: _sifreController, icon: Icons.lock_outline, hint: "Siber Şifre",
          isPassword: true, sifreGizli: _sifreGizli,
          onVisibilityToggle: () => setState(() => _sifreGizli = !_sifreGizli),
        ),
      ],
    );
  }

  Widget _buildSiberTextField({required TextEditingController controller, required IconData icon, required String hint, bool isPassword = false, bool sifreGizli = false, VoidCallback? onVisibilityToggle}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), border: Border.all(color: Colors.white24, width: 1), borderRadius: BorderRadius.circular(16)),
          child: TextField(
            controller: controller,
            obscureText: isPassword && sifreGizli,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: SiberTema.kuantumCyan, size: 22),
              suffixIcon: isPassword ? IconButton(icon: Icon(sifreGizli ? Icons.visibility_off : Icons.visibility, color: Colors.white54, size: 20), onPressed: onVisibilityToggle) : null,
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 13, fontFamily: 'Avenir'),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            ),
          ),
        ),
      ),
    );
  }

  // ─── 4. ALTIN ÜÇLÜ AKSİYON (Beni Hatırla - QR - Şifremi Unuttum) ───
  Widget _buildAltinUcluAksiyon() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Sol: Beni Hatırla
        GestureDetector(
          onTap: () => setState(() => _beniHatirla = !_beniHatirla),
          child: Row(
            children: [
              Icon(_beniHatirla ? Icons.check_box : Icons.check_box_outline_blank, color: _beniHatirla ? SiberTema.kuantumCyan : Colors.white54, size: 20),
              const SizedBox(width: 8),
              const Text("Beni Hatırla", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
            ],
          ),
        ),
        // Orta: Kuantum QR Okuyucu
        GestureDetector(
          onTap: () => _uyariGoster("QR Tarayıcı Başlatılıyor..."),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: SiberTema.kuantumCyan, width: 2), boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.3), blurRadius: 10)]),
            child: const Icon(Icons.qr_code_scanner, color: SiberTema.kuantumCyan, size: 28),
          ),
        ),
        // Sağ: Şifremi Unuttum
        GestureDetector(
          onTap: () => _uyariGoster("Şifre Sıfırlama İstemi Gönderildi"),
          child: const Text("Şifremi Unuttum", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir', decoration: TextDecoration.underline)),
        ),
      ],
    );
  }

  // ─── 5. GİRİŞ YAP BUTONU ───
  Widget _buildAteslemeButonu() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: SiberTema.kuantumCyan,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 10,
          shadowColor: SiberTema.kuantumCyan.withOpacity(0.5),
        ),
        onPressed: _isProcessing ? null : _kapiyiZorla,
        child: _isProcessing
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
            : const Text("SİSTEME GİRİŞ YAP", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
      ),
    );
  }
}

// ─── CUSTOM CLIPPER (6 KÖŞELİ SOMUN / HEXAGON) ───
class _HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.5, 0); // Üst orta
    path.lineTo(size.width, size.height * 0.25); // Sağ üst köşe
    path.lineTo(size.width, size.height * 0.75); // Sağ alt köşe
    path.lineTo(size.width * 0.5, size.height); // Alt orta
    path.lineTo(0, size.height * 0.75); // Sol alt köşe
    path.lineTo(0, size.height * 0.25); // Sol üst köşe
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}