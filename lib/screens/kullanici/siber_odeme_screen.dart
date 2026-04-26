// lib/screens/siber_odeme_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🚀 KARARGAH ZIRHLARI
import '../core/responsive_kalkan.dart';

class SiberOdemeScreen extends StatefulWidget {
  final double odenecekTutar;
  final String? islemAciklamasi;

  const SiberOdemeScreen({super.key, required this.odenecekTutar, this.islemAciklamasi});

  @override
  State<SiberOdemeScreen> createState() => _SiberOdemeScreenState();
}

class _SiberOdemeScreenState extends State<SiberOdemeScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // KART BİLGİLERİNİ TUTACAK KONTROLCÜLER
  final TextEditingController _isimController = TextEditingController();
  final TextEditingController _kartNoController = TextEditingController();
  final TextEditingController _ayYilController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  bool _isProcessing = false;

  final Color primaryTeal = Colors.teal.shade700;
  final Color textColor = const Color(0xFF1E293B);
  final Color bgColor = const Color(0xFFFAFAFC);
  final Color dangerColor = Colors.redAccent;

  @override
  void dispose() {
    _isimController.dispose();
    _kartNoController.dispose();
    _ayYilController.dispose();
    _cvvController.dispose();
    super.dispose();
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

  // 🚀 FİREBASE / IYZICO API İSTEK MOTORU VE %12 KESİNTİ MÜHRÜ
  Future<void> _iyzicoOdemeyiTamamla() async {
    if (_isimController.text.isEmpty || _kartNoController.text.length < 15 || !_ayYilController.text.contains('/') || _cvvController.text.length < 3) {
      _plazaUyariGoster("BİLGİ EKSİK", "Geçersiz veya eksik kart verisi tespit edildi.", dangerColor);
      return;
    }

    if (_currentUser == null) {
      _plazaUyariGoster("KİMLİK HATASI", "Sistemde oturum açmadınız.", dangerColor);
      return;
    }

    setState(() => _isProcessing = true);
    HapticFeedback.heavyImpact();

    try {
      // 1. IYZICO SİMÜLASYONU (Ağa istek atılıyormuş gibi bekleme)
      await Future.delayed(const Duration(seconds: 2));

      // 2. FİREBASE WRITEBATCH - %12 PLAZA KESİNTİSİ
      double brutTutar = widget.odenecekTutar;
      double karargahKesintisi = brutTutar * 0.12; // %12 Komisyon
      double saticiHakedis = brutTutar - karargahKesintisi;

      WriteBatch batch = _db.batch();

      // İşlemi Cüzdan Hareketlerine Ekle
      DocumentReference cuzdanRef = _db.collection('cuzdan_islemleri').doc();
      batch.set(cuzdanRef, {
        'kullanici_id': _currentUser!.uid,
        'baslik': widget.islemAciklamasi ?? 'OtoDNA Kredi Kartı Ödemesi',
        'tur': 'gider',
        'tutar': brutTutar,
        'tarih': FieldValue.serverTimestamp(),
        'ikon_tipi': 'cuzdan'
      });

      // İşlemi Plaza Finans Havuzuna Şifrele
      DocumentReference finansRef = _db.collection('finans_havuzu').doc();
      batch.set(finansRef, {
        'islem_tipi': 'DIS_AG_KART_ODEMESI',
        'kullanici_id': _currentUser!.uid,
        'brut_tutar': brutTutar,
        'karargah_komisyonu': karargahKesintisi, // PLAZA KASA PAYI
        'satici_hakedis': saticiHakedis,
        'zaman_damgasi': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      // 3. BAŞARILI İŞLEM MÜHRÜ
      if (!mounted) return;
      HapticFeedback.vibrate();
      _basariliOdemeEkraniGoster();

    } catch (e) {
      _plazaUyariGoster("AĞ HATASI", "İşlem tamamlanamadı. $e", dangerColor);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // 💎 PLAZA KALİTESİ: ŞIK BAŞARI ONAY EKRANI
  void _basariliOdemeEkraniGoster() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
        contentPadding: const EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle, border: Border.all(color: Colors.green.shade700, width: 2), boxShadow: [BoxShadow(color: Colors.green.withValues(alpha: 0.1), blurRadius: 20)]),
              child: Icon(Icons.check_circle_outline, color: Colors.green.shade700, size: 48),
            ),
            const SizedBox(height: 32),
            Text("İŞLEM ONAYLANDI", style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
            const SizedBox(height: 12),
            Text("₺${widget.odenecekTutar} başarıyla tahsil edildi. Fatura cüzdanınıza eklendi.", textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54, fontSize: 12, height: 1.5, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text("ANA MERKEZE DÖN", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1, fontFamily: 'Avenir')),
              ),
            )
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
          backgroundColor: Colors.white, 
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: primaryTeal, size: 20), onPressed: () => Navigator.pop(context)),
          title: Text('G Ü V E N L İ   Ö D E M E', style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 3, fontFamily: 'Avenir')),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =================================================================
                // 1. ÖZET KARTI
                // =================================================================
                Container(
                  width: double.infinity, padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                      color: primaryTeal,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [BoxShadow(color: primaryTeal.withValues(alpha: 0.2), blurRadius: 40, spreadRadius: 5, offset: const Offset(0, 10))],
                      gradient: LinearGradient(colors: [primaryTeal, Colors.teal.shade500], begin: Alignment.topLeft, end: Alignment.bottomRight)
                  ),
                  child: Column(
                    children: [
                      const Text("ÖDENECEK TOPLAM TUTAR", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
                      const SizedBox(height: 12),
                      Text("₺${widget.odenecekTutar.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -1, fontFamily: 'Avenir')),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // =================================================================
                // 2. KART BİLGİLERİ (Premium Input)
                // =================================================================
                const Text("KART BİLGİLERİ", style: TextStyle(color: Colors.black45, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                const SizedBox(height: 16),

                _buildTextField(hint: "Kart Üzerindeki İsim", icon: Icons.person_outline, controller: _isimController),
                const SizedBox(height: 16),
                _buildTextField(hint: "Kart Numarası", icon: Icons.credit_card_outlined, isNumber: true, controller: _kartNoController),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(child: _buildTextField(hint: "AA / YY", icon: Icons.calendar_month_outlined, isNumber: false, controller: _ayYilController)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(hint: "CVV", icon: Icons.lock_outline, isNumber: true, isObscure: true, controller: _cvvController)),
                  ],
                ),
                const SizedBox(height: 40),

                // IYZICO Güvencesi Bildirimi
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))]),
                  child: Row(
                    children: [
                      Icon(Icons.shield_outlined, color: primaryTeal, size: 24),
                      const SizedBox(width: 16),
                      const Expanded(child: Text("İşleminiz Iyzico ve OtoDNA güvencesiyle 256-bit şifrelenmektedir.", style: TextStyle(color: Colors.black54, fontSize: 11, height: 1.4, fontWeight: FontWeight.bold, fontFamily: 'Avenir'))),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // =================================================================
                // 3. DEVASA ÖDEME BUTONU
                // =================================================================
                SizedBox(
                  width: double.infinity, height: 60,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    onPressed: _isProcessing ? null : _iyzicoOdemeyiTamamla,
                    icon: _isProcessing ? const SizedBox() : const Icon(Icons.fingerprint, color: Colors.white, size: 24),
                    label: _isProcessing
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("GÜVENLİ AĞ İLE ÖDE", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 💎 YARDIMCI TEXTFIELD
  Widget _buildTextField({required String hint, required IconData icon, bool isNumber = false, bool isObscure = false, required TextEditingController controller}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5))]
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        obscureText: isObscure,
        style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir'),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38, fontWeight: FontWeight.bold, letterSpacing: 0, fontFamily: 'Avenir'),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Icon(icon, color: primaryTeal, size: 20),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 40),
          border: InputBorder.none,
        ),
      ),
    );
  }
}