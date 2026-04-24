// lib/screens/bayi/itibar_yonetimi.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI VE MERKEZİ TEMA BAĞLANTISI (2 Kat Yukarı)
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

/// 🛡️ KUANTUM İTİBAR VE KARALİSTE RADARI (SiberItibarPaneli)
/// Bayinin müşteri yorumlarını canlı çeker ve Karargahın (1-5 Yıldız / Blacklist) kurallarını otonom uygular.
class SiberItibarPaneli extends StatelessWidget {
  final String bayiId; // İtibarı sorgulanan bayinin Karargah kimliği

  const SiberItibarPaneli({super.key, required this.bayiId});

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent, // Zırhın arkası görünsün
        appBar: AppBar(
          title: const Text("İTİBAR VE MÜŞTERİ RADARI", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: SiberTema.kuantumCyan),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('bayi_yorumlari')
              .where('bayi_id', isEqualTo: bayiId)
              .orderBy('zaman_damgasi', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
            }

            List<DocumentSnapshot> yorumlar = snapshot.hasData ? snapshot.data!.docs : [];

            // 🧠 Otonom Karargah Puan Hesaplaması
            double toplamPuan = 0;
            for (var doc in yorumlar) {
              toplamPuan += (doc['puan'] ?? 0).toDouble();
            }
            double ortalamaPuan = yorumlar.isEmpty ? 0.0 : (toplamPuan / yorumlar.length);

            return Column(
              children: [
                _buildSiberPuanOzeti(ortalamaPuan),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Divider(color: Colors.white24, height: 1),
                ),

                if (yorumlar.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text("SİBER ONAY: Henüz istihbarat verisi bulunmuyor.", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: yorumlar.length,
                      itemBuilder: (context, index) {
                        var yorumVerisi = yorumlar[index].data() as Map<String, dynamic>;
                        return _buildSiberYorumKarti(yorumVerisi);
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── 🛡️ KARARGAH PUAN VE ROZET MOTORU ──
  Widget _buildSiberPuanOzeti(double puan) {
    // Rozet kuralını otonom olarak uygular
    Map<String, dynamic> rozet = _getKarargahRozeti(puan.round());

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: SiberTema.matGrey.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: rozet['renk'].withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(color: rozet['renk'].withOpacity(0.1), blurRadius: 30, spreadRadius: 5),
          ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Text("KARARGAH DNA SKORU", style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(puan.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
            ],
          ),
          Column(
            children: [
              Icon(rozet['ikon'], color: rozet['renk'], size: 48),
              const SizedBox(height: 8),
              Text(rozet['isim'], style: TextStyle(color: rozet['renk'], fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  /// ⚖️ SİBER DOKTRİN: Komutan Gazi'nin kesin rozet kuralı
  Map<String, dynamic> _getKarargahRozeti(int yuvarlanmisPuan) {
    if (yuvarlanmisPuan >= 5) return {'isim': 'GOLD BAYİ', 'ikon': Icons.workspace_premium, 'renk': Colors.amberAccent};
    if (yuvarlanmisPuan == 4) return {'isim': 'SILVER BAYİ', 'ikon': Icons.stars, 'renk': Colors.blueGrey[300]!};
    if (yuvarlanmisPuan == 3) return {'isim': 'BRONZE BAYİ', 'ikon': Icons.star_border, 'renk': Colors.deepOrangeAccent};
    if (yuvarlanmisPuan == 2) return {'isim': 'STANDART BAYİ', 'ikon': Icons.shield_outlined, 'renk': Colors.white54};
    // 🚨 1 ve altı acımasızca Karalisteye düşer!
    return {'isim': 'BLACKLIST', 'ikon': Icons.gavel, 'renk': SiberTema.kanKirmizi};
  }

  // ── 📜 MÜŞTERİ İSTİHBARAT KARTI ──
  Widget _buildSiberYorumKarti(Map<String, dynamic> yorum) {
    int verilenPuan = (yorum['puan'] ?? 0).toInt();
    bool isBlacklist = verilenPuan <= 1; // 1 Yıldız Karaliste demektir
    Color kartRengi = isBlacklist ? SiberTema.kanKirmizi : SiberTema.kuantumCyan;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isBlacklist ? SiberTema.kanKirmizi.withOpacity(0.05) : SiberTema.matGrey.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kartRengi.withOpacity(0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: kartRengi.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(isBlacklist ? Icons.warning_amber_rounded : Icons.person_outline, color: kartRengi),
        ),
        title: Text(yorum['musteri_adi'] ?? "Gizli Ajan", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 13)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(yorum['yorum_metni'] ?? "Detay yok.", style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4, fontWeight: FontWeight.bold)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (i) {
            return Icon(
              isBlacklist ? Icons.star : Icons.star, // Karalistede siyah yıldız kuralı
              size: 16,
              color: i < verilenPuan
                  ? (isBlacklist ? Colors.black : Colors.amberAccent) // Karalisteyse yıldız SİYAH olur
                  : Colors.white12,
            );
          }),
        ),
        onTap: () {
          HapticFeedback.selectionClick();
          developer.log("SİBER İSTİHBARAT: Yorum detayları inceleniyor...");
        },
      ),
    );
  }
}