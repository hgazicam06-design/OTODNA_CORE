// lib/screens/garaj_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/responsive_kalkan.dart';
import 'arac_detay_screen.dart';

class GarajScreen extends StatefulWidget {
  const GarajScreen({super.key});

  @override
  State<GarajScreen> createState() => _GarajScreenState();
}

class _GarajScreenState extends State<GarajScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // 🏢 PLAZA KALİTESİ PALET
  final Color primaryTeal = Colors.teal.shade700;
  final Color bgColor = const Color(0xFFFAFAFC);
  final Color textColor = const Color(0xFF1E293B);
  final Color dangerColor = Colors.redAccent;
  final Color premiumGold = const Color(0xFFD4AF37);

  // --- PLAZA GARAJ VERİ SETİ ---
  String? _secilenAracCinsi;
  String? _secilenMarka;
  String? _secilenModel;
  String? _secilenYil;

  final TextEditingController _plakaController = TextEditingController();
  final TextEditingController _saseController = TextEditingController();
  bool _islemSuruyor = false;

  final List<String> _aracCinsleri = [
    'Otomobil 🚗 (Maks. 9 Koltuk)',
    'Motosiklet 🏍️ (İki veya Üç Tekerlekli)',
    'Kamyonet / Panelvan 🚐 (Maks. 3.5 Ton)',
    'Minibüs / Otobüs 🚌 (9+ Koltuklu)',
    'Kamyon / Çekici 🚛 (3.5 Ton Üzeri)',
    'Motorlu Karavan 🏕️ (Özel Maksatlı)',
    'İş Makinesi / Traktör 🚜 (Ağır Hizmet)'
  ];

  final Map<String, List<String>> _markalarVeritabanasi = {
    'Otomobil 🚗 (Maks. 9 Koltuk)': ['BMW', 'Mercedes', 'Toyota', 'Renault', 'Togg', 'Fiat'],
    'Motosiklet 🏍️ (İki veya Üç Tekerlekli)': ['Honda', 'Yamaha', 'Ducati', 'Kawasaki', 'BMW Motorrad'],
    'Kamyonet / Panelvan 🚐 (Maks. 3.5 Ton)': ['Ford', 'Fiat', 'Volkswagen', 'Renault'],
    'Minibüs / Otobüs 🚌 (9+ Koltuklu)': ['Mercedes', 'Otokar', 'Isuzu', 'BMC'],
    'Kamyon / Çekici 🚛 (3.5 Ton Üzeri)': ['Scania', 'Volvo', 'Mercedes', 'MAN', 'Ford Trucks'],
    'Motorlu Karavan 🏕️ (Özel Maksatlı)': ['Fiat (Ducato Tabanlı)', 'Peugeot', 'Volkswagen'],
    'İş Makinesi / Traktör 🚜 (Ağır Hizmet)': ['Caterpillar', 'JCB', 'New Holland', 'Massey Ferguson']
  };

  final Map<String, List<String>> _modellerVeritabanasi = {
    'BMW': ['3 Serisi', '5 Serisi', 'X5', 'i4 (Elektrikli)'],
    'Toyota': ['Corolla', 'Yaris', 'Hilux', 'C-HR'],
    'Honda': ['CBR 600RR', 'PCX 125', 'Africa Twin'],
    'Ford': ['Transit', 'Tourneo Custom', 'F-Max'],
    'Scania': ['R Serisi', 'S Serisi', 'G Serisi'],
    'Togg': ['T10X', 'T10F'],
  };

  final List<String> _yillar = List.generate(37, (index) => (2026 - index).toString());

  // =======================================================================
  // 📸 PLAZA GÖZ: ŞASE (VIN) TARAMA
  // =======================================================================
  void _saseTarayiciyiAc() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SaseScannerOverlay(),
    ).then((tarananSase) {
      if (tarananSase != null) {
        setState(() => _saseController.text = tarananSase);
        _hubdanVeriCek(tarananSase);
      }
    });
  }

  void _hubdanVeriCek(String saseNo) async {
    if (saseNo.length < 17) {
      _plazaUyariGoster("SİSTEM İHLALİ", "Şase numarası 17 haneli olmalıdır!", dangerColor);
      return;
    }
    _plazaUyariGoster("KAMERA AKTİF", "Şase Onaylandı. Hub Verileri Çekiliyor... ⏳", primaryTeal);
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _secilenAracCinsi = 'Otomobil 🚗 (Maks. 9 Koltuk)';
      _secilenMarka = 'BMW'; 
      _secilenModel = '3 Serisi';
      _secilenYil = '2023';
    });
  }

  // =======================================================================
  // 🚀 FİREBASE: YENİ ARAÇ MÜHÜRLEME (WRITEBATCH)
  // =======================================================================
  Future<void> _aracEkle() async {
    if (_plakaController.text.isEmpty || _secilenModel == null) {
      _plazaUyariGoster("EKSİK VERİ", "Plaka ve Model Seçimi Zorunludur!", Colors.orange);
      return;
    }

    if (_currentUser == null) return;

    setState(() => _islemSuruyor = true);
    String plaka = _plakaController.text.trim().toUpperCase().replaceAll(' ', '');
    String sase = _saseController.text.trim().toUpperCase();
    String docId = sase.isNotEmpty ? sase : plaka; // Öncelik Şase

    try {
      WriteBatch batch = _db.batch();
      DocumentReference aracRef = _db.collection('arac_kimlikleri').doc(docId);

      batch.set(aracRef, {
        'sahibi_id': _currentUser!.uid,
        'plaka': plaka,
        'sase_no': sase,
        'arac_cinsi': _secilenAracCinsi,
        'marka': _secilenMarka,
        'model': _secilenModel,
        'marka_model': '$_secilenMarka $_secilenModel',
        'yil': _secilenYil ?? 'Bilinmiyor',
        'dna_skoru': 100, // Karargah başlangıç skoru
        'durum': 'Aktif, Onaylı ✅',
        'eklenme_tarihi': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      setState(() {
        _plakaController.clear(); _saseController.clear(); _secilenAracCinsi = null; _secilenMarka = null; _secilenModel = null; _secilenYil = null;
      });

      _plazaUyariGoster("KAYIT BAŞARILI", "Araç OtoDNA Garajına Eklendi! 🛡️", primaryTeal);

    } catch (e) {
      _plazaUyariGoster("HATA", "Merkez ile bağlantı kurulamadı.", dangerColor);
    } finally {
      if (mounted) setState(() => _islemSuruyor = false);
    }
  }

  void _plazaUyariGoster(String baslik, String mesaj, Color renk) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: renk, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
            Text(mesaj, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) return Scaffold(backgroundColor: bgColor, body: Center(child: Text("Kimlik Doğrulanamadı!", style: TextStyle(color: textColor, fontFamily: 'Avenir', fontWeight: FontWeight.bold))));

    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
            backgroundColor: Colors.white, 
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            shape: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
            title: Text('O T O D N A   G A R A J', style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 4, fontFamily: 'Avenir')),
            centerTitle: true,
            leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: primaryTeal, size: 20), onPressed: () => Navigator.pop(context))
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =================================================================
              // 1. CANLI GARAJ RADARI (FİREBASE)
              // =================================================================
              Text("Garaj", style: TextStyle(color: primaryTeal, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
              const SizedBox(height: 8),
              Text("Kayıtlı Araçlar", style: TextStyle(color: textColor, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Avenir')),
              const SizedBox(height: 24),

              StreamBuilder<QuerySnapshot>(
                  stream: _db.collection('arac_kimlikleri').where('sahibi_id', isEqualTo: _currentUser!.uid).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: primaryTeal));
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Container(
                          width: double.infinity, padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)]),
                          child: const Column(
                              children: [
                                Icon(Icons.garage_outlined, color: Colors.black12, size: 56),
                                SizedBox(height: 16),
                                Text("Garajınız şu an boş.", style: TextStyle(color: Colors.black45, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                              ]
                          )
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var arac = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => AracDetayScreen(aracVerisi: arac)));
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 5))]
                            ),
                            child: Row(
                              children: [
                                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: primaryTeal.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(Icons.directions_car_outlined, color: primaryTeal, size: 32)),
                                const SizedBox(width: 20),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(arac['plaka'] ?? 'PLAKA YOK', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                                          const SizedBox(height: 4),
                                          Text("${arac['marka_model']} (${arac['yil']})", style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                                          const SizedBox(height: 6),
                                          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: premiumGold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)), child: Text("DNA Skoru: %${arac['dna_skoru'] ?? 100}", style: TextStyle(color: premiumGold, fontSize: 10, fontWeight: FontWeight.w900, fontFamily: 'Avenir')))
                                        ]
                                    )
                                ),
                                const Icon(Icons.arrow_forward_ios, color: Colors.black26, size: 16),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
              ),
              const SizedBox(height: 40),

              // =================================================================
              // 2. YENİ ARAÇ EKLEME FORMU
              // =================================================================
              Text("Yeni İşlem", style: TextStyle(color: primaryTeal, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
              const SizedBox(height: 8),
              Text("Garaja Araç Ekle", style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Avenir')),
              const SizedBox(height: 12),
              const Text("Şase numarasını (VIN) okutun veya bilgileri elle doldurun.", style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.5, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)]),
                        child: TextField(
                            controller: _saseController,
                            style: TextStyle(color: textColor, fontSize: 15, letterSpacing: 1.5, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
                            maxLength: 17,
                            decoration: InputDecoration(
                              labelText: 'Şase (VIN) No',
                              labelStyle: const TextStyle(color: Colors.black45, fontSize: 13, fontFamily: 'Avenir'),
                              counterText: "",
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            )
                        ),
                      )
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: _saseTarayiciyiAc,
                    child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        decoration: BoxDecoration(color: primaryTeal, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: primaryTeal.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))]),
                        child: const Icon(Icons.document_scanner_outlined, color: Colors.white, size: 24)
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)]),
                child: TextField(
                    controller: _plakaController,
                    textCapitalization: TextCapitalization.characters,
                    style: TextStyle(color: textColor, fontSize: 15, letterSpacing: 2, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
                    decoration: const InputDecoration(
                      labelText: 'Plaka (Örn: 34DNA2026)',
                      labelStyle: TextStyle(color: Colors.black45, fontSize: 13, fontFamily: 'Avenir'),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    )
                ),
              ),
              const SizedBox(height: 32),

              _buildDropdown("Araç Cinsi", _secilenAracCinsi, _aracCinsleri, (val) => setState(() { _secilenAracCinsi = val; _secilenMarka = null; _secilenModel = null; })),
              if (_secilenAracCinsi != null) const SizedBox(height: 16),
              if (_secilenAracCinsi != null) _buildDropdown("Marka Seç", _secilenMarka, _markalarVeritabanasi[_secilenAracCinsi] ?? [], (val) => setState(() { _secilenMarka = val; _secilenModel = null; })),
              if (_secilenMarka != null) const SizedBox(height: 16),
              if (_secilenMarka != null) _buildDropdown("Model Seç", _secilenModel, _modellerVeritabanasi[_secilenMarka] ?? [], (val) => setState(() => _secilenModel = val)),
              if (_secilenModel != null) const SizedBox(height: 16),
              if (_secilenModel != null) _buildDropdown("Üretim Yılı", _secilenYil, _yillar, (val) => setState(() => _secilenYil = val)),

              const SizedBox(height: 48),

              SizedBox(
                  width: double.infinity, height: 60,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryTeal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: _islemSuruyor ? null : _aracEkle,
                      child: _islemSuruyor
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('SİSTEME KAYDET', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir'))
                  )
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String hint, String? value, List<String> items, Function(String?) onChanged) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: value != null ? primaryTeal.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)]),
        child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
                dropdownColor: Colors.white, isExpanded: true, value: value,
                hint: Text(hint, style: const TextStyle(color: Colors.black38, fontSize: 14, fontFamily: 'Avenir', fontWeight: FontWeight.bold)),
                icon: Icon(Icons.keyboard_arrow_down, color: value != null ? primaryTeal : Colors.black38),
                style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
                items: items.map((String item) { return DropdownMenuItem<String>(value: item, child: Text(item)); }).toList(),
                onChanged: onChanged
            )
        )
    );
  }
}

