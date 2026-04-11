import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// 🦅 OTODNA ESNAF KAYIT TERMİNALİ - V5 (ŞEFFAF KİMLİK PROTOKOLÜ)
/// [2026-03-28] GÜNCELLEME: Murat Plaza imtiyazı silindi. Herkes kendi adıyla mühürlenir.
/// Mutlak Gazi Finans Protokolü (%12) kayıt anında kilitlenir.
class FirmaKayitScreen extends StatefulWidget {
  const FirmaKayitScreen({super.key});

  @override
  State<FirmaKayitScreen> createState() => _FirmaKayitScreenState();
}

class _FirmaKayitScreenState extends State<FirmaKayitScreen> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  static const Color bgColor = Color(0xFF000000);
  static const Color surfaceColor = Color(0xFF111111);
  static const Color primaryCyan = Color(0xFF00FFC2);
  static const Color dangerColor = Colors.redAccent;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firmaAdiCtrl = TextEditingController();
  final TextEditingController _vergiNoCtrl = TextEditingController();
  final TextEditingController _yetkiliCtrl = TextEditingController();

  String? _secilenSehir;
  bool _isProcessing = false;
  bool _isUploading = false;
  bool _belgeYuklendi = false;

  // 🚀 GERÇEK VERİTABANI İÇİN ŞEHİR LİSTESİ (81 İL İSKELETİ)
  final List<String> sehirler = ["ANKARA", "İSTANBUL", "İZMİR", "ANTALYA", "BURSA", "ADANA", "KONYA"];

  // 🚀 SİBER BELGE YÜKLEME MOTORU (Firebase Storage Hazırlığı)
  Future<void> _belgeYukle() async {
    setState(() => _isUploading = true);

    // Gerçek sistemde file_picker ve Firebase Storage uploadTask çalışacak
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() {
      _isUploading = false;
      _belgeYuklendi = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("KRİPTOLU BELGELER AĞA MÜHÜRLENDİ 🦅", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1)),
        backgroundColor: primaryCyan,
      ),
    );
  }

  // 🚀 FİREBASE KAYIT ATEŞLEME MOTORU (MUTLAK FİNANS ENTEGRASYONU)
  Future<void> _kaydiTamamla() async {
    if (!_formKey.currentState!.validate()) return;

    if (_secilenSehir == null) {
      _hataGoster("SİBER İHLAL: HİZMET VERİLECEK İL SEÇİLMEDİ!");
      return;
    }

    if (!_belgeYuklendi) {
      _hataGoster("SİBER İHLAL: RUHSAT VE İMZA SİRKÜLERİ YÜKLENMEDİ!");
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // 🛡️ SİBER MÜHÜR: Doğrudan 'bayiler' koleksiyonuna şeffaf kayıt
      await FirebaseFirestore.instance.collection('bayiler').add({
        "dealer_name": _firmaAdiCtrl.text.trim().toUpperCase(),
        "tax_number": _vergiNoCtrl.text.trim(),
        "yetkili": _yetkiliCtrl.text.trim().toUpperCase(),
        "city": _secilenSehir,
        "region": "Bölge Belirleniyor", // Koordinat servisinden gelecek
        "rozet": "Bronz",
        "aktif_mi": false, // Karargah onayı bekliyor
        "belgeler_tam_mi": true,

        // 💰 MUTLAK GAZİ PROTOKOLÜ: %12 (%10 Kâr + %2 Vergi)
        // Murat Plaza dahil istisnasız tüm ağ için standart kilit.
        "komisyon_orani": 0.12,

        "kayit_tarihi": FieldValue.serverTimestamp(),
        "durum": "ANKARA MERKEZ ONAYI BEKLİYOR",
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("KİMLİK VE FİNANSAL MÜHÜR AĞA İŞLENDİ. ONAY BEKLENİYOR.", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: primaryCyan,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _hataGoster("AĞ BAĞLANTI HATASI: $e");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _hataGoster(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mesaj, style: const TextStyle(fontWeight: FontWeight.bold)), backgroundColor: dangerColor));
  }

  @override
  void dispose() {
    _firmaAdiCtrl.dispose();
    _vergiNoCtrl.dispose();
    _yetkiliCtrl.dispose();
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
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('E S N A F   K A Y I T   P R O T O K O L Ü', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.domain_verification, color: primaryCyan, size: 64),
                  const SizedBox(height: 16),
                  const Text("OTODNA TİCARİ AĞINA KATILIM", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 8),
                  const Text("Öz isminiz ve vergi numaranızla siber ağa mühürlenin.\n%12 Gazi Finans Protokolü sisteme gömülüdür.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.5, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 40),

                  _buildSiberTextField(_firmaAdiCtrl, "FİRMA ÖZ ADI (ÖR: EGE OTOMOTİV)", Icons.business_outlined),
                  const SizedBox(height: 16),
                  _buildSiberTextField(_yetkiliCtrl, "YETKİLİ AD SOYAD", Icons.person_outline),
                  const SizedBox(height: 16),
                  _buildSiberTextField(_vergiNoCtrl, "VERGİ NUMARASI / TC KİMLİK", Icons.account_balance_outlined, isNumber: true),
                  const SizedBox(height: 16),

                  _buildSiberDropdown(),

                  const SizedBox(height: 32),
                  _buildBelgeYuklemeKarti(),
                  const SizedBox(height: 48),

                  SizedBox(
                    height: 64,
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _kaydiTamamla,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryCyan,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: _isProcessing
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                          : const Icon(Icons.security, size: 24),
                      label: Text(
                        _isProcessing ? "AĞA MÜHÜRLENİYOR..." : "KENDİ İSMİMLE AĞA KATIL",
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

  Widget _buildSiberTextField(TextEditingController controller, String hint, IconData icon, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      textCapitalization: TextCapitalization.characters,
      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 11, fontWeight: FontWeight.bold),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primaryCyan, width: 1.5)),
      ),
      validator: (value) => value!.isEmpty ? 'BU ALAN ZORUNLUDUR' : null,
    );
  }

  Widget _buildSiberDropdown() {
    return DropdownButtonFormField<String>(
      value: _secilenSehir,
      icon: const Icon(Icons.expand_more, color: primaryCyan),
      dropdownColor: surfaceColor,
      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: "HİZMET VERİLECEK İL",
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 11, fontWeight: FontWeight.bold),
        prefixIcon: const Icon(Icons.map_outlined, color: Colors.white38, size: 20),
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
      items: sehirler.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
      onChanged: (val) => setState(() => _secilenSehir = val),
    );
  }

  Widget _buildBelgeYuklemeKarti() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _belgeYuklendi ? primaryCyan.withOpacity(0.3) : Colors.white.withOpacity(0.05), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(
            _belgeYuklendi ? Icons.verified_user_outlined : Icons.upload_file_outlined,
            color: _belgeYuklendi ? primaryCyan : Colors.white38,
            size: 40,
          ),
          const SizedBox(height: 16),
          Text(
            _belgeYuklendi ? "RESMİ BELGELER AĞA MÜHÜRLENDİ" : "RUHSAT VE İMZA SİRKÜLERİ",
            textAlign: TextAlign.center,
            style: TextStyle(color: _belgeYuklendi ? primaryCyan : Colors.white70, fontSize: 11, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          if (!_belgeYuklendi)
            OutlinedButton.icon(
              onPressed: _isUploading ? null : _belgeYukle,
              style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: BorderSide(color: Colors.white.withOpacity(0.2))),
              icon: _isUploading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.cloud_upload_outlined, size: 16),
              label: Text(_isUploading ? "ŞİFRELENİYOR..." : "DOSYA SEÇ", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
            ),
        ],
      ),
    );
  }
}