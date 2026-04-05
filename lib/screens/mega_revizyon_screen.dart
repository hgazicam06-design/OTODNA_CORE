import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';
import '../services/kuantum_ocr_motoru.dart';
import '../services/kuantum_pdf_motoru.dart'; // ✅ HATA ÇÖZÜLDÜ

class MegaRevizyonScreen extends StatefulWidget {
  final String plaka;
  const MegaRevizyonScreen({super.key, required this.plaka});

  @override
  State<MegaRevizyonScreen> createState() => _MegaRevizyonScreenState();
}

class _MegaRevizyonScreenState extends State<MegaRevizyonScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  final KuantumPdfMotoru _pdfMotoru = KuantumPdfMotoru();
  final KuantumOcrMotoru _ocrMotoru = KuantumOcrMotoru();

  String _seciliAracTipi = 'Otomobil';
  bool _isProcessing = false;
  bool _isOcrScanning = false;

  final Map<String, List<String>> _paketler = {
    'Otomobil': ['Piston Takımı', 'Segman Seti', 'Ana Yatak', 'Kol Yatak', 'Triger Seti', 'Salıncak', 'Amortisör', 'Fren Disk/Balata'],
    'Kamyon / Tır': ['Islak Gömlek', 'Kompresör Revizyonu', 'Makas Burçları', 'Hava Körükleri', 'PTO (Yavru Şanzıman)', 'Kurutucu Filtre'],
    'İş Makinesi': ['Ana Pompa Revizyonu', 'Kumanda Valfi Keçeleri', 'Bom Silindiri', 'Yürüyüş Motoru', 'Palet Pabucu', 'Radyatör Temizliği'],
    'OCR Fatura Parçaları': [],
  };

  final Map<String, Map<String, dynamic>> _secilenParcalar = {};

  Future<void> _gorselSec(String parca, ImageSource kaynak) async {
    final XFile? secilenGorsel = await _picker.pickImage(source: kaynak, imageQuality: 70);
    if (secilenGorsel != null) {
      setState(() { _secilenParcalar[parca] ??= {'fiyat': 0.0}; _secilenParcalar[parca]!['gorsel'] = File(secilenGorsel.path); });
    }
  }

  void _fiyatGuncelle(String parca, String fiyatText) {
    double fiyat = double.tryParse(fiyatText.replaceAll(',', '.')) ?? 0.0;
    _secilenParcalar[parca] ??= {}; _secilenParcalar[parca]!['fiyat'] = fiyat;
  }

  Future<void> _faturayiTaraVeCozumle() async {
    setState(() => _isOcrScanning = true);
    _siberUyari("SİBER GÖZ AÇILIYOR: Faturayı hizalayın...", isError: false);
    final analizSonucu = await _ocrMotoru.faturaTaramaMotoru();
    if (!mounted) return;
    setState(() => _isOcrScanning = false);

    if (analizSonucu != null) {
      double okunanToplamMaliyet = analizSonucu["maliyet"] ?? 0.0;
      List<String> okunanParcalar = analizSonucu["parcalar"] ?? [];
      if (okunanParcalar.isNotEmpty || okunanToplamMaliyet > 0) {
        setState(() {
          if (okunanParcalar.isNotEmpty) { _seciliAracTipi = 'OCR Fatura Parçaları'; _paketler['OCR Fatura Parçaları'] = okunanParcalar; _secilenParcalar[okunanParcalar.first] = {'fiyat': okunanToplamMaliyet}; }
        });
        _siberUyari("FATURA ÇÖZÜMLENDİ: ${okunanParcalar.length} kalem ve Toplam ₺$okunanToplamMaliyet okundu.", isError: false);
      } else { _siberUyari("ANALİZ HATASI: Faturadan anlamlı bir parça veya fiyat çıkarılamadı.", isError: true); }
    } else { _siberUyari("TARAMA İPTAL EDİLDİ.", isError: true); }
  }

  Future<void> _agaMuhurle() async {
    if (_secilenParcalar.isEmpty) { _siberUyari("SİBER İHLAL: Lütfen en az bir parça seçin!", isError: true); return; }
    setState(() => _isProcessing = true);
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      String konumMetni = '${position.latitude}, ${position.longitude}';
      double toplamMaliyet = 0;
      List<Map<String, dynamic>> muhurlenecekParcalar = [];
      String islemId = _db.collection('islem_kayitlari').doc().id;

      for (var parca in _secilenParcalar.entries) {
        double fiyat = parca.value['fiyat'] ?? 0.0; toplamMaliyet += fiyat; String gorselUrl = '';
        if (parca.value['gorsel'] != null) { File dosya = parca.value['gorsel']; TaskSnapshot snapshot = await _storage.ref('kanit_gorselleri/$islemId/${parca.key}.jpg').putFile(dosya); gorselUrl = await snapshot.ref.getDownloadURL(); }
        muhurlenecekParcalar.add({'parca_adi': parca.key, 'fiyat': fiyat, 'gorsel_url': gorselUrl, 'firma_onayi': true});
      }

      double komutanPayi = toplamMaliyet * 0.12;
      WriteBatch batch = _db.batch();
      DocumentReference islemRef = _db.collection('islem_kayitlari').doc(islemId);
      batch.set(islemRef, {'islem_id': islemId, 'plaka': widget.plaka, 'arac_tipi': _seciliAracTipi, 'toplam_maliyet': toplamMaliyet, 'komutan_payi': komutanPayi, 'parcalar': muhurlenecekParcalar, 'bayi_id': FirebaseAuth.instance.currentUser?.uid ?? 'BilinmeyenBayi', 'islem_tarihi': FieldValue.serverTimestamp(), 'firma_onay_konumu': GeoPoint(position.latitude, position.longitude), 'musteri_onayi': 'bekliyor'});
      await batch.commit();

      _siberUyari("MÜHÜR VURULDU! PDF GARANTİ BELGESİ ÜRETİLİYOR...", isError: false);
      String anlikTarih = DateFormat('dd.MM.yyyy - HH:mm').format(DateTime.now());
      await _pdfMotoru.garantiBelgesiUretVePaylas(bayiIsim: 'Siber Otorite Bayisi', plaka: widget.plaka.toUpperCase(), aracTipi: _seciliAracTipi, toplamMaliyet: toplamMaliyet, degisenParcalar: muhurlenecekParcalar, islemTarihi: anlikTarih, islemKonumu: konumMetni);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) { _siberUyari("SİSTEM HATASI: $e", isError: true); } finally { if (mounted) setState(() => _isProcessing = false); }
  }

  void _siberUyari(String mesaj, {required bool isError}) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mesaj, style: TextStyle(color: isError ? Colors.white : SiberTema.oledBlack, fontWeight: FontWeight.bold, fontFamily: 'Avenir')), backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))); }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: SiberTema.kuantumCyan), onPressed: () => Navigator.pop(context)), title: Text("MEGA REVİZYON: ${widget.plaka}", style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5, fontFamily: 'Avenir')), centerTitle: true, actions: [IconButton(icon: Icon(Icons.document_scanner, color: _isOcrScanning ? SiberTema.kanKirmizi : SiberTema.altinSari), tooltip: "Faturayı Tara", onPressed: _isOcrScanning ? null : _faturayiTaraVeCozumle)]),
        body: Column(
          children: [
            Container(margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: SiberTema.matGrey.withOpacity(0.5), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.1))), child: SingleChildScrollView(scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(), child: Row(children: _paketler.keys.map((tip) { if (_paketler[tip]!.isEmpty && tip == 'OCR Fatura Parçaları') return const SizedBox.shrink(); return GestureDetector(onTap: () => setState(() { _seciliAracTipi = tip; _secilenParcalar.clear(); }), child: Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), decoration: BoxDecoration(color: _seciliAracTipi == tip ? SiberTema.kuantumCyan.withOpacity(0.2) : Colors.transparent, borderRadius: BorderRadius.circular(8), border: Border.all(color: _seciliAracTipi == tip ? SiberTema.kuantumCyan : Colors.transparent)), child: Center(child: Text(tip, style: TextStyle(color: _seciliAracTipi == tip ? SiberTema.kuantumCyan : Colors.white54, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'Avenir'))))); }).toList()))),
            Expanded(child: _isOcrScanning ? const Center(child: CircularProgressIndicator(color: SiberTema.altinSari)) : ListView.builder(physics: const BouncingScrollPhysics(), padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: _paketler[_seciliAracTipi]?.length ?? 0, itemBuilder: (context, index) { String parca = _paketler[_seciliAracTipi]![index]; bool isSelected = _secilenParcalar.containsKey(parca); String onTanimliFiyat = _secilenParcalar[parca]?['fiyat']?.toString() ?? ""; if (onTanimliFiyat == "0.0") onTanimliFiyat = ""; return AnimatedContainer(duration: const Duration(milliseconds: 200), margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(gradient: LinearGradient(colors: isSelected ? [SiberTema.kuantumCyan.withOpacity(0.1), SiberTema.oledBlack] : [SiberTema.matGrey.withOpacity(0.3), SiberTema.oledBlack]), borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? SiberTema.kuantumCyan.withOpacity(0.5) : Colors.white.withOpacity(0.05))), child: ExpansionTile(onExpansionChanged: (expanded) { setState(() { if (expanded) _secilenParcalar[parca] ??= {'fiyat': 0.0}; else _secilenParcalar.remove(parca); }); }, leading: Icon(isSelected ? Icons.check_circle : Icons.radio_button_unchecked, color: isSelected ? SiberTema.kuantumCyan : Colors.white24), title: Text(parca, style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w700, fontFamily: 'Avenir')), childrenPadding: const EdgeInsets.all(16), children: [Row(children: [Expanded(child: TextField(keyboardType: TextInputType.number, controller: TextEditingController(text: onTanimliFiyat)..selection = TextSelection.fromPosition(TextPosition(offset: onTanimliFiyat.length)), style: const TextStyle(color: Colors.white, fontFamily: 'Avenir'), decoration: InputDecoration(labelText: "Fiyat (₺)", labelStyle: TextStyle(color: SiberTema.kuantumCyan.withOpacity(0.5), fontSize: 12), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.1))), focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: SiberTema.kuantumCyan))), onChanged: (val) => _fiyatGuncelle(parca, val))), const SizedBox(width: 12), IconButton(icon: Icon(Icons.camera_alt, color: _secilenParcalar[parca]?['gorsel'] != null ? SiberTema.kuantumCyan : Colors.white54), onPressed: () => _gorselSec(parca, ImageSource.camera)), IconButton(icon: Icon(Icons.photo_library, color: _secilenParcalar[parca]?['gorsel'] != null ? SiberTema.kuantumCyan : Colors.white54), onPressed: () => _gorselSec(parca, ImageSource.gallery))])])); })),
            Padding(padding: const EdgeInsets.all(20.0), child: GestureDetector(onTap: _isProcessing ? null : _agaMuhurle, child: Container(height: 60, decoration: BoxDecoration(color: _isProcessing ? SiberTema.matGrey : SiberTema.kuantumCyan.withOpacity(0.9), borderRadius: BorderRadius.circular(12), boxShadow: _isProcessing ? [] : [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5))]), child: Center(child: _isProcessing ? const CircularProgressIndicator(color: SiberTema.oledBlack) : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.fingerprint, color: SiberTema.oledBlack, size: 28), SizedBox(width: 12), Text("SİSTEME MÜHÜRLE", style: TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.w900, fontSize: 16, fontFamily: 'Avenir'))]))))),
          ],
        ),
      ),
    );
  }
}