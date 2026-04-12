import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🔥 SİBER KÖPRÜLER VE TEMA (Zırh v2.0)
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

class SiberSmsScreen extends StatefulWidget {
  const SiberSmsScreen({super.key});

  @override
  State<SiberSmsScreen> createState() => _SiberSmsScreenState();
}

class _SiberSmsScreenState extends State<SiberSmsScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _codeSent = false;
  bool _isLoading = false;
  String _verificationId = "";

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // 🔥 FİREBASE SMS GÖNDERME MOTORU
  Future<void> _telefonuDogrulaBaslat() async {
    final String phoneNumber = _phoneController.text.trim();

    // Telefon numarasının +90 ile başlamasını zorunlu kılıyoruz (Türkiye standartı)
    if (phoneNumber.isEmpty || !phoneNumber.startsWith('+90') || phoneNumber.length < 13) {
      _siberUyariVer("HATA: Numarayı +905XXXXXXXXX formatında giriniz.", isError: true);
      return;
    }

    setState(() { _isLoading = true; });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),

        // 1. Durum: Android'de bazen kod sormadan otomatik doğrular
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _kullaniciHesabinaTelefonuBagla(credential);
        },

        // 2. Durum: Siber Güvenlik İhlali veya Limit Aşımı
        verificationFailed: (FirebaseAuthException e) {
          setState(() { _isLoading = false; });
          _siberUyariVer("SİBER İHLAL: ${e.message}", isError: true);
        },

        // 3. Durum: Kod Başarıyla Gönderildi (Siber Terminal Kod Ekranına Geçer)
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _codeSent = true;
            _isLoading = false;
          });
          _siberUyariVer("PROTOKOL AKTİF: Siber Doğrulama Kodu Gönderildi.", isError: false);
        },

        // 4. Durum: Kodun Süresi Doldu
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      setState(() { _isLoading = false; });
      _siberUyariVer("SİSTEM HATASI: SMS motoru tetiklenemedi.", isError: true);
    }
  }

  // 🔥 GİRİLEN KODU (OTP) FİREBASE'DE ONAYLAMA MOTORU
  Future<void> _koduDogrula() async {
    final String smsCode = _otpController.text.trim();
    if (smsCode.length < 6) {
      _siberUyariVer("EKSİK VERİ: Lütfen 6 haneli Kuantum Şifresini girin.", isError: true);
      return;
    }

    setState(() { _isLoading = true; });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: smsCode,
      );

      await _kullaniciHesabinaTelefonuBagla(credential);

    } on FirebaseAuthException catch (e) {
      setState(() { _isLoading = false; });
      _siberUyariVer("DOĞRULAMA REDDEDİLDİ: Hatalı veya süresi dolmuş Kuantum Şifresi.", isError: true);
    }
  }

  // 🔥 TELEFON NUMARASINI MEVCUT HESABA BAĞLAMA VE YÖNLENDİRME
  Future<void> _kullaniciHesabinaTelefonuBagla(PhoneAuthCredential credential) async {
    try {
      // Giriş yap
      UserCredential userCred = await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCred.user != null) {
        _siberUyariVer("DOĞRULAMA TAMAMLANDI! Karargaha Geçiliyor...", isError: false);
        if (mounted) {
          Navigator.pop(context); // SMS ekranından çık, Ana kapı (AuthGate) devralsın.
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() { _isLoading = false; });
      _siberUyariVer("BAĞLANTI HATASI: ${e.message}", isError: true);
    } catch (e) {
      setState(() { _isLoading = false; });
      _siberUyariVer("SİSTEM HATASI: Beklenmeyen anomali.", isError: true);
    }
  }

  // Uyarı Sistemi
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
            fontFamily: 'Avenir', // 🛠️ DÜZELTİLDİ: Özel font adı yerine standart Avenir
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
        backgroundColor: Colors.transparent, // Zırh arka planı
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
                // 🛡️ ŞIK İKON (3D Derinlik Eklendi)
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: SiberTema.matGrey,
                    border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3), width: 1.5),
                    boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.2), blurRadius: 20, spreadRadius: 2)], // 🛠️ DÜZELTİLDİ: Manuel 3D Gölge
                  ),
                  child: Icon(
                    _codeSent ? Icons.mark_email_read_rounded : Icons.phonelink_ring_rounded,
                    color: SiberTema.kuantumCyan,
                    size: 40,
                    shadows: const [Shadow(color: SiberTema.kuantumCyan, blurRadius: 10)], // İkon parlaması
                  ),
                ),
                const SizedBox(height: 30),

                Text(
                  _codeSent ? "KUANTUM ŞİFRESİ" : "SİBER DOĞRULAMA",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    fontFamily: 'Avenir', // 🛠️ DÜZELTİLDİ
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _codeSent
                      ? "Telefonunuza gönderilen 6 haneli siber güvenlik kodunu girin."
                      : "Sisteme giriş için telefon numaranızı +90 formatında doğrulayın.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                    height: 1.5,
                    fontFamily: 'Avenir', // 🛠️ DÜZELTİLDİ
                  ),
                ),
                const SizedBox(height: 40),

                // 🔥 3D SİBER FORM ALANI
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: SiberTema.matGrey.withOpacity(0.5),
                    border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 10))], // 🛠️ DÜZELTİLDİ: Katmanlı Derinlik
                  ),
                  child: Column(
                    children: [
                      if (!_codeSent) ...[
                        _buildPremiumInput(
                          controller: _phoneController,
                          icon: Icons.phone_android,
                          hint: "+90 5XX XXX XX XX",
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan, strokeWidth: 3))
                              : ElevatedButton(
                            onPressed: _telefonuDogrulaBaslat,
                            style: SiberTema.kuantumButonStili(), // 🔥 3D Buton
                            child: const Text(
                              "KOD GÖNDER",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir', color: SiberTema.oledBlack), // 🛠️ DÜZELTİLDİ
                            ),
                          ),
                        ),
                      ] else ...[
                        _buildPremiumInput(
                          controller: _otpController,
                          icon: Icons.password,
                          hint: "6 Haneli Şifre",
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan, strokeWidth: 3))
                              : ElevatedButton(
                            onPressed: _koduDogrula,
                            style: SiberTema.kuantumButonStili(), // 🔥 3D Buton
                            child: const Text(
                              "DOĞRULA VE BAĞLAN",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir', color: SiberTema.oledBlack), // 🛠️ DÜZELTİLDİ
                            ),
                          ),
                        ),
                      ],
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
    required TextInputType keyboardType,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Avenir', letterSpacing: 1.5, fontWeight: FontWeight.bold), // 🛠️ DÜZELTİLDİ
      decoration: InputDecoration(
        counterText: "", // maxLength yazısını gizler
        prefixIcon: Icon(icon, color: Colors.white54, size: 22),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30, fontSize: 14, fontFamily: 'Avenir', letterSpacing: 1), // 🛠️ DÜZELTİLDİ
        filled: true,
        fillColor: SiberTema.oledBlack, // Derin Siyah
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
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