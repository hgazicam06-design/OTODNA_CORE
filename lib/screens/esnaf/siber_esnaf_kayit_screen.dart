import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

/// 🏢 SİBER ESNAF KAYIT (ONBOARDING) EKRANI
/// Trendyol usulü güvenli dükkan kaydı ve evrak yükleme arayüzü.
class SiberEsnafKayitScreen extends StatefulWidget {
  const SiberEsnafKayitScreen({super.key});

  @override
  State<SiberEsnafKayitScreen> createState() => _SiberEsnafKayitScreenState();
}

class _SiberEsnafKayitScreenState extends State<SiberEsnafKayitScreen> {
  int _currentStep = 0;
  bool _islemSuruyor = false;

  // 1. ADIM KONTROLLERİ
  final TextEditingController _firmaAdCtrl = TextEditingController();
  final TextEditingController _yetkiliAdCtrl = TextEditingController();
  final TextEditingController _isTelCtrl = TextEditingController();
  final TextEditingController _wpTelCtrl = TextEditingController();

  // 2. ADIM: KONUM SİMÜLASYONU (İleride Dropdown'a bağlanacak)
  String _secilenUlke = "Türkiye";
  String _secilenBolge = "Marmara";
  String _secilenSehir = "İstanbul";
  String _secilenIlce = "Maslak";

  // 3. ADIM: KARANLIK ODA (EVRAKLAR)
  File? _vergiLevhasi;
  File? _ustalikBelgesi;
  bool _adliProtokolOnay = false;

  void _siberUyari(String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: TextStyle(color: renk, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
      backgroundColor: Colors.black87,
      shape: RoundedRectangleBorder(side: BorderSide(color: renk), borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _ileriGit() {
    if (_currentStep == 0) {
      if (_firmaAdCtrl.text.isEmpty || _yetkiliAdCtrl.text.isEmpty) {
        _siberUyari("Lütfen zorunlu alanları doldurun.", SiberTema.kanKirmizi);
        return;
      }
    }
    
    if (_currentStep == 1) {
      // Konum validasyonu
    }

    if (_currentStep == 2) {
      if (!_adliProtokolOnay) {
        _siberUyari("Yasal Adli Protokolü onaylamanız zorunludur.", Colors.orangeAccent);
        return;
      }
      _kaydiTamamla();
      return;
    }

    HapticFeedback.lightImpact();
    setState(() => _currentStep++);
  }

  void _geriGit() {
    if (_currentStep > 0) {
      HapticFeedback.lightImpact();
      setState(() => _currentStep--);
    }
  }

  Future<void> _kaydiTamamla() async {
    setState(() => _islemSuruyor = true);
    HapticFeedback.heavyImpact();
    
    // Simüle edilmiş kayıt süresi
    await Future.delayed(const Duration(seconds: 3));
    
    setState(() => _islemSuruyor = false);
    _siberUyari("EVRAKLAR KARARGAHA GÖNDERİLDİ! Onay süreci başladı.", SiberTema.kuantumCyan);
    
    // Gerçekte Navigator.pop veya Onay Bekliyor ekranına yönlendirilecek.
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.8),
          elevation: 0,
          title: const Text("🛡️ SİBER GARAJ KAYDI", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
          centerTitle: true,
          iconTheme: const IconThemeData(color: SiberTema.kuantumCyan),
        ),
        body: _buildCyberStepper(),
      ),
    );
  }

