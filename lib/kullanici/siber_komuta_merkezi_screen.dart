// lib/kullanici/siber_komuta_merkezi_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🚀 YÖNLENDİRME KABLOLARI
import '../core/responsive_kalkan.dart';
import '../screens/siber_sos_merkezi.dart';
import '../screens/siber_market_vitrini.dart';
import '../screens/arac_kayit_screen.dart';
import '../qr_merkezi/siber_goz_radari.dart';

class SiberKomutaMerkeziScreen extends StatefulWidget {
  const SiberKomutaMerkeziScreen({super.key});

  @override
  State<SiberKomutaMerkeziScreen> createState() => _SiberKomutaMerkeziScreenState();
}

class _SiberKomutaMerkeziScreenState extends State<SiberKomutaMerkeziScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  int _seciliSekme = 0;

  final Color primaryTeal = Colors.teal.shade700;
  final Color dangerColor = Colors.redAccent;
  final Color textColor = const Color(0xFF1E293B);
  final Color bgColor = const Color(0xFFFAFAFC);
  final Color surfaceColor = Colors.white;

  // ── 🚪 AĞDAN ÇIKIŞ PROTOKOLÜ ──
  Future<void> _agdanCikisYap() async {
    await _auth.signOut();
  }

  // 💎 TIKLAMA EFEKTLERİ VE YÖNLENDİRME
  void _modulBaslat(String modulAdi) {
    Widget? gidilecekSayfa;

    if (modulAdi == "Yedek Parça Ağı") gidilecekSayfa = const SiberMarketVitrini();
    if (modulAdi == "QR Kimlik Ağı") gidilecekSayfa = const SiberGozRadari();
    if (modulAdi == "Plaza Garaj") gidilecekSayfa = const AracKayitScreen(); // Şimdilik kayıt ekranına gitsin

    // S.O.S Özel Yönlendirme (Kırmızı Kod)
    if (modulAdi == "S.O.S Acil Durum") gidilecekSayfa = const SiberSosMerkezi();

    if (gidilecekSayfa != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => gidilecekSayfa!));
    } else {
      _plazaUyariGoster("BİLGİ", "[$modulAdi] Modülü Hazırlanıyor...", primaryTeal);
    }
  }

  void _plazaUyariGoster(String baslik, String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: renk, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
            const SizedBox(height: 4),
            Text(mesaj, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = _auth.currentUser;

    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: bgColor,
        extendBody: true,
        body: currentUser == null
            ? Center(child: CircularProgressIndicator(color: primaryTeal))
            : FutureBuilder<DocumentSnapshot>(
          future: _db.collection('kullanicilar').doc(currentUser.uid).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: primaryTeal));
            }

            String eposta = currentUser.email ?? "Kullanıcı";
            String adSoyad = "Kullanıcı";
            if (snapshot.hasData && snapshot.data!.exists) {
              adSoyad = (snapshot.data!.data() as Map<String, dynamic>)['ad_soyad'] ?? eposta.split('@')[0];
            }

            return Stack(
              children: [
                // =================================================================
                // 1. ANA ARAYÜZ
                // =================================================================
                SafeArea(
                  bottom: false,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- ÜST BAR (Kişiselleştirilmiş Karargah Başlığı) ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("HOŞ GELDİNİZ", style: TextStyle(color: Colors.black45, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
                                  const SizedBox(height: 4),
                                  Text(adSoyad.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                                ],
                              ),
                            ),
                            // Güvenli Çıkış Butonu
                            GestureDetector(
                              onTap: _agdanCikisYap,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: dangerColor.withValues(alpha: 0.3)),
                                  boxShadow: [BoxShadow(color: dangerColor.withValues(alpha: 0.1), blurRadius: 10)],
                                ),
                                child: Icon(Icons.power_settings_new, color: dangerColor, size: 20),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 32),

                        // --- MİNİMALİST ARAMA ÇUBUĞU ---
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5))]
                          ),
                          child: TextField(
                            style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
                            decoration: InputDecoration(
                              hintText: "Uygulamada ne arıyorsunuz?",
                              hintStyle: const TextStyle(color: Colors.black38, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
                              prefixIcon: const Icon(Icons.search, color: Colors.black38, size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.qr_code_scanner_outlined, color: primaryTeal, size: 20),
                                onPressed: () => _modulBaslat("QR Kimlik Ağı"),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // --- 3D AKTİF ARAÇ KARTI (GARAJ KÖPRÜSÜ) ---
                        const Text("AKTİF BAĞLANTI", style: TextStyle(color: Colors.black45, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => _modulBaslat("Plaza Garaj"),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: primaryTeal.withValues(alpha: 0.3), width: 1.5),
                              boxShadow: [BoxShadow(color: primaryTeal.withValues(alpha: 0.05), blurRadius: 30, spreadRadius: 5, offset: const Offset(0, 5))],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(color: primaryTeal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryTeal.withValues(alpha: 0.3))),
                                      child: Icon(Icons.directions_car_outlined, color: primaryTeal, size: 28),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black.withValues(alpha: 0.05))),
                                            child: Text("YENİ ARAÇ KAYDI", style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text("Garaja araç eklemek için dokun", style: TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_ios, color: Colors.black.withValues(alpha: 0.2), size: 16),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),

                        // --- GERÇEKÇİ İKONLARLA HİZMET AĞI ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("HİZMET MODÜLLERİ", style: TextStyle(color: Colors.black45, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
                            Icon(Icons.tune_outlined, color: Colors.black.withValues(alpha: 0.3), size: 18),
                          ],
                        ),
                        const SizedBox(height: 16),

                        GridView.count(
                          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 2.5,
                          children: [
                            _buildGercekciModul("S.O.S Acil Durum", Icons.sos, dangerColor),
                            _buildGercekciModul("Yedek Parça Ağı", Icons.settings_outlined, Colors.blue.shade700),
                            _buildGercekciModul("QR Kimlik Ağı", Icons.qr_code_scanner_outlined, primaryTeal),
                            _buildGercekciModul("Usta & Servis", Icons.engineering_outlined, Colors.green.shade700),
                            _buildGercekciModul("Dijital Cüzdan", Icons.account_balance_wallet_outlined, Colors.purple.shade700),
                            _buildGercekciModul("İkinci El Market", Icons.storefront_outlined, Colors.orange.shade700),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // =================================================================
                // 2. YÜZEN CAM (FLOATING GLASS) ALT MENÜ
                // =================================================================
                Positioned(
                  bottom: 24, left: 24, right: 24,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 5))]
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildNavIcon(0, Icons.dashboard_rounded, "Merkez"),
                            _buildNavIcon(1, Icons.directions_car_rounded, "Garaj"),
                            _buildNavIcon(2, Icons.grid_view_rounded, "Hizmet"),
                            _buildNavIcon(3, Icons.person_rounded, "Profil"),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // 💎 ŞIK MODÜL KARTLARI
  // -------------------------------------------------------------------------
  Widget _buildGercekciModul(String baslik, IconData ikon, Color vurguRengi) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: vurguRengi.withValues(alpha: 0.1),
          onTap: () => _modulBaslat(baslik),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: vurguRengi.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(ikon, color: vurguRengi, size: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(baslik, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5, fontFamily: 'Avenir'), maxLines: 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // 💎 YÜZEN MENÜ İKON OLUŞTURUCU
  // -------------------------------------------------------------------------
  Widget _buildNavIcon(int index, IconData icon, String label) {
    bool isSelected = _seciliSekme == index;
    return GestureDetector(
      onTap: () => setState(() => _seciliSekme = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryTeal.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? primaryTeal : Colors.black38, size: 22),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: primaryTeal, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
            ]
          ],
        ),
      ),
    );
  }
}
