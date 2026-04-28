import 'package:otodna/core/siber_tema.dart';
import 'package:flutter/material.dart';

import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

// SİBER EKRANLAR (Bunları daha önce yazdık)
// Kırmızı çizerse yollarını kendi projendeki klasörlere göre düzelt!
// import '../screens/bayi/firma_paneli_screen.dart';
// import '../screens/bayi/gercek_arac_kayit_terminali.dart';
// import '../screens/bayi/urun_katalog_screen.dart';
// import '../screens/bayi/kargo_qr_kilit_screen.dart';

class WebMainLayout extends StatefulWidget {
  // Varsayılan olarak gösterilecek ekran (Örn: Firma Paneli)
  final Widget initialChild;
  WebMainLayout({super.key, required this.initialChild});

  @override
  State<WebMainLayout> createState() => _WebMainLayoutState();
}

class _WebMainLayoutState extends State<WebMainLayout> {
  final Color bgColor = SiberTema.oledBlack;
  final Color sidebarColor = SiberTema.matGrey;
  final Color primaryCyan = SiberTema.kuantumCyan;

  late Widget _currentChild;
  int _selectedIndex = 0; // Hangi menünün aktif olduğunu takip eder

  @override
  void initState() {
    super.initState();
    _currentChild = widget.initialChild;
  }

  // 🚀 MENÜ YÖNLENDİRME MOTORU
  void _changeScreen(Widget screen, int index) {
    setState(() {
      _currentChild = screen;
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Row(
        children: [
          // ==============================================================
          // SOL SABİT MENÜ (FÜTÜRİSTİK SİDEBAR)
          // ==============================================================
          Container(
            width: 260,
            decoration: BoxDecoration(
              color: sidebarColor,
              border: Border(right: BorderSide(color: SiberTema.textMuted, width: 1)),
              boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.05), blurRadius: 20)],
            ),
            child: Column(
              children: [
                // 1. LOGO ALANI
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: bgColor,
                    border: Border(bottom: BorderSide(color: primaryCyan.withOpacity(0.3))),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.radar, color: primaryCyan, size: 40),
                      SizedBox(height: 8),
                      Text(
                        "OtoDNA WEB",
                        style: TextStyle(color: SiberTema.textMain, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2),
                      ),
                      Text("KARARGAH TERMİNALİ", style: TextStyle(color: primaryCyan, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // 2. MENÜ ELEMANLARI
                _buildMenuItem(Icons.dashboard, "Ana Karargah", 0, () {
                  // TODO: _changeScreen(FirmaPaneliScreen(), 0);
                  print("Firma Paneline Geç");
                }),
                _buildMenuItem(Icons.precision_manufacturing, "Araç Kabul & Ekspertiz", 1, () {
                  // TODO: _changeScreen(GercekAracKayitTerminali(), 1);
                  print("Ekspertiz Ekranına Geç");
                }),
                _buildMenuItem(Icons.inventory_2, "Siber Katalog (Yedek Parça)", 2, () {
                  // TODO: _changeScreen(UrunKatalogScreen(), 2);
                  print("Katalog Ekranına Geç");
                }),
                _buildMenuItem(Icons.local_shipping, "Kargo & Güvenli Havuz", 3, () {
                  // TODO: _changeScreen(KargoQrKilitScreen(), 3);
                  print("Kargo Ekranına Geç");
                }),
                _buildMenuItem(Icons.account_balance_wallet, "Finans & B2B Uzlaşma", 4, () {
                  print("Finans Ekranına Geç");
                }),

                Spacer(), // Ayarları en alta iter

                // 3. AYARLAR VE ÇIKIŞ
                Divider(color: SiberTema.textMuted),
                _buildMenuItem(Icons.settings, "Sistem Ayarları", 5, () {}),
                _buildMenuItem(Icons.logout, "Güvenli Çıkış", 6, () {}, isLogout: true),
                SizedBox(height: 20),
              ],
            ),
          ),

          // ==============================================================
          // SAĞ ANA İÇERİK ALANI (Ekranda Gösterilen Sayfa)
          // ==============================================================
          Expanded(
            child: Container(
              color: bgColor,
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _currentChild, // Tıklanan ekran buraya gelir!
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  // Yardımcı Widget: Siber Menü Butonu
  Widget _buildMenuItem(IconData icon, String title, int index, VoidCallback onTap, {bool isLogout = false}) {
    bool isSelected = _selectedIndex == index;
    Color itemColor = isLogout ? Colors.redAccent : (isSelected ? primaryCyan : Colors.white70);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onTap();
          if (!isLogout) {
            setState(() => _selectedIndex = index);
          }
        },
        hoverColor: primaryCyan.withOpacity(0.1),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            border: Border(
                left: BorderSide(
                    color: isSelected ? primaryCyan : Colors.transparent,
                    width: 4
                )
            ),
            color: isSelected ? primaryCyan.withOpacity(0.05) : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(icon, color: itemColor, size: 22),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : itemColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}