import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminGlobalPanel extends StatefulWidget {
  const AdminGlobalPanel({super.key});

  @override
  State<AdminGlobalPanel> createState() => _AdminGlobalPanelState();
}

class _AdminGlobalPanelState extends State<AdminGlobalPanel> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  final Color bgColor = const Color(0xFF000000);
  final Color surfaceColor = const Color(0xFF111111);
  final Color primaryCyan = const Color(0xFF00FFC2);

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Yeni Ülke Ekleme Simülasyonu
  void _yeniUlkeAgaEkle() {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("YENİ DİSTRİBÜTÖR AĞI OLUŞTURULUYOR... 🌍", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1)),
          backgroundColor: primaryCyan,
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('G L O B A L   S İ B E R   A Ğ', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 3)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.public, color: Colors.white54), onPressed: () {}),
          const SizedBox(width: 8)
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =================================================================
          // 1. ÜST BİLGİ VE RADAR PANELİ
          // =================================================================
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: primaryCyan.withOpacity(0.3), width: 1.5),
                boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.05), blurRadius: 40)],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle, border: Border.all(color: primaryCyan.withOpacity(0.5))),
                    child: const Icon(Icons.radar, color: primaryCyan, size: 32),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("OTODNA KÜRESEL UYDU BAĞLANTISI", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: primaryCyan, shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            const Text("SİSTEM ÇEVRİMİÇİ | MERKEZ: ANKARA HQ", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("AKTİF ÜLKE VE BÖLGELER", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                Icon(Icons.satellite_alt_outlined, color: Colors.white.withOpacity(0.2), size: 16),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // =================================================================
          // 2. FİREBASE CANLI DİSTRİBÜTÖR AĞI
          // =================================================================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db.collection('global_aglari').orderBy('oncelik', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: primaryCyan));

                // EĞER VERİTABANI BOŞSA, İLK KURULUM (MOCK) GÖRÜNTÜSÜ GELSİN
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      _buildUlkeKarti("TR", "TÜRKİYE (MERKEZ)", "81 İl / 7 Bölge Kuantum Ağı", "AKTİF", primaryCyan),
                      _buildUlkeKarti("DE", "ALMANYA (BERLİN)", "Avrupa Dağıtım Terminali Planlanıyor", "STANDBY", Colors.orangeAccent),
                      _buildUlkeKarti("AZ", "AZERBAYCAN (BAKÜ)", "Siber Görüşmeler Devam Ediyor", "PASİF", Colors.blueAccent),
                      _buildUlkeKarti("RU", "RUSYA (MOSKOVA)", "Ambargo Nedeniyle Askıda", "KARA LİSTE", Colors.redAccent),
                    ],
                  );
                }

                // FİREBASE'DEN GELEN CANLI VERİ
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var veri = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    String kod = veri['kod'] ?? 'XX';
                    String ulke = veri['ulke'] ?? 'Bilinmeyen Bölge';
                    String detay = veri['detay'] ?? 'Bağlantı Bekleniyor...';
                    String durum = veri['durum'] ?? 'PASİF';

                    Color durumRengi = Colors.blueAccent;
                    if (durum == 'AKTİF') durumRengi = primaryCyan;
                    if (durum == 'STANDBY') durumRengi = Colors.orangeAccent;
                    if (durum == 'KARA LİSTE') durumRengi = Colors.redAccent;

                    return _buildUlkeKarti(kod, ulke, detay, durum, durumRengi);
                  },
                );
              },
            ),
          ),
        ],
      ),

      // =================================================================
      // 3. ALT AKSİYON BUTONU (YENİ DİSTRİBÜTÖR)
      // =================================================================
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(color: surfaceColor, border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05)))),
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: bgColor,
                foregroundColor: primaryCyan,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryCyan.withOpacity(0.5))),
              ),
              onPressed: _yeniUlkeAgaEkle,
              icon: const Icon(Icons.add_location_alt_outlined, size: 20),
              label: const Text("YENİ ÜLKE / BÖLGE İSKELETİ OLUŞTUR", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ),
        ),
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: ÜLKE SİBER KARTI
  Widget _buildUlkeKarti(String kod, String ulke, String detay, String durum, Color renk) {
    bool isKaraListe = durum == 'KARA LİSTE';

    return Opacity(
      opacity: isKaraListe ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isKaraListe ? Colors.redAccent.withOpacity(0.3) : Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            // Ülke Kodu Kutusu (Örn: TR, DE)
            Container(
              width: 56, height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: renk.withOpacity(0.3))),
              child: Text(kod.toUpperCase(), style: TextStyle(color: renk, fontSize: 18, fontWeight: FontWeight.w900)),
            ),
            const SizedBox(width: 16),

            // Ülke Bilgisi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ulke.toUpperCase(), style: TextStyle(color: isKaraListe ? Colors.redAccent : Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5, decoration: isKaraListe ? TextDecoration.lineThrough : TextDecoration.none)),
                  const SizedBox(height: 6),
                  Text(detay, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Durum Rozeti (AKTİF, STANDBY vb.)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: renk.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: renk.withOpacity(0.5))),
              child: Text(durum, style: TextStyle(color: renk, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ],
        ),
      ),
    );
  }
}