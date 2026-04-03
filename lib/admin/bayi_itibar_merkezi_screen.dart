import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// SİBER ZIRHLAR
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

class BayiItibarMerkeziScreen extends StatefulWidget {
  const BayiItibarMerkeziScreen({super.key});

  @override
  State<BayiItibarMerkeziScreen> createState() => _BayiItibarMerkeziScreenState();
}

class _BayiItibarMerkeziScreenState extends State<BayiItibarMerkeziScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- 🔴 FİREBASE: İTİBAR MOTORU (Puan Güncelleme ve Karaliste) ---
  Future<void> _itibarGuncelle(String bayiId, double mevcutPuan, bool isArtirma) async {
    double yeniPuan = isArtirma ? mevcutPuan + 1 : mevcutPuan - 1;
    if (yeniPuan > 5) yeniPuan = 5;
    if (yeniPuan < 1) yeniPuan = 1;

    bool isKaraListe = (yeniPuan <= 1.0);

    try {
      await _db.collection('bayiler').doc(bayiId).update({
        'puan': yeniPuan,
        'kara_liste': isKaraListe,
        'aktif_mi': !isKaraListe, // Karalisteye girerse ağdan düşer!
      });
      _siberUyariVer(isKaraListe ? "BAYİ KARA LİSTEYE ALINDI VE AĞDAN KOPARILDI!" : "İtibar Skoru Güncellendi: $yeniPuan Yıldız", isError: isKaraListe);
    } catch (e) {
      _siberUyariVer("SİBER AĞ HATASI: Mühür koptu.", isError: true);
    }
  }

  void _siberUyariVer(String mesaj, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: TextStyle(color: isError ? Colors.white : SiberTema.oledBlack, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
      backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // --- SİBER ROZET MİMARİSİ (3D DOKULU) ---
  Widget _buildRozet(double puan) {
    if (puan >= 5.0) {
      return _rozetKutusu(Icons.star, SiberTema.altinSari, "ALTIN ROZET");
    } else if (puan >= 4.0) {
      return _rozetKutusu(Icons.star, Colors.grey[300]!, "GÜMÜŞ ROZET");
    } else if (puan >= 3.0) {
      return _rozetKutusu(Icons.star, Colors.orange[300]!, "BRONZ ROZET");
    } else if (puan >= 2.0) {
      return _rozetKutusu(Icons.star_border, Colors.white54, "ROZETSİZ");
    } else {
      return _rozetKutusu(Icons.star, Colors.black, "KARA LİSTE", isBlacklist: true);
    }
  }

  Widget _rozetKutusu(IconData icon, Color color, String text, {bool isBlacklist = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isBlacklist
              ? [SiberTema.kanKirmizi, SiberTema.kanKirmizi.withOpacity(0.7)]
              : [color.withOpacity(0.2), color.withOpacity(0.05)],
        ),
        border: Border.all(color: isBlacklist ? SiberTema.oledBlack : color.withOpacity(0.5), width: 1.5),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: isBlacklist ? SiberTema.kanKirmizi.withOpacity(0.3) : color.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isBlacklist ? SiberTema.oledBlack : color, size: 16),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: isBlacklist ? SiberTema.oledBlack : color, fontSize: 10, fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 1)),
        ],
      ),
    );
  }

  // --- 3D FİZİKSEL BUTON ZIRHI ---
  Widget _build3DButon(IconData icon, Color renk, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [SiberTema.matGrey.withOpacity(0.8), SiberTema.oledBlack],
          ),
          border: Border.all(color: renk.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 6, offset: const Offset(0, 3)),
            BoxShadow(color: renk.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 0)),
          ],
        ),
        child: Icon(icon, color: renk, size: 20),
      ),
    );
  }

  Widget _buildBosDurum() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [SiberTema.oledBlack, SiberTema.matGrey.withOpacity(0.5)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_outlined, size: 64, color: SiberTema.kuantumCyan.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text("AĞDA KAYITLI BAYİ YOK", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14, letterSpacing: 2, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
          ],
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
          leading: IconButton(icon: const Icon(Icons.shield, color: SiberTema.kuantumCyan), onPressed: () => Navigator.pop(context)),
          title: Text("İTİBAR VE ROZET MERKEZİ", style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2, fontFamily: 'Avenir')),
          centerTitle: true,
        ),
        body: Container(
          decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/radar_grid.png'), fit: BoxFit.cover, opacity: 0.05)),
          child: StreamBuilder<QuerySnapshot>(
            stream: _db.collection('bayiler').orderBy('puan', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan, strokeWidth: 3));
              if (snapshot.hasError) return const Center(child: Text("SİBER AĞ HATASI", style: TextStyle(color: SiberTema.kanKirmizi, fontWeight: FontWeight.bold)));

              final bayiler = snapshot.data?.docs ?? [];
              if (bayiler.isEmpty) return _buildBosDurum();

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                itemCount: bayiler.length,
                itemBuilder: (context, index) {
                  final bayi = bayiler[index].data() as Map<String, dynamic>;
                  final bayiId = bayiler[index].id;
                  final double puan = (bayi['puan'] ?? 5.0).toDouble();
                  final String isim = bayi['firma_adi'] ?? 'Bilinmeyen Firma';
                  final bool isKaraListe = bayi['kara_liste'] ?? false;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      // 3D Dışa Çıkık Bayi Kasası
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isKaraListe
                            ? [SiberTema.kanKirmizi.withOpacity(0.15), SiberTema.oledBlack]
                            : [SiberTema.matGrey.withOpacity(0.8), SiberTema.oledBlack],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isKaraListe ? SiberTema.kanKirmizi.withOpacity(0.5) : Colors.white.withOpacity(0.1), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                            color: isKaraListe ? SiberTema.kanKirmizi.withOpacity(0.2) : Colors.black.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: const Offset(0, 5)
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(isim, style: TextStyle(color: isKaraListe ? SiberTema.kanKirmizi : Colors.white, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Avenir', height: 1.2)),
                              ),
                              const SizedBox(width: 12),
                              _buildRozet(puan),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // İtibar Kontrol Paneli (3D Tuşlar)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [SiberTema.oledBlack, SiberTema.matGrey.withOpacity(0.3)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.05)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _build3DButon(Icons.remove, SiberTema.kanKirmizi, () => _itibarGuncelle(bayiId, puan, false)),

                                Column(
                                  children: [
                                    Text("İTİBAR SKORU", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
                                    const SizedBox(height: 4),
                                    Text("${puan.toStringAsFixed(1)}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20, fontFamily: 'Avenir')),
                                  ],
                                ),

                                _build3DButon(Icons.add, SiberTema.kuantumCyan, () => _itibarGuncelle(bayiId, puan, true)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}