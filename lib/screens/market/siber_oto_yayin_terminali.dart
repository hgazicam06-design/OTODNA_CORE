import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../core/siber_tema.dart';
import '../../services/siber_ai_yayin_motoru.dart';

class SiberOtoYayinTerminali extends StatefulWidget {
  const SiberOtoYayinTerminali({super.key});

  @override
  State<SiberOtoYayinTerminali> createState() => _SiberOtoYayinTerminaliState();
}

class _SiberOtoYayinTerminaliState extends State<SiberOtoYayinTerminali> {
  // Fildişi ve Siber Gold Tema Renkleri
  final Color bgColor = const Color(0xFFFDFBF7);
  final Color surfaceColor = Colors.white;
  final Color primaryTeal = Colors.teal.shade700;
  final Color textMain = const Color(0xFF1E293B);
  final Color textMuted = const Color(0xFF64748B);
  
  final TextEditingController _saseController = TextEditingController();
  
  bool _isAnalyzing = false;
  bool _ilanHazir = false;
  
  String _aiIlanMetni = "";
  String _aiFiyatBandi = "";
  Map<String, dynamic> _mockAracVerisi = {};

  Future<void> _siberAnalizBaslat() async {
    if (_saseController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lütfen Kuantum Şase numarasını giriniz veya okutunuz."), backgroundColor: SiberTema.kanKirmizi)
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _ilanHazir = false;
    });

    try {
      // 1. AŞAMA: Sistemden veya Dış API'den Veri Çekme (Şu an Mock)
      // İleride burası NHTSA API veya OtoDNA Karargah veritabanından dolacak.
      await Future.delayed(const Duration(seconds: 2)); // API simülasyonu
      _mockAracVerisi = {
        'markaModel': 'Mercedes-Benz E 300 d 4MATIC AMG',
        'yil': 2022,
        'dnaSkoru': 96,
        'onayliEkstralar': 'Burmester Ses Sistemi, Otonom Sürüş Paketi, Seramik Kaplama (OtoDNA Onaylı)',
        'ekspertiz': 'Boyasız, Değişensiz (Kusursuz)',
        'tramer': 'Tramer Kaydı Yoktur'
      };

      // 2. AŞAMA: Gemini AI ile Otonom İlan Metni Üretimi (Plaza Kalitesinde)
      _aiIlanMetni = await SiberAiYayinMotoru.ilanMetniYaz(_mockAracVerisi);

      // 3. AŞAMA: Gemini AI ile Fiyat Bandı Tespiti
      _aiFiyatBandi = await SiberAiYayinMotoru.piyasaDegeriAnalizEt(
        _mockAracVerisi['markaModel'], 
        _mockAracVerisi['yil'], 
        _mockAracVerisi['dnaSkoru']
      );

      setState(() {
        _ilanHazir = true;
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("AI Bağlantı Koptu: $e"), backgroundColor: SiberTema.kanKirmizi)
      );
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _ilaniAgaYayinla() async {
    // Burada Firestore'a doğrudan _aiIlanMetni ve _aiFiyatBandi ile kayıt açılacak.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("🚀 İlan Kuantum Pazar Yerine Mühürlendi!"), backgroundColor: primaryTeal)
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "OTONOM İLAN MOTORU",
                      style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2, fontFamily: 'Avenir'),
                    ),
                    const SizedBox(height: 16),
                    _buildSaseGirisi(),
                    
                    const SizedBox(height: 32),
                    
                    if (_isAnalyzing)
                      _buildAnalizAnimasyonu()
                    else if (_ilanHazir)
                      _buildAIYayinGorunumu(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor, 
        border: Border(bottom: BorderSide(color: textMuted.withOpacity(0.1)))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(8), 
              decoration: BoxDecoration(color: textMuted.withOpacity(0.05), shape: BoxShape.circle), 
              child: Icon(Icons.arrow_back_ios_new, color: textMain, size: 18)
            ),
          ),
          Text('S İ B E R   O T O - Y A Y İ N', style: TextStyle(color: textMain, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 3, fontFamily: 'Avenir')),
          Container(
            padding: const EdgeInsets.all(8), 
            decoration: BoxDecoration(color: SiberTema.siberGold.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: SiberTema.siberGold.withOpacity(0.5))), 
            child: Icon(Icons.auto_awesome, color: SiberTema.siberGold, size: 18) // AI Yıldız İkonu
          ),
        ],
      ),
    );
  }

  Widget _buildSaseGirisi() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryTeal.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("QR / Şase Tarama Ayrıcalığı", style: TextStyle(color: primaryTeal, fontWeight: FontWeight.w900, fontSize: 14)),
              Icon(Icons.qr_code_scanner, color: primaryTeal),
            ],
          ),
          const SizedBox(height: 12),
          Text("Aracınızın şasesini okutarak Manuel Girişi tamamen ortadan kaldırın. Sistem her şeyi AI ile derleyecektir.", style: TextStyle(color: textMuted, fontSize: 12)),
          const SizedBox(height: 16),
          TextField(
            controller: _saseController,
            style: TextStyle(color: textMain, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              hintText: "Örn: WDD2130001AXXXXXX",
              hintStyle: TextStyle(color: textMuted.withOpacity(0.5)),
              filled: true,
              fillColor: bgColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.auto_awesome, color: Colors.white),
              label: const Text("AI SİBER ANALİZİ BAŞLAT", style: TextStyle(letterSpacing: 1, fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _siberAnalizBaslat,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAnalizAnimasyonu() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          CircularProgressIndicator(color: SiberTema.siberGold),
          const SizedBox(height: 24),
          Text("Gemini AI Aracı İnceliyor...", style: TextStyle(color: textMain, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text("Karargah kayıtları taranıyor, ilan derleniyor.", style: TextStyle(color: textMuted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildAIYayinGorunumu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI Fiyat Önerisi
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: SiberTema.siberGold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: SiberTema.siberGold)
          ),
          child: Column(
            children: [
              Text("OTODNA AI PİYASA DEĞERİ", style: TextStyle(color: SiberTema.siberGold, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
              const SizedBox(height: 8),
              Text(_aiFiyatBandi, style: TextStyle(color: textMain, fontSize: 24, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // AI İlan Açıklaması
        Text("AI DERLEMELİ İLAN METNİ (Plaza Üslubu)", style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: textMuted.withOpacity(0.2))
          ),
          child: Text(
            _aiIlanMetni,
            style: TextStyle(color: textMain, fontSize: 14, height: 1.5),
          ),
        ),
        const SizedBox(height: 32),
        
        // Tek Tuşla Yayınla Butonu
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.rocket_launch, color: Colors.white),
            label: const Text("OTONOM OLARAK YAYINLA", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
            style: ElevatedButton.styleFrom(
              backgroundColor: textMain,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _ilaniAgaYayinla,
          ),
        ),
      ],
    );
  }
}
