import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🔥 SİBER KÖPRÜLER
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';
import '../core/siber_lokasyon_motoru.dart'; // ✅ YENİ EKLENDİ (Otonom İl/İlçe/Bölge Seçici)

class KayitOlScreen extends StatefulWidget {
  const KayitOlScreen({super.key});

  @override
  State<KayitOlScreen> createState() => _KayitOlScreenState();
}

class _KayitOlScreenState extends State<KayitOlScreen> with SingleTickerProviderStateMixin {
  int _asama = 0; // 0: Temel Bilgiler, 1: SMS Doğrulama, 2: Profil Tamamlama
  late TabController _tabController;
  bool _sifreGizli = true;
  bool _garantiSozlesmesiOnay = false;
  bool _isLoading = false;
  String _verificationId = ""; // Firebase SMS Kodu ID'si

  // 🚀 FİREBASE MOTORLARI
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🧠 SİBER VERİ YAKALAYICILAR
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _sifreCtrl = TextEditingController();
  final TextEditingController _telKayitCtrl = TextEditingController();
  final TextEditingController _otpCtrl = TextEditingController();

  final TextEditingController _adSoyadCtrl = TextEditingController();
  final TextEditingController _yasCtrl = TextEditingController();
  final TextEditingController _plakaCtrl = TextEditingController();

  final TextEditingController _firmaAdiCtrl = TextEditingController();
  final TextEditingController _vergiNoCtrl = TextEditingController();

