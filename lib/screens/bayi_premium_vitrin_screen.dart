import 'package:otodna/core/siber_tema.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

class BayiPremiumVitrinScreen extends StatefulWidget {
  final String bayiId;
  BayiPremiumVitrinScreen({super.key, required this.bayiId});

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
      case 'ELMAS': return Colors.purpleAccent;
      case 'ALTIN': return SiberTema.altinSari;
      case 'GUMUS': return Colors.grey.shade400;
      case 'BRONZ': return Colors.deepOrangeAccent;
      default: return SiberTema.kuantumCyan;
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
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent, // Kalkan arka planı kontrol ediyor
        body: StreamBuilder<DocumentSnapshot>(
          stream: _db.collection('kullanicilar').doc(widget.bayiId).snapshots(),
          builder: (context, bayiSnapshot) {
            if (bayiSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan, strokeWidth: 3));
            }

            if (!bayiSnapshot.hasData || !bayiSnapshot.data!.exists) {
              return _buildHataEkrani("SİCİL BULUNAMADI: Bu bayi Kuantum Ağında yok.");
            }

            var bayiData = bayiSnapshot.data!.data() as Map<String, dynamic>;

            // ── FİREBASE VERİLERİ ──
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
              physics: BouncingScrollPhysics(),
              slivers: [
                // ── 1. HOLOGRAFİK KAPAK (SliverAppBar) ──
                SliverAppBar(
                  expandedHeight: 300.0,
                  pinned: true,
                  stretch: true,
                  backgroundColor: SiberTema.oledBlack,
                  leading: IconButton(
                    icon: ClipRRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle, border: Border.all(color: temaRengi.withOpacity(0.5))),
                          child: Icon(Icons.arrow_back_ios_new, color: temaRengi, size: 16),
                        ),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: [StretchMode.zoomBackground, StretchMode.blurBackground],
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        kapakFoto.isNotEmpty
                            ? Image.network(kapakFoto, fit: BoxFit.cover)
                            : Container(color: SiberTema.matGrey),

                        // Siber Gradient Kalkanı
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, SiberTema.oledBlack.withOpacity(0.8), SiberTema.oledBlack],
                              stops: [0.4, 0.8, 1.0],
                            ),
                          ),
                        ),

                        // Bayi Kimlik Bloğu
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildSiberLogo(logoFoto, temaRengi),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildRutbeEtiketi(paket, temaRengi),
                                    SizedBox(height: 8),
                                    Text(firmaAdi.toUpperCase(),
                                        style: TextStyle(color: SiberTema.textMain, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
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

                // ── 2. KARARGAH BİLGİLERİ ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBilgiKarti(yetkiliIsim, calismaSaatleri, temaRengi),
                        SizedBox(height: 24),
                        _sectionBaslik("KARARGAH HAKKINDA", temaRengi),
                        SizedBox(height: 8),
                        Text(hakkinda, style: TextStyle(color: SiberTema.textMain.withOpacity(0.7), fontSize: 13, height: 1.5, fontFamily: 'Avenir')),
                        SizedBox(height: 24),
                        if (isYeriFotolari.isNotEmpty) _buildFotoGaleri(isYeriFotolari, temaRengi),
                      ],
                    ),
                  ),
                ),

                // ── 3. VİTRİN RADARI (Sticky Header) ──
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SiberKategoriDelegate(
                    child: ClipRRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          color: SiberTema.oledBlack.withOpacity(0.8),
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: _buildKategoriListesi(temaRengi),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── 4. SİBER İLAN AĞI ──
                _buildIlanGrid(temaRengi),

                SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSiberLogo(String url, Color renk) {
    return Container(
      width: 85,
      height: 85,
      decoration: BoxDecoration(
        color: SiberTema.matGrey,
        shape: BoxShape.circle,
        border: Border.all(color: renk, width: 2),
        boxShadow: [BoxShadow(color: renk.withOpacity(0.3), blurRadius: 15, spreadRadius: 2)],
        image: url.isNotEmpty ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover) : null,
      ),
      child: url.isEmpty ? Icon(Icons.store, color: renk, size: 40) : null,
    );
  }

  Widget _buildRutbeEtiketi(String paket, Color renk) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: renk.withOpacity(0.15), borderRadius: BorderRadius.circular(8), border: Border.all(color: renk.withOpacity(0.5))),
        child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
            Icon(_getRütbeIkoni(paket), color: renk, size: 12),
    SizedBox(width: 6),
    Text("$paket BAYİ", style: TextStyle(color: renk, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
    ],
    ),
    );
  }

  Widget _buildBilgiKarti(String yetkili, String saat, Color renk) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: SiberTema.siberCamDekoru(borderColor: Colors.white10),
      child: Row(
        children: [
          Expanded(child: _bilgiSutun("SİBER YETKİLİ", yetkili, Icons.admin_panel_settings, renk)),
          Container(width: 1, height: 30, color: SiberTema.textMuted),
          Expanded(child: _bilgiSutun("MESAİ SAATLERİ", saat, Icons.access_time, SiberTema.kuantumCyan)),
        ],
      ),
    );
  }

  Widget _bilgiSutun(String baslik, String deger, IconData ikon, Color renk) {
    return Column(
      children: [
        Text(baslik, style: TextStyle(color: SiberTema.textMuted, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)),
        SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(ikon, color: renk, size: 14),
            SizedBox(width: 6),
            Flexible(child: Text(deger, style: TextStyle(color: SiberTema.textMain, fontSize: 12, fontWeight: FontWeight.w900))),
          ],
        ),
      ],
    );
  }

  Widget _buildFotoGaleri(List<dynamic> fotolar, Color renk) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        itemCount: fotolar.length,
        itemBuilder: (context, index) => Container(
          width: 160,
          margin: EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: renk.withOpacity(0.2)),
            image: DecorationImage(image: NetworkImage(fotolar[index]), fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  Widget _buildKategoriListesi(Color renk) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: _kategoriler.map((kat) {
          bool isSelected = _seciliKategori == kat;
          return GestureDetector(
            onTap: () => setState(() => _seciliKategori = kat),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 250),
              margin: EdgeInsets.only(right: 10),
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? renk.withOpacity(0.2) : Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? renk : Colors.white10),
              ),
              child: Text(kat, style: TextStyle(color: isSelected ? renk : Colors.white38, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildIlanGrid(Color renk) {
    return StreamBuilder<QuerySnapshot>(
      stream: _seciliKategori == 'TÜMÜ'
          ? _db.collection('ilanlar').where('satici_id', isEqualTo: widget.bayiId).where('aktif_mi', isEqualTo: true).snapshots()
          : _db.collection('ilanlar').where('satici_id', isEqualTo: widget.bayiId).where('kategori', isEqualTo: _seciliKategori).where('aktif_mi', isEqualTo: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: SiberTema.kuantumCyan))));

        final ilanlar = snapshot.data?.docs ?? [];
        if (ilanlar.isEmpty) return _buildBosIlanMesaji(renk);

        return SliverPadding(
          padding: EdgeInsets.all(20),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                var ilan = ilanlar[index].data() as Map<String, dynamic>;
                return _buildIlanKarti(ilan, renk);
              },
              childCount: ilanlar.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildIlanKarti(Map<String, dynamic> ilan, Color renk) {
    String baslik = ilan['baslik'] ?? 'İsimsiz İlan';
    double fiyat = (ilan['fiyat'] ?? 0).toDouble();
    String gorsel = ilan['gorsel_url'] ?? '';

    return Container(
      decoration: SiberTema.siberCamDekoru(borderColor: Colors.white.withOpacity(0.05)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: gorsel.isNotEmpty
                  ? Image.network(gorsel, fit: BoxFit.cover, width: double.infinity)
                  : Container(color: SiberTema.oledBlack, child: Icon(Icons.image_not_supported, color: SiberTema.textMuted)),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(baslik, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text("₺${fiyat.toStringAsFixed(0)}", style: TextStyle(color: renk, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBosIlanMesaji(Color renk) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(Icons.radar, size: 48, color: renk.withOpacity(0.1)),
            SizedBox(height: 16),
            Text("BU RADARDA İLAN YOK", style: TextStyle(color: SiberTema.textMuted, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2)),
          ],
        ),
      ),
    );
  }

  Widget _sectionBaslik(String baslik, Color renk) {
    return Text(baslik, style: TextStyle(color: renk, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2));
  }

  Widget _buildHataEkrani(String mesaj) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: SiberTema.kanKirmizi, size: 50),
          SizedBox(height: 16),
          Text(mesaj, style: TextStyle(color: SiberTema.kanKirmizi, fontWeight: FontWeight.bold)),
          SizedBox(height: 24),
          TextButton(onPressed: () => Navigator.pop(context), child: Text("GERİ DÖN", style: TextStyle(color: SiberTema.textMuted))),
        ],
      ),
    );
  }
}

class _SiberKategoriDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _SiberKategoriDelegate({required this.child});

  @override double get minExtent => 65.0;
  @override double get maxExtent => 65.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => SizedBox.expand(child: child);

  @override bool shouldRebuild(_SiberKategoriDelegate oldDelegate) => true;
}