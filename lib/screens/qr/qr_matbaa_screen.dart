import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🔥 SİBER KÖPRÜLER
import '../../../core/siber_tema.dart';
import '../../../core/responsive_kalkan.dart';
import '../../../services/qr_engine_service.dart';

class QrMatbaaScreen extends StatefulWidget {
  const QrMatbaaScreen({super.key});

  @override
  State<QrMatbaaScreen> createState() => _QrMatbaaScreenState();
}

class _QrMatbaaScreenState extends State<QrMatbaaScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _plateController = TextEditingController();

  String? _qrData;
  bool _isGenerating = false;

  Future<void> _qrKodUretVeMuhrle() async {
    String plaka = _plateController.text.trim().toUpperCase().replaceAll(" ", "");
    if (plaka.length < 5) {
      _siberUyari("Geçerli bir plaka veya şase girin!", isError: true);
      return;
    }

    setState(() => _isGenerating = true);
    FocusScope.of(context).unfocus();

    try {
      // Motoru kullanarak şifreyi üret
      String guvenliSifre = QREngineService.generateVehicleDNAString(plateNumber: plaka, dealerId: _currentUser?.uid ?? 'BİLİNMEYEN');

      // Firebase'e Mühürle
      await _db.collection('basili_qr_kodlar').doc(plaka).set({
        'bayi_id': _currentUser?.uid ?? 'Bilinmeyen Bayi',
        'plaka': plaka,
        'qr_sifresi': guvenliSifre,
        'basim_tarihi': FieldValue.serverTimestamp(),
        'aktif_mi': true,
      }, SetOptions(merge: true));

      setState(() => _qrData = guvenliSifre);
      _siberUyari("Siber Kimlik Başarıyla Üretildi ve Ağa Mühürlendi! ✅");

    } catch (e) {
      _siberUyari("Ağ Hatası: $e", isError: true);
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  void _siberUyari(String mesaj, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: TextStyle(color: isError ? Colors.white : SiberTema.oledBlack, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
      backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
    ));
  }

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent, elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20), onPressed: () => Navigator.pop(context)),
          title: const Text('QR MATBAA MERKEZİ', style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Text("FİZİKSEL ARAÇ ETİKETİ BASIMI", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontFamily: 'Avenir')),
              const SizedBox(height: 24),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _qrData == null
                    ? Container(
                  height: 240, width: 240,
                  decoration: BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12, style: BorderStyle.dash)),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_scanner, color: Colors.white24, size: 64),
                      SizedBox(height: 12),
                      Text("Siber Kimlik\nBekleniyor...", textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontFamily: 'Avenir')),
                    ],
                  ),
                )
                    : QREngineService.buildSiberQRCode(_qrData!), // Motordan çizdiriyoruz!
              ),
              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
                child: TextField(
                  controller: _plateController,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 4, fontFamily: 'Avenir'),
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    hintText: "PLAKA / ŞASE GİR",
                    hintStyle: TextStyle(color: Colors.white24, fontSize: 16, letterSpacing: 4, fontWeight: FontWeight.bold),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton.icon(
                  style: SiberTema.kuantumButonStili(),
                  onPressed: _isGenerating ? null : _qrKodUretVeMuhrle,
                  icon: _isGenerating ? const SizedBox() : const Icon(Icons.generating_tokens, size: 24),
                  label: _isGenerating
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: SiberTema.oledBlack, strokeWidth: 2))
                      : const Text('KRİPTOLU QR ÜRET', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5, fontFamily: 'Avenir')),
                ),
              ),

              if (_qrData != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity, height: 56,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: SiberTema.kuantumCyan), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () => _siberUyari("Etiket Bluetooth Yazıcıya Gönderiliyor... 🖨️"),
                    icon: const Icon(Icons.print, color: SiberTema.kuantumCyan),
                    label: const Text('FİZİKSEL ETİKETİ YAZDIR', style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}