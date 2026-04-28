import 'package:otodna/core/siber_tema.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import '../core/siber_tema.dart';

/// 🏢 PLAZA KALİTESİNDE GİRİŞ TERMİNALİ (Lüks ve Ferah)
class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

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
  final String _seciliDil = "TR";

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
      _uyariGoster("Lütfen E-Posta ve Şifrenizi giriniz.", isError: true);
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

  Future<void> _yeniKayit() async {
    final email = _emailController.text.trim();
    final sifre = _sifreController.text.trim();

    if (email.isEmpty || sifre.isEmpty) {
      HapticFeedback.heavyImpact();
      _uyariGoster("Kayıt olmak için E-Posta ve Şifre giriniz.", isError: true);
      return;
    }

    setState(() => _isProcessing = true);
    HapticFeedback.lightImpact();

    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: sifre);
      
      await _db.collection('kullanicilar').doc(cred.user!.uid).set({
        'email': email,
        'rol': 'USER',
        'kayit_tarihi': FieldValue.serverTimestamp(),
      });

      await _db.collection('sistem_loglari').add({
        'islem_turu': 'YENİ_KAYIT',
        'islem_detayi': 'YENİ ÜYE: $email sisteme katıldı.',
        'tarih': FieldValue.serverTimestamp(),
      });
      _uyariGoster("Kayıt Başarılı! Sisteme yönlendiriliyorsunuz.");
      
    } on FirebaseAuthException catch (e) {
      HapticFeedback.heavyImpact();
      String hataMesaji = "Kayıt Başarısız.";
      if (e.code == 'email-already-in-use') {
        hataMesaji = "Bu E-Posta adresi zaten kayıtlı!";
      } else if (e.code == 'weak-password') {
        hataMesaji = "Şifre çok zayıf! En az 6 karakter olmalı.";
      } else if (e.code == 'invalid-email') {
        hataMesaji = "Geçersiz E-Posta formatı!";
      }
      _uyariGoster(hataMesaji, isError: true);
    } catch (e) {
      _uyariGoster("Bağlantı Hatası: İnternetinizi kontrol edin.", isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _uyariGoster(String mesaj, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 13, fontFamily: 'Avenir')),
        backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Somun boyutları
    final double nutSize = 340.0;
    final double innerHoleSize = nutSize * 0.70; // Formun sığacağı delik boyutu

    return Scaffold(
      backgroundColor: Color(0xFFFAFAFC), // Sedefli Fil Dişi Arka Plan (Plaza / Banka Stili)
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ── ÜST BAR ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "OtoDNA",
                        style: TextStyle(
                          color: SiberTema.kuantumCyan,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                          fontFamily: 'Avenir',
                        ),
                      ),
                      Row(
                        children: [
                          Text(_seciliDil, style: TextStyle(color: SiberTema.textMuted, fontWeight: FontWeight.bold, fontSize: 13)),
                          SizedBox(width: 4),
                          Icon(Icons.language, color: SiberTema.textMuted, size: 16),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // ── ORTA SOMUN FORMU ──
                Center(
                  child: SizedBox(
                    width: nutSize,
                    height: nutSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Somun Çizimi
                        CustomPaint(
                          size: Size(nutSize, nutSize),
                          painter: _SomunPainter(),
                        ),
                        
                        // İç Boşluktaki Form
                        SizedBox(
                          width: innerHoleSize * 0.85, // Deliğin içine tam oturması için
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "GİRİŞ YAP",
                                style: TextStyle(
                                  color: SiberTema.textMain,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                  fontFamily: 'Avenir',
                                ),
                              ),
                              SizedBox(height: 16),
                              
                              // Kullanıcı Adı (Sade Bankacılık Stili)
                              _buildSadeTextField(
                                controller: _emailController,
                                icon: Icons.person_outline,
                                hint: "T.C. Kimlik / E-Posta",
                              ),
                              SizedBox(height: 12),
                              
                              // Şifre
                              _buildSadeTextField(
                                controller: _sifreController,
                                icon: Icons.lock_outline,
                                hint: "Şifre",
                                isPassword: true,
                                sifreGizli: _sifreGizli,
                                onVisibilityToggle: () => setState(() => _sifreGizli = !_sifreGizli),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // ── ALT AKSİYONLAR VE BUTONLAR ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _beniHatirla = !_beniHatirla),
                            child: Row(
                              children: [
                                Icon(_beniHatirla ? Icons.check_circle : Icons.radio_button_unchecked, color: _beniHatirla ? SiberTema.kuantumCyan : Colors.black26, size: 20),
                                SizedBox(width: 8),
                                Text("Beni Hatırla", style: TextStyle(color: SiberTema.textMain, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Avenir')),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _uyariGoster("Şifre sıfırlama bağlantısı yakında eklenecek."),
                            child: Text("Şifremi Unuttum", style: TextStyle(color: SiberTema.textMuted, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Avenir', decoration: TextDecoration.underline)),
                          ),
                        ],
                      ),
                      SizedBox(height: 32),
                      
                      // Geniş Giriş Butonu (Bankacılık Stili)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SiberTema.kuantumCyan, // Kurumsal Turkuaz/Mavi
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 4,
                            shadowColor: SiberTema.kuantumCyan.withOpacity(0.4),
                          ),
                          onPressed: _isProcessing ? null : _kapiyiZorla,
                          child: _isProcessing
                              ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text("GİRİŞ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2, fontFamily: 'Avenir')),
                        ),
                      ),
                      SizedBox(height: 24),
                      
                      TextButton(
                        onPressed: _isProcessing ? null : _yeniKayit,
                        child: RichText(
                          text: TextSpan(
                            text: "Hesabınız yok mu? ",
                            style: TextStyle(color: SiberTema.textMuted, fontSize: 14, fontFamily: 'Avenir'),
                            children: [
                              TextSpan(
                                text: "Kayıt Olun",
                                style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildSadeTextField({required TextEditingController controller, required IconData icon, required String hint, bool isPassword = false, bool sifreGizli = false, VoidCallback? onVisibilityToggle}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SiberTema.textMuted.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && sifreGizli,
        style: TextStyle(color: SiberTema.textMain, fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Avenir'),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: SiberTema.textMuted, size: 18),
          suffixIcon: isPassword ? IconButton(icon: Icon(sifreGizli ? Icons.visibility_off : Icons.visibility, color: SiberTema.textMuted, size: 18), onPressed: onVisibilityToggle) : null,
          hintText: hint,
          hintStyle: TextStyle(color: SiberTema.textMuted.withOpacity(0.6), fontSize: 13, fontFamily: 'Avenir'),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
      ),
    );
  }
}

/// 🔧 METALİK SOMUN ÇİZİCİSİ (Altıgen ve Yivli)
class _SomunPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double width = size.width;
    double height = size.height;
    double radius = width / 2;
    Offset center = Offset(width / 2, height / 2);

    // 1. Somunun Altıgen Dış Gövdesi
    Path outerPath = Path();
    for (int i = 0; i < 6; i++) {
      // 30 derece kaydırılmış (sivri uçlar yatayda değil dikeyde olacak şekilde)
      double angle = (math.pi / 3) * i - (math.pi / 6); 
      double x = center.dx + radius * math.cos(angle);
      double y = center.dy + radius * math.sin(angle);
      if (i == 0) outerPath.moveTo(x, y);
      else outerPath.lineTo(x, y);
    }
    outerPath.close();

    // 2. İç Delik (Kullanıcı giriş kısmının oyuğu)
    double innerRadius = radius * 0.70;
    outerPath.addOval(Rect.fromCircle(center: center, radius: innerRadius));
    outerPath.fillType = PathFillType.evenOdd; // Deliği boşalt

    // 3. Gövde Gölgesi (Yere vuran)
    canvas.drawShadow(outerPath, Colors.black.withOpacity(0.3), 15, true);

    // 4. Metalik Gradient Dolgu
    Paint bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFF5F5F5), // Açık metalik parlama
          Color(0xFFE0E0E0),
          Color(0xFFBDBDBD),
          Color(0xFF9E9E9E), // Koyu metalik köşe
        ],
        stops: [0.0, 0.4, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, width, height));
    
    canvas.drawPath(outerPath, bodyPaint);

    // 5. İç Yiv Çizgileri (Somunun dişleri)
    Paint threadPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 1; i <= 4; i++) {
      // İç deliğin hemen etrafında 4 adet yiv dairesi
      double threadRadius = innerRadius + (i * 3);
      
      // Işık ve gölge etkisi için yarı saydam geçişli yivler
      threadPaint.shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.5),
          Colors.black.withOpacity(0.2),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: threadRadius));

      canvas.drawCircle(center, threadRadius, threadPaint);
    }

    // 6. Dış Altıgenin 3D Işık Kenarları (Bevel Etkisi)
    Paint bevelHighlight = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    Paint bevelShadow = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 0; i < 6; i++) {
      double angle1 = (math.pi / 3) * i - (math.pi / 6);
      double angle2 = (math.pi / 3) * (i + 1) - (math.pi / 6);
      
      double x1 = center.dx + radius * math.cos(angle1);
      double y1 = center.dy + radius * math.sin(angle1);
      double x2 = center.dx + radius * math.cos(angle2);
      double y2 = center.dy + radius * math.sin(angle2);

      // Sol üst ve üst kenarlara ışık, sağ alt kenarlara gölge ver
      if (i >= 3 && i <= 5) { // Sol, Sol Üst, Sağ Üst 
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), bevelHighlight);
      } else { // Sağ, Sağ Alt, Sol Alt
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), bevelShadow);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}