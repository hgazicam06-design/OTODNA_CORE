import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

class SuperAdminScreen extends StatefulWidget {
  const SuperAdminScreen({super.key});

  @override
  State<SuperAdminScreen> createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends State<SuperAdminScreen> with TickerProviderStateMixin {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  static const Color bgColor = Color(0xFF000000);
  static const Color surfaceColor = Color(0xFF111111);
  static const Color primaryCyan = Color(0xFF00FFC2);
  static const Color adminPurple = Colors.purpleAccent;
  static const Color dangerColor = Colors.redAccent;
  static const Color warningColor = Colors.orangeAccent;

  late TabController _tabController;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // =========================================================================
  // 🔓 ATOMİK MÜHÜR KIRMA: FİREBASE GÜNCELLEME MOTORU
  // =========================================================================
  Future<void> _muhruKir(String islemId) async {
    try {
      await _db.collection('islem_kayitlari').doc(islemId).update({
        'muhur_durumu': 'KIRILDI',
        'duzenleme_yetkisi': true,
        'admin_onay_tarihi': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context);
      _siberMesajGoster("SİBER MÜHÜR KIRILDI! DÜZENLEME YETKİSİ VERİLDİ. 🔓", isError: false);
    } catch (e) {
      _siberMesajGoster("AĞ İHLALİ: Mühür kırılamadı!", isError: true);
    }
  }

  void _siberMesajGoster(String mesaj, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1)),
        backgroundColor: isError ? dangerColor : primaryCyan,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.admin_panel_settings, color: primaryCyan, size: 24),
              SizedBox(width: 12),
              Text('ANKARA MERKEZ KARARGAH', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2)),
            ],
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: primaryCyan),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: primaryCyan,
            labelColor: primaryCyan,
            unselectedLabelColor: Colors.white38,
            isScrollable: true,
            labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
            tabs: const [
              Tab(icon: Icon(Icons.account_balance), text: "KASA & FİNANS"),
              Tab(icon: Icon(Icons.gavel), text: "MÜHÜR & İTİRAZ"),
              Tab(icon: Icon(Icons.satellite_alt), text: "S.O.S RADAR"),
              Tab(icon: Icon(Icons.warning_amber_rounded), text: "KARA LİSTE"),
            ],
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildKasaSekmesi(),
                _buildMuhurSekmesi(),
                _buildSosSekmesi(),
                _buildKaraListeSekmesi(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── 💰 1. SEKME: CANLI FİNANSAL RADAR ──
  Widget _buildKasaSekmesi() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _db.collection('sistem_istatistikleri').doc('finansal_ozet').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: primaryCyan));

        var data = snapshot.data?.data() as Map<String, dynamic>? ?? {
          'toplam_hacim': 0.0,
          'bayi_komisyonu': 0.0,
          'murat_plaza_kari': 0.0
        };

        return ListView(
          padding: const EdgeInsets.all(24),
          physics: const BouncingScrollPhysics(),
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: primaryCyan.withOpacity(0.3))),
              child: Column(
                children: [
                  const Text("OTODNA KÜRESEL SİSTEM HACMİ", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 12),
                  Text("₺ ${data['toplam_hacim']}", style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: 2)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildFinansKarti("BAYİ KOMİSYON\nHAVUZU (%12)", "₺ ${data['bayi_komisyonu']}", primaryCyan, Icons.pie_chart)),
                const SizedBox(width: 16),
                Expanded(child: _buildFinansKarti("MURAT PLAZA\nGİZLİ SATIŞ KÂRI (%30)", "₺ ${data['murat_plaza_kari']}", adminPurple, Icons.store)),
              ],
            ),
            const SizedBox(height: 48),
            const Text("SON OTONOM İŞLEMLER", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
            const SizedBox(height: 16),
            _buildCanliIslemListesi(),
          ],
        );
      },
    );
  }

  Widget _buildCanliIslemListesi() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('finansal_islemler').orderBy('tarih', descending: true).limit(10).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        return Column(
          children: snapshot.data!.docs.map((doc) {
            var islem = doc.data() as Map<String, dynamic>;
            return _buildIslemSatiri(islem['baslik'] ?? 'İŞLEM', islem['detay'] ?? 'DETAY', "₺${islem['tutar']}", islem['tip'] == 'MURAT' ? adminPurple : primaryCyan);
          }).toList(),
        );
      },
    );
  }

  // ── ⚖️ 2. SEKME: MÜHÜR VE İTİRAZ TERMİNALİ ──
  Widget _buildMuhurSekmesi() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('itiraz_talepleri').where('durum', isEqualTo: 'BEKLEMEDE').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: adminPurple));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return _buildBosEkran("AKTİF İTİRAZ SİNYALİ YOK");

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var itiraz = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            var id = snapshot.data!.docs[index].id;
            return GestureDetector(
              onTap: () => _muhurKirmaTalebiIncele(id, itiraz),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: adminPurple.withOpacity(0.5))),
                child: Row(
                  children: [
                    Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: adminPurple.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.lock_clock, color: adminPurple)),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("İPTAL TALEBİ: $id", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1)),
                          const SizedBox(height: 6),
                          const Text("İkili Onay Sağlandı: Müşteri & Firma", style: TextStyle(color: adminPurple, fontSize: 10, fontWeight: FontWeight.bold))
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: adminPurple, size: 16)
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── 📡 3. SEKME: KÜRESEL S.O.S RADARI ──
  Widget _buildSosSekmesi() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('acil_durum_sinyalleri').orderBy('zaman_damgasi', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: dangerColor));
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildRadarVizuel(),
            const SizedBox(height: 32),
            ...snapshot.data!.docs.map((doc) {
              var sos = doc.data() as Map<String, dynamic>;
              return _buildSosSatiri(sos['plaka'] ?? 'PLAKA YOK', sos['bolge'] ?? 'KONUM ALINIYOR', sos['durum'] ?? 'BEKLİYOR', dangerColor);
            }).toList(),
          ],
        );
      },
    );
  }

  // ── 🚫 4. SEKME: KARA LİSTE DENETİMİ ──
  Widget _buildKaraListeSekmesi() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('bayiler').where('is_blacklisted', isEqualTo: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: dangerColor));
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text("SİBER İHLAL YAPAN FİRMALAR", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
            const SizedBox(height: 16),
            ...snapshot.data!.docs.map((doc) {
              var firma = doc.data() as Map<String, dynamic>;
              return _buildKaraListeKarti(firma['firma_adi'] ?? 'BİLİNMEYEN', firma['il_ilce'] ?? 'LOKASYON YOK', firma['ihlal_notu'] ?? 'KURAL İHLALİ');
            }).toList(),
          ],
        );
      },
    );
  }

  // ── 🛠️ YARDIMCI BİLEŞENLER ──

  Widget _buildRadarVizuel() {
    return Container(
      height: 220,
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: dangerColor.withOpacity(0.5))),
      child: Stack(
        children: [
          Center(child: Icon(Icons.radar, color: dangerColor.withOpacity(0.1), size: 120)),
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.satellite_alt, color: dangerColor, size: 40),
                SizedBox(height: 12),
                Text("TÜRKİYE S.O.S AĞI AKTİF", style: TextStyle(color: dangerColor, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 3))
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinansKarti(String baslik, String tutar, Color renk, IconData ikon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: renk.withOpacity(0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, color: renk, size: 28),
          const SizedBox(height: 16),
          Text(tutar, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(baslik, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.bold, height: 1.5, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildIslemSatiri(String islem, String detay, String kazanc, Color renk) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(islem, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)),
                const SizedBox(height: 4),
                Text(detay, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.bold))
              ],
            ),
          ),
          Text(kazanc, style: TextStyle(color: renk, fontWeight: FontWeight.w900, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSosSatiri(String plaka, String konum, String durum, Color renk) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: renk.withOpacity(0.5))),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: renk, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plaka, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
                Text(konum, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.bold))
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: renk.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(durum, style: TextStyle(color: renk, fontSize: 8, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _buildKaraListeKarti(String firma, String konum, String sebep) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: dangerColor.withOpacity(0.5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(firma, style: const TextStyle(color: dangerColor, fontWeight: FontWeight.w900, fontSize: 12))),
              const Icon(Icons.block, color: dangerColor, size: 20)
            ],
          ),
          const SizedBox(height: 8),
          Text(konum, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.bold)),
          const Divider(color: Colors.white12, height: 24),
          Text("SİBER İHLAL: $sebep", style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () {}, child: const Text("UYARI SİNYALİ", style: TextStyle(color: warningColor, fontSize: 10, fontWeight: FontWeight.w900))),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: dangerColor, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: () {},
                child: const Text("MEN ET", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBosEkran(String mesaj) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shield_outlined, color: Colors.white12, size: 64),
          const SizedBox(height: 16),
          Text(mesaj, style: const TextStyle(color: Colors.white12, fontWeight: FontWeight.w900, letterSpacing: 2)),
        ],
      ),
    );
  }

  void _muhurKirmaTalebiIncele(String islemId, Map<String, dynamic> itiraz) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: surfaceColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(24)), border: const Border(top: BorderSide(color: adminPurple, width: 2))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("ADMİN YETKİSİ: MÜHÜR KIRMA", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
            const SizedBox(height: 24),
            Text("İTİRAZ SEBEBİ: ${itiraz['sebep']}", style: const TextStyle(color: Colors.white70, fontSize: 11)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: adminPurple),
                onPressed: () => _muhurKir(islemId),
                child: const Text("MÜHRÜ KIR VE ONAYLA", style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            )
          ],
        ),
      ),
    );
  }
}