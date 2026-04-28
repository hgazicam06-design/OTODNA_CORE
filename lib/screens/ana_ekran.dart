import 'package:otodna/core/siber_tema.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../models/arac_model.dart';
import '../services/api_key_service.dart';
import '../services/asistan_service.dart';
import '../services/hatirlatma_service.dart';
import '../widgets/asistan_widget.dart';

class AnaEkran extends StatefulWidget {
  AnaEkran({super.key});

  @override
  State<AnaEkran> createState() => _AnaEkranState();
}

class _AnaEkranState extends State<AnaEkran> with TickerProviderStateMixin {
  // 🏢 ULTRA PROFESYONEL KURUMSAL PALET (Kurumsal Web Sitesi Esintisi)
  final Color bgColor = Color(0xFFF4F6F8); // Çok hafif kurumsal gri
  final Color surfaceColor = Colors.white;
  final Color primaryTeal = Color(0xFF005A64); // Yapı Kredi & Kurumsal derin turkuaz/lacivert karışımı
  final Color secondaryTeal = Color(0xFF009688); // Açık turkuaz vurgu
  final Color textMain = Color(0xFF1E293B);
  final Color textMuted = Color(0xFF64748B);
  final Color dangerColor = Color(0xFFD32F2F); // Profesyonel kırmız

  final _asistan = AsistanService();
  List<AracModel> _araclar = [];
  bool _yukleniyor = true;

  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat(reverse: true);
    _araclariYukle();
    _asistaniBaslat();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _asistaniBaslat() async {
    final key = await ApiKeyService.geminiKeyOku();
    if (key != null && key.isNotEmpty) {
      _asistan.baslat(key);
    }
  }

