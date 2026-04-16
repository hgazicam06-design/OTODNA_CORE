// lib/screens/kullanici/market_ana_sayfa.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI VE MERKEZİ TEMA BAĞLANTISI (2 Kat Yukarı)
import '../../../../core/siber_tema.dart';
import '../../../../core/responsive_kalkan.dart';

/// 🛡️ KUANTUM GLOBAL MARKET VİTRİNİ (SiberMarketAnaSayfa)
/// Firebase'den canlı ürünleri çeker, her bayiyi kendi şanlı markasıyla sergiler ve %12 kesinti kuralını uygular.
class SiberMarketAnaSayfa extends StatelessWidget {
  const SiberMarketAnaSayfa({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent, // Kalkanın siber aydınlatması arkadan vursun
        appBar: AppBar(
          title: const Text("OTODNA GLOBAL MARKET", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: SiberTema.kuantumCyan),
        ),
        body: StreamBuilder<QuerySnapshot>(
          // 📡 SİBER NOT: Ürünler Karargah veritabanından canlı akıyor!
          stream: FirebaseFirestore.instance.collection('market_urunleri').orderBy('eklenme_tarihi', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text("SİBER ONAY: Vitrinde henüz ürün bulunmuyor.", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, letterSpacing: 1)),
              );
            }

            return GridView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.62, // Kartların siber cam efekti için dikey oran artırıldı
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
      ),
    );
  }

  // ── 🛡️ KARARGAH ROZET MOTORU (1-5 YILDIZ KURALI) ──
  Map<String, dynamic> _getKarargahRozeti(double puan) {
    int yuvarlanmisPuan = puan.round();
    if (yuvarlanmisPuan >= 5) return {'isim': 'GOLD BAYİ', 'ikon': Icons.workspace_premium, 'renk': SiberTema.altinSari};
    if (yuvarlanmisPuan == 4) return {'isim': 'SILVER BAYİ', 'ikon': Icons.stars, 'renk': Colors.blueGrey[300]!};
    if (yuvarlanmisPuan == 3) return {'isim': 'BRONZE BAYİ', 'ikon': Icons.star_border, 'renk': Colors.deepOrangeAccent};
    if (yuvarlanmisPuan == 2) return {'isim': 'STANDART', 'ikon': Icons.shield_outlined, 'renk': Colors.white54};
    // 🚨 1 ve altı Karalisteye düşer! Siyah yıldız cezası.
    return {'isim': 'BLACKLIST', 'ikon': Icons.gavel, 'renk': SiberTema.kanKirmizi};
  }

  // ── 🛒 SİBER ÜRÜN KARTI ──
  Widget _buildSiberUrunKarti(Map<String, dynamic> urun) {
    double fiyat = (urun['fiyat'] ?? 0).toDouble();
    double puan = (urun['puan'] ?? 0).toDouble();

    // 🔥 KARARGAH YENİ STRATEJİSİ: Her bayi kendi markasıyla çıkar!
    String vitrinSaticiAdi = urun['satici_adi'] ?? "Bağımsız Tedarikçi";
    Map<String, dynamic> rozet = _getKarargahRozeti(puan);

    return Container(
      decoration: BoxDecoration(
          color: SiberTema.matGrey.withOpacity(0.8), // Siber Cam Efekti
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
          boxShadow: [
            BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.05), blurRadius: 15, spreadRadius: 1),
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ÜRÜN GÖRSELİ (Kuantum Turkuazı Placeholder)
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: SiberTema.kuantumCyan.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Icon(Icons.precision_manufacturing_outlined, size: 60, color: SiberTema.kuantumCyan),
            ),
          ),

          // ÜRÜN BİLGİLERİ VE ROZET
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SATICI ETİKETİ VE ROZET
                Row(
                  children: [
                    Icon(rozet['ikon'], size: 14, color: rozet['renk']),
                    const SizedBox(width: 4),
                    Expanded(child: Text(vitrinSaticiAdi, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: rozet['renk'], letterSpacing: 1), overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 8),

                // ÜRÜN ADI
                Text(urun['ad'] ?? "Bilinmeyen Ürün", maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, height: 1.2)),
                const SizedBox(height: 8),

                // FİYAT
                Text("₺${fiyat.toStringAsFixed(2)}", style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
                const SizedBox(height: 12),

                // SİBER SATIN AL BUTONU
                SizedBox(
                  width: double.infinity,
                  height: 35,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      // Arka planda %12 Karargah komisyonu otonom hesaplanır.
                      developer.log("💰 SİBER SATIŞ: ${urun['ad']} sepete eklendi. Satıcı: $vitrinSaticiAdi | Karargah Komisyonu (%12) otonom olarak işlenecektir.");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SiberTema.kuantumCyan,
                      foregroundColor: SiberTema.oledBlack,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.zero,
                      elevation: 5,
                      shadowColor: SiberTema.kuantumCyan.withOpacity(0.4),
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