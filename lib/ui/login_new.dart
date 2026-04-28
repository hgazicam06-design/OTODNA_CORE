import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 🚀 KARARGAH LOGLAMASI İÇİN EKLENDİ
import 'dart:developer' as developer;

/// 🛡️ KUANTUM ANA GİRİŞ KAPISI (SiberLoginTerminali)
/// OtoDNA sistemine giriş yapmak için Firebase Auth kullanan, OLED Siyah tasarımlı Kuantum Terminali.
class LoginNew extends StatefulWidget {
  LoginNew({super.key});

  @override
  State<LoginNew> createState() => _LoginNewState();
}

class _LoginNewState extends State<LoginNew> {
  // ── SİBER İSTİHBARAT KONTROLCÜLERİ ──
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _masterKeyController = TextEditingController();

  bool _sistemMesgulMu = false;

  // ── 🔐 SİBER DOĞRULAMA VE İZ SÜRME MOTORU ───────────────────────────────
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
      UserCredential cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: gaziId,
        password: masterKey,
      );

      // 🚨 KARARGAH KURALI: GİRİŞ İŞLEMİNİ KARA KUTUYA MÜHÜRLE! (Kayıt Dışılık Engellendi)
      await FirebaseFirestore.instance.collection('sistem_loglari').add({
        'islem_turu': 'SİSTEM_GİRİŞİ',
        'islem_detayi': 'SİBER ONAY: $gaziId yetkilisi Ana Karargaha başarıyla giriş yaptı.',
        'kullanici_id': cred.user?.uid ?? 'BİLİNMİYOR',
        'tarih': FieldValue.serverTimestamp(),
      });

      developer.log("SİBER ONAY: ✅ Kimlik doğrulandı ve giriş Karargaha loglandı! Ana Karargaha geçiş yapılıyor.");

      // SİBER NOT: Giriş başarılı olunca kullanıcıyı Ana Gövdeye yönlendir
      // if (!mounted) return;
      // Navigator.pushReplacementNamed(context, '/ana_karargah');

    } on FirebaseAuthException catch (e) {
      developer.log("AĞ REDDEDİLDİ: Giriş başarısız!", error: e);
      _siberUyariVer("ERİŞİM REDDEDİLDİ", "KİMLİK (DNA) VEYA ŞİFRE UYUMSUZ!");

      // 🚨 KARARGAH KURALI: SALDIRI DENEMESİNİ KARA KUTUYA YAZ! (İz Sürme Aktif)
      try {
        await FirebaseFirestore.instance.collection('sistem_loglari').add({
          'islem_turu': 'YETKİSİZ_GİRİŞ_DENEMESİ',
          'islem_detayi': 'SİBER İHLAL GİRİŞİMİ: $gaziId kimliği ile Karargaha yetkisiz sızma denendi! (Hata: ${e.code})',
          'tarih': FieldValue.serverTimestamp(),
        });
      } catch (logError) {
        developer.log("SİBER HATA: İhlal loglanamadı!", error: logError);
      }

    } finally {
      if (mounted) setState(() => _sistemMesgulMu = false);
    }
  }

  // ── 🚨 HATA SİNYALİ (SNACKBAR) ──────────────────────────────────────────
  void _siberUyariVer(String baslik, String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent, // Kan Kırmızı İhlal Rengi
        content: Text(
          "$baslik: $mesaj",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
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
      backgroundColor: Color(0xFF000000), // 🌑 TAM OLED SİYAHI (Karargah Kuralı)
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 🇹🇷 YERLİ VE MİLLİ İBARESİ
              SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.flag_outlined, color: Colors.redAccent, size: 22),
                  SizedBox(width: 10),
                  Text(
                    "YERLİ VE MİLLİ PROTOKOL",
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                ],
              ),

              Spacer(flex: 2),

              // 2. 🛡️ DEVRE KARTLI MERKEZ LOGO
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      "assets/images/otodna_logo_yeni.png",
                      width: MediaQuery.of(context).size.width * 0.55,
                      errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.security, size: 100, color: Color(0xFF00FFC2)
                      ), // Logo yoksa siber kalkan göster
                    ),
                    SizedBox(height: 24),
                    Text(
                      "ARACIN DİJİTAL KİMLİĞİ",
                      style: TextStyle(
                        color: Color(0xFF00FFC2), // Kuantum Turkuazı
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              Spacer(flex: 3),

              // 3. ⌨️ SİBER GİRİŞ TERMİNALLERİ (TEXTFIELDS)
              _buildSiberInput(
                controller: _idController,
                hintText: "GAZİ ID / E-POSTA",
                icon: Icons.badge_outlined,
              ),
              SizedBox(height: 20),
              _buildSiberInput(
                controller: _masterKeyController,
                hintText: "MASTER KEY (ŞİFRE)",
                icon: Icons.vpn_key_outlined,
                isPassword: true,
              ),

              SizedBox(height: 40),

              // 4. 🚀 ATEŞLEME BUTONU (SİBER CAM EFEKTİ VE NEON)
              SizedBox(
                width: double.infinity,
                height: 60,
                child: _sistemMesgulMu
                    ? Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF00FFC2),
                    strokeWidth: 3,
                  ),
                )
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00FFC2), // Kuantum Turkuazı
                    foregroundColor: Colors.black, // Yazı rengi
                    elevation: 10,
                    shadowColor: Color(0xFF00FFC2).withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _kuantumKapilariniAc,
                  child: Text(
                    "SİSTEME GİRİŞ YAP",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              Spacer(flex: 2),
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
        color: Color(0xFF111111), // Mat Koyu Gri (Glassmorphism hissiyatı)
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFF00FFC2).withValues(alpha: 0.3), width: 1.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 1.2),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Color(0xFF00FFC2), size: 22),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white30, letterSpacing: 2, fontSize: 12),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}
