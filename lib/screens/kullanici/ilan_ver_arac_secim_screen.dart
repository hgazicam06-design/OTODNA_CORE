import 'package:otodna/core/siber_tema.dart';
import 'package:flutter/material.dart';
import '../../core/responsive_kalkan.dart';

// Bir sonraki adıma (Ekspertiz veya Fotoğraf yükleme) geçmek için kendi rotanı buraya ekle
// import 'ilan_ver_ekspertiz_screen.dart';

class IlanVerAracSecimScreen extends StatefulWidget {
  IlanVerAracSecimScreen({super.key});

  @override
  State<IlanVerAracSecimScreen> createState() => _IlanVerAracSecimScreenState();
}

class _IlanVerAracSecimScreenState extends State<IlanVerAracSecimScreen> {
  // Senin kodlarındaki değişkenleri korudum
  bool _otodnaSenkronizasyon = false;
  double _bazFiyat = 1500000;
  double _hesaplananFiyat = 1500000;
  final TextEditingController _kullanimKmController = TextEditingController();

  String? _secilenMarka;
  String? _secilenModel;
  String? _secilenYil;

  // Örnek Veri Seti (Bunu ileride Firebase'den çekebilirsin)
  final List<String> _markalar = ['Tesla', 'Mercedes-Benz', 'BMW', 'Audi', 'Volvo'];
  final Map<String, List<String>> _modeller = {
    'Tesla': ['Model S', 'Model 3', 'Model X', 'Model Y'],
    'Mercedes-Benz': ['C-Class', 'E-Class', 'G-Class', 'EQE'],
    'BMW': ['3 Series', '5 Series', 'i4', 'X5'],
    'Audi': ['A4', 'A6', 'e-tron', 'Q7'],
    'Volvo': ['XC90', 'XC60', 'S90'],
  };
  final List<String> _yillar = ['2024', '2023', '2022', '2021', '2020'];

  void _fiyatGuncelle() {
    // Örnek bir fiyat algoritması
    setState(() {
      _hesaplananFiyat = _bazFiyat;
      if (_secilenYil == '2024') _hesaplananFiyat += 200000;
      if (_otodnaSenkronizasyon) _hesaplananFiyat += 50000; // OtoDNA Güvence Bedeli
    });
  }

  void _sonrakiAdim() {
    if (_secilenMarka == null || _secilenModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lütfen Marka ve Model seçiniz.', style: TextStyle(color: SiberTema.textMain, fontFamily: 'Avenir')), backgroundColor: Colors.redAccent));
      return;
    }
    // Navigator.push(context, MaterialPageRoute(builder: (context) => IlanVerEkspertizScreen()));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Araç Genetiği Onaylandı. Adım 2\'ye Geçiliyor...', style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, fontFamily: 'Avenir')), backgroundColor: Colors.teal.shade700));
  }

