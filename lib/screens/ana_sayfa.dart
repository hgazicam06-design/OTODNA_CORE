import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  // 🌑 SİBER RENK PALETİ
  final Color bgColor = SiberTema.oledBlack;
  final Color surfaceColor = SiberTema.matGrey.withOpacity(0.1);
  final Color primaryCyan = SiberTema.kuantumCyan;

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

  @override
  Widget build(BuildContext context) {
    // 📡 SİBER SİCİL RADARI: Kullanıcının rolünü anlık izle
    final sicilAsync = ref.watch(siberSicilProvider);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          SafeArea(
            child: sicilAsync.when(
              data: (sicil) => Column(
                children: [
                  _buildUstBar(sicil),
                  Expanded(
                    child: _yukleniyor
                        ? Center(child: CircularProgressIndicator(color: primaryCyan, strokeWidth: 2))
                        : _buildIcerik(sicil),
                  ),
                ],
              ),
              loading: () => Center(child: CircularProgressIndicator(color: primaryCyan)),
              error: (err, stack) => Center(child: Text("SİNYAL KESİLDİ: $err", style: const TextStyle(color: Colors.red))),
            ),
          ),
          AsistanWidget(ekran: 'ana_sayfa', asistan: _asistan),
        ],
      ),
      bottomNavigationBar: _buildAltNav(),
    );
  }

  // ── 1. SİBER ÜST BAR (PERSONEL KİMLİK ALANI) ──
  Widget _buildUstBar(Map<String, dynamic>? sicil) {
    final user = FirebaseAuth.instance.currentUser;
    final rütbe = sicil?['rol']?.toString().toUpperCase() ?? "ER";

    return Padding(
    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
    child: Row(
    children: [
    _buildProfilIkonu(rütbe),
    const SizedBox(width: 16),
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text("RÜTBE: $rütbe", style: TextStyle(color: primaryCyan, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
    const SizedBox(height: 4),
    Text(
    (user?.displayName ?? user?.email?.split('@').first ?? 'BİLİNMEYEN').toUpperCase(),
    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5),
    ),
    ],
    ),
    ),
    _ikonButon(Icons.logout_rounded, () => FirebaseAuth.instance.signOut(), isDanger: true),
    ],
    ),
    );
  }

  Widget _buildProfilIkonu(String rütbe) {
  return Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
  color: surfaceColor,
  shape: BoxShape.circle,
  border: Border.all(color: primaryCyan.withOpacity(0.2)),
  boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.05), blurRadius: 20)]
  ),
  child: Icon(
  rütbe == "ADMIN" ? Icons.admin_panel_settings : Icons.person_pin,
  color: Colors.white, size: 24
  ),
  );
  }

  // ── 2. İÇERİK MOTORU ──
  Widget _buildIcerik(Map<String, dynamic>? sicil) {
  if (_aktifTab == 0) return _buildAnaSayfa(sicil);
  if (_aktifTab == 1) return _buildAraclarim();
  return _buildAyarlar();
  }

  Widget _buildAnaSayfa(Map<String, dynamic>? sicil) => RefreshIndicator(
  color: primaryCyan,
  onRefresh: _araclariYukle,
  child: ListView(
  physics: const BouncingScrollPhysics(),
  padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
  children: [
  if (_araclar.isEmpty) _buildAracYokKarti() else ...[
  for (final arac in _araclar) _buildAracKarti(arac),
  ],
  const SizedBox(height: 32),
  _buildHizliErisim(sicil),
  const SizedBox(height: 32),
  _buildHatirlatmalar(),
  ],
  ),
  );

  // ── 3. ARAÇ KARTI (KUANTUM MÜHÜRLÜ) ──
  Widget _buildAracKarti(AracModel a) => Container(
  margin: const EdgeInsets.only(bottom: 24),
  decoration: SiberTema.siberKutuDekorasyonu(isTrueBlack: true),
  child: Column(
  children: [
  ListTile(
  contentPadding: const EdgeInsets.all(20),
  leading: const Icon(Icons.directions_car_filled, color: Colors.white70, size: 32),
  title: Text('${a.marka} ${a.model}'.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
  subtitle: Text(a.plaka.toUpperCase(), style: TextStyle(color: primaryCyan.withOpacity(0.7), letterSpacing: 2)),
  trailing: IconButton(
  icon: const Icon(Icons.qr_code_2, color: Colors.white),
  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QrPublicScreen(saseNo: a.saseNo))),
  ),
  ),
  _buildKartAltBilgi(a.saseNo),
  ],
  ),
  );

  Widget _buildKartAltBilgi(String sase) => Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20))),
  child: Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
  const Icon(Icons.fingerprint, color: Colors.white24, size: 14),
  const SizedBox(width: 8),
  Text("DNA: $sase", style: const TextStyle(color: Colors.white24, fontSize: 10, fontFamily: 'monospace')),
  ],
  ),
  );

  // ── 4. HIZLI ERİŞİM (ROL BAZLI YETKİLENDİRME) ──
  Widget _buildHizliErisim(Map<String, dynamic>? sicil) {
  final rol = sicil?['rol'] ?? 'user';

  return Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
  _bolumBasligi('SİBER TERMİNAL'),
  const SizedBox(height: 16),
  Row(
  children: [
  _siberButon(Icons.add_moderator, 'KAYIT', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AracKayitScreen()))),
  const SizedBox(width: 12),
  // Sadece Bayi ve Admin görebilir
  if (rol == 'bayi' || rol == 'admin')
  _siberButon(Icons.build_circle, 'SERVİS', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OtoDnaKategoriMotoru()))),
  const SizedBox(width: 12),
  _siberButon(Icons.travel_explore, 'SORGULA', () {}),
  ],
  ),
  ],
  );
  }

  Widget _siberButon(IconData icon, String label, VoidCallback onTap) => Expanded(
  child: InkWell(
  onTap: onTap,
  borderRadius: BorderRadius.circular(20),
  child: Container(
  padding: const EdgeInsets.symmetric(vertical: 20),
  decoration: SiberTema.siberKutuDekorasyonu(),
  child: Column(
  children: [
  Icon(icon, color: primaryCyan, size: 26),
  const SizedBox(height: 8),
  Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold)),
  ],
  ),
  ),
  ),
  );

  // DİĞER YARDIMCI METODLAR (TEMA UYUMLU)
  Widget _bolumBasligi(String baslik) => Text(baslik, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2));

  Widget _ikonButon(IconData icon, VoidCallback onTap, {bool isDanger = false}) => GestureDetector(
  onTap: onTap,
  child: Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: isDanger ? Colors.red.withOpacity(0.3) : Colors.white10)),
  child: Icon(icon, color: isDanger ? Colors.redAccent : Colors.white, size: 20),
  ),
  );

  Widget _buildAracYokKarti() => Container(
  padding: const EdgeInsets.all(40),
  decoration: SiberTema.siberKutuDekorasyonu(),
  child: const Column(
  children: [
  Icon(Icons.cloud_off, color: Colors.white24, size: 48),
  SizedBox(height: 16),
  Text("AĞDA ARAÇ BULUNAMADI", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
  ],
  ),
  );

  Widget _buildAraclarim() => _buildAnaSayfa(null);
  Widget _buildAyarlar() => Center(child: Text("SİSTEM AYARLARI YÜKLENİYOR...", style: TextStyle(color: primaryCyan)));

  Widget _buildAltNav() => BottomNavigationBar(
  backgroundColor: bgColor,
  selectedItemColor: primaryCyan,
  unselectedItemColor: Colors.white24,
  currentIndex: _aktifTab,
  onTap: (i) => setState(() => _aktifTab = i),
  items: const [
  BottomNavigationBarItem(icon: Icon(Icons.radar), label: 'MERKEZ'),
  BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'GARAJ'),
  BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'AYARLAR'),
  ],
  );

  Widget _buildHatirlatmalar() => const SizedBox.shrink(); // Gerekirse doldurulacak
}