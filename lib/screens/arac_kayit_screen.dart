// lib/screens/arac_kayit_screen.dart (Dosya yoluna göre ayarla)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🚀 KARARGAH ZIRHLARI VE TEMALARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

class AracKayitScreen extends ConsumerStatefulWidget {
  const AracKayitScreen({super.key});

  @override
  ConsumerState<AracKayitScreen> createState() => _AracKayitScreenState();
}

class _AracKayitScreenState extends ConsumerState<AracKayitScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false; // Kuantum Yükleme Kalkanı

  // 1. Kişisel Bilgi Kontrolleri
  final _adSoyadController = TextEditingController();
  final _dogumTarihiController = TextEditingController();
  final _ilController = TextEditingController(text: 'Ankara'); // Distribütörlük Merkezi Başlangıç
  final _ilceController = TextEditingController();

  // 2. Araç Bilgi Kontrolleri
  final _plakaController = TextEditingController();
  final _markaController = TextEditingController();
  final _modelController = TextEditingController();
  final _renkController = TextEditingController();
  final _postaKoduController = TextEditingController();

  // 3. Şase (VIN) Kontrolleri
  final _saseController = TextEditingController();
  bool _saseElleDogrulandi = false;

  // 4. Tarih Kontrolleri
  final _muayeneTarihController = TextEditingController();
  final _egzozTarihController = TextEditingController();
  final _sigortaTarihController = TextEditingController();
  final _kaskoTarihController = TextEditingController();
  String _muayenePeriyodu = '2 Yılda Bir';

  // 5. Kulüp Katılımı
  bool _kulubeKatil = true;

  @override
  void dispose() {
    _adSoyadController.dispose();
    _dogumTarihiController.dispose();
    _ilController.dispose();
    _ilceController.dispose();
    _plakaController.dispose();
    _markaController.dispose();
    _modelController.dispose();
    _renkController.dispose();
    _postaKoduController.dispose();
    _saseController.dispose();
    _muayeneTarihController.dispose();
    _egzozTarihController.dispose();
    _sigortaTarihController.dispose();
    _kaskoTarihController.dispose();
    super.dispose();
  }

  // 📸 SİBER GÖZ: OCR ŞASE TARAMA
  void _saseOkuKamera() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: SiberTema.kuantumCyan,
        content: Text(
          'SİBER GÖZ AKTİF: Şase numarasını (VIN) okutunuz. 🦅',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ),
    );
    // TODO: google_mlkit_text_recognition paketi canlıya alındığında burası tetiklenecek
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _saseController.text = "NMTK33BXVX0123456"; // Örnek Test Şasesi
        _saseElleDogrulandi = false; // Güvenlik Protokolü: Manuel Doğrulama Şart!
      });
    });
  }

  void _tarihSec(TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: SiberTema.kuantumCyan,
              onPrimary: SiberTema.oledBlack,
              surface: SiberTema.matGrey,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        controller.text = "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
      });
    }
  }

  // 🚀 %100 GERÇEK FİREBASE KAYIT MOTORU
  Future<void> _kaydiTamamla() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_saseElleDogrulandi) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: SiberTema.kanKirmizi,
          content: Text('SİBER İHLAL: Şase numarasının doğru olduğunu elle onaylayınız!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String saseNoKripto = _saseController.text.trim().toUpperCase();

      // Kuantum Ağına Doğrudan Yazma İşlemi (Profil Ekranı ile Uyumlu Tablo: arac_kimlikleri)
      await FirebaseFirestore.instance.collection('arac_kimlikleri').doc(saseNoKripto).set({
        "sahibi": {
          "ad_soyad": _adSoyadController.text.trim(),
          "dogum_tarihi": _dogumTarihiController.text.trim(),
          "il": _ilController.text.trim(),
          "ilce": _ilceController.text.trim(),
        },
        // DNA RADARI İÇİN TEMEL BİLGİLER
        "plaka": _plakaController.text.trim().replaceAll(" ", "").toUpperCase(),
        "marka_model": "${_markaController.text.trim().toUpperCase()} ${_modelController.text.trim().toUpperCase()}",
        "renk": _renkController.text.trim(),
        "posta_kodu": _postaKoduController.text.trim(),

        // 🧬 DNA VE REFERANS SİSTEMİ BAŞLANGIÇ DEĞERLERİ
        "dna_skoru": 100, // Yeni araç kusursuz başlar
        "muayene_durumu": "🟢 YENİ KAYIT / REFERANSLI",
        "son_muayene_zaman_damgasi": FieldValue.serverTimestamp(),

        "tarihler": {
          "muayene_tarihi": _muayeneTarihController.text.trim(),
          "muayene_periyodu": _muayenePeriyodu,
          "egzoz_tarihi": _egzozTarihController.text.trim(),
          "sigorta_tarihi": _sigortaTarihController.text.trim(),
          "kasko_tarihi": _kaskoTarihController.text.trim(),
        },
        "kulup_uyesi": _kulubeKatil,
        "kayit_tarihi": FieldValue.serverTimestamp(),
        "aktif": true,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: SiberTema.kuantumCyan,
          content: Text(
            'ARAÇ OTODNA AĞINA BAŞARIYLA MÜHÜRLENDİ! 🦅',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
        ),
      );

      // Başarılı kayıttan sonra terminale geri dön
      Navigator.pop(context, true);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: SiberTema.kanKirmizi, content: Text('AĞ BAĞLANTI HATASI: $e', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🛡️ Bütün ekranı Tablet/Araç İçi Zırhına alıyoruz!
    return ResponsiveKalkan(
      child: Scaffold(
        backgroundColor: Colors.transparent, // Kalkan siyaha boyar
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'SİBER ARAÇ KAYDI',
            style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 3),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildBolumBasligi('1. KİMLİK PROTOKOLÜ', Icons.person_outline),
                _buildKisiselBilgilerKarti(),
                const SizedBox(height: 32),

                _buildBolumBasligi('2. ARAÇ GENETİĞİ', Icons.directions_car_outlined),
                _buildAracBilgileriKarti(),
                const SizedBox(height: 32),

                _buildBolumBasligi('3. ŞASE (VIN) DOĞRULAMA', Icons.memory),
                _buildSaseDogrulamaKarti(),
                const SizedBox(height: 32),

                _buildBolumBasligi('4. ZAMAN ÇİZELGESİ', Icons.calendar_month_outlined),
                _buildTarihlerKarti(),
                const SizedBox(height: 32),

                _buildOtoDnaKulupKarti(),
                const SizedBox(height: 40),

                // =================================================================
                // 🚀 MÜHÜRLEME BUTONU
                // =================================================================
                SizedBox(
                  height: 64,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _kaydiTamamla,
                    style: SiberTema.kuantumButonStili(),
                    icon: _isSaving
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                        : const Icon(Icons.fingerprint, size: 24, color: SiberTema.oledBlack),
                    label: Text(
                      _isSaving ? 'AĞA MÜHÜRLENİYOR...' : 'KAYDI TAMAMLA VE AĞA GİR',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: SiberTema.oledBlack),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞENLER
  Widget _buildBolumBasligi(String baslik, IconData ikon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(ikon, color: SiberTema.kuantumCyan, size: 20),
          const SizedBox(width: 12),
          Text(
            baslik,
            style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isNumber = false, bool readOnly = false, VoidCallback? onTap, bool isUppercase = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        textCapitalization: isUppercase ? TextCapitalization.characters : TextCapitalization.words,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12, fontWeight: FontWeight.normal),
          prefixIcon: Icon(icon, color: SiberTema.kuantumCyan.withOpacity(0.7), size: 20),
          filled: true,
          fillColor: SiberTema.oledBlack,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: SiberTema.kuantumCyan, width: 1.5)),
          errorStyle: const TextStyle(color: SiberTema.kanKirmizi, fontWeight: FontWeight.bold),
        ),
        validator: (value) => value!.isEmpty ? 'Bu alan zorunludur' : null,
      ),
    );
  }

  Widget _buildKisiselBilgilerKarti() {
    return SiberTema.siberCamKalkan(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(_adSoyadController, 'İsim Soyisim', Icons.person_outline),
          _buildTextField(_dogumTarihiController, 'Doğum Tarihi', Icons.calendar_today_outlined, readOnly: true, onTap: () => _tarihSec(_dogumTarihiController)),
          Row(
            children: [
              Expanded(child: _buildTextField(_ilController, 'İl', Icons.map_outlined)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(_ilceController, 'İlçe', Icons.location_city_outlined)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAracBilgileriKarti() {
    return SiberTema.siberCamKalkan(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(_plakaController, 'Araç Plakası (Örn: 06 DNA 001)', Icons.credit_card_outlined, isUppercase: true),
          Row(
            children: [
              Expanded(child: _buildTextField(_markaController, 'Marka', Icons.directions_car_outlined, isUppercase: true)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(_modelController, 'Model', Icons.settings_suggest_outlined, isUppercase: true)),
            ],
          ),
          Row(
            children: [
              Expanded(child: _buildTextField(_renkController, 'Renk', Icons.color_lens_outlined)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(_postaKoduController, 'Posta Kodu', Icons.markunread_mailbox_outlined, isNumber: true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaseDogrulamaKarti() {
    return SiberTema.siberCamKalkan(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: _saseOkuKamera,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: SiberTema.kuantumCyan.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5), style: BorderStyle.solid),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.document_scanner_outlined, color: SiberTema.kuantumCyan, size: 20),
                  SizedBox(width: 12),
                  Text('GÖRÜNTÜDEN ŞASE (VIN) OKU', style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildTextField(_saseController, 'Şase Numarası (VIN)', Icons.numbers, isUppercase: true),

          // Siber Güvenlik Onay Kutusu
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _saseElleDogrulandi ? SiberTema.kuantumCyan.withOpacity(0.05) : SiberTema.kanKirmizi.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _saseElleDogrulandi ? SiberTema.kuantumCyan.withOpacity(0.3) : SiberTema.kanKirmizi.withOpacity(0.3)),
            ),
            child: CheckboxListTile(
              title: Text(
                'Şase numarasının Kuantum Ağı için doğru olduğunu bizzat teyit ediyorum.',
                style: TextStyle(color: _saseElleDogrulandi ? Colors.white : SiberTema.kanKirmizi.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.bold),
              ),
              value: _saseElleDogrulandi,
              onChanged: (val) => setState(() => _saseElleDogrulandi = val!),
              activeColor: SiberTema.kuantumCyan,
              checkColor: Colors.black,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTarihlerKarti() {
    return SiberTema.siberCamKalkan(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('OtoDNA Asistanı, yaklaşan kritik tarihler için sizi önceden uyarır.', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, height: 1.5)),
          const SizedBox(height: 20),
          _buildTextField(_muayeneTarihController, 'Son Muayene Bitiş', Icons.build_circle_outlined, readOnly: true, onTap: () => _tarihSec(_muayeneTarihController)),

          // Özel Dropdown Tasarımı
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: SiberTema.oledBlack, borderRadius: BorderRadius.circular(16)),
            child: DropdownButtonFormField<String>(
              value: _muayenePeriyodu,
              dropdownColor: SiberTema.matGrey,
              icon: const Icon(Icons.expand_more, color: Colors.white38),
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.update, color: SiberTema.kuantumCyan.withOpacity(0.7), size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
              ),
              items: ['1 Yılda Bir', '2 Yılda Bir', '3 Yılda Bir'].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (newValue) => setState(() => _muayenePeriyodu = newValue!),
            ),
          ),
          _buildTextField(_egzozTarihController, 'Egzoz Emisyon Bitiş', Icons.co2, readOnly: true, onTap: () => _tarihSec(_egzozTarihController)),
          _buildTextField(_sigortaTarihController, 'Sigorta Poliçe Bitiş', Icons.health_and_safety_outlined, readOnly: true, onTap: () => _tarihSec(_sigortaTarihController)),
          _buildTextField(_kaskoTarihController, 'Kasko Poliçe Bitiş', Icons.shield_outlined, readOnly: true, onTap: () => _tarihSec(_kaskoTarihController)),
        ],
      ),
    );
  }

  Widget _buildOtoDnaKulupKarti() {
    return SiberTema.siberCamKalkan(
      child: Column(
        children: [
          Icon(Icons.groups_outlined, color: _kulubeKatil ? SiberTema.kuantumCyan : Colors.white38, size: 40),
          const SizedBox(height: 16),
          const Text('OTODNA KULÜP AĞI', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(
            _markaController.text.isNotEmpty ? '${_markaController.text.toUpperCase()} markasına ait siber kulüp forumuna katılmak ister misiniz?' : 'Aracınızın markasına ait siber kulüp forumuna katılmak ister misiniz?',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 11, height: 1.5),
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: Text(_kulubeKatil ? 'AĞA KATILIM ONAYLANDI' : 'ŞİMDİLİK İPTAL', style: TextStyle(color: _kulubeKatil ? SiberTema.kuantumCyan : Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
            value: _kulubeKatil,
            onChanged: (val) => setState(() => _kulubeKatil = val),
            activeColor: Colors.black,
            activeTrackColor: SiberTema.kuantumCyan,
            inactiveThumbColor: Colors.white54,
            inactiveTrackColor: SiberTema.oledBlack,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}