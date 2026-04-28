import 'package:otodna/core/siber_tema.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/siber_tema.dart'; // 🚀 SİBER KÖPRÜ
import '../distributor/distributor_terminali.dart'; // 👑 DİSTRİBÜTÖR KÖPRÜSÜ

class SiberProfilScreen extends StatefulWidget {
  SiberProfilScreen({super.key});

  @override
  State<SiberProfilScreen> createState() => _SiberProfilScreenState();
}

class _SiberProfilScreenState extends State<SiberProfilScreen> {
  static Color primaryCyan = SiberTema.kuantumCyan;
  static Color siberGold = SiberTema.siberGold;
  static Color neonPink = SiberTema.kanKirmizi;

  bool _gucTasarrufu = false;
  String _kullaniciMail = "Bilinmeyen Ajan";

  @override
  void initState() {
    super.initState();
    _kullaniciMail = FirebaseAuth.instance.currentUser?.email ?? "KUANTUM ZİYARETÇİSİ";
  }

  void _cikisYap() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. KUANTUM ARKA PLAN
          Positioned.fill(child: Container(decoration: SiberTema.siberArkaPlan)),

          // 2. ANA İÇERİK
          SafeArea(
            child: Column(
              children: [
                _buildSiberAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHolografikKimlik(),
                        SizedBox(height: 32),
                        _buildGenetikSkorPaneli(),
                        SizedBox(height: 32),
                        Text("SİBER KOMUTA MERKEZİ", style: TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
                        SizedBox(height: 16),
                        _buildKomutaMenusu(),
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

  Widget _buildSiberAppBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.4), border: Border(bottom: BorderSide(color: SiberTema.textMuted))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle), child: Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 18)),
              ),
              Text('K İ Ş İ S E L   A Ğ', style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 3, fontFamily: 'Avenir')),
              Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: primaryCyan.withOpacity(0.5))), child: Icon(Icons.qr_code_scanner, color: primaryCyan, size: 18)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHolografikKimlik() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: primaryCyan, width: 2),
              boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.3), blurRadius: 20, spreadRadius: 5)],
              image: DecorationImage(image: NetworkImage("https://via.placeholder.com/150/000000/00FFC2?text=AJAN"), fit: BoxFit.cover),
            ),
          ),
          SizedBox(height: 16),
          Text(_kullaniciMail.toUpperCase(), style: TextStyle(color: SiberTema.textMain, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: siberGold.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: siberGold.withOpacity(0.5))),
            child: Text("BİREYSEL AJAN", style: TextStyle(color: siberGold, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
          )
        ],
      ),
    );
  }

  Widget _buildGenetikSkorPaneli() {
    double skor = 85.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(24), border: Border.all(color: SiberTema.textMuted)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("SİBER GENETİK SKORU", style: TextStyle(color: SiberTema.textMain, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                  Text("%${skor.toInt()}", style: TextStyle(color: primaryCyan, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                ],
              ),
              SizedBox(height: 16),
              ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: skor / 100, minHeight: 8, backgroundColor: Colors.white.withOpacity(0.05), color: primaryCyan)),
              SizedBox(height: 16),
              Text("Ağdaki güvenilirliğiniz Kuantum Yapay Zeka tarafından analiz edilmektedir. Yüksek skor, ilanlarınızın vitrinde çıkmasını sağlar.", textAlign: TextAlign.center, style: TextStyle(color: SiberTema.textMuted, fontSize: 10, height: 1.5, fontFamily: 'Avenir')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKomutaMenusu() {
    return Column(
      children: [
        _buildMenuElemani(Icons.account_balance_wallet_outlined, "Siber Kasa Bakiye", "Havuzda Bekleyen Tutar: ₺0.00"),
        _buildMenuElemani(Icons.inventory_2_outlined, "Aktif İlanlarım", "Yayında olan 3 ilanınız var."),
        _buildMenuElemani(Icons.favorite_border, "Favori Parçalarım", "İzlemeye aldığınız yedek parçalar."),
        SizedBox(height: 16),
        _buildGucTasarrufuAnahtari(),
        SizedBox(height: 16),
        // 👑 DİSTRİBÜTÖR AĞI BAĞLANTISI
        _buildMenuElemani(Icons.hub_outlined, "Toptancı / Distribütör Ağı", "V.I.P B2B Ticaret ve Alt Bayi Yönetimi", isAltin: true, onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => DistributorTerminali()));
        }),
        _buildMenuElemani(Icons.security_outlined, "Karargah İzni İste", "Bayi / Distribütör olmak için başvur."),
        _buildMenuElemani(Icons.exit_to_app, "Ağdan Çıkış Yap (Log Out)", "Siber kimliğinizi güvenle kapatın.", isTehlike: true, onTap: _cikisYap),
      ],
    );
  }

  Widget _buildMenuElemani(IconData ikon, String baslik, String altBaslik, {bool isTehlike = false, bool isAltin = false, VoidCallback? onTap}) {
    Color anaRenk = isAltin ? siberGold : (isTehlike ? neonPink : primaryCyan);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(16), border: Border.all(color: anaRenk.withOpacity(0.2))),
        child: Row(
          children: [
            Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: anaRenk.withOpacity(0.1), shape: BoxShape.circle), child: Icon(ikon, color: anaRenk, size: 20)),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(baslik, style: TextStyle(color: isTehlike ? neonPink : (isAltin ? siberGold : Colors.white), fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                  SizedBox(height: 4),
                  Text(altBaslik, style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontFamily: 'Avenir')),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.2), size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildGucTasarrufuAnahtari() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(16), border: Border.all(color: SiberTema.textMuted)),
      child: Row(
        children: [
          Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: siberGold.withOpacity(0.1), shape: BoxShape.circle), child: Icon(Icons.battery_saver_outlined, color: siberGold, size: 20)),
          SizedBox(width: 16),
          Expanded(child: Text("Kuantum Güç Tasarrufu", style: TextStyle(color: SiberTema.textMain, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Avenir'))),
          Switch(
            value: _gucTasarrufu,
            activeColor: primaryCyan,
            onChanged: (val) => setState(() => _gucTasarrufu = val),
          )
        ],
      ),
    );
  }
}
