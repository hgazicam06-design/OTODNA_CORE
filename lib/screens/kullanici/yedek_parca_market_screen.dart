import 'package:otodna/core/siber_tema.dart';
import 'package:flutter/material.dart';

// İleride satın al tuşuna basıldığında yine Iyzico'yu çağıracağız
// import 'siber_odeme_screen.dart';

class YedekParcaMarketScreen extends StatefulWidget {
  YedekParcaMarketScreen({super.key});

  @override
  State<YedekParcaMarketScreen> createState() => _YedekParcaMarketScreenState();
}

class _YedekParcaMarketScreenState extends State<YedekParcaMarketScreen> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  final Color bgColor = Color(0xFF000000);
  final Color surfaceColor = Color(0xFF111111);
  final Color primaryCyan = Color(0xFF00FFC2);

  String _seciliKategori = "Tümü";

  // 1. PROFESYONEL KATEGORİLER
  final List<String> _kategoriler = [
    "Tümü",
    "Fren & Süspansiyon",
    "Filtre & Bakım",
    "Silecek & Dış Aksam",
    "Elektrik & Aydınlatma",
    "Motor & Mekanik"
  ];

  // 2. FİREBASE SİMÜLASYONU (YEDEK PARÇALAR)
  final List<Map<String, dynamic>> _yedekParcalar = [
    {
      "ad": "Bosch Seramik Fren Balatası",
      "kategori": "Fren & Süspansiyon",
      "marka": "Bosch",
      "uyumluluk": "VW Golf, Seat Leon, Audi A3",
      "fiyat": 1250.0,
      "stok": true,
      "gorsel_ikon": Icons.stop_circle_outlined,
    },
    {
      "ad": "Mann Karbonlu Polen Filtresi",
      "kategori": "Filtre & Bakım",
      "marka": "Mann-Filter",
      "uyumluluk": "Tüm VAG Grubu (2013+)",
      "fiyat": 450.0,
      "stok": true,
      "gorsel_ikon": Icons.air_outlined,
    },
    {
      "ad": "Osram Night Breaker LED H7",
      "kategori": "Elektrik & Aydınlatma",
      "marka": "Osram",
      "uyumluluk": "H7 Soketli Tüm Araçlar",
      "fiyat": 2100.0,
      "stok": false, // Stokta yok simülasyonu
      "gorsel_ikon": Icons.lightbulb_outline,
    },
    {
      "ad": "Bosch Aerotwin Silecek Takımı",
      "kategori": "Silecek & Dış Aksam",
      "marka": "Bosch",
      "uyumluluk": "Ford Focus (2015-2022)",
      "fiyat": 680.0,
      "stok": true,
      "gorsel_ikon": Icons.water_drop_outlined,
    },
    {
      "ad": "Castrol Edge 5W-30 Tam Sentetik",
      "kategori": "Filtre & Bakım",
      "marka": "Castrol",
      "uyumluluk": "Dizel/Benzin Uyumlu (4L)",
      "fiyat": 1150.0,
      "stok": true,
      "gorsel_ikon": Icons.oil_barrel_outlined,
    },
    {
      "ad": "Sachs Amortisör Takımı (Ön)",
      "kategori": "Fren & Süspansiyon",
      "marka": "Sachs",
      "uyumluluk": "BMW 3 Serisi (F30)",
      "fiyat": 4500.0,
      "stok": true,
      "gorsel_ikon": Icons.compress_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // SEÇİLİ KATEGORİYE GÖRE FİLTRELEME
    List<Map<String, dynamic>> filtrelenmisParcalar = _seciliKategori == "Tümü"
        ? _yedekParcalar
        : _yedekParcalar.where((p) => p['kategori'] == _seciliKategori).toList();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text("Y E D E K   P A R Ç A   A Ğ I", style: TextStyle(color: SiberTema.textMuted, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 3)),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.shopping_cart_outlined, color: primaryCyan), onPressed: () {}),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 💎 1. ARAMA ÇUBUĞU (Minimalist)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
              child: TextField(
                style: TextStyle(color: SiberTema.textMain, fontSize: 14),
                decoration: InputDecoration(
                    icon: Icon(Icons.search, color: SiberTema.textMuted, size: 20),
                    hintText: "Siber Ağda OEM Kodu veya Parça Ara...",
                    hintStyle: TextStyle(color: SiberTema.textMain.withOpacity(0.2), fontSize: 13),
                    border: InputBorder.none
                ),
              ),
            ),
          ),

          // 💎 2. YATAY KATEGORİ FİLTRELERİ (Glow Çipler)
          Container(
            height: 64,
            margin: EdgeInsets.only(top: 8, bottom: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20),
              itemCount: _kategoriler.length,
              itemBuilder: (context, index) {
                String kategori = _kategoriler[index];
                bool isSelected = _seciliKategori == kategori;
                return GestureDetector(
                  onTap: () => setState(() => _seciliKategori = kategori),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: isSelected ? primaryCyan.withOpacity(0.1) : surfaceColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? primaryCyan.withOpacity(0.5) : Colors.white.withOpacity(0.05))
                    ),
                    child: Text(
                      kategori.toUpperCase(),
                      style: TextStyle(
                          color: isSelected ? primaryCyan : Colors.white54,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          letterSpacing: 1
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 💎 3. E-TİCARET GRID (SİBER KARTLAR)
          Expanded(
            child: filtrelenmisParcalar.isEmpty
                ? Center(child: Text("Siber ağda bu kategoride veri bulunamadı.", style: TextStyle(color: SiberTema.textMuted, fontSize: 12, fontWeight: FontWeight.bold)))
                : GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              physics: BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.60, // Kartları biraz daha uzattık, ferahlasın diye
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: filtrelenmisParcalar.length,
              itemBuilder: (context, index) {
                var parca = filtrelenmisParcalar[index];
                bool stoktaVar = parca['stok'];

                return Container(
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ÜST KISIM (GÖRSEL ALANI)
                      Expanded(
                        flex: 4,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Color(0xFF000000),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(24))
                          ),
                          child: Stack(
                            children: [
                              Center(child: Icon(parca['gorsel_ikon'], size: 56, color: SiberTema.textMuted)),
                              // Marka Etiketi
                              Positioned(
                                top: 12, left: 12,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white.withOpacity(0.1))),
                                  child: Text(parca['marka'].toUpperCase(), style: TextStyle(color: SiberTema.textMuted, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),

                      // ALT KISIM (BİLGİ VE FİYAT)
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(parca['ad'], maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: SiberTema.textMain, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: -0.5, height: 1.4)),
                                  SizedBox(height: 8),
                                  Text(parca['uyumluluk'], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                                ],
                              ),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("₺${parca['fiyat'].toStringAsFixed(2)}", style: TextStyle(color: SiberTema.textMain, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -1)),
                                  SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 40,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: stoktaVar ? primaryCyan : Color(0xFF000000),
                                          foregroundColor: stoktaVar ? Colors.black : Colors.white38,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: stoktaVar ? BorderSide.none : BorderSide(color: Colors.white.withOpacity(0.1))),
                                          elevation: 0,
                                          padding: EdgeInsets.zero
                                      ),
                                      onPressed: stoktaVar ? () {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${parca['ad']} ağ sepetine mühürlendi!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: primaryCyan));
                                      } : null,
                                      child: Text(stoktaVar ? "AĞA EKLE" : "STOKTA YOK", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}