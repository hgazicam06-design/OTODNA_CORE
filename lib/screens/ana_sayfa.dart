import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

// 🔥 SİBER KÖPRÜLER VE TEMA
import '../core/siber_tema.dart';
import '../core/providers/siber_kimlik_provider.dart';
import 'usta_paneli/dinamik_kategori_ekrani.dart';
import '../models/arac_model.dart';
import '../services/api_key_service.dart';
import '../services/asistan_service.dart';
import '../services/hatirlatma_service.dart';
import '../widgets/asistan_widget.dart';
import 'arac_kayit_screen.dart';
import 'qr_public_screen.dart';

class AnaEkran extends ConsumerStatefulWidget {
  const AnaEkran({super.key});

  @override
  ConsumerState<AnaEkran> createState() => _AnaEkranState();
}

class _AnaEkranState extends ConsumerState<AnaEkran> with TickerProviderStateMixin {
  // 🏢 ULTRA PROFESYONEL KURUMSAL PALET (Kurumsal Web Sitesi Esintisi)
  final Color bgColor = const Color(0xFFF4F6F8);
  final Color surfaceColor = Colors.white;
  final Color primaryTeal = const Color(0xFF005A64);
  final Color secondaryTeal = const Color(0xFF009688);
  final Color textMain = const Color(0xFF1E293B);
  final Color textMuted = const Color(0xFF64748B);
  final Color dangerColor = const Color(0xFFD32F2F);