  Future<void> _araclariYukle() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _yukleniyor = false);
      return;
    }

    final snap = await FirebaseFirestore.instance
        .collection('vehicles')
        .where('sahibiUid', isEqualTo: uid)
        .get();

    if (mounted) {
      setState(() {
        _araclar = snap.docs.map((d) => AracModel.fromMap(d.data(), d.id)).toList();
        _yukleniyor = false;
      });
    }
  }

  Future<void> _cikisYap() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildKurumsalAppBar(context),
      drawer: _buildKurumsalDrawer(context),
      body: Stack(
        children: [
          RefreshIndicator(
            color: primaryTeal,
            backgroundColor: surfaceColor,
            onRefresh: _araclariYukle,
            child: _yukleniyor
                ? Center(child: CircularProgressIndicator(color: primaryTeal, strokeWidth: 3))
                : ListView(
                    physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    padding: EdgeInsets.only(top: 20, bottom: 100),
                    children: [
                      _buildAraclarBolumu(),
                      SizedBox(height: 32),
                      _buildHizliIslemler(),
                      SizedBox(height: 32),
                      _buildAnaIslemlerListe(),
                    ],
                  ),
          ),
          // 🛡️ OTODNA ASİSTANI
          AsistanWidget(ekran: 'ana_sayfa', asistan: _asistan),
        ],
      ),
    );
  }

  // ── 1. ÜST BAR (Kurumsal Web Tarzı Temiz AppBar) ──
  PreferredSizeWidget _buildKurumsalAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: surfaceColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: primaryTeal), // Hamburger menü ikonu
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Color(0xFFF1F3F5), // Web tarzı açık gri arama kutusu
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: TextField(
          style: TextStyle(color: textMain, fontSize: 14, fontFamily: 'Avenir', fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: "OtoDNA'da işlemler, servisler...",
            hintStyle: TextStyle(color: textMuted.withOpacity(0.8), fontFamily: 'Avenir', fontSize: 13),
            prefixIcon: Icon(Icons.search, color: textMuted, size: 20),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 11), // Merkezi hizalama
          ),
        ),
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.notifications_none_rounded, color: primaryTeal, size: 26),
              onPressed: () {},
            ),
            if (_bildirimSayisi() > 0)
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(color: dangerColor, shape: BoxShape.circle, border: Border.all(color: surfaceColor, width: 1.5)),
                  child: Text('${_bildirimSayisi()}', style: TextStyle(color: SiberTema.textMain, fontSize: 7, fontWeight: FontWeight.bold)),
                ),
              )
          ],
        ),
        SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.0),
        child: Container(color: Colors.white.withOpacity(0.05), height: 1.0), // Zarif bir ayırıcı çizgi
      ),
    );
  }

  // ── 2. YAN MENÜ (Kurumsal Drawer) ──
  Widget _buildKurumsalDrawer(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = (user?.displayName ?? user?.email?.split('@').first ?? 'KULLANICI').toUpperCase();
    
    return Drawer(
      backgroundColor: surfaceColor,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
            decoration: BoxDecoration(
              color: primaryTeal,
              image: DecorationImage(
                image: AssetImage('assets/images/radar_grid.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.1), BlendMode.dstIn),
              )
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: primaryTeal, size: 36),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName, style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 1, fontSize: 16)),
                      SizedBox(height: 4),
                      Text(user?.email ?? '', style: TextStyle(color: SiberTema.textMain.withOpacity(0.8), fontSize: 11, fontFamily: 'Avenir')),
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 10),
              children: [
                _drawerItem(Icons.language, "Dil Seçenekleri (TR)"),
                _drawerItem(Icons.settings_outlined, "Hesap Ayarları"),
                _drawerItem(Icons.security_outlined, "Güvenlik & Gizlilik"),
                Divider(height: 30),
                _drawerItem(Icons.headset_mic_outlined, "Müşteri İletişim Merkezi"),
                _drawerItem(Icons.info_outline, "Hakkımızda & Sözleşmeler"),
              ],
            ),
          ),
          Divider(height: 1),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            leading: Icon(Icons.logout, color: dangerColor),
            title: Text("Güvenli Çıkış", style: TextStyle(color: dangerColor, fontWeight: FontWeight.bold, fontFamily: 'Avenir', fontSize: 14)),
            onTap: _cikisYap,
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon, color: textMuted, size: 22),
      title: Text(title, style: TextStyle(color: textMain, fontWeight: FontWeight.w600, fontFamily: 'Avenir', fontSize: 14)),
      trailing: Icon(Icons.arrow_forward_ios, size: 12, color: textMuted.withOpacity(0.5)),
      onTap: () {},
    );
  }

  // ── 3. ARAÇLARIM BÖLÜMÜ (Premium Kredi Kartı Görünümü) ──
  Widget _buildAraclarBolumu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Araçlarım", style: TextStyle(color: textMain, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 0.5)),
              GestureDetector(
                onTap: () => context.push('/arac_kayit'),
                child: Row(
                  children: [
                    Icon(Icons.add_circle, color: secondaryTeal, size: 16),
                    SizedBox(width: 4),
                    Text("Yeni Araç Ekle", style: TextStyle(color: secondaryTeal, fontSize: 13, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                  ],
                ),
              )
            ],
          ),
        ),
        SizedBox(height: 20),
        SizedBox(
          height: 190, // Kart yüksekliği biraz daha artırıldı
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: _araclar.isEmpty ? 1 : _araclar.length,
            itemBuilder: (ctx, i) {
              if (_araclar.isEmpty) return _buildAracYokKarti();
              return _buildPremiumAracKarti(_araclar[i]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumAracKarti(AracModel a) {
    return Container(
      width: 320,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [primaryTeal, Color(0xFF003D47)], // Çok derin, kurumsal lacivert/turkuaz
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: primaryTeal.withOpacity(0.25), blurRadius: 15, offset: Offset(0, 8)),
        ],
      ),
      child: Stack(
        children: [
          // Arka plan filigranı (Premium his)
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(Icons.directions_car, color: Colors.white.withOpacity(0.03), size: 150),
          ),
          Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.memory, color: Color(0xFFFFD700), size: 24), // Altın çip detayı
                        SizedBox(width: 8),
                        Text("OTODNA PLATINUM", style: TextStyle(color: SiberTema.textMain.withOpacity(0.6), fontSize: 9, letterSpacing: 2, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => context.push('/qr/${a.plaka}'), 
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Icon(Icons.qr_code_scanner, color: SiberTema.kuantumCyan, size: 16),
                      ),
                    )
                  ],
                ),
                Spacer(),
                Text(a.plaka.toUpperCase(), style: TextStyle(color: SiberTema.textMain, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 3, fontFamily: 'Avenir')),
                SizedBox(height: 4),
                Text('${a.marka} ${a.model}'.toUpperCase(), style: TextStyle(color: SiberTema.textMain.withOpacity(0.8), fontSize: 13, fontFamily: 'Avenir', fontWeight: FontWeight.w500)),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _premiumKartiDurum("ŞASE NO", a.saseNo.toUpperCase(), isMonospace: true),
                    _premiumKartiDurum("KASKO", _kalanGunMetni(a.kaskoBitis)),
                    _premiumKartiDurum("MUAYENE", _kalanGunMetni(a.muayeneBitis)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _premiumKartiDurum(String baslik, String deger, {bool isMonospace = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(baslik, style: TextStyle(color: SiberTema.textMain.withOpacity(0.5), fontSize: 8, letterSpacing: 1, fontFamily: 'Avenir')),
        SizedBox(height: 4),
        Text(deger, style: TextStyle(color: SiberTema.textMain, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: isMonospace ? 'monospace' : 'Avenir', letterSpacing: isMonospace ? 1 : 0)),
      ],
    );
  }

  String _kalanGunMetni(DateTime? tarih) {
    if (tarih == null) return "YOK";
    int gun = HatirlatmaService.kalanGun(tarih);
    if (gun < 0) return "GEÇTİ";
    return "$gun GÜN";
  }

  Widget _buildAracYokKarti() {
    return Container(
      width: 320,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textMuted.withOpacity(0.2), style: BorderStyle.solid),
        boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.03), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(Icons.add_directions_car, color: primaryTeal, size: 36),
          ),
          SizedBox(height: 16),
          Text("GARAJINIZ BOŞ", style: TextStyle(color: textMain, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1, fontFamily: 'Avenir')),
          SizedBox(height: 8),
          Text("OtoDNA'nın ayrıcalıklı dünyasına\nkatılmak için araç ekleyin.", textAlign: TextAlign.center, style: TextStyle(color: textMuted, fontSize: 12, fontFamily: 'Avenir', height: 1.5)),
        ],
      ),
    );
  }

  // ── 4. HIZLI İŞLEMLER (Varlıklarım / İşlemler Menüsü) ──
  Widget _buildHizliIslemler() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.03), blurRadius: 20, offset: Offset(0, 8))],
        border: Border.all(color: Colors.white.withOpacity(0.02))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kurumsalHizliIslem(Icons.build_circle, "Arıza Bildir"),
          _kurumsalHizliIslem(Icons.storefront, "Oto Market"),
          _kurumsalHizliIslem(Icons.directions_car, "Oto Galeri"),
          _kurumsalHizliIslem(Icons.handshake, "Servis"),
        ],
      ),
    );
  }

  Widget _kurumsalHizliIslem(IconData icon, String label) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.03)),
            ),
            child: Icon(icon, color: primaryTeal, size: 26),
          ),
          SizedBox(height: 10),
          Text(label, textAlign: TextAlign.center, style: TextStyle(color: textMain, fontSize: 11, fontWeight: FontWeight.w800, fontFamily: 'Avenir')),
        ],
      ),
    );
  }

  // ── 5. ANA İŞLEMLER DİZİLİMİ (OtoDNA Finans & İşlem Dünyası) ──
  Widget _buildAnaIslemlerListe() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("OtoDNA İşlemleri", style: TextStyle(color: textMain, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 0.5)),
          SizedBox(height: 20),
          _kurumsalIslemSatiri(Icons.gavel, "Siber Bilirkişi (AI)", "Adli Rapor & Kusur Hakemliği", isHighlight: true),
          _kurumsalIslemSatiri(Icons.document_scanner_outlined, "Ekspertiz Raporları", "Araç geçmişini detaylı sorgulayın"),
          _kurumsalIslemSatiri(Icons.calendar_month_outlined, "TÜVTÜRK İşlemleri", "Muayene randevusu ve hatırlatmalar"),
          _kurumsalIslemSatiri(Icons.shield_outlined, "Kasko & Sigorta", "Poliçe yenileme, teklif alma ve ödeme"),
          _kurumsalIslemSatiri(Icons.sos, "7/24 Acil Destek (SOS)", "Çekici ve yol yardım hizmetleri"),
        ],
      ),
    );
  }

  Widget _kurumsalIslemSatiri(IconData icon, String title, String subtitle, {bool isHighlight = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isHighlight ? secondaryTeal.withOpacity(0.3) : Colors.black.withOpacity(0.04)),
        boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.02), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isHighlight ? secondaryTeal.withOpacity(0.1) : bgColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: isHighlight ? secondaryTeal : primaryTeal, size: 24),
        ),
        title: Text(title, style: TextStyle(color: textMain, fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'Avenir')),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(subtitle, style: TextStyle(color: textMuted, fontSize: 11, fontFamily: 'Avenir')),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: textMuted.withOpacity(0.4)),
        onTap: () {},
      ),
    );
  }

  int _bildirimSayisi() {
    int sayac = 0;
    for (final a in _araclar) {
      if (HatirlatmaService.kalanGun(a.muayeneBitis) <= 30) sayac++;
      if (HatirlatmaService.kalanGun(a.sigortaBitis) <= 30) sayac++;
      if (HatirlatmaService.kalanGun(a.kaskoBitis) <= 30) sayac++;
    }
    return sayac;
  }
}