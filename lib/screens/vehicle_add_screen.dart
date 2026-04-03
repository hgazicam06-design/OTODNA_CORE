import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // Gerçek kayıt için açılacak

class VehicleAddScreen extends StatefulWidget {
  const VehicleAddScreen({super.key});

  @override
  State<VehicleAddScreen> createState() => _VehicleAddScreenState();
}

class _VehicleAddScreenState extends State<VehicleAddScreen> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  static const Color bgColor = Color(0xFF000000);
  static const Color surfaceColor = Color(0xFF111111);
  static const Color primaryCyan = Color(0xFF00FFC2);
  static const Color dangerColor = Colors.redAccent;

  final TextEditingController _vinController = TextEditingController();
  final TextEditingController _plakaController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _vinController.dispose();
    _plakaController.dispose();
    super.dispose();
  }

  // 🚀 FİREBASE: ARAÇ DNA'SINI KUANTUM AĞINA MÜHÜRLE
  Future<void> _araciTanimla() async {
    String vin = _vinController.text.trim().toUpperCase();
    String plaka = _plakaController.text.trim().toUpperCase();

    if (vin.length != 17) {
      _uyariGoster("SİBER İHLAL: Şase Numarası (VIN) tam 17 haneli olmalıdır!", isError: true);
      return;
    }

    if (plaka.isEmpty || plaka.length < 5) {
      _uyariGoster("SİBER İHLAL: Lütfen geçerli bir araç plakası giriniz!", isError: true);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // 1. Kuantum Ağına Bağlanılıyor (Sorgu Simülasyonu)
      await Future.delayed(const Duration(seconds: 2));

      // 2. TODO: FİREBASE KAYIT MOTORU (Gerçekte bu satırlar aktif olacak)
      /*
      await FirebaseFirestore.instance.collection('araclar').add({
        'sase_no': vin,
        'plaka': plaka,
        'sahip_id': FirebaseAuth.instance.currentUser?.uid,
        'kayit_tarihi': FieldValue.serverTimestamp(),
      });
      */

      if (!mounted) return;

      _uyariGoster("ARAÇ DNA'SI BAŞARIYLA KUANTUM AĞINA MÜHÜRLENDİ! 🦅");

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) Navigator.pop(context); // Terminali Kapat
      });

    } catch (e) {
      _uyariGoster("AĞ ÇÖKTÜ: Araç mühürlenemedi!", isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _uyariGoster(String mesaj, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1)),
        backgroundColor: isError ? dangerColor : primaryCyan,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: primaryCyan, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text("ARAÇ DNA KODLAMA", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500), // 🖥️ Web / Double Teyp Kalkanı
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. SİBER BARKOD GÖRSELİ
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryCyan.withOpacity(0.5), width: 2),
                        boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.15), blurRadius: 40, spreadRadius: 10)],
                      ),
                      child: const Icon(Icons.qr_code_scanner, color: primaryCyan, size: 64),
                    ),
                  ),
                  const SizedBox(height: 32),

                  const Text("SİSTEME ARAÇ ENTEGRE ET", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 12),
                  const Text(
                    "OtoDNA Kuantum Ağına yeni bir araç mühürlemek için donanım kimliğini (17 Haneli VIN) giriniz.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, height: 1.5, letterSpacing: 1),
                  ),
                  const SizedBox(height: 48),

                  // 2. PLAKA GİRİŞ TERMİNALİ
                  _buildKuantumInput(
                    controller: _plakaController,
                    hint: "ARAÇ PLAKASI (ÖRN: 34 DNA 2026)",
                    icon: Icons.directions_car,
                    maxLength: 10,
                  ),
                  const SizedBox(height: 24),

                  // 3. ŞASE (VIN) GİRİŞ TERMİNALİ
                  _buildKuantumInput(
                    controller: _vinController,
                    hint: "17 HANELİ ŞASE NO (VIN)",
                    icon: Icons.memory,
                    maxLength: 17,
                  ),
                  const SizedBox(height: 48),

                  // 4. ATEŞLEME BUTONU
                  SizedBox(
                    height: 64,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryCyan,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        disabledBackgroundColor: primaryCyan.withOpacity(0.2),
                      ),
                      onPressed: _isProcessing ? null : _araciTanimla,
                      icon: _isProcessing
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                          : const Icon(Icons.radar, size: 24),
                      label: Text(
                        _isProcessing ? "DNA SORGULANIYOR..." : "ARACI KUANTUM AĞINA MÜHÜRLE",
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: SİBER METİN KUTUSU
  Widget _buildKuantumInput({required TextEditingController controller, required String hint, required IconData icon, required int maxLength}) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        controller: controller,
        maxLength: maxLength,
        textCapitalization: TextCapitalization.characters, // Otomatik BÜYÜK harf
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')), // Sadece harf, rakam ve boşluk (Özel karakter yasak)
        ],
        style: const TextStyle(color: primaryCyan, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2),
        decoration: InputDecoration(
          counterText: "", // Alt kısımdaki "17/17" yazısını gizler
          prefixIcon: Icon(icon, color: Colors.white38, size: 20),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: primaryCyan, width: 1.5),
          ),
        ),
      ),
    );
  }
}