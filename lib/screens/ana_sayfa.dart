import 'package:otodna_app/screens/usta_paneli/dinamik_kategori_ekrani.dart';
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

// ── YARDIMCI SINIF ──
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
          AsistanWidget(ekran: 'ana_sayfa', asistan: _asistan),
        ],
      ),
      bottomNavigationBar: _buildAltNav(),
    );
  }

  // ── 1. SİBER ÜST BAR (TESLA PROFİL ALANI) ──
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
    Color ikonRengi = isDanger ? Colors.redAccent.withOpacity(0.8) : Colors.white70;

    return Stack(
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
            right: -2, top: -2,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(color: primaryCyan, shape: BoxShape.circle, border: Border.all(color: bgColor, width: 2)),
              child: Text('$badge', style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w900)),
            ),
          ),
      ],
    );
  }

  // ── 2. İÇERİK MOTORU ──
  Widget _buildIcerik() {
    if (_aktifTab == 0) return _buildAnaSayfa();
    if (_aktifTab == 1) return _buildAraclarim();
    return _buildAyarlar();
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
          for (final arac in _araclar) _buildAracKarti(arac),
        ],
        const SizedBox(height: 32),
        _buildHizliErisim(),
        const SizedBox(height: 32),
        _buildHatirlatmalar(),
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
          _siberButon(Icons.add_security_rounded, 'ARAÇ EKLE', () async {
            final s = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AracKayitScreen()));
            if (s == true) _araclariYukle();
          }),
          const SizedBox(width: 12),
          // İŞTE YENİ USTA PANELİ GEÇİŞ BUTONU! 🚀
          _siberButon(Icons.build_circle_outlined, 'SERVİS', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const OtoDnaKategoriMotoru()));
          }),
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
            Icon(icon, color: primaryCyan, size: 24),
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

  // ── 7. ARAÇLARIM VE AYARLAR SEKMELERİ ──
  Widget _buildAraclarim() => ListView(
    physics: const BouncingScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
    children: [
      for (final a in _araclar) _buildAracKarti(a),
      const SizedBox(height: 16),
      GestureDetector(
        onTap: () async {
          final s = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AracKayitScreen()));
          if (s == true) _araclariYukle();
        },
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: primaryCyan.withOpacity(0.05),
            border: Border.all(color: primaryCyan.withOpacity(0.3), style: BorderStyle.solid),
          ),
          child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_security_rounded, color: primaryCyan, size: 20),
                SizedBox(width: 12),
                Text('YENİ ARAÇ MÜHÜRLE', style: TextStyle(color: primaryCyan, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
              ]),
        ),
      ),
    ],
  );

  Widget _buildAyarlar() {
    final user = FirebaseAuth.instance.currentUser;
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: surfaceColor,
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: primaryCyan.withOpacity(0.4))),
              child: const Icon(Icons.person_outline, color: primaryCyan, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  (user?.displayName ?? user?.email?.split('@').first ?? 'KULLANICI').toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(user?.email ?? '', style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
              ]),
            ),
          ]),
        ),
        _ayarSatiri(Icons.smart_toy_rounded, 'GEMİNİ YAPAY ZEKA BAĞLANTISI', _geminiKeyAyarla),
        _ayarSatiri(Icons.notifications_outlined, 'BİLDİRİM PROTOKOLLERİ', () {}),
        _ayarSatiri(Icons.security_outlined, 'SİBER GÜVENLİK AYARLARI', () {}),
        _ayarSatiri(Icons.help_outline, 'MERKEZ DESTEK HATTI', () {}),
        const SizedBox(height: 16),
        _ayarSatiri(Icons.power_settings_new, 'SİSTEMDEN GÜVENLİ ÇIKIŞ', _cikisYap, renk: Colors.redAccent),
      ],
    );
  }

  // Gemini API Anahtarı Ayar Ekranı (Kuantum Modal)
  Future<void> _geminiKeyAyarla() async {
    final mevcut = await ApiKeyService.geminiKeyOku();
    final ctrl = TextEditingController(text: mevcut ?? '');
    bool gizle = true;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          backgroundColor: surfaceColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: primaryCyan.withOpacity(0.5))),
          title: const Row(children: [
            Icon(Icons.smart_toy_outlined, color: primaryCyan, size: 24),
            SizedBox(width: 12),
            Text('YAPAY ZEKA BAĞLANTISI', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ]),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text(
              'OtoDNA Asistanını aktifleştirmek için Google AI Studio üzerinden aldığınız anahtarı mühürleyin.',
              style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.5),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: ctrl,
              obscureText: gizle,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'monospace', letterSpacing: 1),
              decoration: InputDecoration(
                hintText: 'AIzaSy...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 13),
                filled: true,
                fillColor: bgColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primaryCyan)),
                suffixIcon: IconButton(
                  icon: Icon(gizle ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.white38, size: 20),
                  onPressed: () => setDlg(() => gizle = !gizle),
                ),
              ),
            ),
          ]),
          actionsPadding: const EdgeInsets.only(right: 24, bottom: 24),
          actions: [
            if (mevcut != null)
              TextButton(
                onPressed: () async {
                  await ApiKeyService.geminiKeySil();
                  _asistan.sifirla();
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yapay Zeka Devre Dışı Bırakıldı.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: Colors.redAccent));
                },
                child: const Text('AĞDAN KOPAR', style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryCyan, foregroundColor: Colors.black, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () async {
                final key = ctrl.text.trim();
                if (key.isEmpty) return;
                await ApiKeyService.geminiKeyKaydet(key);
                _asistan.baslat(key);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yapay Zeka Ağa Bağlandı! 🚀', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: primaryCyan));
              },
              child: const Text('SİBER MÜHÜR VUR', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ayarSatiri(IconData icon, String baslik, VoidCallback onTap, {Color renk = Colors.white}) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: surfaceColor,
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(children: [
        Icon(icon, color: renk == Colors.white ? Colors.white54 : renk, size: 20),
        const SizedBox(width: 16),
        Expanded(child: Text(baslik, style: TextStyle(color: renk, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1))),
        Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.2), size: 20),
      ]),
    ),
  );

  // ── 8. ALT MENÜ VE NAVİGASYON (Siber Bar) ──
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