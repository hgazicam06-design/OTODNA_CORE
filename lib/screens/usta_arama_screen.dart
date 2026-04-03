import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UstaAramaScreen extends StatefulWidget {
  const UstaAramaScreen({super.key});

  @override
  State<UstaAramaScreen> createState() => _UstaAramaScreenState();
}

class _UstaAramaScreenState extends State<UstaAramaScreen> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  static const Color bgColor = Color(0xFF000000);
  static const Color surfaceColor = Color(0xFF111111);
  static const Color primaryCyan = Color(0xFF00FFC2);
  static const Color dangerColor = Colors.redAccent;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void _uyariGoster(String mesaj, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1)),
        backgroundColor: isError ? dangerColor : primaryCyan,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: primaryCyan, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text("KÜRESEL USTA RADARI", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined, color: primaryCyan),
            onPressed: () => _uyariGoster("SİBER HARİTA MODÜLÜ YAKINDA AKTİF EDİLECEK!"),
          )
        ],
      ),
      body: SafeArea(
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
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: primaryCyan.withOpacity(0.3), width: 1.5),
                    boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.05), blurRadius: 20)],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.radar, color: primaryCyan, size: 24),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("AKTİF TARAMA BÖLGESİ", style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                            SizedBox(height: 4),
                            Text("İÇ ANADOLU / ANKARA", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1)),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => _uyariGoster("BÖLGE DEĞİŞTİRME TERMİNALİ BAŞLATILIYOR..."),
                        child: const Text("DEĞİŞTİR", style: TextStyle(color: primaryCyan, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
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
                        return const Center(child: CircularProgressIndicator(color: primaryCyan));
                      }

                      // 🚨 VERİ YOKSA SİBER MOCK GÖSTERİMİ
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
    );
  }

  // 💎 YARDIMCI BİLEŞEN: SİBER FİRMA KARTI
  Widget _buildSiberUstaKarti(String isim, String konum, double puan, String mesafe) {
    bool isKaraListe = puan < 1.5;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isKaraListe ? dangerColor.withOpacity(0.5) : Colors.white.withOpacity(0.05), width: 1.5),
        boxShadow: isKaraListe ? [BoxShadow(color: dangerColor.withOpacity(0.1), blurRadius: 20)] : [],
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
                    Text(isim.toUpperCase(), style: TextStyle(color: isKaraListe ? dangerColor : Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.my_location, color: Colors.white38, size: 12),
                        const SizedBox(width: 4),
                        Text("$konum  •  $mesafe", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
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
                _uyariGoster("$isim İÇİN SİBER RANDEVU PROTOKOLÜ BAŞLATILIYOR...");
                // Navigator.pushNamed(context, '/randevu_onay');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isKaraListe ? dangerColor.withOpacity(0.1) : primaryCyan.withOpacity(0.1),
                foregroundColor: isKaraListe ? dangerColor : primaryCyan,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isKaraListe ? dangerColor.withOpacity(0.3) : primaryCyan.withOpacity(0.5))),
              ),
              icon: Icon(isKaraListe ? Icons.block : Icons.handshake, size: 16),
              label: Text(
                isKaraListe ? "SİSTEMDEN MEN EDİLDİ" : "RANDEVU MÜHRÜ VUR",
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
              ),
            ),
          )
        ],
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: DİJİTAL ROZET HİYERARŞİSİ
  Widget _buildSiberRozet(double puan) {
    if (puan >= 4.5) {
      return _rozet(Icons.star, Colors.amber, "ALTIN"); // 5 Yıldız
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
        decoration: BoxDecoration(color: dangerColor.withOpacity(0.15), borderRadius: BorderRadius.circular(6), border: Border.all(color: dangerColor.withOpacity(0.5))),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: Colors.black, size: 14),
            SizedBox(width: 4),
            Text("KARA LİSTE", style: TextStyle(color: dangerColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
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
          Text(metin, style: TextStyle(color: renk, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ],
      ),
    );
  }
}