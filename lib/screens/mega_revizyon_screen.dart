import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // 🛡️ SİBER DÜZELTME: Tarih formatı paketi eklendi!

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';
import '../services/kuantum_ocr_motoru.dart';
import '../services/kuantum_pdf_motoru.dart';

/// 🦅 OTODNA MEGA REVİZYON VE SİBER MÜHÜRLEME MOTORU
/// [2026-03-28] GÜNCELLEME: %100 Gerçek Firebase Batch ve Siber Cam Efektli Arayüz
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
    'Kamyon / Tır': ['Islak Gömlek', 'Kompresör Revizyonu', 'Makas Burçları', 'Hava Körükleri', 'PTO', 'Kurutucu Filtre'],
    'İş Makinesi': ['Ana Pompa Revizyonu', 'Kumanda Valfi', 'Bom Silindiri', 'Yürüyüş Motoru', 'Palet Pabucu'],
    'OCR Fatura Parçaları': [],
  };

  final Map<String, Map<String, dynamic>> _secilenParcalar = {};

  // 🚀 SİBER GÖRSEL KAYIT
  Future<void> _gorselSec(String parca, ImageSource kaynak) async {
    final XFile? secilenGorsel = await _picker.pickImage(source: kaynak, imageQuality: 70);
    if (secilenGorsel != null) {
      setState(() {
        _secilenParcalar[parca] ??= <String, dynamic>{'fiyat': 0.0};
        _secilenParcalar[parca]!['gorsel'] = File(secilenGorsel.path);
      });
    }
  }

  void _fiyatGuncelle(String parca, String fiyatText) {
    double fiyat = double.tryParse(fiyatText.replaceAll(',', '.')) ?? 0.0;
    _secilenParcalar[parca] ??= <String, dynamic>{};
    _secilenParcalar[parca]!['fiyat'] = fiyat;
  }

  // 🛡️ SİBER GÖZ: OCR FATURA ANALİZİ
  Future<void> _faturayiTaraVeCozumle() async {
    setState(() => _isOcrScanning = true);
    _siberUyari("SİBER GÖZ AKTİF: Fatura analiz ediliyor...", isError: false);

    final analizSonucu = await _ocrMotoru.faturaTaramaMotoru();

    if (!mounted) return;
    setState(() => _isOcrScanning = false);

    if (analizSonucu != null) {
      double okunanToplamMaliyet = analizSonucu["maliyet"] ?? 0.0;
      List<String> okunanParcalar = List<String>.from(analizSonucu["parcalar"] ?? []);

      if (okunanParcalar.isNotEmpty || okunanToplamMaliyet > 0) {
        setState(() {
          _seciliAracTipi = 'OCR Fatura Parçaları';
          _paketler['OCR Fatura Parçaları'] = okunanParcalar;
          if (okunanParcalar.isNotEmpty) {
            _secilenParcalar[okunanParcalar.first] = <String, dynamic>{'fiyat': okunanToplamMaliyet};
          }
        });
        _siberUyari("SİBER ANALİZ BAŞARILI: ${okunanParcalar.length} Kalem Tespit Edildi.", isError: false);
      }
    }
  }

  // 🔥 ATOMİK SİBER MÜHÜRLEME (WRITE BATCH)
  Future<void> _agaMuhurle() async {
    if (_secilenParcalar.isEmpty) {
      _siberUyari("HATA: Hiçbir parça veya fiyat girişi yapılmadı!", isError: true);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      String islemId = _db.collection('islem_kayitlari').doc().id;
      double toplamMaliyet = 0;
      List<Map<String, dynamic>> muhurlenecekParcalar = [];

      for (var entry in _secilenParcalar.entries) {
        double fiyat = entry.value['fiyat'] ?? 0.0;
        toplamMaliyet += fiyat;
        String gorselUrl = '';

        if (entry.value['gorsel'] != null) {
          File dosya = entry.value['gorsel'];
          TaskSnapshot snap = await _storage.ref('oto_dna/kanitlar/$islemId/${entry.key}.jpg').putFile(dosya);
          gorselUrl = await snap.ref.getDownloadURL();
        }

        muhurlenecekParcalar.add({
          'parca': entry.key,
          'maliyet': fiyat,
          'kanit_url': gorselUrl,
          'onay': true,
          'ust_onay_zamani': FieldValue.serverTimestamp(),
        });
      }

      double karargahPayi = toplamMaliyet * 0.12;

      WriteBatch siberBatch = _db.batch();

      DocumentReference islemRef = _db.collection('islem_kayitlari').doc(islemId);
      siberBatch.set(islemRef, {
        'islem_id': islemId,
        'plaka': widget.plaka.toUpperCase(),
        'arac_tipi': _seciliAracTipi,
        'toplam_maliyet': toplamMaliyet,
        'karargah_payi': karargahPayi,
        'parcalar': muhurlenecekParcalar,
        'bayi_id': FirebaseAuth.instance.currentUser?.uid,
        'tarih': FieldValue.serverTimestamp(),
        'koordinat': GeoPoint(position.latitude, position.longitude),
        'durum': 'MUHURLENDI',
      });

      DocumentReference aracRef = _db.collection('araclar').doc(widget.plaka.toUpperCase());
      siberBatch.update(aracRef, {
        'son_islem_tarihi': FieldValue.serverTimestamp(),
        'dna_skoru': FieldValue.increment(5),
        'bekleyen_islem': false,
      });

      await siberBatch.commit();

      // 🛡️ SİBER DÜZELTME: Kapsam hatası giderildi, değişkenler temizlendi.
      String anlikTarih = DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now());

      // NOT: Eğer bu fonksiyon kırmızı çiziyorsa 'KuantumPdfMotoru' sınıfında
      // bu parametreler eksiktir veya fonksiyon adı yanlıştır!
      await _pdfMotoru.garantiBelgesiUretVePaylas(
        bayiIsim: 'OTO DNA MERKEZ SERVİS',
        plaka: widget.plaka.toUpperCase(),
        aracTipi: _seciliAracTipi,
        toplamMaliyet: toplamMaliyet,
        degisenParcalar: muhurlenecekParcalar,
        islemTarihi: anlikTarih,
        islemKonumu: '${position.latitude}, ${position.longitude}',
      );

      _siberUyari("SİBER MÜHÜR BASILDI: Veriler Kuantum Ağına İşlendi.", isError: false);
      if (mounted) Navigator.pop(context);

    } catch (e) {
      _siberUyari("SİSTEM İHLALİ: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _siberUyari(String mesaj, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, fontFamily: 'Avenir')),
      backgroundColor: isError ? SiberTema.kritikRed : SiberTema.kuantumCyan,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // 🛡️ SİBER DÜZELTME 2: Temada bulunmayan siberInputDecor kodun içine gömüldü!
  InputDecoration _siberInputDecor(String hint, IconData icon) {
    return InputDecoration(
      labelText: hint,
      labelStyle: TextStyle(color: SiberTema.kuantumCyan.withOpacity(0.5), fontSize: 12, fontFamily: 'Avenir'),
      prefixIcon: Icon(icon, color: SiberTema.kuantumCyan, size: 20),
      filled: true,
      fillColor: Colors.black,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SiberTema.kuantumCyan, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: SiberTema.kuantumCyan), onPressed: () => Navigator.pop(context)),
          title: Text("MEGA REVİZYON: ${widget.plaka}", style: const TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 16, fontFamily: 'Avenir')),
          actions: [
            IconButton(
              icon: Icon(Icons.document_scanner, color: _isOcrScanning ? SiberTema.kritikRed : SiberTema.altinSari),
              onPressed: _isOcrScanning ? null : _faturayiTaraVeCozumle,
            )
          ],
        ),
        body: Column(
          children: [
            _buildAracTipiSelector(),
            Expanded(
              child: _isOcrScanning
                  ? const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan))
                  : _buildParcaListesi(),
            ),
            _buildMuhurleButonu(),
          ],
        ),
      ),
    );
  }

  Widget _buildAracTipiSelector() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _paketler.keys.map((tip) {
          if (_paketler[tip]!.isEmpty && tip == 'OCR Fatura Parçaları') return const SizedBox.shrink();
          bool active = _seciliAracTipi == tip;
          return GestureDetector(
            onTap: () => setState(() { _seciliAracTipi = tip; _secilenParcalar.clear(); }),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: active ? SiberTema.kuantumCyan.withOpacity(0.1) : Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: active ? SiberTema.kuantumCyan : Colors.white10),
              ),
              alignment: Alignment.center,
              child: Text(tip, style: TextStyle(color: active ? SiberTema.kuantumCyan : Colors.white54, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildParcaListesi() {
    final list = _paketler[_seciliAracTipi] ?? [];
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final parca = list[index];
        bool selected = _secilenParcalar.containsKey(parca);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.01),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? SiberTema.kuantumCyan.withOpacity(0.3) : Colors.white.withOpacity(0.05)),
          ),
          child: ExpansionTile(
            onExpansionChanged: (val) {
              if (val) { setState(() => _secilenParcalar[parca] ??= <String, dynamic>{'fiyat': 0.0}); }
              else { if (_secilenParcalar[parca]?['fiyat'] == 0.0 && _secilenParcalar[parca]?['gorsel'] == null) setState(() => _secilenParcalar.remove(parca)); }
            },
            leading: Icon(selected ? Icons.check_circle : Icons.circle_outlined, color: selected ? SiberTema.kuantumCyan : Colors.white10),
            title: Text(parca, style: TextStyle(color: selected ? Colors.white : Colors.white38, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
            childrenPadding: const EdgeInsets.all(16),
            iconColor: SiberTema.kuantumCyan,
            collapsedIconColor: Colors.white54,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (val) => _fiyatGuncelle(parca, val),
                      style: const TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
                      decoration: _siberInputDecor("Maliyet (₺)", Icons.payments_outlined),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: Icon(Icons.camera_alt, color: _secilenParcalar[parca]?['gorsel'] != null ? SiberTema.kuantumCyan : Colors.white24),
                    onPressed: () => _gorselSec(parca, ImageSource.camera),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildMuhurleButonu() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: GestureDetector(
        onTap: _isProcessing ? null : _agaMuhurle,
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [SiberTema.kuantumCyan, SiberTema.kuantumCyan.withOpacity(0.7)]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Center(
            child: _isProcessing
                ? const CircularProgressIndicator(color: Colors.white)
                : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fingerprint, color: Colors.white, size: 30),
                SizedBox(width: 15),
                Text("SİSTEME MÜHÜRLE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 2, fontFamily: 'Avenir')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}