  // 🌍 OTONOM LOKASYON DEĞİŞKENLERİ
  String _seciliSehir = "";
  String _seciliBolge = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailCtrl.dispose(); _sifreCtrl.dispose(); _telKayitCtrl.dispose(); _otpCtrl.dispose();
    _adSoyadCtrl.dispose(); _yasCtrl.dispose(); _plakaCtrl.dispose();
    _firmaAdiCtrl.dispose(); _vergiNoCtrl.dispose();
    super.dispose();
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: TextStyle(color: isError ? Colors.white : SiberTema.oledBlack, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
      backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
    ));
  }

  // ========================================================================
  // 🚀 AŞAMA 1: VERİTABANI KONTROLÜ VE SMS GÖNDERME MOTORU
  // ========================================================================
  Future<void> _hizliKayitVeSmsGonder() async {
    String email = _emailCtrl.text.trim();
    String sifre = _sifreCtrl.text.trim();
    String telefon = _telKayitCtrl.text.trim();

    if (email.isEmpty || !email.contains('@') || sifre.length < 6 || telefon.length < 10) {
      return _showSnackBar("E-Posta, Şifre (Min 6) ve Telefon (Örn: 555...) eksiksiz olmalı!", isError: true);
    }

    setState(() => _isLoading = true);

    try {
      var emailCheck = await _db.collection('kullanicilar').where('email', isEqualTo: email).get();
      var phoneCheck = await _db.collection('kullanicilar').where('telefon', isEqualTo: telefon).get();

      if (emailCheck.docs.isNotEmpty || phoneCheck.docs.isNotEmpty) {
        setState(() => _isLoading = false);
        return _showSnackBar("Bu E-posta veya Telefon numarası Kuantum Ağında zaten kayıtlı!", isError: true);
      }

      String formatliTelefon = telefon.startsWith('0') ? '+90${telefon.substring(1)}' : '+90$telefon';

      await _auth.verifyPhoneNumber(
        phoneNumber: formatliTelefon,
        verificationCompleted: (PhoneAuthCredential credential) async {
          _otpCtrl.text = credential.smsCode ?? '';
          await _auth.signInWithCredential(credential);
          _showSnackBar("Siber Radar SMS'i Otomatik Yakaladı! 🚀");
          setState(() { _asama = 2; _isLoading = false; });
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _isLoading = false);
          _showSnackBar("Güvenlik Duvarı: SMS Gönderilemedi! (${e.code})", isError: true);
        },
        codeSent: (String verId, int? resendToken) {
          _verificationId = verId;
          setState(() { _asama = 1; _isLoading = false; });
          _showSnackBar("Kuantum SMS Kodu Gönderildi! 📩");
        },
        codeAutoRetrievalTimeout: (String verId) {
          _verificationId = verId;
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("Siber Ağ Hatası oluştu.", isError: true);
    }
  }

  // ========================================================================
  // 🚀 AŞAMA 2: MANUEL KOD DOĞRULAMA
  // ========================================================================
  Future<void> _koduDogrula() async {
    if (_otpCtrl.text.length < 6) return _showSnackBar("Lütfen 6 haneli kodu eksiksiz girin!", isError: true);

    setState(() => _isLoading = true);
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: _verificationId, smsCode: _otpCtrl.text.trim());
      await _auth.signInWithCredential(credential);
      _showSnackBar("Siber Kimlik Doğrulandı! ✅");
      setState(() { _asama = 2; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("Hatalı veya süresi dolmuş kod! 🚨", isError: true);
    }
  }

  // ========================================================================
  // 🚀 AŞAMA 3: FİREBASE'E MÜHÜRLEME İŞLEMİ (ATOMİK)
  // ========================================================================
  Future<void> _profilTamamla() async {
    if (_seciliSehir.isEmpty) {
      return _showSnackBar("Lütfen Lokasyon Radarı üzerinden şehrinizi seçin!", isError: true);
    }

    if (_tabController.index == 1 && !_garantiSozlesmesiOnay) {
      return _showSnackBar("Ulusal Çapraz Garanti Sözleşmesini onaylamanız zorunludur! 🛑", isError: true);
    }

    setState(() => _isLoading = true);

    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception("Oturum düştü!");

      await currentUser.updateEmail(_emailCtrl.text.trim());
      await currentUser.updatePassword(_sifreCtrl.text.trim());

      Map<String, dynamic> userData = {};
      WriteBatch batch = _db.batch();

      if (_tabController.index == 0) {
        userData = {
          'email': _emailCtrl.text.trim(),
          'telefon': _telKayitCtrl.text.trim(),
          'rol': 'bireysel',
          'ad_soyad': _adSoyadCtrl.text.trim(),
          'yas': _yasCtrl.text.trim(),
          'sehir': _seciliSehir,
          'bolge': _seciliBolge,
          'plaka': _plakaCtrl.text.trim().toUpperCase(),
          'kayit_tarihi': FieldValue.serverTimestamp(),
          'is_blacklisted': false,
        };
      } else {
        userData = {
          'email': _emailCtrl.text.trim(),
          'telefon': _telKayitCtrl.text.trim(),
          'rol': 'bayi',
          'ad': _firmaAdiCtrl.text.trim(),
          'vergi_no': _vergiNoCtrl.text.trim(),
          'sehir': _seciliSehir,
          'bolge': _seciliBolge,
          'onayli_mi': false,
          'aktif_mi': true,
          'is_vip': false,
          'rozet': 'Standart',
          'kullanilan_ilan_sayisi': 0,
          'komisyon_orani': 0.12,
          'kayit_tarihi': FieldValue.serverTimestamp(),
          'is_blacklisted': false,
        };

        DocumentReference bayiRef = _db.collection('bayiler').doc(currentUser.uid);
        batch.set(bayiRef, userData);
      }

      DocumentReference userRef = _db.collection('kullanicilar').doc(currentUser.uid);
      batch.set(userRef, userData);

      await batch.commit();

      _showSnackBar("OtoDNA Siber Kimliğiniz Başarıyla Mühürlendi! 🚀");

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pushReplacementNamed(context, '/home'); // Rota Kuantum ağında neresiyse
      });

    } catch (e) {
      _showSnackBar("Profil Mühürleme Hatası: $e", isError: true);
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent, elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: SiberTema.kuantumCyan), onPressed: () => _asama == 0 ? Navigator.pop(context) : setState(() => _asama--)),
          title: Text(_asama == 0 ? "1. Temel Kayıt" : _asama == 1 ? "2. Siber Doğrulama" : "3. Profil Tamamlama", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1, fontFamily: 'Avenir')),
          centerTitle: true,
        ),
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _asama == 0 ? _buildHizliKayit() : _asama == 1 ? _buildKodDogrulama() : _buildProfilTamamlama(),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // AŞAMA 1: TEMEL BİLGİLER
  // ==========================================
  Widget _buildHizliKayit() {
    return SingleChildScrollView(
      key: const ValueKey(0),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.fingerprint, color: SiberTema.kuantumCyan, size: 80),
          const SizedBox(height: 24),
          const Text("Siber Ağa Katıl", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
          const SizedBox(height: 8),
          const Text("Sisteme giriş bilgilerini ve doğrulama için telefon numaranı gir.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 14, fontFamily: 'Avenir')),
          const SizedBox(height: 40),
          _buildTextField(Icons.email_outlined, "E-Posta Adresiniz", SiberTema.kuantumCyan, _emailCtrl),
          const SizedBox(height: 16),
          _buildTextField(Icons.lock_outline, "Siber Şifre (En az 6 hane)", SiberTema.kuantumCyan, _sifreCtrl, isPassword: true),
          const SizedBox(height: 16),
          _buildTextField(Icons.phone_android, "Telefon Numarası (5XX...)", SiberTema.kuantumCyan, _telKayitCtrl, isNumber: true),
          const SizedBox(height: 32),
          _buildGirisButonu(SiberTema.kuantumCyan, _isLoading ? "SMS Gönderiliyor..." : "İleri: SMS Onayı", _isLoading ? () {} : _hizliKayitVeSmsGonder),
        ],
      ),
    );
  }

  // ==========================================
  // AŞAMA 2: SİBER KOD DOĞRULAMA (OTP)
  // ==========================================
  Widget _buildKodDogrulama() {
    return SingleChildScrollView(
      key: const ValueKey(1),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.mark_chat_read, color: SiberTema.altinSari, size: 80),
          const SizedBox(height: 24),
          const Text("Siber SMS Onayı", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
          const SizedBox(height: 8),
          Text("${_telKayitCtrl.text} numarasına gönderilen 6 haneli kodu girin.", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 14, fontFamily: 'Avenir')),
          const SizedBox(height: 40),
          TextField(
            controller: _otpCtrl,
            textAlign: TextAlign.center, keyboardType: TextInputType.number, maxLength: 6,
            style: const TextStyle(color: SiberTema.altinSari, fontSize: 24, letterSpacing: 12, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              counterText: "", hintText: "000000", hintStyle: TextStyle(color: SiberTema.altinSari.withOpacity(0.3)),
              filled: true, fillColor: SiberTema.matGrey,
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: SiberTema.altinSari, width: 2)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: SiberTema.altinSari, width: 3)),
            ),
          ),
          const SizedBox(height: 32),
          _buildGirisButonu(SiberTema.altinSari, _isLoading ? "Doğrulanıyor..." : "Kodu Onayla", _isLoading ? () {} : _koduDogrula),
        ],
      ),
    );
  }

  // ==========================================
  // AŞAMA 3: PROFİL TAMAMLAMA
  // ==========================================
  Widget _buildProfilTamamlama() {
    return Column(
      key: const ValueKey(2),
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
          child: TabBar(
            controller: _tabController, indicator: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.2), borderRadius: BorderRadius.circular(16), border: Border.all(color: SiberTema.kuantumCyan)), labelColor: SiberTema.kuantumCyan, unselectedLabelColor: Colors.white54,
            tabs: const [Tab(text: "Bireysel Sürücü"), Tab(text: "Yetkili Bayi")],
            onTap: (index) => setState(() {}),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController, physics: const BouncingScrollPhysics(),
            children: [
              // 👤 BİREYSEL EKRANI
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(Icons.person, "İsim Soyisim", SiberTema.kuantumCyan, _adSoyadCtrl), const SizedBox(height: 16),
                    _buildTextField(Icons.cake, "Yaş", SiberTema.kuantumCyan, _yasCtrl, isNumber: true), const SizedBox(height: 16),

                    // 🌍 SİBER LOKASYON MOTORU
                    SiberLokasyonMotoru(
                      onLokasyonSecildi: (ulke, sehir, bolge) {
                        setState(() { _seciliSehir = sehir; _seciliBolge = bolge; });
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(Icons.directions_car, "Plaka (Opsiyonel)", SiberTema.kuantumCyan, _plakaCtrl), const SizedBox(height: 32),
                    _buildGirisButonu(SiberTema.kuantumCyan, _isLoading ? "Mühürleniyor..." : "Siber Kimliği Tamamla", _isLoading ? () {} : _profilTamamla),
                  ],
                ),
              ),
              // 🏢 BAYİ EKRANI
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(Icons.storefront, "Firma / Servis Adı", Colors.purpleAccent, _firmaAdiCtrl), const SizedBox(height: 16),
                    _buildTextField(Icons.receipt_long, "Vergi No / Sicil Numarası", Colors.purpleAccent, _vergiNoCtrl), const SizedBox(height: 16),

                    // 🌍 SİBER LOKASYON MOTORU
                    SiberLokasyonMotoru(
                      onLokasyonSecildi: (ulke, sehir, bolge) {
                        setState(() { _seciliSehir = sehir; _seciliBolge = bolge; });
                      },
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.purpleAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.purpleAccent.withOpacity(0.5))),
                      child: Row(children: [Checkbox(value: _garantiSozlesmesiOnay, activeColor: Colors.purpleAccent, checkColor: Colors.white, side: const BorderSide(color: Colors.purpleAccent), onChanged: (val) { setState(() { _garantiSozlesmesiOnay = val ?? false; }); }), const Expanded(child: Text("OtoDNA Ulusal Çapraz Garanti Sözleşmesi'ni okudum, yasal yükümlülükleri kabul ediyorum.", style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.4, fontFamily: 'Avenir')))]),
                    ), const SizedBox(height: 32),
                    _buildGirisButonu(Colors.purpleAccent, _isLoading ? "Mühürleniyor..." : "Bayi Kaydını Tamamla", _isLoading ? () {} : _profilTamamla),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(IconData icon, String hint, Color color, TextEditingController ctrl, {bool isPassword = false, bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      obscureText: isPassword && _sifreGizli, keyboardType: isNumber ? TextInputType.number : TextInputType.text, style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Avenir'),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: color, size: 20),
        suffixIcon: isPassword ? IconButton(icon: Icon(_sifreGizli ? Icons.visibility_off : Icons.visibility, color: Colors.white38, size: 20), onPressed: () { setState(() { _sifreGizli = !_sifreGizli; }); }) : null,
        hintText: hint, hintStyle: const TextStyle(color: Colors.white38, fontSize: 13, fontFamily: 'Avenir'), filled: true, fillColor: SiberTema.matGrey, contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: color, width: 1.5)),
      ),
    );
  }

  Widget _buildGirisButonu(Color color, String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 10, shadowColor: color.withOpacity(0.5)),
        onPressed: onPressed,
        child: _isLoading && text.contains("...")
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: SiberTema.oledBlack, strokeWidth: 2))
            : Text(text, style: const TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5, fontFamily: 'Avenir')),
      ),
    );
  }
}