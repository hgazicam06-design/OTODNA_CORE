import 'package:flutter/material.dart';

class TuvturkRandevuScreen extends StatefulWidget {
  const TuvturkRandevuScreen({super.key});

  @override
  State<TuvturkRandevuScreen> createState() => _TuvturkRandevuScreenState();
}

class _TuvturkRandevuScreenState extends State<TuvturkRandevuScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 1. RANDEVU VERİTABANI (Simülasyon)
  final String _seciliArac = "34 DNA 2026 • Tesla Model Y";
  final String _seciliSehir = "Ankara";
  final String _seciliIstasyon = "İvedik TÜVTÜRK (8.2 km)";
  final String _seciliTarih = "18 Mart 2026 • Çarşamba";
  final String _seciliSaat = "14:30";

  // BORÇ/SİGORTA KONTROL SİSTEMİ
  final Map<String, bool> _onKontrolListesi = {
    "Trafik Cezası Borcu": true,
    "Motorlu Taşıtlar Vergisi (MTV)": true,
    "HGS/OGS Kaçak Geçiş": false, // false = Borç var! (Uyarı verecek)
    "Zorunlu Trafik Sigortası": true,
  };

  // 3. PLAKA BASIM VERİTABANI
  final String _plakaTipi = "Standart Dikdörtgen (52x11)";
  final String _basimNedeni = "Noter Yeni Tescil / Alım";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 💎 AI DESTEKLİ RANDEVU ONAYLAMA MOTORU
  void _randevuOnayla() {
    if (_onKontrolListesi.containsValue(false)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("AĞ UYARISI: Ödenmemiş borcunuz (HGS) bulunmaktadır! İşlem bloke edildi.", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 4)
      ));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF00FFC2).withOpacity(0.5))),
        contentPadding: const EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF00FFC2), width: 2), boxShadow: [BoxShadow(color: const Color(0xFF00FFC2).withOpacity(0.2), blurRadius: 20)]),
              child: const Icon(Icons.verified_outlined, color: Color(0xFF00FFC2), size: 48),
            ),
            const SizedBox(height: 24),
            const Text("RANDEVU ONAYLANDI", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
            const SizedBox(height: 12),
            Text("$_seciliArac plakalı aracınız için $_seciliTarih saat $_seciliSaat konumuna randevunuz Kuantum Ağı üzerinden TÜVTÜRK'e şifrelenerek iletilmiştir.", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 12, height: 1.5)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FFC2), foregroundColor: Colors.black, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () => Navigator.pop(context),
                child: const Text("ANLAŞILDI", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
    const primaryCyan = Color(0xFF00FFC2);
    const bgColor = Color(0xFF000000);
    const surfaceColor = Color(0xFF111111);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text("R E S M İ   İ Ş L E M L E R", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 3)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 💎 MİNİMALİST SEKMELER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              height: 48,
              decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.white38,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5),
                tabs: const [Tab(text: "Muayene"), Tab(text: "Emisyon"), Tab(text: "Plaka")],
              ),
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(),
              children: [
                // ==========================================
                // 1. SEKME: TÜVTÜRK MUAYENE RANDEVUSU
                // ==========================================
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("ARAÇ & İSTASYON", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
                        child: Column(
                          children: [
                            _buildAyarSatiri(Icons.directions_car_outlined, "Hedef Araç", _seciliArac, true),
                            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.white12)),
                            _buildAyarSatiri(Icons.map_outlined, "Lokasyon", _seciliSehir, true),
                            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.white12)),
                            _buildAyarSatiri(Icons.location_on_outlined, "İstasyon", _seciliIstasyon, true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      const Text("ZAMAN ÇİZELGESİ", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.calendar_month_outlined, color: primaryCyan, size: 20), const SizedBox(height: 12), const Text("TARİH", style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)), const SizedBox(height: 4), Text(_seciliTarih.split("•")[0].trim(), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900))]))),
                          const SizedBox(width: 12),
                          Expanded(child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.access_time_outlined, color: primaryCyan, size: 20), const SizedBox(height: 12), const Text("SAAT", style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)), const SizedBox(height: 4), Text(_seciliSaat, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900))]))),
                        ],
                      ),
                      const SizedBox(height: 32),

                      const Text("AI ÖN KONTROL PROTOKOLÜ", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Veriler Kuantum Ağı üzerinden çekildi. Kırmızı uyarılar muayeneye kesin engeldir.", style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.5)),
                            const SizedBox(height: 24),
                            ..._onKontrolListesi.entries.map((entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                children: [
                                  Icon(entry.value ? Icons.check_circle_outline : Icons.cancel_outlined, color: entry.value ? Colors.greenAccent : Colors.redAccent, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(entry.key, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, decoration: entry.value ? TextDecoration.none : TextDecoration.underline, decorationColor: Colors.redAccent))),
                                  if (!entry.value)
                                    GestureDetector(
                                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Siber Cüzdan Ödeme Ekranı Açılıyor...", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: primaryCyan)),
                                        child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.redAccent.withOpacity(0.5))), child: const Text("ÖDE", style: TextStyle(color: Colors.redAccent, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)))
                                    )
                                ],
                              ),
                            ))
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      SizedBox(
                        width: double.infinity, height: 60,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: primaryCyan, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                          onPressed: _randevuOnayla,
                          icon: const Icon(Icons.send_outlined, size: 20),
                          label: const Text("SİSTEME İLET", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),

                // ==========================================
                // 2. SEKME: EGZOZ EMİSYON TESTİ
                // ==========================================
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity, padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(color: const Color(0xFF000000), borderRadius: BorderRadius.circular(32), border: Border.all(color: Colors.greenAccent.withOpacity(0.5), width: 1.5), boxShadow: [BoxShadow(color: Colors.greenAccent.withOpacity(0.05), blurRadius: 40, spreadRadius: 10)]),
                        child: const Column(
                          children: [
                            Icon(Icons.cloud_done_outlined, color: Colors.greenAccent, size: 48),
                            SizedBox(height: 16),
                            Text("GEÇERLİLİK TARİHİ", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                            SizedBox(height: 8),
                            Text("15 AĞU 2026", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1)),
                            SizedBox(height: 16),
                            Text("Emisyon ölçümü Kuantum Ağında günceldir.", textAlign: TextAlign.center, style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Text("YETKİLİ MERKEZLER", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                      const SizedBox(height: 16),
                      _buildEmisyonMerkeziKarti("Murat Plaza Servis", "3.2 km • Şaşmaz Oto Sanayi", "256 ₺", true),
                      const SizedBox(height: 16),
                      _buildEmisyonMerkeziKarti("Gazi Özel Otomotiv", "5.1 km • İvedik OSB", "256 ₺", false),
                    ],
                  ),
                ),

                // ==========================================
                // 3. SEKME: PLAKA BASIM ATÖLYESİ
                // ==========================================
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.orangeAccent.withOpacity(0.3))),
                        child: const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 28), SizedBox(width: 16),
                            Expanded(child: Text("Plaka basımı için Noter Tescil Belgesi zorunludur. Evraklar AI (Yapay Zeka) tarafından anında doğrulanır.", style: TextStyle(color: Colors.orangeAccent, fontSize: 11, height: 1.5))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      const Text("BASIM BİLGİLERİ", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
                        child: Column(
                          children: [
                            _buildAyarSatiri(Icons.gavel_outlined, "İşlem Nedeni", _basimNedeni, true),
                            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.white12)),
                            _buildAyarSatiri(Icons.aspect_ratio_outlined, "Plaka Formatı", _plakaTipi, true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      const Text("AI EVRAK DOĞRULAMA", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Siber Optik Okuyucu Açılıyor...", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: primaryCyan)),
                        child: Container(
                          width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 40),
                          decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: primaryCyan.withOpacity(0.3), style: BorderStyle.solid)),
                          child: Column(
                            children: [
                              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(shape: BoxShape.circle, color: primaryCyan.withOpacity(0.1)), child: const Icon(Icons.qr_code_scanner_outlined, color: primaryCyan, size: 32)),
                              const SizedBox(height: 20),
                              const Text("NOTER EVRAKINI OKUT", style: TextStyle(color: primaryCyan, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
                              const SizedBox(height: 8),
                              const Text("Yapay zeka şasiyi otomatik eşleştirir.", style: TextStyle(color: Colors.white38, fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      SizedBox(
                        width: double.infinity, height: 60,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Talep Şoförler Odası Sistemine İletildi! 🖨️", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: Colors.green)),
                          icon: const Icon(Icons.print_outlined, size: 20),
                          label: const Text("BASIM EMRİ VER", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 💎 YARDIMCI WIDGET: SİBER AYAR SATIRI
  Widget _buildAyarSatiri(IconData ikon, String baslik, String deger, bool yonOlsun) {
    return Row(
      children: [
        Icon(ikon, color: Colors.white54, size: 20), const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(baslik, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)), const SizedBox(height: 4),
              Text(deger, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        if (yonOlsun) const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
      ],
    );
  }

  // 💎 YARDIMCI WIDGET: EMİSYON KARTI
  Widget _buildEmisyonMerkeziKarti(String isim, String konum, String fiyat, bool tavsiye) {
    return Container(
      padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(20), border: Border.all(color: tavsiye ? const Color(0xFF00FFC2).withOpacity(0.5) : Colors.white.withOpacity(0.05))),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF000000), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))), child: Icon(Icons.storefront_outlined, color: tavsiye ? const Color(0xFF00FFC2) : Colors.white54, size: 20)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(isim, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: -0.5)),
                    if (tavsiye) ...[const SizedBox(width: 8), const Icon(Icons.verified, color: Color(0xFF00FFC2), size: 14)]
                  ],
                ),
                const SizedBox(height: 4),
                Text(konum, style: const TextStyle(color: Colors.white54, fontSize: 10)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(fiyat, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF00FFC2).withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF00FFC2).withOpacity(0.5))), child: const Text("SEÇ", style: TextStyle(color: Color(0xFF00FFC2), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1))),
            ],
          )
        ],
      ),
    );
  }
}