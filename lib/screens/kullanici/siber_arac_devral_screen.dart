// lib/screens/kullanici/siber_arac_devral_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/responsive_kalkan.dart';
import '../../services/arac_devir_servisi.dart';

/// 🛡️ PLAZA ARAÇ DEVRALMA TERMİNALİ
/// Kullanıcıların satın aldıkları aracın mülkiyetini Kuantum Kod ile üzerlerine geçirdikleri ekran.
class SiberAracDevralScreen extends StatefulWidget {
  const SiberAracDevralScreen({super.key});

  @override
  State<SiberAracDevralScreen> createState() => _SiberAracDevralScreenState();
}

class _SiberAracDevralScreenState extends State<SiberAracDevralScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _devirKoduCtrl = TextEditingController();
  final TextEditingController _yeniPlakaCtrl = TextEditingController();
  bool _isProcessing = false;

  final Color primaryTeal = Colors.teal.shade700;
  final Color dangerColor = Colors.redAccent;
  final Color textColor = const Color(0xFF1E293B);
  final Color bgColor = const Color(0xFFFAFAFC);

  Future<void> _devirIsleminiBaslat() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);
    HapticFeedback.heavyImpact();

    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("Oturum bulunamadı!");

      String ad = currentUser.displayName?.split(' ').first ?? "YENI_SAHIP";
      String soyad = currentUser.displayName?.split(' ').last ?? "";

      await AracDevirServisi().araciDevral(
        devirKodu: _devirKoduCtrl.text,
        yeniPlaka: _yeniPlakaCtrl.text,
        yeniSahipUid: currentUser.uid,
        yeniSahipAdi: ad,
        yeniSahipSoyadi: soyad,
      );

      if (!mounted) return;
      _plazaUyariGoster("MÜLKİYET AKTARILDI", "Araç başarıyla garajınıza (sicili ile birlikte) eklendi.", primaryTeal);
      
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pop(context);

    } catch (e) {
      _plazaUyariGoster("İŞLEM BAŞARISIZ", e.toString().replaceAll("Exception: ", ""), dangerColor);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _plazaUyariGoster(String baslik, String mesaj, Color renk) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: renk, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
            const SizedBox(height: 4),
            Text(mesaj, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text("ARAÇ DEVRALMA MERKEZİ", style: TextStyle(color: textColor, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13, fontFamily: 'Avenir')),
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
          iconTheme: IconThemeData(color: primaryTeal),
        ),
        body: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: _buildDevirFormu(),
          ),
        ),
      ),
    );
  }

  Widget _buildDevirFormu() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 10))]
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: primaryTeal.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(Icons.handshake_outlined, color: primaryTeal, size: 48),
            ),
            const SizedBox(height: 24),
            Text("MÜLKİYET TRANSFER PROTOKOLÜ", textAlign: TextAlign.center, style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
            const SizedBox(height: 12),
            const Text("Eski sahibinin oluşturduğu 6 haneli devir kodunu ve (değiştiyse) yeni plakayı girerek aracı siciliyle birlikte üstünüze alın.", textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 12, height: 1.5, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
            const SizedBox(height: 40),

            // KOD GİRİŞİ
            _buildPlazaInput(
              controller: _devirKoduCtrl,
              hint: "6 HANELİ DEVİR KODU",
              isRequired: true,
              maxLength: 6,
            ),
            
            // YENİ PLAKA GİRİŞİ
            _buildPlazaInput(
              controller: _yeniPlakaCtrl,
              hint: "YENİ PLAKA (Örn: 34XYZ123)",
              isRequired: true,
            ),

            const SizedBox(height: 40),

            // ONAY BUTONU
            SizedBox(
              width: double.infinity,
              height: 56,
              child: _isProcessing
                  ? Center(child: CircularProgressIndicator(color: primaryTeal))
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryTeal,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.fingerprint, color: Colors.white),
                      label: const Text("MÜLKİYETİ ÜZERİME AL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13, fontFamily: 'Avenir')),
                      onPressed: _devirIsleminiBaslat,
                    ),
            ),
            const SizedBox(height: 24),
            const Text("UYARI: Aracın geçmiş tüm servis, bakım ve hasar sicili Şase Numarası üzerinden korunmaya devam edecektir.", textAlign: TextAlign.center, style: TextStyle(color: Colors.black38, fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.bold, fontFamily: 'Avenir', height: 1.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlazaInput({required TextEditingController controller, required String hint, bool isRequired = false, int? maxLength}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: bgColor, 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: Colors.black.withValues(alpha: 0.05))
      ),
      child: TextFormField(
        controller: controller,
        textCapitalization: TextCapitalization.characters,
        maxLength: maxLength,
        style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'monospace', letterSpacing: 4),
        textAlign: TextAlign.center,
        validator: isRequired ? (v) => v == null || v.isEmpty ? "Zorunlu Alan" : null : null,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 12, fontFamily: 'Avenir', letterSpacing: 1, fontWeight: FontWeight.bold),
          border: InputBorder.none,
          counterText: "",
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
      ),
    );
  }
}
