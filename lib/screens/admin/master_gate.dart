// lib/admin/master_gate.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🚀 KARARGAH ZIRHLARI VE HEDEF ROTA (Mutlak Rota ile Bağlandı!)
import 'package:otodna/core/siber_tema.dart';
import 'package:otodna/core/responsive_kalkan.dart';
// 🔥 Giriş başarılı olunca asıl Amiral Gemisine (hq_command_center) fırlatılacak!
import 'package:otodna/screens/admin/hq_command_center.dart';

class MasterGateScreen extends StatefulWidget {
  MasterGateScreen({super.key});

  @override
  State<MasterGateScreen> createState() => _MasterGateScreenState();
}

class _MasterGateScreenState extends State<MasterGateScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: Duration(seconds: 2))..repeat(reverse: true);
    _emailController.text = "admin@otodna.com"; // Test için kolaylık
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // --- 🔴 FİREBASE: SİBER DOĞRULAMA MOTORU ---
  Future<void> _agaBaglan() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _siberUyari("SİBER İHLAL: Lütfen tüm protokol şifrelerini girin!", SiberTema.kanKirmizi);
      return;
    }

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      // SADECE VE SADECE GERÇEK FİREBASE DOĞRULAMASI!
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 📡 SİBER İSTİHBARAT: Başarılı Giriş Mührü
      FirebaseFirestore.instance.collection('siber_istihbarat_loglari').add({
        'islem_turu': 'GÜVENLİK',
        'seviye': 'BİLGİ',
        'islem_detayi': 'MASTER GATE AÇILDI: Yetkili Karargaha giriş yaptı. (${_emailController.text.trim()})',
        'kullanici_id': FirebaseAuth.instance.currentUser?.uid ?? 'BILINMIYOR',
        'tarih': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _siberUyari("SİBER AĞ ONAYLANDI. Karargaha Geçiliyor... 🦅", SiberTema.kuantumCyan);

      // 🔥 Başarılı girişte DOĞRUDAN Asıl Karargaha (HqCommandCenter) yönlendir!
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HqCommandCenterScreen()));

    } on FirebaseAuthException catch (e) {
      String hataMesaji = "KUANTUM KİLİDİ AÇILAMADI!";
      if (e.code == 'user-not-found' || e.code == 'invalid-email') {
        hataMesaji = "ERİŞİM REDDEDİLDİ: Bu kimlik Siber Ağda bulunamadı.";
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        hataMesaji = "ERİŞİM REDDEDİLDİ: Hatalı Kuantum Şifresi!";
      }

      // 🚨 SİBER İSTİHBARAT: Brute Force Kırmızı Alarm
      FirebaseFirestore.instance.collection('siber_istihbarat_loglari').add({
        'islem_turu': 'GÜVENLİK',
        'seviye': 'KRİTİK',
        'islem_detayi': 'SİBER İHLAL DENEMESİ: Master Gate Zorlanıyor! Denenen Email: ${_emailController.text.trim()}',
        'kullanici_id': 'YETKİSİZ_GİRİŞ',
        'tarih': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _siberUyari(hataMesaji, SiberTema.kanKirmizi);
    } catch (e) {
      if (!mounted) return;
      _siberUyari("SİSTEM ÇÖKMESİ VEYA AĞ HATASI: $e", SiberTema.kanKirmizi);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _siberUyari(String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: TextStyle(color: renk == SiberTema.kuantumCyan ? SiberTema.oledBlack : Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
        backgroundColor: renk,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      child: Scaffold(
        backgroundColor: Colors.transparent, // Arka plan ana uygulama rengiyle aynı (OLED Siyah)
        body: Center(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. SİBER KİLİT ANİMASYONU (Görkemli ve Büyük Logo)
                AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        padding: EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: SiberTema.oledBlack,
                          border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5 + (_pulseController.value * 0.5)), width: 2),
                          boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.2 * _pulseController.value), blurRadius: 40, spreadRadius: 10)],
                        ),
                        child: Icon(Icons.security, color: SiberTema.kuantumCyan, size: 80), // İkon devasa boyuta çıkarıldı!
                      );
                    }
                ),
                SizedBox(height: 32),

                // 2. BAŞLIKLAR
                Text("MASTER GATE", style: TextStyle(color: SiberTema.textMain, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 6)),
                SizedBox(height: 8),
                Text("OtoDNA Kuantum Karargahı Giriş Protokolü", style: TextStyle(color: SiberTema.kuantumCyan.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                SizedBox(height: 48),

                // 3. CAM EFEKTLİ GİRİŞ FORMU
                _buildCamEfektliKutu(
                  child: Column(
                    children: [
                      _buildSiberTextField(
                        controller: _emailController,
                        hint: "Yönetici E-posta Kimliği",
                        icon: Icons.alternate_email,
                        isObscure: false,
                      ),
                      SizedBox(height: 16),
                      _buildSiberTextField(
                        controller: _passwordController,
                        hint: "Kuantum Şifresi",
                        icon: Icons.password,
                        isObscure: true,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40),

                // 4. BAĞLANTI BUTONU
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    style: SiberTema.kuantumButonStili(),
                    onPressed: _isLoading ? null : _agaBaglan,
                    icon: _isLoading
                        ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: SiberTema.oledBlack, strokeWidth: 3))
                        : Icon(Icons.fingerprint, color: SiberTema.oledBlack, size: 28),
                    label: Text(
                        _isLoading ? "MÜHÜR DOĞRULANIYOR..." : "AĞA BAĞLAN VE GİRİŞ YAP",
                        style: TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 2)
                    ),
                  ),
                ),

                SizedBox(height: 30),
                Icon(Icons.lock_outline, color: SiberTema.textMuted, size: 16),
                SizedBox(height: 8),
                Text("256-Bit Kuantum Şifreleme Aktif", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, letterSpacing: 1)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 🎨 SİBER GÖRSEL YARDIMCILAR ---
  Widget _buildSiberTextField({required TextEditingController controller, required String hint, required IconData icon, required bool isObscure}) {
    return Container(
      decoration: BoxDecoration(
        color: SiberTema.matGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SiberTema.textMuted),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        keyboardType: isObscure ? TextInputType.text : TextInputType.emailAddress,
        style: TextStyle(color: SiberTema.textMain, letterSpacing: isObscure ? 4 : 1, fontSize: 14),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: SiberTema.kuantumCyan, size: 20),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white30, letterSpacing: 1, fontSize: 13),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildCamEfektliKutu({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: SiberTema.matGrey.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.2)),
            boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.02), blurRadius: 30)],
          ),
          child: child,
        ),
      ),
    );
  }
}