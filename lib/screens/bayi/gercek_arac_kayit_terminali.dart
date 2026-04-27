import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🚨 DİKKAT: Modellerinin import yolları. Kırmızı çizerse Ctrl + . ile düzelt!
import '../../models/arac_model.dart';
import '../../models/car_ad_model.dart';
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

class GercekAracKayitTerminali extends StatefulWidget {
  const GercekAracKayitTerminali({super.key});

  @override
  State<GercekAracKayitTerminali> createState() => _GercekAracKayitTerminaliState();
}

class _GercekAracKayitTerminaliState extends State<GercekAracKayitTerminali> {
  // --- KULLANICI / RUHSAT BİLGİLERİ ---
  final _adController = TextEditingController();
  final _soyadController = TextEditingController();
  final _ilController = TextEditingController();
  final _ilceController = TextEditingController();

  // --- ARAÇ KİMLİK BİLGİLERİ ---
  final _plakaController = TextEditingController();
  final _saseNoController = TextEditingController();
  final _markaController = TextEditingController();
  final _modelController = TextEditingController();
  final _renkController = TextEditingController();

  // --- İLAN (CAR AD) BİLGİLERİ ---
  final _fiyatController = TextEditingController();
  final _aciklamaController = TextEditingController();

  bool _isSaving = false;
  DateTime _secilenDogumTarihi = DateTime(1990);

