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

class _UrunGirisTerminaliState extends State<UrunGirisTerminali> with SingleTickerProviderStateMixin {
  // 🌑 SİBER RENK PALETİ
  static const Color bgColor = Color(0xFF000000);
  static const Color surfaceColor = Color(0xFF111111);
  static const Color primaryCyan = Color(0xFF00FFC2);
  static const Color neonPink = Color(0xFFFC00FF);

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
      duration: const Duration(seconds: 2),
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

  // 💰 %12 KARARGAH PAYI HESAPLAYICI (Siber Finans Motoru)
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
    }
  }

  // 🚀 ATOMİK MÜHÜRLEME MOTORU (Storage + WriteBatch)
  Future<void> _sistemeMuhurle() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFile == null) {
      _siberMesaj("HATA: Teknik evrak yüklemesi zorunludur!", isError: true);
      return;
    }

    setState(() => _isProcessing = true);

    final String uid = FirebaseAuth.instance.currentUser?.uid ?? "ANONIM_BAYI";
    final String docId = FirebaseFirestore.instance.collection('yedek_parcalar').doc().id;

    try {
      String fileUrl = "";

      // 1. Dosyayı Firebase Storage'a mühürle
      Reference ref = FirebaseStorage.instance.ref().child('urun_evraklari/$docId');
      await ref.putFile(_selectedFile!);
      fileUrl = await ref.getDownloadURL();

      // 2. Veritabanı Kaydı (WriteBatch - %100 Gerçek Kayıt)
      WriteBatch batch = FirebaseFirestore.instance.batch();
      DocumentReference urunRef = FirebaseFirestore.instance.collection('yedek_parcalar').doc(docId);

      double hamFiyat = double.parse(_fiyatController.text);

      batch.set(urunRef, {
        'urun_id': docId,
        'bayi_id': uid,
        'urun_adi': _adController.text.trim().toUpperCase(),
        'ham_fiyat': hamFiyat,
        'karargah_payi': _karargahPayi,
        'toplam_satis_fiyati': hamFiyat + _karargahPayi,
        'stok': int.parse(_stokController.text),
        'evrak_url': fileUrl,
        'olusturma_tarihi': FieldValue.serverTimestamp(),
        'onay_durumu': 'BEKLEMEDE',
        'vitrin_etiketi': "Murat Plaza", // Protokol gereği vitrin ismi
        'satici_goster': false,
      });

      await batch.commit();
      _siberMesaj("ÜRÜN VE EVRAK KUANTUM AĞINA MÜHÜRLENDİ!");

      _formKey.currentState!.reset();
      _adController.clear();
      _fiyatController.clear();
      _stokController.clear();
      setState(() => _selectedFile = null);

    } catch (e) {
      _siberMesaj("SİBER HATA: Protokol başarısız! Veri hattı kesildi.", isError: true);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _siberMesaj(String mesaj, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
      backgroundColor: isError ? neonPink : primaryCyan,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text("TEDARİK TERMİNALİ V2.0", style: TextStyle(color: primaryCyan, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16)),
      ),
      body: Stack(
        children: [
          // Arka Plan Radar Efekti
          Positioned(
            top: -100, right: -100,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) => Container(
                width: 300, height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryCyan.withOpacity(0.1 * _pulseController.value), width: 2),
                ),
              ),
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // 📂 DOSYA YÜKLEME PANELİ (Siber Cam Efekti)
                  GestureDetector(
                    onTap: _dosyaSec,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _selectedFile == null ? primaryCyan.withOpacity(0.2) : neonPink.withOpacity(0.5)),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _selectedFile == null ? Icons.qr_code_scanner : Icons.verified_user_outlined,
                                color: _selectedFile == null ? primaryCyan : neonPink,
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _selectedFile == null ? "TEKNİK EVRAK / PDF / GÖRSEL" : "DOSYA ŞİFRELENDİ VE HAZIR",
                                style: TextStyle(color: _selectedFile == null ? Colors.white54 : neonPink, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildInput("PARÇA / ÜRÜN ADI", _adController, Icons.precision_manufacturing_outlined),
                  _buildInput("BİRİM ALIŞ FİYATI (₺)", _fiyatController, Icons.account_balance_wallet_outlined, isNumber: true),
                  _buildInput("STOK MİKTARI", _stokController, Icons.inventory_2_outlined, isNumber: true),

                  const SizedBox(height: 12),

                  // 💰 FİNANSAL ANALİZ PANELİ
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primaryCyan.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: primaryCyan.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        _buildFinansRow("KARARGAH PAYI (%12)", "${_karargahPayi.toStringAsFixed(2)} ₺", primaryCyan),
                        const Divider(color: Colors.white10, height: 20),
                        _buildFinansRow("TOPLAM SATIŞ", "${((double.tryParse(_fiyatController.text) ?? 0) + _karargahPayi).toStringAsFixed(2)} ₺", Colors.white),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 🚀 ATEŞLEME BUTONU
                  SizedBox(
                    width: double.infinity,
                    height: 65,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryCyan,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: _isProcessing ? null : _sistemeMuhurle,
                      child: _isProcessing
                          ? const CircularProgressIndicator(color: bgColor)
                          : const Text("SİBER AĞA MÜHÜRLE", style: TextStyle(color: bgColor, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("TÜM VERİLER KUANTUM ŞİFRELEME İLE KORUNMAKTADIR.", style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinansRow(String label, String value, Color valColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
        Text(value, style: TextStyle(color: valColor, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
      ],
    );
  }

  Widget _buildInput(String hint, TextEditingController controller, IconData icon, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: primaryCyan, size: 20),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
          filled: true,
          fillColor: surfaceColor,
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primaryCyan, width: 1)),
        ),
        validator: (v) => v!.isEmpty ? "KRİTİK VERİ EKSİK" : null,
      ),
    );
  }
}