import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM ANA GİRİŞ KAPISI (LoginScreen)
/// OtoDNA sistemine giriş yapmak için Firebase Auth kullanan, OLED Siyah tasarımlı Kuantum Terminali.
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ── SİBER İSTİHBARAT KONTROLCÜLERİ ──
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _masterKeyController = TextEditingController();

  bool _sistemMesgulMu = false;

  // ── 🔐 SİBER DOĞRULAMA MOTORU (FIREBASE AUTH) ───────────────────────────
  Future<void> _kuantumKapilariniAc() async {
    final String gaziId = _idController.text.trim();
    final String masterKey = _masterKeyController.text.trim();

    // 1. Zırh Kontrolü: Boş veriyle Karargaha girilemez!
    if (gaziId.isEmpty || masterKey.isEmpty) {
      _siberUyariVer("SİBER İHLAL", "GAZİ ID VEYA MASTER KEY BOŞ BIRAKILAMAZ!");
      return;
    }

    setState(() => _sistemMesgulMu = true);
    developer.log("SİBER BİLGİ: 🚀 Amiral gemisi kalkış protokolü (Firebase Auth) başlatıldı...");

    try {
      // 2. Kuantum Ağına (Firebase) Bağlantı
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: gaziId,
        password: masterKey,
      );

      developer.log("SİBER ONAY: ✅ Kimlik doğrulandı! Ana Karargaha geçiş yapılıyor.");

      // SİBER NOT: Giriş başarılı olunca kullanıcıyı Ana Gövdeye yönlendir
      // if (!mounted) return;
      // Navigator.pushReplacementNamed(context, '/siber_ana_govde');

    } on FirebaseAuthException catch (e) {
      developer.log("AĞ REDDEDİLDİ: Giriş başarısız!", error: e);
      _siberUyariVer("ERİŞİM REDDEDİLDİ", "KİMLİK (DNA) VEYA ŞİFRE UYUMSUZ!");
    } finally {
      if (mounted) setState(() => _sistemMesgulMu = false);
    }
  }

  // ── 🚨 HATA SİNYALİ (SNACKBAR) ──────────────────────────────────────────
  void _siberUyariVer(String baslik, String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(
          "$baslik: $mesaj",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _masterKeyController.dispose();
    super.dispose();
  }

  // ── 🎨 KUANTUM ARAYÜZ (UI) İNŞASI ───────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // 🌑 TAM OLED SİYAHI
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // 1. 🇹🇷 YERLİ VE MİLLİ İBARESİ
              const Text(
                "🇹🇷 YERLİ VE MİLLİ 🇹🇷",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                  color: Color(0xFF00FFC2), // Kuantum Turkuazı
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),

              // 2. 🛡️ DEVRE KARTLI MERKEZ LOGO
              Image.asset(
                "assets/images/otodna_logo.png",
                width: MediaQuery.of(context).size.width * 0.55,
                errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.security, size: 100, color: Color(0xFF00FFC2)
                ),
              ),
              const SizedBox(height: 16),

              // GÜNCELLENEN BÖLÜM BURASI
              const Text(
                "ARACIN DİJİTAL KİMLİĞİ",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 50),

              // 3. ⌨️ SİBER GİRİŞ TERMİNALLERİ (TEXTFIELDS)
              _buildSiberInput(
                controller: _idController,
                hintText: "GAZİ ID / KULLANICI ADI",
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 20),
              _buildSiberInput(
                controller: _masterKeyController,
                hintText: "MASTER KEY (ŞİFRE)",
                icon: Icons.vpn_key_outlined,
                isPassword: true,
              ),

              const SizedBox(height: 30),

              // 4. 🛡️ GÜVENLİK İBARESİ
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.gpp_good_outlined, color: Colors.redAccent, size: 24),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "VERİLERİNİZ %100 YERLİ ALTYAPI İLE ANKARA MERKEZ SUNUCULARINDA KORUNMAKTADIR. GÜVENDESİNİZ.",
                        style: TextStyle(fontSize: 10, color: Colors.white60, letterSpacing: 1, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // 5. 🚀 ATEŞLEME BUTONU (SİBER CAM EFEKTİ VE NEON)
              SizedBox(
                width: double.infinity,
                height: 60,
                child: _sistemMesgulMu
                    ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF00FFC2),
                    strokeWidth: 3,
                  ),
                )
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FFC2), // Kuantum Turkuazı
                    foregroundColor: Colors.black, // Yazı rengi
                    elevation: 10,
                    shadowColor: const Color(0xFF00FFC2).withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _kuantumKapilariniAc,
                  child: const Text(
                    "SİSTEME GİRİŞ YAP",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── 🔧 YARDIMCI WIDGET: SİBER INPUT ALANI ──────────────────────────────
  Widget _buildSiberInput({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111), // Mat Koyu Gri
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF00FFC2).withOpacity(0.3), width: 1.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 1.2),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF00FFC2), size: 22),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white30, letterSpacing: 2, fontSize: 12),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}