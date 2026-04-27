import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// 🦅 OTODNA BAYİ KAYIT TERMİNALİ - V5 (ŞEFFAF KİMLİK PROTOKOLÜ)
/// [2026-03-28] GÜNCELLEME: Her bayi kendi ismiyle ağa katılır.
/// Mutlak Gazi Finans Protokolü (%12) sisteme gömülmüştür.
class FirmRegisterScreen extends StatefulWidget {
  const FirmRegisterScreen({super.key});

  @override
  State<FirmRegisterScreen> createState() => _FirmRegisterScreenState();
}

class _FirmRegisterScreenState extends State<FirmRegisterScreen> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  static const Color bgColor = Color(0xFF000000);
  static const Color surfaceColor = Color(0xFF111111);
  static const Color primaryCyan = Color(0xFF00FFC2);
  static const Color dangerColor = Colors.redAccent;

  final _formKey = GlobalKey<FormState>();
  final _firmaAdiCtrl = TextEditingController();
  final _yetkiliCtrl = TextEditingController();
  final _vergiNoCtrl = TextEditingController();
  final _sehirCtrl = TextEditingController();

  bool _isProcessing = false;
  bool _isLocationScanning = false;
  String _konumVerisi = "SİNYAL BEKLENİYOR...";
  GeoPoint? _secilenKoordinat;

  // 🚀 SİBER KONUM BULUCU (GPS Simülasyonu)
  void _konumuMudurle() async {
    setState(() => _isLocationScanning = true);

    // Gerçekte geolocator paketiyle koordinat çekilecek
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() {
      _konumVerisi = "ANKARA, İVEDİK OSB (KOORDİNAT MÜHÜRLENDİ)";
      _secilenKoordinat = const GeoPoint(39.967, 32.748);
      _isLocationScanning = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("GPS RADARI: Konum Kilitlendi 🦅",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryCyan));
  }

  // 🚀 FİREBASE KAYIT MOTORU (GERÇEK SİSTEM)
  Future<void> _kaydiTamamla() async {
    if (!_formKey.currentState!.validate()) return;

    if (_secilenKoordinat == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("SİBER İHLAL: Lütfen önce konum mühürleyin!",
              style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: dangerColor));
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // 🛡️ SİBER MÜHÜR: Herkes kendi ismiyle 'bayiler' ana koleksiyonuna hazırlanır.
      await FirebaseFirestore.instance.collection('bayiler').add({
        "dealer_name": _firmaAdiCtrl.text.trim().toUpperCase(),
        "yetkili": _yetkiliCtrl.text.trim().toUpperCase(),
        "tax_number": _vergiNoCtrl.text.trim(),
        "city": _sehirCtrl.text.trim().toUpperCase(),
        "koordinat": _secilenKoordinat,
        "adres": _konumVerisi,
        "region": "İç Anadolu",
        "rozet": "Bronz",
        "aktif_mi": false, // İlk kayıt pasif; Karargah onayı bekler.

        // 💰 GAZİ FİNANS PROTOKOLÜ: Sabit %12 (%10 Kâr + %2 Vergi)
        // Murat Plaza dahil hiçbir bayi bu orandan kaçamaz.
        "komisyon_orani": 0.12,

        "kayit_tarihi": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("BAŞVURU SİBER AĞA MÜHÜRLENDİ!",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: primaryCyan));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("AĞ HATASI: $e",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: dangerColor));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _firmaAdiCtrl.dispose();
    _yetkiliCtrl.dispose();
    _vergiNoCtrl.dispose();
    _sehirCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20),
            onPressed: () => Navigator.pop(context)),
        title: const Text('B A Y İ   A Ğ I   K A Y I T   T E R M İ N A L İ',
            style: TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 3)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),

                  _buildSiberTextField(_firmaAdiCtrl, "FİRMA ÖZ ADI (ÖR: DOĞAN OTO)", Icons.business_outlined),
                  _buildSiberTextField(_yetkiliCtrl, "YETKİLİ AD SOYAD", Icons.person_outline),
                  _buildSiberTextField(_sehirCtrl, "ŞEHİR", Icons.map_outlined),
                  _buildSiberTextField(_vergiNoCtrl, "VERGİ NO", Icons.assignment_ind_outlined, isNumber: true),

                  const SizedBox(height: 32),
                  _buildKonumRadari(),
                  const SizedBox(height: 48),

                  SizedBox(
                    height: 64,
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _kaydiTamamla,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryCyan,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: _isProcessing
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.lock_open_rounded, size: 24),
                      label: Text(
                        _isProcessing ? "AĞA YÜKLENİYOR..." : "KENDİ İSMİMLE SİBER AĞA KATIL",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "NOT: OTODNA Gazi Protokolü Gereği %12 Karargah Payı Sisteme Gömülüdür.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: SiberTema.textMuted, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: primaryCyan.withOpacity(0.3)), color: primaryCyan.withOpacity(0.05)),
          child: const Icon(Icons.shield_outlined, color: primaryCyan, size: 48),
        ),
        const SizedBox(height: 24),
        const Text("OTODNA TİCARİ İSTİHBARAT AĞI", textAlign: TextAlign.center, style: TextStyle(color: SiberTema.textMain, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
        const SizedBox(height: 12),
        const Text("Dükkanınızı kendi markanızla kuantum ağına bağlayın.", textAlign: TextAlign.center, style: TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSiberTextField(TextEditingController controller, String hint, IconData icon, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        textCapitalization: TextCapitalization.characters,
        style: const TextStyle(color: SiberTema.textMain, fontSize: 14, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: SiberTema.textMain.withOpacity(0.2), fontSize: 11, fontWeight: FontWeight.bold),
          prefixIcon: Icon(icon, color: SiberTema.textMuted, size: 20),
          filled: true,
          fillColor: surfaceColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primaryCyan, width: 1.5)),
        ),
        validator: (value) => value!.isEmpty ? 'ZORUNLU ALAN EKSİK' : null,
      ),
    );
  }

  Widget _buildKonumRadari() {
    bool konumBulundu = _secilenKoordinat != null;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: konumBulundu ? primaryCyan.withOpacity(0.3) : dangerColor.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.radar, color: konumBulundu ? primaryCyan : dangerColor, size: 20),
              const SizedBox(width: 12),
              Text("İŞ YERİ SİBER KOORDİNATI", style: TextStyle(color: konumBulundu ? primaryCyan : dangerColor, fontSize: 11, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Text(_konumVerisi, textAlign: TextAlign.center, style: TextStyle(color: konumBulundu ? Colors.white : Colors.white38, fontSize: 10, fontFamily: 'monospace')),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isLocationScanning ? null : _konumuMudurle,
              style: OutlinedButton.styleFrom(foregroundColor: primaryCyan, side: const BorderSide(color: primaryCyan)),
              icon: const Icon(Icons.my_location, size: 18),
              label: Text(konumBulundu ? "KONUMU YENİDEN TARA" : "UYDU BAĞLANTISI KUR", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}