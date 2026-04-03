import 'package:flutter/material.dart';

class SiberDijitalTorpidoScreen extends StatefulWidget {
  const SiberDijitalTorpidoScreen({super.key});

  @override
  State<SiberDijitalTorpidoScreen> createState() => _SiberDijitalTorpidoScreenState();
}

class _SiberDijitalTorpidoScreenState extends State<SiberDijitalTorpidoScreen> {
  bool _belgeTaraniyor = false;

  // 💎 KOMUTANIN İSTEDİĞİ EKSİKSİZ TORPİDO LİSTESİ
  final List<Map<String, dynamic>> _evraklar = [
    {"baslik": "Sürücü Belgesi (Ehliyet)", "kurum": "Nüfus Müdürlüğü", "gecerlilik": "2032", "durum": "Gecerli", "ikon": Icons.badge_outlined, "renk": const Color(0xFF00FFC2)},
    {"baslik": "Araç Ruhsatı", "kurum": "Noterler Birliği", "gecerlilik": "Süresiz", "durum": "Gecerli", "ikon": Icons.directions_car_outlined, "renk": Colors.blueAccent},
    {"baslik": "Kasko Poliçesi", "kurum": "Anadolu Sigorta", "gecerlilik": "25 Nisan 2026", "durum": "Yaklasiyor", "ikon": Icons.shield_outlined, "renk": Colors.orangeAccent},
    {"baslik": "TÜVTÜRK Muayene Raporu", "kurum": "TÜVTÜRK", "gecerlilik": "12 Ekim 2026", "durum": "Gecerli", "ikon": Icons.fact_check_outlined, "renk": const Color(0xFF00FFC2)},
    {"baslik": "Egzoz Emisyon Raporu", "kurum": "Çevre Bakanlığı", "gecerlilik": "01 Mart 2026", "durum": "Gecersiz", "ikon": Icons.cloud_off_outlined, "renk": Colors.redAccent},
    {"baslik": "Trafik Cezası Makbuzları", "kurum": "Emniyet Genel Müd.", "gecerlilik": "Tümü Ödendi", "durum": "Gecerli", "ikon": Icons.receipt_long_outlined, "renk": Colors.white54},
    {"baslik": "Yakıt Fişleri & Giderler", "kurum": "Opet / Shell", "gecerlilik": "Son 30 Gün", "durum": "Gecerli", "ikon": Icons.local_gas_station_outlined, "renk": Colors.white54},
  ];

