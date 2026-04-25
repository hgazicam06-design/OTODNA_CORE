import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';
import '../../models/offer_item_model.dart';
import 'siber_odeme_gecidi_screen.dart';

/// 💰 SİBER FATURA VE KUANTUM TEKLİF ARAYÜZÜ
/// Ürünlerin manuel eklendiği veya PDF'ten okutulduğu,
/// OtoDNA Komisyonunun (Gazi Payı) siber hızda kesilip net hakedişin gösterildiği kokpit.
class SiberFaturaScreen extends StatefulWidget {
  final String firmaAdi;

  const SiberFaturaScreen({super.key, required this.firmaAdi});

  @override
  State<SiberFaturaScreen> createState() => _SiberFaturaScreenState();
}

class _SiberFaturaScreenState extends State<SiberFaturaScreen> {
  final List<OfferItem> _faturaKalemleri = [];
  bool _islemSuruyor = false;

  // Yeni Ürün Ekleme Kontrolleri
  final TextEditingController _urunAdiCtrl = TextEditingController();
  final TextEditingController _adetCtrl = TextEditingController(text: "1");
  final TextEditingController _alisFiyatiCtrl = TextEditingController();
  final TextEditingController _satisFiyatiCtrl = TextEditingController();

  // ── 🧮 GENEL BİLANÇO HESAPLAYICILARI ──
  double get _toplamMusteriOdemesi => _faturaKalemleri.fold(0, (sum, item) => sum + item.totalWithTax);
  double get _toplamGaziPayi => _faturaKalemleri.fold(0, (sum, item) => sum + item.gaziPayi);
  double get _toplamEsnafHakedisi => _faturaKalemleri.fold(0, (sum, item) => sum + item.bayiHakedisi);
  double get _toplamNetKar => _faturaKalemleri.fold(0, (sum, item) => sum + item.esnafNetKari);

  void _siberUyari(String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: TextStyle(color: renk, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
      backgroundColor: Colors.black87,
      shape: RoundedRectangleBorder(side: BorderSide(color: renk), borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
  }

  // ── PDF YAPAY ZEKA TARAMA SİMÜLASYONU ──
  Future<void> _pdfVeyaFaturaTara() async {
    setState(() => _islemSuruyor = true);
    HapticFeedback.heavyImpact();
    
    // AI Tarama Simülasyonu
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _faturaKalemleri.add(OfferItem(
        saticiAdi: widget.firmaAdi,
        description: "AI Taraması: Triger Seti (Orijinal)",
        quantity: 1,
        alisFiyati: 3500.0,
        satisFiyati: 4500.0,
      ));
      _faturaKalemleri.add(OfferItem(
        saticiAdi: widget.firmaAdi,
        description: "AI Taraması: İşçilik Bedeli",
        quantity: 1,
        alisFiyati: 0.0,
        satisFiyati: 1500.0,
      ));
      _islemSuruyor = false;
    });

    _siberUyari("PDF BAŞARIYLA TARANDI: Veriler listeye eklendi.", SiberTema.kuantumCyan);
  }

