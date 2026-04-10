import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/arac_model.dart';
import '../services/api_key_service.dart';
import '../services/asistan_service.dart';
import '../services/hatirlatma_service.dart';
import '../widgets/asistan_widget.dart';
import 'arac_kayit_screen.dart';
import 'qr_public_screen.dart';

// ── YARDIMCI SINIF (Siber Uyarı Kalemi) ──
class _HatirlatmaItem {
  final String plaka;
  final String tur;
  final DateTime tarih;
  final IconData icon;

  _HatirlatmaItem({
    required this.plaka,
    required this.tur,
    required this.tarih,
    required this.icon,
  });
}

class AnaEkran extends StatefulWidget {
  const AnaEkran({super.key});

  @override
  State<AnaEkran> createState() => _AnaEkranState();
}

class _AnaEkranState extends State<AnaEkran> with TickerProviderStateMixin {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  final Color bgColor = const Color(0xFF000000);
  final Color surfaceColor = const Color(0xFF0A0A0A);
  final Color cardColor = const Color(0xFF111111);
  final Color primaryCyan = const Color(0xFF00FFC2);

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
    if (uid == null) {
      if (mounted) setState(() => _yukleniyor = false);
      return;
    }

    // 🔥 GERÇEK VERİ AKIŞI: Firebase üzerinden araçları mühürlüyoruz
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
      body: Stack(
        children: [
          // Arka Plan Radar Izgarası Simülasyonu
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: Image.asset('assets/images/radar_grid.png', fit: BoxFit.cover), // Eğer dosya yoksa siyah kalır, hata vermez
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildUstBar(),
                Expanded(
                  child: _yukleniyor
                      ? Center(child: CircularProgressIndicator(color: primaryCyan, strokeWidth: 2))
                      : _buildIcerik(),
                ),
              ],
            ),
          ),
          // 🛡️ OTODNA ASİSTANI (Görünmez Kalkan)
          AsistanWidget(ekran: 'ana_sayfa', asistan: _asistan),
        ],
      ),
      bottomNavigationBar: _buildAltNav(),
    );
  }

  // ── 1. SİBER ÜST BAR (Tesla Profil & Bildirim Hattı) ──
  Widget _buildUstBar() {
    final user = FirebaseAuth.instance.currentUser;
    final saat = DateTime.now().hour;
    final selamlama = saat < 12 ? 'SİSTEM AKTİF: GÜNAYDIN' : saat < 18 ? 'SİSTEM AKTİF: İYİ GÜNLER' : 'SİSTEM AKTİF: İYİ AKŞAMLAR';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: surfaceColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.05)),
                boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.05), blurRadius: 20)]
            ),
            child: const Icon(Icons.fingerprint, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(selamlama, style: TextStyle(color: primaryCyan.withOpacity(0.8), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                const SizedBox(height: 4),
                Text(
                  (user?.displayName ?? user?.email?.split('@').first ?? 'KULLANICI').toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _ikonButon(Icons.notifications_none_rounded, () {}, badge: _bildirimSayisi()),
          const SizedBox(width: 12),
          _ikonButon(Icons.logout_rounded, _cikisYap, isDanger: true),
        ],
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

  Widget _ikonButon(IconData icon, VoidCallback onTap, {int badge = 0, bool isDanger = false}) {
    Color ikonRengi = isDanger ? Colors.redAccent : Colors.white70;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Icon(icon, color: ikonRengi, size: 20),
          ),
        ),
        if (badge > 0)
          Positioned(
            right: -4, top: -4,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(color: primaryCyan, shape: BoxShape.circle, border: Border.all(color: bgColor, width: 2)),
              child: Text('$badge', style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w900)),
            ),
          ),
      ],
    );
  }

  // ── 2. İÇERİK MOTORU (Sekme Yönetimi) ──
  Widget _buildIcerik() {
    switch (_aktifTab) {
      case 0: return _buildAnaSayfa();
      case 1: return _buildGarajSayfasi();
      case 2: return _buildAyarlarSayfasi();
      default: return _buildAnaSayfa();
    }
  }

  Widget _buildAnaSayfa() => RefreshIndicator(
    color: primaryCyan,
    backgroundColor: surfaceColor,
    onRefresh: _araclariYukle,
    child: ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
      children: [
        if (_araclar.isEmpty) _buildAracYokKarti() else ...[
          // En son eklenen veya muayenesi en yakın aracı öne çıkarıyoruz
          _buildAracKarti(_araclar.first),
        ],
        const SizedBox(height: 32),
        _buildHizliErisim(),
        const SizedBox(height: 32),
        _buildHatirlatmalar(),
      ],
    ),
  );

  Widget _buildGarajSayfasi() => ListView(
    physics: const BouncingScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
    children: [
      _bolumBasligi('TÜM ARAÇLARINIZ'),
      const SizedBox(height: 16),
      if (_araclar.isEmpty) _buildAracYokKarti() else
        for (final arac in _araclar) _buildAracKarti(arac),
    ],
  );

  Widget _buildAyarlarSayfasi() => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      _bolumBasligi('HESAP AYARLARI'),
      const SizedBox(height: 20),
      _ayarlarSatiri(Icons.person_outline, "Profil Bilgileri"),
      _ayarlarSatiri(Icons.security_outlined, "Güvenlik Duvarı"),
      _ayarlarSatiri(Icons.language_outlined, "Bölge/Dil: Türkiye"),
      const SizedBox(height: 32),
      _bolumBasligi('SİSTEM'),
      const SizedBox(height: 20),
      _ayarlarSatiri(Icons.info_outline, "Versiyon 1.0.4-Kuantum"),
      _ayarlarSatiri(Icons.bug_report_outlined, "Hata Raporla", isDanger: true),
    ],
  );

  Widget _ayarlarSatiri(IconData icon, String title, {bool isDanger = false}) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16)),
    child: Row(
      children: [
        Icon(icon, color: isDanger ? Colors.redAccent : primaryCyan, size: 20),
        const SizedBox(width: 16),
        Text(title, style: TextStyle(color: isDanger ? Colors.redAccent : Colors.white, fontWeight: FontWeight.bold)),
        const Spacer(),
        const Icon(Icons.arrow_forward_ios, color: Colors.white10, size: 14),
      ],
    ),
  );

  // ── 3. ARAÇ YOK KARTI (Premium Boş Garaj) ──
  Widget _buildAracYokKarti() => GestureDetector(
    onTap: () async {
      final sonuc = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AracKayitScreen()));
      if (sonuc == true) _araclariYukle();
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
        boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.02), blurRadius: 40)],
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) => Transform.scale(
              scale: 0.98 + 0.02 * _pulseCtrl.value,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryCyan.withOpacity(0.02),
                  border: Border.all(color: primaryCyan.withOpacity(0.1 + 0.1 * _pulseCtrl.value)),
                ),
                child: const Icon(Icons.blur_on, color: primaryCyan, size: 48),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text('GARAJINIZ BOŞ', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 12),
          const Text(
            'OtoDNA Siber Ağına bağlanmak ve aracınızın genetik kodunu oluşturmak için ilk kaydınızı yapın.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.6),
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(color: primaryCyan, borderRadius: BorderRadius.circular(16)),
            child: const Center(child: Text('ARACINI MÜHÜRLE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5))),
          ),
        ],
      ),
    ),
  );

  // ── 4. ARAÇ KARTI (Tesla Model Kimlik Kartı) ──
  Widget _buildAracKarti(AracModel a) => Container(
    margin: const EdgeInsets.only(bottom: 24),
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(32),
      border: Border.all(color: Colors.white.withOpacity(0.03)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10))],
    ),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
                child: const Icon(Icons.directions_car_outlined, color: Colors.white70, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${a.marka} ${a.model}'.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.5), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFF0038A8), borderRadius: BorderRadius.circular(4)),
                          child: const Text("TR", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Text(a.plaka.toUpperCase(), style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.5)),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QrPublicScreen(saseNo: a.saseNo))),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: primaryCyan.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryCyan.withOpacity(0.3))),
                  child: const Icon(Icons.qr_code_scanner_rounded, color: primaryCyan, size: 20),
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              _durumCip('MUAYENE', a.muayeneBitis),
              const SizedBox(width: 12),
              _durumCip('SİGORTA', a.sigortaBitis),
              const SizedBox(width: 12),
              _durumCip('KASKO', a.kaskoBitis),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(color: surfaceColor, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)), border: Border(top: BorderSide(color: Colors.white.withOpacity(0.02)))),
          child: Row(
            children: [
              const Icon(Icons.memory, color: Colors.white24, size: 16),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("SİBER GENETİK KOD (ŞASİ)", style: TextStyle(color: Colors.white24, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text(a.saseNo.toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'monospace', letterSpacing: 2, fontWeight: FontWeight.bold)),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: a.saseNo));
                  HapticFeedback.mediumImpact();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Siber Genetik Kod Kopyalandı', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)), backgroundColor: primaryCyan));
                },
                child: const Icon(Icons.copy_rounded, color: primaryCyan, size: 18),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _durumCip(String etiket, DateTime? tarih) {
    final gun = HatirlatmaService.kalanGun(tarih);
    final renk = gun < 0 ? Colors.redAccent : gun <= 15 ? Colors.redAccent : gun <= 30 ? Colors.orangeAccent : Colors.white;
    final metin = tarih == null ? 'YOK' : gun < 0 ? 'GEÇTİ' : '$gun GÜN';

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: bgColor,
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Text(etiket, style: const TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
            const SizedBox(height: 6),
            Text(metin, style: TextStyle(color: renk, fontSize: 12, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  // ── 5. HIZLI ERİŞİM (Kuantum Menü) ──
  Widget _buildHizliErisim() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _bolumBasligi('SİBER TERMİNAL'),
      const SizedBox(height: 16),
      Row(
        children: [
          _siberButon(Icons.add_moderator_outlined, 'MÜHÜRLE', () async {
            final s = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AracKayitScreen()));
            if (s == true) _araclariYukle();
          }),
          const SizedBox(width: 12),
          _siberButon(Icons.build_circle_outlined, 'SERVİS', () {}),
          const SizedBox(width: 12),
          _siberButon(Icons.manage_search_rounded, 'SORGULA', () {}),
        ],
      ),
    ],
  );

  Widget _siberButon(IconData icon, String label, VoidCallback onTap) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.03)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white70, size: 24),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ],
        ),
      ),
    ),
  );

  // ── 6. HATIRLATMALAR (Siber Log Kayıtları) ──
  Widget _buildHatirlatmalar() {
    final hatirlatmalar = <_HatirlatmaItem>[];
    for (final a in _araclar) {
      if (a.muayeneBitis != null && HatirlatmaService.kalanGun(a.muayeneBitis) <= 30) hatirlatmalar.add(_HatirlatmaItem(plaka: a.plaka, tur: 'MUAYENE', tarih: a.muayeneBitis!, icon: Icons.car_crash_outlined));
      if (a.sigortaBitis != null && HatirlatmaService.kalanGun(a.sigortaBitis) <= 30) hatirlatmalar.add(_HatirlatmaItem(plaka: a.plaka, tur: 'SİGORTA', tarih: a.sigortaBitis!, icon: Icons.shield_outlined));
      if (a.kaskoBitis != null && HatirlatmaService.kalanGun(a.kaskoBitis) <= 30) hatirlatmalar.add(_HatirlatmaItem(plaka: a.plaka, tur: 'KASKO', tarih: a.kaskoBitis!, icon: Icons.security_outlined));
    }

    if (hatirlatmalar.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _bolumBasligi('SİSTEM UYARILARI'),
        const SizedBox(height: 16),
        for (final h in hatirlatmalar) _hatirlatmaKarti(h),
      ],
    );
  }

  Widget _hatirlatmaKarti(_HatirlatmaItem h) {
    final gun = HatirlatmaService.kalanGun(h.tarih);
    final renk = gun <= 0 ? Colors.redAccent : gun <= 15 ? Colors.redAccent : Colors.orangeAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: surfaceColor,
        border: Border.all(color: renk.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: renk.withOpacity(0.1), shape: BoxShape.circle), child: Icon(h.icon, color: renk, size: 20)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${h.plaka.toUpperCase()} — ${h.tur}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text('${h.tarih.day.toString().padLeft(2, '0')}.${h.tarih.month.toString().padLeft(2, '0')}.${h.tarih.year}', style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
            ]),
          ),
          Text(gun < 0 ? 'GEÇTİ' : '$gun GÜN', style: TextStyle(color: renk, fontSize: 14, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _bolumBasligi(String baslik) {
    return Text(baslik, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2));
  }

  // ── 7. ALT NAVİGASYON (Siber Bar) ──
  Widget _buildAltNav() {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: primaryCyan,
        unselectedItemColor: Colors.white24,
        selectedLabelStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
        unselectedLabelStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
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
}