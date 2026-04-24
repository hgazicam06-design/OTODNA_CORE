import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

class DijitalLpgRuhsatiScreen extends StatelessWidget {
  const DijitalLpgRuhsatiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 18), onPressed: () => Navigator.pop(context)),
          title: const Text("DİJİTAL MONTAJ RUHSATI", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2, fontFamily: 'Avenir')),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGarantiKarti(),
              const SizedBox(height: 32),
              const Text("MONTAJ DETAYLARI", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 16),
              _buildDetaySatiri("Araç Şase", "WBA**************"),
              _buildDetaySatiri("Kit Markası", "Prins VSI-3 DI"),
              _buildDetaySatiri("Yazılım Versiyonu", "V2.1.0"),
              _buildDetaySatiri("Yetkili Servis", "Kadıköy Merkez Otogaz"),
              const SizedBox(height: 32),
              const Text("MEDYA KANITLARI", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildKanitKarti("Manifold", Icons.image)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildKanitKarti("Sızdırmazlık", Icons.videocam)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGarantiKarti() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: SiberTema.kuantumCyan.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3), width: 1.5),
            boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.1), blurRadius: 20)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.verified_user, color: SiberTema.kuantumCyan, size: 64),
              const SizedBox(height: 16),
              const Text("10 YIL KUANTUM GARANTİSİ", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
              const SizedBox(height: 8),
              const Text("Bu aracın LPG montajı yetkili Karargah bayisi tarafından yapılmış ve blokzincir ağına mühürlenmiştir.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.5)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Text("GEÇERLİLİK: 2036 YILINA KADAR", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetaySatiri(String baslik, String deger) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(baslik, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          Text(deger, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
        ],
      ),
    );
  }

  Widget _buildKanitKarti(String baslik, IconData ikon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(ikon, color: Colors.white38, size: 32),
          const SizedBox(height: 12),
          Text(baslik, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
