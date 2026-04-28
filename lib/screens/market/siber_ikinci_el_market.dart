import 'package:otodna/core/siber_tema.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../core/siber_tema.dart';
import '../../models/car_ad_model.dart';
// import 'siber_ilan_detay_screen.dart'; // go_router handle edecek
// import 'siber_ilan_ver_terminali.dart'; // go_router handle edecek

class SiberIkinciElMarket extends StatefulWidget {
  SiberIkinciElMarket({super.key});

  @override
  State<SiberIkinciElMarket> createState() => _SiberIkinciElMarketState();
}

class _SiberIkinciElMarketState extends State<SiberIkinciElMarket> {
  // 🏢 FİLDİŞİ SEDEF PALET
  final Color bgColor = Color(0xFFFDFBF7);
  final Color surfaceColor = Colors.white;
  final Color primaryTeal = Colors.teal.shade700;
  final Color textMain = Color(0xFF1E293B);
  final Color textMuted = Color(0xFF64748B);
  static Color siberGold = SiberTema.siberGold;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildSiberAppBar(),
            _buildAramaVeFiltreKalkani(),
            Expanded(child: _buildIlanVitrinRadari()),
            _buildYeniIlanTerminalButonu(),
          ],
        ),
      ),
    );
  }

  Widget _buildSiberAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(color: bgColor, border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.pop(), // Back button works with context.pop
            child: Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle), child: Icon(Icons.arrow_back_ios_new, color: textMain, size: 18)),
          ),
          Text('K U A N T U M   G A L E R İ', style: TextStyle(color: textMain, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 3, fontFamily: 'Avenir')),
          Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: primaryTeal.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: primaryTeal.withOpacity(0.3))), child: Icon(Icons.storefront, color: primaryTeal, size: 18)),
        ],
      ),
    );
  }

  Widget _buildAramaVeFiltreKalkani() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05)), boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.02), blurRadius: 10)]),
              child: TextField(
                style: TextStyle(color: textMain, fontSize: 13, fontFamily: 'Avenir'),
                decoration: InputDecoration(
                  hintText: "Siber ağda araç ara...",
                  hintStyle: TextStyle(color: textMuted.withOpacity(0.5)),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: textMuted, size: 20),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryTeal.withOpacity(0.3)), boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.02), blurRadius: 10)]),
            child: Icon(Icons.tune, color: primaryTeal, size: 20),
          )
        ],
      ),
    );
  }

  Widget _buildIlanVitrinRadari() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('vehicles_ads')
                 .where('ilan_durumu', isEqualTo: 'Yayında')
                 .orderBy('ilan_tarihi', descending: true)
                 .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: primaryTeal));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome_mosaic_outlined, size: 64, color: Colors.white12),
                SizedBox(height: 16),
                Text("VİTRİN BOŞ", style: TextStyle(color: textMuted, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
              ],
            ),
          );
        }

        return ListView.builder(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            CarAd ad = CarAd.fromFirestore(snapshot.data!.docs[index]);
            return _buildIlanKarti(ad);
          },
        );
      },
    );
  }

  Widget _buildIlanKarti(CarAd ad) {
    // Sahibinden Listeleme Stili: Solda Görsel, Sağda Detaylar
    String coverImg = ad.images.isNotEmpty ? ad.images.first : 'https://via.placeholder.com/300x200/FDFBF7/00796B?text=SİBER+GÖRSEL';
    
    // Fiyat formatlama (Virgülsüz ve 0 lı, Örn: 1.250.000)
    String formatliFiyat = "₺${ad.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";

    return GestureDetector(
      onTap: () {
        context.push('/ilan_detay', extra: ad);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        height: 120, // Sabit liste yüksekliği
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ad.otodnaReferansliMi ? primaryTeal.withOpacity(0.3) : Colors.black.withOpacity(0.05)),
          boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.02), blurRadius: 10)]
        ),
        child: Row(
          children: [
            // SOL: GÖRSEL ALANI
            ClipRRect(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
              child: SizedBox(
                width: 140,
                height: 120,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(coverImg, fit: BoxFit.cover),
                    // Kuantum Çerçeve Efekti (Sedefte hafif beyaz gradient daha iyi olabilir)
                    Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Colors.transparent, Colors.white.withOpacity(0.5)]))),
                  ],
                ),
              ),
            ),
            
            // SAĞ: DETAYLAR
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Marka / Model
                    Text(ad.brandModel.toUpperCase(), maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: textMain, fontSize: 13, fontWeight: FontWeight.w900, fontFamily: 'Avenir', height: 1.2)),
                    
                    // Fiyat ve Kapora Etiketi
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(formatliFiyat, style: TextStyle(color: primaryTeal, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                        if (ad.isSecureDeposit)
                          Container(
                            margin: EdgeInsets.only(top: 4),
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: siberGold.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: siberGold.withOpacity(0.3))),
                            child: Text("GÜVENLİ KAPORA", style: TextStyle(color: siberGold, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                          )
                      ],
                    ),

                    // En alt satır: Satıcı ve OtoDNA Mührü
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(ad.saticiAdi, overflow: TextOverflow.ellipsis, style: TextStyle(color: textMuted, fontSize: 10, fontFamily: 'Avenir'))),
                        if (ad.otodnaReferansliMi)
                          Icon(Icons.verified, color: primaryTeal, size: 14)
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildYeniIlanTerminalButonu() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(color: bgColor, border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05)))),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryTeal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          onPressed: () {
            context.push('/ilan_ver_terminali');
          },
          icon: Icon(Icons.add, size: 18),
          label: Text("KARARGAHA İLAN GİR", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
        ),
      ),
    );
  }
}
