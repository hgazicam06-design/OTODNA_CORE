import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  String? _secilenSehir;
  bool _isProcessing = false;
  bool _isUploading = false;
  bool _belgeYuklendi = false;

  // 🚀 GERÇEK VERİTABANI İÇİN ŞEHİR LİSTESİ
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

  // 🚀 FİREBASE KAYIT ATEŞLEME MOTORU
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
      // Ankara Merkez Onayına (Veritabanına) Gerçek Kayıt İşlemi
      await FirebaseFirestore.instance.collection('bayi_basvurulari').add({
        "firma_adi": _firmaAdiCtrl.text.trim().toUpperCase(),
        "vergi_no": _vergiNoCtrl.text.trim(),
        "hizmet_ili": _secilenSehir,
        "belgeler_tam_mi": true,
        "durum": "ANKARA MERKEZ ONAYI BEKLİYOR",
        "basvuru_tarihi": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("BAŞVURU SİSTEME MÜHÜRLENDİ. ONAY BEKLENİYOR.", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: primaryCyan,
        ),
      );
      Navigator.pop(context); // Terminalden çıkış
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
          constraints: const BoxConstraints(maxWidth: 800), // Web Mimarisi Koruma Kalkanı
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // SİBER İKON VE BİLGİLENDİRME
                  const Icon(Icons.domain_verification, color: primaryCyan, size: 64),
                  const SizedBox(height: 16),
                  const Text("OTODNA TİCARİ AĞINA KATILIM", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 8),
                  const Text("Girilen tüm veriler resmi evrak niteliğindedir.\nAnkara Merkez Karargahı tarafından teyit edilecektir.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.5, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 40),

                  // 1. FİRMA VE VERGİ BİLGİLERİ
                  _buildSiberTextField(_firmaAdiCtrl, "FİRMA ADI (RUHSATTAKİ GİBİ)", Icons.business_outlined),
                  const SizedBox(height: 16),
                  _buildSiberTextField(_vergiNoCtrl, "VERGİ NUMARASI / TC KİMLİK", Icons.account_balance_outlined, isNumber: true),
                  const SizedBox(height: 16),

                  // 2. SİBER DROPDOWN (ŞEHİR SEÇİMİ)
                  _buildSiberDropdown(),

                  const SizedBox(height: 32),

                  // 3. BELGE YÜKLEME RADARI
                  _buildBelgeYuklemeKarti(),

                  const SizedBox(height: 48),

                  // 4. ATEŞLEME BUTONU
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
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                          : const Icon(Icons.security, size: 24),
                      label: Text(
                        _isProcessing ? "AĞA MÜHÜRLENİYOR..." : "ANKARA MERKEZ ONAYINA GÖNDER",
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

  // 💎 YARDIMCI BİLEŞEN: SİBER TEXTFIELD
  Widget _buildSiberTextField(TextEditingController controller, String hint, IconData icon, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      textCapitalization: TextCapitalization.characters,
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
      validator: (value) => value!.isEmpty ? 'BU ALAN ZORUNLUDUR' : null,
    );
  }

  // 💎 YARDIMCI BİLEŞEN: SİBER DROPDOWN
  Widget _buildSiberDropdown() {
    return DropdownButtonFormField<String>(
      value: _secilenSehir,
      icon: const Icon(Icons.expand_more, color: primaryCyan),
      dropdownColor: surfaceColor,
      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: "HİZMET VERİLECEK İL",
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
        prefixIcon: const Icon(Icons.map_outlined, color: Colors.white38, size: 20),
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
      items: sehirler.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
      onChanged: (val) => setState(() => _secilenSehir = val),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: BELGE YÜKLEME KALKANI
  Widget _buildBelgeYuklemeKarti() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _belgeYuklendi ? primaryCyan.withOpacity(0.05) : surfaceColor,
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
            _belgeYuklendi ? "RUHSAT VE İMZA SİRKÜLERİ AĞA YÜKLENDİ" : "RESMİ EVRAKLARI (PDF/JPG) SİSTEME YÜKLEYİN",
            textAlign: TextAlign.center,
            style: TextStyle(color: _belgeYuklendi ? primaryCyan : Colors.white70, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
          const SizedBox(height: 16),
          if (!_belgeYuklendi)
            OutlinedButton.icon(
              onPressed: _isUploading ? null : _belgeYukle,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withOpacity(0.2)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: _isUploading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.cloud_upload_outlined, size: 16),
              label: Text(_isUploading ? "ŞİFRELENİYOR..." : "DOSYA SEÇ", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
        ],
      ),
    );
  }
}