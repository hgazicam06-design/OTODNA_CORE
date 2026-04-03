import 'package:flutter/material.dart';

// Bir sonraki adıma (Ekspertiz veya Fotoğraf yükleme) geçmek için kendi rotanı buraya ekle
// import 'ilan_ver_ekspertiz_screen.dart';

class IlanVerAracSecimScreen extends StatefulWidget {
  const IlanVerAracSecimScreen({super.key});

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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen Marka ve Model seçiniz.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent));
      return;
    }
    // Navigator.push(context, MaterialPageRoute(builder: (context) => const IlanVerEkspertizScreen()));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Araç Genetiği Onaylandı. Adım 2\'ye Geçiliyor...', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Color(0xFF00FFC2)));
  }

  @override
  Widget build(BuildContext context) {
    // 🌑 TESLA / APPLE ULTRA-MİNİMALİST PALET
    const bgColor = Color(0xFF000000); // Saf OLED Siyahı
    const surfaceColor = Color(0xFF111111); // Çok Koyu Gri
    const accentColor = Colors.white;
    const primaryCyan = Color(0xFF00FFC2);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: accentColor, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('A D I M   1 / 3', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 4)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Araç Seçimi", style: TextStyle(color: accentColor, fontSize: 32, fontWeight: FontWeight.w600, letterSpacing: -1)),
                  const SizedBox(height: 8),
                  const Text("Sisteme kaydedilecek aracın temel genetik bilgilerini seçin.", style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5)),
                  const SizedBox(height: 40),

                  // =========================================================
                  // MİNİMALİST DROPDOWN SEÇİCİLER
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
                  ),
                  const SizedBox(height: 16),

                  _buildPremiumDropdown(
                    baslik: "Model",
                    deger: _secilenModel,
                    liste: _secilenMarka != null ? _modeller[_secilenMarka!]! : [],
                    onChanged: (val) {
                      setState(() { _secilenModel = val; _fiyatGuncelle(); });
                    },
                    ikon: Icons.directions_car_outlined,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildPremiumDropdown(
                          baslik: "Üretim Yılı",
                          deger: _secilenYil,
                          liste: _yillar,
                          onChanged: (val) { setState(() { _secilenYil = val; _fiyatGuncelle(); }); },
                          ikon: Icons.calendar_today_outlined,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
                          child: TextField(
                            controller: _kullanimKmController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white, fontSize: 15),
                            decoration: const InputDecoration(
                              icon: Icon(Icons.speed_outlined, color: Colors.white54, size: 20),
                              labelText: "Kilometre",
                              labelStyle: TextStyle(color: Colors.white38, fontSize: 13),
                              border: InputBorder.none,
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // =========================================================
                  // OTODNA SENKRONİZASYON (TOGGLE)
                  // =========================================================
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _otodnaSenkronizasyon ? primaryCyan.withOpacity(0.5) : Colors.transparent)
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: _otodnaSenkronizasyon ? primaryCyan.withOpacity(0.1) : Colors.white.withOpacity(0.05), shape: BoxShape.circle),
                          child: Icon(Icons.security, color: _otodnaSenkronizasyon ? primaryCyan : Colors.white54, size: 24),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("OtoDNA Ağ Senkronizasyonu", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text("Aracınızı Kuantum Ağına mühürleyerek güven değerini artırın.", style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.4)),
                            ],
                          ),
                        ),
                        Switch(
                          value: _otodnaSenkronizasyon,
                          activeColor: primaryCyan,
                          activeTrackColor: primaryCyan.withOpacity(0.3),
                          inactiveThumbColor: Colors.white54,
                          inactiveTrackColor: Colors.white12,
                          onChanged: (val) {
                            setState(() { _otodnaSenkronizasyon = val; _fiyatGuncelle(); });
                          },
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // =========================================================
                  // DİNAMİK FİYAT HESAPLAYICI (Siber Kasa)
                  // =========================================================
                  const Text("Sistem Tarafından Önerilen Değer", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Text(
                      "₺${_hesaplananFiyat.toStringAsFixed(0)}",
                      style: const TextStyle(color: primaryCyan, fontSize: 40, fontWeight: FontWeight.w600, letterSpacing: -1)
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // =========================================================
          // SABİT ALT BUTON ALANI
          // =========================================================
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: bgColor,
              border: Border(top: BorderSide(color: Colors.white12)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryCyan,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _sonrakiAdim,
                child: const Text("SONRAKİ ADIM", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5)),
              ),
            ),
          )
        ],
      ),
    );
  }

  // 💎 TESLA MİMARİSİ: ŞIK VE SADE AÇILIR MENÜ (DROPDOWN)
  Widget _buildPremiumDropdown({required String baslik, required String? deger, required List<String> liste, required Function(String?) onChanged, required IconData ikon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(ikon, color: Colors.white54, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                dropdownColor: const Color(0xFF111111),
                isExpanded: true,
                value: deger,
                hint: Text(baslik, style: const TextStyle(color: Colors.white38, fontSize: 15)),
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white24),
                style: const TextStyle(color: Colors.white, fontSize: 15),
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