  // ── MANUEL ÜRÜN EKLEME ──
  void _manuelUrunEkle() {
    if (_urunAdiCtrl.text.isEmpty || _satisFiyatiCtrl.text.isEmpty) {
      _siberUyari("Ürün Adı ve Satış Fiyatı zorunludur!", SiberTema.kanKirmizi);
      return;
    }

    final double satisFiyati = double.tryParse(_satisFiyatiCtrl.text.replaceAll(',', '.')) ?? 0.0;
    final double alisFiyati = double.tryParse(_alisFiyatiCtrl.text.replaceAll(',', '.')) ?? 0.0;
    final int adet = int.tryParse(_adetCtrl.text) ?? 1;

    setState(() {
      _faturaKalemleri.add(OfferItem(
        saticiAdi: widget.firmaAdi,
        description: _urunAdiCtrl.text.trim(),
        quantity: adet,
        alisFiyati: alisFiyati,
        satisFiyati: satisFiyati,
      ));
    });

    // Formu temizle
    _urunAdiCtrl.clear();
    _adetCtrl.text = "1";
    _alisFiyatiCtrl.clear();
    _satisFiyatiCtrl.clear();
    
    HapticFeedback.lightImpact();
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
          title: const Text("💰 KUANTUM TEKLİF & FATURA", style: TextStyle(color: SiberTema.sariAltin, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
          centerTitle: true,
          iconTheme: const IconThemeData(color: SiberTema.sariAltin),
          actions: [
            IconButton(
              icon: const Icon(Icons.document_scanner, color: SiberTema.kuantumCyan),
              tooltip: "AI Fatura/PDF Tara",
              onPressed: _islemSuruyor ? null : _pdfVeyaFaturaTara,
            )
          ],
        ),
        body: Column(
          children: [
            // ÜST KISIM: YENİ ÜRÜN GİRİŞ ALANI
            _buildManuelGirisFormu(),
            
            // ORTA KISIM: FATURA KALEMLERİ LİSTESİ
            Expanded(
              child: _faturaKalemleri.isEmpty 
                ? _buildBosListeUyarisi() 
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _faturaKalemleri.length,
                    itemBuilder: (context, index) {
                      final item = _faturaKalemleri[index];
                      return _buildFaturaSatiri(item, index);
                    },
                  ),
            ),
            
            // ALT KISIM: GERÇEK ZAMANLI BİLANÇO
            _buildSiberBilancoPaneli(),
          ],
        ),
      ),
    );
  }

  // ── YENİ ÜRÜN GİRİŞ FORMU ──
  Widget _buildManuelGirisFormu() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        border: const Border(bottom: BorderSide(color: Colors.white12, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(flex: 3, child: _buildCyberInput("Ürün/Hizmet Adı", Icons.build, _urunAdiCtrl)),
              const SizedBox(width: 12),
              Expanded(flex: 1, child: _buildCyberInput("Adet", Icons.numbers, _adetCtrl, type: TextInputType.number)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildCyberInput("Alış F. (Opsiyonel)", Icons.arrow_downward, _alisFiyatiCtrl, type: const TextInputType.numberWithOptions(decimal: true))),
              const SizedBox(width: 12),
              Expanded(child: _buildCyberInput("Satış F. (Zorunlu)", Icons.arrow_upward, _satisFiyatiCtrl, type: const TextInputType.numberWithOptions(decimal: true))),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _manuelUrunEkle,
            icon: const Icon(Icons.add_shopping_cart, color: Colors.black),
            label: const Text("LİSTEYE EKLE", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
            style: ElevatedButton.styleFrom(
              backgroundColor: SiberTema.sariAltin,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCyberInput(String hint, IconData icon, TextEditingController controller, {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: type,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 11),
        prefixIcon: Icon(icon, color: SiberTema.sariAltin, size: 16),
        filled: true,
        fillColor: Colors.black45,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: SiberTema.sariAltin)),
      ),
    );
  }

  Widget _buildBosListeUyarisi() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded, size: 80, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          const Text("Fatura Boş", style: TextStyle(color: Colors.white54, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Yukarıdan manuel ekleyin veya PDF taratın.", style: TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }

  // ── FATURA SATIRI (ITEM) ──
  Widget _buildFaturaSatiri(OfferItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SiberTema.matGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(item.description, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.delete_outline, color: SiberTema.kanKirmizi, size: 20),
                onPressed: () => setState(() => _faturaKalemleri.removeAt(index)),
              )
            ],
          ),
          const Divider(color: Colors.white12, height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniBilgi("Miktar", "${item.quantity}x", Colors.white70),
              _buildMiniBilgi("Birim F.", "${item.satisFiyati.toStringAsFixed(2)} ₺", Colors.white70),
              _buildMiniBilgi("OtoDNA Payı", "-${item.gaziPayi.toStringAsFixed(2)} ₺", SiberTema.kanKirmizi),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBilgi(String baslik, String deger, Color renk) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(baslik, style: const TextStyle(color: Colors.white38, fontSize: 10)),
        const SizedBox(height: 2),
        Text(deger, style: TextStyle(color: renk, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }

  // ── GERÇEK ZAMANLI SİBER BİLANÇO KOKPİTİ ──
  Widget _buildSiberBilancoPaneli() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        border: const Border(top: BorderSide(color: SiberTema.sariAltin, width: 2)),
        boxShadow: [BoxShadow(color: SiberTema.sariAltin.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildBilancoSatiri("Müşteri Ödemesi (KDV Dahil)", _toplamMusteriOdemesi, Colors.white),
            const SizedBox(height: 8),
            _buildBilancoSatiri("OtoDNA Payı (Komisyon)", -_toplamGaziPayi, SiberTema.kanKirmizi),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(color: Colors.white24, height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("BAYİ NET HAKEDİŞİ", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    Text("Esnafın cebine girecek tutar", style: TextStyle(color: Colors.white38, fontSize: 10)),
                  ],
                ),
                Text("${_toplamEsnafHakedisi.toStringAsFixed(2)} ₺", style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _faturaKalemleri.isEmpty ? null : () async {
                  final sonuc = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SiberOdemeGecidiScreen(
                        toplamTutar: _toplamMusteriOdemesi,
                        komisyonTutar: _toplamGaziPayi,
                        esnafNet: _toplamEsnafHakedisi,
                      ),
                    ),
                  );
                  
                  if (sonuc == true) {
                    // Ödeme başarılıysa listeyi sıfırla
                    setState(() {
                      _faturaKalemleri.clear();
                    });
                  }
                },
                icon: const Icon(Icons.payment_rounded, color: Colors.black),
                label: const Text("ÖDEME AL (PayTR)", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SiberTema.sariAltin,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: Colors.white12,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBilancoSatiri(String baslik, double deger, Color renk) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(baslik, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
        Text("${deger > 0 ? '' : ''}${deger.toStringAsFixed(2)} ₺", style: TextStyle(color: renk, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
