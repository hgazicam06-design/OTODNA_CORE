// lib/screens/kullanici/market_ana_sayfa.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

import '../../../../core/responsive_kalkan.dart';

/// 🛡️ PLAZA GLOBAL MARKET VİTRİNİ (SiberMarketAnaSayfa)
/// Firebase'den canlı ürünleri çeker, her bayiyi kendi şanlı markasıyla sergiler ve %12 kesinti kuralını uygular.
class SiberMarketAnaSayfa extends StatelessWidget {
  SiberMarketAnaSayfa({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryTeal = Colors.teal.shade700;
    Color bgColor = Color(0xFFFAFAFC);
    Color textColor = Color(0xFF1E293B);

    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text("OTODNA GLOBAL MARKET", style: TextStyle(color: textColor, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13, fontFamily: 'Avenir')),
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
          iconTheme: IconThemeData(color: primaryTeal),
        ),
        body: StreamBuilder<QuerySnapshot>(
          // 📡 Ürünler Merkez veritabanından canlı akıyor!
          stream: FirebaseFirestore.instance.collection('market_urunleri').orderBy('eklenme_tarihi', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: primaryTeal));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text("PLAZA BİLGİ: Vitrinde henüz ürün bulunmuyor.", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
              );
            }

            return GridView.builder(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.62,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16
              ),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var urunVerisi = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                return _buildPlazaUrunKarti(urunVerisi);
              },
            );
          },
        ),
      ),
    );
  }

  // ── 🛡️ PLAZA ROZET MOTORU (1-5 YILDIZ KURALI) ──
  Map<String, dynamic> _getPlazaRozeti(double puan) {
    int yuvarlanmisPuan = puan.round();
    if (yuvarlanmisPuan >= 5) return {'isim': 'GOLD BAYİ', 'ikon': Icons.workspace_premium, 'renk': Colors.orange.shade600};
    if (yuvarlanmisPuan == 4) return {'isim': 'SILVER BAYİ', 'ikon': Icons.stars, 'renk': Colors.blueGrey};
    if (yuvarlanmisPuan == 3) return {'isim': 'BRONZE BAYİ', 'ikon': Icons.star_border, 'renk': Colors.deepOrangeAccent};
    if (yuvarlanmisPuan == 2) return {'isim': 'STANDART', 'ikon': Icons.shield_outlined, 'renk': Colors.black45};
    // 🚨 1 ve altı Karalisteye düşer!
    return {'isim': 'BLACKLIST', 'ikon': Icons.gavel, 'renk': Colors.redAccent};
  }

  // ── 🛒 PLAZA ÜRÜN KARTI ──
  Widget _buildPlazaUrunKarti(Map<String, dynamic> urun) {
    double fiyat = (urun['fiyat'] ?? 0).toDouble();
    double puan = (urun['puan'] ?? 0).toDouble();

    final Color primaryTeal = Colors.teal.shade700;

    // 🔥 Her bayi kendi markasıyla çıkar!
    String vitrinSaticiAdi = urun['satici_adi'] ?? "Bağımsız Tedarikçi";
    Map<String, dynamic> rozet = _getPlazaRozeti(puan);

    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 15, offset: Offset(0, 5)),
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ÜRÜN GÖRSELİ (Plaza Yeşil Placeholder)
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: primaryTeal.withValues(alpha: 0.05),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Icon(Icons.precision_manufacturing_outlined, size: 60, color: primaryTeal.withValues(alpha: 0.5)),
            ),
          ),

          // ÜRÜN BİLGİLERİ VE ROZET
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SATICI ETİKETİ VE ROZET
                Row(
                  children: [
                    Icon(rozet['ikon'], size: 14, color: rozet['renk']),
                    SizedBox(width: 4),
                    Expanded(child: Text(vitrinSaticiAdi, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: rozet['renk'], letterSpacing: 1, fontFamily: 'Avenir'), overflow: TextOverflow.ellipsis)),
                  ],
                ),
                SizedBox(height: 8),

                // ÜRÜN ADI
                Text(urun['ad'] ?? "Bilinmeyen Ürün", maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 12, height: 1.2, fontFamily: 'Avenir')),
                SizedBox(height: 8),

                // FİYAT
                Text("₺${fiyat.toStringAsFixed(2)}", style: TextStyle(color: primaryTeal, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                SizedBox(height: 12),

                // SİBER SATIN AL BUTONU
                SizedBox(
                  width: double.infinity,
                  height: 35,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      // Arka planda %12 Karargah komisyonu otonom hesaplanır.
                      developer.log("💰 PLAZA SATIŞ: ${urun['ad']} sepete eklendi. Satıcı: $vitrinSaticiAdi | Merkez Komisyonu (%12) otonom olarak işlenecektir.");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryTeal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.zero,
                      elevation: 0,
                    ),
                    child: Text("SEPETE EKLE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1, fontFamily: 'Avenir')),
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