// lib/screens/barkod_urun_ekleme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Siber Titreşim (Haptic) için eklendi
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM ÜRÜN & BARKOD MERKEZİ (BarkodUrunEkleme)
/// Bayinin girdiği satış fiyatı üzerinden otonom %12 (Veya Murat Plaza için %30) kesinti hesaplar, barkod üretir ve markete mühürler.
class BarkodUrunEkleme extends StatefulWidget {
  final String bayiId; // Ürünü ekleyen firmanın Karargah kimliği

  BarkodUrunEkleme({super.key, required this.bayiId});

  @override
  State<BarkodUrunEkleme> createState() => _BarkodUrunEklemeState();
}

class _BarkodUrunEklemeState extends State<BarkodUrunEkleme> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── SİBER İSTİHBARAT DEĞİŞKENLERİ ──
  final TextEditingController _urunAdiCtrl = TextEditingController();
  final TextEditingController _fiyatCtrl = TextEditingController();

  String _barkodVerisi = "";
  double _musteriSatisFiyati = 0.0;
  double _bayiHakedisi = 0.0;
  double _otodnaPayi = 0.0;
  double _uygulananKesintiOrani = 0.12;
  bool _islemSuruyor = false;

  // ── 🎨 KARARGAH TASARIM DOKTRİNİ ──
  static Color _oledBlack = Color(0xFF000000);
  static Color _matGrey = Color(0xFF111111);
  static Color _kuantumCyan = Color(0xFF00FFC2);

  // ── ⚙️ DİNAMİK BARKOD VE FİNANS MOTORU ──
  void _hesaplaVeBarkodUret() {
    String urunAdi = _urunAdiCtrl.text.trim();
    String fiyatMetni = _fiyatCtrl.text.trim();

    if (urunAdi.isEmpty || fiyatMetni.isEmpty) {
      setState(() {
        _barkodVerisi = "";
        _musteriSatisFiyati = 0.0;
        _bayiHakedisi = 0.0;
        _otodnaPayi = 0.0;
      });
      return;
    }

    double girilenFiyat = double.tryParse(fiyatMetni) ?? 0.0;

    setState(() {
      // 1. Barkod Üretimi (Kriptolu Şifre)
      _barkodVerisi = "OTODNA-${widget.bayiId}-${DateTime.now().millisecondsSinceEpoch}";

      // 2. DOĞRU FİNANS HESABI (Komisyon Satış Fiyatının İçinden Alınır)
      _musteriSatisFiyati = girilenFiyat;

      // ⚖️ KARARGAH KURALI: Murat Plaza %30, diğerleri %12 kesinti!
      _uygulananKesintiOrani = (widget.bayiId == "MURAT_PLAZA") ? 0.30 : 0.12;

      _otodnaPayi = _musteriSatisFiyati * _uygulananKesintiOrani;
      _bayiHakedisi = _musteriSatisFiyati - _otodnaPayi;
    });

    HapticFeedback.lightImpact(); // Hesaplama yapıldığında hafif siber titreşim
  }

  // ── 🚀 FİREBASE MÜHÜRLEME PROTOKOLÜ ──
  Future<void> _urunuMarketeFirlat() async {
    if (!_formKey.currentState!.validate() || _barkodVerisi.isEmpty) {
      HapticFeedback.heavyImpact();
      _siberUyariGoster("SİBER İHLAL", "Ürün adı ve geçerli bir fiyat girmelisiniz.", Colors.redAccent);
      return;
    }

    setState(() => _islemSuruyor = true);
    developer.log("🚀 SİBER MÜHÜRLEME: Ürün markete fırlatılıyor...");

    try {
      // Ürünü Firebase Market koleksiyonuna kaydet
      await _db.collection('market_urunleri').add({
        'bayi_id': widget.bayiId,
        'urun_adi': _urunAdiCtrl.text.trim(),
        'barkod_id': _barkodVerisi,
        'satis_fiyati': _musteriSatisFiyati,
        'otodna_kesintisi': _otodnaPayi,
        'kesinti_orani': "%${(_uygulananKesintiOrani * 100).toInt()}",
        'bayi_hakedisi': _bayiHakedisi,
        'olusturulma_tarihi': FieldValue.serverTimestamp(),
        'aktif_mi': true,
      });

      HapticFeedback.vibrate(); // Başarı titreşimi
      developer.log("✅ ONAY: ${_urunAdiCtrl.text} adlı ürün markette yayınlandı. Barkod: $_barkodVerisi");
      _siberUyariGoster("MÜHÜRLENDİ!", "Ürün ve Siber Barkod başarıyla Karargaha işlendi.", _kuantumCyan);

      // İşlem başarılıysa formu sıfırla
      _urunAdiCtrl.clear();
      _fiyatCtrl.clear();
      _hesaplaVeBarkodUret();

    } catch (e) {
      HapticFeedback.heavyImpact();
      developer.log("AĞ ÇÖKTÜ!", error: e);
      _siberUyariGoster("BAĞLANTI HATASI", "Ürün Karargaha iletilemedi.", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _islemSuruyor = false);
    }
  }

  // ── 🚨 ARAYÜZ YARDIMCILARI ──
  void _siberUyariGoster(String baslik, String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _matGrey,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: renk, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            SizedBox(height: 4),
            Text(mesaj, style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _urunAdiCtrl.dispose();
    _fiyatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _oledBlack,
      appBar: AppBar(
        title: Text("ÜRÜN & BARKOD MERKEZİ", style: TextStyle(color: _kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: _kuantumCyan),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            children: [
              // 1. ÜRÜN BİLGİSİ GİRİŞİ (Siber TextField)
              Text("ÜRÜN / HİZMET ADI", style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              _buildSiberInput(
                controller: _urunAdiCtrl,
                hintText: "Örn: Bosh Fren Balatası",
                icon: Icons.settings_input_component_outlined,
                onChanged: (v) => _hesaplaVeBarkodUret(),
              ),

              SizedBox(height: 20),

              // 2. FİYAT GİRİŞİ
              Text("MÜŞTERİ SATIŞ FİYATI (TL)", style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              _buildSiberInput(
                controller: _fiyatCtrl,
                hintText: "Örn: 2500",
                icon: Icons.account_balance_wallet_outlined,
                isNumber: true,
                onChanged: (v) => _hesaplaVeBarkodUret(),
              ),

              SizedBox(height: 24),

              // 3. 💰 OTOMATİK FİNANS HESAPLAYICI (Kuantum Pano)
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _matGrey,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _musteriSatisFiyati > 0 ? _kuantumCyan.withOpacity(0.5) : Colors.white12, width: 2),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.currency_exchange, color: _kuantumCyan, size: 20),
                        SizedBox(width: 8),
                        Text("SİBER FİNANS ANALİZİ (%${(_uygulananKesintiOrani * 100).toInt()})", style: TextStyle(color: _kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                      ],
                    ),
                    Divider(color: Colors.white24, height: 30),
                    _bilgiSatiri("KASANIZA GİRECEK (NET):", "₺${_bayiHakedisi.toStringAsFixed(2)}", Colors.white),
                    SizedBox(height: 12),
                    _bilgiSatiri("OTODNA KESİNTİSİ:", "₺${_otodnaPayi.toStringAsFixed(2)}", Colors.redAccent),
                    Divider(color: Colors.white24, height: 30),
                    _bilgiSatiri("MÜŞTERİ ÖDEYECEK:", "₺${_musteriSatisFiyati.toStringAsFixed(2)}", _kuantumCyan, isBold: true, isLarge: true),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // 4. 🖨️ BARKOD ÖNİZLEME (Hologram)
              if (_barkodVerisi.isNotEmpty)
                Center(
                  child: Column(
                    children: [
                      Text("SİBER ÜRÜN MÜHRÜ (QR KOD)", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white, // QR Kod okuyucular için beyaz arka plan şarttır
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: _kuantumCyan.withOpacity(0.3), blurRadius: 20, spreadRadius: 5)],
                        ),
                        child: QrImageView(
                          data: _barkodVerisi,
                          size: 160,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text("BARKOD ID: $_barkodVerisi", style: TextStyle(fontSize: 9, color: Colors.white30, letterSpacing: 1)),
                    ],
                  ),
                ),

              SizedBox(height: 40),

              // 5. 🚀 KARARGAHA FIRLATMA BUTONU
              SizedBox(
                height: 60,
                child: _islemSuruyor
                    ? Center(child: CircularProgressIndicator(color: _kuantumCyan))
                    : ElevatedButton.icon(
                  icon: Icon(Icons.rocket_launch, color: Colors.black, size: 24),
                  label: Text("ÜRÜNÜ VE BARKODU YAYINLA", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kuantumCyan,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: _barkodVerisi.isEmpty ? 0 : 10,
                    shadowColor: _kuantumCyan.withOpacity(0.5),
                  ),
                  onPressed: _urunuMarketeFirlat,
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── 🔧 ARAYÜZ YARDIMCI WIDGET'LARI ──────────────────────────────────────
  Widget _buildSiberInput({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isNumber = false,
    required Function(String) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _matGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24, width: 1.5),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        style: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 1),
        onChanged: onChanged,
        validator: (value) => value == null || value.isEmpty ? "Bu alan zorunludur" : null,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: _kuantumCyan, size: 22),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white30, letterSpacing: 1, fontSize: 12),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _bilgiSatiri(String baslik, String deger, Color degerRengi, {bool isBold = false, bool isLarge = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(baslik, style: TextStyle(color: Colors.white54, fontSize: isLarge ? 14 : 12, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, letterSpacing: 1)),
        Text(deger, style: TextStyle(color: degerRengi, fontSize: isLarge ? 22 : 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
      ],
    );
  }
}