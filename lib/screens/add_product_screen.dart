import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  final Color bgColor = const Color(0xFF000000);
  final Color surfaceColor = const Color(0xFF111111);
  final Color primaryCyan = const Color(0xFF00FFC2);

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Kontrolcüler
  final TextEditingController _urunAdController = TextEditingController();
  final TextEditingController _oemKoduController = TextEditingController();
  final TextEditingController _fiyatController = TextEditingController();
  String _secilenMarka = "Marka Seçilmedi";
  bool _isLoading = false;

  // 🧠 YAPAY ZEKA GÖRÜNTÜ İŞLEME SİMÜLASYONU (Alper'in Motoru)
  Future<void> _yapayZekaIleTani() async {
    _showCyberLoading("AI Parçayı Analiz Ediyor...");
    await Future.delayed(const Duration(seconds: 2)); // İşleme Süresi
    if (!mounted) return;
    Navigator.pop(context); // Loadingi kapat

    setState(() {
      _urunAdController.text = "V Kayışı Gergisi";
      _oemKoduController.text = "FIAT-55268018";
      _secilenMarka = "FIAT Egea";
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text("Kuantum Analizi Tamamlandı: FIAT Egea Parçası Tespit Edildi! 🦅", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      backgroundColor: primaryCyan,
    ));
  }

  // 📸 ŞASİ / BARKOD TARAMA SİMÜLASYONU
  Future<void> _barkodTara() async {
    _showCyberLoading("Ruhsat DNA'sı Çözülüyor...");
    await Future.delayed(const Duration(seconds: 2)); // İşleme Süresi
    if (!mounted) return;
    Navigator.pop(context); // Loadingi kapat

    setState(() {
      _secilenMarka = "BMW 3 Serisi"; // WBA şasi simülasyonu
      _oemKoduController.text = "WBA320I-DNA-2026";
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Şasi DNA'sı Çözüldü: BMW Tespit Edildi! ✅", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      backgroundColor: Colors.blueAccent,
    ));
  }

  // Yükleme Animasyonu (Siber)
  void _showCyberLoading(String mesaj) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), border: Border.all(color: primaryCyan.withOpacity(0.5))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: primaryCyan),
            const SizedBox(height: 16),
            Text(mesaj, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Kuantum Hub Ağı Taranıyor...", style: TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  // FİREBASE'E KAYIT MOTORU
  Future<void> _urunuAgaMuhurle() async {
    if (_urunAdController.text.isEmpty || _fiyatController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Eksik veri girişi tespit edildi!", style: TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _db.collection('yedek_parcalar').add({
        'urun_ad': _urunAdController.text,
        'oem_kodu': _oemKoduController.text,
        'marka': _secilenMarka,
        'fiyat': double.tryParse(_fiyatController.text) ?? 0.0,
        'durum': 'Onaylı/Satışta',
        'ikinci_el_mi': false,
        'eklenme_tarihi': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Ürün Kuantum Ağına Başarıyla Mühürlendi! 🚀", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: primaryCyan));
      Navigator.pop(context); // İşlem bitince ekranı kapat
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ağ Hatası: $e", style: const TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('S İ B E R   İ L A N   T E R M İ N A L İ', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =================================================================
            // 1. YAPAY ZEKA KONTROL PANELİ
            // =================================================================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: primaryCyan.withOpacity(0.3))),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: primaryCyan, size: 24),
                      SizedBox(width: 12),
                      Expanded(child: Text("YAPAY ZEKA (AI) İSTİHBARATI", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: primaryCyan.withOpacity(0.1), foregroundColor: primaryCyan, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: primaryCyan.withOpacity(0.5)))),
                          onPressed: _yapayZekaIleTani,
                          icon: const Icon(Icons.camera_alt_outlined, size: 20),
                          label: const Text("PARÇAYI TANI", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent.withOpacity(0.1), foregroundColor: Colors.blueAccent, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.blueAccent.withOpacity(0.5)))),
                          onPressed: _barkodTara,
                          icon: const Icon(Icons.document_scanner_outlined, size: 20),
                          label: const Text("RUHSAT / ŞASİ", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // =================================================================
            // 2. SİBER VERİ GİRİŞ FORMU
            // =================================================================
            const Text("ÜRÜN KİMLİĞİ", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
            const SizedBox(height: 16),

            _buildCyberTextField("Ürün / Parça Adı", _urunAdController, Icons.build_circle_outlined),
            const SizedBox(height: 16),
            _buildCyberTextField("OEM / Barkod Kodu", _oemKoduController, Icons.qr_code),
            const SizedBox(height: 16),

            // Tespit Edilen Marka Alanı (Sadece Okunabilir gibi tasarladık)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
              child: Row(
                children: [
                  const Icon(Icons.directions_car_outlined, color: Colors.white38, size: 20),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Uyumlu Marka / Model", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(_secilenMarka, style: TextStyle(color: _secilenMarka == "Marka Seçilmedi" ? Colors.white54 : primaryCyan, fontSize: 14, fontWeight: FontWeight.w900)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),

            _buildCyberTextField("Satış Fiyatı (₺)", _fiyatController, Icons.attach_money, isNumber: true),
            const SizedBox(height: 40),

            // =================================================================
            // 3. AĞA MÜHÜRLEME BUTONU
            // =================================================================
            SizedBox(
              width: double.infinity, height: 60,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: primaryCyan, foregroundColor: Colors.black, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: _isLoading ? null : _urunuAgaMuhurle,
                icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)) : const Icon(Icons.publish, size: 24),
                label: Text(_isLoading ? "VERİ AKTARILIYOR..." : "SİBER AĞA MÜHÜRLE", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // 💎 YARDIMCI GİRİŞ KUTUSU BİLEŞENİ
  Widget _buildCyberTextField(String hint, TextEditingController controller, IconData icon, {bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 13),
          prefixIcon: Icon(icon, color: Colors.white38, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}