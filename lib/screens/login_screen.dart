// lib/screens/login_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

// 🚀 KARARGAH ZIRHLARI VE TEMA
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart'; // EKLENDİ: Web/Tablet Kalkanı

/// 🦅 OTODNA SİBER GİRİŞ KALKANI - V4 (MERKEZİ TEMA UYARLAMASI)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();

  bool _isProcessing = false;
  bool _sifreGizli = true;
  bool _isKullaniciGirisi = true; // Segmented Control (UI için)
  bool _isLoginMode = true; // TRUE: Giriş Yap, FALSE: Kayıt Ol

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _sifreController.dispose();
    super.dispose();
  }

  // 🚀 FİREBASE SİBER GİRİŞ VE KAYIT MOTORU (ATOMİK ZIRHLI)
  Future<void> _kapiyiZorla() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final sifre = _sifreController.text.trim();

    if (email.isEmpty || sifre.isEmpty || (!_isLoginMode && name.isEmpty)) {
      HapticFeedback.heavyImpact();
      _uyariGoster("SİBER İHLAL: LÜTFEN TÜM ALANLARI DOLDURUN!", isError: true);
      return;
    }

    if (!_isLoginMode && sifre.length < 6) {
      HapticFeedback.heavyImpact();
      _uyariGoster("GÜVENLİK İHLALİ: ŞİFRE EN AZ 6 KARAKTER OLMALI!", isError: true);
      return;
    }

    setState(() => _isProcessing = true);
    HapticFeedback.lightImpact();

    try {
      if (_isLoginMode) {
        // 🟢 GİRİŞ YAP PROTOKOLÜ
        await _auth.signInWithEmailAndPassword(email: email, password: sifre);

        // GİRİŞ LOGLAMASI (Kara Kutu)
        await _db.collection('sistem_loglari').add({
          'islem_turu': 'SİSTEM_GİRİŞİ',
          'islem_detayi': 'SİBER ONAY: $email yetkilisi Karargaha giriş yaptı.',
          'tarih': FieldValue.serverTimestamp(),
        });
      } else {
        // 🔵 YENİ KAYIT PROTOKOLÜ (ATOMİK ZIRHLI WRITEBATCH)
        UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: sifre);

        if (cred.user != null) {
          WriteBatch batch = _db.batch();

          DocumentReference userRef = _db.collection('kullanicilar').doc(cred.user!.uid);
          batch.set(userRef, {
            'uid': cred.user!.uid,
            'ad_soyad': name,
            'email': email,
            'rol': 'USER', // Varsayılan rütbe
            'kuantum_puan': 100,
            'kara_liste': false,
            'kayit_tarihi': FieldValue.serverTimestamp(),
          });

          DocumentReference logRef = _db.collection('sistem_loglari').doc();
          batch.set(logRef, {
            'islem_turu': 'YENI_ASKER_KAYDI',
            'islem_detayi': 'SİBER AĞ: $name ($email) Karargaha katıldı.',
            'tarih': FieldValue.serverTimestamp(),
          });

          await batch.commit();
          _uyariGoster("OTODNA AĞINA HOŞ GELDİNİZ! SİCİLİNİZ OLUŞTURULDU.");
        }
      }
    } on FirebaseAuthException catch (e) {
      HapticFeedback.heavyImpact();
      String hataMesaji = "AĞ ERİŞİMİ REDDEDİLDİ.";
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        hataMesaji = "GEÇERSİZ KİMLİK VEYA ŞİFRE!";
      } else if (e.code == 'email-already-in-use') {
        hataMesaji = "BU KİMLİK ZATEN KARARGAHTA KAYITLI!";
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
        content: Text(mesaj, style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5, color: SiberTema.oledBlack, fontSize: 11, fontFamily: 'Avenir')),
        backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _modDegistir() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _nameController.clear();
      _sifreController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🛡️ KALKAN DEVREYE ALINDI
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent, // Arka plan Kalkan'dan besleniyor
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
                          // --- KAYIT OL / GİRİŞ YAP GEÇİŞ BAĞLANTISI ---
                          _buildModeToggleLink(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // --- ALT KOMUTA MERKEZİ (Görsel Kabuk) ---
              _buildBottomNav(),
            ],
          ),
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
          const Icon(Icons.notifications_none, color: SiberTema.kuantumCyan, size: 28),
          const Column(
            children: [
              Text("OtoDNA", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
              Text("Siber Karargah", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 2, fontFamily: 'Avenir')),
            ],
          ),
          Icon(Icons.security, color: SiberTema.kuantumCyan.withOpacity(0.5), size: 28),
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
              if (_isLoginMode) _buildSegmentedControl(),
              if (_isLoginMode) const SizedBox(height: 32),

              Text(
                  _isLoginMode ? "HOŞ GELDİNİZ\nKOMUTAN GAZİ" : "AĞA KATIL\nYENİ YETKİLİ PROTOKOLÜ",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')
              ),
              const SizedBox(height: 32),

              if (!_isLoginMode) ...[
                _buildSiberTextField(controller: _nameController, icon: Icons.badge_outlined, hint: "AD SOYAD / FİRMA ADI"),
                const SizedBox(height: 16),
              ],

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
      decoration: BoxDecoration(color: SiberTema.oledBlack, borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white10)),
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
            color: isActive ? SiberTema.kuantumCyan : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          alignment: Alignment.center,
          child: Text(title, style: TextStyle(color: isActive ? SiberTema.oledBlack : Colors.white38, fontSize: 12, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
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
          foregroundColor: SiberTema.kuantumCyan,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: SiberTema.kuantumCyan, width: 2)),
          elevation: 0,
        ),
        onPressed: _isProcessing ? null : _kapiyiZorla,
        child: _isProcessing
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: SiberTema.kuantumCyan, strokeWidth: 2))
            : Text(_isLoginMode ? "AĞI AKTİFLEŞTİR" : "PROTOKOLÜ TAMAMLA", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
      ),
    );
  }

  Widget _buildModeToggleLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(_isLoginMode ? "Henüz kayıtlı değil misin? " : "Zaten yetkili misin? ", style: const TextStyle(color: Colors.white38, fontSize: 12, fontFamily: 'Avenir')),
        GestureDetector(
          onTap: _isProcessing ? null : _modDegistir,
          child: Text(_isLoginMode ? "YENİ KAYIT AÇ" : "GİRİŞ YAP", style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 12, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
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
              color: SiberTema.oledBlack,
              shape: BoxShape.circle,
              border: Border.all(color: SiberTema.kuantumCyan, width: 2),
              boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.2), blurRadius: 15)],
            ),
            child: const Icon(Icons.qr_code_scanner, color: SiberTema.kuantumCyan, size: 28),
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
        Text(label, style: const TextStyle(color: Colors.white24, fontSize: 8, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
      ],
    );
  }

  Widget _buildSiberTextField({required TextEditingController controller, required IconData icon, required String hint, bool isPassword = false, bool sifreGizli = false, VoidCallback? onVisibilityToggle}) {
    return Container(
      decoration: BoxDecoration(color: SiberTema.oledBlack, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
      child: TextField(
        controller: controller,
        obscureText: isPassword && sifreGizli,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: SiberTema.kuantumCyan.withOpacity(0.5), size: 20),
          suffixIcon: isPassword ? IconButton(icon: Icon(sifreGizli ? Icons.visibility_off : Icons.visibility, color: SiberTema.kuantumCyan, size: 20), onPressed: onVisibilityToggle) : null,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white12, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir'),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SiberTema.kuantumCyan, width: 1.5)),
        ),
      ),
    );
  }
}