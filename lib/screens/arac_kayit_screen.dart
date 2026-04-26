// lib/screens/arac_kayit_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // 🚀 GERÇEK SİBER GÖZ

// 🚀 KARARGAH ZIRHLARI VE TEMALARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';
import 'dashboard/home_screen.dart'; // Yönlendirme için

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
  final _ilController = TextEditingController(text: 'Ankara');
  final _ilceController = TextEditingController();
  final _postaKoduController = TextEditingController(); // Buraya taşındı

  // 2. Araç Bilgi Kontrolleri
  final _plakaController = TextEditingController();
  final _markaController = TextEditingController();
  final _modelController = TextEditingController();
  final _modelYiliController = TextEditingController(); // YENİ
  final _renkController = TextEditingController();

  // 3. Şase (VIN) Kontrolleri
  final _saseController = TextEditingController();
  bool _saseElleDogrulandi = false;

  // 4. Tarih Kontrolleri
  final _muayeneTarihController = TextEditingController();
  final _emisyonTarihController = TextEditingController(); // Egzoz -> Emisyon oldu

  @override
  void dispose() {
    _adSoyadController.dispose();
    _dogumTarihiController.dispose();
    _ilController.dispose();
    _ilceController.dispose();
    _postaKoduController.dispose();
    _plakaController.dispose();
    _markaController.dispose();
    _modelController.dispose();
    _modelYiliController.dispose();
    _renkController.dispose();
    _saseController.dispose();
    _muayeneTarihController.dispose();
    _emisyonTarihController.dispose();
    super.dispose();
  }

  // 📸 GERÇEK SİBER GÖZ (KAMERA İLE BARKOD/QR TARAMA)
  void _saseOkuKamera() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: SiberTema.geceMavisi,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
              ),
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Text("SİBER GÖZ AKTİF", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2)),
              ),
              const Text("Şase numarası (VIN) veya araç QR kodunu okutun.", style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: SiberTema.kuantumCyan, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: MobileScanner(
                      onDetect: (capture) {
                        final List<Barcode> barcodes = capture.barcodes;
                        for (final barcode in barcodes) {
                          if (barcode.rawValue != null) {
                            String okunanSase = barcode.rawValue!;
                            // QR Formatındaysa temizle "OTODNA:123" gibi
                            if (okunanSase.startsWith("OTODNA:")) {
                              okunanSase = okunanSase.replaceAll("OTODNA:", "");
                            }
                            setState(() {
                              _saseController.text = okunanSase;
                              _saseElleDogrulandi = true;
                            });
                            Navigator.pop(context); // Kamerayı kapat
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: SiberTema.kuantumCyan,
                                content: Text('ŞASE BAŞARIYLA ÇÖZÜMLENDİ!', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                              ),
                            );
                            break;
                          }
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  void _tarihSec(TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2035),
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

  // 🚀 %100 GERÇEK FİREBASE KAYIT MOTORU (ATOMİK)
  Future<void> _kaydiTamamla() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_saseElleDogrulandi) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: SiberTema.kanKirmizi,
          content: Text('SİBER İHLAL: Şase numarasının doğru olduğunu onaylayın!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final db = FirebaseFirestore.instance;
      String saseNo = _saseController.text.trim().toUpperCase();

      // MÜHÜRLEME İŞLEMİ BAŞLIYOR
      await db.collection('arac_kimlikleri').doc(saseNo).set({
        "sahibi": {
          "ad_soyad": _adSoyadController.text.trim(),
          "dogum_tarihi": _dogumTarihiController.text.trim(),
          "il": _ilController.text.trim(),
          "ilce": _ilceController.text.trim(),
          "posta_kodu": _postaKoduController.text.trim(),
        },
        "plaka": _plakaController.text.trim().replaceAll(" ", "").toUpperCase(),
        "marka_model": "${_markaController.text.trim().toUpperCase()} ${_modelController.text.trim().toUpperCase()}",
        "model_yili": _modelYiliController.text.trim(),
        "renk": _renkController.text.trim(),
        "dna_skoru": 100,
        "muayene_durumu": "🟢 REFERANSLI",
        "tarihler": {
          "muayene_tarihi": _muayeneTarihController.text.trim(),
          "emisyon_tarihi": _emisyonTarihController.text.trim(),
        },
        "kayit_tarihi": FieldValue.serverTimestamp(),
        "aktif": true,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: SiberTema.kuantumCyan,
          content: Text('ARAÇ OTODNA AĞINA MÜHÜRLENDİ! 🦅', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
        ),
      );

      // 🔥 BAŞARILI KAYIT SONRASI ANA EKRANA DÖNÜŞ (Ahiret Sorusunu Bitirir)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: SiberTema.kanKirmizi, content: Text('SİBER HATA: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: SiberTema.geceMavisi,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text('SİBER ARAÇ KAYDI', style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 3)),
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20), onPressed: () => Navigator.pop(context)),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32), // Daha ferah padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildBolumBasligi('1. KİMLİK PROTOKOLÜ', Icons.person_outline),
                _buildKisiselBilgilerKarti(),
                const SizedBox(height: 48), // Boluklar artırıldı

                _buildBolumBasligi('2. ARAÇ GENETİĞİ', Icons.directions_car_outlined),
                _buildAracBilgileriKarti(),
                const SizedBox(height: 48),

                _buildBolumBasligi('3. ŞASE (VIN) DOĞRULAMA', Icons.memory),
                _buildSaseDogrulamaKarti(),
                const SizedBox(height: 48),

                _buildBolumBasligi('4. ZAMAN ÇİZELGESİ', Icons.calendar_month_outlined),
                _buildTarihlerKarti(),
                const SizedBox(height: 56), // Ekstra ferahlık

                SizedBox(
                  height: 64,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _kaydiTamamla,
                    style: SiberTema.kuantumButonStili(),
                    icon: _isSaving
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                        : const Icon(Icons.fingerprint, size: 24, color: SiberTema.oledBlack),
                    label: Text(_isSaving ? 'AĞA MÜHÜRLENİYOR...' : 'KAYDI TAMAMLA VE AĞA GİR', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: SiberTema.oledBlack)),
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBolumBasligi(String baslik, IconData ikon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20), // Alt boşluk artırıldı
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [SiberTema.kuantumCyan, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds);
            },
            child: Icon(ikon, color: Colors.white, size: 24), // İkon biraz büyütüldü
          ),
          const SizedBox(width: 12),
          Text(baslik, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2)),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isNumber = false, bool readOnly = false, VoidCallback? onTap, bool isUppercase = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20), // Elemanlar arası boşluk
      child: Container(
        decoration: SiberTema.siberKutuZirhi,
        child: TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          textCapitalization: isUppercase ? TextCapitalization.characters : TextCapitalization.words,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 12),
            prefixIcon: Icon(icon, color: SiberTema.kuantumCyan.withValues(alpha: 0.7), size: 20),
            filled: false,
            contentPadding: const EdgeInsets.symmetric(vertical: 20), // İç boşluk (ferah)
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: SiberTema.kuantumCyan, width: 1.5)),
          ),
          validator: (value) => value!.isEmpty ? 'Gerekli!' : null,
        ),
      ),
    );
  }

  Widget _buildKisiselBilgilerKarti() {
    return SiberTema.siberCamKalkan(
      padding: const EdgeInsets.all(24), // Cam kalkan iç boşluğu artırıldı
      child: Column(
        children: [
          _buildTextField(_adSoyadController, 'İsim Soyisim', Icons.person_outline),
          _buildTextField(_dogumTarihiController, 'Doğum Tarihi', Icons.calendar_today_outlined, readOnly: true, onTap: () => _tarihSec(_dogumTarihiController)),
          Row(
            children: [
              Expanded(child: _buildTextField(_ilController, 'İl', Icons.map_outlined)),
              const SizedBox(width: 16), // Ara boşluk artırıldı
              Expanded(child: _buildTextField(_ilceController, 'İlçe', Icons.location_city_outlined)),
            ],
          ),
          _buildTextField(_postaKoduController, 'Posta Kodu', Icons.markunread_mailbox_outlined, isNumber: true),
        ],
      ),
    );
  }

  Widget _buildAracBilgileriKarti() {
    return SiberTema.siberCamKalkan(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildTextField(_plakaController, 'Araç Plakası', Icons.credit_card_outlined, isUppercase: true),
          Row(
            children: [
              Expanded(child: _buildTextField(_markaController, 'Marka', Icons.directions_car_outlined, isUppercase: true)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField(_modelController, 'Model', Icons.settings_suggest_outlined, isUppercase: true)),
            ],
          ),
          Row(
            children: [
              Expanded(child: _buildTextField(_modelYiliController, 'Model Yılı', Icons.date_range_outlined, isNumber: true)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField(_renkController, 'Renk', Icons.color_lens_outlined)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaseDogrulamaKarti() {
    return SiberTema.siberCamKalkan(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          InkWell(
            onTap: _saseOkuKamera,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20), // Buton daha etli
              decoration: BoxDecoration(
                color: SiberTema.kuantumCyan.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SiberTema.kuantumCyan.withValues(alpha: 0.6), width: 1.5),
                boxShadow: [
                  BoxShadow(color: SiberTema.kuantumCyan.withValues(alpha: 0.3), blurRadius: 15, spreadRadius: 1),
                ],
              ),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.document_scanner_outlined, color: SiberTema.kuantumCyan, size: 24), SizedBox(width: 12), Text('ŞASE (VIN) OKU / KAMERA', style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5))]),
            ),
          ),
          const SizedBox(height: 28),
          _buildTextField(_saseController, 'Şase Numarası (VIN)', Icons.numbers, isUppercase: true),
          CheckboxListTile(
            title: const Text('Şase numarası doğrudur, onaylıyorum.', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            value: _saseElleDogrulandi,
            onChanged: (val) => setState(() => _saseElleDogrulandi = val!),
            activeColor: SiberTema.kuantumCyan,
            checkColor: Colors.black,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }

  Widget _buildTarihlerKarti() {
    return SiberTema.siberCamKalkan(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildTextField(_muayeneTarihController, 'Muayene Geçerlilik Tarihi', Icons.build_circle_outlined, readOnly: true, onTap: () => _tarihSec(_muayeneTarihController)),
          _buildTextField(_emisyonTarihController, 'Emisyon Geçerlilik Tarihi', Icons.co2, readOnly: true, onTap: () => _tarihSec(_emisyonTarihController)),
        ],
      ),
    );
  }
}