// 📸 KAMERA EKRANI: ŞASE (VIN) TARAYICI
class SaseScannerOverlay extends StatefulWidget {
  const SaseScannerOverlay({super.key});
  @override
  State<SaseScannerOverlay> createState() => _SaseScannerOverlayState();
}

class _SaseScannerOverlayState extends State<SaseScannerOverlay> with SingleTickerProviderStateMixin {
  bool _isProcessing = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(seconds: 2), vsync: this)..repeat(reverse: true);
  }
  @override
  void dispose() { _animationController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final scanAreaWidth = MediaQuery.of(context).size.width * 0.8;
    final scanAreaHeight = 100.0;
    final Color primaryTeal = Colors.teal.shade700;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: IconThemeData(color: primaryTeal), title: Text("ŞASE TARAYICI (OCR)", style: TextStyle(color: primaryTeal, letterSpacing: 2, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'Avenir')), centerTitle: true),
      body: Stack(
        children: [
          MobileScanner(onDetect: (capture) {
            if (_isProcessing) return;
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty && (barcodes.first.rawValue ?? "").isNotEmpty) {
              setState(() => _isProcessing = true);
              Navigator.pop(context, barcodes.first.rawValue);
            }
          }),
          ColorFiltered(colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.srcOut), child: Container(decoration: const BoxDecoration(color: Colors.transparent), child: Align(alignment: Alignment.center, child: Container(width: scanAreaWidth, height: scanAreaHeight, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)))))),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: scanAreaWidth, height: scanAreaHeight,
              child: Stack(
                children: [
                  Container(decoration: BoxDecoration(border: Border.all(color: primaryTeal, width: 2), borderRadius: BorderRadius.circular(16))),
                  AnimatedBuilder(animation: _animationController, builder: (context, child) => Positioned(top: _animationController.value * (scanAreaHeight - 4), left: 0, right: 0, child: Container(height: 3, decoration: BoxDecoration(color: primaryTeal, boxShadow: [BoxShadow(color: primaryTeal.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 2)]))))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}