// lib/screens/super_admin_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

import 'admin/siber_bayi_rozet_yonetimi_screen.dart';

/// 🦅 OTODNA YÜKSEK KONSEY TERMİNALİ (Super Admin)
class SuperAdminScreen extends StatefulWidget {
  const SuperAdminScreen({super.key});

  @override
  State<SuperAdminScreen> createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends State<SuperAdminScreen> with TickerProviderStateMixin {
  // 🌑 TESLA MİMARİSİ PALETİ
  static const Color surfaceColor = Color(0xFF111111);
  static const Color adminPurple = Colors.purpleAccent;

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
  // 🔓 ATOMİK MÜHÜR KIRMA: FİREBASE GÜNCELLEME MOTORU (WRITEBATCH)
  // =========================================================================
  // 🛡️ SİBER DÜZELTME: Metot adı _muhurKir olarak butonla eşitlendi!
  Future<void> _muhurKir(String islemId) async {
    try {
      developer.log("SİBER ONAY: $islemId için Mühür Kırma Protokolü başlatıldı.");
      WriteBatch batch = _db.batch();

      batch.update(_db.collection('islem_kayitlari').doc(islemId), {
        'muhur_durumu': 'KIRILDI',
        'duzenleme_yetkisi': true,
        'admin_onay_tarihi': FieldValue.serverTimestamp(),
      });

      batch.set(_db.collection('sistem_loglari').doc(), {
        'islem_turu': 'MUHUR_KIRMA_ONAYI',
        'islem_detayi': 'YÜKSEK KONSEY: $islemId numaralı işlemin mührü kırıldı.',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();

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
        content: Text(mesaj, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1, fontFamily: 'Avenir')),
        backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.admin_panel_settings, color: SiberTema.kuantumCyan, size: 24),
              SizedBox(width: 12),
              Text('ANKARA MERKEZ KARARGAH', style: TextStyle(color: SiberTema.textMain, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
            ],
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: SiberTema.kuantumCyan),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: SiberTema.kuantumCyan,
            labelColor: SiberTema.kuantumCyan,
            unselectedLabelColor: Colors.white38,
            isScrollable: true,
            labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir'),
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
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));

        var data = snapshot.data?.data() as Map<String, dynamic>? ?? {
          'toplam_hacim': 0.0,
          'bayi_komisyonu': 0.0,
          'sistem_komisyonu': 0.0
        };

        return ListView(
          padding: const EdgeInsets.all(24),
          physics: const BouncingScrollPhysics(),
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3))),
              child: Column(
                children: [
                  const Text("OTODNA KÜRESEL SİSTEM HACMİ", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
                  const SizedBox(height: 12),
                  Text("₺ ${data['toplam_hacim']}", style: const TextStyle(color: SiberTema.textMain, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildFinansKarti("TÜM BAYİLERİN\nNET KAZANCI", "₺ ${data['bayi_komisyonu']}", SiberTema.kuantumCyan, Icons.account_balance_wallet)),
                const SizedBox(width: 16),
                Expanded(child: _buildFinansKarti("SİSTEM KOMİSYONU\nKARARGAH PAYI (%12)", "₺ ${data['sistem_komisyonu']}", SiberTema.altinSari, Icons.account_balance)),
              ],
            ),
            const SizedBox(height: 48),
            const Text("SON OTONOM İŞLEMLER", style: TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
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
            return _buildIslemSatiri(islem['baslik'] ?? 'İŞLEM', islem['detay'] ?? 'DETAY', "₺${islem['tutar']}", SiberTema.kuantumCyan);
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
                          Text("İPTAL TALEBİ: $id", style: const TextStyle(color: SiberTema.textMain, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                          const SizedBox(height: 6),
                          const Text("İkili Onay Sağlandı: Müşteri & Firma", style: TextStyle(color: adminPurple, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Avenir'))
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
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: SiberTema.kanKirmizi));
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildRadarVizuel(),
            const SizedBox(height: 32),
            ...snapshot.data!.docs.map((doc) {
              var sos = doc.data() as Map<String, dynamic>;
              return _buildSosSatiri(sos['plaka'] ?? 'PLAKA YOK', sos['bolge'] ?? 'KONUM ALINIYOR', sos['durum'] ?? 'BEKLİYOR', SiberTema.kanKirmizi);
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
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: SiberTema.kanKirmizi));
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // 🛡️ SİBER BAYİ ROZET YÖNETİMİ BUTONU
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: SiberTema.kuantumCyan.withOpacity(0.1),
                  foregroundColor: SiberTema.kuantumCyan,
                  side: const BorderSide(color: SiberTema.kuantumCyan, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.workspace_premium),
                label: const Text("TÜM BAYİLERİN ROZET VE YILDIZ YÖNETİMİ", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SiberBayiRozetYonetimiScreen())),
              ),
            ),
            const SizedBox(height: 40),

            const Text("SİBER İHLAL YAPAN FİRMALAR (BLACKLIST)", style: TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
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
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: SiberTema.kanKirmizi.withOpacity(0.5))),
      child: Stack(
        children: [
          Center(child: Icon(Icons.radar, color: SiberTema.kanKirmizi.withOpacity(0.1), size: 120)),
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.satellite_alt, color: SiberTema.kanKirmizi, size: 40),
                SizedBox(height: 12),
                Text("TÜRKİYE S.O.S AĞI AKTİF", style: TextStyle(color: SiberTema.kanKirmizi, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 3, fontFamily: 'Avenir'))
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
          Text(tutar, style: const TextStyle(color: SiberTema.textMain, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
          const SizedBox(height: 8),
          Text(baslik, style: TextStyle(color: SiberTema.textMain.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.bold, height: 1.5, letterSpacing: 1, fontFamily: 'Avenir')),
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
                Text(islem, style: const TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5, fontFamily: 'Avenir')),
                const SizedBox(height: 4),
                Text(detay, style: TextStyle(color: SiberTema.textMain.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'Avenir'))
              ],
            ),
          ),
          Text(kazanc, style: TextStyle(color: renk, fontWeight: FontWeight.w900, fontSize: 12, fontFamily: 'Avenir')),
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
                Text(plaka, style: const TextStyle(color: SiberTema.textMain, fontSize: 12, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                Text(konum, style: TextStyle(color: SiberTema.textMain.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'Avenir'))
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: renk.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(durum, style: TextStyle(color: renk, fontSize: 8, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
          ),
        ],
      ),
    );
  }

  Widget _buildKaraListeKarti(String firma, String konum, String sebep) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: SiberTema.oledBlack, borderRadius: BorderRadius.circular(20), border: Border.all(color: SiberTema.kanKirmizi.withOpacity(0.5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(firma, style: const TextStyle(color: SiberTema.kanKirmizi, fontWeight: FontWeight.w900, fontSize: 12, fontFamily: 'Avenir'))),
              const Icon(Icons.block, color: SiberTema.kanKirmizi, size: 20)
            ],
          ),
          const SizedBox(height: 8),
          Text(konum, style: TextStyle(color: SiberTema.textMain.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
          const Divider(color: SiberTema.textMuted, height: 24),
          Text("SİBER İHLAL: $sebep", style: const TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () {}, child: const Text("UYARI SİNYALİ", style: TextStyle(color: Colors.orangeAccent, fontSize: 10, fontWeight: FontWeight.w900, fontFamily: 'Avenir'))),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: SiberTema.kanKirmizi, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: () {},
                child: const Text("MEN ET", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
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
          const Icon(Icons.shield_outlined, color: SiberTema.textMuted, size: 64),
          const SizedBox(height: 16),
          Text(mesaj, style: const TextStyle(color: SiberTema.textMuted, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
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
            const Text("ADMİN YETKİSİ: MÜHÜR KIRMA", style: TextStyle(color: SiberTema.textMain, fontSize: 13, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
            const SizedBox(height: 24),
            Text("İTİRAZ SEBEBİ: ${itiraz['sebep']}", style: const TextStyle(color: SiberTema.textMuted, fontSize: 11, fontFamily: 'Avenir')),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: adminPurple),
                onPressed: () => _muhurKir(islemId),
                child: const Text("MÜHRÜ KIR VE ONAYLA", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Avenir')),
              ),
            )
          ],
        ),
      ),
    );
  }
}