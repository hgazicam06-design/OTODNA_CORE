import 'package:otodna/core/siber_tema.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:developer' as developer; // 🚀 SİBER LOGLAMA İÇİN EKLENDİ

// 🚀 KARARGAH ZIRHLARI
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

class UrunGirisTerminali extends StatefulWidget {
  UrunGirisTerminali({super.key});

  @override
  State<UrunGirisTerminali> createState() => _UrunGirisTerminaliState();
}

class _UrunGirisTerminaliState extends State<UrunGirisTerminali> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _adController = TextEditingController();
  final TextEditingController _fiyatController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();

  bool _isProcessing = false;
  File? _selectedFile;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _adController.dispose();
    _fiyatController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  // 💰 %12 KARARGAH PAYI HESAPLAYICI (Finansal Strateji)
  double get _karargahPayi => (double.tryParse(_fiyatController.text) ?? 0) * 0.12;

  // 📂 SİBER DOSYA SEÇİCİ
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
      developer.log("SİBER RADAR: Yeni bir tedarik evrakı tarandı.");
    }
  }

  // 🚀 ATOMİK MÜHÜRLEME MOTORU (Storage + WriteBatch + Kara Kutu)
  Future<void> _sistemeMuhurle() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFile == null) {
      _siberMesaj("HATA: Teknik evrak yüklemesi zorunludur!", isError: true);
      return;
    }

    setState(() => _isProcessing = true);

    final String uid = FirebaseAuth.instance.currentUser?.uid ?? "ANONIM_BAYI";
    final String docId = FirebaseFirestore.instance.collection('yedek_parcalar').doc().id;
    final String urunAdiSiber = _adController.text.trim().toUpperCase();

    try {
      developer.log("SİBER HAREKAT: $urunAdiSiber için Kuantum mühürleme başlatıldı...");

      // 1. Dosyayı Firebase Storage'a mühürle
      Reference ref = FirebaseStorage.instance.ref().child('urun_evraklari/$docId');
      await ref.putFile(_selectedFile!);
      String fileUrl = await ref.getDownloadURL();

      // 2. Veritabanı Kaydı (WriteBatch - %100 Gerçek Kayıt)
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Ürün Verisi
      DocumentReference urunRef = FirebaseFirestore.instance.collection('yedek_parcalar').doc(docId);
      double hamFiyat = double.parse(_fiyatController.text);

      batch.set(urunRef, {
        'urun_id': docId,
        'bayi_id': uid,
        'urun_adi': urunAdiSiber,
        'ham_fiyat': hamFiyat,
        'karargah_payi': _karargahPayi,
        'toplam_satis_fiyati': hamFiyat + _karargahPayi,
        'stok': int.parse(_stokController.text),
        'evrak_url': fileUrl,
        'olusturma_tarihi': FieldValue.serverTimestamp(),
        'onay_durumu': 'BEKLEMEDE',
        'vitrin_etiketi': "Murat Plaza", // Karargah Gizlilik Kuralı
        'satici_goster': false,
      });

      // 🚨 SİBER YAMA: Kara Kutuya (Sistem Loglarına) Otonom Loglama
      DocumentReference logRef = FirebaseFirestore.instance.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'YENI_TEDARIK_GIRISI',
        'islem_detayi': 'SİBER BİLGİ: $uid ID\'li yetkili "$urunAdiSiber" mühimmatını Karargah stoklarına yükledi.',
        'tarih': FieldValue.serverTimestamp(),
      });

      // Füzeleri Ateşle!
      await batch.commit();
      developer.log("SİBER ONAY: ✅ Ürün başarıyla kasaya kilitlendi ve loglandı!");
      _siberMesaj("ÜRÜN VE EVRAK KUANTUM AĞINA MÜHÜRLENDİ!");

      _formKey.currentState!.reset();
      _adController.clear();
      _fiyatController.clear();
      _stokController.clear();
      setState(() => _selectedFile = null);

      if (mounted) Navigator.pop(context);

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Tedarik terminali arızalandı!", error: e);
      _siberMesaj("SİBER HATA: Protokol başarısız! Ağınızı kontrol edin.", isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _siberMesaj(String mesaj, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.bold)),
      backgroundColor: isError ? SiberTema.kritikRed : SiberTema.kuantumCyan,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      child: Scaffold(
        backgroundColor: SiberTema.oledBlack,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text("TEDARİK TERMİNALİ V2.0", style: SiberTema.kuantumBaslik.copyWith(fontSize: 16)),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildEvrakAlani(),
                SizedBox(height: 24),
                _buildSiberInput(_adController, "PARÇA / ÜRÜN ADI", Icons.precision_manufacturing),
                _buildSiberInput(_fiyatController, "BİRİM ALIŞ FİYATI (₺)", Icons.payments, isNumber: true),
                _buildSiberInput(_stokController, "STOK MİKTARI", Icons.inventory, isNumber: true),
                SizedBox(height: 12),
                _buildFinansPaneli(),
                SizedBox(height: 40),
                _buildAteslemeButonu(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEvrakAlani() {
    return GestureDetector(
      onTap: _dosyaSec,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(40),
        decoration: SiberTema.siberCamZirh(),
        child: Column(
          children: [
            Icon(
              _selectedFile == null ? Icons.cloud_upload_outlined : Icons.verified_outlined,
              color: SiberTema.kuantumCyan,
              size: 50,
            ),
            SizedBox(height: 12),
            Text(
              _selectedFile == null ? "TEKNİK EVRAK / GÖRSEL YÜKLE" : "EVRAK HAZIR",
              style: TextStyle(color: SiberTema.kuantumCyan.withValues(alpha: 0.7), fontWeight: FontWeight.bold, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinansPaneli() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SiberTema.kuantumCyan.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SiberTema.kuantumCyan.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _buildRow("KARARGAH PAYI (%12)", "${_karargahPayi.toStringAsFixed(2)} ₺", SiberTema.kuantumCyan),
          Divider(color: Colors.white10),
          _buildRow("TOPLAM SATIŞ", "${((double.tryParse(_fiyatController.text) ?? 0) + _karargahPayi).toStringAsFixed(2)} ₺", Colors.white),
        ],
      ),
    );
  }

  Widget _buildRow(String l, String v, Color c) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l, style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
        Text(v, style: TextStyle(color: c, fontSize: 16, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildSiberInput(TextEditingController c, String h, IconData i, {bool isNumber = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: TextStyle(color: Colors.white, fontSize: 14),
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          prefixIcon: Icon(i, color: SiberTema.kuantumCyan, size: 20),
          hintText: h,
          hintStyle: TextStyle(color: Colors.white24, fontSize: 12),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.03),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white10)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: SiberTema.kuantumCyan)),
        ),
        validator: (v) => v!.isEmpty ? "EKSİK VERİ" : null,
      ),
    );
  }

  Widget _buildAteslemeButonu() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: SiberTema.kuantumButonStili(),
        onPressed: _isProcessing ? null : _sistemeMuhurle,
        child: _isProcessing
            ? CircularProgressIndicator(color: SiberTema.oledBlack)
            : Text("SİBER AĞA MÜHÜRLE", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
      ),
    );
  }
}
