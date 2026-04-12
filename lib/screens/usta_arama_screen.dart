import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🔥 SİBER KÖPRÜLER VE TEMA
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

class UstaAramaScreen extends StatefulWidget {
  const UstaAramaScreen({super.key});

  @override
  State<UstaAramaScreen> createState() => _UstaAramaScreenState();
}

class _UstaAramaScreenState extends State<UstaAramaScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void _siberUyariGoster(String mesaj, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: TextStyle(fontWeight: FontWeight.w900, color: isError ? Colors.white : SiberTema.oledBlack, letterSpacing: 1, fontFamily: 'Avenir')),
        backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
        behavior: SnackBarBehavior.floating,
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
          centerTitle: true,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20), onPressed: () => Navigator.pop(context)),
          title: const Text("KÜRESEL USTA RADARI", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
          actions: [
            IconButton(
              icon: const Icon(Icons.map_outlined, color: SiberTema.kuantumCyan),
              onPressed: () => _siberUyariGoster("SİBER HARİTA MODÜLÜ YAKINDA AKTİF EDİLECEK!"),
            )
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/images/radar_grid.png'), fit: BoxFit.cover, opacity: 0.05),
          ),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800), // 🖥️ Web / Double Teyp Kalkanı
                child: Column(
                  children: [
                    // =================================================================
                    // 1. SİBER LOKASYON FİLTRESİ
                    // =================================================================
                    Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: SiberTema.matGrey.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3), width: 1.5),
                        boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.05), blurRadius: 20)],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.radar, color: SiberTema.kuantumCyan, size: 24),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("AKTİF TARAMA BÖLGESİ", style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
                                SizedBox(height: 4),
                                Text("İÇ ANADOLU / ANKARA", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => _siberUyariGoster("BÖLGE DEĞİŞTİRME TERMİNALİ BAŞLATILIYOR..."),
                            child: const Text("DEĞİŞTİR", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                          )
                        ],
                      ),
                    ),

                    // =================================================================
                    // 2. FİREBASE USTA VE FİRMA LİSTESİ (Canlı Veri Ağı)
                    // =================================================================
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _db.collection('firmalar').orderBy('puan', descending: true).snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
                          }

                          // 🚨 VERİ YOKSA SİBER MOCK GÖSTERİMİ (Karargah Çökmesin Diye)
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return ListView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              children: [
                                _buildSiberUstaKarti("MURAT PLAZA SERVİSİ", "ANKARA", 4.9, "1.2 KM"),
                                _buildSiberUstaKarti("HASSAS MOTOR REKTEFİYE", "ANKARA", 3.8, "3.4 KM"),
                                _buildSiberUstaKarti("STANDART KAPORTA", "ANKARA", 2.1, "5.0 KM"),
                                _buildSiberUstaKarti("KORSAN ELEKTRONİK", "ANKARA", 1.0, "8.2 KM"), // Kara Liste simülasyonu
                              ],
                            );
                          }

                          // GERÇEK VERİTABANI DÖNGÜSÜ
                          return ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                              return _buildSiberUstaKarti(
                                data['isim'] ?? 'BİLİNMEYEN FİRMA',
                                data['bolge'] ?? 'BİLİNMEYEN KONUM',
                                (data['puan'] ?? 0.0).toDouble(),
                                "${data['mesafe'] ?? '0'} KM",
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: SİBER FİRMA KARTI
  Widget _buildSiberUstaKarti(String isim, String konum, double puan, String mesafe) {
    bool isKaraListe = puan < 1.5;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: SiberTema.matGrey.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isKaraListe ? SiberTema.kanKirmizi.withOpacity(0.5) : Colors.white.withOpacity(0.05), width: 1.5),
            boxShadow: isKaraListe ? [BoxShadow(color: SiberTema.kanKirmizi.withOpacity(0.1), blurRadius: 20)] : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isim.toUpperCase(), style: TextStyle(color: isKaraListe ? SiberTema.kanKirmizi : Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.my_location, color: Colors.white38, size: 12),
                            const SizedBox(width: 4),
                            Text("$konum  •  $mesafe", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildSiberRozet(puan),
                ],
              ),
              const SizedBox(height: 20),

              // RANDEVU AL BUTONU (Kara listede buton kilitlenir)
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: isKaraListe ? null : () {
                    _siberUyariGoster("$isim İÇİN SİBER RANDEVU PROTOKOLÜ BAŞLATILIYOR...");
                    // Navigator.pushNamed(context, '/randevu_onay');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isKaraListe ? SiberTema.kanKirmizi.withOpacity(0.1) : SiberTema.kuantumCyan.withOpacity(0.1),
                    foregroundColor: isKaraListe ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isKaraListe ? SiberTema.kanKirmizi.withOpacity(0.3) : SiberTema.kuantumCyan.withOpacity(0.5))),
                  ),
                  icon: Icon(isKaraListe ? Icons.block : Icons.handshake, size: 16),
                  label: Text(
                    isKaraListe ? "SİSTEMDEN MEN EDİLDİ" : "RANDEVU MÜHRÜ VUR",
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir'),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: DİJİTAL ROZET HİYERARŞİSİ
  Widget _buildSiberRozet(double puan) {
    if (puan >= 4.5) {
      return _rozet(Icons.star, SiberTema.altinSari, "ALTIN"); // 5 Yıldız
    } else if (puan >= 3.5) {
      return _rozet(Icons.star, const Color(0xFFC0C0C0), "GÜMÜŞ"); // 4 Yıldız
    } else if (puan >= 2.5) {
      return _rozet(Icons.star, const Color(0xFFCD7F32), "BRONZ"); // 3 Yıldız
    } else if (puan >= 1.5) {
      return _rozet(Icons.star_border, Colors.white54, "BOŞ ROZET"); // 2 Yıldız
    } else {
      // 1 Yıldız: Kara Liste (Siyah Yıldız + Kara Liste Yazısı)
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: SiberTema.kanKirmizi.withOpacity(0.15), borderRadius: BorderRadius.circular(6), border: Border.all(color: SiberTema.kanKirmizi.withOpacity(0.5))),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: Colors.black, size: 14),
            SizedBox(width: 4),
            Text("KARA LİSTE", style: TextStyle(color: SiberTema.kanKirmizi, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
          ],
        ),
      );
    }
  }

  Widget _rozet(IconData ikon, Color renk, String metin) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: renk.withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: renk.withOpacity(0.5))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikon, color: renk, size: 14),
          const SizedBox(width: 4),
          Text(metin, style: TextStyle(color: renk, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
        ],
      ),
    );
  }
}