import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart'; // 🚀 SİBER SİLAH: Harita Tetikleyici

class BayiPaneliScreen extends StatefulWidget {
  const BayiPaneliScreen({super.key});

  @override
  State<BayiPaneliScreen> createState() => _BayiPaneliScreenState();
}

class _BayiPaneliScreenState extends State<BayiPaneliScreen> {
  final Color bgColor = const Color(0xFF0F172A);
  final Color primaryCyan = const Color(0xFF00FFC2);
  final Color cardColor = const Color(0xFF1E293B);

  // Sinyal durumunu güncelleyen Firebase Motoru
  Future<void> _sinyalDurumGuncelle(String docId, String yeniDurum, bool asilsizMi) async {
    try {
      await FirebaseFirestore.instance.collection('sos_sinyalleri').doc(docId).update({
        'durum': yeniDurum,
        'asilsiz_ihbar_mi': asilsizMi,
        'guncelleme_tarihi': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kuantum Ağı: Sinyal Durumu "$yeniDurum" olarak mühürlendi!', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: primaryCyan,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('🚨 GÜNCELLEME HATASI: $e'), backgroundColor: Colors.redAccent));
      }
    }
  }

  // --- GERÇEK HARİTADA AÇMA MOTORU ---
  Future<void> _haritayiAc(String konumStr) async {
    if (konumStr == 'Konum Alınamadı' || !konumStr.contains(',')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli bir koordinat bulunamadı!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: Colors.orangeAccent),
      );
      return;
    }

    try {
      // Koordinatları parçalıyoruz: Enlem ve Boylam
      final kordinatlar = konumStr.split(',');
      final lat = kordinatlar[0].trim();
      final lng = kordinatlar[1].trim();

      // Haritalar (Google Maps / Apple Maps) Evrensel Tetikleyici URL
      final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Harita açılamadı');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Siber Hata: Harita tetiklenemedi!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.radar, color: primaryCyan, size: 28),
            const SizedBox(width: 10),
            Text('OTO DNA - BAYİ RADARI', style: TextStyle(color: primaryCyan, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 16)),
          ],
        ),
        centerTitle: true,
      ),
      // 📡 CANLI FİREBASE DİNLEYİCİSİ (S.O.S RADARI)
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sos_sinyalleri')
            .orderBy('sinyal_zamani', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Kuantum Radarında bir hata oluştu!', style: TextStyle(color: Colors.redAccent)));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryCyan));
          }

          final data = snapshot.requireData;

          // EĞER SİNYAL YOKSA ÇIKACAK EKRAN
          if (data.size == 0) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.security, color: primaryCyan.withOpacity(0.3), size: 100),
                  const SizedBox(height: 24),
                  const Text('Sahada Her Şey Sakin.', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Aktif S.O.S Sinyali Bulunmuyor.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 14)),
                ],
              ),
            );
          }

          // SİNYALLER LİSTESİ
          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            itemCount: data.size,
            itemBuilder: (context, index) {
              var sinyal = data.docs[index];
              var docId = sinyal.id;

              Map<String, dynamic> sinyalData = sinyal.data() as Map<String, dynamic>;

              var plaka = sinyalData['plaka'] ?? 'Bilinmiyor';
              var kullanici = sinyalData['kullanici'] ?? 'Siber Sürücü';
              var durum = sinyalData['durum'] ?? 'Bekliyor';
              var konum = sinyalData['konum'] ?? 'Konum Alınamadı';

              bool isBekliyor = durum == 'Bekliyor';
              Color durumRengi = isBekliyor ? Colors.redAccent : primaryCyan;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isBekliyor ? Colors.redAccent.withOpacity(0.05) : cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: durumRengi.withOpacity(0.5), width: isBekliyor ? 2 : 1),
                  boxShadow: isBekliyor ? [BoxShadow(color: Colors.redAccent.withOpacity(0.1), blurRadius: 20, spreadRadius: 2)] : [],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: durumRengi.withOpacity(0.2), shape: BoxShape.circle),
                              child: Icon(isBekliyor ? Icons.warning_amber_rounded : Icons.shield, color: durumRengi, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(plaka, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: durumRengi.withOpacity(0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: durumRengi)),
                          child: Text(durum, style: TextStyle(color: durumRengi, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.white12)),
                    Row(children: [const Icon(Icons.person, color: Colors.white54, size: 16), const SizedBox(width: 8), Text('Sürücü: $kullanici', style: const TextStyle(color: Colors.white70, fontSize: 14))]),
                    const SizedBox(height: 12),

                    // --- İŞTE SENİN TIKLANABİLİR HARİTA BUTONUN ---
                    GestureDetector(
                      onTap: () => _haritayiAc(konum),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.orangeAccent, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                konum == 'Konum Alınamadı' ? konum : "Konuma Gitmek İçin Tıklayın (Navigasyon)",
                                style: const TextStyle(color: Colors.orangeAccent, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Icon(Icons.navigation, color: Colors.orangeAccent, size: 16),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // MÜDAHALE BUTONLARI
                    if (isBekliyor)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: primaryCyan, foregroundColor: bgColor, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              icon: const Icon(Icons.directions_car, size: 18),
                              label: const Text('Müdahale Et', style: TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: () => _sinyalDurumGuncelle(docId, 'Müdahale Edildi', false),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(vertical: 14), side: const BorderSide(color: Colors.redAccent), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              icon: const Icon(Icons.block, size: 18),
                              label: const Text('Asılsız İhbar', style: TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: () => _sinyalDurumGuncelle(docId, 'Asılsız İhbar', true),
                            ),
                          ),
                        ],
                      )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}