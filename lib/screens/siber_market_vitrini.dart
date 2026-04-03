// lib/screens/siber_market_vitrini.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI VE ROTALAR
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';
import 'siber_sepet_ekrani.dart'; // SEPET BAĞLANTISI AKTİF!

/// 🛡️ KUANTUM MARKET VİTRİNİ
/// Reklamları, VIP Bayileri ve Kampanyalı Ürünleri otonom olarak Matrix'ten çeker.
class SiberMarketVitrini extends StatefulWidget {
  const SiberMarketVitrini({super.key});

  @override
  State<SiberMarketVitrini> createState() => _SiberMarketVitriniState();
}

class _SiberMarketVitriniState extends State<SiberMarketVitrini> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── 🛒 OTONOM SEPETE EKLEME MOTORU ──
  Future<void> _sepeteEkle(String urunId, Map<String, dynamic> urunData) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      _siberUyariGoster("SİBER İHLAL", "Sepete ürün eklemek için ağa giriş yapmalısınız!", SiberTema.kanKirmizi);
      return;
    }

    HapticFeedback.lightImpact();
    developer.log("🛒 SEPET RADARI: $urunId kodlu ürün sepete çekiliyor...");

    try {
      // Ürün zaten sepette varsa adedini 1 artırır, yoksa yeni ekler (Kuantum Merge)
      await _db.collection('kullanicilar').doc(currentUser.uid).collection('sepet').doc(urunId).set({
        'ad': urunData['ad'] ?? 'Bilinmeyen Ürün',
        'fiyat': urunData['fiyat'] ?? 0.0,
        'gorsel_url': urunData['gorsel_url'],
        'satici_id': urunData['asil_satici_id'] ?? 'GIZLI_SATIC',
        'adet': FieldValue.increment(1),
        'eklenme_tarihi': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _siberUyariGoster("ONAYLANDI", "Ürün başarıyla Kuantum Sepete mühürlendi.", SiberTema.kuantumCyan);
    } catch (e) {
      developer.log("🚨 SEPET HATASI: Ürün eklenemedi!", error: e);
      _siberUyariGoster("HATA", "Ürün sepete eklenemedi. Matriks bağlantısını kontrol edin.", SiberTema.kanKirmizi);
    }
  }

  // ── 🔧 ARAYÜZ YARDIMCILARI ──
  void _siberUyariGoster(String baslik, String mesaj, Color renk) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SiberTema.matGrey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: renk, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            Text(mesaj, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildBolumBasligi(String baslik, IconData ikon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Icon(ikon, color: SiberTema.altinSari, size: 20),
          const SizedBox(width: 8),
          Text(baslik, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        ],
      ),
    );
  }

  Widget _buildSiberHataVeyaBos(String mesaj) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(mesaj, style: const TextStyle(color: Colors.white30, fontSize: 12, letterSpacing: 1)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("KARARGAH VİTRİNİ", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2)),
          actions: [
            // 🚀 SEPET EKRANINA YÖNLENDİRME KABLOSU
            IconButton(
              icon: const Icon(Icons.shopping_cart, color: SiberTema.kuantumCyan),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SiberSepetEkrani()));
              },
            )
          ],
        ),
        body: RefreshIndicator(
          color: SiberTema.kuantumCyan,
          backgroundColor: SiberTema.matGrey,
          onRefresh: () async => setState(() {}),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildSiberReklamRadari(),
                const SizedBox(height: 24),
                _buildBolumBasligi("ELİT VE VIP BAYİLER", Icons.verified_user),
                _buildVipBayilerRadari(),
                const SizedBox(height: 24),
                _buildBolumBasligi("SİBER FIRSATLAR", Icons.flash_on),
                _buildKampanyaliUrunlerRadari(),
                const SizedBox(height: 24),
                _buildBolumBasligi("TÜM ENVANTER", Icons.inventory_2),
                _buildTumUrunlerRadari(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── 🚀 1. REKLAM PANOSU MOTORU ──
  Widget _buildSiberReklamRadari() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('market_reklamlar').where('aktif', isEqualTo: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox(height: 150, child: Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan)));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return _buildSiberHataVeyaBos("Aktif reklam yayını bulunmuyor.");

        return SizedBox(
          height: 160,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.9),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var veri = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: SiberTema.matGrey,
                  image: veri['gorsel_url'] != null
                      ? DecorationImage(image: NetworkImage(veri['gorsel_url']), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken))
                      : null,
                  border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5)),
                ),
                child: Center(
                  child: Text(veri['baslik'] ?? "SİBER REKLAM", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2, backgroundColor: Colors.black45)),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ── 🛡️ 2. VIP BAYİLER MOTORU ──
  Widget _buildVipBayilerRadari() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('kullanicilar').where('rol', isEqualTo: 'BAYI').where('vip_mi', isEqualTo: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator(color: SiberTema.altinSari)));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return _buildSiberHataVeyaBos("VIP Bayi radarda görünmüyor.");

        return SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var bayi = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: SiberTema.matGrey,
                      backgroundImage: bayi['logo_url'] != null ? NetworkImage(bayi['logo_url']) : null,
                      child: bayi['logo_url'] == null ? const Icon(Icons.store, color: SiberTema.altinSari, size: 30) : null,
                    ),
                    const SizedBox(height: 8),
                    Text(bayi['firma_adi'] ?? "VIP Bayi", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ── ⚡ 3. KAMPANYALI ÜRÜNLER MOTORU ──
  Widget _buildKampanyaliUrunlerRadari() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('market_urunleri').where('kampanyali_mi', isEqualTo: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox(height: 180, child: Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan)));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return _buildSiberHataVeyaBos("Şu an aktif Kuantum fırsatı bulunmuyor.");

        return SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var docId = snapshot.data!.docs[index].id;
              var urun = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return Container(
                width: 150,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: SiberTema.matGrey,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          image: urun['gorsel_url'] != null ? DecorationImage(image: NetworkImage(urun['gorsel_url']), fit: BoxFit.cover) : null,
                        ),
                        child: urun['gorsel_url'] == null ? const Center(child: Icon(Icons.settings_input_component, color: Colors.white30, size: 50)) : null,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(urun['ad'] ?? "Bilinmeyen Ürün", maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text("Satıcı: ${urun['vitrin_satici_adi'] ?? 'Gizli'}", maxLines: 1, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("₺${urun['fiyat']}", style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 16, fontWeight: FontWeight.w900)),
                              // 🚀 SEPETE EKLEME MOTORU BAĞLANDI
                              InkWell(
                                onTap: () => _sepeteEkle(docId, urun),
                                child: const Icon(Icons.add_shopping_cart, color: SiberTema.kuantumCyan, size: 24),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ── 📦 4. TÜM ÜRÜNLER MOTORU (GRID) ──
  Widget _buildTumUrunlerRadari() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('market_urunleri').orderBy('eklenme_tarihi', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return _buildSiberHataVeyaBos("Karargah envanterinde ürün bulunamadı.");

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.65,
          ),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var docId = snapshot.data!.docs[index].id;
            var urun = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return SiberTema.siberCamKalkan(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Center(child: Icon(Icons.inventory, color: SiberTema.kuantumCyan.withOpacity(0.5), size: 60)),
                  ),
                  const Divider(color: Colors.white24),
                  Text(urun['ad'] ?? "Bilinmeyen Ürün", maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(urun['vitrin_satici_adi'] ?? "Bilinmeyen Satıcı", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("₺${urun['fiyat']}", style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 15, fontWeight: FontWeight.w900)),
                      // 🚀 SEPETE EKLEME MOTORU BAĞLANDI
                      InkWell(
                        onTap: () => _sepeteEkle(docId, urun),
                        child: const Icon(Icons.add_shopping_cart, color: SiberTema.kuantumCyan, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
// ── DOSYA SONU MÜHRÜ ──