import 'package:otodna/core/siber_tema.dart';
import 'package:flutter/material.dart';

class YolBilgisayariScreen extends StatefulWidget {
  YolBilgisayariScreen({super.key});

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
        backgroundColor: Color(0xFF111111),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.deepOrangeAccent.withOpacity(0.5))),
        contentPadding: EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(padding: EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.deepOrangeAccent.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: Colors.deepOrangeAccent.withOpacity(0.5))), child: Icon(Icons.toll_outlined, color: Colors.deepOrangeAccent, size: 48)),
            SizedBox(height: 24),
            Text("BAKİYE YÜKLEME", style: TextStyle(color: SiberTema.textMain, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
            SizedBox(height: 12),
            Text("Kayıtlı Kripto Cüzdanınızdan HGS hesabınıza 500 ₺ yüklenecektir. Onaylıyor musunuz?", textAlign: TextAlign.center, style: TextStyle(color: SiberTema.textMuted, fontSize: 12, height: 1.5)),
            SizedBox(height: 32),
            Row(
              children: [
                Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: Text("İPTAL", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)))),
                SizedBox(width: 12),
                Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrangeAccent, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: () { setState(() => _hgsBakiye += 500.0); Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('HGS Bakiyesi Ağa Mühürlendi! ✅', style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold)), backgroundColor: Colors.deepOrangeAccent)); }, child: Text("ONAYLA", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1))))
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
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20), onPressed: () => Navigator.pop(context)),
          title: Text('K O K P İ T   M E R K E Z İ', style: TextStyle(color: SiberTema.textMuted, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 3)),
          centerTitle: true
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 🏷️ 1. HGS CÜZDANI (Premium Dijital Kart)
            // ==========================================
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.deepOrangeAccent.withOpacity(0.9), Colors.orangeAccent.withOpacity(0.6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [BoxShadow(color: Colors.deepOrangeAccent.withOpacity(0.2), blurRadius: 40, spreadRadius: 5)]
              ),
              child: Row(
                children: [
                  Container(padding: EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: Icon(Icons.sensors_outlined, color: SiberTema.kuantumCyan, size: 36)),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("HGS KUANTUM BAKİYE", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        SizedBox(height: 8),
                        Text("₺ ${_hgsBakiye.toStringAsFixed(2)}", style: TextStyle(color: SiberTema.textMain, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _hgsYukle,
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                      child: Icon(Icons.add, color: SiberTema.kuantumCyan, size: 24),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 48),

            // ==========================================
            // 2. ARAÇ TİPİ SEÇİCİ (Demo İçin)
            // ==========================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("SİBER MOTOR TİPİ", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    SizedBox(height: 6),
                    Text(_isElektrikli ? "OtoDNA EV Modu Aktif" : "İçten Yanmalı Mod Aktif", style: TextStyle(color: _isElektrikli ? primaryCyan : Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                Switch(value: _isElektrikli, activeColor: primaryCyan, inactiveThumbColor: Colors.orangeAccent, inactiveTrackColor: Colors.orangeAccent.withOpacity(0.2), onChanged: (val) => setState(() => _isElektrikli = val)),
              ],
            ),
            SizedBox(height: 24),

            // ==========================================
            // 🔋 3. ELEKTRİKLİ ARAÇ (EV) SİBER MENZİL MOTORU
            // ==========================================
            if (_isElektrikli) ...[
              Container(
                width: double.infinity, padding: EdgeInsets.all(32),
                decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(32), border: Border.all(color: primaryCyan.withOpacity(0.3), width: 1.5), boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.05), blurRadius: 30)]),
                child: Column(
                  children: [
                    Icon(Icons.electric_car_outlined, color: primaryCyan, size: 48),
                    SizedBox(height: 16),
                    Text("AI DESTEKLİ GERÇEK MENZİL", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    SizedBox(height: 12),
                    Text("${_gercekMenzilHesapla()} KM", style: TextStyle(color: SiberTema.textMain, fontSize: 56, fontWeight: FontWeight.w900, letterSpacing: -2)),
                    SizedBox(height: 24),
                    Divider(color: SiberTema.textMuted),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildVeriSutunu("FABRİKA", "${_fabrikaMenzili.toInt()} KM", Colors.white),
                        _buildVeriSutunu("BATARYA (SOH)", "%${_bataryaSoh.toInt()}", Colors.greenAccent),
                        _buildVeriSutunu("ŞARJ DURUMU", "%${_anlikSarjYuzdesi.toInt()}", primaryCyan),
                      ],
                    ),
                    SizedBox(height: 40),
                    Text("ŞARJ SİMÜLASYONU", style: TextStyle(color: SiberTema.textMuted, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    SizedBox(height: 8),
                    SliderTheme(
                      data: SliderThemeData(trackHeight: 2, thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8), overlayShape: RoundSliderOverlayShape(overlayRadius: 16), activeTrackColor: primaryCyan, inactiveTrackColor: Colors.white.withOpacity(0.1), thumbColor: primaryCyan),
                      child: Slider(value: _anlikSarjYuzdesi, min: 0, max: 100, onChanged: (val) => setState(() => _anlikSarjYuzdesi = val)),
                    )
                  ],
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                  width: double.infinity, height: 56,
                  child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(side: BorderSide(color: primaryCyan.withOpacity(0.5)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      onPressed: () {},
                      icon: Icon(Icons.ev_station_outlined, color: primaryCyan, size: 20),
                      label: Text("EN YAKIN ŞARJ İSTASYONU", style: TextStyle(color: primaryCyan, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1))
                  )
              ),
            ]

            // ==========================================
            // ⛽ 4. İÇTEN YANMALI (YAKITLI) ARAÇ TÜKETİM MOTORU
            // ==========================================
            else ...[
              Container(
                width: double.infinity, padding: EdgeInsets.all(32),
                decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(32), border: Border.all(color: Colors.orangeAccent.withOpacity(0.3), width: 1.5), boxShadow: [BoxShadow(color: Colors.orangeAccent.withOpacity(0.05), blurRadius: 30)]),
                child: Column(
                  children: [
                    Icon(Icons.local_gas_station_outlined, color: Colors.orangeAccent, size: 48),
                    SizedBox(height: 16),
                    Text("ORTALAMA TÜKETİM (100 KM)", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    SizedBox(height: 12),
                    Text(_ortalamaTuketim, style: TextStyle(color: SiberTema.textMain, fontSize: 56, fontWeight: FontWeight.w900, letterSpacing: -2)),
                    SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                            child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4), decoration: BoxDecoration(color: Color(0xFF000000), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
                                child: TextField(controller: _litreController, keyboardType: TextInputType.number, style: TextStyle(color: SiberTema.textMain, fontSize: 14, fontWeight: FontWeight.bold), decoration: InputDecoration(hintText: 'Litre', hintStyle: TextStyle(color: SiberTema.textMuted, fontWeight: FontWeight.normal), border: InputBorder.none))
                            )
                        ),
                        SizedBox(width: 16),
                        Expanded(
                            child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4), decoration: BoxDecoration(color: Color(0xFF000000), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
                                child: TextField(controller: _kmController, keyboardType: TextInputType.number, style: TextStyle(color: SiberTema.textMain, fontSize: 14, fontWeight: FontWeight.bold), decoration: InputDecoration(hintText: 'KM', hintStyle: TextStyle(color: SiberTema.textMuted, fontWeight: FontWeight.normal), border: InputBorder.none))
                            )
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                        width: double.infinity, height: 50,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            onPressed: _yakitHesapla,
                            child: Text("TÜKETİMİ HESAPLA", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1))
                        )
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                  width: double.infinity, height: 56,
                  child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.orangeAccent.withOpacity(0.5)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      onPressed: () {},
                      icon: Icon(Icons.map_outlined, color: Colors.orangeAccent, size: 20),
                      label: Text("EN UCUZ İSTASYONLAR", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1))
                  )
              ),
            ],
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // 💎 YARDIMCI WIDGET: VERİ SÜTUNU
  Widget _buildVeriSutunu(String baslik, String deger, Color renk) {
    return Column(
        children: [
          Text(baslik, style: TextStyle(color: SiberTema.textMuted, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
          SizedBox(height: 8),
          Text(deger, style: TextStyle(color: renk, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.5))
        ]
    );
  }
}