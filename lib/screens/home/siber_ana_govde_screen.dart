import 'package:flutter/material.dart';

// OLUŞTURDUĞUMUZ DEVASA MODÜLLERİ ÇAĞIRIYORUZ
import 'home_screen.dart';
import '../kullanici/ikinci_el_market_screen.dart';
import '../lojistik/otodna_cigir_screen.dart'; // YENİ ÇIĞIR MODÜLÜ
import '../kullanici/siber_garaj_screen.dart';
import '../kullanici/siber_cuzdan_screen.dart';
import '../kullanici/siber_goz_tarayici_screen.dart';

class SiberAnaGovdeScreen extends StatefulWidget {
  SiberAnaGovdeScreen({super.key});

  @override
  State<SiberAnaGovdeScreen> createState() => _SiberAnaGovdeScreenState();
}

class _SiberAnaGovdeScreenState extends State<SiberAnaGovdeScreen> {
  // HANGİ SAYFADAYIZ? (Varsayılan 0: Ana Karargah)
  int _aktifSekme = 0;

  // ALT NAVİGASYONDAN GEÇİŞ YAPILACAK SAYFALARIN LİSTESİ
  final List<Widget> _sayfalar = [
    HomeScreen(),               // 0. Sekme
    OtoDnaCigirScreen(),        // 1. Sekme (Taksi Çığır)
    SiberGarajScreen(),         // 2. Sekme (Ortadaki QR butonu için boşluk)
    SiberGarajScreen(),         // 3. Sekme
    SiberCuzdanScreen(),        // 4. Sekme
  ];

  void _sekmeDegistir(int index) {
    // Ortadaki butona (indeks 2) basılınca sayfa değişmez, QR kamera açılır!
    if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => SiberGozTarayiciScreen()));
      return;
    }
    setState(() {
      _aktifSekme = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0F172A);
    const primaryCyan = Color(0xFF00FFC2);
    const cardColor = Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: bgColor,
      // AKTİF OLAN SAYFAYI EKRANA BASIYORUZ
      body: IndexedStack(
        index: _aktifSekme,
        children: _sayfalar,
      ),

      // ORTADAKİ DEVASA SİBER GÖZ (QR TARAYICI) BUTONU
      floatingActionButton: Container(
        height: 64,
        width: 64,
        margin: EdgeInsets.only(top: 30),
        child: FloatingActionButton(
          backgroundColor: primaryCyan,
          elevation: 10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          child: Icon(Icons.qr_code_scanner, color: bgColor, size: 32),
          onPressed: () {
            // Siber Göz Tarayıcıyı Üstten Aç
            Navigator.push(context, MaterialPageRoute(builder: (context) => SiberGozTarayiciScreen()));
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ALT NAVİGASYON BARI (BOTTOM NAV BAR)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(color: primaryCyan.withOpacity(0.1), blurRadius: 20, spreadRadius: 5)
            ]
        ),
        child: BottomAppBar(
          color: cardColor,
          shape: CircularNotchedRectangle(), // Ortadaki butona kavisli yuva yapar
          notchMargin: 8.0, // Kavisin boşluğu
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // SOL TARAFTAKİ BUTONLAR
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNavButonu(ikon: Icons.grid_view, baslik: "Karargah", index: 0),
                    _buildNavButonu(ikon: Icons.local_taxi, baslik: "Taksi Çığır", index: 1),
                  ],
                ),
                // SAĞ TARAFTAKİ BUTONLAR
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNavButonu(ikon: Icons.garage, baslik: "Garajım", index: 3),
                    _buildNavButonu(ikon: Icons.account_balance_wallet, baslik: "Cüzdan", index: 4),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // YARDIMCI WİDGET: NAVİGASYON BUTONU
  Widget _buildNavButonu({required IconData ikon, required String baslik, required int index}) {
    bool isSelected = _aktifSekme == index;
    const primaryCyan = Color(0xFF00FFC2);

    return MaterialButton(
      minWidth: 40,
      onPressed: () => _sekmeDegistir(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            ikon,
            color: isSelected ? primaryCyan : Colors.white54,
            size: isSelected ? 28 : 24,
          ),
          SizedBox(height: 2),
          Text(
            baslik,
            style: TextStyle(
              color: isSelected ? primaryCyan : Colors.white54,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          )
        ],
      ),
    );
  }
}