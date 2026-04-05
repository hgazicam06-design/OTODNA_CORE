import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

        // 1. Durum: Android'de bazen kod sormadan otomatik doğrular (Harika bir durum)
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
      // Girilen kodu ve daha önce aldığımız ID'yi birleştirip Kuantum Anahtarı (Credential) oluşturuyoruz
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
        // 🔥 SİBER ZIRH: Eğer giriş başarılıysa, AuthGate bizi zaten rotamıza çekecektir.
        // Bu yüzden sadece bu ekranı kapatıyoruz.
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
        backgroundColor: isError ? Colors.redAccent.shade700 : const Color(0xFF00FFC2), // Kuantum Turkuazı
        content: Text(
          mesaj,
          style: TextStyle(
            color: isError ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 14,
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
    const Color neonCyan = Color(0xFF00FFC2); // Kuantum Turkuazı
    const Color bgKaranlik = Color(0xFF000000); // Tam OLED Siyah!

    return Scaffold(
      backgroundColor: bgKaranlik,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: neonCyan),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Şık İkon
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: neonCyan.withOpacity(0.05),
                  border: Border.all(color: neonCyan.withOpacity(0.3), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: neonCyan.withOpacity(0.15), blurRadius: 30, spreadRadius: 2),
                  ],
                ),
                child: Icon(
                    _codeSent ? Icons.mark_email_read_outlined : Icons.phonelink_ring_outlined,
                    color: neonCyan,
                    size: 40
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
                  fontFamily: 'Avenir',
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
                  fontFamily: 'Avenir',
                ),
              ),
              const SizedBox(height: 40),

              // Siber Form Alanı
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
                  borderRadius: BorderRadius.circular(24),
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
                            ? const Center(child: CircularProgressIndicator(color: neonCyan, strokeWidth: 3))
                            : ElevatedButton(
                          onPressed: _telefonuDogrulaBaslat,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: neonCyan,
                            foregroundColor: bgKaranlik,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text(
                            "KOD GÖNDER",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 2, fontFamily: 'Avenir'),
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
                            ? const Center(child: CircularProgressIndicator(color: neonCyan, strokeWidth: 3))
                            : ElevatedButton(
                          onPressed: _koduDogrula,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: neonCyan,
                            foregroundColor: bgKaranlik,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text(
                            "DOĞRULA VE BAĞLAN",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.5, fontFamily: 'Avenir'),
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
    );
  }

  Widget _buildPremiumInput({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    required TextInputType keyboardType,
    int? maxLength,
  }) {
    const Color neonCyan = Color(0xFF00FFC2);
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Avenir', letterSpacing: 1.5),
      decoration: InputDecoration(
        counterText: "", // maxLength yazısını gizler
        prefixIcon: Icon(icon, color: Colors.white54, size: 22),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30, fontSize: 14, fontFamily: 'Avenir', letterSpacing: 1),
        filled: true,
        fillColor: Colors.black.withOpacity(0.2),
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: neonCyan, width: 1.5),
        ),
      ),
    );
  }
}