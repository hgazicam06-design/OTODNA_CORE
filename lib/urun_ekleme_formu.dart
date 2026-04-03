// lib/screens/urun_ekleme_formu.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

/// 🛡️ KUANTUM ÜRÜN FIRLATMA MERKEZİ (SiberUrunEklemeFormu)
/// Bayilerin kendi bayrakları ve adlarıyla markete otonom ürün yüklediği ekran.
class SiberUrunEklemeFormu extends StatefulWidget {
  final String bayiId; // Ürünü yükleyen bayinin Karargah kimliği
  final String bayiAdi; // Bayinin Vitrinde Görünecek Kendi Adı!

  const SiberUrunEklemeFormu({super.key, required this.bayiId, required this.bayiAdi});

  @override
  State<SiberUrunEklemeFormu> createState() => _SiberUrunEklemeFormuState();
}

class _SiberUrunEklemeFormuState extends State<SiberUrunEklemeFormu> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _adCtrl = TextEditingController();
  final TextEditingController _skuCtrl = TextEditingController();
  final TextEditingController _adetCtrl = TextEditingController();
  final TextEditingController _fiyatCtrl = TextEditingController();

  String? _secilenKategori;
  bool _islemSuruyor = false;

  // ── 🚀 FİREBASE MÜHÜRLEME PROTOKOLÜ ──
  Future<void> _urunuPiyasayaFirlat() async {
    double fiyat = double.tryParse(_fiyatCtrl.text.trim()) ?? 0.0;

    if (!_formKey.currentState!.validate() || _secilenKategori == null || fiyat <= 0) {
      HapticFeedback.heavyImpact();
      _siberUyariGoster("SİBER İHLAL", "Lütfen tüm ürün bilgilerini, kategoriyi ve geçerli bir fiyatı girin.", SiberTema.kanKirmizi);
      return;
    }

    if (_islemSuruyor) return;
    setState(() => _islemSuruyor = true);
    HapticFeedback.lightImpact();

    developer.log("🚀 SİBER MARKET: ${widget.bayiAdi} bayisinin ürünü Karargah ağına yükleniyor...");

    try {
      int adet = int.tryParse(_adetCtrl.text) ?? 1;
      String urunKodu = _skuCtrl.text.trim().isEmpty ? "DNA-${DateTime.now().millisecondsSinceEpoch}" : _skuCtrl.text.trim();

      // ACID İşlem: Hem Market Vitrinine hem de Bayinin kendi stoklarına yaz
      await _db.runTransaction((transaction) async {
        DocumentReference marketRef = _db.collection('market_urunleri').doc(urunKodu);
        DocumentReference bayiStokRef = _db.collection('bayi_stoklari').doc("${widget.bayiId}_$urunKodu");

        Map<String, dynamic> urunVerisi = {
          'ad': _adCtrl.text.trim(),
          'barkod': urunKodu,
          'kategori': _secilenKategori,
          'fiyat': fiyat, // Bayi kendi fiyatını kendi belirler
          'asil_satici_id': widget.bayiId,
          'vitrin_satici_adi': widget.bayiAdi, // ÖZGÜRLÜK: Her bayi kendi adıyla çıkar!
          'puan': 5.0, // Yeni ürünler 5 yıldızla başlar
          'eklenme_tarihi': FieldValue.serverTimestamp(),
          'garantili_mi': true,
        };

        // 1. Vitrine Ekle
        transaction.set(marketRef, urunVerisi);

        // 2. Bayinin Envanterine Ekle
        transaction.set(bayiStokRef, {
          'urun_adi': _adCtrl.text.trim(),
          'barkod': urunKodu,
          'bayi_id': widget.bayiId,
          'adet': adet,
          'kritik_seviye': 5,
          'fiyat': fiyat,
          'eklenme_tarihi': FieldValue.serverTimestamp(),
        });
      });

      HapticFeedback.vibrate();
      developer.log("✅ ÜRÜN YAYINLANDI: Matrix vitrininde yerini aldı!");

      if (mounted) {
        _siberUyariGoster("SİBER ONAY", "Ürün başarıyla Kuantum Markete fırlatıldı.", SiberTema.kuantumCyan);
        Navigator.pop(context); // İşlem bitince formu kapatır
      }

    } catch (e) {
      HapticFeedback.heavyImpact();
      developer.log("🚨 AĞ ÇÖKTÜ: Ürün yüklenemedi!", error: e);
      _siberUyariGoster("BAĞLANTI HATASI", "Ürün Karargaha iletilemedi.", SiberTema.kanKirmizi);
    } finally {
      if (mounted) setState(() => _islemSuruyor = false);
    }
  }

  // ── 🚨 ARAYÜZ YARDIMCILARI ──
  void _siberUyariGoster(String baslik, String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SiberTema.matGrey,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: renk, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            const SizedBox(height: 4),
            Text(mesaj, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _adCtrl.dispose();
    _skuCtrl.dispose();
    _adetCtrl.dispose();
    _fiyatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🛡️ Bütün ekranı Tablet/Araç İçi Zırhına alıyoruz!
    return ResponsiveKalkan(
      child: Scaffold(
        backgroundColor: Colors.transparent, // Arka plan kalkan tarafından siyaha boyanacak
        appBar: AppBar(
          title: const Text("YENİ ÜRÜN FIRLAT", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 14)),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [
              // 1. SİBER BİLGİ PANELİ
              SiberTema.siberCamKalkan(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.storefront, color: SiberTema.kuantumCyan, size: 28),
                    const SizedBox(width: 12),
                    Expanded(child: Text("Yüklediğiniz ürünler OtoDNA Global Market vitrininde Karargahın güvencesiyle [${widget.bayiAdi}] bayrağı altında satılacaktır.", style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.5, letterSpacing: 0.5))),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // 2. TEKNİK BİLGİLER
              _buildSiberBaslik("ÜRÜN İSTİHBARATI"),
              _buildSiberGirdiAlan("Ürün Adı", "Örn: Kuantum Fren Balatası", Icons.inventory, _adCtrl, zorunlu: true),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildSiberGirdiAlan("Siber Kod (SKU)", "Barkod", Icons.qr_code, _skuCtrl)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSiberGirdiAlan("Stok Adedi", "10", Icons.layers, _adetCtrl, isNumber: true, zorunlu: true)),
                ],
              ),
              const SizedBox(height: 16),

              // Kategori Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24, width: 1.5)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    dropdownColor: SiberTema.matGrey,
                    icon: const Icon(Icons.keyboard_arrow_down, color: SiberTema.kuantumCyan),
                    hint: const Text("Kategori Seçin", style: TextStyle(color: Colors.white30, fontSize: 13)),
                    value: _secilenKategori,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    items: ["Mekanik & Motor", "Şase & Alt Takım", "Elektrik & Yazılım", "Kaporta & Estetik", "Sarf Malzeme"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => _secilenKategori = v),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 3. FİYATLANDIRMA
              _buildSiberBaslik("VİTRİN FİYATI"),
              _buildSiberGirdiAlan("Ürün Satış Fiyatı (₺)", "0.00", Icons.attach_money, _fiyatCtrl, isNumber: true, zorunlu: true),

              const SizedBox(height: 40),

              // 4. ATEŞLEME BUTONU
              SizedBox(
                height: 60,
                width: double.infinity,
                child: _islemSuruyor
                    ? const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan))
                    : ElevatedButton.icon(
                  style: SiberTema.kuantumButonStili(),
                  onPressed: _urunuPiyasayaFirlat,
                  icon: const Icon(Icons.rocket_launch, color: SiberTema.oledBlack, size: 24),
                  label: const Text("ÜRÜNÜ VİTRİNE ÇIKAR"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 🔧 ARAYÜZ YARDIMCILARI ──
  Widget _buildSiberBaslik(String baslik) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(baslik, style: const TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSiberGirdiAlan(String baslik, String ipucu, IconData ikon, TextEditingController? controller, {bool isNumber = false, bool zorunlu = false}) {
    return Container(
      decoration: BoxDecoration(
        color: SiberTema.matGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 1.5),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: zorunlu ? (value) {
          if (value == null || value.trim().isEmpty) return '*';
          return null;
        } : null,
        style: const TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 1),
        decoration: InputDecoration(
          prefixIcon: Icon(ikon, color: SiberTema.kuantumCyan, size: 20),
          labelText: baslik,
          labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
          hintText: ipucu,
          hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
    );
  }
}