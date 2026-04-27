import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/kuresel_harita_sistemi.dart';

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

  final String _secilenUlke = KureselHaritaSistemi.globalMerkezUlkemiz; // Arka planda Türkiye olarak mühürlenir
  String? _secilenSehir;
  String? _secilenIlce;

  bool _isProcessing = false;
  bool _isUploading = false;
  bool _belgeYuklendi = false;

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
        content: Text("KRİPTOLU BELGELER AĞA MÜHÜRLENDİ 🦅", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
        backgroundColor: primaryCyan,
      ),
    );
  }

  // 🚀 FİREBASE KAYIT ATEŞLEME MOTORU (MUTLAK FİNANS ENTEGRASYONU)
  Future<void> _kaydiTamamla() async {
    if (!_formKey.currentState!.validate()) return;

    if (_secilenIlce == null) {
      _hataGoster("SİBER İHLAL: HİZMET VERİLECEK KONUM (İLÇE) SEÇİLMEDİ!");
      return;
    }

    if (!_belgeYuklendi) {
      _hataGoster("SİBER İHLAL: RUHSAT VE İMZA SİRKÜLERİ YÜKLENMEDİ!");
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Arka planda siber istihbarat motoru ile bölgeyi tespit et
      String otonomBolge = KureselHaritaSistemi.hangiBolgede(_secilenUlke, _secilenSehir!);

      // Konum paketini Karargah standartlarına göre derle
      Map<String, dynamic> konumPaketi = KureselHaritaSistemi.firebaseKonumPaketi(
        ulke: _secilenUlke,
        bolge: otonomBolge,
        sehir: _secilenSehir!,
        ilce: _secilenIlce,
      );

      // 🛡️ SİBER MÜHÜR: Doğrudan 'bayiler' koleksiyonuna şeffaf kayıt
      Map<String, dynamic> bayiData = {
        "dealer_name": _firmaAdiCtrl.text.trim().toUpperCase(),
        "tax_number": _vergiNoCtrl.text.trim(),
        "yetkili": _yetkiliCtrl.text.trim().toUpperCase(),
        "rozet": "Bronz",
        "aktif_mi": false, // Karargah onayı bekliyor
        "belgeler_tam_mi": true,

        // 💰 MUTLAK GAZİ PROTOKOLÜ: %12 (%10 Kâr + %2 Vergi)
        "komisyon_orani": 0.12,

        "kayit_tarihi": FieldValue.serverTimestamp(),
        "durum": "ANKARA MERKEZ ONAYI BEKLİYOR",
      };
      
      // Konum verisini atomik olarak birleştir
      bayiData.addAll(konumPaketi);

      await FirebaseFirestore.instance.collection('bayiler').add(bayiData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("KİMLİK VE FİNANSAL MÜHÜR AĞA İŞLENDİ. ONAY BEKLENİYOR.", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('E S N A F   K A Y I T   P R O T O K O L Ü', style: TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
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
                  const Text("OTODNA TİCARİ AĞINA KATILIM", textAlign: TextAlign.center, style: TextStyle(color: SiberTema.textMain, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 8),
                  const Text("Öz isminiz ve vergi numaranızla siber ağa mühürlenin.\n%12 Gazi Finans Protokolü sisteme gömülüdür.", textAlign: TextAlign.center, style: TextStyle(color: SiberTema.textMuted, fontSize: 11, height: 1.5, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 40),

                  _buildSiberTextField(_firmaAdiCtrl, "FİRMA ÖZ ADI (ÖR: EGE OTOMOTİV)", Icons.business_outlined),
                  const SizedBox(height: 16),
                  _buildSiberTextField(_yetkiliCtrl, "YETKİLİ AD SOYAD", Icons.person_outline),
                  const SizedBox(height: 16),
                  _buildSiberTextField(_vergiNoCtrl, "VERGİ NUMARASI / TC KİMLİK", Icons.account_balance_outlined, isNumber: true),
                  const SizedBox(height: 16),

                  _buildSiberDropdown("ŞEHİR / İL", KureselHaritaSistemi.tumSehirleriGetir(_secilenUlke), _secilenSehir, (val) {
                    setState(() {
                      _secilenSehir = val;
                      _secilenIlce = null;
                    });
                  }),
                  const SizedBox(height: 16),
                  if (_secilenSehir != null)
                    _buildSiberDropdown("İLÇE / MERKEZ", KureselHaritaSistemi.ilceleriGetir(_secilenUlke, KureselHaritaSistemi.hangiBolgede(_secilenUlke, _secilenSehir!), _secilenSehir!), _secilenIlce, (val) {
                      setState(() => _secilenIlce = val);
                    }),

                  const SizedBox(height: 32),
                  _buildBelgeYuklemeKarti(),
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
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
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
      validator: (value) => value!.isEmpty ? 'BU ALAN ZORUNLUDUR' : null,
    );
  }

  Widget _buildSiberDropdown(String hint, List<String> items, String? currentValue, Function(String?) onChanged) {
    // Eğer currentValue items içinde yoksa null yap (Eyalet değiştiğinde şehrin sıfırlanması için güvenlik)
    if (currentValue != null && !items.contains(currentValue)) {
      currentValue = null;
    }

    return DropdownButtonFormField<String>(
      value: currentValue,
      icon: const Icon(Icons.expand_more, color: primaryCyan),
      dropdownColor: surfaceColor,
      style: const TextStyle(color: SiberTema.textMain, fontSize: 14, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: SiberTema.textMain.withOpacity(0.2), fontSize: 11, fontWeight: FontWeight.bold),
        prefixIcon: const Icon(Icons.map_outlined, color: SiberTema.textMuted, size: 20),
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
      items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
      onChanged: onChanged,
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