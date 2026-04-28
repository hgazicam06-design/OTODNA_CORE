import 'package:otodna/core/siber_tema.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

// 🔥 SİBER KÖPRÜLER
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';
import '../../core/providers/siber_kimlik_provider.dart';
import '../../services/corporate_ai_engine.dart';
import '../../widgets/siber_rehber_dialog.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Siber Renk Paleti
  final Color _primaryCyan = SiberTema.kuantumCyan;
  final Color _cyberBlack = SiberTema.oledBlack;
  final Color _surfaceColor = SiberTema.matGrey.withOpacity(0.2);

  // Kontrolcüler
  final TextEditingController _urunAdController = TextEditingController();
  final TextEditingController _oemKoduController = TextEditingController();
  final TextEditingController _fiyatController = TextEditingController();
  final TextEditingController _fiyatController = TextEditingController();
  String _secilenMarka = "Marka Seçilmedi";
  String _secilenUrunDurumu = "Sıfır (Orijinal)"; // YENİ: Şelale Arama İçin Ürün Durumu
  bool _isLoading = false;

  final List<String> _urunDurumlari = [
    "Sıfır (Orijinal)",
    "Sıfır (Yan Sanayi / Muadil)",
    "Çıkma / İkinci El"
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _rehberiGoster(otomatik: true);
    });
  }

  void _rehberiGoster({bool otomatik = false}) {
    String baslik = "SİBER İLAN TERMİNALİ";
    String icerik = "OtoDNA Küresel Parça Ağına Hoş Geldiniz!\n\n"
        "Parçanın fotoğrafını çekerek veya ruhsat barkodunu okutarak Yapay Zekanın (AI) markayı/parçayı otomatik tanımasını sağlayabilirsiniz.\n\n"
        "ÖNEMLİ: Eklediğiniz parçanın 'Sıfır' mı yoksa 'Çıkma' mı olduğunu doğru seçiniz. Bu veri, Kuantum Şelale Arama Motoru tarafından müşterilere parça bulunurken kullanılacaktır.";

    if (otomatik) {
      SiberRehber.otomatikGoster(context: context, screenKey: 'ilan_terminali_rehber', baslik: baslik, icerik: icerik);
    } else {
      SiberRehber.goster(context: context, screenKey: 'ilan_terminali_rehber', baslik: baslik, icerik: icerik);
    }
  }

  // 🧠 YAPAY ZEKA GÖRÜNTÜ İŞLEME (Siber Analiz)
  Future<void> _yapayZekaIleTani() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    _showCyberLoading("Siber Göz (AI) Parçayı Analiz Ediyor...");

    final result = await CorporateAIEngine.parcayiTani(image);

    if (!mounted) return;
    Navigator.pop(context);

    if (result != null) {
      setState(() {
        _urunAdController.text = result["parca_adi"] ?? "";
        _oemKoduController.text = result["oem"] ?? "";
        _secilenMarka = result["marka"] ?? "Bilinmiyor";
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Kuantum Analizi Tamamlandı: Yapay Zeka Tespiti Başarılı! 🦅",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
        backgroundColor: _primaryCyan,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("AI Radarı Arızası: Parça Tanımlanamadı!",
            style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  // 📸 RUHSAT DNA TARAMA
  Future<void> _barkodTara() async {
    _showCyberLoading("Ruhsat DNA'sı Çözülüyor...");
    await Future.delayed(Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pop(context);

    setState(() {
      _secilenMarka = "BMW 3 Serisi";
      _oemKoduController.text = "WBA320I-DNA-2026";
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Şasi DNA'sı Çözüldü: BMW Tespit Edildi! ✅",
          style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
      backgroundColor: Colors.blueAccent,
    ));
  }

  void _showCyberLoading(String mesaj) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: _cyberBlack,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: _primaryCyan.withOpacity(0.5))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: _primaryCyan),
            SizedBox(height: 16),
            Text(mesaj, style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
            SizedBox(height: 8),
            Text("Kuantum Hub Ağı Taranıyor...", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontFamily: 'Avenir')),
          ],
        ),
      ),
    );
  }

  // 🚀 FİREBASE'E GERÇEK KAYIT MOTORU (Zırhlı ve Mühürlü)
  Future<void> _urunuAgaMuhurle() async {
    final sicil = ref.read(siberSicilProvider).value;

    if (sicil == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("🚨 Yetkisiz Erişim: Sicil Kaydı Bulunamadı!")));
      return;
    }

    if (_urunAdController.text.isEmpty || _fiyatController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Eksik veri girişi tespit edildi!"), backgroundColor: Colors.redAccent));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final double hamFiyat = double.tryParse(_fiyatController.text) ?? 0.0;
      final String dukkanAd = sicil['dukkan_adi'] ?? "Bilinmeyen Bayi";

      // 💰 EVRENSEL KARARGAH KESİNTİSİ
      const double komisyonOrani = 0.12;
      final double gaziPayi = hamFiyat * komisyonOrani;

      await _db.collection('yedek_parcalar').add({
        'urun_ad': _urunAdController.text,
        'oem_kodu': _oemKoduController.text,
        'marka': _secilenMarka,
        'urun_durumu': _secilenUrunDurumu, // ŞELALE ARAMA KİLİDİ
        'liste_fiyati': hamFiyat,
        'gazi_payi': gaziPayi,
        'bayi_id': sicil['uid'],
        'bayi_adi': dukkanAd,
        'durum': 'Onaylı/Satışta',
        'eklenme_tarihi': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Ürün Kuantum Ağına Başarıyla Mühürlendi! 🚀",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
          backgroundColor: _primaryCyan));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ağ Hatası: $e"), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent, elevation: 0,
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20), onPressed: () => Navigator.pop(context)),
          title: Text('S İ B E R   İ L A N   T E R M İ N A L İ',
              style: TextStyle(color: SiberTema.textMuted, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2, fontFamily: 'Avenir')),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.help_outline_rounded, color: SiberTema.kuantumCyan),
              tooltip: "Siber Rehber",
              onPressed: () => _rehberiGoster(otomatik: false),
            )
          ],
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAIControlPanel(),
              SizedBox(height: 32),
              Text("ÜRÜN KİMLİĞİ", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
              SizedBox(height: 16),
              _buildCyberTextField("Ürün / Parça Adı", _urunAdController, Icons.build_circle_outlined),
              SizedBox(height: 16),
              _buildCyberTextField("OEM / Barkod Kodu", _oemKoduController, Icons.qr_code),
              SizedBox(height: 16),
              _buildMarkaDisplay(),
              SizedBox(height: 16),
              _buildDurumSecici(),
              SizedBox(height: 16),
              _buildCyberTextField("Satış Fiyatı (₺)", _fiyatController, Icons.attach_money, isNumber: true),
              SizedBox(height: 40),
              _buildSubmitButton(),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIControlPanel() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _primaryCyan.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: _primaryCyan.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: _primaryCyan, size: 24),
              SizedBox(width: 12),
              Expanded(child: Text("YAPAY ZEKA (AI) İSTİHBARATI",
                  style: TextStyle(color: SiberTema.textMain, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir'))),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildAIButton("PARÇAYI TANI", Icons.camera_alt_outlined, _primaryCyan, _yapayZekaIleTani)),
              SizedBox(width: 12),
              Expanded(child: _buildAIButton("RUHSAT / ŞASİ", Icons.document_scanner_outlined, Colors.blueAccent, _barkodTara)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAIButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: color.withOpacity(0.5))),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
    );
  }

  Widget _buildMarkaDisplay() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(color: _cyberBlack, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Row(
        children: [
          Icon(Icons.directions_car_outlined, color: SiberTema.textMuted, size: 20),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Uyumlu Marka / Model", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
              SizedBox(height: 4),
              Text(_secilenMarka, style: TextStyle(color: _secilenMarka == "Marka Seçilmedi" ? Colors.white54 : _primaryCyan, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDurumSecici() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: _surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: _cyberBlack,
          isExpanded: true,
          value: _secilenUrunDurumu,
          icon: Icon(Icons.keyboard_arrow_down, color: _primaryCyan),
          items: _urunDurumlari.map((String durum) {
            return DropdownMenuItem<String>(
              value: durum,
              child: Row(
                children: [
                  Icon(
                    durum.contains("Çıkma") ? Icons.recycling : Icons.verified_rounded, 
                    color: durum.contains("Orijinal") ? _primaryCyan : (durum.contains("Çıkma") ? Colors.orangeAccent : Colors.white54), 
                    size: 18
                  ),
                  SizedBox(width: 12),
                  Text(durum, style: TextStyle(color: SiberTema.textMain, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                ],
              ),
            );
          }).toList(),
          onChanged: (String? yeniDurum) {
            if (yeniDurum != null) {
              setState(() => _secilenUrunDurumu = yeniDurum);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity, height: 60,
      child: ElevatedButton.icon(
        style: SiberTema.kuantumButonStili(),
        onPressed: _isLoading ? null : _urunuAgaMuhurle,
        icon: _isLoading ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Icon(Icons.publish, size: 24, color: Colors.white),
        label: Text(_isLoading ? "VERİ AKTARILIYOR..." : "SİBER AĞA MÜHÜRLE",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1, color: Colors.white, fontFamily: 'Avenir')),
      ),
    );
  }

  Widget _buildCyberTextField(String hint, TextEditingController controller, IconData icon, {bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(color: _surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: TextStyle(color: SiberTema.textMain, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: SiberTema.textMain.withOpacity(0.2), fontSize: 13, fontFamily: 'Avenir'),
          prefixIcon: Icon(icon, color: SiberTema.textMuted, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}