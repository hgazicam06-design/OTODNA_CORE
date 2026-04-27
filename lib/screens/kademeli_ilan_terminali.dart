import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';
import '../core/otodna_mega_protocol.dart'; // Gazi Protokolü Entegrasyonu

class KademeliIlanTerminali extends StatefulWidget {
  const KademeliIlanTerminali({super.key});

  @override
  State<KademeliIlanTerminali> createState() => _KademeliIlanTerminaliState();
}

class _KademeliIlanTerminaliState extends State<KademeliIlanTerminali> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final ImagePicker _picker = ImagePicker();

  int _guncelAdim = 0;
  bool _isProcessing = false;
  bool _veriYukleniyor = true;

  // 🛡️ KUANTUM ABONELİK LİMİTLERİ (GAZİ STANDARTLARI)
  final Map<String, int> _paketLimitleri = {
    'NORMAL': 5,
    'BRONZ': 50,
    'GUMUS': 100,
    'ALTIN': 200,
    'ELMAS': 999999,
  };

  String _kullaniciPaketi = 'NORMAL';
  int _kullaniciIlanSayisi = 0;
  bool _limitAsildiMi = false;

  final TextEditingController _baslikController = TextEditingController();
  final TextEditingController _aciklamaController = TextEditingController();
  final TextEditingController _fiyatController = TextEditingController();
  final TextEditingController _parcaKoduController = TextEditingController();
  File? _secilenGorsel;
  String _seciliKategori = 'Yedek Parça';

  final List<String> _kategoriler = ['Yedek Parça', 'Oto Aksesuar', 'Elektronik / Beyin', 'Kaporta', 'Hasarlı Araç'];

  @override
  void initState() {
    super.initState();
    _siberIstihbaratTopla();
  }

  @override
  void dispose() {
    _baslikController.dispose();
    _aciklamaController.dispose();
    _fiyatController.dispose();
    _parcaKoduController.dispose();
    super.dispose();
  }

  Future<void> _siberIstihbaratTopla() async {
    if (_currentUser == null) return;
    try {
      DocumentSnapshot userDoc = await _db.collection('kullanicilar').doc(_currentUser.uid).get();
      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _kullaniciPaketi = (data['abonelik_paketi'] ?? 'NORMAL').toString().toUpperCase();
          _kullaniciIlanSayisi = (data['aktif_ilan_sayisi'] ?? 0).toInt();
          int izinVerilenLimit = _paketLimitleri[_kullaniciPaketi] ?? 5;
          _limitAsildiMi = _kullaniciIlanSayisi >= izinVerilenLimit;
          _veriYukleniyor = false;
        });
      }
    } catch (e) {
      _siberUyariVer("SİBER HATA: İstihbarat toplanamadı.", isError: true);
      setState(() => _veriYukleniyor = false);
    }
  }

  Future<void> _gorselSec(ImageSource kaynak) async {
    final XFile? foto = await _picker.pickImage(source: kaynak, imageQuality: 70);
    if (foto != null) {
      setState(() => _secilenGorsel = File(foto.path));
    }
  }

  Future<void> _ilaniAgaMuhurle() async {
    if (_limitAsildiMi) {
      _siberUyariVer("LİMİT İHLALİ: Paketinizi yükseltin!", isError: true);
      return;
    }

    if (_baslikController.text.isEmpty || _fiyatController.text.isEmpty) {
      _siberUyariVer("EKSİK VERİ: Tüm kritik alanları doldurun!", isError: true);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      String ilanId = _db.collection('ilanlar').doc().id;
      String gorselUrl = "";

      if (_secilenGorsel != null) {
        TaskSnapshot snapshot = await _storage.ref('ilan_gorselleri/${_currentUser!.uid}/$ilanId.jpg').putFile(_secilenGorsel!);
        gorselUrl = await snapshot.ref.getDownloadURL();
      }

      // 💰 GAZİ PROTOKOLÜ: %12 (10+2) Otomatik Hesaplama
      double hamFiyat = double.tryParse(_fiyatController.text.replaceAll(',', '.')) ?? 0.0;
      double mühürlüFiyat = hamFiyat * (1 + OtodnaMegaProtocol.karargahPayi);

    WriteBatch batch = _db.batch();
    DocumentReference ilanRef = _db.collection('ilanlar').doc(ilanId);

    batch.set(ilanRef, {
    'ilan_id': ilanId,
    'satici_id': _currentUser!.uid,
    'baslik': _baslikController.text.trim().toUpperCase(),
    'aciklama': _aciklamaController.text.trim(),
    'parca_kodu': _parcaKoduController.text.trim().toUpperCase(),
    'kategori': _seciliKategori,
    'fiyat_ham': hamFiyat,
    'fiyat': mühürlüFiyat, // Vitrin fiyatı
    'gorsel_url': gorselUrl,
    'aktif_mi': true,
    'yayin_tarihi': FieldValue.serverTimestamp(),
    });

    DocumentReference userRef = _db.collection('kullanicilar').doc(_currentUser!.uid);
    batch.update(userRef, {'aktif_ilan_sayisi': FieldValue.increment(1)});

    await batch.commit();

    if (!mounted) return;
    _siberUyariVer("İŞLEM BAŞARILI: İlan Kuantum Ağına Mühürlendi!", isError: false);
    Navigator.pop(context);

    } catch (e) {
    _siberUyariVer("SİSTEM ÇÖKTÜ: $e", isError: true);
    setState(() => _isProcessing = false);
    }
  }

  void _siberUyariVer(String mesaj, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: const TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'monospace')),
      backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_veriYukleniyor) return const Scaffold(backgroundColor: SiberTema.oledBlack, body: Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan)));

    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: SiberTema.kuantumCyan), onPressed: () => Navigator.pop(context)),
          title: const Text("İLAN TERMİNALİ V4", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 3, fontFamily: 'monospace')),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Column(
              children: [
                _buildLimitKalkan(),
                Expanded(
                  child: Theme(
                    data: Theme.of(context).copyWith(colorScheme: const ColorScheme.dark(primary: SiberTema.kuantumCyan)),
                    child: Stepper(
                      type: StepperType.vertical,
                      currentStep: _guncelAdim,
                      onStepContinue: () => _guncelAdim < 2 ? setState(() => _guncelAdim++) : _ilaniAgaMuhurle(),
                      onStepCancel: () => _guncelAdim > 0 ? setState(() => _guncelAdim--) : null,
                      steps: [
                        _buildStepKimlik(),
                        _buildStepGorsel(),
                        _buildStepFinans(),
                      ],
                      controlsBuilder: (context, details) => _buildStepperKontrol(details),
                    ),
                  ),
                ),
              ],
            ),
            if (_isProcessing) Container(color: Colors.white54, child: const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan))),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitKalkan() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _limitAsildiMi ? SiberTema.kanKirmizi.withOpacity(0.1) : SiberTema.kuantumCyan.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _limitAsildiMi ? SiberTema.kanKirmizi : SiberTema.kuantumCyan, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("PAKET: $_kullaniciPaketi", style: const TextStyle(color: SiberTema.textMain, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          Text("LİMİT: $_kullaniciIlanSayisi / ${_paketLimitleri[_kullaniciPaketi] == 999999 ? '∞' : _paketLimitleri[_kullaniciPaketi]}",
              style: TextStyle(color: _limitAsildiMi ? SiberTema.kanKirmizi : SiberTema.kuantumCyan, fontWeight: FontWeight.w900, fontSize: 12)),
        ],
      ),
    );
  }

  Step _buildStepKimlik() {
    return Step(
      title: const Text("KİMLİK VERİLERİ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      isActive: _guncelAdim >= 0,
      content: Column(
        children: [
          _siberInput("İLAN BAŞLIĞI", _baslikController),
          const SizedBox(height: 10),
          _siberInput("OEM / PARÇA KODU", _parcaKoduController),
        ],
      ),
    );
  }

  Step _buildStepGorsel() {
    return Step(
      title: const Text("GÖRSEL KANIT", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      isActive: _guncelAdim >= 1,
      content: Column(
        children: [
          if (_secilenGorsel != null) Image.file(_secilenGorsel!, height: 100, fit: BoxFit.cover),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () => _gorselSec(ImageSource.camera), child: const Text("KAMERA"))),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton(onPressed: () => _gorselSec(ImageSource.gallery), child: const Text("GALERİ"))),
            ],
          ),
        ],
      ),
    );
  }

  Step _buildStepFinans() {
    return Step(
      title: const Text("FİNANS VE MÜHÜR", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      isActive: _guncelAdim >= 2,
      content: Column(
        children: [
          _siberInput("HAM FİYAT (₺)", _fiyatController, isNumeric: true),
          const SizedBox(height: 10),
          _siberInput("DETAYLI AÇIKLAMA", _aciklamaController, lines: 3),
        ],
      ),
    );
  }

  Widget _siberInput(String label, TextEditingController ctrl, {bool isNumeric = false, int lines = 1}) {
    return SiberTema.siberCamKalkan(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TextField(
        controller: ctrl,
        maxLines: lines,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: SiberTema.textMain, fontSize: 12),
        decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: SiberTema.textMuted, fontSize: 10), border: InputBorder.none),
      ),
    );
  }

  Widget _buildStepperKontrol(ControlsDetails details) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        children: [
          Expanded(child: ElevatedButton(onPressed: details.onContinue, child: Text(_guncelAdim == 2 ? "MÜHÜRLE" : "İLERLE"))),
          if (_guncelAdim > 0) ...[const SizedBox(width: 10), Expanded(child: OutlinedButton(onPressed: details.onCancel, child: const Text("GERİ")))],
        ],
      ),
    );
  }
}