import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🔥 SİBER KÖPRÜLER (Mutlak Rota ile Zırhlandı - Bağlantı Asla Kopmaz!)
import 'package:otodna/admin/master_gate.dart'; // Not: Eğer master_gate auth klasöründeyse CTRL+. ile yolunu teyit et Komutan!

class HqCommandCenterScreen extends StatefulWidget {
  const HqCommandCenterScreen({super.key});

  @override
  State<HqCommandCenterScreen> createState() => _HqCommandCenterScreenState();
}

class _HqCommandCenterScreenState extends State<HqCommandCenterScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  static const _darkSpace = Color(0xFF060F0F); // Derin Karargah Siyahı
  static const _cyan = Color(0xFF00FFC2); // Kuantum Turkuazı
  static const _neonBlue = Color(0xFF2979FF); // Siber Mavi
  static const _alertRed = Color(0xFFFF2A2A); // Kırmızı Alarm

  // Oturum açan komutanın ismini Auth'dan alıyoruz (Gerçek sistem)
  final String _adminIsmi = FirebaseAuth.instance.currentUser?.displayName ?? "Gazi Komutan";

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _sistemdenCik() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MasterGateScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkSpace,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.shield, color: _cyan),
        title: const Text("ADMİN KARARGAHI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.power_settings_new, color: _alertRed),
            onPressed: () => _cikisOnayDiyalogu(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/radar_grid.png'), // Siber arka plan
            fit: BoxFit.cover,
            opacity: 0.05,
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. ADMİN KARŞILAMA VE SİSTEM DURUMU
              _buildSiberKarsilama(),
              const SizedBox(height: 32),

              // 2. FİREBASE: CANLI FİNANS DEDEKTİFİ
              _buildKuantumBaslik("FİNANS DEDEKTİFİ (KARA KASA)", Icons.account_balance),
              _buildCanliFinansKarti(),
              const SizedBox(height: 32),

              // 3. FİREBASE: CANLI ARAÇ AĞI RADARI
              _buildKuantumBaslik("FİREBASE CANLI ARAÇ AĞI", Icons.radar),
              _buildCanliAracAgi(),
              const SizedBox(height: 32),

              // 4. FİREBASE: SİSTEM DENETİM MODÜLLERİ (Gerçek Sayımlar)
              _buildKuantumBaslik("SİBER DENETİM MODÜLLERİ", Icons.memory),
              _buildDenetimModulleri(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- 🔴 FİREBASE CANLI VERİ MOTORLARI ---

  Widget _buildCanliFinansKarti() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('sistem_verileri').doc('finans').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return _buildKuantumLoader(_cyan);

        double toplamHacim = 0.0;
        if (snapshot.hasData && snapshot.data!.exists) {
          toplamHacim = ((snapshot.data!.data() as Map<String, dynamic>)['toplam_ciro'] ?? 0).toDouble();
        }

        // 💰 SİBER FİNANS KURALI: Sadece ve sadece %12 (Net %10 + Vergi %2)
        double gaziPayi = toplamHacim * 0.12;

        return _buildCamEfektliKutu(
          borderColor: _cyan.withOpacity(0.5),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Ağdaki Toplam Hacim", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                  Text("₺${toplamHacim.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.white12, thickness: 1)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Merkez Hakedişi", style: TextStyle(color: _cyan, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      SizedBox(height: 4),
                      Text("Net %10 Pay + %2 Vergi", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Text("₺${gaziPayi.toStringAsFixed(2)}", style: const TextStyle(color: _cyan, fontSize: 24, fontWeight: FontWeight.w900)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCanliAracAgi() {
    return StreamBuilder<QuerySnapshot>(
      // Yalnızca en son eklenen veya güncellenen 5 aracı radarda gösterir (Performans için)
      stream: FirebaseFirestore.instance.collection('araclar').orderBy('kayit_tarihi', descending: true).limit(5).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return _buildKuantumLoader(_neonBlue);
        if (snapshot.hasError) return _buildSiberUyari("Radar Bağlantı Hatası: ${snapshot.error}", _alertRed);

        final araclar = snapshot.data?.docs ?? [];
        if (araclar.isEmpty) return _buildSiberUyari("Kuantum Ağında Henüz Araç Yok.", Colors.white54);

        return Column(
          children: araclar.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            String plaka = doc.id.toUpperCase();
            String sahip = data['sahibi'] ?? 'Bilinmeyen Sahip';
            String durum = data['durum'] ?? 'Siber Onaylı';

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildCamEfektliKutu(
                borderColor: _neonBlue.withOpacity(0.3),
                child: Row(
                  children: [
                    _buildNeonIkon(Icons.directions_car, _neonBlue),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(plaka, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 2)),
                          const SizedBox(height: 4),
                          Text("Sahip: $sahip", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
                        ],
                      ),
                    ),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: _cyan.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: _cyan.withOpacity(0.5))),
                        child: Text(durum, style: const TextStyle(color: _cyan, fontSize: 10, fontWeight: FontWeight.w900))
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildDenetimModulleri() {
    return Row(
      children: [
        Expanded(
          // FİREBASE: Aktif Bayi Sayacı
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('bayiler').where('aktif_mi', isEqualTo: true).snapshots(),
            builder: (context, snapshot) {
              int bayiSayisi = snapshot.hasData ? snapshot.data!.docs.length : 0;
              return _buildAdminModulKarti("Aktif Bayi Ağı", "$bayiSayisi Firma", Icons.storefront, _neonBlue, () {});
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          // FİREBASE: Aktif SOS Sayacı
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('sos_cagrilari').where('durum', isEqualTo: 'aktif').snapshots(),
            builder: (context, snapshot) {
              int sosSayisi = snapshot.hasData ? snapshot.data!.docs.length : 0;
              Color sosRengi = sosSayisi > 0 ? _alertRed : Colors.greenAccent;
              return _buildAdminModulKarti("S.O.S Radarı", "$sosSayisi Acil", Icons.radar, sosRengi, () {});
            },
          ),
        ),
      ],
    );
  }

  // --- 🎨 SİBER GÖRSEL ZIRHLAR VE UI BİLEŞENLERİ ---

  Widget _buildSiberKarsilama() {
    return Row(
      children: [
        AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _cyan.withOpacity(0.3 + (_pulseController.value * 0.7)), width: 2),
                  boxShadow: [BoxShadow(color: _cyan.withOpacity(_pulseController.value * 0.5), blurRadius: 15)],
                ),
                child: const CircleAvatar(radius: 26, backgroundColor: Colors.black, child: Icon(Icons.admin_panel_settings, color: _cyan, size: 30)),
              );
            }
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("SİBER KOMUTAN", style: TextStyle(color: _cyan, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
            const SizedBox(height: 4),
            Text(_adminIsmi, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
          ],
        ),
        const Spacer(),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.greenAccent)),
            child: const Row(
              children: [
                Icon(Icons.wifi_tethering, color: Colors.greenAccent, size: 12),
                SizedBox(width: 4),
                Text("AĞ ONLINE", style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ],
            )
        ),
      ],
    );
  }

  Widget _buildAdminModulKarti(String baslik, String altBilgi, IconData ikon, Color renk, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: _buildCamEfektliKutu(
        borderColor: renk.withOpacity(0.3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNeonIkon(ikon, renk),
                Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.3), size: 14),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(baslik, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, height: 1.2)),
                const SizedBox(height: 6),
                Text(altBilgi, style: TextStyle(color: renk, fontSize: 14, fontWeight: FontWeight.w900)),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _cikisOnayDiyalogu(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: _alertRed.withOpacity(0.5))),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: _alertRed),
            SizedBox(width: 10),
            Text("SİSTEMDEN ÇIKIŞ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
          ],
        ),
        content: const Text("Karargahtan ayrılmak ve Kuantum Ağı bağlantısını kesmek istediğinize emin misiniz?", style: TextStyle(color: Colors.white70, fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İPTAL", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold))),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _alertRed, foregroundColor: Colors.white),
              onPressed: _sistemdenCik,
              child: const Text("AĞI KES VE ÇIK", style: TextStyle(fontWeight: FontWeight.w900))
          ),
        ],
      ),
    );
  }

  Widget _buildKuantumBaslik(String metin, IconData icon) => Row(
    children: [
      Icon(icon, color: _cyan, size: 20),
      const SizedBox(width: 10),
      Text(metin, style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12)),
    ],
  );

  Widget _buildCamEfektliKutu({required Widget child, required Color borderColor}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: [BoxShadow(color: _cyan.withOpacity(0.02), blurRadius: 20)],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildNeonIkon(IconData icon, Color renk) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: renk.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: renk.withOpacity(0.4))),
      child: Icon(icon, color: renk, size: 20),
    );
  }

  Widget _buildKuantumLoader(Color renk) => Center(child: Padding(padding: const EdgeInsets.all(20.0), child: CircularProgressIndicator(color: renk, strokeWidth: 2)));

  Widget _buildSiberUyari(String mesaj, Color renk) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: renk.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: renk.withOpacity(0.5))), child: Text(mesaj, style: TextStyle(color: renk, fontWeight: FontWeight.bold)));
}