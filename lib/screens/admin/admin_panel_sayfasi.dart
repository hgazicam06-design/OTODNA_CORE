import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🚀 KARARGAH ZIRHLARI VE MUTLAK ROTA
import '../../../core/siber_tema.dart';
import '../../../core/responsive_kalkan.dart';

class AdminPanelSayfasi extends StatefulWidget {
  const AdminPanelSayfasi({super.key});

  @override
  State<AdminPanelSayfasi> createState() => _AdminPanelSayfasiState();
}

class _AdminPanelSayfasiState extends State<AdminPanelSayfasi> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  final Color bgColor = SiberTema.oledBlack;
  final Color surfaceColor = SiberTema.matGrey.withOpacity(0.1);
  final Color primaryCyan = SiberTema.kuantumCyan;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String _secilenUlke = "TÜRKİYE"; // Merkez Kilitli Başlangıç

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context)),
          title: const Text('G L O B A L   D E N E T İ M',
              style: TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 3,
                  fontFamily: 'Avenir')),
          centerTitle: true,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.radar, color: primaryCyan, size: 18),
            )
          ],
        ),
        body: Column(
          children: [
            // =================================================================
            // 1. SİBER ÜLKE SEÇİCİ (Kuantum Sekmeler)
            // =================================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05))),
                child: Row(
                  children: [
                    _buildUlkeSekmesi("TÜRKİYE", Icons.flag_outlined),
                    _buildUlkeSekmesi("ALMANYA", Icons.language_outlined),
                  ],
                ),
              ),
            ),

            // =================================================================
            // 2. İSTATİSTİK ÖZET KARTLARI (Canlı Veri Dinleyici)
            // =================================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: StreamBuilder<DocumentSnapshot>(
                  stream: _db.collection('global_istatistikler').doc(_secilenUlke).snapshots(),
                  builder: (context, snapshot) {
                    String toplamMuhur = "154";
                    String aktifBayi = "12";

                    if (snapshot.hasData && snapshot.data!.exists) {
                      var data = snapshot.data!.data() as Map<String, dynamic>;
                      toplamMuhur = (data['toplam_muhur'] ?? 0).toString();
                      aktifBayi = (data['aktif_bayi'] ?? 0).toString();
                    } else if (_secilenUlke == "ALMANYA") {
                      toplamMuhur = "28";
                      aktifBayi = "3";
                    }

                    return Row(
                      children: [
                        Expanded(child: _buildBilgiKarti("TOPLAM MÜHÜR", toplamMuhur, primaryCyan, Icons.verified_user_outlined)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildBilgiKarti("AKTİF BAYİ AĞI", aktifBayi, Colors.blueAccent, Icons.share_location_outlined)),
                      ],
                    );
                  }),
            ),
            const SizedBox(height: 32),

            // =================================================================
            // 3. BÖLGE BAZLI ANALİZ BAŞLIĞI
            // =================================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(Icons.hub_outlined, color: Colors.white.withOpacity(0.3), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("$_secilenUlke BÖLGE DAĞILIMI",
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        const SizedBox(height: 4),
                        const Text("Kuantum Ağı Üzerindeki Mühür Sayıları",
                            style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // =================================================================
            // 4. DİNAMİK BÖLGE LİSTESİ (FİREBASE)
            // =================================================================
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _db.collection('bolge_istatistikleri').where('ulke', isEqualTo: _secilenUlke).orderBy('muhur_sayisi', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: primaryCyan));

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    List<Map<String, dynamic>> bolgeler = _secilenUlke == "TÜRKİYE"
                        ? [
                      {"ad": "İÇ ANADOLU", "muhur": 64},
                      {"ad": "MARMARA", "muhur": 42},
                      {"ad": "EGE", "muhur": 28},
                      {"ad": "AKDENİZ", "muhur": 12},
                      {"ad": "KARADENİZ", "muhur": 8}
                    ]
                        : [
                      {"ad": "BAVYERA", "muhur": 14},
                      {"ad": "KUZEY ALMANYA", "muhur": 8},
                      {"ad": "HESSEN", "muhur": 6}
                    ];

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      itemCount: bolgeler.length,
                      itemBuilder: (context, index) => _buildBolgeSatiri(bolgeler[index]["ad"], bolgeler[index]["muhur"]),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      return _buildBolgeSatiri(data['bolge_adi'] ?? 'BİLİNMEYEN BÖLGE', data['muhur_sayisi'] ?? 0);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUlkeSekmesi(String ulkeAdi, IconData ikon) {
    bool isSelected = _secilenUlke == ulkeAdi;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _secilenUlke = ulkeAdi),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? primaryCyan.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isSelected ? primaryCyan.withOpacity(0.5) : Colors.transparent),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(ikon, color: isSelected ? primaryCyan : Colors.white38, size: 16),
              const SizedBox(width: 8),
              Text(ulkeAdi, style: TextStyle(color: isSelected ? primaryCyan : Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBilgiKarti(String baslik, String deger, Color renk, IconData ikon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: renk.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: renk.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(baslik, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
              Icon(ikon, color: renk, size: 16),
            ],
          ),
          const SizedBox(height: 16),
          Text(deger, style: TextStyle(color: renk, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1)),
        ],
      ),
    );
  }

  Widget _buildBolgeSatiri(String bolgeAdi, int muhurSayisi) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: primaryCyan.withOpacity(0.05), borderRadius: BorderRadius.circular(10), border: Border.all(color: primaryCyan.withOpacity(0.2))),
            child: const Icon(Icons.my_location_outlined, color: primaryCyan, size: 16),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(bolgeAdi, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(muhurSayisi.toString(), style: TextStyle(color: primaryCyan, fontSize: 18, fontWeight: FontWeight.w900)),
              const Text("MÜHÜR", style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ],
          )
        ],
      ),
    );
  }
}