import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

// 🔥 SİBER KÖPRÜLER
import 'admin_onay_havuzu_screen.dart';
import 'admin_dash_ui.dart';
import '../screens/bayi_itibar_merkezi_screen.dart';
import '../screens/bayi_yonetim_merkezi_screen.dart';
import '../screens/bolge_komuta_merkezi_screen.dart';
import '../screens/mega_revizyon_screen.dart';
import '../screens/bayi_paneli.dart';
import '../screens/kullanici_yonetim_screen.dart';
import '../screens/bayi_ekosistemi_screen.dart';

class AdminControlCenter extends StatelessWidget {
  const AdminControlCenter({super.key});

  Future<void> _siberCikisYap() async {
    await FirebaseAuth.instance.signOut();
  }

  void _sistemAyarMenuAc(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _SistemAyarlariTerminali(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text("OTODNA MERKEZ KARARGAHI", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1.5, fontFamily: 'Avenir')),
          centerTitle: true,
          actions: [IconButton(icon: const Icon(Icons.power_settings_new, color: SiberTema.kanKirmizi), onPressed: _siberCikisYap, tooltip: "Ağdan Çıkış Yap")],
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            _buildPanelBaslik("SİBER FİNANS (KARARGAH)"),
            const SizedBox(height: 12),
            _canliFinansRadari(),
            const SizedBox(height: 30),

            _buildPanelBaslik("SİSTEM KONTROL MODÜLLERİ"),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 15, // 🔥 3D kartlar için daha fazla boşluk
              mainAxisSpacing: 15,
              childAspectRatio: 0.85,
              children: [
                _buildSiberMenuKarti(context, "BÖLGE\nRADARI", Icons.radar, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BolgeKomutaMerkeziScreen()))),
                _buildSiberMenuKarti(context, "BAYİ\nAĞI", Icons.add_business, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BayiYonetimMerkeziScreen()))),
                _buildSiberMenuKarti(context, "İTİBAR\nSİCİL", Icons.shield, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BayiItibarMerkeziScreen()))),
                _buildSiberMenuKarti(context, "BAYİ\nKOKPİTİ", Icons.store_mall_directory, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BayiPaneliScreen(bayiId: "TEST_BAYI_001")))),
                _buildSiberMenuKarti(context, "KULLANICI\nYETKİ", Icons.people_alt, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KullaniciYonetimScreen()))),
                _buildSiberMenuKarti(context, "ONAY\nHAVUZU", Icons.verified_user, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminOnayHavuzuScreen()))),
                _buildSiberMenuKarti(context, "MEGA\nREVİZYON", Icons.build_circle, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MegaRevizyonScreen(plaka: "KARARGAH-GİRİŞİ")))),
                _buildSiberMenuKarti(context, "EKSPERTİZ\nDNA", Icons.fact_check, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BayiEkosistemiScreen()))),
                _buildSiberMenuKarti(context, "KASA\n& SOS", Icons.dashboard_customize, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashUI()))),
                _buildSiberMenuKarti(context, "SİSTEM\nAYARLARI", Icons.tune, () => _sistemAyarMenuAc(context), isOzel: true),
              ],
            ),
            const SizedBox(height: 30),

            _buildPanelBaslik("CANLI AĞ HAREKETLERİ"),
            const SizedBox(height: 12),
            Container(
              height: 220,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: SiberTema.matGrey, // 🔥 3D Zemin Rengi
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
                  boxShadow: SiberTema.siberGolgeDerin // 🔥 3D GÖLGE EKLENDİ
              ),
              child: _canliHareketListesi(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelBaslik(String baslik) {
    return Row(
      children: [
        const Icon(Icons.memory, color: SiberTema.kuantumCyan, size: 18),
        const SizedBox(width: 8),
        Text(baslik, style: TextStyle(color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w800, letterSpacing: 1.5, fontSize: 12, fontFamily: 'Avenir')),
      ],
    );
  }

  Widget _buildSiberMenuKarti(BuildContext context, String baslik, IconData ikon, VoidCallback onTap, {bool isOzel = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
            color: SiberTema.matGrey, // 🔥 Gradient yerine solid renk, üstüne 3D gölge!
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isOzel ? SiberTema.altinSari.withOpacity(0.5) : Colors.white.withOpacity(0.1), width: isOzel ? 1.5 : 1),
            boxShadow: SiberTema.siberGolgeDerin // 🔥 EFSANE 3D GÖLGE BURADA
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: isOzel ? SiberTema.altinSari.withOpacity(0.1) : SiberTema.kuantumCyan.withOpacity(0.05),
                    shape: BoxShape.circle,
                    border: Border.all(color: isOzel ? SiberTema.altinSari.withOpacity(0.5) : SiberTema.kuantumCyan.withOpacity(0.2)),
                    // 🔥 İKONUN ARKASINA DA DERİNLİK KATALIM
                    boxShadow: [BoxShadow(color: isOzel ? SiberTema.altinSari.withOpacity(0.1) : SiberTema.kuantumCyan.withOpacity(0.1), blurRadius: 10)]
                ),
                child: Icon(ikon, color: isOzel ? SiberTema.altinSari : SiberTema.kuantumCyan, size: 28, shadows: [Shadow(color: isOzel ? SiberTema.altinSari : SiberTema.kuantumCyan, blurRadius: 10)]) // 🔥 İKON NEON PARLASIN
            ),
            const SizedBox(height: 12),
            Text(baslik, textAlign: TextAlign.center, style: TextStyle(color: isOzel ? SiberTema.altinSari : Colors.white.withOpacity(0.95), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.0, fontFamily: 'Avenir')),
          ],
        ),
      ),
    );
  }

  Widget _canliFinansRadari() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('islem_kayitlari').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return _buildKuantumLoader();
        final islemler = snapshot.data?.docs ?? [];
        double siberKomutanPayi = 0;
        for (var islem in islemler) {
          final data = islem.data() as Map<String, dynamic>;
          siberKomutanPayi += (data['komutan_payi'] ?? 0).toDouble();
        }
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: SiberTema.matGrey, // 🔥 3D Zemin
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
              boxShadow: SiberTema.siberGolgeKatmanli // 🔥 KATMANLI DERİNLİK GÖLGESİ
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("NET KARARGAH PAYI (%12)", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                  const SizedBox(height: 8),
                  Text("₺${siberKomutanPayi.toStringAsFixed(2)}", style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 26, fontWeight: FontWeight.w900, fontFamily: 'Avenir', shadows: [Shadow(color: SiberTema.kuantumCyan, blurRadius: 10)])),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _canliHareketListesi() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('sistem_loglari').orderBy('tarih', descending: true).limit(20).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return _buildKuantumLoader();
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return Center(child: Text("Radar Temiz.", style: TextStyle(color: Colors.white.withOpacity(0.4), fontFamily: 'Avenir', fontWeight: FontWeight.bold)));
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            String bayi = data['bayi_isim'] ?? 'Sistem Merkezi';
            String islem = data['islem_detayi'] ?? 'Bilinmeyen İşlem';
            String tur = data['islem_turu'] ?? 'bilgi';

            IconData icon = Icons.info_outline;
            Color renk = Colors.white54;
            if (tur == 'basarili') { icon = Icons.security; renk = SiberTema.kuantumCyan; }
            else if (tur == 'hata') { icon = Icons.warning_amber_rounded; renk = SiberTema.kanKirmizi; }
            else if (tur == 'sos') { icon = Icons.radar; renk = SiberTema.altinSari; }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: renk.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: renk.withOpacity(0.3))), child: Icon(icon, color: renk, size: 18)),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(bayi, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w900, fontFamily: 'Avenir')), const SizedBox(height: 4), Text(islem, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, fontFamily: 'Avenir'))])),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildKuantumLoader() => const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan, strokeWidth: 3));
}

