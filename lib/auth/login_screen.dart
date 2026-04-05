import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🔥 SİBER KÖPRÜ (Göreceli Rota - Klasör kopmalarını engeller)
import '../screens/scanner/qr_scanner_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // --- Kuantum Kontrolcüler ---
  final _identifierController = TextEditingController(); // SADECE: Kullanıcı Adı veya E-Posta
  final _passwordController = TextEditingController();

  // --- Siber Şalterler ---
  bool _rememberMe = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 🚀 AKILLI GİRİŞ MOTORU (Kullanıcı Adı / E-Posta)
  Future<void> _smartLogin() async {
    String rawIdentifier = _identifierController.text.trim();
    String password = _passwordController.text.trim();

    if (rawIdentifier.isEmpty || password.isEmpty) {
      return _showError('Kimlik ve Şifre alanı boş bırakılamaz!');
    }

    setState(() => _isLoading = true);

    try {
      String targetEmail = rawIdentifier;

      // 1. E-POSTA DEĞİLSE (Kullanıcı Adı Kuantum Analizi)
      if (!rawIdentifier.contains('@')) {
        // Firebase'de 'kullanici_adi' alanında arama yapıyoruz
        QuerySnapshot userQuery = await FirebaseFirestore.instance
            .collection('kullanicilar')
            .where('kullanici_adi', isEqualTo: rawIdentifier)
            .limit(1)
            .get();

        if (userQuery.docs.isEmpty) {
          setState(() => _isLoading = false);
          return _showError('Sistemde böyle bir Kullanıcı Adı bulunamadı.');
        }

        // Bulunan profilin E-postasını al
        targetEmail = userQuery.docs.first['email'];
      }

      // 2. FİREBASE KİMLİK DOĞRULAMA (Ateşleme)
      UserCredential userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: targetEmail,
        password: password,
      );

      // 3. ROL SORGULAMA VE İÇERİ ALMA (VIP/SaaS Yönlendirmesi)
      await _rolSorgulaVeGirisYap(userCred);

    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      _showError('Giriş Başarısız: Şifre hatalı veya hesap yasaklı!');
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Siber Ağ Hatası: Bağlantınızı kontrol edin.');
    }
  }

  // --- 🧠 ROL SORGULAMA VE YÖNLENDİRME ---
  Future<void> _rolSorgulaVeGirisYap(UserCredential userCred) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('kullanicilar').doc(userCred.user!.uid).get();

    String hosgeldinMesaji = 'Kuantum Ağına Hoş Geldiniz! 🚀';

    if (userDoc.exists) {
      var data = userDoc.data() as Map<String, dynamic>;

      // Blacklist (Karaliste) Kontrolü
      if (data['is_blacklisted'] == true) {
        await FirebaseAuth.instance.signOut();
        setState(() => _isLoading = false);
        return _showError('ERİŞİM REDDEDİLDİ: Hesabınız karalisteye alınmış!');
      }

      // Bayi / VIP Firma Yönlendirmesi (Abonelik ve Limit Motorları Devreye Girer)
      if (data['rol'] == 'bayi') {
        hosgeldinMesaji = 'Yetkili Bayi Doğrulandı! VIP Paneline Yönlendiriliyorsunuz... 🏢';
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(hosgeldinMesaji, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: const Color(0xFF00FFC2)));

    // İşlem başarılı, Ana Karargaha geç
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent));
  }

  // QR Siber Göz
  void _openQRScanner() async {
    final scannedCode = await Navigator.push(context, MaterialPageRoute(builder: (context) => const QrScannerScreen()));
    if (scannedCode != null && mounted) {
      _identifierController.text = scannedCode;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🌑 TESLA MİMARİSİ: TAM OLED SİYAH
    const bgColor = Color(0xFF000000);
    const primaryCyan = Color(0xFF00FFC2);
    const textSecondary = Colors.white70;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // =========================================================
              // 🛡️ GAZİ PROTOKOLÜ: SİBER KALKAN VE LOGO
              // =========================================================
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryCyan, width: 4),
                    boxShadow: [
                      BoxShadow(color: primaryCyan.withOpacity(0.4), blurRadius: 40, spreadRadius: 5),
                      BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                    gradient: RadialGradient(colors: [primaryCyan.withOpacity(0.15), bgColor], radius: 0.8),
                  ),
                  child: SizedBox(
                    width: 100, height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.directions_car, color: Colors.white.withOpacity(0.15), size: 70),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: bgColor.withOpacity(0.9), shape: BoxShape.circle, boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.5), blurRadius: 15, spreadRadius: -5)]),
                          child: const Icon(Icons.fingerprint, color: primaryCyan, size: 50),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Column(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(colors: [Colors.white, Color(0xFF00FFC2)], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(bounds),
                    child: const Text('OtoDNA', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2.0)),
                  ),
                  const SizedBox(height: 4),
                  const Text('DİJİTAL REFERANS PROTOKOLÜ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primaryCyan, letterSpacing: 2.0)),
                ],
              ),
              const SizedBox(height: 40),

              // --- KULLANICI ADI VEYA E-POSTA ---
              _buildTextField(
                  controller: _identifierController,
                  hintText: 'Kullanıcı Adı veya E-Posta',
                  icon: Icons.person_outline,
                  primaryColor: primaryCyan
              ),
              const SizedBox(height: 16),

              _buildTextField(
                  controller: _passwordController,
                  hintText: 'Siber Şifreniz',
                  icon: Icons.lock_outline,
                  primaryColor: primaryCyan,
                  isPassword: true,
                  obscureText: _obscurePassword,
                  onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword)
              ),
              const SizedBox(height: 20),

              // --- 🎯 MERKEZLENMİŞ QR VE ALT MENÜ ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // SOL: Beni Hatırla
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                              width: 24, height: 24,
                              child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (val) => setState(() => _rememberMe = val ?? true),
                                  activeColor: primaryCyan,
                                  checkColor: bgColor,
                                  side: const BorderSide(color: primaryCyan, width: 1.5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))
                              )
                          ),
                          const SizedBox(width: 8),
                          const Text('Beni Hatırla', style: TextStyle(color: textSecondary, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),

                  // ORTA: Büyütülmüş QR Siber Göz
                  GestureDetector(
                    onTap: _openQRScanner,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: primaryCyan.withOpacity(0.6), width: 1.5),
                          boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.2), blurRadius: 10, spreadRadius: 1)]
                      ),
                      child: const Icon(Icons.qr_code_scanner, color: primaryCyan, size: 28),
                    ),
                  ),

                  // SAĞ: Şifremi Unuttum
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/sifre_sifirlama');
                          },
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                          child: const Text('Şifremi Unuttum', style: TextStyle(color: primaryCyan, fontSize: 13, fontWeight: FontWeight.bold))
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // --- GİRİŞ YAP BUTONU ---
              Container(
                height: 52,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(colors: [Color(0xFF00FFC2), Color(0xFF00B8D4)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                  boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _smartLogin,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), disabledBackgroundColor: Colors.transparent),
                  child: _isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Color(0xFF000000), strokeWidth: 3))
                      : const Text('SİSTEME GİRİŞ YAP', style: TextStyle(color: Color(0xFF000000), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
              ),

              const SizedBox(height: 32),

              // --- KAYIT OL BUTONU (EN ALT KISIM) ---
              SizedBox(
                height: 52,
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/kayit_ol'),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text('HESABIN YOK MU? KAYIT OL', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- ARINDIRILMIŞ ŞABLON ---
  Widget _buildTextField({required TextEditingController controller, required String hintText, required IconData icon, required Color primaryColor, bool isPassword = false, bool obscureText = false, VoidCallback? onTogglePassword}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 1.0),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 14, letterSpacing: 0),
        prefixIcon: Icon(icon, color: Colors.white54, size: 22),
        suffixIcon: isPassword ? IconButton(icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: primaryColor, size: 22), onPressed: onTogglePassword) : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.04),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white12, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: primaryColor, width: 2)),
      ),
    );
  }
}