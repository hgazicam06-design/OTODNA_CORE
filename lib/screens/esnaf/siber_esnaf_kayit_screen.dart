import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';
import '../../models/dukkan_model.dart';

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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // 1. ADIM KONTROLLERİ
  final TextEditingController _firmaAdCtrl = TextEditingController();
  final TextEditingController _yetkiliAdCtrl = TextEditingController();
  final TextEditingController _isTelCtrl = TextEditingController();
  final TextEditingController _wpTelCtrl = TextEditingController();

  // 2. ADIM: KONUM SİMÜLASYONU (Kuantum Lokasyon)
  String? _secilenUlke;
  String? _secilenBolge;
  String? _secilenSehir;
  String? _secilenIlce;
  
  // Hızlandırılmış Harita Verisi (Cihazı kasmamak için lokalde tutulur)
  final List<String> ulkeler = ["Türkiye"];
  final List<String> bolgeler = ["Marmara", "Ege", "İç Anadolu", "Akdeniz"];
  final Map<String, List<String>> sehirler = {
    "Marmara": ["İstanbul", "Bursa", "Kocaeli", "Tekirdağ", "Edirne"],
    "Ege": ["İzmir", "Aydın", "Muğla", "Manisa", "Denizli"],
    "İç Anadolu": ["Ankara", "Konya", "Kayseri", "Eskişehir"],
    "Akdeniz": ["Antalya", "Adana", "Mersin", "Hatay"],
  };
  final Map<String, List<String>> ilceler = {
    "İstanbul": ["Maslak", "Kadıköy", "Beşiktaş", "Pendik", "Bostancı"],
    "Ankara": ["Çankaya", "Keçiören", "Yenimahalle", "Şaşmaz", "Ostim"],
    "İzmir": ["Bornova", "Karşıyaka", "Buca", "Gaziemir"],
  };

  // 3. ADIM: KARANLIK ODA (EVRAKLAR)
  File? _vergiLevhasi;
  File? _ustalikBelgesi;
  bool _adliProtokolOnay = false;
  final ImagePicker _picker = ImagePicker();

  void _siberUyari(String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: TextStyle(color: renk, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
      backgroundColor: Colors.black87,
      shape: RoundedRectangleBorder(side: BorderSide(color: renk), borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    ));
  }

  void _ileriGit() {
    if (_currentStep == 0) {
      if (!_formKey.currentState!.validate()) {
        _siberUyari("Lütfen zorunlu alanları eksiksiz doldurun.", SiberTema.kanKirmizi);
        HapticFeedback.vibrate();
        return;
      }
    }
    
    if (_currentStep == 1) {
      if (_secilenUlke == null || _secilenBolge == null || _secilenSehir == null || _secilenIlce == null) {
        _siberUyari("Kuantum Konum koordinatları eksik!", SiberTema.kanKirmizi);
        HapticFeedback.vibrate();
        return;
      }
    }

    if (_currentStep == 2) {
      if (_vergiLevhasi == null) {
        _siberUyari("Vergi Levhası (Siber Mühür) zorunludur!", SiberTema.kanKirmizi);
        HapticFeedback.vibrate();
        return;
      }
      if (!_adliProtokolOnay) {
        _siberUyari("Yasal Adli Protokolü onaylamanız zorunludur.", Colors.orangeAccent);
        HapticFeedback.vibrate();
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
    
    try {
      final String epochTarih = DateTime.now().millisecondsSinceEpoch.toString();
      final String dokumanId = _firmaAdCtrl.text.replaceAll(' ', '_').toLowerCase() + "_$epochTarih";
      
      String? vergiUrl;
      String? ustalikUrl;

      // STORAGE YÜKLEME (Sıralı veya paralel)
      if (_vergiLevhasi != null) {
        final ref = FirebaseStorage.instance.ref().child('esnaf_evraklari').child(dokumanId).child('vergi_levhasi.jpg');
        await ref.putFile(_vergiLevhasi!);
        vergiUrl = await ref.getDownloadURL();
      }

      if (_ustalikBelgesi != null) {
        final ref = FirebaseStorage.instance.ref().child('esnaf_evraklari').child(dokumanId).child('ustalik_belgesi.jpg');
        await ref.putFile(_ustalikBelgesi!);
        ustalikUrl = await ref.getDownloadURL();
      }

      // FIRESTORE BATCH İŞLEMİ (Atomik yazma)
      final batch = FirebaseFirestore.instance.batch();
      final docRef = FirebaseFirestore.instance.collection('dukkanlar').doc(dokumanId);

      final dukkan = Dukkan(
        ad: _firmaAdCtrl.text.trim(),
        countryId: _secilenUlke ?? '',
        regionId: _secilenBolge ?? '',
        cityId: _secilenSehir ?? '',
        districtId: _secilenIlce ?? '',
        firmaYetkilisiAdSoyad: _yetkiliAdCtrl.text.trim(),
        isTelefonu: _isTelCtrl.text.trim(),
        whatsappNumarasi: _wpTelCtrl.text.trim(),
        vergiLevhasiUrl: vergiUrl,
        ustalikBelgesiUrl: ustalikUrl,
        evrakOnayDurumu: 'bekliyor',
        aktifMi: false,
        rozet: 'Bronz',
        kayitTarihi: DateTime.now(),
      );

      batch.set(docRef, dukkan.toMap());
      await batch.commit();

      _siberUyari("EVRAKLAR KARARGAHA GÖNDERİLDİ! Onay süreci başladı.", SiberTema.kuantumCyan);
      
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pop(); // Geri dön
      }

    } catch (e) {
      _siberUyari("Bağlantı Kopuşu: $e", SiberTema.kanKirmizi);
    } finally {
      if (mounted) setState(() => _islemSuruyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
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
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _islemSuruyor 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(_currentStep == 2 ? "KAYDI KARARGAHA İLET" : "İLERİ", style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: _islemSuruyor ? null : details.onStepCancel,
                    child: const Text("GERİ", style: TextStyle(color: SiberTema.textMuted, fontWeight: FontWeight.bold)),
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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text("Müşterilerin size ulaşacağı resmi bilgileri girin.", style: TextStyle(color: SiberTema.textMuted, fontSize: 12)),
              const SizedBox(height: 20),
              _buildSiberTextField("Dükkan / Firma Adı", Icons.store_rounded, _firmaAdCtrl, zorunlu: true),
              const SizedBox(height: 16),
              _buildSiberTextField("Firma Yetkilisi Ad-Soyad", Icons.person_rounded, _yetkiliAdCtrl, zorunlu: true),
              const SizedBox(height: 16),
              _buildSiberTextField("Sabit İş Telefonu", Icons.phone_rounded, _isTelCtrl, type: TextInputType.phone),
              const SizedBox(height: 16),
              _buildSiberTextField("WhatsApp Destek Hattı", Icons.chat_rounded, _wpTelCtrl, type: TextInputType.phone, zorunlu: true),
            ],
          ),
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
            const Text("Milisaniyelik harita aramalarında bulunabilmeniz için tam konumunuz.", style: TextStyle(color: SiberTema.textMuted, fontSize: 12)),
            const SizedBox(height: 20),
            
            _buildSiberDropdown("Ülke", ulkeler, _secilenUlke, (v) {
              setState(() { _secilenUlke = v; _secilenBolge = null; _secilenSehir = null; _secilenIlce = null; });
            }),
            const SizedBox(height: 12),
            _buildSiberDropdown("Bölge", _secilenUlke != null ? bolgeler : [], _secilenBolge, (v) {
              setState(() { _secilenBolge = v; _secilenSehir = null; _secilenIlce = null; });
            }),
            const SizedBox(height: 12),
            _buildSiberDropdown("Şehir", _secilenBolge != null ? sehirler[_secilenBolge!] ?? [] : [], _secilenSehir, (v) {
              setState(() { _secilenSehir = v; _secilenIlce = null; });
            }),
            const SizedBox(height: 12),
            _buildSiberDropdown("İlçe (Mikro-İstihbarat)", _secilenSehir != null ? ilceler[_secilenSehir!] ?? [] : [], _secilenIlce, (v) {
              setState(() { _secilenIlce = v; });
            }),
            
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: const Row(
                children: [
                  Icon(Icons.location_on_rounded, color: SiberTema.kuantumCyan, size: 24),
                  SizedBox(width: 12),
                  Expanded(child: Text("Siber Harita Konumunuz (GeoPoint) onay sonrası karargah tarafından otomatik çekilecektir.", style: TextStyle(color: SiberTema.textMuted, fontSize: 11, height: 1.4))),
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
                Expanded(child: _buildResimSeciciBox("Vergi Levhası (Zorunlu)", _vergiLevhasi, true)),
                const SizedBox(width: 12),
                Expanded(child: _buildResimSeciciBox("Ustalık Belgesi (Opsiyonel)", _ustalikBelgesi, false)),
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
                        style: TextStyle(color: SiberTema.textMuted, fontSize: 11, height: 1.5),
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

  Widget _buildSiberTextField(String hint, IconData icon, TextEditingController controller, {TextInputType type = TextInputType.text, bool zorunlu = false}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w600),
      keyboardType: type,
      validator: (value) {
        if (zorunlu && (value == null || value.trim().isEmpty)) return "Bu alan zorunludur.";
        return null;
      },
      decoration: InputDecoration(
        labelText: hint + (zorunlu ? " *" : ""),
        labelStyle: const TextStyle(color: SiberTema.textMuted),
        prefixIcon: Icon(icon, color: SiberTema.kuantumCyan, size: 20),
        filled: true,
        fillColor: Colors.black45,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SiberTema.textMuted)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SiberTema.kuantumCyan)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SiberTema.kanKirmizi)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SiberTema.kanKirmizi)),
      ),
    );
  }

  Widget _buildSiberDropdown(String label, List<String> items, String? currentValue, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: currentValue,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: SiberTema.textMain)))).toList(),
      onChanged: items.isEmpty ? null : onChanged,
      dropdownColor: Colors.black87,
      icon: const Icon(Icons.arrow_drop_down, color: SiberTema.kuantumCyan),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: SiberTema.textMuted),
        filled: true,
        fillColor: Colors.black45,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SiberTema.textMuted)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SiberTema.kuantumCyan)),
      ),
    );
  }

  Future<void> _resimSec(bool isVergi) async {
    try {
      // imageQuality: 70 -> Belleği ve veritabanını kasmamak için sıkıştırma
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70); 
      if (image != null) {
        setState(() {
          if (isVergi) {
            _vergiLevhasi = File(image.path);
          } else {
            _ustalikBelgesi = File(image.path);
          }
        });
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      _siberUyari("Dosya erişim hatası. Yetkileri kontrol edin.", SiberTema.kanKirmizi);
    }
  }

  Widget _buildResimSeciciBox(String baslik, File? resimFile, bool isVergi) {
    return GestureDetector(
      onTap: () => _resimSec(isVergi),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white45,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: resimFile != null ? SiberTema.kuantumCyan : Colors.white24, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              resimFile != null ? Icons.check_circle_outline_rounded : Icons.drive_folder_upload_rounded, 
              color: resimFile != null ? SiberTema.kuantumCyan : Colors.white38, 
              size: 36
            ),
            const SizedBox(height: 8),
            Text(
              resimFile != null ? "YÜKLENDİ" : baslik, 
              style: TextStyle(
                color: resimFile != null ? SiberTema.kuantumCyan : Colors.white54, 
                fontSize: 10, 
                fontWeight: FontWeight.bold
              ), 
              textAlign: TextAlign.center,
            ),
            if (resimFile != null)
               const Padding(
                 padding: EdgeInsets.only(top: 4.0),
                 child: Text("Değiştirmek için dokun", style: TextStyle(color: SiberTema.textMuted, fontSize: 8)),
               ),
          ],
        ),
      ),
    );
  }
}
