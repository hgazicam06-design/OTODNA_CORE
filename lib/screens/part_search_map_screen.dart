import 'package:otodna/core/siber_tema.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

/// 🦅 OTO DNA TEDARİK AĞI VE SİBER ENVANTER RADARI
/// [2026-03-28] GÜNCELLEME: KÜRESEL PARÇA TAKİBİ VE FİREBASE ENTEGRASYONU
class PartSearchMapScreen extends StatefulWidget {
  PartSearchMapScreen({super.key});

  @override
  State<PartSearchMapScreen> createState() => _PartSearchMapScreenState();
}

class _PartSearchMapScreenState extends State<PartSearchMapScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController _aramaController = TextEditingController();

  void _siberMesajGoster(String mesaj, {bool isCart = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
        backgroundColor: isCart ? Colors.orangeAccent : SiberTema.kuantumCyan,
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
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20),
              onPressed: () => Navigator.pop(context)
          ),
          title: Text("OTODNA TEDARİK AĞI", style: TextStyle(color: SiberTema.textMuted, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.shopping_cart_outlined, color: SiberTema.kuantumCyan),
              onPressed: () => _siberMesajGoster("SİBER SEPETE BAĞLANILIYOR..."),
            )
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1000),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 📡 AI SİBER RADAR (Arama Terminali)
                  _buildSiberAramaCubugu(),

                  // 🔥 SİBER FIRSAT RADARI (Kampanyalı Ürünler)
                  _buildBolumBasligi("🔥 SİBER FIRSAT RADARI", SiberTema.kuantumCyan),
                  _buildKampanyaListesi(),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Divider(color: SiberTema.textMuted, thickness: 1),
                  ),

                  // 🌍 KÜRESEL ENVANTER (Tüm Ürünler Grid)
                  _buildBolumBasligi("🌍 KÜRESEL PARÇA ENVANTERİ", Colors.white24),
                  _buildEnvanterGrid(),

                  SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSiberAramaCubugu() {
    return Container(
      margin: EdgeInsets.all(24),
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: SiberTema.matGrey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.2), width: 1.5),
      ),
      child: TextField(
        controller: _aramaController,
        style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, fontSize: 13),
        decoration: InputDecoration(
          hintText: "OEM KODU, MARKA VEYA PARÇA ARA...",
          hintStyle: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
          prefixIcon: Icon(Icons.radar, color: SiberTema.kuantumCyan, size: 20),
          suffixIcon: Icon(Icons.qr_code_scanner, color: SiberTema.textMuted, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 20),
        ),
        onSubmitted: (val) => _siberMesajGoster("AĞDA ARANIYOR: ${val.toUpperCase()}"),
      ),
    );
  }

  Widget _buildBolumBasligi(String baslik, Color renk) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(baslik, style: TextStyle(color: renk, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
    );
  }

  Widget _buildKampanyaListesi() {
    return SizedBox(
      height: 280,
      child: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('yedek_parcalar').where('kampanya', isEqualTo: true).limit(10).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return _buildBosRadar("AKTİF KAMPANYA BULUNAMADI");

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return _buildUrunKarti(data, isHorizontal: true);
            },
          );
        },
      ),
    );
  }

  Widget _buildEnvanterGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('yedek_parcalar').orderBy('tarih', descending: true).limit(30).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: SiberTema.kuantumCyan)));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return _buildBosRadar("ENVANTER KAYDI BULUNAMADI");

        return GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 24),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            childAspectRatio: 0.6,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return _buildUrunKarti(data, isHorizontal: false);
          },
        );
      },
    );
  }

  Widget _buildUrunKarti(Map<String, dynamic> data, {required bool isHorizontal}) {
    String ad = data['ad'] ?? 'BİLİNMEYEN PARÇA';
    String marka = data['marka'] ?? 'OEM';
    double fiyat = (data['fiyat'] ?? 0).toDouble();

    return Container(
      width: isHorizontal ? 180 : null,
      margin: isHorizontal ? EdgeInsets.symmetric(horizontal: 8) : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: SiberTema.matGrey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Stack(
                children: [
                  Center(child: Icon(Icons.settings_input_component, size: 40, color: SiberTema.kuantumCyan.withOpacity(0.1))),
                  Positioned(
                    top: 10, right: 10,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(Icons.verified_user, color: SiberTema.kuantumCyan, size: 12),
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(marka.toUpperCase(), style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      SizedBox(height: 4),
                      Text(ad, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("₺${fiyat.toStringAsFixed(2)}", style: TextStyle(color: SiberTema.textMain, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _siberMesajGoster("$ad SEPETE MÜHÜRLENDİ!", isCart: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SiberTema.kuantumCyan,
                            foregroundColor: SiberTema.oledBlack,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: EdgeInsets.symmetric(vertical: 10),
                            elevation: 0,
                          ),
                          child: Text("SEPETE EKLE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBosRadar(String mesaj) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.radar, color: SiberTema.textMuted, size: 50),
          SizedBox(height: 12),
          Text(mesaj, style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}