import 'package:flutter/material.dart';

class AracDnaRaporuScreen extends StatefulWidget {
  const AracDnaRaporuScreen({super.key});

  @override
  State<AracDnaRaporuScreen> createState() => _AracDnaRaporuScreenState();
}

class _AracDnaRaporuScreenState extends State<AracDnaRaporuScreen> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  // SINIRSIZ ARAÇ VERİTABANI VE ORİJİNAL MOTOR GÜÇLERİ (HP)
  int _seciliAracIndex = 0;
  final List<Map<String, dynamic>> _araclar = [
    {
      "plaka": "34 DNA 2026",
      "model": "Tesla Model Y",
      "hp": "Long Range AWD (514 HP)",
      "anaSkor": 92, "kaporta": 70, "mekanik": 39, "menzil": 311,
      "renk": const Color(0xFF00FFC2) // Kusursuz - Turkuaz
    },
    {
      "plaka": "06 GZ 1071",
      "model": "BMW M3 Competition",
      "hp": "S58 Twin-Turbo (510 HP)",
      "anaSkor": 85, "kaporta": 90, "mekanik": 65, "menzil": 120,
      "renk": Colors.orangeAccent // Uyarı - Turuncu
    },
    {
      "plaka": "35 SBR 99",
      "model": "Mercedes AMG GT",
      "hp": "V8 BiTurbo (577 HP)",
      "anaSkor": 98, "kaporta": 100, "mekanik": 95, "menzil": 450,
      "renk": const Color(0xFF3B82F6) // Premium - Mavi
    }
  ];

  @override
  void initState() {
    super.initState();
    // Resmi Rapor Işıması (Daha yavaş ve ağırbaşlı bir nabız efekti)
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🌑 DİJİTAL KALE / E-DEVLET RENK PALETİ
    const bgColor = Color(0xFF070B14);
    const cardColor = Color(0xFF121B2B);

    var aktifArac = _araclar[_seciliAracIndex];
    Color siberRenk = aktifArac['renk'];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: siberRenk, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_user, color: Colors.white70, size: 20),
            SizedBox(width: 8),
            Text("Resmi DNA Raporu", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // =================================================================
            // 1. DOSYA / ARAÇ SEÇİM BÖLÜMÜ (Kurumsal Klasör Mantığı)
            // =================================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                color: cardColor,
                border: Border(bottom: BorderSide(color: Colors.white12, width: 1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("İNCELENEN ARAÇ DOSYASI", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: siberRenk.withOpacity(0.5))),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _seciliAracIndex,
                        dropdownColor: cardColor,
                        isExpanded: true,
                        icon: Icon(Icons.expand_circle_down, color: siberRenk),
                        items: List.generate(_araclar.length, (index) {
                          return DropdownMenuItem(
                            value: index,
                            child: Row(
                              children: [
                                Icon(Icons.directions_car, color: _araclar[index]['renk'], size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("${_araclar[index]['plaka']} - ${_araclar[index]['model']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                      Text("Orijinal Güç: ${_araclar[index]['hp']}", style: const TextStyle(color: Colors.white54, fontSize: 11)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        onChanged: (value) => setState(() => _seciliAracIndex = value!),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // =================================================================
            // 2. RESMİ DİYAGNOSTİK (ANALİZ) EKRANI
            // =================================================================
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // YENİ EKLENEN: AĞ DURUMU BİLDİRİMİ
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_tethering, color: siberRenk, size: 16),
                        const SizedBox(width: 8),
                        Text("OtoDNA Merkezi Sunucusu ile Senkronize", style: TextStyle(color: siberRenk, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // DEVASA ANA SKOR (Oyuncak kutusu yerine Resmi Sertifika Paneli)
                    AnimatedBuilder(
                      animation: _glowController,
                      builder: (context, child) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: siberRenk.withOpacity(0.3), width: 2),
                            // Hafif ve ağırbaşlı bir nabız ışıması
                            boxShadow: [BoxShadow(color: siberRenk.withOpacity(0.15 * _glowController.value), blurRadius: 40, spreadRadius: 5)],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Üst Modül İkonları
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.memory, color: siberRenk.withOpacity(0.5), size: 24),
                                  const SizedBox(width: 16),
                                  Icon(Icons.health_and_safety, color: siberRenk, size: 32),
                                  const SizedBox(width: 16),
                                  Icon(Icons.speed, color: siberRenk.withOpacity(0.5), size: 24),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Text("%${aktifArac['anaSkor']}", style: TextStyle(color: siberRenk, fontSize: 64, fontWeight: FontWeight.w900, letterSpacing: -2)),
                              const SizedBox(height: 8),
                              const Text("GENEL DNA SAĞLIK SKORU", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // ALT SENSÖRLER VE MENZİL (Yan Yana Kurumsal Kartlar)
                    Row(
                      children: [
                        Expanded(child: _buildKurumsalSensor("Mekanik Durum", aktifArac['mekanik'], siberRenk)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildKurumsalSensor("Kaporta Bütünlüğü", aktifArac['kaporta'], siberRenk)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Ömür / Menzil Kartı
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
                      child: Row(
                        children: [
                          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.update, color: Colors.white70)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Tahmini Sorunsuz Kullanım", style: TextStyle(color: Colors.white54, fontSize: 12)),
                                const SizedBox(height: 4),
                                Text("${aktifArac['menzil']} GÜN", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // =================================================================
                    // E-İMZALI RAPOR İNDİRME BUTONU (Resmiyet Katıldı)
                    // =================================================================
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryCyan,
                          foregroundColor: bgColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 5,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("e-İmzalı Resmi Rapor İndiriliyor..."), backgroundColor: primaryCyan));
                        },
                        icon: const Icon(Icons.download_rounded, size: 24),
                        label: const Text("E-İMZALI PDF RAPORUNU İNDİR", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text("Bu rapor OtoDNA Kuantum Ağı tarafından kriptolanmıştır.", style: TextStyle(color: Colors.white38, fontSize: 10)),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // YARDIMCI WİDGET: KURUMSAL SENSÖR KARTLARI
  Widget _buildKurumsalSensor(String baslik, int yuzde, Color renk) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
          color: const Color(0xFF121B2B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12)
      ),
      child: Column(
        children: [
          SizedBox(
            width: 70, height: 70,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(value: yuzde / 100, color: renk, backgroundColor: Colors.white12, strokeWidth: 8),
                Center(child: Text("%$yuzde", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(baslik, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}