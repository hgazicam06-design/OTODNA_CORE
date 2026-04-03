import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SiberBakimKarnesiScreen extends StatefulWidget {
  final String plaka;
  final String markaModel;
  final String saseNo;

  const SiberBakimKarnesiScreen({
    super.key,
    required this.plaka,
    required this.markaModel,
    required this.saseNo,
  });

  @override
  State<SiberBakimKarnesiScreen> createState() => _SiberBakimKarnesiScreenState();
}

class _SiberBakimKarnesiScreenState extends State<SiberBakimKarnesiScreen> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  static const Color bgColor = Color(0xFF000000);
  static const Color surfaceColor = Color(0xFF111111);
  static const Color primaryCyan = Color(0xFF00FFC2);
  static const Color dangerColor = Colors.redAccent;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: primaryCyan, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('D İ J İ T A L   B A K I M   A Ğ I', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 3)),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: primaryCyan.withOpacity(0.5))),
            child: const Icon(Icons.qr_code_scanner, color: primaryCyan, size: 16),
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
                // 1. ARAÇ KİMLİĞİ VE DNA DURUMU (Holografik Kart)
                // =================================================================
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: primaryCyan.withOpacity(0.3), width: 1.5),
                      boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.05), blurRadius: 40)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.markaModel.toUpperCase(), style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                                  const SizedBox(height: 8),
                                  Text(widget.plaka.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
                              child: const Icon(Icons.health_and_safety_outlined, color: primaryCyan, size: 32),
                            )
                          ],
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.white12)),
                        Row(
                          children: [
                            const Icon(Icons.memory, color: Colors.white38, size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text("ŞASE (VIN): ${widget.saseNo.toUpperCase()}", style: const TextStyle(color: Colors.white54, fontSize: 11, fontFamily: 'monospace', letterSpacing: 1.5, fontWeight: FontWeight.bold))),
                          ],
                        )
                      ],
                    ),
                  ),
                ),

                // =================================================================
                // 2. GELECEK BAKIM RADARI (Yapay Zeka Tahmini)
                // =================================================================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Icon(Icons.timeline, color: Colors.white.withOpacity(0.3), size: 20),
                      const SizedBox(width: 12),
                      const Text("SİBER BAKIM GEÇMİŞİ VE İŞLEM LOGLARI", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // =================================================================
                // 3. FİREBASE'DEN ÇEKİLEN BAKIM LOGLARI (Siber Timeline)
                // =================================================================
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _db.collection('bakim_kayitlari')
                        .where('plaka', isEqualTo: widget.plaka)
                        .orderBy('tarih', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: primaryCyan));
                      }

                      // 🚨 EĞER VERİ YOKSA GÖSTERİLECEK ZIRHLI MOCK VERİLER (Görseli test etmek için)
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          children: [
                            _buildBakimLogu("12.03.2026", "112.500 KM", "GAZİ OTOMOTİV HQ", ["TRİGER SETİ", "V KAYIŞI", "DEVİRDAİM"], true),
                            _buildBakimLogu("05.11.2025", "100.000 KM", "İSTANBUL ELİT SERVİS", ["PERİYODİK BAKIM", "HAVA FİLTRESİ", "MOTOR YAĞI"], true),
                            _buildBakimLogu("14.05.2025", "85.200 KM", "BİLİNMEYEN SERVİS", ["FREN BALATASI"], false), // Kırmızı İhlal Kartı (Sistem dışı servis)
                          ],
                        );
                      }

                      // GERÇEK FİREBASE VERİLERİ
                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;

                          // Firestore Timestamp'i String'e çevirme mantığı
                          String tarih = "BİLİNMİYOR";
                          if (data['tarih'] != null) {
                            DateTime dt = (data['tarih'] as Timestamp).toDate();
                            tarih = "${dt.day.toString().padLeft(2,'0')}.${dt.month.toString().padLeft(2,'0')}.${dt.year}";
                          }

                          List<dynamic> parcalar = data['degisen_parcalar'] ?? [];
                          List<String> stringParcalar = parcalar.map((e) => e.toString()).toList();

                          return _buildBakimLogu(
                              tarih,
                              "${data['km'] ?? '0'} KM",
                              data['servis_adi'] ?? 'OTO DNA SERVİSİ',
                              stringParcalar,
                              data['otodna_onayli'] ?? true
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

      // =================================================================
      // 4. ALT AKSİYON: YENİ MÜHÜR VUR (Sadece Yetkili Ustalar İçin)
      // =================================================================
      bottomNavigationBar: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800), // Web'de butonun uzamasını engeller
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(color: surfaceColor, border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05)))),
              child: SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryCyan,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    // TODO: Yeni Bakım Ekleme Ekranına Gider (usta_paneli.dart)
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("YENİ BAKIM TERMİNALİ BAŞLATILIYOR...", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: primaryCyan));
                  },
                  icon: const Icon(Icons.add_moderator, size: 20),
                  label: const Text("YENİ BAKIM MÜHRÜ VUR", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: SİBER BAKIM TİMELİNE LOGU
  Widget _buildBakimLogu(String tarih, String km, String servis, List<String> parcalar, bool otoDnaOnayli) {
    Color durumRengi = otoDnaOnayli ? primaryCyan : dangerColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: otoDnaOnayli ? Colors.white.withOpacity(0.05) : dangerColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ÜST BİLGİ BARI (Tarih & KM & Onay)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: otoDnaOnayli ? bgColor : dangerColor.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.speed, color: durumRengi, size: 16),
                    const SizedBox(width: 8),
                    Text(km, style: TextStyle(color: durumRengi, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
                  ],
                ),
                Text(tarih, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ],
            ),
          ),

          // İÇERİK ALANI (Servis & Parçalar)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Servis Bilgisi
                Row(
                  children: [
                    Icon(otoDnaOnayli ? Icons.verified : Icons.warning_amber_rounded, color: durumRengi, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(servis.toUpperCase(), style: TextStyle(color: otoDnaOnayli ? Colors.white : dangerColor, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1))),
                    if (otoDnaOnayli) ...[
                      const SizedBox(width: 8),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: primaryCyan.withOpacity(0.5))), child: const Text("AĞ ONAYLI", style: TextStyle(color: primaryCyan, fontSize: 7, fontWeight: FontWeight.w900)))
                    ]
                  ],
                ),
                const SizedBox(height: 16),

                // Değişen Parçalar (Kuantum Çipler)
                const Text("MÜDAHALE EDİLEN DONANIMLAR:", style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: parcalar.map((p) => _buildParcaCipi(p, otoDnaOnayli)).toList(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: DEĞİŞEN PARÇA ÇİPİ
  Widget _buildParcaCipi(String parcaAdi, bool otoDnaOnayli) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: otoDnaOnayli ? primaryCyan.withOpacity(0.3) : dangerColor.withOpacity(0.3)),
      ),
      child: Text(
        parcaAdi.toUpperCase(),
        style: TextStyle(color: otoDnaOnayli ? Colors.white70 : dangerColor.withOpacity(0.8), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    );
  }
}