  Widget _buildCyberStepper() {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.dark(
          primary: SiberTema.kuantumCyan,
          surface: SiberTema.matGrey,
        ),
      ),
      child: Stepper(
        currentStep: _currentStep,
        onStepContinue: _ileriGit,
        onStepCancel: _geriGit,
        type: StepperType.vertical,
        physics: const BouncingScrollPhysics(),
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _islemSuruyor ? null : details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SiberTema.kuantumCyan,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _islemSuruyor 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                        : Text(_currentStep == 2 ? "KAYDI KARARGAHA İLET" : "İLERİ", style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text("GERİ", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
                  ),
                ]
              ],
            ),
          );
        },
        steps: [
          _buildAdim1(),
          _buildAdim2(),
          _buildAdim3(),
        ],
      ),
    );
  }

  // ── ADIM 1: FİRMA VE İLETİŞİM ──
  Step _buildAdim1() {
    return Step(
      title: const Text("Firma & İletişim Zırhı", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.bold, fontSize: 16)),
      content: _buildGlassContainer(
        child: Column(
          children: [
            const Text("Müşterilerin size ulaşacağı resmi bilgileri girin.", style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 20),
            _buildSiberTextField("Dükkan / Firma Adı", Icons.store_rounded, _firmaAdCtrl),
            const SizedBox(height: 16),
            _buildSiberTextField("Firma Yetkilisi Ad-Soyad", Icons.person_rounded, _yetkiliAdCtrl),
            const SizedBox(height: 16),
            _buildSiberTextField("Sabit İş Telefonu", Icons.phone_rounded, _isTelCtrl, type: TextInputType.phone),
            const SizedBox(height: 16),
            _buildSiberTextField("WhatsApp Destek Hattı", Icons.chat_rounded, _wpTelCtrl, type: TextInputType.phone),
          ],
        ),
      ),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
    );
  }

  // ── ADIM 2: KUANTUM KONUM ──
  Step _buildAdim2() {
    return Step(
      title: const Text("Kuantum Konum (4 Katman)", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.bold, fontSize: 16)),
      content: _buildGlassContainer(
        child: Column(
          children: [
            const Text("Milisaniyelik harita aramalarında bulunabilmeniz için tam konumunuz.", style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 20),
            // İleride Dropdown API'ye bağlanacak, şimdilik mock UI
            _buildMockDropdown("Ülke", _secilenUlke),
            const SizedBox(height: 12),
            _buildMockDropdown("Bölge", _secilenBolge),
            const SizedBox(height: 12),
            _buildMockDropdown("Şehir", _secilenSehir),
            const SizedBox(height: 12),
            _buildMockDropdown("İlçe (Mikro-İstihbarat Merkezi)", _secilenIlce),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: const Row(
                children: [
                  Icon(Icons.location_on_rounded, color: SiberTema.kuantumCyan, size: 24),
                  SizedBox(width: 12),
                  Expanded(child: Text("Siber Harita Konumunuz (GeoPoint) sistem tarafından arka planda otomatik çekilecektir.", style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.4))),
                ],
              ),
            )
          ],
        ),
      ),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
    );
  }

  // ── ADIM 3: KARANLIK ODA (EVRAKLAR) ──
  Step _buildAdim3() {
    return Step(
      title: const Text("Karanlık Oda & Evrak Onayı", style: TextStyle(color: SiberTema.kanKirmizi, fontWeight: FontWeight.bold, fontSize: 16)),
      content: _buildGlassContainer(
        borderColor: SiberTema.kanKirmizi.withOpacity(0.5),
        child: Column(
          children: [
            const Text("DİKKAT: Yükleyeceğiniz evraklar SADECE Kuantum Karargahı (Admin) tarafından görülür. Müşterilere ASLA açık değildir.", 
                style: TextStyle(color: SiberTema.kanKirmizi, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildResimSeciciBox("Vergi Levhası (Zorunlu)", _vergiLevhasi)),
                const SizedBox(width: 12),
                Expanded(child: _buildResimSeciciBox("Ustalık Belgesi (Opsiyonel)", _ustalikBelgesi)),
              ],
            ),
            const SizedBox(height: 30),
            // ⚖️ ADLİ PROTOKOL
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: SiberTema.kanKirmizi.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: SiberTema.kanKirmizi.withOpacity(0.3))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Theme(
                    data: Theme.of(context).copyWith(unselectedWidgetColor: Colors.white54),
                    child: Checkbox(
                      value: _adliProtokolOnay,
                      activeColor: SiberTema.kanKirmizi,
                      checkColor: Colors.white,
                      onChanged: (val) => setState(() => _adliProtokolOnay = val ?? false),
                    ),
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        "Evraklarımın Kuantum Karargahı tarafından onaylanana kadar vitrine (arama sonuçlarına) ÇIKAMAYACAĞINI anladım ve kabul ediyorum.",
                        style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.5),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      isActive: _currentStep >= 2,
    );
  }

  // ── YARDIMCI WIDGET'LAR ──
  Widget _buildGlassContainer({required Widget child, Color? borderColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? SiberTema.kuantumCyan.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: (borderColor ?? SiberTema.kuantumCyan).withOpacity(0.02), blurRadius: 20)],
      ),
      child: child,
    );
  }

  Widget _buildSiberTextField(String hint, IconData icon, TextEditingController controller, {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      keyboardType: type,
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: SiberTema.kuantumCyan, size: 20),
        filled: true,
        fillColor: Colors.black45,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SiberTema.kuantumCyan)),
      ),
    );
  }

  Widget _buildMockDropdown(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          Row(
            children: [
              Text(value, style: const TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_drop_down, color: SiberTema.kuantumCyan),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildResimSeciciBox(String baslik, File? resimFile) {
    return GestureDetector(
      onTap: () {
        // İleride ImagePicker entegre edilecek
        _siberUyari("Kamera modülü üretim aşamasında entegre edilecek.", SiberTema.kuantumCyan);
      },
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: resimFile != null ? SiberTema.kanKirmizi : Colors.white24, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.drive_folder_upload_rounded, color: resimFile != null ? SiberTema.kanKirmizi : Colors.white38, size: 36),
            const SizedBox(height: 8),
            Text(baslik, style: TextStyle(color: resimFile != null ? SiberTema.kanKirmizi : Colors.white54, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
          ],
        ),
      ),
    );
  }
}
