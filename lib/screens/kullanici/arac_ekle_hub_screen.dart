import 'package:otodna/core/siber_tema.dart';
import 'dart:ui';
import 'package:flutter/material.dart';

// 🚀 KARARGAH ZIRHLARI
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

// Kendi projenin rotalarına göre buraları aktif et
import 'arac_kayit_screen.dart';
import 'siber_goz_tarayici_screen.dart';
import 'siber_arac_devral_screen.dart';
import 'ev_batarya_muhur_terminali.dart'; // EV Terminali Eklendi

class AracEkleHubScreen extends StatelessWidget {
  AracEkleHubScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: SiberTema.oledBlack.withOpacity(0.8),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "KUANTUM MERKEZ",
            style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            // =================================================================
            // 2. ANA İÇERİK (HUD)
            // =================================================================
            SafeArea(
              child: Column(
                children: [

                Expanded(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // =================================================================
                        // GÜVENLİK BİLDİRİMİ (Mat Siyah Cam)
                        // =================================================================
                        _buildGlassCard(
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: SiberTema.kuantumCyan.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.2), blurRadius: 10)],
                                ),
                                child: Icon(Icons.gpp_good_outlined, color: SiberTema.kuantumCyan, size: 24),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Yetkili Terminal Bağlantısı Sağlandı", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, fontSize: 13)),
                                    SizedBox(height: 4),
                                    Text("Tüm işlemler 256-bit Kripto ile mühürlenir.", style: TextStyle(color: SiberTema.textMuted, fontSize: 11)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 32),

                        // =================================================================
                        // ARAÇ KAYIT VE MÜLKİYET BÖLÜMÜ
                        // =================================================================
                        _buildKategoriBaslik("KAYIT & DEVRALMA İŞLEMLERİ"),
                        SizedBox(height: 16),
                        _buildTeknolojiIslemKarti(
                          context: context,
                          baslik: "Sıfır Araç / Sicil Oluştur",
                          altBaslik: "Sisteme yeni bir aracın genetiğini işleyin.",
                          ikon: Icons.add_to_photos_outlined,
                          vurguRengi: SiberTema.kuantumCyan,
                          hedefEkran: AracKayitScreen(),
                        ),
                        SizedBox(height: 12),
                        _buildTeknolojiIslemKarti(
                          context: context,
                          baslik: "İkinci El Araç Devral",
                          altBaslik: "Eski sahibinden alınan Kuantum Kod ile aracı üzerinize alın.",
                          ikon: Icons.handshake_outlined,
                          vurguRengi: SiberTema.altinSari,
                          hedefEkran: SiberAracDevralScreen(),
                        ),

                        SizedBox(height: 32),

                        // =================================================================
                        // SİBER GÖZ BÖLÜMÜ
                        // =================================================================
                        _buildKategoriBaslik("KİMLİK DOĞRULAMA MOTORU"),
                        SizedBox(height: 16),
                        _buildTeknolojiIslemKarti(
                          context: context,
                          baslik: "Kuantum QR & Şase Tarayıcı",
                          altBaslik: "Aracın üzerindeki etiketi okutup genetiğini çözün.",
                          ikon: Icons.qr_code_scanner_outlined,
                          vurguRengi: Color(0xFF3B82F6), // Elektrik Mavisi
                          hedefEkran: SiberGozTarayiciScreen(),
                        ),

                        SizedBox(height: 32),

                        // =================================================================
                        // MÜHÜR TERMİNALLERİ (Izgara)
                        // =================================================================
                        _buildKategoriBaslik("RESMİ MÜHÜR TERMİNALLERİ"),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildKutuIslemKarti(
                                context: context,
                                baslik: "EV Batarya\nTerminali",
                                ikon: Icons.electrical_services_outlined,
                                vurguRengi: Colors.orangeAccent,
                                hedefEkran: EvBataryaMuhurTerminali(),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _buildKutuIslemKarti(
                                context: context,
                                baslik: "Ekspertiz\nMühür Merkezi",
                                ikon: Icons.verified_outlined,
                                vurguRengi: Colors.white24,
                                isRezerve: true,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 40),
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

  // -------------------------------------------------------------------------
  // 💎 GERÇEKÇİ CAM EFEKTİ (GLASSMORPHISM) MİNİMALİST
  // -------------------------------------------------------------------------
  Widget _buildGlassCard({required Widget child, double padding = 16}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: Color(0xFF111111), // Mat Gri
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildKategoriBaslik(String baslik) {
    return Row(
      children: [
        Container(
            width: 2, height: 14,
            decoration: BoxDecoration(color: SiberTema.kuantumCyan, boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.5), blurRadius: 6)])
        ),
        SizedBox(width: 8),
        Text(baslik, style: TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2)),
      ],
    );
  }

  Widget _buildTeknolojiIslemKarti({required BuildContext context, required String baslik, required String altBaslik, required IconData ikon, required Color vurguRengi, required Widget hedefEkran}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: vurguRengi.withOpacity(0.2),
        highlightColor: vurguRengi.withOpacity(0.1),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => hedefEkran)),
        child: _buildGlassCard(
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [vurguRengi.withOpacity(0.15), vurguRengi.withOpacity(0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: vurguRengi.withOpacity(0.3)),
                ),
                child: Icon(ikon, color: vurguRengi, size: 26),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(baslik, style: TextStyle(color: SiberTema.textMain, fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.5)),
                    SizedBox(height: 4),
                    Text(altBaslik, style: TextStyle(color: SiberTema.textMuted, fontSize: 11, height: 1.4)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.2), size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKutuIslemKarti({required BuildContext context, required String baslik, required IconData ikon, required Color vurguRengi, Widget? hedefEkran, bool isRezerve = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: isRezerve ? Colors.white12 : vurguRengi.withOpacity(0.2),
        onTap: () {
          if (!isRezerve && hedefEkran != null) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => hedefEkran));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Siber Ağa yakında entegre edilecektir.", style: TextStyle(color: SiberTema.textMain)), backgroundColor: Colors.black87));
          }
        },
        child: _buildGlassCard(
          padding: 24,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isRezerve ? Colors.transparent : vurguRengi.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: isRezerve ? Colors.white12 : vurguRengi.withOpacity(0.3)),
                  boxShadow: isRezerve ? [] : [BoxShadow(color: vurguRengi.withOpacity(0.2), blurRadius: 15)],
                ),
                child: Icon(ikon, color: isRezerve ? Colors.white24 : vurguRengi, size: 32),
              ),
              SizedBox(height: 16),
              Text(baslik, textAlign: TextAlign.center, style: TextStyle(color: isRezerve ? Colors.white38 : Colors.white, fontSize: 13, fontWeight: FontWeight.bold, height: 1.4, letterSpacing: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}