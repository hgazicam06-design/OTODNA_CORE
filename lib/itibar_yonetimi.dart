// lib/screens/itibar_yonetimi.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM İTİBAR VE KARALİSTE RADARI (SiberItibarPaneli)
/// Bayinin müşteri yorumlarını canlı çeker ve Karargahın (1-5 Yıldız / Blacklist) kurallarını uygular.
class SiberItibarPaneli extends StatelessWidget {
  final String bayiId; // İtibarı sorgulanan bayinin Karargah kimliği

  const SiberItibarPaneli({super.key, required this.bayiId});

  // ── 🎨 KARARGAH TASARIM DOKTRİNİ ──
  static const Color _oledBlack = Color(0xFF000000);
  static const Color _matGrey = Color(0xFF111111);
  static const Color _kuantumCyan = Color(0xFF00FFC2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _oledBlack,
      appBar: AppBar(
        title: const Text("İTİBAR VE MÜŞTERİ RADARI", style: TextStyle(color: _kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 14)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kuantumCyan),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('bayi_yorumlari')
            .where('bayi_id', isEqualTo: bayiId)
            .orderBy('zaman_damgasi', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _kuantumCyan));
          }

          List<DocumentSnapshot> yorumlar = snapshot.hasData ? snapshot.data!.docs : [];

          // Otonom Karargah Puan Hesaplaması
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
                    child: Text("SİBER ONAY: Henüz istihbarat verisi bulunmuyor.", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
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
          color: _matGrey,
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
              const Text("KARARGAH DNA SKORU", style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(puan.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900)),
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

  /// Senin belirlediğin kesin kural (5: Gold, 4: Silver, 3: Bronze, 2: Boş, 1: Blacklist)
  Map<String, dynamic> _getKarargahRozeti(int yuvarlanmisPuan) {
    if (yuvarlanmisPuan >= 5) return {'isim': 'GOLD BAYİ', 'ikon': Icons.workspace_premium, 'renk': Colors.amberAccent};
    if (yuvarlanmisPuan == 4) return {'isim': 'SILVER BAYİ', 'ikon': Icons.stars, 'renk': Colors.blueGrey[300]!};
    if (yuvarlanmisPuan == 3) return {'isim': 'BRONZE BAYİ', 'ikon': Icons.star_border, 'renk': Colors.deepOrangeAccent};
    if (yuvarlanmisPuan == 2) return {'isim': 'STANDART BAYİ', 'ikon': Icons.shield_outlined, 'renk': Colors.white54};
    // 1 ve altı Karalisteye düşer!
    return {'isim': 'BLACKLIST', 'ikon': Icons.gavel, 'renk': Colors.redAccent};
  }

  // ── 📜 MÜŞTERİ İSTİHBARAT KARTI ──
  Widget _buildSiberYorumKarti(Map<String, dynamic> yorum) {
    int verilenPuan = (yorum['puan'] ?? 0).toInt();
    bool isBlacklist = verilenPuan <= 1;
    Color kartRengi = isBlacklist ? Colors.redAccent : _kuantumCyan;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isBlacklist ? Colors.redAccent.withOpacity(0.05) : _matGrey,
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
            Text(yorum['yorum_metni'] ?? "Detay yok.", style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (i) {
            return Icon(
              isBlacklist ? Icons.star : Icons.star,
              size: 16,
              color: i < verilenPuan
                  ? (isBlacklist ? Colors.black : Colors.amberAccent)
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