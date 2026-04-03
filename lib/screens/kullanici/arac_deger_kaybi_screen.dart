import 'package:flutter/material.dart';

class AracDegerKaybiScreen extends StatefulWidget {
  const AracDegerKaybiScreen({super.key});

  @override
  State<AracDegerKaybiScreen> createState() => _AracDegerKaybiScreenState();
}

class _AracDegerKaybiScreenState extends State<AracDegerKaybiScreen> {
  bool _hesaplaniyor = false;
  bool _sonucGoster = false;

  void _aiHesaplamaBaslat() {
    setState(() { _hesaplaniyor = true; _sonucGoster = false; });
    // Yapay Zeka Kuantum Hesaplama Simülasyonu (3 saniye)
    Future.delayed(const Duration(seconds: 3), () {
      setState(() { _hesaplaniyor = false; _sonucGoster = true; });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Siber AI Analizi Tamamlandı! 🧠"), backgroundColor: Color(0xFF00FFC2)));
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🌑 DİJİTAL KALE RENK PALETİ
    const bgColor = Color(0xFF070B14); // Derin Uzay Siyahı
    const primaryCyan = Color(0xFF00FFC2); // Kuantum Turkuazı
    const panelColor = Color(0xFF121B2B); // Koyu Cam Rengi

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor.withOpacity(0.5), shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back_ios_new, color: primaryCyan, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Yapay Zeka Değer Kaybı", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🌟 1. YENİ SEKME: HUKUK AĞI DURUM PANELİ
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryCyan.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primaryCyan.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.account_balance, color: primaryCyan, size: 20),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Emsal Karar Ağı: Senkronize", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        SizedBox(height: 4),
                        Text("Yargıtay veritabanı ile eşzamanlı çalışıyor.", style: TextStyle(color: Colors.white54, fontSize: 11)),
                      ],
                    ),
                  ),
                  const Icon(Icons.wifi_tethering, color: primaryCyan, size: 18),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 🚨 2. ÜST BİLGİ KARTI (Daha Siber ve Keskin)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3), width: 1.5),
                  boxShadow: [BoxShadow(color: const Color(0xFFEF4444).withOpacity(0.05), blurRadius: 15)]
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.gavel, color: Color(0xFFEF4444), size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("HUKUKİ AI MOTORU", style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.2)),
                            SizedBox(height: 6),
                            Text("Kazaya karışan aracınızın piyasa değer kaybını Kuantum AI motoru ile saniyeler içinde hesaplayın.", style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.4))
                          ]
                      )
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 🛠️ 3. FORM ALANI (Glassmorphism Cam Efekti)
            const Text("KAZA VE HASAR DETAYLARI", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 16),
            _buildSiberGirisAlani("Kusur Oranınız (%)", "Örn: %0 (Haklı Taraf)", Icons.pie_chart_outline, panelColor, primaryCyan),
            _buildSiberGirisAlani("Değişen Parça Sayısı", "Örn: 2", Icons.build_circle_outlined, panelColor, primaryCyan),
            _buildSiberGirisAlani("Boyanan Parça Sayısı", "Örn: 3", Icons.format_paint_outlined, panelColor, primaryCyan),
            _buildSiberGirisAlani("Güncel Kilometre", "Örn: 45.000", Icons.speed_outlined, panelColor, primaryCyan),
            const SizedBox(height: 32),

            // 🚀 4. HESAPLA BUTONU (Neon Işımalı)
            _hesaplaniyor
                ? Center(
                child: Column(
                    children: [
                      const SizedBox(
                        height: 40, width: 40,
                        child: CircularProgressIndicator(color: primaryCyan, strokeWidth: 3),
                      ),
                      const SizedBox(height: 16),
                      Text("Siber AI Emsal Kararları Tarıyor...", style: TextStyle(color: primaryCyan.withOpacity(0.8), fontWeight: FontWeight.bold, letterSpacing: 1))
                    ]
                )
            )
                : SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: primaryCyan,
                        foregroundColor: bgColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 10,
                        shadowColor: primaryCyan.withOpacity(0.5)
                    ),
                    onPressed: _aiHesaplamaBaslat,
                    icon: const Icon(Icons.psychology, size: 28),
                    label: const Text("AI MOTORU İLE HESAPLA", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1))
                )
            ),
            const SizedBox(height: 32),

            // 🛡️ 5. SONUÇ EKRANI (Başarı Hologramı)
            if (_sonucGoster)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                    color: panelColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: primaryCyan.withOpacity(0.5), width: 2),
                    boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.15), blurRadius: 30, spreadRadius: 5)]
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.check_circle, color: primaryCyan, size: 48),
                    ),
                    const SizedBox(height: 20),
                    const Text("TAHMİNİ DEĞER KAYBI", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    const SizedBox(height: 8),
                    const Text("₺42.500", style: TextStyle(color: primaryCyan, fontSize: 44, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    const SizedBox(height: 20),
                    const Text("Bu tutarı karşı tarafın sigortasından tahsil etmek için OtoDNA Hukuk Departmanı'na tek tuşla dosya açabilirsiniz.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5)),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                              side: BorderSide(color: primaryCyan.withOpacity(0.5), width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              foregroundColor: primaryCyan
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Dosya Siber Avukata İletildi! ⚖️"), backgroundColor: primaryCyan));
                          },
                          icon: const Icon(Icons.send),
                          label: const Text("AVUKATA DOSYA GÖNDER", style: TextStyle(fontWeight: FontWeight.bold))
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // 🎛️ DİJİTAL KALE VERİ GİRİŞ ALANI WIDGET'I
  Widget _buildSiberGirisAlani(String baslik, String hint, IconData ikon, Color panelColor, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
                decoration: BoxDecoration(
                    color: panelColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12)
                ),
                child: TextField(
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                        prefixIcon: Icon(ikon, color: accentColor.withOpacity(0.7), size: 20),
                        hintText: hint,
                        hintStyle: const TextStyle(color: Colors.white24, fontWeight: FontWeight.normal),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16)
                    )
                )
            ),
          ]
      ),
    );
  }
}