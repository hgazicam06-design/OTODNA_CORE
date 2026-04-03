// lib/screens/market_ana_sayfa.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM GLOBAL MARKET VİTRİNİ (SiberMarketAnaSayfa)
/// Firebase'den canlı ürünleri çeker, tedarikçi adlarını gizleyerek tüm ürünleri "MURAT PLAZA" adıyla satar.
class SiberMarketAnaSayfa extends StatelessWidget {
  const SiberMarketAnaSayfa({super.key});

  // ── 🎨 KARARGAH TASARIM DOKTRİNİ ──
  static const Color _oledBlack = Color(0xFF000000);
  static const Color _matGrey = Color(0xFF111111);
  static const Color _kuantumCyan = Color(0xFF00FFC2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _oledBlack,
      appBar: AppBar(
        title: const Text("OTODNA GLOBAL MARKET", style: TextStyle(color: _kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 14)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kuantumCyan),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 📡 SİBER NOT: Ürünler Karargah veritabanından canlı akıyor!
        stream: FirebaseFirestore.instance.collection('market_urunleri').orderBy('eklenme_tarihi', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _kuantumCyan));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("SİBER ONAY: Vitrinde henüz ürün bulunmuyor.", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
            );
          }

          return GridView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var urunVerisi = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return _buildSiberUrunKarti(urunVerisi);
            },
          );
        },
      ),
    );
  }

  // ── 🛡️ KARARGAH ROZET MOTORU (1-5 YILDIZ KURALI) ──
  Map<String, dynamic> _getKarargahRozeti(double puan) {
    int yuvarlanmisPuan = puan.round();
    if (yuvarlanmisPuan >= 5) return {'isim': 'GOLD BAYİ', 'ikon': Icons.workspace_premium, 'renk': Colors.amberAccent};
    if (yuvarlanmisPuan == 4) return {'isim': 'SILVER BAYİ', 'ikon': Icons.stars, 'renk': Colors.blueGrey[300]!};
    if (yuvarlanmisPuan == 3) return {'isim': 'BRONZE BAYİ', 'ikon': Icons.star_border, 'renk': Colors.deepOrangeAccent};
    if (yuvarlanmisPuan == 2) return {'isim': 'STANDART', 'ikon': Icons.shield_outlined, 'renk': Colors.white54};
    // 1 ve altı Karalisteye düşer!
    return {'isim': 'BLACKLIST', 'ikon': Icons.gavel, 'renk': Colors.redAccent};
  }

  // ── 🛒 SİBER ÜRÜN KARTI ──
  Widget _buildSiberUrunKarti(Map<String, dynamic> urun) {
    double fiyat = (urun['fiyat'] ?? 0).toDouble();
    double puan = (urun['puan'] ?? 0).toDouble();

    // 🔥 KARARGAH STRATEJİSİ: Arka planda kim satarsa satsın, vitrinde sadece Murat Plaza görünür!
    String vitrinSaticiAdi = "MURAT PLAZA";
    Map<String, dynamic> rozet = _getKarargahRozeti(puan);

    return Container(
      decoration: BoxDecoration(
          color: _matGrey,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
          boxShadow: [
            BoxShadow(color: _kuantumCyan.withOpacity(0.05), blurRadius: 10, spreadRadius: 1),
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ÜRÜN GÖRSELİ (Siber Cam Efekti / Placeholder)
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: _kuantumCyan.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Icon(Icons.precision_manufacturing_outlined, size: 60, color: _kuantumCyan),
            ),
          ),

          // ÜRÜN BİLGİLERİ VE ROZET
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // MURAT PLAZA ETİKETİ VE ROZET
                Row(
                  children: [
                    Icon(rozet['ikon'], size: 14, color: rozet['renk']),
                    const SizedBox(width: 4),
                    Expanded(child: Text(vitrinSaticiAdi, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: rozet['renk'], letterSpacing: 1), overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 8),

                // ÜRÜN ADI
                Text(urun['ad'] ?? "Bilinmeyen Ürün", maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, height: 1.2)),
                const SizedBox(height: 8),

                // FİYAT
                Text("₺${fiyat.toStringAsFixed(2)}", style: const TextStyle(color: _kuantumCyan, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
                const SizedBox(height: 12),

                // SİBER SATIN AL BUTONU
                SizedBox(
                  width: double.infinity,
                  height: 35,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      developer.log("💰 SİBER SATIŞ: ${urun['ad']} sepete eklendi. Gerçek Tedarikçi Gizlendi, Satış Murat Plaza üzerinden işleniyor.");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kuantumCyan,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text("SEPETE EKLE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}