import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

class BayiPremiumVitrinScreen extends StatefulWidget {
  final String bayiId;
  const BayiPremiumVitrinScreen({super.key, required this.bayiId});

  @override
  State<BayiPremiumVitrinScreen> createState() => _BayiPremiumVitrinScreenState();
}

class _BayiPremiumVitrinScreenState extends State<BayiPremiumVitrinScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String _seciliKategori = 'TÜMÜ';

  // Kuantum Kategori Radarı
  final List<String> _kategoriler = ['TÜMÜ', 'Oto Galeri', 'Yedek Parça', 'Rent A Car', 'İş Makinesi', 'Sürücü Kursu'];

  // 🛡️ SİBER RÜTBE (TIER) RENK MOTORU
  Color _getRütbeRengi(String paket) {
    switch (paket.toUpperCase()) {
      case 'ELMAS': return Colors.purpleAccent; // Premium Elmas Hissi
      case 'ALTIN': return SiberTema.altinSari;
      case 'GUMUS': return Colors.grey.shade400;
      case 'BRONZ': return Colors.deepOrangeAccent;
      default: return SiberTema.kuantumCyan; // Normal Paket
    }
  }

  // 🛡️ SİBER RÜTBE İKON MOTORU
  IconData _getRütbeIkoni(String paket) {
    switch (paket.toUpperCase()) {
      case 'ELMAS': return Icons.diamond;
      case 'ALTIN': return Icons.workspace_premium;
      case 'GUMUS': return Icons.star_half;
      case 'BRONZ': return Icons.star_border;
      default: return Icons.storefront;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: SiberTema.oledBlack,
        body: StreamBuilder<DocumentSnapshot>(
          stream: _db.collection('kullanicilar').doc(widget.bayiId).snapshots(),
          builder: (context, bayiSnapshot) {
            if (bayiSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan, strokeWidth: 3));
            }

            if (!bayiSnapshot.hasData || !bayiSnapshot.data!.exists) {
              return _buildHataEkrani("SİCİL BULUNAMADI: Bu bayi Kuantum Ağında yok.");
            }

            var bayiData = bayiSnapshot.data!.data() as Map<String, dynamic>;

            // ── FİREBASE VERİLERİ (Gerçekçi Vitrin Bilgileri) ──
            String firmaAdi = bayiData['firma_adi'] ?? 'İsimsiz Plaza';
            String yetkiliIsim = bayiData['isim'] ?? 'Yetkili Bilgisi Yok';
            String paket = bayiData['abonelik_paketi'] ?? 'NORMAL';
            String calismaSaatleri = bayiData['calisma_saatleri'] ?? '09:00 - 18:00';
            String hakkinda = bayiData['hakkinda'] ?? 'Karargah Onaylı Dijital Tedarikçi.';
            String kapakFoto = bayiData['kapak_fotosu'] ?? '';
            String logoFoto = bayiData['profil_fotosu'] ?? '';
            List<dynamic> isYeriFotolari = bayiData['is_yeri_fotolari'] ?? [];

            Color temaRengi = _getRütbeRengi(paket);

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
              // ── 1. HOLOGRAFİK KAPAK (SliverAppBar) ──
              SliverAppBar(
              expandedHeight: 280.0,
              pinned: true,
              backgroundColor: SiberTema.oledBlack,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle, border: Border.all(color: temaRengi.withOpacity(0.5))),
                  child: Icon(Icons.arrow_back_ios_new, color: temaRengi, size: 16),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Kapak Fotoğrafı
                    kapakFoto.isNotEmpty
                        ? Image.network(kapakFoto, fit: BoxFit.cover)
                        : Container(
                      decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/radar_grid.png'), fit: BoxFit.cover, opacity: 0.3)),
                    ),
                    // Karartma ve Siber Gradient
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, SiberTema.oledBlack.withOpacity(0.8), SiberTema.oledBlack],
                          stops: const [0.3, 0.8, 1.0],
                        ),
                      ),
                    ),
                    // Bayi Logosu ve İsim Alanı
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // 3D Logo Kutusu
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: SiberTema.matGrey,
                              shape: BoxShape.circle,
                              border: Border.all(color: temaRengi, width: 3),
                              boxShadow: [BoxShadow(color: temaRengi.withOpacity(0.5), blurRadius: 20, spreadRadius: 2)],
                              image: logoFoto.isNotEmpty ? DecorationImage(image: NetworkImage(logoFoto), fit: BoxFit.cover) : null,
                            ),
                            child: logoFoto.isEmpty ? Icon(Icons.store, color: temaRengi, size: 40) : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Rütbe Rozeti
                                Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: temaRengi.withOpacity(0.2), borderRadius: BorderRadius.circular(8), border: Border.all(color: temaRengi)),
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                        Icon(_getRütbeIkoni(paket), color: temaRengi, size: 12),
                                const SizedBox(width: 6),
                                Text("$paket BAYİ", style: TextStyle(color: temaRengi, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(firmaAdi, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Avenir', shadows: [Shadow(color: Colors.black, blurRadius: 10)])),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ],
            ),
            ),
            ),

            // ── 2. KARARGAH (BAYİ) BİLGİLERİ ──
            SliverToBoxAdapter(
            child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Yetkili ve Çalışma Saatleri Kalkanı
            Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
            color: SiberTema.matGrey.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text("SİBER YETKİLİ", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
            const SizedBox(height: 4),
            Row(
            children: [
            Icon(Icons.admin_panel_settings, color: temaRengi, size: 14),
            const SizedBox(width: 6),
            Text(yetkiliIsim, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'Avenir')),
            ],
            ),
            ],
            ),
            Container(width: 1, height: 30, color: Colors.white.withOpacity(0.1)),
            Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
            Text("ÇALIŞMA SAATLERİ", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
            const SizedBox(height: 4),
            Row(
            children: [
            Text(calismaSaatleri, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'Avenir')),
            const SizedBox(width: 6),
            const Icon(Icons.access_time, color: SiberTema.kuantumCyan, size: 14),
            ],
            ),
            ],
            ),
            ],
            ),
            ),
            const SizedBox(height: 20),

            // Hakkında ve İş Yeri Fotoğrafları
            Text("KARARGAH HAKKINDA", style: TextStyle(color: temaRengi, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontFamily: 'Avenir')),
            const SizedBox(height: 8),
            Text(hakkinda, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, height: 1.5, fontFamily: 'Avenir')),
            const SizedBox(height: 20),

            if (isYeriFotolari.isNotEmpty) ...[
            SizedBox(
            height: 100,
            child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: isYeriFotolari.length,
            itemBuilder: (context, index) {
            return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: temaRengi.withOpacity(0.3)),
            image: DecorationImage(image: NetworkImage(isYeriFotolari[index]), fit: BoxFit.cover),
            ),
            );
            },
            ),
            ),
            const SizedBox(height: 24),
            ],
            ],
            ),
            ),
            ),

            // ── 3. VİTRİN KATEGORİ RADARI (Sticky Header) ──
            SliverPersistentHeader(
            pinned: true,
            delegate: _SiberKategoriDelegate(
            child: Container(
            color: SiberTema.oledBlack,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
            children: _kategoriler.map((kat) {
            bool isSelected = _seciliKategori == kat;
            return GestureDetector(
            onTap: () => setState(() => _seciliKategori = kat),
            child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
            color: isSelected ? temaRengi.withOpacity(0.15) : SiberTema.matGrey.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? temaRengi : Colors.transparent, width: 1.5),
            boxShadow: isSelected ? [BoxShadow(color: temaRengi.withOpacity(0.3), blurRadius: 10)] : [],
            ),
            child: Text(kat, style: TextStyle(color: isSelected ? temaRengi : Colors.white54, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'Avenir', letterSpacing: 1)),
            ),
            );
            }).toList(),
            ),
            ),
            ),
            ),
            ),

            // ── 4. SİBER İLAN AĞI (Vitrin Ürünleri) ──
            StreamBuilder<QuerySnapshot>(
            stream: _seciliKategori == 'TÜMÜ'
            ? _db.collection('ilanlar').where('satici_id', isEqualTo: widget.bayiId).where('aktif_mi', isEqualTo: true).snapshots()
                : _db.collection('ilanlar').where('satici_id', isEqualTo: widget.bayiId).where('kategori', isEqualTo: _seciliKategori).where('aktif_mi', isEqualTo: true).snapshots(),
            builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
            return const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(50), child: Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan))));
            }

            final ilanlar = snapshot.data?.docs ?? [];

            if (ilanlar.isEmpty) {
            return SliverToBoxAdapter(
            child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
            children: [
            Icon(Icons.radar, size: 64, color: temaRengi.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text("BU KATEGORİDE İLAN YOK", style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.bold, letterSpacing: 2, fontFamily: 'Avenir')),
            ],
            ),
            ),
            );
            }

            return SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75, // Dikdörtgen İlan Kartı
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
            (context, index) {
            var ilan = ilanlar[index].data() as Map<String, dynamic>;
            String baslik = ilan['baslik'] ?? 'İlan';
            double fiyat = (ilan['fiyat'] ?? 0).toDouble();
            String gorsel = ilan['gorsel_url'] ?? '';
            String kategori = ilan['kategori'] ?? '';

            return _buildIlanKarti(baslik, fiyat, gorsel, kategori, temaRengi);
            },
            childCount: ilanlar.length,
            ),
            ),
            );
            },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)), // Alt boşluk
            ],
            );
          },
        ),
      ),
    );
  }

  // --- SİBER İLAN KARTI (Premium Glassmorphism) ---
  Widget _buildIlanKarti(String baslik, double fiyat, String gorsel, String kategori, Color temaRengi) {
    return Container(
      decoration: BoxDecoration(
        color: SiberTema.matGrey.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // İlan Görseli
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    color: SiberTema.oledBlack,
                    child: gorsel.isNotEmpty
                        ? Image.network(gorsel, fit: BoxFit.cover)
                        : const Icon(Icons.image_not_supported, color: Colors.white24, size: 40),
                  ),
                ),
                // İlan Detayları
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(baslik, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir', height: 1.2)),
                        Text("₺${fiyat.toStringAsFixed(2)}", style: TextStyle(color: temaRengi, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Kategori Etiketi (Sol Üst)
            Positioned(
              top: 8,
              left: 8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: SiberTema.oledBlack.withOpacity(0.6), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white.withOpacity(0.1))),
                    child: Text(kategori, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHataEkrani(String mesaj) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: SiberTema.kanKirmizi, size: 64),
          const SizedBox(height: 16),
          Text(mesaj, style: const TextStyle(color: SiberTema.kanKirmizi, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: SiberTema.matGrey, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context),
            child: const Text("KARARGAHA DÖN"),
          )
        ],
      ),
    );
  }
}

// Slivers için yapışkan (sticky) başlık delegesi
class _SiberKategoriDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _SiberKategoriDelegate({required this.child});

  @override
  double get minExtent => 60.0;
  @override
  double get maxExtent => 60.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SiberKategoriDelegate oldDelegate) => true;
}