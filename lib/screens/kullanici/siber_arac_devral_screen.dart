// lib/screens/kullanici/siber_arac_devral_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI VE TEMA
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

// SERVİSLER
import '../../services/arac_devir_servisi.dart';

/// 🛡️ KUANTUM ARAÇ DEVRALMA TERMİNALİ
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

  Future<void> _devirIsleminiBaslat() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);
    HapticFeedback.heavyImpact();

    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("Oturum bulunamadı!");

      // Gerçek senaryoda kullanıcı ad soyad veritabanından çekilmeli
      // Burada örnek isim gönderiyoruz, sistem mevcut Firebase Auth displayName'i de kullanabilir.
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
      _siberUyariGoster("MÜLKİYET AKTARILDI", "Araç başarıyla garajınıza (sicili ile birlikte) eklendi.", SiberTema.kuantumCyan);
      
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pop(context);

    } catch (e) {
      _siberUyariGoster("SİBER İHLAL", e.toString(), SiberTema.kanKirmizi);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _siberUyariGoster(String baslik, String mesaj, Color renk) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SiberTema.matGrey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: renk, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
            const SizedBox(height: 4),
            Text(mesaj, style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Avenir')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("ARAÇ SATIN ALMA & DEVRALMA", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 12, fontFamily: 'Avenir')),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: SiberTema.kuantumCyan),
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
      padding: const EdgeInsets.all(24),
      decoration: SiberTema.siberCamZirh(renk: Colors.black),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Icon(Icons.handshake_outlined, color: SiberTema.kuantumCyan, size: 50),
            const SizedBox(height: 16),
            const Text("MÜLKİYET TRANSFER PROTOKOLÜ", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 2)),
            const SizedBox(height: 8),
            const Text("Eski sahibinin Karargahtan oluşturduğu 6 Haneli Devir Kodunu ve (değiştiyse) yeni plakayı girerek aracı siciliyle birlikte üstünüze alın.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.5)),
            const SizedBox(height: 32),

            // KOD GİRİŞİ
            _buildSiberInput(
              controller: _devirKoduCtrl,
              hint: "6 HANELİ DEVİR KODU",
              isRequired: true,
              maxLength: 6,
            ),
            
            // YENİ PLAKA GİRİŞİ
            _buildSiberInput(
              controller: _yeniPlakaCtrl,
              hint: "YENİ PLAKA (Örn: 34XYZ123)",
              isRequired: true,
            ),

            const SizedBox(height: 32),

            // ONAY BUTONU
            SizedBox(
              width: double.infinity,
              height: 55,
              child: _isProcessing
                  ? const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan))
                  : ElevatedButton.icon(
                      style: SiberTema.kuantumButonStili(),
                      icon: const Icon(Icons.fingerprint, color: Colors.black),
                      label: const Text("MÜLKİYETİ ÜZERİME AL", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                      onPressed: _devirIsleminiBaslat,
                    ),
            ),
            const SizedBox(height: 16),
            const Text("UYARI: Aracın geçmiş tüm servis, bakım ve hasar sicili Şase Numarası üzerinden korunmaya devam edecektir.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white24, fontSize: 9, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildSiberInput({required TextEditingController controller, required String hint, bool isRequired = false, int? maxLength}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: SiberTema.matGrey.withOpacity(0.5), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white12)),
      child: TextFormField(
        controller: controller,
        textCapitalization: TextCapitalization.characters,
        maxLength: maxLength,
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'monospace', letterSpacing: 3),
        textAlign: TextAlign.center,
        validator: isRequired ? (v) => v == null || v.isEmpty ? "Zorunlu Alan" : null : null,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white30, fontSize: 12, fontFamily: 'Avenir', letterSpacing: 1, fontWeight: FontWeight.normal),
          border: InputBorder.none,
          counterText: "", // maxLength yazısını gizler
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
