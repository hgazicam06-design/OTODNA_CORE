import 'package:otodna/core/siber_tema.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AracKayitStepperScreen extends StatefulWidget {
  AracKayitStepperScreen({super.key});

  @override
  State<AracKayitStepperScreen> createState() => _AracKayitStepperScreenState();
}

class _AracKayitStepperScreenState extends State<AracKayitStepperScreen> {
  int _aktifAdim = 0;
  bool _isSaving = false;

  // 1. ADIM KONTROLCÜLERİ (ARAÇ KİMLİĞİ)
  final TextEditingController _plakaController = TextEditingController();
  final TextEditingController _markaController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yilController = TextEditingController();

  // 2. ADIM KONTROLCÜLERİ (EKSPERTİZ & DURUM)
  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _durumController = TextEditingController();
  final TextEditingController _dnaSkoruController = TextEditingController();

  // 3. ADIM KONTROLCÜLERİ (SATIŞ & FİYAT)
  final TextEditingController _fiyatController = TextEditingController();
  final TextEditingController _lokasyonController = TextEditingController();
  final TextEditingController _aciklamaController = TextEditingController();

  @override
  void dispose() {
    _plakaController.dispose(); _markaController.dispose(); _modelController.dispose(); _yilController.dispose();
    _kmController.dispose(); _durumController.dispose(); _dnaSkoruController.dispose();
    _fiyatController.dispose(); _lokasyonController.dispose(); _aciklamaController.dispose();
    super.dispose();
  }

  // ========================================================================
  // 🚀 FİREBASE SAAS LİMİT VE KAYIT MOTORU 🌟
  // ========================================================================
  Future<void> _araciKuantumAginaKaydet() async {
    if (_plakaController.text.isEmpty || _markaController.text.isEmpty || _fiyatController.text.isEmpty) {
      _showSnackBar("Plaka, Marka ve Fiyat zorunludur!", isError: true);
      return;
    }

    setState(() => _isSaving = true);
    FocusScope.of(context).unfocus();

    try {
      String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

      // 1. SİBER SAAS KONTROLÜ: Kullanıcının limitlerini veritabanından çek!
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('kullanicilar').doc(currentUserUid).get();
      if (!userDoc.exists) throw Exception("Siber Kimlik Bulunamadı!");

      var userData = userDoc.data() as Map<String, dynamic>;
      bool isVip = userData['is_vip'] ?? false;
      int kullanilanIlan = userData['kullanilan_ilan_sayisi'] ?? 0;
      int maxLimit = isVip ? -1 : 10; // VIP ise -1 (Sınırsız), değilse 10

      // 🚨 ÖDEME DUVARI (PAYWALL): Limit dolmuşsa işlemi durdur!
      if (!isVip && kullanilanIlan >= maxLimit) {
        setState(() => _isSaving = false);
        _showPaywall();
        return;
      }

      // 2. HER ŞEY TEMİZ: Aracı Veritabanına Beton Gibi Dök (WriteBatch ile Atomik Kayıt)
      String plakaID = _plakaController.text.trim().replaceAll(" ", "").toUpperCase();
      WriteBatch batch = FirebaseFirestore.instance.batch();

      DocumentReference aracRef = FirebaseFirestore.instance.collection('vehicles').doc(plakaID);
      batch.set(aracRef, {
        "plaka": plakaID,
        "marka": _markaController.text.trim(),
        "model": _modelController.text.trim(),
        "yil": int.tryParse(_yilController.text.trim()) ?? 2023,
        "km": int.tryParse(_kmController.text.trim()) ?? 0,
        "durum": _durumController.text.trim().isEmpty ? "Kusursuz" : _durumController.text.trim(),
        "dna_skoru": int.tryParse(_dnaSkoruController.text.trim()) ?? 90,
        "fiyat": int.tryParse(_fiyatController.text.trim()) ?? 0,
        "lokasyon": _lokasyonController.text.trim().isEmpty ? "Merkez Bayi" : _lokasyonController.text.trim(),
        "aciklama": _aciklamaController.text.trim(),

        // 💰 FİNANS VE BAĞLANTI ZIRHLARI
        "ekleyen_kullanici_id": currentUserUid, // Komisyon kime kesilecek?
        "satista_mi": true, // Vitrine anında düşsün
        "kayit_tarihi": FieldValue.serverTimestamp(),
      });

      // 3. LİMİTİ GÜNCELLE: VIP değilse kullanilan_ilan_sayisi'nı 1 artır!
      if (!isVip) {
        DocumentReference userRef = FirebaseFirestore.instance.collection('kullanicilar').doc(currentUserUid);
        batch.update(userRef, {
          'kullanilan_ilan_sayisi': FieldValue.increment(1)
        });
      }

      // 4. SİBER RADARA BİLDİR: Yeni Araç Sisteme Girdi
      DocumentReference logRef = FirebaseFirestore.instance.collection('siber_istihbarat_loglari').doc();
      batch.set(logRef, {
        'kategori': 'BAYİ_RÜTBESİ',
        'seviye': 'BİLGİ',
        'mesaj': 'YENİ ARAÇ: ${_markaController.text.trim()} sisteme yüklendi. (Fiyat: ₺${_fiyatController.text.trim()})',
        'hedef_id': plakaID,
        'tarih': FieldValue.serverTimestamp(),
      });

      // SİSTEME ATEŞLE
      await batch.commit();

      _showSnackBar("Araç Kuantum Ağına Başarıyla Yüklendi! 🦅");
      if (mounted) Navigator.pop(context);

    } catch (e) {
      _showSnackBar("Siber Ağ Hatası: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: TextStyle(color: isError ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
      backgroundColor: isError ? Colors.redAccent : Color(0xFF00FFC2),
    ));
  }

