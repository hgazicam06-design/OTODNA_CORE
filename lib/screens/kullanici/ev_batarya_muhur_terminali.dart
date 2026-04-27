import 'package:flutter/material.dart';

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

  // Plaza Kalitesi Renkleri (EV Konsepti: Zümrüt Yeşili & Teal)
  final Color primaryTeal = Colors.teal.shade700;
  final Color bgColor = const Color(0xFFFAFAFC);
  final Color textColor = const Color(0xFF1E293B);
  final Color evGreen = const Color(0xFF10B981); // Emerald Green

  // Şarj İstasyonları Mock Verisi
  final List<Map<String, dynamic>> _sarjIstasyonlari = [
    {'isim': 'ZES Hızlı Şarj İstasyonu', 'mesafe': '1.2 km', 'soket': '2/4 Boş', 'tip': 'DC 120kW', 'ikon': Icons.ev_station},
    {'isim': 'Eşarj Plaza AVM', 'mesafe': '3.5 km', 'soket': '1/2 Boş', 'tip': 'AC 22kW', 'ikon': Icons.electrical_services},
    {'isim': 'Voltrun Şehir Merkezi', 'mesafe': '5.0 km', 'soket': 'Dolu', 'tip': 'DC 60kW', 'ikon': Icons.battery_charging_full},
  ];

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
    
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Batarya Hücreleri Analiz Edildi. Durum: MÜKEMMEL", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, fontFamily: 'Avenir')), backgroundColor: evGreen));
  }

  void _istasyonlariTara() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: evGreen.withValues(alpha: 0.3), width: 2)),
          boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.1), blurRadius: 20)]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(Icons.radar, color: evGreen, size: 28),
                const SizedBox(width: 12),
                Text("EN YAKIN ŞARJ İSTASYONLARI", style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
              ],
            ),
            const SizedBox(height: 8),
            const Text("Bölgenizdeki 10 km yarıçapında bulunan güncel şarj noktaları.", style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
            const SizedBox(height: 24),
            
            ..._sarjIstasyonlari.map((istasyon) {
              bool isDolu = istasyon['soket'] == 'Dolu';
              Color durumRengi = isDolu ? Colors.redAccent : evGreen;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 10)]
                ),
                child: Row(
                  children: [
                    Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: durumRengi.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(istasyon['ikon'], color: durumRengi, size: 24)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(istasyon['isim'], style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                          const SizedBox(height: 4),
                          Text("${istasyon['tip']} • Mesafe: ${istasyon['mesafe']}", style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(isDolu ? Icons.do_disturb : Icons.check_circle, color: durumRengi, size: 16),
                        const SizedBox(height: 4),
                        Text(istasyon['soket'], style: TextStyle(color: durumRengi, fontSize: 10, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                      ],
                    )
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: textColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.white.withValues(alpha: 0.1))), elevation: 0),
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text("PANELİ KAPAT", style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: primaryTeal, size: 20), onPressed: () => Navigator.pop(context)),
          title: Text("EV BATARYA TERMİNALİ", style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2, fontFamily: 'Avenir')),
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
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 10)]),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: evGreen.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: Icon(Icons.electric_car, color: evGreen, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("YÜKSEK VOLTAJ (HV) AĞI", style: TextStyle(color: evGreen, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                          const SizedBox(height: 4),
                          const Text("Elektrikli araç bataryalarının SoH (State of Health) ölçümleri ve blok mühürlemesi buradan yapılır.", style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.4, fontFamily: 'Avenir')),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ŞARJ İSTASYONU RADARI (YENİ EKLENTİ)
              InkWell(
                onTap: _istasyonlariTara,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryTeal.withValues(alpha: 0.3)), boxShadow: [BoxShadow(color: primaryTeal.withValues(alpha: 0.05), blurRadius: 10)]),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: primaryTeal.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: Icon(Icons.ev_station, color: primaryTeal, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("ŞARJ İSTASYONU RADARI", style: TextStyle(color: primaryTeal, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                            const SizedBox(height: 4),
                            const Text("En yakın DC/AC istasyonlarını tara", style: TextStyle(color: Colors.white54, fontSize: 11, fontFamily: 'Avenir')),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, color: primaryTeal.withValues(alpha: 0.5), size: 16)
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // 2. RADAR VE TARAMA (BATARYA)
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 200, height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: evGreen.withValues(alpha: 0.5), width: 2),
                      boxShadow: [BoxShadow(color: evGreen.withValues(alpha: _taranmiyor ? 0.05 : 0.2 * _pulseController.value), blurRadius: 40, spreadRadius: 10)],
                    ),
                    child: Center(
                      child: _taranmiyor 
                          ? Icon(Icons.electrical_services, color: evGreen, size: 64)
                          : CircularProgressIndicator(color: evGreen, strokeWidth: 3),
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
                      backgroundColor: Colors.white,
                      foregroundColor: evGreen,
                      side: BorderSide(color: evGreen, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0
                    ),
                    onPressed: _taranmiyor ? _bataryayiTara : null,
                    icon: Icon(_taranmiyor ? Icons.radar : Icons.hourglass_top, size: 24),
                    label: Text(_taranmiyor ? "BATARYA HÜCRELERİNİ TARA" : "OBD2 VERİSİ OKUNUYOR...", style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                  ),
                ),

              // 4. SONUÇLAR VE MÜHÜR EKRANI
              if (_taramaBitti)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: evGreen.withValues(alpha: 0.3), width: 2), boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.05), blurRadius: 20)]),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle, color: evGreen, size: 48),
                      const SizedBox(height: 16),
                      const Text("BATARYA SAĞLIĞI (SoH)", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2, fontFamily: 'Avenir')),
                      const SizedBox(height: 8),
                      Text("%96.4", style: TextStyle(color: evGreen, fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -2, fontFamily: 'Avenir')),
                      const SizedBox(height: 24),
                      _buildHucreSatiri("Hücre Voltaj Dengesi", "KUSURSUZ (0.02V Fark)", evGreen, textColor),
                      const SizedBox(height: 12),
                      _buildHucreSatiri("Şarj Döngüsü (Cycle)", "142 Kez Dolduruldu", textColor, textColor),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity, height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: evGreen, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Batarya Plaza Ağına Mühürlendi!"), backgroundColor: primaryTeal));
                          },
                          icon: const Icon(Icons.vpn_key),
                          label: const Text("BATARYAYI MÜHÜRLE", style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
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

  Widget _buildHucreSatiri(String baslik, String deger, Color vurgu, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(baslik, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
        Text(deger, style: TextStyle(color: vurgu, fontSize: 12, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
      ],
    );
  }
}
