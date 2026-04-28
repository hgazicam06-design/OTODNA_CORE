import 'package:otodna/core/siber_tema.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dukkan_model.dart';
import '../../core/siber_tema.dart';

class IlanVerScreen extends StatefulWidget {
  final Dukkan aktifDukkan;

  IlanVerScreen({super.key, required this.aktifDukkan});

  @override
  State<IlanVerScreen> createState() => _IlanVerScreenState();
}

class _IlanVerScreenState extends State<IlanVerScreen> {
  static const _neonGreen = SiberTema.kuantumCyan;
  static const _siberGold = SiberTema.siberGold;

  final TextEditingController _adController = TextEditingController();
  final TextEditingController _fiyatController = TextEditingController();
  final TextEditingController _aciklamaController = TextEditingController();

  bool _isProcessing = false;

  @override
  void dispose() {
    _adController.dispose();
    _fiyatController.dispose();
    _aciklamaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool limitDolduMu = !widget.aktifDukkan.yeniIlanEklenebilirMi;
    bool vipMi = widget.aktifDukkan.isVip;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. KUANTUM ARKA PLAN
          Positioned.fill(
            child: Container(decoration: SiberTema.siberArkaPlan),
          ),
          
          // 2. ANA İSKELET
          SafeArea(
            child: Column(
              children: [
                _buildSiberAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFirmaBilgiBandi(maxLimit: widget.aktifDukkan.maxIlanSiniri),
                        SizedBox(height: 24),
                        
                        if (vipMi) ...[
                          _buildVipTopluYuklemeAlani(),
                          SizedBox(height: 24),
                        ],
                        
                        if (limitDolduMu)
                          _buildLimitDoluUyarisi()
                        else
                          _buildStandartIlanFormu(),
                          
                        SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── ŞIK CAM APP BAR ───
  Widget _buildSiberAppBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            border: Border(bottom: BorderSide(color: Colors.white10)),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back_ios_new, color: _neonGreen, size: 20),
              ),
              SizedBox(width: 16),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(color: _neonGreen.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.add_shopping_cart, color: _neonGreen, size: 18),
              ),
              SizedBox(width: 12),
              Text("Siber Oto Market", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
            ],
          ),
        ),
      ),
    );
  }

  // ─── ROZET & LİMİT EKRANI (GLASSMORPHISM) ───
  Widget _buildFirmaBilgiBandi({required int maxLimit}) {
    String limitMetni = maxLimit == -1 ? "Sınırsız (VIP)" : "${widget.aktifDukkan.kullanilanIlanSayisi} / $maxLimit";
    bool isVip = widget.aktifDukkan.isVip;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isVip ? _siberGold.withOpacity(0.5) : Colors.white10),
            boxShadow: isVip ? [BoxShadow(color: _siberGold.withOpacity(0.1), blurRadius: 15)] : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.aktifDukkan.ad.toUpperCase(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5, fontFamily: 'Avenir')),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(isVip ? Icons.stars : Icons.storefront, color: isVip ? _siberGold : Colors.white54, size: 14),
                      SizedBox(width: 6),
                      Text("Ağ Rozeti: ${widget.aktifDukkan.rozet}", style: TextStyle(color: isVip ? _siberGold : Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Aktif İlan", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                  Text(limitMetni, style: TextStyle(color: _neonGreen, fontWeight: FontWeight.w900, fontSize: 16, fontFamily: 'Avenir')),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // ─── VIP TOPLU YÜKLEME (ELİT GÖRÜNÜM) ───
  Widget _buildVipTopluYuklemeAlani() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _siberGold.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: _siberGold.withOpacity(0.05), blurRadius: 20, spreadRadius: 2)],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: _siberGold.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.auto_awesome, color: _siberGold, size: 28),
          ),
          SizedBox(height: 16),
          Text("VIP TOPLU KİTLE YÜKLEME", style: TextStyle(color: _siberGold, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5, fontFamily: 'Avenir')),
          SizedBox(height: 8),
          Text("Excel / PDF ağını bağlayın. Kuantum AI binlerce ilanı tek tuşla vitrine dizsin.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.4, fontFamily: 'Avenir')),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _siberGold.withOpacity(0.1),
                foregroundColor: _siberGold,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: _siberGold.withOpacity(0.5))),
                elevation: 0,
              ),
              icon: Icon(Icons.file_upload, size: 18),
              label: Text("Katalog Ağına Bağlan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'Avenir')),
              onPressed: () => _uyariGoster("VIP Kuantum Tarayıcı Başlatılıyor...", isGold: true),
            ),
          )
        ],
      ),
    );
  }

  // ─── LİMİT DOLU (KAN KIRMIZISI UYARI) ───
  Widget _buildLimitDoluUyarisi() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SiberTema.kanKirmizi.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: SiberTema.kanKirmizi.withOpacity(0.1), blurRadius: 20)],
      ),
      child: Column(
        children: [
          Icon(Icons.block, color: SiberTema.kanKirmizi, size: 40),
          SizedBox(height: 16),
          Text("SİBER LİMİT DOLDU", style: TextStyle(color: SiberTema.kanKirmizi, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1, fontFamily: 'Avenir')),
          SizedBox(height: 8),
          Text(
            "Mevcut paketinizle Kuantum Ağına daha fazla ilan basamazsınız. Daha fazla müşteriye ulaşmak için yetki rozetinizi yükseltin.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, height: 1.4, fontFamily: 'Avenir'),
          ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: SiberTema.kanKirmizi,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: Icon(Icons.rocket_launch, size: 18),
              label: Text("ROZET YÜKSELT (VIP GEÇİŞ)", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
              onPressed: () => _uyariGoster("Siber Kasaya Bağlanılıyor..."),
            ),
          )
        ],
      ),
    );
  }

  // ─── TEKLİ İLAN FORMU (GLASSMORPHISM) ───
  Widget _buildStandartIlanFormu() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.add_box_outlined, color: _neonGreen, size: 18),
              SizedBox(width: 8),
              Text("MANUEL İLAN GİRİŞİ", style: TextStyle(color: _neonGreen, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5, fontFamily: 'Avenir')),
            ],
          ),
          SizedBox(height: 24),
          _buildSiberTextField("Parça / Araç Adı", Icons.title, _adController),
          SizedBox(height: 16),
          _buildSiberTextField("Fiyat (TL)", Icons.attach_money, _fiyatController, isNumber: true),
          SizedBox(height: 16),
          _buildSiberTextField("Açıklama / Detaylar", Icons.description_outlined, _aciklamaController, maxLines: 4),
          SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _neonGreen,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 10,
                shadowColor: _neonGreen.withOpacity(0.3),
              ),
              onPressed: _isProcessing ? null : _ilanYayinla,
              child: _isProcessing
                  ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
                  : Text("AĞA YAYINLA", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5, fontFamily: 'Avenir')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiberTextField(String hint, IconData icon, TextEditingController controller, {bool isNumber = false, int maxLines = 1}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            border: Border.all(color: Colors.white12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            maxLines: maxLines,
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: maxLines > 1 ? (maxLines * 10.0) : 0),
                child: Icon(icon, color: _neonGreen.withOpacity(0.7), size: 18),
              ),
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white38, fontSize: 12, fontFamily: 'Avenir'),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
          ),
        ),
      ),
    );
  }

  void _uyariGoster(String mesaj, {bool isGold = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: TextStyle(color: isGold ? Colors.black : SiberTema.oledBlack, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
      backgroundColor: isGold ? _siberGold : _neonGreen,
    ));
  }

  Future<void> _ilanYayinla() async {
    if (_adController.text.isEmpty || _fiyatController.text.isEmpty) {
      _uyariGoster("SİBER İHLAL: Lütfen Zorunlu Alanları Doldurun!", isGold: true);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      await FirebaseFirestore.instance.collection('ilanlar').add({
        'dukkan_id': widget.aktifDukkan.id,
        'ilan_ad': _adController.text,
        'fiyat': double.tryParse(_fiyatController.text) ?? 0,
        'aciklama': _aciklamaController.text,
        'kayit_tarihi': FieldValue.serverTimestamp(),
        'vitrin_etiketi': widget.aktifDukkan.ad,
      });

      if (mounted) {
        _uyariGoster("İlan Kuantum Ağına Mühürlendi!");
        Navigator.pop(context);
      }
    } catch (e) {
      _uyariGoster("AĞ HATASI: İlan yayınlanamadı!", isGold: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}