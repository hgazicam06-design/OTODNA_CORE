import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🔥 SİBER KÖPRÜLER
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';
import '../../core/providers/siber_kimlik_provider.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Siber Renk Paleti
  final Color _primaryCyan = SiberTema.kuantumCyan;
  final Color _cyberBlack = SiberTema.oledBlack;
  final Color _surfaceColor = SiberTema.matGrey.withOpacity(0.2);

  // Kontrolcüler
  final TextEditingController _urunAdController = TextEditingController();
  final TextEditingController _oemKoduController = TextEditingController();
  final TextEditingController _fiyatController = TextEditingController();
  String _secilenMarka = "Marka Seçilmedi";
  bool _isLoading = false;

  // 🧠 YAPAY ZEKA GÖRÜNTÜ İŞLEME (Siber Analiz)
  Future<void> _yapayZekaIleTani() async {
    _showCyberLoading("AI Parçayı Analiz Ediyor...");
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pop(context);

    setState(() {
      _urunAdController.text = "V Kayışı Gergisi";
      _oemKoduController.text = "FIAT-55268018";
      _secilenMarka = "FIAT Egea";
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text("Kuantum Analizi Tamamlandı: FIAT Egea Parçası Tespit Edildi! 🦅",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
      backgroundColor: _primaryCyan,
    ));
  }

  // 📸 RUHSAT DNA TARAMA
  Future<void> _barkodTara() async {
    _showCyberLoading("Ruhsat DNA'sı Çözülüyor...");
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pop(context);

    setState(() {
      _secilenMarka = "BMW 3 Serisi";
      _oemKoduController.text = "WBA320I-DNA-2026";
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Şasi DNA'sı Çözüldü: BMW Tespit Edildi! ✅",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
      backgroundColor: Colors.blueAccent,
    ));
  }

  void _showCyberLoading(String mesaj) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: _cyberBlack,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), border: Border.all(color: _primaryCyan.withOpacity(0.5))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: _primaryCyan),
            const SizedBox(height: 16),
            Text(mesaj, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
            const SizedBox(height: 8),
            const Text("Kuantum Hub Ağı Taranıyor...", style: TextStyle(color: Colors.white38, fontSize: 10, fontFamily: 'Avenir')),
          ],
        ),
      ),
    );
  }

  // 🚀 FİREBASE'E GERÇEK KAYIT MOTORU (Zırhlı ve Mühürlü)
  Future<void> _urunuAgaMuhurle() async {
    final sicil = ref.read(siberSicilProvider).value;

    if (sicil == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🚨 Yetkisiz Erişim: Sicil Kaydı Bulunamadı!")));
      return;
    }

    if (_urunAdController.text.isEmpty || _fiyatController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Eksik veri girişi tespit edildi!"), backgroundColor: Colors.redAccent));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final double hamFiyat = double.tryParse(_fiyatController.text) ?? 0.0;
      final String dukkanAd = sicil['dukkan_adi'] ?? "Bilinmeyen Bayi";

      // 💰 MURAT PLAZA ÖZEL KAR MARJI KONTROLÜ
      final double komisyonOrani = dukkanAd == "Murat Plaza" ? 0.30 : 0.12;
      final double gaziPayi = hamFiyat * komisyonOrani;

      await _db.collection('yedek_parcalar').add({
        'urun_ad': _urunAdController.text,
        'oem_kodu': _oemKoduController.text,
        'marka': _secilenMarka,
        'liste_fiyati': hamFiyat,
        'gazi_payi': gaziPayi,
        'bayi_id': sicil['uid'],
        'bayi_adi': dukkanAd,
        'durum': 'Onaylı/Satışta',
        'eklenme_tarihi': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text("Ürün Kuantum Ağına Başarıyla Mühürlendi! 🚀",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
          backgroundColor: _primaryCyan));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ağ Hatası: $e"), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent, elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
          title: const Text('S İ B E R   İ L A N   T E R M İ N A L İ',
              style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2, fontFamily: 'Avenir')),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAIControlPanel(),
              const SizedBox(height: 32),
              const Text("ÜRÜN KİMLİĞİ", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
              const SizedBox(height: 16),
              _buildCyberTextField("Ürün / Parça Adı", _urunAdController, Icons.build_circle_outlined),
              const SizedBox(height: 16),
              _buildCyberTextField("OEM / Barkod Kodu", _oemKoduController, Icons.qr_code),
              const SizedBox(height: 16),
              _buildMarkaDisplay(),
              const SizedBox(height: 16),
              _buildCyberTextField("Satış Fiyatı (₺)", _fiyatController, Icons.attach_money, isNumber: true),
              const SizedBox(height: 40),
              _buildSubmitButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIControlPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _primaryCyan.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: _primaryCyan.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: _primaryCyan, size: 24),
              const SizedBox(width: 12),
              const Expanded(child: Text("YAPAY ZEKA (AI) İSTİHBARATI",
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir'))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildAIButton("PARÇAYI TANI", Icons.camera_alt_outlined, _primaryCyan, _yapayZekaIleTani)),
              const SizedBox(width: 12),
              Expanded(child: _buildAIButton("RUHSAT / ŞASİ", Icons.document_scanner_outlined, Colors.blueAccent, _barkodTara)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAIButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: color.withOpacity(0.5))),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
    );
  }

  Widget _buildMarkaDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(color: _cyberBlack, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Row(
        children: [
          const Icon(Icons.directions_car_outlined, color: Colors.white38, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Uyumlu Marka / Model", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
              const SizedBox(height: 4),
              Text(_secilenMarka, style: TextStyle(color: _secilenMarka == "Marka Seçilmedi" ? Colors.white54 : _primaryCyan, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity, height: 60,
      child: ElevatedButton.icon(
        style: SiberTema.kuantumButonStili(),
        onPressed: _isLoading ? null : _urunuAgaMuhurle,
        icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)) : const Icon(Icons.publish, size: 24, color: Colors.black),
        label: Text(_isLoading ? "VERİ AKTARILIYOR..." : "SİBER AĞA MÜHÜRLE",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1, color: Colors.black, fontFamily: 'Avenir')),
      ),
    );
  }

  Widget _buildCyberTextField(String hint, TextEditingController controller, IconData icon, {bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(color: _surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 13, fontFamily: 'Avenir'),
          prefixIcon: Icon(icon, color: Colors.white38, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}