import 'package:flutter/material.dart';

class SiberFormMerkeziScreen extends StatefulWidget {
  const SiberFormMerkeziScreen({super.key});

  @override
  State<SiberFormMerkeziScreen> createState() => _SiberFormMerkeziScreenState();
}

class _SiberFormMerkeziScreenState extends State<SiberFormMerkeziScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Color primaryTeal = Colors.teal.shade700;
  final Color textColor = const Color(0xFF1E293B);
  final Color bgColor = const Color(0xFFFAFAFC);
  final Color surfaceColor = Colors.white;

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

  // 💎 PLAZA KALİTESİ: E-TUTANAK MODÜLÜ
  void _kazaTutanagiBaslat() {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, -5))]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 32),
            Row(children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28)), 
              const SizedBox(width: 16), 
              Text("E-Kaza Tespit Tutanağı", style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Avenir'))
            ]),
            const SizedBox(height: 16),
            const Text("Klasik kağıt tutanaklara son! Kazaya karışan aracın QR kimliğini okutarak saniyeler içinde yasal süreci başlatın.", style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.5, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
            const SizedBox(height: 32),

            _buildAdimSatiri(Icons.satellite_alt_outlined, "SİNYAL", "Konum GPS'ten çekiliyor.", Colors.blue),
            _buildAdimSatiri(Icons.document_scanner_outlined, "ANALİZ", "Yapay zeka ile hasar taranıyor.", Colors.orange),
            _buildAdimSatiri(Icons.qr_code_scanner_outlined, "KİMLİK", "Karşı aracın QR kimliği okutuluyor.", primaryTeal),

            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                onPressed: () {
                  Navigator.pop(context);
                  _plazaUyariGoster("TUTANAK BAŞLATILDI", "E-Tutanak Modülü Devrede 🚨", Colors.redAccent);
                },
                icon: const Icon(Icons.shield_outlined, size: 20),
                label: const Text("TUTANAĞI BAŞLAT", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1, fontFamily: 'Avenir')),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAdimSatiri(IconData icon, String adim, String aciklama, Color renk) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: renk.withValues(alpha: 0.1), shape: BoxShape.circle, border: Border.all(color: renk.withValues(alpha: 0.3))),
              child: Icon(icon, color: renk, size: 24)
          ),
          const SizedBox(width: 16),
          Text(adim, style: TextStyle(color: renk, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1, fontFamily: 'Avenir')),
          const SizedBox(width: 16),
          Expanded(child: Text(aciklama, style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir'))),
        ],
      ),
    );
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
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: primaryTeal, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text('E V R A K   Y Ö N E T İ M İ', style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 3, fontFamily: 'Avenir')),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 💎 MİNİMALİST SEKMELER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Container(
              height: 52,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(26)),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2))]),
                labelColor: primaryTeal,
                unselectedLabelColor: Colors.black45,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5, fontFamily: 'Avenir'),
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    Text("Resmi Belgeler", style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Avenir')),
                    const SizedBox(height: 20),
                    _buildFormKarti("Kaza Tespit Tutanağı", "Kazaya karıştığınızda QR onaylı yasal e-tutanak oluşturun.", Icons.car_crash_outlined, Colors.redAccent, _kazaTutanagiBaslat),
                    _buildFormKarti("Araç Tesellüm Tutanağı", "Aracı vale/servise bırakırken çizik ve yakıt durumunu imzalayın.", Icons.key_outlined, Colors.orange, () {}),
                    _buildFormKarti("İkinci El Kapora Sözleşmesi", "Oto Market işlemlerinizde şifreli dijital kapora sözleşmesi yapın.", Icons.handshake_outlined, Colors.green, () {}),
                  ],
                ),

                // 2. SEKME: BAKIM & TEKLİF FORMLARI
                ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    Text("Onay Bekleyen İşlemler", style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Avenir')),
                    const SizedBox(height: 20),
                    _buildTeklifKarti("Gazi Oto Servis", "Ön Fren Balatası + Disk Değişimi", "4.500 ₺", "ONAY BEKLİYOR"),

                    const SizedBox(height: 40),
                    Text("Periyodik Bakım Cetvelleri", style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Avenir')),
                    const SizedBox(height: 20),
                    _buildFormKarti("10.000 KM Standart Bakım", "Yağ, filtre ve sıvı değişimlerinin dijital onay cetveli.", Icons.oil_barrel_outlined, Colors.blue, () {}),
                    _buildFormKarti("50.000 KM Ağır Bakım", "Triger, şanzıman ve balata değişim detayları.", Icons.settings_outlined, Colors.purple, () {}),
                  ],
                ),

                // 3. SEKME: RANDEVU SİSTEMİ
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity, height: 56,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(backgroundColor: Colors.white, side: BorderSide(color: primaryTeal.withValues(alpha: 0.5)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                          onPressed: () { _plazaUyariGoster("SİSTEM HAZIRLANIYOR", "Akıllı Asistan üzerinden randevu motoru başlatılıyor...", primaryTeal); },
                          icon: Icon(Icons.add, color: primaryTeal, size: 20),
                          label: Text("YENİ SERVİS RANDEVUSU AL", style: TextStyle(color: primaryTeal, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1, fontFamily: 'Avenir')),
                        ),
                      ),
                      const SizedBox(height: 48),

                      Text("Yaklaşan İşlemler", style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Avenir')),
                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: primaryTeal.withValues(alpha: 0.3)), boxShadow: [BoxShadow(color: primaryTeal.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))]),
                        child: Row(
                          children: [
                            Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: primaryTeal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryTeal.withValues(alpha: 0.3))),
                                child: Column(
                                    children: [
                                      Text("15", style: TextStyle(color: primaryTeal, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                                      Text("MART", style: TextStyle(color: primaryTeal, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir'))
                                    ]
                                )
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Borusan Oto Yetkili Servis", style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                                  const SizedBox(height: 8),
                                  const Text("Saat: 14:30 • Şikayet: Standart Bakım", style: TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                                ],
                              ),
                            ),
                            Icon(Icons.qr_code_outlined, color: primaryTeal, size: 28)
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

  // 💎 ŞIK FORM KARTLARI
  Widget _buildFormKarti(String baslik, String aciklama, IconData ikon, Color renk, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5))]),
        child: Row(
          children: [
            Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: renk.withValues(alpha: 0.05), shape: BoxShape.circle, border: Border.all(color: renk.withValues(alpha: 0.3))),
                child: Icon(ikon, color: renk, size: 28)
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(baslik, style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Avenir')),
                  const SizedBox(height: 8),
                  Text(aciklama, style: const TextStyle(color: Colors.black54, fontSize: 11, height: 1.4, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.arrow_forward_ios, color: Colors.black.withValues(alpha: 0.2), size: 16)
          ],
        ),
      ),
    );
  }

  // 💎 TEKLİF ONAY KARTI
  Widget _buildTeklifKarti(String firma, String islem, String fiyat, String durum) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
          boxShadow: [BoxShadow(color: Colors.orange.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 5))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.business_outlined, color: Colors.black45, size: 20),
                  const SizedBox(width: 8),
                  Text(firma, style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 14, fontFamily: 'Avenir')),
                ],
              ),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.withValues(alpha: 0.5))), child: Text(durum, style: const TextStyle(color: Colors.orange, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir'))),
            ],
          ),
          const SizedBox(height: 24),
          Text(islem, style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.4, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
          const SizedBox(height: 20),
          Divider(color: Colors.black.withValues(alpha: 0.05)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(fiyat, style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Avenir')),
              Row(
                children: [
                  TextButton(onPressed: () {}, child: const Text("REDDET", style: TextStyle(color: Colors.black38, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir'))),
                  const SizedBox(width: 8),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: () {},
                      child: const Text("ONAYLA", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1, fontFamily: 'Avenir'))
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