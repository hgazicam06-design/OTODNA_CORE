import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ---------------------------------------------------------
// 1. KUANTUM REKLAM VERİ MODELİ (FİREBASE UYUMLU)
// ---------------------------------------------------------
class OtoDNACampaign {
  final String id;
  final String sirketAd;
  final String kampanyaBaslik;
  final String gorselUrl;
  final String hedefLink;
  final int tiklanmaSayisi;
  final bool aktifMi;

  OtoDNACampaign({
    required this.id,
    required this.sirketAd,
    required this.kampanyaBaslik,
    required this.gorselUrl,
    required this.hedefLink,
    required this.tiklanmaSayisi,
    required this.aktifMi,
  });

  // Firebase'den gelen veriyi modele dönüştürme kalkanı
  factory OtoDNACampaign.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return OtoDNACampaign(
      id: doc.id,
      sirketAd: data['sirket_ad'] ?? 'Bilinmeyen Şirket',
      kampanyaBaslik: data['kampanya_baslik'] ?? 'Fırsatı İncele',
      gorselUrl: data['gorsel_url'] ?? '',
      hedefLink: data['hedef_link'] ?? '',
      tiklanmaSayisi: data['tiklanma_sayisi'] ?? 0,
      aktifMi: data['aktif_mi'] ?? true,
    );
  }
}

// ---------------------------------------------------------
// 2. SPONSORLU İÇERİK (BANNER) GÖRSELLEŞTİRME VE TETİKLEYİCİ
// ---------------------------------------------------------
class KampanyaKarti extends StatelessWidget {
  final OtoDNACampaign kampanya;

  const KampanyaKarti({super.key, required this.kampanya});

  // 🚀 FİREBASE TIKLAMA SAYACI (PARA MOTORU)
  Future<void> _reklamaTiklandi(BuildContext context) async {
    try {
      // 1. Firebase'de Tıklanma Sayısını Gerçek Zamanlı Artır
      await FirebaseFirestore.instance.collection('reklam_kampanyalari').doc(kampanya.id).update({
        'tiklanma_sayisi': FieldValue.increment(1),
        'son_tiklanma_tarihi': FieldValue.serverTimestamp(),
      });

      // 2. Kuantum Raporlama Paneline Bilgi Düş
      print("💰 Reklam Tıklaması Başarılı! Hedefe Yönlendiriliyor: ${kampanya.hedefLink}");

      // TODO: URL_Launcher paketi ile telefonu tarayıcıya veya hedefe yönlendir
      // launchUrl(Uri.parse(kampanya.hedefLink));

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Yönlendiriliyor: ${kampanya.sirketAd}", style: const TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.amber[700],
            duration: const Duration(seconds: 2),
          )
      );
    } catch (e) {
      print("Reklam Motoru Hatası: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sadece aktif reklamları göster
    if (!kampanya.aktifMi) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blueGrey[900]!, const Color(0xFF0D0D0D)]
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.amberAccent.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(color: Colors.amberAccent.withOpacity(0.1), blurRadius: 10, spreadRadius: 1)
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SPONSORLU MÜHRÜ
          const Row(
            children: [
              Icon(Icons.stars, color: Colors.amber, size: 16),
              SizedBox(width: 5),
              Text("SPONSORLU İÇERİK / ETKİNLİK", style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 12),

          // REKLAM METNİ VE FİRMA
          Text(kampanya.kampanyaBaslik, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(kampanya.sirketAd, style: const TextStyle(color: Colors.white70, fontSize: 12)),

          // GÖRSEL (Eğer URL varsa Kuantum Ağından yükler)
          if (kampanya.gorselUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                kampanya.gorselUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(height: 120, color: Colors.white10, child: const Icon(Icons.broken_image, color: Colors.grey)),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // FIRSATI YAKALA BUTONU (TETİKLEYİCİ)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
              ),
              onPressed: () => _reklamaTiklandi(context),
              child: const Text("FIRSATI YAKALA", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }
}