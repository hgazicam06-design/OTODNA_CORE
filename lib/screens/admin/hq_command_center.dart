import 'package:otodna/core/siber_tema.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🔥 SİBER KÖPRÜLER (Mutlak Rota ile Zırhlandı - Bağlantı Asla Kopmaz!)
import 'package:otodna/screens/admin/master_gate.dart';
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

class HqCommandCenterScreen extends StatefulWidget {
  HqCommandCenterScreen({super.key});

  @override
  State<HqCommandCenterScreen> createState() => _HqCommandCenterScreenState();
}

class _HqCommandCenterScreenState extends State<HqCommandCenterScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  static const _darkSpace = SiberTema.oledBlack; // Derin Karargah Siyahı
  static const _cyan = SiberTema.kuantumCyan; // Kuantum Turkuazı
  static const _neonBlue = SiberTema.kuantumCyan; // Siber Mavi'yi de Turkuaz'a sabitle
  static const _alertRed = SiberTema.kanKirmizi; // Kırmızı Alarm

  // Oturum açan komutanın ismini Auth'dan alıyoruz (Gerçek sistem)
  final String _adminIsmi = FirebaseAuth.instance.currentUser?.displayName ?? "Gazi Komutan";

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _sistemdenCik() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MasterGateScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Icon(Icons.shield, color: _cyan),
        title: Text("ADMİN KARARGAHI", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.power_settings_new, color: _alertRed),
            onPressed: () => _cikisOnayDiyalogu(context),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/radar_grid.png'), // Siber arka plan
            fit: BoxFit.cover,
            opacity: 0.05,
          ),
        ),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. ADMİN KARŞILAMA VE SİSTEM DURUMU
              _buildSiberKarsilama(),
              SizedBox(height: 32),

              // 2. FİREBASE: CANLI FİNANS DEDEKTİFİ
              _buildKuantumBaslik("FİNANS DEDEKTİFİ (KARA KASA)", Icons.account_balance),
              _buildCanliFinansKarti(),
              SizedBox(height: 32),

              // 3. FİREBASE: CANLI ARAÇ AĞI RADARI
              _buildKuantumBaslik("FİREBASE CANLI ARAÇ AĞI", Icons.radar),
              _buildCanliAracAgi(),
              SizedBox(height: 32),

              // 4. FİREBASE: SİSTEM DENETİM MODÜLLERİ (Gerçek Sayımlar)
              _buildKuantumBaslik("SİBER DENETİM MODÜLLERİ", Icons.memory),
              _buildDenetimModulleri(),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
      ),
    );
  }

  // --- 🔴 FİREBASE CANLI VERİ MOTORLARI ---

  Widget _buildCanliFinansKarti() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('finansal_islemler').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return _buildKuantumLoader(_cyan);

        double toplamHacim = 0.0;
        double gaziPayi = 0.0;
        
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            var data = doc.data() as Map<String, dynamic>;
            toplamHacim += (data['brut_tutar'] ?? 0).toDouble();
            gaziPayi += (data['gazi_payi_12'] ?? ((data['brut_tutar'] ?? 0) * 0.12)).toDouble();
          }
        }

        return _buildCamEfektliKutu(
          borderColor: _cyan.withOpacity(0.5),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Ağdaki Toplam Hacim", style: TextStyle(color: SiberTema.textMuted, fontSize: 13, fontWeight: FontWeight.bold)),
                  Text("₺${toplamHacim.toStringAsFixed(2)}", style: TextStyle(color: SiberTema.textMain, fontSize: 18, fontWeight: FontWeight.w900)),
                ],
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: SiberTema.textMuted, thickness: 1)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Merkez Hakedişi", style: TextStyle(color: _cyan, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      SizedBox(height: 4),
                      Text("Net %10 Pay + %2 Vergi", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Text("₺${gaziPayi.toStringAsFixed(2)}", style: TextStyle(color: _cyan, fontSize: 24, fontWeight: FontWeight.w900)),
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
      // Yalnızca en son eklenen 5 aracı radarda gösterir
      stream: FirebaseFirestore.instance.collection('vehicles').limit(5).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return _buildKuantumLoader(_neonBlue);
        if (snapshot.hasError) return _buildSiberUyari("Radar Bağlantı Hatası: ${snapshot.error}", _alertRed);

        final araclar = snapshot.data?.docs ?? [];
        if (araclar.isEmpty) return _buildSiberUyari("Kuantum Ağında Henüz Araç Yok.", Colors.white54);

        return Column(
          children: araclar.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            String plaka = data['plaka']?.toString().toUpperCase() ?? doc.id.toUpperCase();
            String adi = data['sahibiAdi'] ?? '';
            String soyadi = data['sahibiSoyadi'] ?? '';
            String sahip = "$adi $soyadi".trim();
            if (sahip.isEmpty) sahip = 'Bilinmeyen Sahip';
            String durum = 'Siber Onaylı';

            return Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: _buildCamEfektliKutu(
                borderColor: _neonBlue.withOpacity(0.3),
                child: Row(
                  children: [
                    _buildNeonIkon(Icons.directions_car, _neonBlue),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(plaka, style: TextStyle(color: SiberTema.textMain, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 2)),
                          SizedBox(height: 4),
                          Text("Sahip: $sahip", style: TextStyle(color: SiberTema.textMain.withOpacity(0.5), fontSize: 11)),
                        ],
                      ),
                    ),
                    Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: _cyan.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: _cyan.withOpacity(0.5))),
                        child: Text(durum, style: TextStyle(color: _cyan, fontSize: 10, fontWeight: FontWeight.w900))
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
        SizedBox(width: 16),
        Expanded(
          // FİREBASE: Aktif SOS Sayacı (İstihbarat)
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('siber_istihbarat_loglari').where('kategori', isEqualTo: 'SOS').snapshots(),
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
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _cyan.withOpacity(0.3 + (_pulseController.value * 0.7)), width: 2),
                  boxShadow: [BoxShadow(color: _cyan.withOpacity(_pulseController.value * 0.5), blurRadius: 15)],
                ),
                child: CircleAvatar(radius: 26, backgroundColor: Colors.black, child: Icon(Icons.admin_panel_settings, color: _cyan, size: 30)),
              );
            }
        ),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("SİBER KOMUTAN", style: TextStyle(color: _cyan, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
            SizedBox(height: 4),
            Text(_adminIsmi, style: TextStyle(color: SiberTema.textMain, fontSize: 20, fontWeight: FontWeight.w900)),
          ],
        ),
        Spacer(),
        Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.greenAccent)),
            child: Row(
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
            SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(baslik, style: TextStyle(color: SiberTema.textMain, fontSize: 12, fontWeight: FontWeight.bold, height: 1.2)),
                SizedBox(height: 6),
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
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: _alertRed),
            SizedBox(width: 10),
            Text("SİSTEMDEN ÇIKIŞ", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w900, fontSize: 16)),
          ],
        ),
        content: Text("Karargahtan ayrılmak ve Kuantum Ağı bağlantısını kesmek istediğinize emin misiniz?", style: TextStyle(color: SiberTema.textMuted, fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("İPTAL", style: TextStyle(color: SiberTema.textMuted, fontWeight: FontWeight.bold))),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _alertRed, foregroundColor: Colors.white),
              onPressed: _sistemdenCik,
              child: Text("AĞI KES VE ÇIK", style: TextStyle(fontWeight: FontWeight.w900))
          ),
        ],
      ),
    );
  }

  Widget _buildKuantumBaslik(String metin, IconData icon) => Row(
    children: [
      Icon(icon, color: _cyan, size: 20),
      SizedBox(width: 10),
      Text(metin, style: TextStyle(color: SiberTema.textMuted, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12)),
    ],
  );

  Widget _buildCamEfektliKutu({required Widget child, required Color borderColor}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
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
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(color: renk.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: renk.withOpacity(0.4))),
      child: Icon(icon, color: renk, size: 20),
    );
  }

  Widget _buildKuantumLoader(Color renk) => Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator(color: renk, strokeWidth: 2)));

  Widget _buildSiberUyari(String mesaj, Color renk) => Container(padding: EdgeInsets.all(16), decoration: BoxDecoration(color: renk.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: renk.withOpacity(0.5))), child: Text(mesaj, style: TextStyle(color: renk, fontWeight: FontWeight.bold)));
}