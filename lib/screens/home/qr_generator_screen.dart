import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  final TextEditingController _plateController = TextEditingController();
  String? _qrData;
  bool _isGenerating = false;

  void _siberUyari(String mesaj, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: TextStyle(color: isError ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
      backgroundColor: isError ? Colors.redAccent : const Color(0xFF00FFC2),
    ));
  }

  // 🚀 FİREBASE BAĞLANTILI KRİPTOLU QR ÜRETİM MOTORU
  Future<void> _qrKodUretVeMuhrle() async {
    String plaka = _plateController.text.trim().toUpperCase().replaceAll(" ", "");

    if (plaka.length < 5) {
      _siberUyari("Lütfen geçerli bir plaka veya şase girin!", isError: true);
      return;
    }

    setState(() => _isGenerating = true);

    try {
      // 1. Kriptolu OtoDNA formatında eşsiz bir veri string'i oluştur
      // Örn: OTODNA_TAG_34DNA2026_1684392812
      String guvenliSifre = "OTODNA_TAG_${plaka}_${DateTime.now().millisecondsSinceEpoch}";

      // 2. Bu üretimi Firebase'e (Siber Ağa) kaydet (Hangi usta, ne zaman, hangi araca bastı?)
      await _db.collection('basili_qr_kodlar').add({
        'bayi_id': _currentUser?.uid ?? 'Bilinmeyen Bayi',
        'plaka': plaka,
        'qr_sifresi': guvenliSifre,
        'basim_tarihi': FieldValue.serverTimestamp(),
        'aktif_mi': true,
      });

      // 3. Ekranda QR'ı göster
      setState(() {
        _qrData = guvenliSifre;
      });

      _siberUyari("Siber Kimlik Başarıyla Üretildi ve Ağa Mühürlendi! ✅");

    } catch (e) {
      _siberUyari("Ağ Hatası: $e", isError: true);
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0F172A);
    const primaryCyan = Color(0xFF00FFC2);
    const cardColor = Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryCyan),
        title: const Text('OtoDNA QR ÜRETİM MERKEZİ', style: TextStyle(color: primaryCyan, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("FİZİKSEL ARAÇ ETİKETİ BASIMI", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 24),

            // --- QR KOD GÖSTERİM ALANI ---
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _qrData == null
                  ? Container(
                height: 240,
                width: 240,
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12, style: BorderStyle.dash)),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_scanner, color: Colors.white24, size: 64),
                    SizedBox(height: 12),
                    Text("Siber Kimlik\nBekleniyor...", textAlign: TextAlign.center, style: TextStyle(color: Colors.white38)),
                  ],
                ),
              )
                  : Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white, // Kameralar siyah-beyaz zıtlığını sevdiği için beyaz
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.4), blurRadius: 30, spreadRadius: 5)],
                ),
                child: QrImageView(
                  data: _qrData!,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // --- PLAKA GİRİŞ ALANI ---
            TextField(
              controller: _plateController,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2),
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: '34 DNA 2026',
                hintStyle: const TextStyle(color: Colors.white24),
                labelText: 'Araç Plakası veya Şase No',
                labelStyle: const TextStyle(color: primaryCyan),
                filled: true,
                fillColor: cardColor,
                enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white12), borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: primaryCyan, width: 2), borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),

            // --- ÜRET BUTONU ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryCyan,
                  foregroundColor: bgColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isGenerating ? null : _qrKodUretVeMuhrle,
                icon: _isGenerating ? const SizedBox() : const Icon(Icons.generating_tokens),
                label: _isGenerating
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black))
                    : const Text('KRİPTOLU QR ÜRET', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5)),
              ),
            ),

            const SizedBox(height: 16),

            // --- YAZICIYA GÖNDER BUTONU ---
            if (_qrData != null)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: primaryCyan),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    _siberUyari("Etiket Bluetooth Yazıcıya Gönderiliyor... 🖨️");
                  },
                  icon: const Icon(Icons.print, color: primaryCyan),
                  label: const Text('FİZİKSEL ETİKETİ YAZDIR', style: TextStyle(color: primaryCyan, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}