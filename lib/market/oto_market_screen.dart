import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🔥 SİBER KÖPRÜLER
import '../core/siber_tema.dart';
import 'urun_detay_screen.dart'; // TRENDYOL FORMATLI DETAY EKRANI KÖPRÜSÜ
import 'urun_giris_terminali.dart'; // 🚀 TEDARİK TERMİNALİ KÖPRÜSÜ

class OtoMarketScreen extends StatefulWidget {
  const OtoMarketScreen({super.key});

  @override
  State<OtoMarketScreen> createState() => _OtoMarketScreenState();
}

class _OtoMarketScreenState extends State<OtoMarketScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const Color primaryCyan = SiberTema.kuantumCyan;
  static const Color siberGold = SiberTema.siberGold;

  String _aramaMetni = "";
  late String _aktifKullaniciId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _aktifKullaniciId = _auth.currentUser?.uid ?? "ZİYARETÇİ";
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // =======================================================================
  // 💎 MİNİMALİST ROZET ALGORİTMASI
  // =======================================================================
  Widget _buildSaticiRozeti(int puan, String saticiAdi) {
    Color rozetRengi;
    IconData ikon = Icons.star_rounded;
    String rozetMetni;

    if (puan >= 5) { rozetRengi = siberGold; rozetMetni = "Premium Onaylı"; }
    else if (puan == 4) { rozetRengi = Colors.grey[300]!; rozetMetni = "Güvenilir"; }
    else if (puan == 3) { rozetRengi = Colors.brown[300]!; rozetMetni = "Standart"; }
    else if (puan == 2) {
      return Row(children: [const Icon(Icons.star_border_rounded, color: Colors.white38, size: 14), const SizedBox(width: 6), Text(saticiAdi.toUpperCase(), style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir'))]);
    }
    else {
      return Row(
        children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: SiberTema.kanKirmizi.withOpacity(0.1), border: Border.all(color: SiberTema.kanKirmizi.withOpacity(0.5)), borderRadius: BorderRadius.circular(6)), child: const Row(children: [Icon(Icons.gpp_bad_outlined, color: SiberTema.kanKirmizi, size: 12), SizedBox(width: 4), Text("KARA LİSTE", style: const TextStyle(color: SiberTema.kanKirmizi, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1))])),
          const SizedBox(width: 8),
          Expanded(child: Text(saticiAdi, style: TextStyle(color: SiberTema.kanKirmizi.withOpacity(0.5), fontSize: 11, decoration: TextDecoration.lineThrough, fontFamily: 'Avenir'), overflow: TextOverflow.ellipsis)),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: rozetRengi.withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: rozetRengi.withOpacity(0.3))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikon, color: rozetRengi, size: 14),
          const SizedBox(width: 6),
          Expanded(child: Text("$saticiAdi ($rozetMetni)".toUpperCase(), style: TextStyle(color: rozetRengi, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5, fontFamily: 'Avenir'), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  // =======================================================================
  // 💎 ANA İSKELET (GLASSMORPHISM)
  // =======================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. KUANTUM ARKA PLAN
          Positioned.fill(child: Container(decoration: SiberTema.siberArkaPlan)),
          
          SafeArea(
            child: Column(
              children: [
                _buildSiberAppBar(),
                _buildSiberTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildOtoMarketSekmesi(),
                      _buildOtoGaleriSekmesi(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryCyan,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: _siberIlanVerDialog,
        icon: const Icon(Icons.add_a_photo_outlined, color: Colors.black, size: 20),
        label: const Text("İLAN VER", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1, fontFamily: 'Avenir')),
      ),
    );
  }

  Widget _buildSiberAppBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            border: const Border(bottom: BorderSide(color: Colors.white10)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios_new, color: primaryCyan, size: 20),
              ),
              const Text('S İ B E R   P A Z A R', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 4, fontFamily: 'Avenir')),
              const Icon(Icons.shopping_cart_outlined, color: primaryCyan, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSiberTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 48,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white10)),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(color: primaryCyan, borderRadius: BorderRadius.circular(24)),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.white38,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5, fontFamily: 'Avenir'),
              tabs: const [Tab(text: "Parça Pazarı"), Tab(text: "Oto Galeri")],
            ),
          ),
        ),
      ),
    );
  }

  // ─── 1. SEKME: CANLI OTO MARKET ───
  Widget _buildOtoMarketSekmesi() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            children: [
              _buildAiAramaKutusu(),
              const SizedBox(height: 16),
              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: primaryCyan.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryCyan.withOpacity(0.2))), child: const Row(children: [Icon(Icons.shield_outlined, color: primaryCyan, size: 20), SizedBox(width: 12), Expanded(child: Text("Bireysel ve Kurumsal tüm satıcılar OtoDNA güvencesindedir.", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, height: 1.4, fontFamily: 'Avenir')))]))
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _db.collection('ilanlar')
                .where('kategori', isNotEqualTo: 'Araç Satış')
                .orderBy('kategori')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: primaryCyan));
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("Siber ağda parça bulunmuyor.", style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold, fontFamily: 'Avenir')));

              var urunler = snapshot.data!.docs.where((doc) {
                var veri = doc.data() as Map<String, dynamic>;
                String ad = (veri['ilan_ad'] ?? "").toString().toLowerCase();
                return ad.contains(_aramaMetni.toLowerCase());
              }).toList();

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                physics: const BouncingScrollPhysics(),
                itemCount: urunler.length,
                itemBuilder: (context, index) {
                  var veri = urunler[index].data() as Map<String, dynamic>;
                  String ilanId = urunler[index].id;
                  double fiyatDouble = (veri['fiyat'] ?? 0).toDouble();

                  return _buildParcaKarti(
                    ilanId: ilanId,
                    veri: veri, // Trendyol ekranına tüm veriyi atacağız
                    baslik: veri['ilan_ad'] ?? "Bilinmeyen Parça",
                    satici: veri['vitrin_etiketi'] ?? "Bilinmeyen Satıcı",
                    saticiPuani: 5,
                    fiyatDouble: fiyatDouble,
                    resimUrl: veri['resim_url'] ?? "https://via.placeholder.com/300x300/000000/00FFC2?text=OtoDNA",
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── 2. SEKME: CANLI OTO GALERİ ───
  Widget _buildOtoGaleriSekmesi() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: siberGold.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: siberGold.withOpacity(0.2))), child: const Row(children: [Icon(Icons.diamond_outlined, color: siberGold, size: 20), SizedBox(width: 12), Expanded(child: Text("OtoDNA Onaylı (VIP) Araçlar Kuantum algoritmasıyla üstte gösterilir.", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, height: 1.4, fontFamily: 'Avenir')))])),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _db.collection('araclar').where('durum', isEqualTo: 'Sahibinden').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: primaryCyan));
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("Siber galeride araç bulunmuyor.", style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold, fontFamily: 'Avenir')));

              var araclar = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                physics: const BouncingScrollPhysics(),
                itemCount: araclar.length,
                itemBuilder: (context, index) {
                  var veri = araclar[index].data() as Map<String, dynamic>;
                  bool isOtoDna = (veri['dna_skoru'] ?? 0) >= 80;

                  return _buildAracIlanKarti(
                    aracAdi: "${veri['marka'] ?? ''} ${veri['model'] ?? ''}",
                    detay: "${veri['yil'] ?? '-'} Model • ${veri['km'] ?? '0'} KM",
                    fiyat: "₺${veri['fiyat'] ?? 0}",
                    dnaSkoru: (veri['dna_skoru'] ?? 0).toDouble(),
                    resimUrl: veri['resim_url'] ?? "https://via.placeholder.com/300x150/000000/00FFC2?text=OtoDNA",
                    isOtoDnaOnayli: isOtoDna,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── YARDIMCI GÖRSEL BİLEŞENLER ───
  Widget _buildAiAramaKutusu() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
          child: TextField(
            onChanged: (deger) => setState(() => _aramaMetni = deger),
            style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Avenir'),
            decoration: InputDecoration(
              hintText: "OEM Kodu, Şase veya Parça Ara...",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 13, fontFamily: 'Avenir'),
              prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
              suffixIcon: IconButton(icon: const Icon(Icons.document_scanner_outlined, color: primaryCyan, size: 20), onPressed: () {}),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 YENİ NESİL ÜRÜN KARTI (TRENDYOL ÜRÜN DETAYINA GİDER)
  Widget _buildParcaKarti({required String ilanId, required Map<String, dynamic> veri, required String baslik, required String satici, required int saticiPuani, required double fiyatDouble, required String resimUrl}) {
    bool isKaraListe = saticiPuani <= 1;

    return GestureDetector(
      onTap: () {
        if (!isKaraListe) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => UrunDetayScreen(ilanId: ilanId, urunVerisi: veri)));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AĞ UYARISI: Bu satıcı Kara Liste\'dedir.', style: TextStyle(color: Colors.white)), backgroundColor: SiberTema.kanKirmizi));
        }
      },
      child: Opacity(
        opacity: isKaraListe ? 0.4 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isKaraListe ? SiberTema.kanKirmizi.withOpacity(0.3) : Colors.white10),
            boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.02), blurRadius: 20)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 180, width: double.infinity,
                decoration: BoxDecoration(color: Colors.black, borderRadius: const BorderRadius.vertical(top: Radius.circular(24)), image: DecorationImage(image: NetworkImage(resimUrl), fit: BoxFit.cover)),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(baslik, style: TextStyle(color: isKaraListe ? SiberTema.kanKirmizi : Colors.white, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.5, decoration: isKaraListe ? TextDecoration.lineThrough : TextDecoration.none, fontFamily: 'Avenir')),
                    const SizedBox(height: 16),
                    Text("₺${fiyatDouble.toStringAsFixed(2)}", style: TextStyle(color: isKaraListe ? SiberTema.kanKirmizi.withOpacity(0.5) : primaryCyan, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -1, fontFamily: 'Avenir')),
                    const SizedBox(height: 20),
                    _buildSaticiRozeti(saticiPuani, satici),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAracIlanKarti({required String aracAdi, required String detay, required String fiyat, required double dnaSkoru, required String resimUrl, required bool isOtoDnaOnayli}) {
    Color dnaRengi = dnaSkoru >= 80 ? primaryCyan : (dnaSkoru >= 50 ? siberGold : SiberTema.kanKirmizi);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(32), border: Border.all(color: isOtoDnaOnayli ? primaryCyan.withOpacity(0.5) : Colors.white10), boxShadow: isOtoDnaOnayli ? [BoxShadow(color: primaryCyan.withOpacity(0.05), blurRadius: 30)] : []),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(height: 200, decoration: BoxDecoration(color: Colors.black, borderRadius: const BorderRadius.vertical(top: Radius.circular(32)), image: DecorationImage(image: NetworkImage(resimUrl), fit: BoxFit.cover))),
              if (isOtoDnaOnayli)
                Positioned(top: 16, left: 16, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.black.withOpacity(0.9), borderRadius: BorderRadius.circular(12), border: Border.all(color: primaryCyan.withOpacity(0.5))), child: const Row(children: [Icon(Icons.qr_code_scanner_outlined, color: primaryCyan, size: 16), SizedBox(width: 8), Text("OtoDNA ONAYLI", style: TextStyle(color: primaryCyan, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir'))]))),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(aracAdi, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5, fontFamily: 'Avenir'), overflow: TextOverflow.ellipsis, maxLines: 2)),
                    const SizedBox(width: 16),
                    Text(fiyat, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -1, fontFamily: 'Avenir')),
                  ],
                ),
                const SizedBox(height: 12),
                Text(detay, style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider(color: Colors.white12)),
                Row(
                  children: [
                    Text("SİBER GENETİK SKORU", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                    const Spacer(),
                    Text("%${dnaSkoru.toInt()}", style: TextStyle(color: dnaRengi, fontSize: 20, fontWeight: FontWeight.w900, shadows: [BoxShadow(color: dnaRengi.withOpacity(0.5), blurRadius: 10)], fontFamily: 'Avenir')),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: dnaSkoru / 100, minHeight: 6, backgroundColor: Colors.white.withOpacity(0.05), color: dnaRengi)),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _siberIlanVerDialog() {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.black.withOpacity(0.9), isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("SİBER İLAN TERMİNALİ", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')), IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => Navigator.pop(ctx))]),
              const SizedBox(height: 24),
              _buildIlanSecenekKarti("Yedek Parça & Aksesuar", "Bireysel ve kurumsal serbest piyasa ilanı oluşturun.", Icons.settings_outlined, primaryCyan, () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const UrunGirisTerminali()));
              }),
              const SizedBox(height: 16),
              _buildIlanSecenekKarti("Otomobil & Taşıt (Galeri)", "OtoDNA kalkanlı araçlarınızı siber ağa mühürleyin.", Icons.directions_car_outlined, siberGold, () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("SİBER BİLGİ: Araç İlan Ekranı Açılıyor...")));
              }),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIlanSecenekKarti(String baslik, String altBaslik, IconData ikon, Color renk, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(24), border: Border.all(color: renk.withOpacity(0.3))),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: renk.withOpacity(0.1), shape: BoxShape.circle), child: Icon(ikon, color: renk, size: 24)),
            const SizedBox(width: 20),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(baslik, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Avenir')), const SizedBox(height: 8), Text(altBaslik, style: const TextStyle(color: Colors.white54, fontSize: 11, height: 1.4, fontFamily: 'Avenir'))])),
            const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16)
          ],
        ),
      ),
    );
  }
}