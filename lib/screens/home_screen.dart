import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../core/responsive_kalkan.dart';
import 'package:flutter/services.dart';

// İçe Aktarılan Modüller
import '../ariza_kaydi.dart';

/// 🏛️ YENİ ANA EKRAN (Yapı Kredi Referanslı - Ivory & Metallic Gold Konsepti)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  bool _otodnaAktif = true;

  // ⚜️ RENK PALETİ (Fildişi Sedef & Metalik Gold)
  static const Color darkGold = Color(0xFFB8860B);
  static const Color lightGold = Color(0xFFF3E5AB);
  static const Color metallicGoldCenter = Color(0xFFD4AF37);
  static const Color bgIvory = Color(0xFFFAFAFC); // Fildişi Sedef Kaplama
  static const Color textDark = Color(0xFF2C2519);
  static const Color cardWhite = Colors.white;

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: bgIvory,
        body: Column(
          children: [
            // ── ÜST BAR VE TOGGLE ALANI (Fildişi Zemin Üzeri Altın/Koyu Detaylar) ──
            Container(
              decoration: BoxDecoration(
                color: bgIvory,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Column(
                    children: [
                      // Üst Header
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.menu, color: textDark, size: 28),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                            },
                          ),
                          Expanded(
                            child: Container(
                              height: 36,
                              decoration: BoxDecoration(
                                color: cardWhite,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: darkGold.withOpacity(0.4)),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)],
                              ),
                              child: const Row(
                                children: [
                                  SizedBox(width: 12),
                                  Icon(Icons.search, color: darkGold, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    "OtoDNA Karargah'ta Ara",
                                    style: TextStyle(color: Colors.black54, fontSize: 13, fontFamily: 'Avenir', fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Stack(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications_none, color: textDark, size: 28),
                                onPressed: () {},
                              ),
                              Positioned(
                                right: 12,
                                top: 12,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                                ),
                              )
                            ],
                          ),
                          GestureDetector(
                            onTap: () => FirebaseAuth.instance.signOut(),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: darkGold, width: 2),
                                color: cardWhite,
                              ),
                              child: const Icon(Icons.person, color: darkGold, size: 20),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Toggle Button (Altın Çerçeveli)
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: cardWhite,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: darkGold.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _otodnaAktif = true),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: _otodnaAktif ? const LinearGradient(colors: [lightGold, metallicGoldCenter, darkGold]) : null,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "OtoDNA",
                                      style: TextStyle(
                                        color: _otodnaAktif ? Colors.white : textDark,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14,
                                        fontFamily: 'Avenir',
                                        shadows: _otodnaAktif ? [const Shadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1))] : [],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _otodnaAktif = false),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: !_otodnaAktif ? const LinearGradient(colors: [lightGold, metallicGoldCenter, darkGold]) : null,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Dış Servisler",
                                      style: TextStyle(
                                        color: !_otodnaAktif ? Colors.white : textDark,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14,
                                        fontFamily: 'Avenir',
                                        shadows: !_otodnaAktif ? [const Shadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1))] : [],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── LİSTELENEN KARTLAR ──
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Araçlarım Başlığı
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text("Araçlarım", style: TextStyle(color: textDark.withOpacity(0.6), fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: darkGold.withOpacity(0.2)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(colors: [lightGold, metallicGoldCenter]),
                                      borderRadius: BorderRadius.circular(8)
                                    ),
                                    child: const Icon(Icons.directions_car, color: Colors.white, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("34 SBR 001", style: TextStyle(color: textDark, fontSize: 15, fontWeight: FontWeight.w900)),
                                      Text("Siber Kuantum SUV", style: TextStyle(color: textDark.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                              const Icon(Icons.more_vert, color: Colors.black26),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("1.250.000 TL", style: TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                                  Text("Güncel Kasko Değeri", style: TextStyle(color: textDark.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text("Güvenli", style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                                  Text("Ağ Durumu", style: TextStyle(color: textDark.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    // Siber Mühürler
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text("Siber Mühürler", style: TextStyle(color: textDark.withOpacity(0.6), fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: darkGold.withOpacity(0.2)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 48, height: 32,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(colors: [textDark, Colors.black87]),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: darkGold, width: 1.5),
                                    ),
                                    child: const Center(child: Text("DNA", style: TextStyle(color: lightGold, fontWeight: FontWeight.w900, fontSize: 12))),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Kuantum Ekspertiz", style: TextStyle(color: textDark, fontSize: 15, fontWeight: FontWeight.w900)),
                                      Text("Rapor No: 5400 61** **** 4852", style: TextStyle(color: textDark.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                              const Icon(Icons.more_vert, color: Colors.black26),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Mühürlendi", style: TextStyle(color: textDark, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                                  Text("Son Durum", style: TextStyle(color: textDark.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── 4'LÜ HIZLI İŞLEM BUTONLARI (Metalik Gold Zemin) ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHizliIslem(Icons.directions_car, "Garajım\n(Varlıklar)", onTap: () => context.push('/musteri_garaj')),
                          _buildHizliIslem(Icons.qr_code_scanner, "Siber\nRadar", onTap: () => context.push('/siber_radar')),
                          _buildHizliIslem(Icons.history, "İşlem\nGeçmişi", onTap: () => context.push('/siber_istihbarat_loglari')),
                          _buildHizliIslem(Icons.build_circle_outlined, "Arıza\nServisi", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SiberArizaKaydi(saseNo: "34 SBR 001", modulKodu: "GENEL_BAKIM", ustaId: "SİSTEM_KULLANICISI")))),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── SİBER LİMİT ──
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: cardWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: darkGold.withOpacity(0.2)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.payments_outlined, color: darkGold, size: 24),
                              const SizedBox(width: 12),
                              const Text("Siber Kredim", style: TextStyle(color: textDark, fontSize: 14, fontWeight: FontWeight.w900)),
                            ],
                          ),
                          Row(
                            children: [
                              const Text("1.265.900 TL", style: TextStyle(color: darkGold, fontSize: 15, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_ios, color: Colors.black26, size: 12),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── BENİM DÜNYAM (HIZLI MENÜ) ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text("Hızlı Kısayollar", style: TextStyle(color: textDark, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                    ),
                    const SizedBox(height: 12),
                    
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildKucukKareKisaYol(Icons.emergency_share, "S.O.S\nMerkezi", onTap: () => context.push('/siber_sos')),
                          _buildKucukKareKisaYol(Icons.gavel_rounded, "Resmi\nİşlemler", onTap: () => context.push('/tuvturk_randevu')),
                          _buildKucukKareKisaYol(Icons.build_circle, "Yedek\nParça", onTap: () => context.push('/yedek_parca_ag')),
                          _buildKucukKareKisaYol(Icons.dashboard_customize, "Kokpit", onTap: () => context.push('/yol_bilgisayari')),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4'LÜ HIZLI İŞLEM BUTONU (Metalik Gold Arka Planlı)
  Widget _buildHizliIslem(IconData icon, String title, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [lightGold, metallicGoldCenter, darkGold],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: darkGold.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: textDark, fontSize: 11, fontWeight: FontWeight.w900, height: 1.2, fontFamily: 'Avenir'),
          ),
        ],
      ),
    );
  }

  // ALT KISIM KÜÇÜK KISA YOLLAR
  Widget _buildKucukKareKisaYol(IconData icon, String title, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: cardWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: darkGold.withOpacity(0.2)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: darkGold, size: 32),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(color: textDark, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
          ],
        ),
      ),
    );
  }
}