  // DOGUM TARİHİ SEÇİCİ
  Future<void> _tarihSec(BuildContext context) async {
    final DateTime? secilen = await showDatePicker(
      context: context,
      initialDate: _secilenDogumTarihi,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
          data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                  primary: Color(0xFF00FFC2),
                  onPrimary: Colors.black,
                  surface: Color(0xFF1E293B)
              )
          ),
          child: child!
      ),
    );
    if (secilen != null && secilen != _secilenDogumTarihi) {
      setState(() => _secilenDogumTarihi = secilen);
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: TextStyle(color: isError ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
      backgroundColor: isError ? Colors.redAccent : const Color(0xFF00FFC2),
    ));
  }

  // 🛑 VIP ÖDEME DUVARI (PAYWALL)
  void _showPaywall() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.redAccent)),
            title: const Row(
              children: [
                Icon(Icons.block, color: Colors.redAccent),
                SizedBox(width: 10),
                Text("İLAN LİMİTİ DOLDU!", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ],
            ),
            content: const Text(
              "Standart paketinizin 10 adet ilan limitini doldurdunuz. Sınırsız ilan eklemek ve OtoDNA Kuantum Ağı'nın VIP ayrıcalıklarından faydalanmak için paketinizi yükseltin.",
              style: TextStyle(color: SiberTema.textMuted),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("İPTAL", style: TextStyle(color: SiberTema.textMuted)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FFC2), foregroundColor: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Ödeme sayfasına (Siber Kasaya) yönlendir!
                },
                child: const Text("VIP PAKET AL", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        }
    );
  }

  // 🔥 FİREBASE BATCH & VIP LİMİT MOTORU 🔥
  Future<void> _verileriKuantumAgaGonder() async {
    // 1. Şase No 17 Hane Kontrolü
    if (_saseNoController.text.trim().length != 17) {
      _showSnackBar("Şase No (VIN) tam 17 karakter olmalıdır!", isError: true);
      return;
    }

    setState(() => _isSaving = true);
    FocusScope.of(context).unfocus();

    try {
      final firestore = FirebaseFirestore.instance;
      final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? 'OTO_DNA_BAYI_${DateTime.now().millisecondsSinceEpoch}';

      // 🚨 SİBER SAAS KONTROLÜ: Kullanıcının limitlerini veritabanından çek!
      DocumentSnapshot userDoc = await firestore.collection('kullanicilar').doc(currentUid).get();
      if (!userDoc.exists) throw Exception("Siber Kimlik Bulunamadı!");

      var userData = userDoc.data() as Map<String, dynamic>;
      bool isVip = userData['is_vip'] ?? false;
      int kullanilanIlan = userData['kullanilan_ilan_sayisi'] ?? 0;
      int maxLimit = isVip ? -1 : 10; // VIP ise -1 (Sınırsız)

      // 🚨 ÖDEME DUVARI: Limit dolmuşsa işlemi durdur!
      if (!isVip && kullanilanIlan >= maxLimit) {
        setState(() => _isSaving = false);
        _showPaywall();
        return;
      }

      String plakaID = _plakaController.text.trim().replaceAll(" ", "").toUpperCase();
      String ilanID = firestore.collection('ilanlar').doc().id;

      // 2. SENİN ARAC_MODEL'İNİ CANLANDIR!
      final yeniArac = AracModel(
        sahibiUid: currentUid,
        kullaniciAdi: "${_adController.text.trim().toLowerCase()}_oto",
        ad: _adController.text.trim(),
        soyad: _soyadController.text.trim(),
        dogumTarihi: _secilenDogumTarihi,
        plaka: plakaID,
        il: _ilController.text.trim(),
        ilce: _ilceController.text.trim(),
        postaKodu: "00000",
        marka: _markaController.text.trim(),
        model: _modelController.text.trim(),
        renk: _renkController.text.trim(),
        saseNo: _saseNoController.text.trim().toUpperCase(),
        kayitTarihi: DateTime.now(),
      );

      // 3. SENİN CAR_AD (İLAN) MODELİNİ CANLANDIR!
      double girilenFiyat = double.tryParse(_fiyatController.text.trim()) ?? 0.0;

      final yeniIlan = CarAd(
        id: ilanID,
        ownerId: currentUid,
        saticiAdi: "${_adController.text.trim()} ${_soyadController.text.trim()}",
        brandModel: "${yeniArac.marka} ${yeniArac.model}",
        price: girilenFiyat,
        kaporaBedeli: 5000.0,
        images: ["https://example.com/placeholder_car.jpg"],
        isSecureDeposit: true,
        description: _aciklamaController.text.trim(),
      );

      // 4. BATCH İŞLEMİ (Atomik Kayıt)
      WriteBatch batch = firestore.batch();

      DocumentReference aracRef = firestore.collection('vehicles').doc(plakaID);
      DocumentReference ilanRef = firestore.collection('ilanlar').doc(ilanID);
      DocumentReference userRef = firestore.collection('kullanicilar').doc(currentUid);

      batch.set(aracRef, yeniArac.toMap());

      batch.set(ilanRef, {
        'id': yeniIlan.id,
        'ownerId': yeniIlan.ownerId,
        'saticiAdi': yeniIlan.saticiAdi,
        'brandModel': yeniIlan.brandModel,
        'price': yeniIlan.price,
        'kaporaBedeli': yeniIlan.kaporaBedeli,
        'images': yeniIlan.images,
        'isSecureDeposit': yeniIlan.isSecureDeposit,
        'description': yeniIlan.description,
        'aracRefPlaka': plakaID,
        'ekleyen_kullanici_id': currentUid, // SİBER KASA KOMİSYONU İÇİN MÜHÜR!
        'olusturmaTarihi': FieldValue.serverTimestamp(),
      });

      // LİMİTİ GÜNCELLE: VIP değilse sayacı 1 artır!
      if (!isVip) {
        batch.update(userRef, {
          'kullanilan_ilan_sayisi': FieldValue.increment(1)
        });
      }

      // 5. SİBER İSTİHBARAT RADARINA BİLDİR
      DocumentReference logRef = firestore.collection('siber_istihbarat_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'YENI_ARAC_KAYDI_VE_ILAN',
        'seviye': 'BİLGİ',
        'islem_detayi': 'YENİ ARAÇ & İLAN: $plakaID plakalı araç ve ilanı sisteme mühürlendi. (Fiyat: ₺${girilenFiyat.toStringAsFixed(2)})',
        'vaka_id': plakaID,
        'kullanici_id': currentUid,
        'tarih': FieldValue.serverTimestamp(),
      });

      // Kuantum Ateşlemesi!
      await batch.commit();

      _showSnackBar("OtoDNA: Araç ve İlan Senkronizasyonu Başarılı! 🦅");
      if (mounted) Navigator.pop(context);

    } catch (e) {
      _showSnackBar("Kritik Ağ Hatası: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _adController.dispose();
    _soyadController.dispose();
    _ilController.dispose();
    _ilceController.dispose();
    _plakaController.dispose();
    _saseNoController.dispose();
    _markaController.dispose();
    _modelController.dispose();
    _renkController.dispose();
    _fiyatController.dispose();
    _aciklamaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryCyan = SiberTema.kuantumCyan;
    const bgColor = SiberTema.oledBlack;

    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent, elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: primaryCyan), onPressed: () => Navigator.pop(context)),
          title: const Text("Kuantum Kayıt Terminali", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, fontSize: 16)),
          centerTitle: true,
        ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("1. Ruhsat Sahibi / Kullanıcı", style: TextStyle(color: primaryCyan, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(children: [Expanded(child: _buildInput("Ad", _adController)), const SizedBox(width: 12), Expanded(child: _buildInput("Soyad", _soyadController))]),
            Row(children: [Expanded(child: _buildInput("İl", _ilController)), const SizedBox(width: 12), Expanded(child: _buildInput("İlçe", _ilceController))]),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Doğum Tarihi", style: TextStyle(color: SiberTema.textMuted, fontSize: 13)),
              subtitle: Text("${_secilenDogumTarihi.day}/${_secilenDogumTarihi.month}/${_secilenDogumTarihi.year}", style: const TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.calendar_month, color: primaryCyan),
              onTap: () => _tarihSec(context),
            ),

            const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: SiberTema.textMuted)),
            const Text("2. OtoDNA Araç Kimliği", style: TextStyle(color: primaryCyan, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildInput("Plaka (Örn: 34 MTH 139)", _plakaController, isUpper: true),
            _buildInput("Şase No (17 Hane Zorunlu)", _saseNoController, isUpper: true, isMaks17: true),
            Row(children: [Expanded(child: _buildInput("Marka", _markaController)), const SizedBox(width: 12), Expanded(child: _buildInput("Model", _modelController))]),
            _buildInput("Renk", _renkController),

            const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: SiberTema.textMuted)),
            const Text("3. İlan & Fiyatlandırma (CarAd)", style: TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildInput("Satış Fiyatı (₺)", _fiyatController, isNumber: true),
            _buildInput("Satıcı Açıklaması", _aciklamaController, isMultiLine: true),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: primaryCyan,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                ),
                onPressed: _isSaving ? null : _verileriKuantumAgaGonder,
                icon: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: bgColor, strokeWidth: 2))
                    : const Icon(Icons.fingerprint, color: bgColor),
                label: Text(
                    _isSaving ? "SİSTEME İŞLENİYOR..." : "ARACI VE İLANI YAYINLA",
                    style: const TextStyle(color: bgColor, fontWeight: FontWeight.bold, fontSize: 16)
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildInput(String hint, TextEditingController controller, {bool isNumber = false, bool isUpper = false, bool isMaks17 = false, bool isMultiLine = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border.all(color: SiberTema.textMuted)),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : (isMultiLine ? TextInputType.multiline : TextInputType.text),
        maxLength: isMaks17 ? 17 : null,
        maxLines: isMultiLine ? 3 : 1,
        textCapitalization: isUpper ? TextCapitalization.characters : TextCapitalization.words,
        style: const TextStyle(color: SiberTema.textMain),
        decoration: InputDecoration(counterText: "", hintText: hint, hintStyle: const TextStyle(color: SiberTema.textMuted, fontSize: 13), border: InputBorder.none),
      ),
    );
  }
}