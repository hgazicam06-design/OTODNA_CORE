import 'package:flutter/material.dart';

class SiberFormMerkeziScreen extends StatefulWidget {
  const SiberFormMerkeziScreen({super.key});

  @override
  State<SiberFormMerkeziScreen> createState() => _SiberFormMerkeziScreenState();
}

class _SiberFormMerkeziScreenState extends State<SiberFormMerkeziScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 💎 TESLA MİMARİSİ: E-TUTANAK MODÜLÜ
  void _kazaTutanagiBaslat() {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.redAccent.withOpacity(0.5))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 24),
            const Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 32), SizedBox(width: 12), Text("E-Kaza Tespit Tutanağı", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5))]),
            const SizedBox(height: 12),
            const Text("Klasik kağıt tutanaklara son! Kazaya karışan aracın QR kimliğini okutarak saniyeler içinde yasal süreci başlatın.", style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5)),
            const SizedBox(height: 32),

            _buildAdimSatiri(Icons.satellite_alt_outlined, "SİNYAL", "Konum uydudan çekiliyor.", Colors.blueAccent),
            _buildAdimSatiri(Icons.document_scanner_outlined, "ANALİZ", "Yapay zeka ile hasar taranıyor.", Colors.orangeAccent),
            _buildAdimSatiri(Icons.qr_code_scanner_outlined, "KİMLİK", "Karşı aracın Kuantum QR'ı okutuluyor.", const Color(0xFF00FFC2)),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('E-Tutanak Motoru Başlatılıyor... 🚨', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.redAccent));
                },
                icon: const Icon(Icons.shield_outlined, size: 20),
                label: const Text("TUTANAĞI BAŞLAT", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAdimSatiri(IconData icon, String adim, String aciklama, Color renk) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: renk.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: renk.withOpacity(0.3))),
              child: Icon(icon, color: renk, size: 20)
          ),
          const SizedBox(width: 16),
          Text(adim, style: TextStyle(color: renk, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
          const SizedBox(width: 12),
          Expanded(child: Text(aciklama, style: const TextStyle(color: Colors.white70, fontSize: 12))),
        ],
      ),
    );
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('B Ü R O K R A S İ   A Ğ I', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 3)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 💎 MİNİMALİST SEKMELER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              height: 48,
              decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.white38,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5),
                tabs: const [Tab(text: "Tutanak"), Tab(text: "Onay"), Tab(text: "Randevu")],
              ),
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(),
              children: [
                // 1. SEKME: TUTANAKLAR (Kaza, Teslimat)
                ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const Text("Resmi Belgeler", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.5)),
                    const SizedBox(height: 16),
                    _buildFormKarti("Kaza Tespit Tutanağı", "Kazaya karıştığınızda QR onaylı yasal e-tutanak oluşturun.", Icons.car_crash_outlined, Colors.redAccent, _kazaTutanagiBaslat),
                    _buildFormKarti("Araç Tesellüm Tutanağı", "Aracı vale/servise bırakırken çizik ve yakıt durumunu imzalayın.", Icons.key_outlined, Colors.orangeAccent, () {}),
                    _buildFormKarti("İkinci El Kapora Sözleşmesi", "Oto Market işlemlerinizde şifreli dijital kapora sözleşmesi yapın.", Icons.handshake_outlined, Colors.greenAccent, () {}),
                  ],
                ),

                // 2. SEKME: BAKIM & TEKLİF FORMLARI
                ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const Text("Onay Bekleyen İşlemler", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.5)),
                    const SizedBox(height: 16),
                    _buildTeklifKarti("Gazi Oto Servis", "Ön Fren Balatası + Disk Değişimi", "4.500 ₺", "ONAY BEKLİYOR"),

                    const SizedBox(height: 32),
                    const Text("Periyodik Bakım Cetvelleri", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.5)),
                    const SizedBox(height: 16),
                    _buildFormKarti("10.000 KM Standart Bakım", "Yağ, filtre ve sıvı değişimlerinin dijital onay cetveli.", Icons.oil_barrel_outlined, Colors.blueAccent, () {}),
                    _buildFormKarti("50.000 KM Ağır Bakım", "Triger, şanzıman ve balata değişim detayları.", Icons.settings_outlined, Colors.purpleAccent, () {}),
                  ],
                ),

                // 3. SEKME: RANDEVU SİSTEMİ
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity, height: 56,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(side: BorderSide(color: primaryCyan.withOpacity(0.5)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Siber Radar Başlatılıyor...', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: primaryCyan)); },
                          icon: const Icon(Icons.add, color: primaryCyan, size: 20),
                          label: const Text("YENİ SERVİS RANDEVUSU AL", style: TextStyle(color: primaryCyan, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
                        ),
                      ),
                      const SizedBox(height: 40),

                      const Text("Yaklaşan İşlemler", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.5)),
                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: primaryCyan.withOpacity(0.3))),
                        child: Row(
                          children: [
                            Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: primaryCyan.withOpacity(0.5))),
                                child: const Column(
                                    children: [
                                      Text("15", style: TextStyle(color: primaryCyan, fontSize: 24, fontWeight: FontWeight.w900)),
                                      Text("MART", style: TextStyle(color: primaryCyan, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1))
                                    ]
                                )
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Borusan Oto Yetkili Servis", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 6),
                                  Text("Saat: 14:30 • Şikayet: Standart Bakım", style: TextStyle(color: Colors.white54, fontSize: 11)),
                                ],
                              ),
                            ),
                            const Icon(Icons.qr_code_outlined, color: primaryCyan, size: 24)
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 💎 TESLA MİMARİSİ: ŞIK FORM KARTLARI
  Widget _buildFormKarti(String baslik, String aciklama, IconData ikon, Color renk, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
        child: Row(
          children: [
            Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: renk.withOpacity(0.05), shape: BoxShape.circle, border: Border.all(color: renk.withOpacity(0.3))),
                child: Icon(ikon, color: renk, size: 24)
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(baslik, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: -0.5)),
                  const SizedBox(height: 6),
                  Text(aciklama, style: const TextStyle(color: Colors.white54, fontSize: 11, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.2), size: 16)
          ],
        ),
      ),
    );
  }

  // 💎 TESLA MİMARİSİ: TEKLİF ONAY KARTI (Glow Efektli)
  Widget _buildTeklifKarti(String firma, String islem, String fiyat, String durum) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
          boxShadow: [BoxShadow(color: Colors.orangeAccent.withOpacity(0.05), blurRadius: 20)]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.business_outlined, color: Colors.white54, size: 18),
                  const SizedBox(width: 8),
                  Text(firma, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.orangeAccent.withOpacity(0.5))), child: Text(durum, style: const TextStyle(color: Colors.orangeAccent, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1))),
            ],
          ),
          const SizedBox(height: 20),
          Text(islem, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(fiyat, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              Row(
                children: [
                  TextButton(onPressed: () {}, child: const Text("REDDET", style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1))),
                  const SizedBox(width: 8),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FFC2), foregroundColor: Colors.black, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      onPressed: () {},
                      child: const Text("ONAYLA", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1))
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}