  @override
  Widget build(BuildContext context) {
    // 🏢 PLAZA KALİTESİ PALET
    final Color primaryTeal = Colors.teal.shade700;
    Color bgColor = Color(0xFFFAFAFC);
    Color textColor = Color(0xFF1E293B);

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
          title: Text('A D I M   1 / 3', style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 4, fontFamily: 'Avenir')),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Araç Seçimi", style: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1, fontFamily: 'Avenir')),
                    SizedBox(height: 8),
                    Text("Sisteme kaydedilecek aracın temel genetik bilgilerini seçin.", style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                    SizedBox(height: 40),

                    // =========================================================
                    // PLAZA DROPDOWN SEÇİCİLER
                    // =========================================================
                    _buildPremiumDropdown(
                      baslik: "Marka",
                      deger: _secilenMarka,
                      liste: _markalar,
                      onChanged: (val) {
                        setState(() {
                          _secilenMarka = val;
                          _secilenModel = null; // Marka değişince modeli sıfırla
                          _fiyatGuncelle();
                        });
                      },
                      ikon: Icons.branding_watermark_outlined,
                      primaryTeal: primaryTeal,
                      textColor: textColor,
                    ),
                    SizedBox(height: 16),

                    _buildPremiumDropdown(
                      baslik: "Model",
                      deger: _secilenModel,
                      liste: _secilenMarka != null ? _modeller[_secilenMarka!]! : [],
                      onChanged: (val) {
                        setState(() { _secilenModel = val; _fiyatGuncelle(); });
                      },
                      ikon: Icons.directions_car_outlined,
                      primaryTeal: primaryTeal,
                      textColor: textColor,
                    ),
                    SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildPremiumDropdown(
                            baslik: "Üretim Yılı",
                            deger: _secilenYil,
                            liste: _yillar,
                            onChanged: (val) { setState(() { _secilenYil = val; _fiyatGuncelle(); }); },
                            ikon: Icons.calendar_today_outlined,
                            primaryTeal: primaryTeal,
                            textColor: textColor,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 5)]),
                            child: TextField(
                              controller: _kullanimKmController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
                              decoration: InputDecoration(
                                icon: Icon(Icons.speed_outlined, color: primaryTeal, size: 20),
                                labelText: "Kilometre",
                                labelStyle: TextStyle(color: Colors.white54, fontSize: 13, fontFamily: 'Avenir', fontWeight: FontWeight.bold),
                                border: InputBorder.none,
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),

                    // =========================================================
                    // OTODNA SENKRONİZASYON (TOGGLE)
                    // =========================================================
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _otodnaSenkronizasyon ? primaryTeal.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.05), width: _otodnaSenkronizasyon ? 2 : 1),
                          boxShadow: [
                            if (_otodnaSenkronizasyon)
                              BoxShadow(color: primaryTeal.withValues(alpha: 0.1), blurRadius: 15, offset: Offset(0, 5))
                            else
                              BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 10, offset: Offset(0, 5))
                          ]
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(color: _otodnaSenkronizasyon ? primaryTeal.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05), shape: BoxShape.circle),
                            child: Icon(Icons.security, color: _otodnaSenkronizasyon ? primaryTeal : Colors.black38, size: 24),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("OtoDNA Ağ Senkronizasyonu", style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                                SizedBox(height: 4),
                                Text("Aracınızı Kuantum Ağına mühürleyerek güven değerini artırın.", style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.4, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                              ],
                            ),
                          ),
                          Switch(
                            value: _otodnaSenkronizasyon,
                            activeColor: Colors.white,
                            activeTrackColor: primaryTeal,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: Colors.black26,
                            onChanged: (val) {
                              setState(() { _otodnaSenkronizasyon = val; _fiyatGuncelle(); });
                            },
                          )
                        ],
                      ),
                    ),

                    SizedBox(height: 40),

                    // =========================================================
                    // DİNAMİK FİYAT HESAPLAYICI
                    // =========================================================
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: primaryTeal.withValues(alpha: 0.3)),
                        boxShadow: [BoxShadow(color: primaryTeal.withValues(alpha: 0.05), blurRadius: 20, offset: Offset(0, 10))]
                      ),
                      child: Column(
                        children: [
                          Text("Sistem Tarafından Önerilen Değer", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
                          SizedBox(height: 8),
                          Text(
                              "₺${_hesaplananFiyat.toStringAsFixed(0)}",
                              style: TextStyle(color: primaryTeal, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -1, fontFamily: 'Avenir')
                          ),
                        ]
                      )
                    ),

                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // =========================================================
            // SABİT ALT BUTON ALANI
            // =========================================================
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
                boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 10, offset: Offset(0, -5))]
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryTeal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _sonrakiAdim,
                    child: Text("SONRAKİ ADIM", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5, fontFamily: 'Avenir')),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // 💎 PLAZA MİMARİSİ: ŞIK VE SADE AÇILIR MENÜ (DROPDOWN)
  Widget _buildPremiumDropdown({required String baslik, required String? deger, required List<String> liste, required Function(String?) onChanged, required IconData ikon, required Color primaryTeal, required Color textColor}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 5)]
      ),
      child: Row(
        children: [
          Icon(ikon, color: primaryTeal, size: 20),
          SizedBox(width: 16),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                dropdownColor: Colors.white,
                isExpanded: true,
                value: deger,
                hint: Text(baslik, style: TextStyle(color: Colors.white54, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                icon: Icon(Icons.keyboard_arrow_down, color: primaryTeal),
                style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
                items: liste.map((String item) {
                  return DropdownMenuItem<String>(value: item, child: Text(item));
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}