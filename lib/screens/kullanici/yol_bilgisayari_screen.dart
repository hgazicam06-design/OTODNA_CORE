import 'package:flutter/material.dart';

class YolBilgisayariScreen extends StatefulWidget {
  const YolBilgisayariScreen({super.key});

  @override
  State<YolBilgisayariScreen> createState() => _YolBilgisayariScreenState();
}

class _YolBilgisayariScreenState extends State<YolBilgisayariScreen> {
  // --- SİBER CÜZDAN & ARAÇ VERİLERİ ---
  double _hgsBakiye = 145.50;
  bool _isElektrikli = true;

  // EV (Elektrikli) Araç Verileri
  final double _fabrikaMenzili = 500.0;
  final double _bataryaSoh = 92.0;
  double _anlikSarjYuzdesi = 80.0;

  // İçten Yanmalı (Yakıtlı) Araç Verileri
  final TextEditingController _litreController = TextEditingController();
  final TextEditingController _kmController = TextEditingController();
  String _ortalamaTuketim = "--";

  // 💎 HGS Yükleme Simülasyonu
  void _hgsYukle() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.deepOrangeAccent.withOpacity(0.5))),
        contentPadding: const EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.deepOrangeAccent.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: Colors.deepOrangeAccent.withOpacity(0.5))), child: const Icon(Icons.toll_outlined, color: Colors.deepOrangeAccent, size: 48)),
            const SizedBox(height: 24),
            const Text("BAKİYE YÜKLEME", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
            const SizedBox(height: 12),
            const Text("Kayıtlı Kripto Cüzdanınızdan HGS hesabınıza 500 ₺ yüklenecektir. Onaylıyor musunuz?", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5)),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text("İPTAL", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrangeAccent, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: () { setState(() => _hgsBakiye += 500.0); Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('HGS Bakiyesi Ağa Mühürlendi! ✅', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: Colors.deepOrangeAccent)); }, child: const Text("ONAYLA", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1))))
              ],
            )
          ],
        ),
      ),
    );
  }

  void _yakitHesapla() {
    if (_litreController.text.isEmpty || _kmController.text.isEmpty) return;
    double litre = double.tryParse(_litreController.text) ?? 0;
    double km = double.tryParse(_kmController.text) ?? 0;

    if (litre > 0 && km > 0) {
      double tuketim = (litre / km) * 100;
      setState(() => _ortalamaTuketim = "${tuketim.toStringAsFixed(1)} L");
      FocusScope.of(context).unfocus();
    }
  }

  int _gercekMenzilHesapla() {
    double saglikliTamMenzil = _fabrikaMenzili * (_bataryaSoh / 100.0);
    return (saglikliTamMenzil * (_anlikSarjYuzdesi / 100.0)).toInt();
  }

  @override
  Widget build(BuildContext context) {
    // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
    const primaryCyan = Color(0xFF00FFC2);
    const bgColor = Color(0xFF000000);
    const surfaceColor = Color(0xFF111111);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
          backgroundColor: Colors.transparent, elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
          title: const Text('K O K P İ T   M E R K E Z İ', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 3)),
          centerTitle: true
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 🏷️ 1. HGS CÜZDANI (Premium Dijital Kart)
            // ==========================================
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.deepOrangeAccent.withOpacity(0.9), Colors.orangeAccent.withOpacity(0.6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [BoxShadow(color: Colors.deepOrangeAccent.withOpacity(0.2), blurRadius: 40, spreadRadius: 5)]
              ),
              child: Row(
                children: [
                  Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.sensors_outlined, color: Colors.white, size: 36)),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("HGS KUANTUM BAKİYE", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        const SizedBox(height: 8),
                        Text("₺ ${_hgsBakiye.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _hgsYukle,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.add, color: Colors.white, size: 24),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 48),

            // ==========================================
            // 2. ARAÇ TİPİ SEÇİCİ (Demo İçin)
            // ==========================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("SİBER MOTOR TİPİ", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    const SizedBox(height: 6),
                    Text(_isElektrikli ? "OtoDNA EV Modu Aktif" : "İçten Yanmalı Mod Aktif", style: TextStyle(color: _isElektrikli ? primaryCyan : Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                Switch(value: _isElektrikli, activeColor: primaryCyan, inactiveThumbColor: Colors.orangeAccent, inactiveTrackColor: Colors.orangeAccent.withOpacity(0.2), onChanged: (val) => setState(() => _isElektrikli = val)),
              ],
            ),
            const SizedBox(height: 24),

            // ==========================================
            // 🔋 3. ELEKTRİKLİ ARAÇ (EV) SİBER MENZİL MOTORU
            // ==========================================
            if (_isElektrikli) ...[
              Container(
                width: double.infinity, padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(32), border: Border.all(color: primaryCyan.withOpacity(0.3), width: 1.5), boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.05), blurRadius: 30)]),
                child: Column(
                  children: [
                    const Icon(Icons.electric_car_outlined, color: primaryCyan, size: 48),
                    const SizedBox(height: 16),
                    const Text("AI DESTEKLİ GERÇEK MENZİL", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    const SizedBox(height: 12),
                    Text("${_gercekMenzilHesapla()} KM", style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.w900, letterSpacing: -2)),
                    const SizedBox(height: 24),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildVeriSutunu("FABRİKA", "${_fabrikaMenzili.toInt()} KM", Colors.white),
                        _buildVeriSutunu("BATARYA (SOH)", "%${_bataryaSoh.toInt()}", Colors.greenAccent),
                        _buildVeriSutunu("ŞARJ DURUMU", "%${_anlikSarjYuzdesi.toInt()}", primaryCyan),
                      ],
                    ),
                    const SizedBox(height: 40),
                    const Text("ŞARJ SİMÜLASYONU", style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderThemeData(trackHeight: 2, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8), overlayShape: const RoundSliderOverlayShape(overlayRadius: 16), activeTrackColor: primaryCyan, inactiveTrackColor: Colors.white.withOpacity(0.1), thumbColor: primaryCyan),
                      child: Slider(value: _anlikSarjYuzdesi, min: 0, max: 100, onChanged: (val) => setState(() => _anlikSarjYuzdesi = val)),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                  width: double.infinity, height: 56,
                  child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(side: BorderSide(color: primaryCyan.withOpacity(0.5)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      onPressed: () {},
                      icon: const Icon(Icons.ev_station_outlined, color: primaryCyan, size: 20),
                      label: const Text("EN YAKIN ŞARJ İSTASYONU", style: TextStyle(color: primaryCyan, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1))
                  )
              ),
            ]

            // ==========================================
            // ⛽ 4. İÇTEN YANMALI (YAKITLI) ARAÇ TÜKETİM MOTORU
            // ==========================================
            else ...[
              Container(
                width: double.infinity, padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(32), border: Border.all(color: Colors.orangeAccent.withOpacity(0.3), width: 1.5), boxShadow: [BoxShadow(color: Colors.orangeAccent.withOpacity(0.05), blurRadius: 30)]),
                child: Column(
                  children: [
                    const Icon(Icons.local_gas_station_outlined, color: Colors.orangeAccent, size: 48),
                    const SizedBox(height: 16),
                    const Text("ORTALAMA TÜKETİM (100 KM)", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    const SizedBox(height: 12),
                    Text(_ortalamaTuketim, style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.w900, letterSpacing: -2)),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                            child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF000000), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
                                child: TextField(controller: _litreController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold), decoration: const InputDecoration(hintText: 'Litre', hintStyle: TextStyle(color: Colors.white24, fontWeight: FontWeight.normal), border: InputBorder.none))
                            )
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                            child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF000000), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
                                child: TextField(controller: _kmController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold), decoration: const InputDecoration(hintText: 'KM', hintStyle: TextStyle(color: Colors.white24, fontWeight: FontWeight.normal), border: InputBorder.none))
                            )
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                        width: double.infinity, height: 50,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, foregroundColor: Colors.black, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            onPressed: _yakitHesapla,
                            child: const Text("TÜKETİMİ HESAPLA", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1))
                        )
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                  width: double.infinity, height: 56,
                  child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.orangeAccent.withOpacity(0.5)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      onPressed: () {},
                      icon: const Icon(Icons.map_outlined, color: Colors.orangeAccent, size: 20),
                      label: const Text("EN UCUZ İSTASYONLAR", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1))
                  )
              ),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // 💎 YARDIMCI WIDGET: VERİ SÜTUNU
  Widget _buildVeriSutunu(String baslik, String deger, Color renk) {
    return Column(
        children: [
          Text(baslik, style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(deger, style: TextStyle(color: renk, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.5))
        ]
    );
  }
}