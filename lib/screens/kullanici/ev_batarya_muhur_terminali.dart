import 'package:flutter/material.dart';

import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

class EvBataryaMuhurTerminali extends StatefulWidget {
  const EvBataryaMuhurTerminali({super.key});

  @override
  State<EvBataryaMuhurTerminali> createState() => _EvBataryaMuhurTerminaliState();
}

class _EvBataryaMuhurTerminaliState extends State<EvBataryaMuhurTerminali> with SingleTickerProviderStateMixin {
  bool _taranmiyor = true;
  bool _taramaBitti = false;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _bataryayiTara() async {
    setState(() {
      _taranmiyor = false;
      _taramaBitti = false;
    });

    // Simüle edilmiş batarya analizi (3 saniye)
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;
    setState(() {
      _taranmiyor = true;
      _taramaBitti = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Batarya Hücreleri Analiz Edildi. Durum: MÜKEMMEL", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.orangeAccent));
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: SiberTema.oledBlack.withOpacity(0.8),
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.orangeAccent, size: 20), onPressed: () => Navigator.pop(context)),
          title: const Text("EV BATARYA TERMİNALİ", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // 1. ÜST BİLGİ PANELLERİ
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.orangeAccent.withOpacity(0.3))),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.electric_car, color: Colors.orangeAccent, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("YÜKSEK VOLTAJ (HV) AĞI", style: TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          SizedBox(height: 4),
                          Text("Elektrikli araç bataryalarının SoH (State of Health) ölçümleri ve blok mühürlemesi buradan yapılır.", style: TextStyle(color: Colors.white54, fontSize: 10, height: 1.4)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // 2. RADAR VE TARAMA
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 200, height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.orangeAccent.withOpacity(0.5), width: 2),
                      boxShadow: [BoxShadow(color: Colors.orangeAccent.withOpacity(_taranmiyor ? 0 : 0.2 * _pulseController.value), blurRadius: 40, spreadRadius: 10)],
                    ),
                    child: Center(
                      child: _taranmiyor 
                          ? const Icon(Icons.electrical_services, color: Colors.orangeAccent, size: 64)
                          : const CircularProgressIndicator(color: Colors.orangeAccent, strokeWidth: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),

              // 3. TARAMA BUTONU
              if (!_taramaBitti)
                SizedBox(
                  width: double.infinity, height: 60,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent.withOpacity(0.1),
                      foregroundColor: Colors.orangeAccent,
                      side: const BorderSide(color: Colors.orangeAccent, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _taranmiyor ? _bataryayiTara : null,
                    icon: Icon(_taranmiyor ? Icons.radar : Icons.hourglass_top, size: 24),
                    label: Text(_taranmiyor ? "BATARYA HÜCRELERİNİ TARA" : "OBD2 VERİSİ OKUNUYOR...", style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ),
                ),

              // 4. SONUÇLAR VE MÜHÜR EKRANI
              if (_taramaBitti)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.orangeAccent.withOpacity(0.5))),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.orangeAccent, size: 48),
                      const SizedBox(height: 16),
                      const Text("BATARYA SAĞLIĞI (SoH)", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2)),
                      const SizedBox(height: 8),
                      const Text("%96.4", style: TextStyle(color: Colors.orangeAccent, fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -2)),
                      const SizedBox(height: 24),
                      _buildHucreSatiri("Hücre Voltaj Dengesi", "KUSURSUZ (0.02V Fark)", Colors.orangeAccent),
                      const SizedBox(height: 12),
                      _buildHucreSatiri("Şarj Döngüsü (Cycle)", "142 Kez Dolduruldu", Colors.white),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity, height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Batarya Kripto Mühürlendi!"), backgroundColor: SiberTema.kuantumCyan));
                          },
                          icon: const Icon(Icons.vpn_key),
                          label: const Text("BATARYAYI MÜHÜRLE", style: TextStyle(fontWeight: FontWeight.w900)),
                        ),
                      )
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHucreSatiri(String baslik, String deger, Color vurgu) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(baslik, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
        Text(deger, style: TextStyle(color: vurgu, fontSize: 12, fontWeight: FontWeight.w900)),
      ],
    );
  }
}