  // 🛑 VIP ÖDEME DUVARI (PAYWALL)
  void _showPaywall() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Color(0xFF1E293B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.redAccent)),
            title: Row(
              children: [
                Icon(Icons.block, color: Colors.redAccent),
                SizedBox(width: 10),
                Text("İLAN LİMİTİ DOLDU!", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text(
              "Standart paketinizin 10 adet ilan limitini doldurdunuz. Sınırsız ilan eklemek ve OtoDNA Kuantum Ağı'nın VIP ayrıcalıklarından faydalanmak için paketinizi yükseltin.",
              style: TextStyle(color: SiberTema.textMuted),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("İPTAL", style: TextStyle(color: SiberTema.textMuted)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF00FFC2), foregroundColor: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Ödeme sayfasına (Siber Kasaya) yönlendir!
                },
                child: Text("VIP PAKET AL", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0F172A);
    const primaryCyan = Color(0xFF00FFC2);
    const cardColor = Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: primaryCyan), onPressed: () => Navigator.pop(context)),
        title: Text("Kuantum İlan Terminali", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: Theme(
        data: ThemeData(
          colorScheme: ColorScheme.dark(primary: primaryCyan, surface: bgColor), // background yerine surface
          canvasColor: bgColor,
        ),
        child: Stepper(
          physics: BouncingScrollPhysics(),
          currentStep: _aktifAdim,
          onStepTapped: (adim) => setState(() => _aktifAdim = adim),
          onStepContinue: () {
            if (_aktifAdim < 2) {
              setState(() => _aktifAdim += 1);
            } else {
              _araciKuantumAginaKaydet();
            }
          },
          onStepCancel: () {
            if (_aktifAdim > 0) setState(() => _aktifAdim -= 1);
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: EdgeInsets.only(top: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryCyan,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isSaving ? null : details.onStepContinue,
                      child: _isSaving
                          ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: bgColor, strokeWidth: 2))
                          : Text(_aktifAdim == 2 ? "AĞA YÜKLE (KAYDET)" : "SONRAKİ ADIM", style: TextStyle(color: bgColor, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ),
                  if (_aktifAdim > 0) SizedBox(width: 12),
                  if (_aktifAdim > 0)
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: SiberTema.textMuted),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: details.onStepCancel,
                        child: Text("GERİ", style: TextStyle(color: SiberTema.textMuted, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            );
          },
          steps: [
            // ADIM 1: KİMLİK
            Step(
              isActive: _aktifAdim >= 0,
              state: _aktifAdim > 0 ? StepState.complete : StepState.indexed,
              title: Text("Araç Kimliği", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold)),
              content: Column(
                children: [
                  _buildKuantumInput("Plaka / Şase", Icons.pin, _plakaController, isUppercase: true),
                  _buildKuantumInput("Marka (Örn: Mercedes)", Icons.branding_watermark, _markaController),
                  _buildKuantumInput("Model (Örn: C200 d AMG)", Icons.directions_car, _modelController),
                  _buildKuantumInput("Üretim Yılı", Icons.calendar_today, _yilController, isNumber: true),
                ],
              ),
            ),

            // ADIM 2: EKSPERTİZ
            Step(
              isActive: _aktifAdim >= 1,
              state: _aktifAdim > 1 ? StepState.complete : StepState.indexed,
              title: Text("Ekspertiz & Durum", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold)),
              content: Column(
                children: [
                  _buildKuantumInput("Kilometre", Icons.speed, _kmController, isNumber: true),
                  _buildKuantumInput("Hasar Durumu (Örn: Değişensiz, 1 Boya)", Icons.health_and_safety, _durumController),
                  _buildKuantumInput("OtoDNA Skoru (0-100)", Icons.science, _dnaSkoruController, isNumber: true),
                ],
              ),
            ),

            // ADIM 3: SATIŞ
            Step(
              isActive: _aktifAdim >= 2,
              title: Text("Satış & Yayın", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold)),
              content: Column(
                children: [
                  _buildKuantumInput("Satış Fiyatı (₺)", Icons.attach_money, _fiyatController, isNumber: true),
                  _buildKuantumInput("Bayi / Lokasyon", Icons.storefront, _lokasyonController),
                  Container(
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: SiberTema.textMuted)),
                    child: TextField(
                      controller: _aciklamaController,
                      style: TextStyle(color: SiberTema.textMain),
                      maxLines: 4,
                      decoration: InputDecoration(hintText: "Satıcı Açıklaması ve Ekstra Donanımlar...", hintStyle: TextStyle(color: SiberTema.textMuted, fontSize: 13), border: InputBorder.none),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // YARDIMCI GÖRSEL BİLEŞEN
  Widget _buildKuantumInput(String hint, IconData icon, TextEditingController controller, {bool isNumber = false, bool isUppercase = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: Color(0xFF1E293B), borderRadius: BorderRadius.circular(16), border: Border.all(color: SiberTema.textMuted)),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        textCapitalization: isUppercase ? TextCapitalization.characters : TextCapitalization.sentences,
        style: TextStyle(color: SiberTema.textMain),
        decoration: InputDecoration(
          icon: Icon(icon, color: Color(0xFF00FFC2), size: 20),
          hintText: hint,
          hintStyle: TextStyle(color: SiberTema.textMuted, fontSize: 13),
          border: InputBorder.none,
        ),
      ),
    );
  }
}