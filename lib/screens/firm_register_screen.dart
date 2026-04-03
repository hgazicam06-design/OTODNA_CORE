import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      _secilenKoordinat = const GeoPoint(39.967, 32.748); // Örnek Merkez
      _isLocationScanning = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("GPS RADARI: Konum Kilitlendi 🦅", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: primaryCyan));
  }

  // 🚀 FİREBASE KAYIT MOTORU
  Future<void> _kaydiTamamla() async {
    if (!_formKey.currentState!.validate()) return;

    if (_secilenKoordinat == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("SİBER İHLAL: Lütfen önce konum mühürleyin!", style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: dangerColor));
      return;
    }

    setState(() => _isProcessing = true);

    try {
      await FirebaseFirestore.instance.collection('bayi_basvurulari').add({
        "isim": _firmaAdiCtrl.text.trim().toUpperCase(),
        "yetkili": _yetkiliCtrl.text.trim().toUpperCase(),
        "vergi_no": _vergiNoCtrl.text.trim(),
        "koordinat": _secilenKoordinat,
        "adres": _konumVerisi,
        "bolge": "İç Anadolu", // Gerçekte koordinattan tersine çözülecek
        "durum": "Bekliyor", // Ankara Merkez Karargahı onaylayacak
        "basvuru_tarihi": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("BAŞVURU MERKEZ KARARGAHA İLETİLDİ!", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: primaryCyan));
      Navigator.pop(context); // Terminali Kapat
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("AĞ HATASI: $e", style: const TextStyle(fontWeight: FontWeight.bold)), backgroundColor: dangerColor));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _firmaAdiCtrl.dispose();
    _yetkiliCtrl.dispose();
    _vergiNoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Web Uyumluluğu
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('B A Y İ   A Ğ I   K A Y I T   T E R M İ N A L İ', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 3)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800), // Ortada kilitli panel
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

                  // FİRMA BİLGİLERİ (Siber TextFields)
                  _buildSiberTextField(_firmaAdiCtrl, "FİRMA ADI (ÖR: YILDIZ ROT BALANS)", Icons.business_outlined),
                  _buildSiberTextField(_yetkiliCtrl, "YETKİLİ AD SOYAD", Icons.person_outline),
                  _buildSiberTextField(_vergiNoCtrl, "VERGİ NO / ESNAF ODASI NO", Icons.assignment_ind_outlined, isNumber: true),

                  const SizedBox(height: 32),

                  // KONUM RADARI
                  _buildKonumRadari(),

                  const SizedBox(height: 48),

                  // ATEŞLEME BUTONU
                  SizedBox(
                    height: 64,
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _kaydiTamamla,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryCyan,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        disabledBackgroundColor: primaryCyan.withOpacity(0.3),
                      ),
                      icon: _isProcessing
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                          : const Icon(Icons.satellite_alt_rounded, size: 24),
                      label: Text(
                        _isProcessing ? "AĞA YÜKLENİYOR..." : "FİRMAYI SİBER AĞA MÜHÜRLE",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: SİBER BAŞLIK
  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: primaryCyan.withOpacity(0.3)), color: primaryCyan.withOpacity(0.05)),
          child: const Icon(Icons.shield_outlined, color: primaryCyan, size: 48),
        ),
        const SizedBox(height: 24),
        const Text("OTODNA TİCARİ İSTİHBARAT AĞI", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
        const SizedBox(height: 12),
        const Text("Dükkanınızı kuantum ağına bağlayarak milyonlarca\nmüşterinin radarına girin.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, height: 1.5)),
      ],
    );
  }

  // 💎 YARDIMCI BİLEŞEN: SİBER TEXTFIELD
  Widget _buildSiberTextField(TextEditingController controller, String hint, IconData icon, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        textCapitalization: TextCapitalization.characters, // Daima büyük harf zorunlu
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
          prefixIcon: Icon(icon, color: Colors.white38, size: 20),
          filled: true,
          fillColor: surfaceColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primaryCyan, width: 1.5)),
          errorStyle: const TextStyle(color: dangerColor, fontWeight: FontWeight.bold),
        ),
        validator: (value) => value!.isEmpty ? 'ZORUNLU ALAN EKSİK' : null,
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: GPS RADARI (KONUM MÜHRÜ)
  Widget _buildKonumRadari() {
    bool konumBulundu = _secilenKoordinat != null;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: konumBulundu ? primaryCyan.withOpacity(0.05) : dangerColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: konumBulundu ? primaryCyan.withOpacity(0.3) : dangerColor.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.radar, color: konumBulundu ? primaryCyan : dangerColor, size: 20),
              const SizedBox(width: 12),
              Text(
                "İŞ YERİ SİBER KOORDİNATI",
                style: TextStyle(color: konumBulundu ? primaryCyan : dangerColor, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Radar Ekranı
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
              // Gerçekte buraya Google Haritalar Widget'i gelecek
            ),
            child: Center(
              child: _isLocationScanning
                  ? const CircularProgressIndicator(color: primaryCyan, strokeWidth: 2)
                  : Icon(konumBulundu ? Icons.satellite_alt : Icons.location_off_outlined, color: Colors.white12, size: 48),
            ),
          ),

          const SizedBox(height: 24),

          // Konum Logu
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
            child: Text(
              _konumVerisi,
              textAlign: TextAlign.center,
              style: TextStyle(color: konumBulundu ? Colors.white : Colors.white38, fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ),

          const SizedBox(height: 16),

          // Tarama Butonu
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isLocationScanning ? null : _konumuMudurle,
              style: OutlinedButton.styleFrom(
                foregroundColor: konumBulundu ? primaryCyan : dangerColor,
                side: BorderSide(color: konumBulundu ? primaryCyan.withOpacity(0.5) : dangerColor.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.my_location, size: 18),
              label: Text(
                konumBulundu ? "KONUMU YENİDEN TARA" : "UYDU BAĞLANTISI KUR VE İŞARETLE",
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}