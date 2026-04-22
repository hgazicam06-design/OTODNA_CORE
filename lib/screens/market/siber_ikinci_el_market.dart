import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/siber_tema.dart';
import '../../models/car_ad_model.dart';
import 'siber_ilan_detay_screen.dart';
import 'siber_ilan_ver_terminali.dart';

class SiberIkinciElMarket extends StatefulWidget {
  const SiberIkinciElMarket({super.key});

  @override
  State<SiberIkinciElMarket> createState() => _SiberIkinciElMarketState();
}

class _SiberIkinciElMarketState extends State<SiberIkinciElMarket> {
  static const Color primaryCyan = SiberTema.kuantumCyan;
  static const Color siberGold = SiberTema.siberGold;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: SiberTema.siberArkaPlan)),
          SafeArea(
            child: Column(
              children: [
                _buildSiberAppBar(),
                _buildAramaVeFiltreKalkani(),
                Expanded(child: _buildIlanVitrinRadari()),
                _buildYeniIlanTerminalButonu(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiberAppBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), border: const Border(bottom: BorderSide(color: Colors.white10))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle), child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18)),
              ),
              const Text('K U A N T U M   G A L E R İ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 3, fontFamily: 'Avenir')),
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: primaryCyan.withOpacity(0.5))), child: const Icon(Icons.storefront, color: primaryCyan, size: 18)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAramaVeFiltreKalkani() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
              child: TextField(
                style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Avenir'),
                decoration: InputDecoration(
                  hintText: "Siber ağda araç ara...",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  border: InputBorder.none,
                  icon: const Icon(Icons.search, color: Colors.white54, size: 20),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryCyan.withOpacity(0.3))),
            child: const Icon(Icons.tune, color: primaryCyan, size: 20),
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
          return const Center(child: CircularProgressIndicator(color: primaryCyan));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome_mosaic_outlined, size: 64, color: Colors.white.withOpacity(0.1)),
                const SizedBox(height: 16),
                const Text("VİTRİN BOŞ", style: TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
              ],
            ),
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    String coverImg = ad.images.isNotEmpty ? ad.images.first : 'https://via.placeholder.com/300x200/111111/00FFC2?text=SİBER+GÖRSEL';
    
    // Fiyat formatlama (Virgülsüz ve 0 lı, Örn: 1.250.000)
    String formatliFiyat = "₺${ad.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => SiberIlanDetayScreen(ad: ad)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 120, // Sabit liste yüksekliği
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ad.otodnaReferansliMi ? primaryCyan.withOpacity(0.3) : Colors.white10),
        ),
        child: Row(
          children: [
            // SOL: GÖRSEL ALANI
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
              child: SizedBox(
                width: 140,
                height: 120,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(coverImg, fit: BoxFit.cover),
                    // Kuantum Çerçeve Efekti
                    Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Colors.transparent, Colors.black.withOpacity(0.5)]))),
                  ],
                ),
              ),
            ),
            
            // SAĞ: DETAYLAR
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Marka / Model
                    Text(ad.brandModel.toUpperCase(), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, fontFamily: 'Avenir', height: 1.2)),
                    
                    // Fiyat ve Kapora Etiketi
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(formatliFiyat, style: const TextStyle(color: primaryCyan, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                        if (ad.isSecureDeposit)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: siberGold.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: siberGold.withOpacity(0.3))),
                            child: const Text("GÜVENLİ KAPORA", style: TextStyle(color: siberGold, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                          )
                      ],
                    ),

                    // En alt satır: Satıcı ve OtoDNA Mührü
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(ad.saticiAdi, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 10, fontFamily: 'Avenir'))),
                        if (ad.otodnaReferansliMi)
                          const Icon(Icons.verified, color: primaryCyan, size: 14)
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), border: const Border(top: BorderSide(color: Colors.white10))),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryCyan.withOpacity(0.1),
            foregroundColor: primaryCyan,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            side: BorderSide(color: primaryCyan.withOpacity(0.5)),
            elevation: 0,
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SiberIlanVerTerminali()));
          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text("KARARGAHA İLAN GİR", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
        ),
      ),
    );
  }
}
