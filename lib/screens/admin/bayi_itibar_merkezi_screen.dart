import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🚀 KARARGAH ZIRHLARI
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';
import '../../services/siber_istihbarat_log_motoru.dart'; // 👁️ İSTİHBARAT AĞI KÖPRÜSÜ

class BayiItibarMerkeziScreen extends StatefulWidget {
  const BayiItibarMerkeziScreen({super.key});

  @override
  State<BayiItibarMerkeziScreen> createState() => _BayiItibarMerkeziScreenState();
}

class _BayiItibarMerkeziScreenState extends State<BayiItibarMerkeziScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- 🔴 FİREBASE: ATOMİK İTİBAR MOTORU (WRITEBATCH) ---
  // Puan değişimini sadece güncellemez, aynı zamanda sistem loglarına mühürler.
  Future<void> _itibarGuncelle(String bayiId, String firmaAdi, double mevcutPuan, bool isArtirma) async {
    double yeniPuan = isArtirma ? mevcutPuan + 1.0 : mevcutPuan - 1.0;
    if (yeniPuan > 5.0) yeniPuan = 5.0;
    if (yeniPuan < 1.0) yeniPuan = 1.0;

    bool isKaraListe = (yeniPuan <= 1.0);

    try {
      WriteBatch batch = _db.batch();

      // 1. Bayi Kartını Güncelle
      DocumentReference bayiRef = _db.collection('bayiler').doc(bayiId);
      batch.update(bayiRef, {
        'puan': yeniPuan,
        'kara_liste': isKaraListe,
        'aktif_mi': !isKaraListe, // 1 Yıldız = Karalisteye giriş ve ağdan kopuş!
        'son_itibar_guncelleme': FieldValue.serverTimestamp(),
      });

      // 2. Siber İstihbarat Radarına Mühürle (Matrix)
      DocumentReference logRef = _db.collection('siber_istihbarat_loglari').doc();
      batch.set(logRef, {
        'islem_turu': isKaraListe ? 'KARA_LISTE_IHLALI' : 'ITIBAR_GUNCELLEMESI',
        'islem_detayi': isKaraListe ? 'SİBER KOMUTAN: "$firmaAdi" kara listeye alındı ve ağdan koparıldı. Skoru: $yeniPuan' : 'SİBER KOMUTAN: "$firmaAdi" güncel itibar skoru: $yeniPuan',
        'bayi_id': bayiId,
        'tarih': FieldValue.serverTimestamp(),
      });

      // Füze ateşlendi
      await batch.commit();

      _siberUyariVer(
          isKaraListe
              ? "KRİTİK: $firmaAdi KARA LİSTEYE ALINDI VE AĞDAN KOPARILDI!"
              : "İtibar Skoru Güncellendi: $yeniPuan Yıldız",
          isError: isKaraListe
      );
    } catch (e) {
      _siberUyariVer("SİBER AĞ HATASI: Veri akışı kesildi!", isError: true);
    }
  }

  void _siberUyariVer(String mesaj, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: TextStyle(color: isError ? Colors.white : SiberTema.oledBlack, fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 1)),
      backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isError ? Colors.white24 : Colors.black12)),
    ));
  }

  // --- SİBER ROZET MİMARİSİ (3D DOKULU & NEON) ---
  Widget _buildRozet(double puan) {
    if (puan >= 5.0) return _rozetKutusu(Icons.workspace_premium, SiberTema.altinSari, "ALTIN ROZET");
    if (puan >= 4.0) return _rozetKutusu(Icons.stars, Colors.blueGrey[100]!, "GÜMÜŞ ROZET");
    if (puan >= 3.0) return _rozetKutusu(Icons.military_tech, Colors.orangeAccent, "BRONZ ROZET");
    if (puan >= 2.0) return _rozetKutusu(Icons.remove_circle_outline, Colors.white30, "ROZETSİZ");
    return _rozetKutusu(Icons.dangerous, SiberTema.kanKirmizi, "KARA LİSTE", isBlacklist: true);
  }

  Widget _rozetKutusu(IconData icon, Color color, String text, {bool isBlacklist = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isBlacklist ? SiberTema.kanKirmizi.withOpacity(0.1) : color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: isBlacklist ? SiberTema.kanKirmizi : color.withOpacity(0.4), width: 1.5),
        boxShadow: [
          if (!isBlacklist) BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, spreadRadius: 1),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isBlacklist ? SiberTema.kanKirmizi : color, size: 14),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: isBlacklist ? SiberTema.kanKirmizi : color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        ],
      ),
    );
  }

  // --- 3D SİBER BUTON ---
  Widget _build3DButon(IconData icon, Color renk, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: SiberTema.matGrey.withOpacity(0.2),
            border: Border.all(color: renk.withOpacity(0.3), width: 1),
          ),
          child: Icon(icon, color: renk, size: 22),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20), onPressed: () => Navigator.pop(context)),
          title: const Text("İTİBAR KOMUTA MERKEZİ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 3)),
          centerTitle: true,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _db.collection('bayiler').orderBy('puan', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
            }

            final bayiler = snapshot.data?.docs ?? [];
            if (bayiler.isEmpty) {
              return Center(child: Text("HİÇBİR BAYİ VERİSİ BULUNAMADI", style: TextStyle(color: Colors.white.withOpacity(0.2), letterSpacing: 2)));
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              physics: const BouncingScrollPhysics(),
              itemCount: bayiler.length,
              itemBuilder: (context, index) {
                final doc = bayiler[index];
                final data = doc.data() as Map<String, dynamic>;
                final double puan = (data['puan'] ?? 5.0).toDouble();
                final String firma = data['firma_adi'] ?? 'Bilinmeyen Bayi';
                final bool isKara = data['kara_liste'] ?? false;

                return Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: SiberTema.siberCamKalkan(
                    borderColor: isKara ? SiberTema.kanKirmizi.withOpacity(0.5) : Colors.white10,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(firma.toUpperCase(), style: TextStyle(color: isKara ? SiberTema.kanKirmizi : Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
                                  const SizedBox(height: 4),
                                  Text("BAYİ ID: ${doc.id.substring(0, 8)}...", style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            _buildRozet(puan),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Divider(color: Colors.white10, height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _build3DButon(Icons.exposure_minus_1, SiberTema.kanKirmizi, () => _itibarGuncelle(doc.id, firma, puan, false)),
                            Column(
                              children: [
                                Text("GÜNCEL SKOR", style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2)),
                                const SizedBox(height: 6),
                                Text(puan.toStringAsFixed(1), style: TextStyle(color: isKara ? SiberTema.kanKirmizi : SiberTema.kuantumCyan, fontSize: 28, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                              ],
                            ),
                            _build3DButon(Icons.plus_one, SiberTema.kuantumCyan, () => _itibarGuncelle(doc.id, firma, puan, true)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}