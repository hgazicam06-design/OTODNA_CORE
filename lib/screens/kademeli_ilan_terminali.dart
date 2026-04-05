import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

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

  // 🛡️ KUANTUM ABONELİK LİMİTLERİ
  final Map<String, int> _paketLimitleri = {
    'NORMAL': 5,
    'BRONZ': 50,
    'GUMUS': 100,
    'ALTIN': 200,
    'ELMAS': 999999, // Sınırsız Kalkanı
  };

  String _kullaniciPaketi = 'NORMAL';
  int _kullaniciIlanSayisi = 0;
  bool _limitAsildiMi = false;

  // 📝 İLAN VERİ HAFIZASI
  final TextEditingController _baslikController = TextEditingController();
  final TextEditingController _aciklamaController = TextEditingController();
  final TextEditingController _fiyatController = TextEditingController();
  final TextEditingController _parcaKoduController = TextEditingController(); // Akıllı arama için
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

  // --- 🔴 FİREBASE: CANLI LİMİT VE PAKET KONTROLÜ ---
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
      _siberUyariVer("İstihbarat Hatası: Kullanıcı verisi okunamadı.", isError: true);
      setState(() => _veriYukleniyor = false);
    }
  }

  // --- 📸 SİBER GÖRSEL MOTORU (Manuel veya Akıllı Arama) ---
  Future<void> _gorselSec(ImageSource kaynak) async {
    final XFile? foto = await _picker.pickImage(source: kaynak, imageQuality: 75);
    if (foto != null) {
      setState(() => _secilenGorsel = File(foto.path));
    }
  }

  Future<void> _akilliGoogleAramaTetikle() async {
    if (_parcaKoduController.text.trim().isEmpty) {
      _siberUyariVer("SİBER İHLAL: Akıllı arama için Parça Kodu veya OEM numarası girmelisiniz!", isError: true);
      return;
    }

    // TODO: İleride Google Custom Search API veya PDF Crawler bağlanacak.
    // Şimdilik Kuantum Radar animasyonuyla simüle ediyoruz.
    setState(() => _isProcessing = true);
    _siberUyariVer("KUANTUM AĞI: İnternette görsel aranıyor...", isError: false);

    await Future.delayed(const Duration(seconds: 2)); // API bekleme simülasyonu

    setState(() {
      _isProcessing = false;
      // İleride burası internetten gelen URL olacak, şimdilik uyarı veriyoruz
    });
    _siberUyariVer("GÖRSEL BULUNDU VE MÜHÜRLENDİ! (API Bağlanacak)", isError: false);
  }

  // --- ⚛️ FİREBASE ATOMİK YAZMA (WRITEBATCH) ---
  Future<void> _ilaniAgaMuhurle() async {
    if (_limitAsildiMi) {
      _siberUyariVer("LİMİT DOLDU! Yeni ilan girmek için paketinizi yükseltin.", isError: true);
      return;
    }

    if (_baslikController.text.trim().isEmpty || _fiyatController.text.trim().isEmpty) {
      _siberUyariVer("SİBER İHLAL: Başlık ve Fiyat alanları zorunludur!", isError: true);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      String ilanId = _db.collection('ilanlar').doc().id;
      String gorselUrl = "";

      // 1. Görsel varsa Storage'a ateşle
      if (_secilenGorsel != null) {
        TaskSnapshot snapshot = await _storage.ref('ilan_gorselleri/${_currentUser!.uid}/$ilanId.jpg').putFile(_secilenGorsel!);
        gorselUrl = await snapshot.ref.getDownloadURL();
      }

      // 2. Fiyatı Temizle (Virgül ve nokta karışıklığını çözer)
      double fiyat = double.tryParse(_fiyatController.text.replaceAll(',', '.')) ?? 0.0;

      // 3. WriteBatch ile hem ilanı ekle hem de kullanıcının ilan sayısını artır (Ya hep ya hiç!)
      WriteBatch batch = _db.batch();

      DocumentReference ilanRef = _db.collection('ilanlar').doc(ilanId);
      batch.set(ilanRef, {
        'ilan_id': ilanId,
        'satici_id': _currentUser!.uid,
        'baslik': _baslikController.text.trim(),
        'aciklama': _aciklamaController.text.trim(),
        'parca_kodu': _parcaKoduController.text.trim(),
        'kategori': _seciliKategori,
        'fiyat': fiyat,
        'gorsel_url': gorselUrl,
        'aktif_mi': true,
        'yayin_tarihi': FieldValue.serverTimestamp(),
      });

      DocumentReference userRef = _db.collection('kullanicilar').doc(_currentUser!.uid);
      batch.update(userRef, {
        'aktif_ilan_sayisi': FieldValue.increment(1),
      });

      await batch.commit();

      if (!mounted) return;
      _siberUyariVer("VİTRİN GÜNCELLENDİ: İlanınız Kuantum Ağına İşlendi!", isError: false);
      Navigator.pop(context); // İşlem başarılı, ekrandan çık

    } catch (e) {
      _siberUyariVer("SİBER HATA: İşlem çöktü -> $e", isError: true);
      setState(() => _isProcessing = false);
    }
  }

  void _siberUyariVer(String mesaj, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: TextStyle(color: isError ? Colors.white : SiberTema.oledBlack, fontWeight: FontWeight.bold, fontFamily: 'Avenir', fontSize: 12)),
      backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_veriYukleniyor) {
      return Scaffold(
        backgroundColor: SiberTema.oledBlack,
        body: const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan, strokeWidth: 3)),
      );
    }

    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: SiberTema.kuantumCyan), onPressed: () => Navigator.pop(context)),
          title: Text("AKILLI İLAN TERMİNALİ", style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2, fontFamily: 'Avenir')),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/radar_grid.png'), fit: BoxFit.cover, opacity: 0.05)),
              child: Column(
                children: [
                  // ── 1. SİBER LİMİT KALKANI EKRANI ──
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_limitAsildiMi ? SiberTema.kanKirmizi.withOpacity(0.2) : SiberTema.matGrey.withOpacity(0.8), SiberTema.oledBlack]),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _limitAsildiMi ? SiberTema.kanKirmizi : SiberTema.kuantumCyan.withOpacity(0.5), width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("MEVCUT PAKET: $_kullaniciPaketi", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Avenir', letterSpacing: 1)),
                            const SizedBox(height: 4),
                            Text("KULLANILAN LİMİT", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9, fontFamily: 'Avenir')),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: _limitAsildiMi ? SiberTema.kanKirmizi : SiberTema.kuantumCyan.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                          child: Text(
                              "$_kullaniciIlanSayisi / ${_paketLimitleri[_kullaniciPaketi] == 999999 ? '∞' : _paketLimitleri[_kullaniciPaketi]}",
                              style: TextStyle(color: _limitAsildiMi ? SiberTema.oledBlack : SiberTema.kuantumCyan, fontWeight: FontWeight.w900, fontSize: 16, fontFamily: 'Avenir')
                          ),
                        )
                      ],
                    ),
                  ),

                  // ── 2. KADEMELİ (STEPPER) VERİ GİRİŞ MOTORU ──
                  Expanded(
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.dark(primary: SiberTema.kuantumCyan, onSurface: Colors.white),
                        canvasColor: Colors.transparent,
                      ),
                      child: Stepper(
                        type: StepperType.vertical,
                        currentStep: _guncelAdim,
                        physics: const BouncingScrollPhysics(),
                        onStepTapped: (step) => setState(() => _guncelAdim = step),
                        onStepContinue: () {
                          if (_guncelAdim < 2) {
                            setState(() => _guncelAdim += 1);
                          } else {
                            _ilaniAgaMuhurle(); // Son adımda veritabanına ateşle
                          }
                        },
                        onStepCancel: () {
                          if (_guncelAdim > 0) setState(() => _guncelAdim -= 1);
                        },
                        controlsBuilder: (context, details) {
                          bool isSonAdim = _guncelAdim == 2;
                          return Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isSonAdim ? SiberTema.altinSari : SiberTema.kuantumCyan,
                                      foregroundColor: SiberTema.oledBlack,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: _limitAsildiMi ? null : details.onContinue,
                                    child: Text(isSonAdim ? "SİSTEME MÜHÜRLE" : "İLERLE", style: const TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 1)),
                                  ),
                                ),
                                if (_guncelAdim > 0) ...[
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white54,
                                        side: const BorderSide(color: Colors.white24),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      onPressed: details.onCancel,
                                      child: const Text("GERİ DÖN", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          );
                        },
                        steps: [
                          // ADIM 1: TEMEL İSTİHBARAT
                          Step(
                            title: const Text("TEMEL BİLGİLER", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                            subtitle: const Text("İlanın başlığı ve kategorisi", style: TextStyle(color: Colors.white54, fontSize: 10)),
                            isActive: _guncelAdim >= 0,
                            state: _guncelAdim > 0 ? StepState.complete : StepState.indexed,
                            content: Column(
                              children: [
                                SiberTema.siberCamKalkan(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      dropdownColor: SiberTema.matGrey,
                                      value: _seciliKategori,
                                      items: _kategoriler.map((kat) => DropdownMenuItem(value: kat, child: Text(kat, style: const TextStyle(color: Colors.white, fontFamily: 'Avenir')))).toList(),
                                      onChanged: (val) => setState(() => _seciliKategori = val!),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SiberTema.siberCamKalkan(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: TextField(
                                    controller: _baslikController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(labelText: "İlan Başlığı", labelStyle: TextStyle(color: SiberTema.kuantumCyan), border: InputBorder.none),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ADIM 2: AKILLI GÖRSEL MOTORU
                          Step(
                            title: const Text("GÖRSEL İSTİHBARATI", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                            subtitle: const Text("Kamera, Galeri veya Kuantum Arama", style: TextStyle(color: Colors.white54, fontSize: 10)),
                            isActive: _guncelAdim >= 1,
                            state: _guncelAdim > 1 ? StepState.complete : StepState.indexed,
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_secilenGorsel != null)
                                  Container(
                                    height: 150,
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), image: DecorationImage(image: FileImage(_secilenGorsel!), fit: BoxFit.cover)),
                                  ),
                                Row(
                                  children: [
                                    Expanded(child: OutlinedButton.icon(onPressed: () => _gorselSec(ImageSource.camera), icon: const Icon(Icons.camera_alt, color: SiberTema.kuantumCyan), label: const Text("Kamera", style: TextStyle(color: Colors.white)))),
                                    const SizedBox(width: 8),
                                    Expanded(child: OutlinedButton.icon(onPressed: () => _gorselSec(ImageSource.gallery), icon: const Icon(Icons.photo, color: SiberTema.kuantumCyan), label: const Text("Galeri", style: TextStyle(color: Colors.white)))),
                                  ],
                                ),
                                const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.white24)),
                                const Text("SİBER ARAMA (Google/PDF Hub)", style: TextStyle(color: SiberTema.altinSari, fontWeight: FontWeight.bold, fontSize: 10, fontFamily: 'Avenir', letterSpacing: 1)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: SiberTema.siberCamKalkan(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: TextField(
                                          controller: _parcaKoduController,
                                          style: const TextStyle(color: Colors.white),
                                          decoration: const InputDecoration(hintText: "OEM / Parça Kodu", hintStyle: TextStyle(color: Colors.white30), border: InputBorder.none),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      decoration: BoxDecoration(color: SiberTema.altinSari.withOpacity(0.2), borderRadius: BorderRadius.circular(10), border: Border.all(color: SiberTema.altinSari)),
                                      child: IconButton(icon: const Icon(Icons.travel_explore, color: SiberTema.altinSari), onPressed: _akilliGoogleAramaTetikle),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),

                          // ADIM 3: FİYAT VE AÇIKLAMA
                          Step(
                            title: const Text("MÜHÜR VE FİYATLANDIRMA", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                            subtitle: const Text("Satış detayları", style: TextStyle(color: Colors.white54, fontSize: 10)),
                            isActive: _guncelAdim >= 2,
                            content: Column(
                              children: [
                                SiberTema.siberCamKalkan(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: TextField(
                                    controller: _fiyatController,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 24, fontWeight: FontWeight.bold),
                                    decoration: const InputDecoration(labelText: "Fiyat (₺)", labelStyle: TextStyle(color: Colors.white54, fontSize: 12), border: InputBorder.none),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SiberTema.siberCamKalkan(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: TextField(
                                    controller: _aciklamaController,
                                    maxLines: 3,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(labelText: "Açıklama / Kondisyon", labelStyle: TextStyle(color: SiberTema.kuantumCyan), border: InputBorder.none),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // İŞLEM BEKLEME KALKANI
            if (_isProcessing)
              Container(
                color: SiberTema.oledBlack.withOpacity(0.8),
                child: const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan, strokeWidth: 3)),
              )
          ],
        ),
      ),
    );
  }
}