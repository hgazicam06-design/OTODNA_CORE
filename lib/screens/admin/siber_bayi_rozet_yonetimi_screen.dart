// lib/screens/admin/siber_bayi_rozet_yonetimi_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🚀 KARARGAH ZIRHLARI VE TEMA
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

// SERVİSLER VE WİDGET'LAR
import '../../commerce/bayi_ekosistemi.dart';
import '../../widgets/premium_rozet_widget.dart';

/// 🛡️ YÜKSEK KONSEY: BAYİ ROZET VE YILDIZ YÖNETİMİ
class SiberBayiRozetYonetimiScreen extends StatelessWidget {
  const SiberBayiRozetYonetimiScreen({super.key});

  void _yildizAyarla(BuildContext context, String bayiId, int guncelYildiz, String bayiAd) {
    showDialog(
      context: context,
      builder: (context) {
        int secilenYildiz = guncelYildiz;
        return StatefulBuilder(
          builder: (context, setStateBuilder) {
            return AlertDialog(
              backgroundColor: SiberTema.oledBlack,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: SiberTema.kuantumCyan.withOpacity(0.5))),
              title: const Text("BAYİ RÜTBESİNİ GÜNCELLE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("$bayiAd isimli bayinin yıldızını seçin. Rozet otonom olarak atanacaktır.", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      int yildizDegeri = index + 1;
                      return IconButton(
                        icon: Icon(
                          yildizDegeri <= secilenYildiz ? Icons.star : Icons.star_border,
                          color: yildizDegeri <= secilenYildiz ? SiberTema.altinSari : Colors.white24,
                          size: 32,
                        ),
                        onPressed: () {
                          setStateBuilder(() => secilenYildiz = yildizDegeri);
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  if (secilenYildiz == 5) const Text("🌟 ALTIN BAYİ", style: TextStyle(color: SiberTema.altinSari, fontWeight: FontWeight.bold)),
                  if (secilenYildiz == 4) const Text("🛡️ GÜMÜŞ BAYİ", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                  if (secilenYildiz == 3) const Text("🛡️ BRONZ BAYİ", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                  if (secilenYildiz <= 1) const Text("🚨 BLACKLIST (SİSTEMDEN İZOLE)", style: TextStyle(color: SiberTema.kanKirmizi, fontWeight: FontWeight.bold)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("İPTAL", style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  style: SiberTema.kuantumButonStili(),
                  onPressed: () async {
                    Navigator.pop(context); // Dialogu kapat
                    try {
                      await BayiEkosistemi().bayiPuaniGuncelle(bayiId, secilenYildiz);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bayi mühürlendi!"), backgroundColor: SiberTema.kuantumCyan));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Güncelleme başarısız!"), backgroundColor: SiberTema.kanKirmizi));
                    }
                  },
                  child: const Text("MÜHÜRLE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
                )
              ],
            );
          }
        );
      },
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
          title: const Text("ROZET & YILDIZ MERKEZİ", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 13, fontFamily: 'Avenir')),
          iconTheme: const IconThemeData(color: SiberTema.kuantumCyan),
          centerTitle: true,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('bayiler').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("Sistemde kayıtlı bayi bulunmuyor.", style: TextStyle(color: Colors.white54)));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                var bayi = doc.data() as Map<String, dynamic>;
                String bayiAd = bayi['ticari_unvan'] ?? bayi['ad_soyad'] ?? "İsimsiz Bayi";
                int yildiz = (bayi['yildiz_sayisi'] ?? 2).toInt();
                String rozet = bayi['rozet'] ?? "Boş";

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: SiberTema.siberCamZirh(renk: Colors.black),
                  child: Row(
                    children: [
                      // SİBER PREMIUM ROZET GÖRSELİ
                      PremiumRozet(rozetTipi: rozet, boyut: 32),
                      const SizedBox(width: 16),
                      
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(bayiAd.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text("$rozet Bayi", style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                Row(
                                  children: List.generate(5, (starIdx) {
                                    return Icon(
                                      starIdx < yildiz ? Icons.star : Icons.star_border,
                                      color: starIdx < yildiz ? SiberTema.altinSari : Colors.white24,
                                      size: 14,
                                    );
                                  }),
                                )
                              ],
                            )
                          ],
                        ),
                      ),

                      // GÜNCELLE BUTONU
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: SiberTema.kuantumCyan),
                        onPressed: () => _yildizAyarla(context, doc.id, yildiz, bayiAd),
                      )
                    ],
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
