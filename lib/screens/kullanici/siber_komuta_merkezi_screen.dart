// lib/kullanici/siber_komuta_merkezi_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🚀 KARARGAH ZIRHLARI VE YÖNLENDİRME KABLOLARI
import '../core/siber_tema.dart';
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

  // ── 🚪 AĞDAN ÇIKIŞ PROTOKOLÜ ──
  Future<void> _agdanCikisYap() async {
    await _auth.signOut();
  }

  // 💎 TIKLAMA EFEKTLERİ VE YÖNLENDİRME (Kuantum Rotalar Eklendi)
  void _modulBaslat(String modulAdi) {
    Widget? gidilecekSayfa;

    if (modulAdi == "Yedek Parça Ağı") gidilecekSayfa = const SiberMarketVitrini();
    if (modulAdi == "QR Kimlik Ağı") gidilecekSayfa = const SiberGozRadari();
    if (modulAdi == "Kuantum Garaj") gidilecekSayfa = const AracKayitScreen(); // Şimdilik kayıt ekranına gitsin

    // S.O.S Özel Yönlendirme (Kırmızı Kod)
    if (modulAdi == "S.O.S Acil Durum") gidilecekSayfa = const SiberSosMerkezi();

    if (gidilecekSayfa != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => gidilecekSayfa!));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('[$modulAdi] Sinyal Bekleniyor... (Yakında)', style: const TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.bold)),
            backgroundColor: SiberTema.kuantumCyan,
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = _auth.currentUser;

    // 🛡️ Bütün Ekranı Zırhın İçine Alıyoruz!
    return ResponsiveKalkan(
      child: Scaffold(
        backgroundColor: Colors.transparent, // Kalkan zaten siyah veriyor
        extendBody: true,
        body: currentUser == null
            ? const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan))
            : FutureBuilder<DocumentSnapshot>(
          future: _db.collection('kullanicilar').doc(currentUser.uid).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
            }

            String eposta = currentUser.email ?? "Ajan";
            String adSoyad = "Kullanıcı";
            if (snapshot.hasData && snapshot.data!.exists) {
              adSoyad = (snapshot.data!.data() as Map<String, dynamic>)['ad_soyad'] ?? eposta.split('@')[0];
            }

            return Stack(
              children: [
                // =================================================================
                // 1. ARKA PLAN: MİNİMALİST NEON IŞIMALARI
                // =================================================================
                Positioned(
                  top: -150, left: -100,
                  child: Container(
                    width: 400, height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [SiberTema.kuantumCyan.withOpacity(0.1), Colors.transparent], stops: const [0.1, 1.0]),
                    ),
                  ),
                ),

                // =================================================================
                // 2. ANA ARAYÜZ (HUD)
                // =================================================================
                SafeArea(
                  bottom: false,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 120),
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
                                  const Text("Siber Komutan", style: TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2)),
                                  const SizedBox(height: 4),
                                  Text(adSoyad.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: SiberTema.textMain, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1)),
                                ],
                              ),
                            ),
                            // Güvenli Çıkış Butonu
                            GestureDetector(
                              onTap: _agdanCikisYap,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: SiberTema.kanKirmizi.withOpacity(0.5), width: 2),
                                  boxShadow: [BoxShadow(color: SiberTema.kanKirmizi.withOpacity(0.2), blurRadius: 10)],
                                ),
                                child: const CircleAvatar(
                                  radius: 20,
                                  backgroundColor: SiberTema.matGrey,
                                  child: Icon(Icons.power_settings_new, color: SiberTema.kanKirmizi, size: 20),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 32),

                        // --- MİNİMALİST ARAMA ÇUBUĞU ---
                        Container(
                          decoration: BoxDecoration(
                            color: SiberTema.matGrey,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                          ),
                          child: TextField(
                            style: const TextStyle(color: SiberTema.textMain, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: "Siber ağda ne arıyorsunuz?",
                              hintStyle: TextStyle(color: SiberTema.textMain.withOpacity(0.2), fontSize: 13),
                              prefixIcon: const Icon(Icons.search, color: SiberTema.textMuted, size: 20),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.qr_code_scanner_outlined, color: SiberTema.kuantumCyan, size: 20),
                                onPressed: () => _modulBaslat("QR Kimlik Ağı"),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // --- 3D AKTİF ARAÇ KARTI (GARAJ KÖPRÜSÜ) ---
                        const Text("AKTİF BAĞLANTI", style: TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => _modulBaslat("Kuantum Garaj"),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: SiberTema.matGrey,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3), width: 1.5),
                              boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.05), blurRadius: 30, spreadRadius: 5)],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(color: SiberTema.oledBlack, borderRadius: BorderRadius.circular(16), border: Border.all(color: SiberTema.textMuted)),
                                      child: const Icon(Icons.directions_car_outlined, color: SiberTema.kuantumCyan, size: 28),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: SiberTema.textMuted)),
                                            child: const Text("YENİ ARAÇ KAYDI", style: TextStyle(color: SiberTema.textMain, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text("Garaja araç eklemek için dokun", style: TextStyle(color: SiberTema.textMuted, fontSize: 10)),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.arrow_forward_ios, color: SiberTema.textMuted, size: 16),
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
                            const Text("SİBER AĞ MODÜLLERİ", style: TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
                            Icon(Icons.tune_outlined, color: Colors.white.withOpacity(0.3), size: 18),
                          ],
                        ),
                        const SizedBox(height: 16),

                        GridView.count(
                          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 2.5,
                          children: [
                            _buildGercekciModul("S.O.S Acil Durum", Icons.sos, SiberTema.kanKirmizi), // Kırmızı Kod Eklendi!
                            _buildGercekciModul("Yedek Parça Ağı", Icons.settings_outlined, Colors.blueAccent),
                            _buildGercekciModul("QR Kimlik Ağı", Icons.qr_code_scanner_outlined, SiberTema.kuantumCyan),
                            _buildGercekciModul("Siber Usta & Servis", Icons.engineering_outlined, Colors.greenAccent),
                            _buildGercekciModul("Kripto Cüzdan", Icons.account_balance_wallet_outlined, Colors.purpleAccent),
                            _buildGercekciModul("İkinci El Market", Icons.storefront_outlined, Colors.orangeAccent),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // =================================================================
                // 3. YÜZEN CAM (FLOATING GLASS) ALT MENÜ
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
                          color: SiberTema.matGrey.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
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
  // 💎 IOS / TESLA TARZI ŞIK MODÜL KARTLARI
  // -------------------------------------------------------------------------
  Widget _buildGercekciModul(String baslik, IconData ikon, Color vurguRengi) {
    return Container(
      decoration: BoxDecoration(
        color: SiberTema.matGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: vurguRengi.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: vurguRengi.withOpacity(0.1),
          onTap: () => _modulBaslat(baslik),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(ikon, color: vurguRengi.withOpacity(0.8), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(baslik, style: const TextStyle(color: SiberTema.textMain, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5), maxLines: 2),
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
          color: isSelected ? SiberTema.kuantumCyan.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? SiberTema.kuantumCyan : Colors.white38, size: 22),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ]
          ],
        ),
      ),
    );
  }
}