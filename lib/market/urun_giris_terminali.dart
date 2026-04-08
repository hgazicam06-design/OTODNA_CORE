import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:ui';

class UrunGirisTerminali extends StatefulWidget {
  const UrunGirisTerminali({super.key});

  @override
  State<UrunGirisTerminali> createState() => _UrunGirisTerminaliState();
}

class _UrunGirisTerminaliState extends State<UrunGirisTerminali> {
  // 🌑 SİBER RENK PALETİ
  static const Color bgColor = Color(0xFF000000);
  static const Color primaryCyan = Color(0xFF00FFC2);
  static const Color neonPink = Color(0xFFFC00FF);

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _adController = TextEditingController();
  final TextEditingController _fiyatController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();

  bool _isProcessing = false;
  File? _selectedFile;

  // 💰 %12 KARARGAH PAYI HESAPLAYICI
  double get _karargahPayi => (double.tryParse(_fiyatController.text) ?? 0) * 0.12;

  // 📂 SİBER DOSYA SEÇİCİ (PDF veya Görsel)
  Future<void> _dosyaSec() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
      _siberMesaj("DOSYA ANALİZ İÇİN YÜKLENDİ. AI MOTORU TETİKLENİYOR...");
      // Burada ileride Google Cloud Vision / Document AI fonksiyonu çağrılacak.
    }
  }

  // 🚀 ATOMİK MÜHÜRLEME MOTORU (Firebase Storage + Firestore WriteBatch)
  Future<void> _sistemeMuhurle() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isProcessing = true);

    final String uid = FirebaseAuth.instance.currentUser?.uid ?? "ANONIM_BAYI";
    final String docId = FirebaseFirestore.instance.collection('urunler').doc().id;

    try {
      String fileUrl = "";
      // 1. Dosyayı Firebase Storage'a mühürle
      if (_selectedFile != null) {
        Reference ref = FirebaseStorage.instance.ref().child('urun_evraklari/$docId');
        await ref.putFile(_selectedFile!);
        fileUrl = await ref.getDownloadURL();
      }

      // 2. Veritabanı Kaydı (WriteBatch)
      WriteBatch batch = FirebaseFirestore.instance.batch();
      DocumentReference urunRef = FirebaseFirestore.instance.collection('urunler').doc(docId);

      double hamFiyat = double.parse(_fiyatController.text);

      batch.set(urunRef, {
        'urun_id': docId,
        'bayi_id': uid,
        'urun_adi': _adController.text.trim(),
        'ham_fiyat': hamFiyat,
        'karargah_payi': _karargahPayi,
        'toplam_satis_fiyati': hamFiyat + _karargahPayi,
        'stok': int.parse(_stokController.text),
        'evrak_url': fileUrl,
        'olusturma_tarihi': FieldValue.serverTimestamp(),
        'onay_durumu': 'BEKLEMEDE',
      });

      await batch.commit();
      _siberMesaj("ÜRÜN VE EVRAK BAŞARIYLA MÜHÜRLENDİ!");
      _formKey.currentState!.reset();
      setState(() => _selectedFile = null);
    } catch (e) {
      _siberMesaj("SİBER HATA: İşlem başarısız!", isError: true);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _siberMesaj(String mesaj, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      backgroundColor: isError ? neonPink : primaryCyan,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(backgroundColor: Colors.transparent, title: const Text("TEDARİK TERMİNALİ V2", style: TextStyle(color: primaryCyan))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildSiberPanel(
                child: Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.picture_as_pdf_outlined, color: _selectedFile == null ? primaryCyan : neonPink, size: 50),
                      onPressed: _dosyaSec,
                    ),
                    Text(_selectedFile == null ? "PDF veya GÖRSEL YÜKLE" : "DOSYA HAZIR", style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildInput("Ürün Adı", _adController, Icons.shopping_bag_outlined),
              _buildInput("Birim Fiyat (₺)", _fiyatController, Icons.monetization_on_outlined, isNumber: true),
              _buildInput("Stok Adedi", _stokController, Icons.inventory_outlined, isNumber: true),
              const SizedBox(height: 10),
              _buildSiberPanel(
                color: primaryCyan.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("KARARGAH PAYI (%12):", style: TextStyle(color: Colors.white70)),
                    Text("${_karargahPayi.toStringAsFixed(2)} ₺", style: const TextStyle(color: primaryCyan, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildAteslemeButonu(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSiberPanel({required Widget child, Color? color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color ?? Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryCyan.withOpacity(0.2)),
      ),
      child: child,
    );
  }

  Widget _buildInput(String hint, TextEditingController controller, IconData icon, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: primaryCyan),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        validator: (v) => v!.isEmpty ? "ZORUNLU ALAN" : null,
      ),
    );
  }

  Widget _buildAteslemeButonu() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: primaryCyan, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        onPressed: _isProcessing ? null : _sistemeMuhurle,
        child: _isProcessing ? const CircularProgressIndicator(color: bgColor) : const Text("SİSTEME MÜHÜRLE", style: TextStyle(color: bgColor, fontWeight: FontWeight.bold)),
      ),
    );
  }
}