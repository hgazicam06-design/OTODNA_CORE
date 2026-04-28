import 'package:otodna/core/siber_tema.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:ui';

import '../../core/siber_tema.dart'; // 🚀 SİBER KÖPRÜ

class UrunGirisTerminali extends StatefulWidget {
  UrunGirisTerminali({super.key});

  @override
  State<UrunGirisTerminali> createState() => _UrunGirisTerminaliState();
}

class _UrunGirisTerminaliState extends State<UrunGirisTerminali> {
  // 🌑 SİBER RENK PALETİ (SiberTema'dan besleniyor)
  static Color primaryCyan = SiberTema.kuantumCyan;
  static Color neonPink = SiberTema.kanKirmizi; // Veya Neon Pembe eklenebilir

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
      content: Text(mesaj, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
      backgroundColor: isError ? neonPink : primaryCyan,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. KUANTUM ARKA PLAN
          Positioned.fill(child: Container(decoration: SiberTema.siberArkaPlan)),

          // 2. ANA İÇERİK
          SafeArea(
            child: Column(
              children: [
                _buildSiberAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24),
                    physics: BouncingScrollPhysics(),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildDosyaYuklemePaneli(),
                          SizedBox(height: 24),
                          _buildInput("Ürün Adı", _adController, Icons.shopping_bag_outlined),
                          _buildInput("Birim Fiyat (₺)", _fiyatController, Icons.monetization_on_outlined, isNumber: true),
                          _buildInput("Stok Adedi", _stokController, Icons.inventory_outlined, isNumber: true),
                          SizedBox(height: 16),
                          _buildSiberPanel(
                            color: primaryCyan.withOpacity(0.1),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("KARARGAH PAYI (%12):", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                                Text("${_karargahPayi.toStringAsFixed(2)} ₺", style: TextStyle(color: primaryCyan, fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                              ],
                            ),
                          ),
                          SizedBox(height: 32),
                          _buildAteslemeButonu(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiberAppBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), border: Border(bottom: BorderSide(color: Colors.white10))),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle), child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18)),
              ),
              Expanded(child: Center(child: Text('TEDARİK TERMİNALİ V2', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 3, fontFamily: 'Avenir')))),
              SizedBox(width: 40), // Ortalama dengesi için
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDosyaYuklemePaneli() {
    return _buildSiberPanel(
      child: InkWell(
        onTap: _dosyaSec,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(Icons.picture_as_pdf_outlined, color: _selectedFile == null ? primaryCyan : neonPink, size: 48),
              SizedBox(height: 16),
              Text(_selectedFile == null ? "PDF VEYA GÖRSEL YÜKLE" : "DOSYA SİBER AĞA ALINDI", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
              if (_selectedFile != null)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(_selectedFile!.path.split('/').last, style: TextStyle(color: Colors.white54, fontSize: 10, fontFamily: 'Avenir')),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSiberPanel({required Widget child, Color? color}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color ?? Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color != null ? color.withOpacity(0.5) : Colors.white10),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildInput(String hint, TextEditingController controller, IconData icon, {bool isNumber = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: TextFormField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: TextStyle(color: Colors.white, fontFamily: 'Avenir', fontSize: 14),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: primaryCyan, size: 20),
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white24, fontFamily: 'Avenir', fontSize: 13),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white10)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: primaryCyan)),
            ),
            validator: (v) => v!.isEmpty ? "ZORUNLU ALAN" : null,
          ),
        ),
      ),
    );
  }

  Widget _buildAteslemeButonu() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryCyan,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 10,
          shadowColor: primaryCyan.withOpacity(0.3),
        ),
        onPressed: _isProcessing ? null : _sistemeMuhurle,
        child: _isProcessing 
          ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)) 
          : Text("SİSTEME MÜHÜRLE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir', fontSize: 12)),
      ),
    );
  }
}