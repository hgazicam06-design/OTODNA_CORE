import 'package:otodna/core/siber_tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

/// 💳 SİBER ÖDEME GEÇİDİ (PAYTR SİMÜLASYONU)
/// Müşteri ödemelerinin "Kredi Kartı" veya "Mobil Ödeme" ile alındığı Kuantum Finans arayüzü.
class SiberOdemeGecidiScreen extends StatefulWidget {
  final double toplamTutar;
  final double komisyonTutar;
  final double esnafNet;

  SiberOdemeGecidiScreen({
    super.key,
    required this.toplamTutar,
    required this.komisyonTutar,
    required this.esnafNet,
  });

  @override
  State<SiberOdemeGecidiScreen> createState() => _SiberOdemeGecidiScreenState();
}

class _SiberOdemeGecidiScreenState extends State<SiberOdemeGecidiScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _islemSuruyor = false;
  bool _odemeBasarili = false;

  // Kredi Kartı Kontrolleri
  final TextEditingController _kartNoCtrl = TextEditingController();
  final TextEditingController _kartSahibiCtrl = TextEditingController();
  final TextEditingController _skTarihCtrl = TextEditingController();
  final TextEditingController _cvvCtrl = TextEditingController();

  // Mobil Ödeme Kontrolleri
  final TextEditingController _telefonCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _siberUyari(String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: TextStyle(color: renk, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
      backgroundColor: Colors.black87,
      shape: RoundedRectangleBorder(side: BorderSide(color: renk), borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _odemeyiTamamla() async {
    // Basit Validasyon
    if (_tabController.index == 0) {
      if (_kartNoCtrl.text.isEmpty || _cvvCtrl.text.isEmpty) {
        _siberUyari("Kredi kartı bilgileri eksik!", SiberTema.kanKirmizi);
        HapticFeedback.vibrate();
        return;
      }
    } else {
      if (_telefonCtrl.text.isEmpty) {
        _siberUyari("Operatör faturası için telefon numarası zorunludur!", SiberTema.kanKirmizi);
        HapticFeedback.vibrate();
        return;
      }
    }

    setState(() => _islemSuruyor = true);
    HapticFeedback.heavyImpact();

    // SİBER İŞLEM SİMÜLASYONU
    await Future.delayed(Duration(seconds: 2));

    try {
      // 🚀 FIRESTORE ATOMİK KAYIT
      final docRef = FirebaseFirestore.instance.collection('finansal_islemler').doc();
      await docRef.set({
        'odeme_turu': _tabController.index == 0 ? 'Kredi Karti (PayTR)' : 'Mobil Odeme (Operator)',
        'toplam_tutar': widget.toplamTutar,
        'otodna_komisyon': widget.komisyonTutar,
        'esnaf_net_hakedis': widget.esnafNet,
        'durum': 'TAMAMLANDI',
        'islem_tarihi': FieldValue.serverTimestamp(),
      });

      // Kuantum Onay Animasyonu Tetikleyici
      setState(() {
        _islemSuruyor = false;
        _odemeBasarili = true;
      });
      HapticFeedback.heavyImpact();

      _siberUyari("✅ KUANTUM FİNANS TRANSFERİ BAŞARILI!", SiberTema.kuantumCyan);

      // Başarılı ödeme sonrası fatura ekranına (veya ana ekrana) dön
      await Future.delayed(Duration(seconds: 3));
      if (mounted) Navigator.pop(context, true);

    } catch (e) {
      _siberUyari("İşlem Başarısız: Ağ Bağlantısı Koptu.", SiberTema.kanKirmizi);
      setState(() => _islemSuruyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_odemeBasarili) {
      return _buildKuantumOnayAnimasyonu();
    }

    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.8),
          elevation: 0,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield_moon_rounded, color: SiberTema.sariAltin),
              SizedBox(width: 8),
              Text("SİBER ÖDEME AĞI", style: TextStyle(color: SiberTema.sariAltin, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
            ],
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: SiberTema.sariAltin),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: SiberTema.sariAltin,
            labelColor: SiberTema.sariAltin,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(icon: Icon(Icons.credit_card), text: "Kredi Kartı"),
              Tab(icon: Icon(Icons.phone_iphone), text: "Mobil Ödeme"),
            ],
          ),
        ),
        body: Column(
          children: [
            // ÖZET KART
            _buildFinansalOzet(),

            // TAB İÇERİKLERİ
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildKrediKartiFormu(),
                  _buildMobilOdemeFormu(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── GERÇEK ZAMANLI BİLANÇO ÖZETİ ──
  Widget _buildFinansalOzet() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SiberTema.matGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SiberTema.sariAltin.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: SiberTema.sariAltin.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Column(
        children: [
          Text("ÖDENECEK TOPLAM TUTAR", style: TextStyle(color: SiberTema.textMuted, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          SizedBox(height: 8),
          Text("${widget.toplamTutar.toStringAsFixed(2)} ₺", style: TextStyle(color: SiberTema.textMain, fontSize: 32, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: SiberTema.textMuted),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniBilgi("OtoDNA Komisyonu", "-${widget.komisyonTutar.toStringAsFixed(2)} ₺", SiberTema.kanKirmizi),
              _buildMiniBilgi("Esnaf Hakedişi", "+${widget.esnafNet.toStringAsFixed(2)} ₺", SiberTema.kuantumCyan),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMiniBilgi(String baslik, String deger, Color renk) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(baslik, style: TextStyle(color: SiberTema.textMuted, fontSize: 10)),
        SizedBox(height: 4),
        Text(deger, style: TextStyle(color: renk, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  // ── KREDİ KARTI (PAYTR SİMÜLASYONU) ──
  Widget _buildKrediKartiFormu() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          // 3D SİBER KART GÖRSELİ
          Container(
            height: 200,
            width: double.infinity,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E1E1E), Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SiberTema.sariAltin.withOpacity(0.5)),
              boxShadow: [BoxShadow(color: SiberTema.sariAltin.withOpacity(0.1), blurRadius: 20, spreadRadius: 5)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.contactless, color: SiberTema.textMuted, size: 28),
                    Text("PayTR", style: TextStyle(color: SiberTema.textMain.withOpacity(0.2), fontWeight: FontWeight.w900, fontSize: 20, fontStyle: FontStyle.italic)),
                  ],
                ),
                Text("**** **** **** ****", style: TextStyle(color: SiberTema.textMain.withOpacity(0.8), fontSize: 24, letterSpacing: 4, fontFamily: 'Courier')),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("İSİM SOYİSİM", style: TextStyle(color: SiberTema.textMuted, fontSize: 14, letterSpacing: 2)),
                    Text("AA/YY", style: TextStyle(color: SiberTema.textMuted, fontSize: 14, letterSpacing: 2)),
                  ],
                )
              ],
            ),
          ),
          SizedBox(height: 24),
          _buildSiberInput("Kart Numarası", Icons.credit_card, _kartNoCtrl, TextInputType.number),
          SizedBox(height: 16),
          _buildSiberInput("Kart Üzerindeki İsim", Icons.person, _kartSahibiCtrl, TextInputType.name),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildSiberInput("Son Kullanma (AA/YY)", Icons.calendar_today, _skTarihCtrl, TextInputType.datetime)),
              SizedBox(width: 16),
              Expanded(child: _buildSiberInput("CVV", Icons.security, _cvvCtrl, TextInputType.number, obscure: true)),
            ],
          ),
          SizedBox(height: 30),
          _buildOdemeButonu(),
        ],
      ),
    );
  }

  // ── MOBİL ÖDEME (OPERATÖR) SİMÜLASYONU ──
  Widget _buildMobilOdemeFormu() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: SiberTema.kuantumCyan.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Icon(Icons.cell_tower_rounded, color: SiberTema.kuantumCyan, size: 48),
                SizedBox(height: 12),
                Text("OPERATÖR MOBİL ÖDEME", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 8),
                Text("Turkcell, Vodafone veya Türk Telekom faturanıza yansıtılarak tahsil edilecektir.", textAlign: TextAlign.center, style: TextStyle(color: SiberTema.textMuted, fontSize: 12)),
              ],
            ),
          ),
          SizedBox(height: 30),
          _buildSiberInput("Cep Telefonu Numarası", Icons.phone_iphone, _telefonCtrl, TextInputType.phone),
          SizedBox(height: 30),
          _buildOdemeButonu(),
        ],
      ),
    );
  }

  // ── ORTAK GİRDİ (INPUT) ──
  Widget _buildSiberInput(String hint, IconData icon, TextEditingController controller, TextInputType type, {bool obscure = false}) {
    return TextField(
      controller: controller,
      keyboardType: type,
      obscureText: obscure,
      style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, letterSpacing: 1.5),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: TextStyle(color: SiberTema.textMuted, letterSpacing: 0),
        prefixIcon: Icon(icon, color: SiberTema.sariAltin, size: 20),
        filled: true,
        fillColor: Colors.black45,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: SiberTema.textMuted)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: SiberTema.sariAltin)),
      ),
    );
  }

  // ── ÖDEME BUTONU ──
  Widget _buildOdemeButonu() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _islemSuruyor ? null : _odemeyiTamamla,
        style: ElevatedButton.styleFrom(
          backgroundColor: SiberTema.sariAltin,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _islemSuruyor 
            ? CircularProgressIndicator(color: Colors.white)
            : Text("ÖDEMEYİ TAMAMLA", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2)),
      ),
    );
  }

  // ── MÜKEMMEL KUANTUM ONAY ANİMASYONU ──
  Widget _buildKuantumOnayAnimasyonu() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 800),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: SiberTema.kuantumCyan.withOpacity(0.1),
                      boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.5), blurRadius: 50, spreadRadius: value * 20)],
                    ),
                    child: Icon(Icons.check_circle, color: SiberTema.kuantumCyan, size: 100),
                  ),
                  SizedBox(height: 30),
                  Text("ÖDEME BAŞARILI", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 4, fontFamily: 'Avenir')),
                  SizedBox(height: 10),
                  Text("Hakediş hesabınıza yansıtıldı.", style: TextStyle(color: SiberTema.textMuted, fontSize: 14)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
