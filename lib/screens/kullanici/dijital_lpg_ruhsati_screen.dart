import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/responsive_kalkan.dart';

class DijitalLpgRuhsatiScreen extends StatelessWidget {
  DijitalLpgRuhsatiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🏢 PLAZA KALİTESİ PALET
    final primaryTeal = Colors.teal.shade700;
    const bgColor = Color(0xFFFAFAFC);
    const textColor = Color(0xFF1E293B);

    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1)),
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: primaryTeal, size: 18), onPressed: () => Navigator.pop(context)),
          title: Text("DİJİTAL MONTAJ RUHSATI", style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2, fontFamily: 'Avenir')),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGarantiKarti(primaryTeal, textColor),
              SizedBox(height: 32),
              Text("MONTAJ DETAYLARI", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontFamily: 'Avenir')),
              SizedBox(height: 16),
              _buildDetaySatiri("Araç Şase", "WBA**************", textColor),
              _buildDetaySatiri("Kit Markası", "Prins VSI-3 DI", textColor),
              _buildDetaySatiri("Yazılım Versiyonu", "V2.1.0", textColor),
              _buildDetaySatiri("Yetkili Servis", "Kadıköy Merkez Otogaz", textColor),
              SizedBox(height: 32),
              Text("MEDYA KANITLARI", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontFamily: 'Avenir')),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildKanitKarti("Manifold", Icons.image, primaryTeal, textColor)),
                  SizedBox(width: 16),
                  Expanded(child: _buildKanitKarti("Sızdırmazlık", Icons.videocam, primaryTeal, textColor)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGarantiKarti(Color primaryTeal, Color textColor) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryTeal.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.05), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.verified_user, color: primaryTeal, size: 64),
          SizedBox(height: 16),
          Text("10 YIL PLAZA GARANTİSİ", style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
          SizedBox(height: 8),
          Text("Bu aracın montajı yetkili Karargah bayisi tarafından yapılmış ve blokzincir ağına mühürlenmiştir.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.5, fontFamily: 'Avenir')),
          SizedBox(height: 24),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(color: primaryTeal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Text("GEÇERLİLİK: 2036 YILINA KADAR", style: TextStyle(color: primaryTeal, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
          )
        ],
      ),
    );
  }

  Widget _buildDetaySatiri(String baslik, String deger, Color textColor) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(baslik, style: TextStyle(color: Colors.white54, fontSize: 13, fontFamily: 'Avenir')),
          Text(deger, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
        ],
      ),
    );
  }

  Widget _buildKanitKarti(String baslik, IconData ikon, Color primaryTeal, Color textColor) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Icon(ikon, color: primaryTeal.withValues(alpha: 0.6), size: 32),
          SizedBox(height: 12),
          Text(baslik, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
        ],
      ),
    );
  }
}
