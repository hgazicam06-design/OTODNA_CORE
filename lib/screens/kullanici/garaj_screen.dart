// lib/screens/garaj_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';
import 'arac_detay_screen.dart'; // Detay ekranı bağlantısı

class GarajScreen extends StatefulWidget {
  const GarajScreen({super.key});

  @override
  State<GarajScreen> createState() => _GarajScreenState();
}

class _GarajScreenState extends State<GarajScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // --- SİBER GARAJ VERİ SETİ ---
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
  // 📸 SİBER GÖZ: ŞASE (VIN) TARAMA
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
      _siberUyariGoster("SİBER İHLAL", "Şase numarası 17 haneli olmalıdır!", SiberTema.kanKirmizi);
      return;
    }
    _siberUyariGoster("SİBER GÖZ AKTİF", "Şase Onaylandı. Hub Verileri Çekiliyor... ⏳", SiberTema.kuantumCyan);
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _secilenAracCinsi = 'Otomobil 🚗 (Maks. 9 Koltuk)';
      _secilenMarka = 'BMW'; // Otonom OCR simülasyonu (Gerçekte API'den gelecek)
      _secilenModel = '3 Serisi';
      _secilenYil = '2023';
    });
  }

  // =======================================================================
  // 🚀 FİREBASE: YENİ ARAÇ MÜHÜRLEME (WRITEBATCH)
  // =======================================================================
  Future<void> _aracEkle() async {
    if (_plakaController.text.isEmpty || _secilenModel == null) {
      _siberUyariGoster("EKSİK VERİ", "Plaka ve Model Seçimi Zorunludur!", SiberTema.altinSari);
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

      _siberUyariGoster("KAYIT BAŞARILI", "Araç Kuantum Garajına Eklendi! 🛡️", SiberTema.kuantumCyan);

    } catch (e) {
      _siberUyariGoster("HATA", "Karargaha bağlantı kurulamadı.", SiberTema.kanKirmizi);
    } finally {
      if (mounted) setState(() => _islemSuruyor = false);
    }
  }

  void _siberUyariGoster(String baslik, String mesaj, Color renk) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SiberTema.matGrey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: renk, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            Text(mesaj, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) return const Scaffold(backgroundColor: SiberTema.oledBlack, body: Center(child: Text("Kimlik Doğrulanamadı!", style: TextStyle(color: Colors.white))));

    return ResponsiveKalkan(
      child: Scaffold(
        backgroundColor: Colors.transparent, // OLED Siyah
        appBar: AppBar(
            backgroundColor: Colors.transparent, elevation: 0,
            title: const Text('O T O D N A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 6)),
            centerTitle: true,
            leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 18), onPressed: () => Navigator.pop(context))
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =================================================================
              // 1. CANLI GARAJ RADARI (FİREBASE)
              // =================================================================
              const Text("Garaj", style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1)),
              const SizedBox(height: 8),
              const Text("Kayıtlı Araçlar", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: -0.5)),
              const SizedBox(height: 24),

              StreamBuilder<QuerySnapshot>(
                  stream: _db.collection('arac_kimlikleri').where('sahibi_id', isEqualTo: _currentUser!.uid).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Container(
                          width: double.infinity, padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
                          child: const Column(
                              children: [
                                Icon(Icons.garage_outlined, color: Colors.white24, size: 48),
                                SizedBox(height: 12),
                                Text("Garajınız şu an boş.", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
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
                            // Detay Ekranına Fırlat
                            Navigator.push(context, MaterialPageRoute(builder: (context) => AracDetayScreen(aracVerisi: arac)));
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: SiberTema.matGrey,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3)) // Zırhlı Çerçeve
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.directions_car_outlined, color: SiberTema.kuantumCyan, size: 32),
                                const SizedBox(width: 20),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(arac['plaka'] ?? 'PLAKA YOK', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                          const SizedBox(height: 4),
                                          Text("${arac['marka_model']} (${arac['yil']})", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                          const SizedBox(height: 6),
                                          Text("DNA Skoru: %${arac['dna_skoru'] ?? 100}", style: const TextStyle(color: SiberTema.altinSari, fontSize: 11, fontWeight: FontWeight.w900))
                                        ]
                                    )
                                ),
                                const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 16),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
              ),
              const SizedBox(height: 32),

              // =================================================================
              // 2. YENİ ARAÇ EKLEME FORMU
              // =================================================================
              const Text("Yeni İşlem", style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1)),
              const SizedBox(height: 8),
              const Text("Garaja Araç Ekle", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: -0.5)),
              const SizedBox(height: 12),
              const Text("Şase numarasını (VIN) okutun veya bilgileri elle doldurun.", style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5)),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: TextField(
                          controller: _saseController,
                          style: const TextStyle(color: Colors.white, fontSize: 15, letterSpacing: 1.5),
                          maxLength: 17,
                          decoration: InputDecoration(
                            labelText: 'Şase (VIN) No',
                            labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
                            counterText: "",
                            filled: true, fillColor: SiberTema.matGrey,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SiberTema.kuantumCyan)),
                          )
                      )
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: _saseTarayiciyiAc,
                    child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5))),
                        child: const Icon(Icons.document_scanner_outlined, color: SiberTema.kuantumCyan, size: 24)
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                  controller: _plakaController,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(color: Colors.white, fontSize: 15, letterSpacing: 2),
                  decoration: InputDecoration(
                    labelText: 'Plaka (Örn: 34DNA2026)',
                    labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
                    filled: true, fillColor: SiberTema.matGrey,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SiberTema.kuantumCyan)),
                  )
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
                      style: SiberTema.kuantumButonStili(),
                      onPressed: _islemSuruyor ? null : _aracEkle,
                      child: _islemSuruyor
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: SiberTema.oledBlack, strokeWidth: 2))
                          : const Text('GARAJA MÜHÜRLE', style: TextStyle(color: SiberTema.oledBlack, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5))
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.circular(12), border: Border.all(color: value != null ? SiberTema.kuantumCyan.withOpacity(0.5) : Colors.transparent)),
        child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
                dropdownColor: SiberTema.matGrey, isExpanded: true, value: value,
                hint: Text(hint, style: const TextStyle(color: Colors.white38, fontSize: 14)),
                icon: Icon(Icons.keyboard_arrow_down, color: value != null ? SiberTema.kuantumCyan : Colors.white54),
                items: items.map((String item) { return DropdownMenuItem<String>(value: item, child: Text(item, style: const TextStyle(color: Colors.white, fontSize: 14))); }).toList(),
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

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: SiberTema.kuantumCyan), title: const Text("ŞASE TARAYICI (OCR)", style: TextStyle(color: SiberTema.kuantumCyan, letterSpacing: 2, fontSize: 14, fontWeight: FontWeight.bold)), centerTitle: true),
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
          ColorFiltered(colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.srcOut), child: Container(decoration: const BoxDecoration(color: Colors.transparent), child: Align(alignment: Alignment.center, child: Container(width: scanAreaWidth, height: scanAreaHeight, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)))))),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: scanAreaWidth, height: scanAreaHeight,
              child: Stack(
                children: [
                  Container(decoration: BoxDecoration(border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5), width: 2), borderRadius: BorderRadius.circular(12))),
                  AnimatedBuilder(animation: _animationController, builder: (context, child) => Positioned(top: _animationController.value * (scanAreaHeight - 4), left: 0, right: 0, child: Container(height: 3, decoration: BoxDecoration(color: SiberTema.kuantumCyan, boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)]))))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}