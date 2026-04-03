import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KuantumAracKunyesi extends StatelessWidget {
  final String plakaID;

  const KuantumAracKunyesi({super.key, required this.plakaID});

  @override
  Widget build(BuildContext context) {
    // 1. FİREBASE'DEN ARACIN CANLI DNA'SINI ÇEK
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('araclar').doc(plakaID).get(),
      builder: (context, snapshot) {

        // AĞ BEKLENİYOR
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF00FFC2)));
        }

        // ARAÇ BULUNAMADI (Sistemden silinmiş veya hatalı plaka)
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text("Siber Ağ Hatası: Araç Kuantum Ağında Bulunamadı!", style: TextStyle(color: Colors.redAccent)));
        }

        // 2. VERİLERİ PARÇALA
        var arac = snapshot.data!.data() as Map<String, dynamic>;

        String markaModel = "${arac['marka'] ?? 'Bilinmeyen'} ${arac['model'] ?? ''}";
        String yil = arac['yil']?.toString() ?? '-';
        String km = arac['km']?.toString() ?? '0';
        String fiyat = arac['fiyat']?.toString() ?? '0';
        int dnaSkoru = arac['dna_skoru'] ?? 0;
        bool kirmiziX = arac['kritik_hata_var_mi'] ?? false;
        String referansNotu = arac['muayene_durumu'] ?? 'Değerlendirme Bekliyor';

        // 3. KUANTUM GÖRSELLEŞTİRME (ARAYÜZ)
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(markaModel, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),

            // Teknik Tablo
            Container(
              decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetaySatiri("Üretim Yılı", yil),
                  _buildDetaySatiri("Kilometre", "$km KM"),
                  _buildDetaySatiri("Satış Fiyatı", "₺$fiyat"),
                  _buildDetaySatiri("DNA Skoru", "$dnaSkoru / 100"),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ⛔ VEYA ✅ OTODNA MÜHRÜ (CANLI EKSPERTİZ ÖZETİ)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // Kırmızı X varsa uyarı rengi, yoksa Kuantum Yeşili
                  color: kirmiziX ? Colors.redAccent.withOpacity(0.1) : const Color(0xFF00FFC2).withOpacity(0.1),
                  border: Border.all(color: kirmiziX ? Colors.redAccent : const Color(0xFF00FFC2), width: 1.5),
                  borderRadius: BorderRadius.circular(12)
              ),
              child: Row(
                children: [
                  Icon(
                      kirmiziX ? Icons.gavel : Icons.verified_user, // Karaliste çekici veya Onay kalkanı
                      color: kirmiziX ? Colors.redAccent : const Color(0xFF00FFC2),
                      size: 36
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            kirmiziX ? "DİKKAT: TRAFİĞE ÇIKIŞI RİSKLİ!" : "OtoDNA Referanslıdır",
                            style: TextStyle(
                                color: kirmiziX ? Colors.redAccent : const Color(0xFF00FFC2),
                                fontWeight: FontWeight.bold,
                                fontSize: 16
                            )
                        ),
                        const SizedBox(height: 4),
                        Text(
                            kirmiziX ? "Bu araçta Usta tarafından atılmış KIRMIZI X var!" : referansNotu,
                            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Özel Tasarım Satır Oluşturucu
  Widget _buildDetaySatiri(String baslik, String deger) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(baslik, style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
          Text(deger, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}