  // 💎 TESLA MİMARİSİ: ŞIK BOTTOM SHEET (YÜKLEME MENÜSÜ)
  void _yeniBelgeTarat() {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: const Color(0xFF00FFC2).withOpacity(0.2))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 24),
            const Row(children: [Icon(Icons.document_scanner_outlined, color: Color(0xFF00FFC2)), SizedBox(width: 12), Text("Siber Ağa Belge Ekle", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5))]),
            const SizedBox(height: 8),
            const Text("Eklemek istediğiniz belgenin formatını seçin. Yapay zeka verileri otomatik okuyacaktır.", style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5)),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(child: _buildYonetimButonu(Icons.camera_alt_outlined, "AI Kamera ile\nTara & Oku", const Color(0xFF00FFC2), () { Navigator.pop(context); _ocrTaramaSimulasyonu("AI Tarama"); })),
                const SizedBox(width: 16),
                Expanded(child: _buildYonetimButonu(Icons.upload_file_outlined, "Cihazdan PDF\nveya Dosya Yükle", Colors.blueAccent, () { Navigator.pop(context); _ocrTaramaSimulasyonu("Dosya"); })),
              ],
            ),
            const SizedBox(height: 16),
            // KOMUTANIN İSTEDİĞİ "DİĞER ÖZEL BELGE EKLE" BUTONU
            SizedBox(
              width: double.infinity, height: 56,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.white.withOpacity(0.1)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Özel Belge Formu Açılıyor..."), backgroundColor: Color(0xFF00FFC2)));
                },
                icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                label: const Text("ÖZEL/DİĞER BİR BELGE EKLE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // 💎 YAPAY ZEKA OKUMA SİMÜLASYONU (HUD EFEKTİYLE)
  void _ocrTaramaSimulasyonu(String tip) {
    setState(() => _belgeTaraniyor = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _belgeTaraniyor = false;
        _evraklar.insert(0, {"baslik": "Yeni Yüklenen Belge (AI)", "kurum": "Kuantum Doğrulama", "gecerlilik": "Analiz Ediliyor", "durum": "Gecerli", "ikon": Icons.file_present_outlined, "renk": const Color(0xFF00FFC2)});
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF111111),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF00FFC2).withOpacity(0.5))),
          title: const Row(children: [Icon(Icons.psychology_outlined, color: Color(0xFF00FFC2)), SizedBox(width: 10), Text("AI Optik Analiz", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))]),
          content: const Text("Yüklediğiniz belge Kuantum OCR Ağı tarafından analiz edildi ve Torpidoya başarıyla şifrelendi.", style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5)),
          actions: [
            ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FFC2), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: () => Navigator.pop(context),
                child: const Text("TORPİDOYA GİR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1))
            )
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🌑 TESLA MİMARİSİ
    const primaryCyan = Color(0xFF00FFC2);
    const bgColor = Color(0xFF000000);
    const surfaceColor = Color(0xFF111111);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
          backgroundColor: Colors.transparent, elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
          title: const Text("D İ J İ T A L   T O R P İ D O", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 3)),
          centerTitle: true
      ),

      // FLOATING ACTION BUTONU
      floatingActionButton: FloatingActionButton.extended(
          backgroundColor: surfaceColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.1))),
          onPressed: _belgeTaraniyor ? null : _yeniBelgeTarat,
          icon: const Icon(Icons.add, color: primaryCyan),
          label: const Text("Belge Ekle", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1))
      ),

      body: _belgeTaraniyor
      // 💎 YAPAY ZEKA İŞLEM EKRANI
          ? Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: primaryCyan.withOpacity(0.3), width: 2), boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.1), blurRadius: 40)]),
                    child: const Icon(Icons.document_scanner_outlined, color: primaryCyan, size: 48)
                ),
                const SizedBox(height: 32),
                SizedBox(width: 200, child: LinearProgressIndicator(backgroundColor: Colors.white.withOpacity(0.05), color: primaryCyan, minHeight: 2)),
                const SizedBox(height: 16),
                const Text("Siber Optik Okuyucu (AI) devrede...\nLütfen bekleyin.", textAlign: TextAlign.center, style: TextStyle(color: primaryCyan, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1, height: 1.5))
              ]
          )
      )
      // 💎 EVRAK LİSTESİ
          : Column(
        children: [
          // ÜST BİLGİ KARTI
          Container(
            width: double.infinity, padding: const EdgeInsets.all(20), margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
            child: const Row(
                children: [
                  Icon(Icons.psychology_outlined, color: primaryCyan, size: 36),
                  SizedBox(width: 16),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("AI Hatırlatıcı Devrede", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text("Sisteme yüklediğiniz belgelerin süresi dolmadan Siber Asistan sizi uyarır.", style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.4))
                          ]
                      )
                  )
                ]
            ),
          ),

          // LİSTE
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemCount: _evraklar.length,
              itemBuilder: (context, index) {
                var evrak = _evraklar[index];
                Color durumRengi = Colors.white54;
                String durumMetni = "Sistemde Kayıtlı";
                IconData durumIkonu = Icons.check_circle_outline;

                // DURUM ANALİZİ
                if (evrak['durum'] == "Gecerli" && evrak['renk'] == primaryCyan) {
                  durumRengi = primaryCyan; durumMetni = "Geçerli"; durumIkonu = Icons.verified_outlined;
                } else if (evrak['durum'] == "Yaklasiyor") {
                  durumRengi = Colors.orangeAccent; durumMetni = "Süre Bitiyor"; durumIkonu = Icons.warning_amber_rounded;
                } else if (evrak['durum'] == "Gecersiz") {
                  durumRengi = Colors.redAccent; durumMetni = "Süresi Doldu!"; durumIkonu = Icons.error_outline;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: durumRengi == Colors.redAccent || durumRengi == Colors.orangeAccent ? durumRengi.withOpacity(0.5) : Colors.white.withOpacity(0.05)),
                      boxShadow: durumRengi == Colors.redAccent ? [BoxShadow(color: Colors.redAccent.withOpacity(0.1), blurRadius: 15)] : []
                  ),
                  child: Row(
                    children: [
                      // İKON KUTUSU
                      Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: evrak['renk'].withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: evrak['renk'].withOpacity(0.2))),
                          child: Icon(evrak['ikon'], color: evrak['renk'], size: 24)
                      ),
                      const SizedBox(width: 16),

                      // ORTA METİN
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(evrak['baslik'], style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                                const SizedBox(height: 4),
                                Text(evrak['kurum'], style: const TextStyle(color: Colors.white54, fontSize: 11)),
                                const SizedBox(height: 12),
                                Row(
                                    children: [
                                      const Icon(Icons.event_outlined, color: Colors.white24, size: 14),
                                      const SizedBox(width: 6),
                                      Text("Bitiş/Durum: ${evrak['gecerlilik']}", style: TextStyle(color: durumRengi == Colors.redAccent ? Colors.redAccent : Colors.white70, fontSize: 10, fontWeight: FontWeight.bold))
                                    ]
                                )
                              ]
                          )
                      ),

                      // SAĞ BİLDİRİM
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Icon(durumIkonu, color: durumRengi, size: 18),
                            const SizedBox(height: 6),
                            Text(durumMetni, style: TextStyle(color: durumRengi, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                            const SizedBox(height: 16),
                            const Text("AÇ / GÖR", style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))
                          ]
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 80), // Fab butonu için alt boşluk
        ],
      ),
    );
  }

  // 💎 YÖNETİM BUTONLARI (Bottom Sheet İçin)
  Widget _buildYonetimButonu(IconData ikon, String baslik, Color renk, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(color: const Color(0xFF000000), borderRadius: BorderRadius.circular(16), border: Border.all(color: renk.withOpacity(0.3))),
        child: Column(
            children: [
              Icon(ikon, color: renk, size: 28),
              const SizedBox(height: 12),
              Text(baslik, textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, height: 1.4))
            ]
        ),
      ),
    );
  }
}