import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🚀 KARARGAH ZIRHLARI
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

// 🔥 SİBER KÖPRÜLER
import 'admin_onay_havuzu_screen.dart';
import '../../admin/admin_dash_ui.dart';
import 'bayi_itibar_merkezi_screen.dart';
import '../bayi_yonetim_merkezi_screen.dart';
import 'bolge_komuta_merkezi_screen.dart'; // 🌍 DOĞRU KÖPRÜ (Arayüz Bağlandı)
import '../mega_revizyon_screen.dart';
import '../bayi_paneli.dart';
import '../kullanici_yonetim_screen.dart';
import '../bayi_ekosistemi_screen.dart';
import '../dashboard/siber_finans_merkezi_screen.dart'; // 💰 YENI SIBER FINANS KOKPITI KOPRUSU
import 'siber_istihbarat_merkezi_screen.dart'; // 👁️ SIBER İSTİHBARAT KÖPRÜSÜ
import 'bayi_basvuru_merkezi_screen.dart'; // 🏢 BAYİ BAŞVURU KÖPRÜSÜ

// 🎨 SİNEMATIK VE TAKTİKSEL RENK KODLARI (TRUE BLACK & KUANTUM TURKUAZI ZIRHI)
const Color renkIstihbarat = SiberTema.kuantumCyan; // Kuantum Turkuazı (Ağ ve Finans)
const Color renkOperasyon = SiberTema.kuantumCyan; // Neon Mor yerine Turkuaz
const Color renkKritik = SiberTema.kanKirmizi; // Kan Kırmızı (SOS)
const Color bgDark = SiberTema.oledBlack; // True Black
const Color glassBg = SiberTema.matGrey; // Şeffaf Cam

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
      builder: (context) => const FractionallySizedBox(
        heightFactor: 0.92,
        child: _SistemAyarlariTerminali(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: bgDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("MERKEZ KARARGAH", style: TextStyle(color: SiberTema.textMain, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2.0)),
          centerTitle: true,
          actions: [
            IconButton(
                icon: const Icon(Icons.power_settings_new, color: renkKritik),
                onPressed: _siberCikisYap,
                tooltip: "Ağdan Çıkış Yap"
            )
          ],
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            _buildPanelBaslik("SİBER FİNANS", renkIstihbarat),
            const SizedBox(height: 16),
            _buildSiberFinansDonanimPaneli(),
            const SizedBox(height: 40),

            _buildPanelBaslik("SİSTEM KONTROL MODÜLLERİ", Colors.white54),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2, // Daha ferah görünüm için 2 sütun
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                // 📡 İSTİHBARAT VE AĞ (TURKUAZ)
                _buildGlassModule(context, "BÖLGE RADARI", Icons.radar, renkIstihbarat, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BolgeKomutaMerkeziScreen()))),
                _buildGlassModule(context, "BAYİ AĞI", Icons.storefront, renkIstihbarat, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BayiYonetimMerkeziScreen()))),
                _buildGlassModule(context, "BAYİ BAŞVURULARI", Icons.domain_add, renkIstihbarat, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BayiBasvuruMerkeziScreen()))),
                _buildGlassModule(context, "İTİBAR SİCİLİ", Icons.folder_special, renkIstihbarat, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BayiItibarMerkeziScreen()))),
                _buildGlassModule(context, "KULLANICI YETKİ", Icons.fingerprint, renkIstihbarat, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KullaniciYonetimScreen()))),

                // ⚙️ AĞIR OPERASYON (MOR)
                _buildGlassModule(context, "MEGA REVİZYON", Icons.build_circle, renkOperasyon, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MegaRevizyonScreen(plaka: "KARARGAH-GİRİŞİ")))),
                _buildGlassModule(context, "EKSPERTİZ DNA", Icons.fact_check, renkOperasyon, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BayiEkosistemiScreen()))),

                // ONAY HAVUZU
                _buildGlassModule(context, "ONAY HAVUZU", Icons.verified_user, renkOperasyon, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminOnayHavuzuScreen()))),

                // 🚨 KRİTİK MÜDAHALE (KIRMIZI)
                _buildGlassModule(context, "KASA & SOS", Icons.warning_amber_rounded, renkKritik, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashUI())), isCritical: true),
              ],
            ),
            const SizedBox(height: 24),

            // 👑 MERKEZİ KONTROL (AYARLAR - TAM GENİŞLİK)
            _buildGlassModule(context, "SİSTEM AYARLARI", Icons.settings_suggest, Colors.white, () => _sistemAyarMenuAc(context), isFullWidth: true),

            const SizedBox(height: 40),
            _buildPanelBaslik("CANLI AĞ HAREKETLERİ", renkIstihbarat),
            const SizedBox(height: 16),
            _buildLiveCrtLogEkrani(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelBaslik(String baslik, Color renk) {
    return Row(
      children: [
        Icon(Icons.memory, color: renk, size: 16),
        const SizedBox(width: 8),
        Text(baslik, style: TextStyle(color: SiberTema.textMain.withOpacity(0.5), fontWeight: FontWeight.w800, letterSpacing: 2.0, fontSize: 11)),
      ],
    );
  }

  // 💎 V.I.P SİBER CAM MODÜLÜ (GLASSMORPHISM)
  Widget _buildGlassModule(BuildContext context, String baslik, IconData ikon, Color neonRenk, VoidCallback onTap, {bool isCritical = false, bool isFullWidth = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            height: isFullWidth ? 80 : null,
            decoration: BoxDecoration(
              color: glassBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isCritical ? renkKritik.withOpacity(0.5) : Colors.white.withOpacity(0.05), width: 1.5),
            ),
            child: isFullWidth
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(ikon, color: neonRenk, size: 28),
                const SizedBox(width: 16),
                Text(baslik, style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 2)),
              ],
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(ikon, color: neonRenk, size: 32),
                const SizedBox(height: 12),
                Text(
                    baslik,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: SiberTema.textMain.withOpacity(0.9), fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 1.0)
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 %12 NET PAY (KARARGAH FİNANS MOTORU)
  Widget _buildSiberFinansDonanimPaneli() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('islem_kayitlari').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return _buildKuantumLoader();
        final islemler = snapshot.data?.docs ?? [];
        double siberKomutanPayi = 0;
        for (var islem in islemler) {
          final data = islem.data() as Map<String, dynamic>;
          // BURASI MUTLAK %12 HESAPLAMASIDIR (%10 kar + %2 vergi)
          siberKomutanPayi += (data['komutan_payi'] ?? 0).toDouble();
        }
        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SiberFinansMerkeziScreen()));
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                decoration: BoxDecoration(
                  color: renkIstihbarat.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: renkIstihbarat.withOpacity(0.3), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("NET KARARGAH PAYI (%12)", style: TextStyle(color: renkIstihbarat, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    const SizedBox(height: 16),
                    Text(
                        "₺ ${siberKomutanPayi.toStringAsFixed(2)}",
                        style: const TextStyle(
                            color: SiberTema.textMain,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            shadows: [Shadow(color: renkIstihbarat, blurRadius: 20)]
                        )
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("SİBER FİNANS MERKEZİ'NE GİRİŞ YAP", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios, color: renkIstihbarat, size: 10),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLiveCrtLogEkrani() {
    return Column(
      children: [
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: glassBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('siber_istihbarat_loglari').orderBy('tarih', descending: true).limit(20).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return _buildKuantumLoader();
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) return const Center(child: Text("> Radar Temiz...", style: TextStyle(color: SiberTema.textMuted, fontWeight: FontWeight.bold)));

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  var data = docs[index].data() as Map<String, dynamic>;
                  String bayi = data['fail_adi'] ?? 'SİSTEM';
                  String islem = data['islem_basligi'] ?? 'Bilinmeyen İşlem';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("> ", style: TextStyle(color: renkIstihbarat, fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Text(
                              "[$bayi] : $islem",
                              style: TextStyle(color: SiberTema.textMain.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w500)
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SiberIstihbaratMerkeziScreen()));
            },
            icon: const Icon(Icons.travel_explore, color: Colors.white),
            label: const Text("TÜM İSTİHBARAT AĞINI AÇ", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
            style: ElevatedButton.styleFrom(
              backgroundColor: renkIstihbarat,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKuantumLoader() => const Center(child: CircularProgressIndicator(color: renkIstihbarat, strokeWidth: 2));
}

// =====================================================================
// ⚙️ TAM YETKİLİ SİSTEM AYARLARI
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

  final TextEditingController _duyuruBaslikCtrl = TextEditingController();
  final TextEditingController _duyuruMesajCtrl = TextEditingController();
  String _hedefKitle = "TÜM AĞ";

  bool _isSaving = false;
  bool _isSendingSignal = false;

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
      // Varsayılan
    }
  }

  Future<void> _ayarlariKaydet() async {
    setState(() => _isSaving = true);
    try {
      WriteBatch batch = _db.batch();

      DocumentReference ayarlarRef = _db.collection('sistem_ayarlari').doc('genel_ayarlar');
      batch.set(ayarlarRef, {
        'hologram_aktif': _hologramAktif,
        'hologram_baslik': _hologramBaslikCtrl.text.trim(),
        'hologram_mesaj': _hologramMesajCtrl.text.trim(),
        'tema_rengi': 'Turkuaz', // Sabit Kuantum Turkuazı
        'guncellenme_tarihi': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      DocumentReference logRef = _db.collection('siber_istihbarat_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'SISTEM_AYARLARI_GUNCELLEME',
        'islem_detayi': 'SİBER KOMUTAN: Sistem ayarları güncellendi. Hologram Aktif: $_hologramAktif',
        'kullanici_id': FirebaseAuth.instance.currentUser?.uid ?? 'BİLİNMEYEN',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (!mounted) return;
      _siberUyari("SİSTEM MÜHÜRLENDİ! Değişiklikler ağa yayıldı.", isError: false);
    } catch (e) {
      if (!mounted) return;
      _siberUyari("Siber Ağ Hatası! Kaydedilemedi.", isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _duyuruFirlat() async {
    if (_duyuruBaslikCtrl.text.isEmpty || _duyuruMesajCtrl.text.isEmpty) {
      return _siberUyari("HATA: Duyuru başlığı ve mesajı boş olamaz!", isError: true);
    }

    setState(() => _isSendingSignal = true);
    try {
      WriteBatch batch = _db.batch();

      DocumentReference duyuruRef = _db.collection('siber_duyurular').doc();
      batch.set(duyuruRef, {
        'baslik': _duyuruBaslikCtrl.text.trim(),
        'mesaj': _duyuruMesajCtrl.text.trim(),
        'hedef_kitle': _hedefKitle,
        'tarih': FieldValue.serverTimestamp(),
        'gonderen': 'SİBER KOMUTAN',
      });

      DocumentReference logRef = _db.collection('siber_istihbarat_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'EVRENSEL_DUYURU_FIRLATMA',
        'islem_detayi': 'SİBER KOMUTAN: "$_hedefKitle" kitlesine duyuru fırlatıldı: "${_duyuruBaslikCtrl.text.trim()}"',
        'kullanici_id': FirebaseAuth.instance.currentUser?.uid ?? 'BİLİNMEYEN',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      _duyuruBaslikCtrl.clear();
      _duyuruMesajCtrl.clear();

      if (!mounted) return;
      _siberUyari("SİNYAL FIRLATILDI! Hedef kitleye iletildi. 🚀", isError: false);
    } catch (e) {
      if (!mounted) return;
      _siberUyari("Fırlatma Hatası: Sinyal çöktü.", isError: true);
    } finally {
      if (mounted) setState(() => _isSendingSignal = false);
    }
  }

  void _siberUyari(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold, color: SiberTema.textMain)),
        backgroundColor: isError ? renkKritik : renkIstihbarat
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: bgDark.withOpacity(0.8),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: SiberTema.textMuted, borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 32),

                const Text("SİSTEM AYARLARI", style: TextStyle(color: SiberTema.textMain, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2)),
                const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider(color: SiberTema.textMuted)),

                // ==========================================
                // 1. HOLOGRAM AYARLARI
                // ==========================================
                const Text("AÇILIŞ ŞOVU (HOLOGRAM)", style: TextStyle(color: renkOperasyon, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2)),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: glassBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: SiberTema.textMuted)),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.celebration, color: renkOperasyon),
                          const SizedBox(width: 16),
                          const Expanded(child: Text("Hologram Ekranını Aktif Et", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, fontSize: 13))),
                          Switch(value: _hologramAktif, activeColor: renkOperasyon, activeTrackColor: renkOperasyon.withOpacity(0.3), inactiveThumbColor: Colors.white54, onChanged: (val) => setState(() => _hologramAktif = val)),
                        ],
                      ),
                      if (_hologramAktif) ...[
                        const SizedBox(height: 24),
                        _buildGirdi("Kutlama Başlığı", "Örn: 29 Ekim Kutlu Olsun!", _hologramBaslikCtrl),
                        const SizedBox(height: 16),
                        _buildGirdi("Kutlama Metni", "Tüm ağa iletilecek mesaj...", _hologramMesajCtrl, maxLines: 3),
                      ]
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: renkOperasyon,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: renkOperasyon, width: 1.5))
                    ),
                    onPressed: _isSaving ? null : _ayarlariKaydet,
                    child: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: renkOperasyon, strokeWidth: 2)) : const Text("SİSTEMİ GÜNCELLE", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  ),
                ),

                const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Divider(color: SiberTema.textMuted)),

                // ==========================================
                // 2. SİBER SİNYAL FIRLATICI (DUYURU)
                // ==========================================
                const Text("EVRENSEL DUYURU (PUSH) SİSTEMİ", style: TextStyle(color: renkIstihbarat, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2)),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: glassBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: SiberTema.textMuted)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(color: bgDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: SiberTema.textMuted)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _hedefKitle,
                            dropdownColor: bgDark,
                            isExpanded: true,
                            icon: const Icon(Icons.radar, color: renkIstihbarat),
                            style: const TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, fontSize: 13),
                            items: ["TÜM AĞ", "SADECE BAYİLER", "SADECE KULLANICILAR"].map((String value) {
                              return DropdownMenuItem<String>(value: value, child: Text(value));
                            }).toList(),
                            onChanged: (yeniHedef) => setState(() => _hedefKitle = yeniHedef!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildGirdi("Duyuru Başlığı", "DİKKAT: Acil Güncelleme...", _duyuruBaslikCtrl),
                      const SizedBox(height: 16),
                      _buildGirdi("Duyuru İçeriği", "Sisteme eklenecek mesajı yazın...", _duyuruMesajCtrl, maxLines: 4),
                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity, height: 56,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: renkIstihbarat, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                          onPressed: _isSendingSignal ? null : _duyuruFirlat,
                          icon: _isSendingSignal ? const SizedBox() : const Icon(Icons.rocket_launch),
                          label: _isSendingSignal ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("SİNYALİ FIRLAT", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 40),
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
        Text(baslik, style: TextStyle(color: SiberTema.textMain.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: const TextStyle(color: SiberTema.textMain, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint, hintStyle: TextStyle(color: SiberTema.textMain.withOpacity(0.2)),
            filled: true, fillColor: bgDark.withOpacity(0.5),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SiberTema.textMuted)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: renkIstihbarat)),
          ),
        )
      ],
    );
  }
}