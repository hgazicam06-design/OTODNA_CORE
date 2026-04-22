import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/siber_tema.dart';

class SiberCiroRaporlama extends StatefulWidget {
  final bool isDistributor; // True ise %10, False ise %12 Kuantum Komisyonu

  const SiberCiroRaporlama({super.key, this.isDistributor = false});

  @override
  State<SiberCiroRaporlama> createState() => _SiberCiroRaporlamaState();
}

class _SiberCiroRaporlamaState extends State<SiberCiroRaporlama> {
  static const Color primaryCyan = SiberTema.kuantumCyan;
  static const Color siberGold = SiberTema.siberGold;

  // Örnek Veri MOCK
  final double aylikCiro = 1450000.0; // 1.45 Milyon TL
  late double komisyonOrani;
  late double kesintiTutari;
  late double netKazanc;

  @override
  void initState() {
    super.initState();
    komisyonOrani = widget.isDistributor ? 0.10 : 0.12;
    kesintiTutari = aylikCiro * komisyonOrani;
    netKazanc = aylikCiro - kesintiTutari;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. KUANTUM ARKA PLAN
          Positioned.fill(child: Container(decoration: SiberTema.siberArkaPlan)),

          // 2. ANA İÇERİK
          SafeArea(
            child: Column(
              children: [
                _buildSiberAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCiroOzeti(),
                        const SizedBox(height: 32),
                        const Text("FİNANSAL İSTİHBARAT", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
                        const SizedBox(height: 16),
                        _buildKomisyonDetayi(),
                        const SizedBox(height: 32),
                        _buildSonIslemler(),
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

  Widget _buildSiberAppBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), border: const Border(bottom: BorderSide(color: Colors.white10))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle), child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18)),
              ),
              const Text('C İ R O   R A D A R I', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 3, fontFamily: 'Avenir')),
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: primaryCyan.withOpacity(0.5))), child: const Icon(Icons.account_balance_wallet_outlined, color: primaryCyan, size: 18)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCiroOzeti() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          shape: BoxShape.circle,
          border: Border.all(color: primaryCyan.withOpacity(0.5), width: 2),
          boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.1), blurRadius: 40, spreadRadius: 10)],
        ),
        child: Column(
          children: [
            const Text("NET SİBER KAZANÇ", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
            const SizedBox(height: 8),
            Text("₺${netKazanc.toStringAsFixed(2)}", style: const TextStyle(color: primaryCyan, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1, fontFamily: 'Avenir')),
          ],
        ),
      ),
    );
  }

  Widget _buildKomisyonDetayi() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white10)),
          child: Column(
            children: [
              _buildFinansSatiri("Brüt İşlem Hacmi", "₺${aylikCiro.toStringAsFixed(2)}", Colors.white),
              const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.white12)),
              _buildFinansSatiri(
                "Karargah Payı (${widget.isDistributor ? '%10 V.I.P' : '%12'})", 
                "-₺${kesintiTutari.toStringAsFixed(2)}", 
                SiberTema.kanKirmizi
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinansSatiri(String baslik, String deger, Color renk) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(baslik, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
        Text(deger, style: TextStyle(color: renk, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
      ],
    );
  }

  Widget _buildSonIslemler() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("SON ONAYLANAN İŞLEMLER", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
        const SizedBox(height: 16),
        _buildIslemKarti("Triger Seti Değişimi", "24.03.2026", 4500.0),
        _buildIslemKarti("Ağır Bakım (100.000 KM)", "22.03.2026", 12500.0),
        _buildIslemKarti("Fren Balatası Yenileme", "20.03.2026", 2800.0),
      ],
    );
  }

  Widget _buildIslemKarti(String baslik, String tarih, double tutar) {
    double kesinti = tutar * komisyonOrani;
    double net = tutar - kesinti;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.check_circle_outline, color: primaryCyan, size: 20)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(baslik, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                const SizedBox(height: 4),
                Text(tarih, style: const TextStyle(color: Colors.white54, fontSize: 10, fontFamily: 'Avenir')),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("+₺${net.toStringAsFixed(2)}", style: const TextStyle(color: primaryCyan, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
              const SizedBox(height: 4),
              Text("Brüt: ₺${tutar.toStringAsFixed(0)}", style: const TextStyle(color: Colors.white38, fontSize: 9, fontFamily: 'Avenir')),
            ],
          )
        ],
      ),
    );
  }
}