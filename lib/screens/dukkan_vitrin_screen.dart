import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DukkanVitrinScreen extends StatelessWidget {
  final String dukkanId;
  final String dukkanAdi;

  const DukkanVitrinScreen({super.key, required this.dukkanId, required this.dukkanAdi});

  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  static const Color bgColor = Color(0xFF000000);
  static const Color surfaceColor = Color(0xFF111111);
  static const Color primaryCyan = Color(0xFF00FFC2);
  static const Color dangerColor = Colors.redAccent;

  @override
  Widget build(BuildContext context) {
    // 💻 Web Responsive (Duyarlı) Kalkanı
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 1200 ? 5 : (screenWidth > 800 ? 4 : (screenWidth > 600 ? 3 : 2));

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            const Text('S İ B E R   V İ T R İ N', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 3)),
            const SizedBox(height: 2),
            Text(dukkanAdi.toUpperCase(), style: const TextStyle(color: Color(0xFF00FFC2), fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 2)),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            children: [
              _buildSiberDukkanHeader(),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  // Firebase'den bu dükkana ait yedek parçaları/stokları anlık çekiyoruz
                  stream: FirebaseFirestore.instance
                      .collection('yedek_parcalar')
                      .where('satici_id', isEqualTo: dukkanId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: primaryCyan, strokeWidth: 2));
                    }

                    if (snapshot.hasError) {
                      return _buildBilgiEkrani(Icons.warning_amber_rounded, dangerColor, 'AĞ BAĞLANTI HATASI');
                    }

                    final docs = snapshot.data?.docs ?? [];

                    // Eğer firmanın stoğu yoksa
                    if (docs.isEmpty) {
                      return _buildBilgiEkrani(Icons.inventory_2_outlined, Colors.white24, 'BU FİRMANIN SİBER STOĞU BOŞ');
                    }

                    return GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.75, // Kartın uzunluk-genişlik oranı (Tesla dikey kartlar)
                      ),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        return _buildKuantumUrunKarti(context, data);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: DÜKKAN MÜHRÜ (HEADER)
  Widget _buildSiberDukkanHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryCyan.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.05), blurRadius: 40)],
      ),
      child: Row(
        children: [
          // Kuantum Çemberli Firma Logosu/İkonu
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(color: primaryCyan.withOpacity(0.5)),
            ),
            child: const Icon(Icons.store_mall_directory_outlined, color: primaryCyan, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified, color: primaryCyan, size: 14),
                    const SizedBox(width: 6),
                    const Text("OTODNA ONAYLI BAYİ AĞI", style: TextStyle(color: primaryCyan, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(dukkanAdi.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: DİNAMİK ÜRÜN KARTI
  Widget _buildKuantumUrunKarti(BuildContext context, Map<String, dynamic> data) {
    final ad = data['urunAdi'] ?? 'BİLİNMEYEN DONANIM';
    final fiyat = (data['fiyat'] ?? 0).toDouble();
    final stokDurumu = data['stokta_var_mi'] ?? true;
    final gorsel = data['gorsel_url']; // İleride Image.network eklenecek

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: stokDurumu ? Colors.white.withOpacity(0.05) : dangerColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Holografik Görsel Alanı
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
              ),
              child: Center(
                child: gorsel != null && gorsel.toString().isNotEmpty
                    ? const Icon(Icons.image_outlined, color: Colors.white24, size: 48) // Geçiçi network kalkanı
                    : const Icon(Icons.settings_suggest_outlined, color: Colors.white24, size: 48),
              ),
            ),
          ),
          // Bilgi Alanı
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ad.toString().toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, height: 1.4),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "₺${fiyat.toStringAsFixed(2)}",
                        style: TextStyle(color: stokDurumu ? primaryCyan : Colors.white38, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'monospace'),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: stokDurumu ? primaryCyan.withOpacity(0.1) : dangerColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          stokDurumu ? Icons.add_shopping_cart : Icons.block,
                          color: stokDurumu ? primaryCyan : dangerColor,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: BİLGİ / HATA EKRANI
  Widget _buildBilgiEkrani(IconData icon, Color renk, String mesaj) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(shape: BoxShape.circle, color: surfaceColor, border: Border.all(color: renk.withOpacity(0.3))),
          child: Icon(icon, color: renk, size: 48),
        ),
        const SizedBox(height: 24),
        Text(mesaj, style: TextStyle(color: renk, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2)),
      ],
    );
  }
}