  final _asistan = AsistanService();
  List<AracModel> _araclar = [];
  bool _yukleniyor = true;
  int _aktifTab = 0;

  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
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
    if (uid == null) return;

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
    // 📡 SİBER SİCİL RADARI: Kullanıcının rolünü anlık izle
    final sicilAsync = ref.watch(siberSicilProvider);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildKurumsalAppBar(context, sicilAsync.valueOrNull),
      drawer: _buildKurumsalDrawer(context, sicilAsync.valueOrNull),
      body: Stack(
        children: [
          SafeArea(
            child: sicilAsync.when(
              data: (sicil) => RefreshIndicator(
                color: primaryTeal,
                backgroundColor: surfaceColor,
                onRefresh: _araclariYukle,
                child: _yukleniyor
                    ? Center(child: CircularProgressIndicator(color: primaryTeal, strokeWidth: 3))
                    : _buildIcerik(sicil),
              ),
              loading: () => Center(child: CircularProgressIndicator(color: primaryTeal)),
              error: (err, stack) => Center(child: Text("SİNYAL KESİLDİ: $err", style: TextStyle(color: dangerColor))),
            ),
          ),
          AsistanWidget(ekran: 'ana_sayfa', asistan: _asistan),
        ],
      ),
      bottomNavigationBar: _buildAltNav(),
    );
  }

  // ── 1. ÜST BAR (Kurumsal Arama ve Bildirimler) ──
  PreferredSizeWidget _buildKurumsalAppBar(BuildContext context, Map<String, dynamic>? sicil) {
    return AppBar(
      backgroundColor: surfaceColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: primaryTeal),
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: TextField(
          style: TextStyle(color: textMain, fontSize: 14, fontFamily: 'Avenir', fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: "OtoDNA'da işlemler, araçlar...",
            hintStyle: TextStyle(color: textMuted.withOpacity(0.8), fontFamily: 'Avenir', fontSize: 13),
            prefixIcon: Icon(Icons.search, color: textMuted, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 11),
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
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: dangerColor, shape: BoxShape.circle, border: Border.all(color: surfaceColor, width: 1.5)),
                  child: Text('${_bildirimSayisi()}', style: const TextStyle(color: SiberTema.textMain, fontSize: 7, fontWeight: FontWeight.bold)),
                ),
              )
          ],
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: Colors.white.withOpacity(0.05), height: 1.0),
      ),
    );
  }

  // ── 2. YAN MENÜ (Kurumsal Drawer) ──
  Widget _buildKurumsalDrawer(BuildContext context, Map<String, dynamic>? sicil) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = (user?.displayName ?? user?.email?.split('@').first ?? 'KULLANICI').toUpperCase();
    final rütbe = sicil?['rol']?.toString().toUpperCase() ?? "ER";
    
    return Drawer(
      backgroundColor: surfaceColor,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
            decoration: BoxDecoration(
              color: primaryTeal,
              image: DecorationImage(
                image: const AssetImage('assets/images/radar_grid.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.1), BlendMode.dstIn),
              )
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(rütbe == "ADMIN" ? Icons.admin_panel_settings : Icons.person_pin, color: primaryTeal, size: 36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName, style: const TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 1, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text("RÜTBE: $rütbe", style: TextStyle(color: secondaryTeal, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                _drawerItem(Icons.language, "Dil Seçenekleri (TR)"),
                _drawerItem(Icons.settings_outlined, "Hesap Ayarları"),
                _drawerItem(Icons.security_outlined, "Güvenlik & Gizlilik"),
                const Divider(height: 30),
                _drawerItem(Icons.headset_mic_outlined, "Müşteri İletişim Merkezi"),
                _drawerItem(Icons.info_outline, "Hakkımızda & Sözleşmeler"),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            leading: Icon(Icons.logout, color: dangerColor),
            title: Text("Güvenli Çıkış", style: TextStyle(color: dangerColor, fontWeight: FontWeight.bold, fontFamily: 'Avenir', fontSize: 14)),
            onTap: _cikisYap,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon, color: textMuted, size: 22),
      title: Text(title, style: TextStyle(color: textMain, fontWeight: FontWeight.w600, fontFamily: 'Avenir', fontSize: 14)),
      trailing: Icon(Icons.arrow_forward_ios, size: 12, color: textMuted.withOpacity(0.5)),
      onTap: () {},
    );
  }

  // ── 2. İÇERİK MOTORU ──
  Widget _buildIcerik(Map<String, dynamic>? sicil) {
    if (_aktifTab == 0) return _buildAnaSayfaBolumu(sicil);
    if (_aktifTab == 1) return _buildAraclarim();
    return _buildAyarlar();
  }

  Widget _buildAnaSayfaBolumu(Map<String, dynamic>? sicil) => ListView(
    physics: const BouncingScrollPhysics(),
    padding: const EdgeInsets.only(top: 20, bottom: 120),
    children: [
      _buildAraclarBolumu(),
      const SizedBox(height: 32),
      _buildHizliErisim(sicil),
      const SizedBox(height: 32),
      _buildAnaIslemlerListe(),
    ],
  );

  // ── 3. ARAÇLARIM BÖLÜMÜ (Premium Kredi Kartı Görünümü) ──
  Widget _buildAraclarBolumu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Araçlarım", style: TextStyle(color: textMain, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 0.5)),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AracKayitScreen())),
                child: Row(
                  children: [
                    Icon(Icons.add_circle, color: secondaryTeal, size: 16),
                    const SizedBox(width: 4),
                    Text("Yeni Araç Ekle", style: TextStyle(color: secondaryTeal, fontSize: 13, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [primaryTeal, const Color(0xFF003D47)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: primaryTeal.withOpacity(0.25), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(Icons.directions_car, color: Colors.white.withOpacity(0.03), size: 150),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.memory, color: Color(0xFFFFD700), size: 24),
                        const SizedBox(width: 8),
                        Text("OTODNA PLATINUM", style: TextStyle(color: SiberTema.textMain.withOpacity(0.6), fontSize: 9, letterSpacing: 2, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QrPublicScreen(saseNo: a.saseNo))),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.qr_code_scanner, color: SiberTema.kuantumCyan, size: 16),
                      ),
                    )
                  ],
                ),
                const Spacer(),
                Text(a.plaka.toUpperCase(), style: const TextStyle(color: SiberTema.textMain, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 3, fontFamily: 'Avenir')),
                const SizedBox(height: 4),
                Text('${a.marka} ${a.model}'.toUpperCase(), style: TextStyle(color: SiberTema.textMain.withOpacity(0.8), fontSize: 13, fontFamily: 'Avenir', fontWeight: FontWeight.w500)),
                const SizedBox(height: 16),
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
        const SizedBox(height: 4),
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
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textMuted.withOpacity(0.2), style: BorderStyle.solid),
        boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(Icons.add_directions_car, color: primaryTeal, size: 36),
          ),
          const SizedBox(height: 16),
          Text("GARAJINIZ BOŞ", style: TextStyle(color: textMain, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1, fontFamily: 'Avenir')),
          const SizedBox(height: 8),
          Text("OtoDNA'nın ayrıcalıklı dünyasına\nkatılmak için araç ekleyin.", textAlign: TextAlign.center, style: TextStyle(color: textMuted, fontSize: 12, fontFamily: 'Avenir', height: 1.5)),
        ],
      ),
    );
  }

  // ── 4. HIZLI İŞLEMLER (Varlıklarım / İşlemler Menüsü) ──
  Widget _buildHizliErisim(Map<String, dynamic>? sicil) {
    final rol = sicil?['rol'] ?? 'user';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 8))],
        border: Border.all(color: Colors.white.withOpacity(0.02))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kurumsalHizliIslem(Icons.build_circle, "Arıza Bildir", () {}),
          _kurumsalHizliIslem(Icons.storefront, "Oto Market", () {}),
          _kurumsalHizliIslem(Icons.directions_car, "Oto Galeri", () {}),
          if (rol == 'bayi' || rol == 'admin')
            _kurumsalHizliIslem(Icons.handshake, "Servis", () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const OtoDnaKategoriMotoru()));
            }),
        ],
      ),
    );
  }

  Widget _kurumsalHizliIslem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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
          const SizedBox(height: 10),
          Text(label, textAlign: TextAlign.center, style: TextStyle(color: textMain, fontSize: 11, fontWeight: FontWeight.w800, fontFamily: 'Avenir')),
        ],
      ),
    );
  }

  // ── 5. ANA İŞLEMLER DİZİLİMİ (OtoDNA Finans & İşlem Dünyası) ──
  Widget _buildAnaIslemlerListe() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("OtoDNA İşlemleri", style: TextStyle(color: textMain, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 0.5)),
          const SizedBox(height: 20),
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
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isHighlight ? secondaryTeal.withOpacity(0.3) : Colors.black.withOpacity(0.04)),
        boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isHighlight ? secondaryTeal.withOpacity(0.1) : bgColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: isHighlight ? secondaryTeal : primaryTeal, size: 24),
        ),
        title: Text(title, style: TextStyle(color: textMain, fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'Avenir')),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle, style: TextStyle(color: textMuted, fontSize: 11, fontFamily: 'Avenir')),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: textMuted.withOpacity(0.4)),
        onTap: () {},
      ),
    );
  }

  Widget _buildAraclarim() => _buildAnaSayfaBolumu(null);
  Widget _buildAyarlar() => Center(child: Text("SİSTEM AYARLARI", style: TextStyle(color: primaryTeal)));

  int _bildirimSayisi() {
    int sayac = 0;
    for (final a in _araclar) {
      if (HatirlatmaService.kalanGun(a.muayeneBitis) <= 30) sayac++;
      if (HatirlatmaService.kalanGun(a.sigortaBitis) <= 30) sayac++;
      if (HatirlatmaService.kalanGun(a.kaskoBitis) <= 30) sayac++;
    }
    return sayac;
  }

  Widget _buildAltNav() => Container(
    decoration: BoxDecoration(
      color: surfaceColor,
      border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))]
    ),
    child: BottomNavigationBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      selectedItemColor: primaryTeal,
      unselectedItemColor: textMuted.withOpacity(0.5),
      selectedLabelStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir'),
      unselectedLabelStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir'),
      currentIndex: _aktifTab,
      onTap: (i) => setState(() => _aktifTab = i),
      items: const [
        BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.radar)), label: 'MERKEZ'),
        BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.directions_car_outlined)), label: 'GARAJ'),
        BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.settings_outlined)), label: 'AYARLAR'),
      ],
    ),
  );
}