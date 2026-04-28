import 'package:otodna/core/siber_tema.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/siber_tema.dart'; // 🚀 SİBER KÖPRÜ
import '../../../core/responsive_kalkan.dart';

class DistributorTerminali extends StatefulWidget {
  DistributorTerminali({super.key});

  @override
  State<DistributorTerminali> createState() => _DistributorTerminaliState();
}

class _DistributorTerminaliState extends State<DistributorTerminali> {
  static Color primaryCyan = SiberTema.kuantumCyan;
  static Color siberGold = SiberTema.siberGold;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Örnek Bayi Verisi (İleride Firestore'dan çekilecek)
  final List<Map<String, dynamic>> _altBayiler = [
    {"ad": "Maslak Oto Sanayi", "ciro": 1250000, "durum": "Aktif"},
    {"ad": "Bostancı Kuantum Motor", "ciro": 840000, "durum": "Aktif"},
    {"ad": "Siber Çıkmacı (İzmir)", "ciro": 450000, "durum": "Beklemede"},
  ];

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _buildSiberAppBar(),
              Expanded(
                child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAvantajPaneli(),
                        SizedBox(height: 32),
                        Text("B2B SİBER SİPARİŞ AĞI", style: TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
                        SizedBox(height: 16),
                        _buildAltBayiRadari(),
                        SizedBox(height: 32),
                        Text("TOPTAN ENVANTER MOTORU", style: TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
                        SizedBox(height: 16),
                        _buildTopluUrunGirisKarti(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ),
    );
  }

  Widget _buildSiberAppBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.4), border: Border(bottom: BorderSide(color: SiberTema.textMuted))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle), child: Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 18)),
              ),
              Text('D İ S T R İ B Ü T Ö R   A Ğ I', style: TextStyle(color: siberGold, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 3, fontFamily: 'Avenir')),
              Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: siberGold.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: siberGold.withOpacity(0.5))), child: Icon(Icons.hub_outlined, color: siberGold, size: 18)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvantajPaneli() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: siberGold.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: siberGold.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: siberGold.withOpacity(0.1), shape: BoxShape.circle), child: Icon(Icons.workspace_premium, color: siberGold, size: 24)),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("V.I.P DİSTRİBÜTÖR", style: TextStyle(color: SiberTema.textMain, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                        SizedBox(height: 4),
                        Text("OtoDNA Özel Komisyon Anlaşması", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontFamily: 'Avenir')),
                      ],
                    ),
                  )
                ],
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: SiberTema.textMuted)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Standart Karargah Payı", style: TextStyle(color: SiberTema.textMuted, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                  Text("%12", style: TextStyle(color: SiberTema.textMuted, fontSize: 16, fontWeight: FontWeight.bold, decoration: TextDecoration.lineThrough, fontFamily: 'Avenir')),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Distribütör Ayrıcalığı", style: TextStyle(color: siberGold, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                  Text("%10", style: TextStyle(color: siberGold, fontSize: 24, fontWeight: FontWeight.w900, shadows: [BoxShadow(color: siberGold, blurRadius: 10)], fontFamily: 'Avenir')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAltBayiRadari() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _altBayiler.length,
      itemBuilder: (context, index) {
        var bayi = _altBayiler[index];
        bool isAktif = bayi['durum'] == 'Aktif';
        Color drmRengi = isAktif ? primaryCyan : SiberTema.kanKirmizi;

        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(16), border: Border.all(color: drmRengi.withOpacity(0.2))),
          child: Row(
            children: [
              Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: drmRengi.withOpacity(0.1), shape: BoxShape.circle), child: Icon(isAktif ? Icons.store_outlined : Icons.timer_outlined, color: drmRengi, size: 20)),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bayi['ad'], style: TextStyle(color: SiberTema.textMain, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                    SizedBox(height: 4),
                    Text("Aylık Ciro: ₺${(bayi['ciro'] as int).toString()}", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontFamily: 'Avenir')),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: drmRengi.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(bayi['durum'].toString().toUpperCase(), style: TextStyle(color: drmRengi, fontSize: 9, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopluUrunGirisKarti() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("B2B Çoklu Ekleme Motoru Başlatılıyor...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: primaryCyan));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(color: primaryCyan.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: primaryCyan.withOpacity(0.3))),
            child: Row(
              children: [
                Icon(Icons.inventory_2_outlined, color: primaryCyan, size: 32),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Kuantum Batch Yükleme", style: TextStyle(color: SiberTema.textMain, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                      SizedBox(height: 8),
                      Text("Excel/CSV dosyanızla 10.000+ ürünü tek seferde siber ağa mühürleyin. %10 komisyon avantajı otomatik uygulanır.", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, height: 1.4, fontFamily: 'Avenir')),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: primaryCyan, size: 16)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
