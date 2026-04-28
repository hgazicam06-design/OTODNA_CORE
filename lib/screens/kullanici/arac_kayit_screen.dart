import 'package:otodna/core/siber_tema.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AracKayitScreen extends StatefulWidget {
  AracKayitScreen({super.key});

  @override
  State<AracKayitScreen> createState() => _AracKayitScreenState();
}

class _AracKayitScreenState extends State<AracKayitScreen> {
  // GERÇEK VERİ GİRİŞ KONTROLCÜLERİ
  final TextEditingController _plakaController = TextEditingController();
  final TextEditingController _markaController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yilController = TextEditingController();
  final TextEditingController _fiyatController = TextEditingController();
  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _durumController = TextEditingController();
  final TextEditingController _sahibiController = TextEditingController();
  final TextEditingController _aciklamaController = TextEditingController();

  bool _isSaving = false;

  Future<void> _araciSistemeKaydet() async {
    if (_plakaController.text.isEmpty || _markaController.text.isEmpty || _fiyatController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Plaka, Marka ve Fiyat zorunlu alanlardır.", style: TextStyle(color: SiberTema.textMain)), backgroundColor: Colors.redAccent));
      return;
    }

    setState(() => _isSaving = true);
    FocusScope.of(context).unfocus();

    String plakaID = _plakaController.text.trim().replaceAll(" ", "").toUpperCase();

    try {
      await FirebaseFirestore.instance.collection('araclar').doc(plakaID).set({
        "plaka": plakaID,
        "marka": _markaController.text.trim(),
        "model": _modelController.text.trim(),
        "yil": int.tryParse(_yilController.text.trim()) ?? 2020,
        "fiyat": int.tryParse(_fiyatController.text.trim()) ?? 0,
        "km": int.tryParse(_kmController.text.trim()) ?? 0,
        "durum": _durumController.text.trim().isEmpty ? "Belirtilmemiş" : _durumController.text.trim(),
        "sahibi": _sahibiController.text.trim().isEmpty ? "OtoDNA Bayi" : _sahibiController.text.trim(),
        "aciklama": _aciklamaController.text.trim(),
        "dna_skoru": 95,
        "lokasyon": "OtoDNA Merkez",
        "kayit_tarihi": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Araç sisteme başarıyla işlendi.", style: TextStyle(color: SiberTema.textMain)), backgroundColor: Colors.teal.shade700));
      Navigator.pop(context);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _plakaController.dispose(); _markaController.dispose(); _modelController.dispose();
    _yilController.dispose(); _fiyatController.dispose(); _kmController.dispose();
    _durumController.dispose(); _sahibiController.dispose(); _aciklamaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🏢 PLAZA KALİTESİ PALET (Açık, Ferah ve Lüks)
    const bgColor = Color(0xFFFAFAFC); // Sedefli Fil Dişi
    final primaryTeal = Colors.teal.shade700;
    const inputColor = Colors.white; // Saf beyaz
    const textColor = Color(0xFF1E293B); // Koyu Gri/Lacivert

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.close, color: textColor, size: 24), onPressed: () => Navigator.pop(context)),
        title: Text("O T O D N A", style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 8, fontFamily: 'Avenir')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =================================================================
            // PLAZA MANTIĞI: ADIM GÖSTERGESİ VE BÜYÜK BAŞLIK
            // =================================================================
            Text("Adım 1/2", style: TextStyle(color: primaryTeal, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
            SizedBox(height: 8),
            Text("Araç Kimliği", style: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Avenir')),
            SizedBox(height: 32),

            // =================================================================
            // FORM ALANLARI (Minimalist & Floating Label)
            // =================================================================
            _buildPremiumInput("Plaka / Şase", Icons.pin_outlined, _plakaController, isUppercase: true, inputColor: inputColor, textColor: textColor, primaryTeal: primaryTeal),
            SizedBox(height: 16),
            _buildPremiumInput("Marka", Icons.branding_watermark_outlined, _markaController, inputColor: inputColor, textColor: textColor, primaryTeal: primaryTeal),
            SizedBox(height: 16),
            _buildPremiumInput("Model", Icons.directions_car_outlined, _modelController, inputColor: inputColor, textColor: textColor, primaryTeal: primaryTeal),
            SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: _buildPremiumInput("Üretim Yılı", Icons.calendar_today_outlined, _yilController, isNumber: true, inputColor: inputColor, textColor: textColor, primaryTeal: primaryTeal)),
                SizedBox(width: 16),
                Expanded(child: _buildPremiumInput("Kilometre", Icons.speed_outlined, _kmController, isNumber: true, inputColor: inputColor, textColor: textColor, primaryTeal: primaryTeal)),
              ],
            ),
            SizedBox(height: 16),
            _buildPremiumInput("Satış Fiyatı (₺)", Icons.attach_money_outlined, _fiyatController, isNumber: true, inputColor: inputColor, textColor: textColor, primaryTeal: primaryTeal),

            SizedBox(height: 40),

            // =================================================================
            // PLAZA MANTIĞI: ADIM 2 BAŞLIĞI
            // =================================================================
            Text("Adım 2/2", style: TextStyle(color: primaryTeal, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
            SizedBox(height: 8),
            Text("Ekspertiz Durumu", style: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Avenir')),
            SizedBox(height: 32),

            _buildPremiumInput("Hasar Durumu (Örn: Değişensiz)", Icons.health_and_safety_outlined, _durumController, inputColor: inputColor, textColor: textColor, primaryTeal: primaryTeal),
            SizedBox(height: 16),
            _buildPremiumInput("Ruhsat Sahibi / Bayi", Icons.person_outline, _sahibiController, inputColor: inputColor, textColor: textColor, primaryTeal: primaryTeal),
            SizedBox(height: 16),

            // Premium Açıklama Kutusu
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: inputColor, 
                borderRadius: BorderRadius.circular(16), 
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: TextField(
                controller: _aciklamaController,
                style: TextStyle(color: textColor, fontSize: 15, fontFamily: 'Avenir', fontWeight: FontWeight.w600),
                maxLines: 4,
                decoration: InputDecoration(
                    labelText: "Açıklama & Donanım",
                    labelStyle: TextStyle(color: Colors.white38, fontSize: 13, fontFamily: 'Avenir'),
                    border: InputBorder.none,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    floatingLabelStyle: TextStyle(color: primaryTeal, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            SizedBox(height: 48),

            // =================================================================
            // PLAZA TARZI GENİŞ SADE BUTON
            // =================================================================
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: textColor, // Koyu elit buton
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: Colors.black.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _isSaving ? null : _araciSistemeKaydet,
                child: _isSaving
                    ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text("SONRAKİ ADIM", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1.5, fontFamily: 'Avenir')),
              ),
            ),

            SizedBox(height: 24),
            Center(
              child: Text("Sisteme girilen araçlar OtoDNA politikalarına tabidir.", style: TextStyle(color: Colors.white38, fontSize: 11, fontFamily: 'Avenir')),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // 💎 PLAZA STANDARTLARINDA ULTRA-MİNİMALİST INPUT (FLOATING LABEL)
  // -------------------------------------------------------------------------
  Widget _buildPremiumInput(String label, IconData icon, TextEditingController controller, {bool isNumber = false, bool isUppercase = false, required Color inputColor, required Color textColor, required Color primaryTeal}) {
    return Container(
      decoration: BoxDecoration(
        color: inputColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        textCapitalization: isUppercase ? TextCapitalization.characters : TextCapitalization.sentences,
        style: TextStyle(color: textColor, fontSize: 16, fontFamily: 'Avenir', fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white54, size: 20),
          labelText: label,
          labelStyle: TextStyle(color: Colors.white38, fontSize: 14, fontFamily: 'Avenir'),
          floatingLabelStyle: TextStyle(color: primaryTeal, fontSize: 14, fontWeight: FontWeight.bold),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}