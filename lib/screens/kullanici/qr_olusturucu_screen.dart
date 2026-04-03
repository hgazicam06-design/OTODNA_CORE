import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QrOlusturucuScreen extends StatefulWidget {
  const QrOlusturucuScreen({super.key});

  @override
  State<QrOlusturucuScreen> createState() => _QrOlusturucuScreenState();
}

class _QrOlusturucuScreenState extends State<QrOlusturucuScreen> {
  final TextEditingController _plakaController = TextEditingController();
  String _uretilenQRVerisi = "";
  bool _isSaving = false;

  // QR ÜRET VE FİREBASE'E KAYDET
  Future<void> _qrUretVeSistemeKaydet() async {
    if (_plakaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Plaka veya Şase numarası girmelisiniz.", style: TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent));
      return;
    }

    FocusScope.of(context).unfocus();
    String plakaID = _plakaController.text.trim().replaceAll(" ", "").toUpperCase();

    setState(() {
      _isSaving = true;
      _uretilenQRVerisi = "OTODNA:$plakaID"; // QR'ın içine gömülen şifreli veri
    });

    try {
      // Bu QR'ın üretildiğini Firebase Araclar veritabanına mühürlüyoruz
      await FirebaseFirestore.instance.collection('araclar').doc(plakaID).set({
        "plaka": plakaID,
        "qr_kimlik_kodu": _uretilenQRVerisi,
        "qr_olusturulma_tarihi": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kuantum QR Kimliği Ağa Mühürlendi! 🧬", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Color(0xFF00FFC2)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Kayıt Hatası: $e", style: const TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _plakaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
    const bgColor = Color(0xFF000000); // Saf Siyah
    const surfaceColor = Color(0xFF111111); // Mat Gri
    const primaryCyan = Color(0xFF00FFC2);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text("Q R   M E R K E Z İ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 4)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ÜST İKON (Sade ve Teknolojik)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: surfaceColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: const Icon(Icons.qr_code_scanner_outlined, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 24),

            const Text("SİBER KİMLİK OLUŞTUR", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 1)),
            const SizedBox(height: 8),
            const Text("Araca ait benzersiz QR kimliği oluşturup cama yapıştırmak veya dijitalde tutmak için plaka girin.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5)),

            const SizedBox(height: 40),

            // MİNİMALİST PLAKA GİRİŞ ALANI
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.05))
              ),
              child: TextField(
                controller: _plakaController,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(color: primaryCyan, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 4),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                    hintText: "PLAKA / ŞASE",
                    hintStyle: TextStyle(color: Colors.white24, fontSize: 16, letterSpacing: 4, fontWeight: FontWeight.bold),
                    border: InputBorder.none
                ),
              ),
            ),

            const SizedBox(height: 32),

            // TESLA STİLİ FLAT BUTON
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryCyan,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: _isSaving ? null : _qrUretVeSistemeKaydet,
                child: _isSaving
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : const Text("KİMLİĞİ ÜRET VE AĞA MÜHÜRLE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
              ),
            ),

            // EĞER QR ÜRETİLDİYSE EKRANA BASTIR (Kusursuz Tasarım)
            if (_uretilenQRVerisi.isNotEmpty) ...[
              const SizedBox(height: 48),
              const Divider(color: Colors.white12),
              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white, // QR kodu okutulabilmesi için zemin beyaz kalmalı
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    QrImageView(
                      data: _uretilenQRVerisi,
                      version: QrVersions.auto,
                      size: 220.0,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                      dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
                    ),
                    const SizedBox(height: 24),
                    Text(_plakaController.text.toUpperCase(), style: const TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 4)),
                    const SizedBox(height: 4),
                    const Text("OtoDNA Kuantum Kimliği", style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ]
          ],
        ),
      ),
    );
  }
}