// =====================================================================
// ⚙️ SİSTEM AYARLARI VE HOLOGRAM KONTROL PANELİ
// =====================================================================
class _SistemAyarlariTerminali extends StatefulWidget {
  const _SistemAyarlariTerminali();

  @override
  State<_SistemAyarlariTerminali> createState() => _SistemAyarlariTerminaliState();
}

class _SistemAyarlariTerminaliState extends State<_SistemAyarlariTerminali> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _hologramAktif = false;
  final TextEditingController _hologramBaslikCtrl = TextEditingController();
  final TextEditingController _hologramMesajCtrl = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _ayarlariCek();
  }

  Future<void> _ayarlariCek() async {
    try {
      DocumentSnapshot doc = await _db.collection('sistem_ayarlari').doc('genel_ayarlar').get();
      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        setState(() {
          _hologramAktif = data['hologram_aktif'] ?? false;
          _hologramBaslikCtrl.text = data['hologram_baslik'] ?? "";
          _hologramMesajCtrl.text = data['hologram_mesaj'] ?? "";
        });
      }
    } catch (e) {
      // Varsayılan ayarlarla devam et
    }
  }

  Future<void> _ayarlariKaydet() async {
    setState(() => _isSaving = true);
    try {
      await _db.collection('sistem_ayarlari').doc('genel_ayarlar').set({
        'hologram_aktif': _hologramAktif,
        'hologram_baslik': _hologramBaslikCtrl.text.trim(),
        'hologram_mesaj': _hologramMesajCtrl.text.trim(),
        'guncellenme_tarihi': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("AĞA MÜHÜRLENDİ! Tüm kullanıcılarda anında değişecek.", style: TextStyle(fontWeight: FontWeight.bold, color: SiberTema.oledBlack)), backgroundColor: SiberTema.kuantumCyan));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Siber Ağ Hatası! Kaydedilemedi."), backgroundColor: SiberTema.kanKirmizi));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: SiberTema.oledBlack.withOpacity(0.85),
            border: Border(top: BorderSide(color: SiberTema.altinSari.withOpacity(0.5), width: 2)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 32),

                const Row(
                  children: [
                    Icon(Icons.tune, color: SiberTema.altinSari, size: 28),
                    SizedBox(width: 12),
                    Text("SİSTEM AYARLARI", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
                  ],
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider(color: Colors.white12)),

                // 🎇 HOLOGRAM ŞALTERİ
                Row(
                  children: [
                    const Icon(Icons.celebration, color: SiberTema.kuantumCyan),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("HOLOGRAM (KUTLAMA) EKRANI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Avenir')),
                          SizedBox(height: 4),
                          Text("Açıldığında uygulamaya giren herkesin karşısına çıkar.", style: TextStyle(color: Colors.white54, fontSize: 10, fontFamily: 'Avenir')),
                        ],
                      ),
                    ),
                    Switch(
                      value: _hologramAktif,
                      activeColor: SiberTema.oledBlack,
                      activeTrackColor: SiberTema.kuantumCyan,
                      inactiveThumbColor: Colors.white54,
                      inactiveTrackColor: Colors.white12,
                      onChanged: (val) => setState(() => _hologramAktif = val),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // HOLOGRAM METİNLERİ
                if (_hologramAktif) ...[
                  _buildGirdi("Kutlama Başlığı", "Örn: 29 Ekim Cumhuriyet Bayramımız Kutlu Olsun!", _hologramBaslikCtrl),
                  const SizedBox(height: 16),
                  _buildGirdi("Kutlama / Duyuru Metni", "Kullanıcılara iletilecek detaylı mesaj...", _hologramMesajCtrl, maxLines: 3),
                  const SizedBox(height: 24),
                ],

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity, height: 56,
                  child: ElevatedButton.icon(
                    style: SiberTema.kuantumButonStili().copyWith(backgroundColor: MaterialStateProperty.all(SiberTema.altinSari)),
                    onPressed: _isSaving ? null : _ayarlariKaydet,
                    icon: _isSaving ? const SizedBox() : const Icon(Icons.save),
                    label: _isSaving
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: SiberTema.oledBlack, strokeWidth: 2))
                        : const Text("TÜM AĞI GÜNCELLE VE MÜHÜRLE", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir', color: SiberTema.oledBlack)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGirdi(String baslik, String hint, TextEditingController ctrl, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(baslik, style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Avenir'),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
            filled: true,
            fillColor: SiberTema.matGrey,
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SiberTema.kuantumCyan)),
          ),
        )
      ],
    );
  }
}