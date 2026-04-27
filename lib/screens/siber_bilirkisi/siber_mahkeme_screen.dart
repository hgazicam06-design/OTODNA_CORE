import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';
import '../../services/corporate_legal_engine.dart';
import '../../models/adli_rapor_model.dart';

/// ⚖️ SİBER MAHKEME EKRANI (OtoDNA Adli Savunma Paneli)
/// Ustanın onurunu ve firmanın itibarını koruyan "Dijital Delil" üretme terminali.
class SiberMahkemeScreen extends StatefulWidget {
  final String ustaUid;

  const SiberMahkemeScreen({super.key, required this.ustaUid});

  @override
  State<SiberMahkemeScreen> createState() => _SiberMahkemeScreenState();
}

class _SiberMahkemeScreenState extends State<SiberMahkemeScreen> with SingleTickerProviderStateMixin {
  // 🏢 FİLDİŞİ SEDEF PALET
  final Color bgColor = const Color(0xFFFDFBF7);
  final Color surfaceColor = Colors.white;
  final Color primaryTeal = Colors.teal.shade700;
  final Color textMain = const Color(0xFF1E293B);
  final Color textMuted = const Color(0xFF64748B);
  final Color dangerColor = SiberTema.kanKirmizi;

  late TabController _tabController;
  
  // Olay Yeri Form Kontrolleri
  final TextEditingController _saseCtrl = TextEditingController();
  final TextEditingController _parcaKoduCtrl = TextEditingController();

  // Dijital Kanıt Checkbox'ları (Demo amaçlı switch'ler)
  bool _fotoYuklendi = false;
  bool _videoYuklendi = false;
  bool _sensorVerisiVar = false;
  
  // Yasal Uyarı Zırhı
  bool _yasalUyariKabul = false;
  
  // State Yönetimi
  bool _islemSuruyor = false;
  AdliRaporModel? _uretilenRapor;

  @override
  void initState() {
    super.initState();
    // İki Ana Dava Türü: Kusur Hakemliği (Usta vs Fabrika) ve Değer Kaybı (Kaza)
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _saseCtrl.dispose();
    _parcaKoduCtrl.dispose();
    super.dispose();
  }

  // ── 🚀 YAPAY ZEKA RAPOR MOTORUNU TETİKLEME ──
  Future<void> _adliRaporUret() async {
    HapticFeedback.heavyImpact();

    if (_saseCtrl.text.isEmpty || _parcaKoduCtrl.text.isEmpty) {
      _uyariGoster("SİBER İHLAL", "Şase ve Parça/Tedarikçi Kodu zorunludur.", Colors.orange.shade700);
      return;
    }

    if (!_fotoYuklendi || !_videoYuklendi || !_sensorVerisiVar) {
      _uyariGoster("EKSİK KANIT", "Montaj öncesi foto, montaj anı video ve test verisi (ısı/basınç) olmadan Adli Rapor üretilemez.", dangerColor);
      return;
    }

    setState(() => _islemSuruyor = true);

    try {
      String davaTuru = _tabController.index == 0 ? "Kusur Hakemliği" : "Değer Kaybı Davası";
      
      AdliRaporModel rapor = await CorporateLegalEngine.aiAnaliziYap(
        aracSaseNo: _saseCtrl.text.trim(),
        ustaUid: widget.ustaUid,
        tedarikciKodu: _parcaKoduCtrl.text.trim(),
        davaTuru: davaTuru,
        fotolar: ["kanit_foto_1.jpg"], // Mock
        videolar: ["kanit_video_1.mp4"], // Mock
        testVerileri: ["tork_analizi.json"], // Mock
      );

      // Veritabanına şifrele
      await CorporateLegalEngine.raporuMasaustuneKilitle(rapor);

      setState(() {
        _uretilenRapor = rapor;
      });

      HapticFeedback.vibrate();

    } catch (e) {
      _uyariGoster("AĞ ÇÖKTÜ", "AI Motoruna ulaşılamadı.", dangerColor);
    } finally {
      setState(() => _islemSuruyor = false);
    }
  }

  void _uyariGoster(String baslik, String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: surfaceColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: renk.withOpacity(0.3), width: 1.5)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
            const SizedBox(height: 4),
            Text(mesaj, style: TextStyle(color: textMain, fontSize: 12, fontFamily: 'Avenir')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text("⚖️ SİBER MAHKEME", style: TextStyle(color: dangerColor, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: dangerColor, size: 20), onPressed: () => context.pop()),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: dangerColor,
            indicatorWeight: 3,
            labelColor: textMain,
            unselectedLabelColor: textMuted,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
            tabs: const [
              Tab(icon: Icon(Icons.gavel_rounded), text: "KUSUR HAKEMLİĞİ"),
              Tab(icon: Icon(Icons.car_crash_rounded), text: "DEĞER KAYBI"),
            ],
          ),
        ),
        body: _uretilenRapor != null ? _buildRaporGorunumu() : _buildKriminalForm(),
      ),
    );
  }

  // ── 📝 OLAY YERİ İNCELEME FORMU (GİRİŞ EKRANI) ──
  Widget _buildKriminalForm() {
    return ListView(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      children: [
        // Siber Mahkeme Uyarı Kalkanı
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: dangerColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: dangerColor.withOpacity(0.3), width: 1.5),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: dangerColor, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "DİKKAT: Sisteme yükleyeceğiniz dijital kanıtlar (foto, video, sensör verisi) Mahkemede delil olarak kullanılacaktır. Asılsız beyan Usta DNA puanını sıfırlar.",
                  style: TextStyle(color: dangerColor, fontSize: 11, height: 1.5, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Araç ve Parça Kimliği
        Container(
          decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05)), boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.02), blurRadius: 10)]),
          child: TextField(
            controller: _saseCtrl,
            style: TextStyle(color: textMain, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: "Aracın Şase Numarası",
              labelStyle: TextStyle(color: textMuted),
              prefixIcon: Icon(Icons.directions_car, color: primaryTeal),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05)), boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.02), blurRadius: 10)]),
          child: TextField(
            controller: _parcaKoduCtrl,
            style: TextStyle(color: textMain, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: "Takılan Parça QR/Barkod Kodu (Örn: ORG-123 veya YAN-456)",
              labelStyle: TextStyle(color: textMuted, fontSize: 12),
              prefixIcon: Icon(Icons.qr_code_scanner, color: primaryTeal),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Kanıt Yükleme Paneli
        Text("DİJİTAL DELİL (KANIT) DOSYALARI", style: TextStyle(color: textMuted, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
          child: Column(
            children: [
              SwitchListTile(
                title: Text("Montaj Öncesi ve Sonrası Fotoğraflar Yüklendi", style: TextStyle(color: textMain, fontSize: 12, fontWeight: FontWeight.bold)),
                value: _fotoYuklendi,
                activeColor: primaryTeal,
                onChanged: (v) => setState(() => _fotoYuklendi = v),
              ),
              Divider(color: Colors.white.withOpacity(0.05), height: 1),
              SwitchListTile(
                title: Text("Montaj Anı (Torklama vb.) Video Yüklendi", style: TextStyle(color: textMain, fontSize: 12, fontWeight: FontWeight.bold)),
                value: _videoYuklendi,
                activeColor: primaryTeal,
                onChanged: (v) => setState(() => _videoYuklendi = v),
              ),
              Divider(color: Colors.white.withOpacity(0.05), height: 1),
              SwitchListTile(
                title: Text("ECU Isı ve Basınç Sensör Verisi Okundu", style: TextStyle(color: textMain, fontSize: 12, fontWeight: FontWeight.bold)),
                value: _sensorVerisiVar,
                activeColor: primaryTeal,
                onChanged: (v) => setState(() => _sensorVerisiVar = v),
              ),
            ],
          )
        ),
        const SizedBox(height: 32),

        // Yasal Uyarı Zırhı
        Container(
          decoration: BoxDecoration(
            color: _yasalUyariKabul ? primaryTeal.withOpacity(0.05) : surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _yasalUyariKabul ? primaryTeal.withOpacity(0.5) : dangerColor.withOpacity(0.3)),
          ),
          child: CheckboxListTile(
            title: Text(AdliRaporModel.yasalUyariMetni, style: TextStyle(color: _yasalUyariKabul ? textMain : textMuted, fontSize: 10, height: 1.5, fontFamily: 'Avenir')),
            value: _yasalUyariKabul,
            activeColor: primaryTeal,
            checkColor: Colors.white,
            onChanged: (v) => setState(() => _yasalUyariKabul = v!),
          ),
        ),
        const SizedBox(height: 32),

        // Mühürleme Butonu
        SizedBox(
          height: 60,
          child: _islemSuruyor
              ? Center(child: CircularProgressIndicator(color: dangerColor))
              : ElevatedButton.icon(
                  onPressed: _yasalUyariKabul ? _adliRaporUret : null,
                  icon: const Icon(Icons.precision_manufacturing, color: Colors.white),
                  label: const Text("SİBER BİLİRKİŞİ RAPORU ÜRET", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _yasalUyariKabul ? dangerColor : Colors.black12,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0
                  ),
                ),
        )
      ],
    );
  }

  // ── 📄 HÜKÜM EKRANI (AI RAPORU SONUCU) ──
  Widget _buildRaporGorunumu() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _uretilenRapor!.kusurOraniUsta == 0 ? primaryTeal.withOpacity(0.1) : dangerColor.withOpacity(0.1),
                shape: BoxShape.circle
              ),
              child: Icon(
                _uretilenRapor!.kusurOraniUsta == 0 ? Icons.verified_user : Icons.dangerous,
                color: _uretilenRapor!.kusurOraniUsta == 0 ? primaryTeal : dangerColor,
                size: 60,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              _uretilenRapor!.kusurOraniUsta == 0 ? "USTA KUSURSUZ (AKLANDI)" : "USTA KUSURLU",
              style: TextStyle(
                color: _uretilenRapor!.kusurOraniUsta == 0 ? primaryTeal : dangerColor,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                fontFamily: 'Avenir'
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Kusur Oranları
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05)), boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.02), blurRadius: 20)]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildKusurCemberi("Usta", _uretilenRapor!.kusurOraniUsta, dangerColor),
                _buildKusurCemberi("Parça", _uretilenRapor!.kusurOraniParca, Colors.orange.shade700),
                _buildKusurCemberi("Kullanıcı", _uretilenRapor!.kusurOraniKullanici, primaryTeal),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // AI Gerekçesi
          Text("SİBER BİLİRKİŞİ (AI) GEREKÇELİ KARARI", style: TextStyle(color: textMuted, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
              boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.02), blurRadius: 10)]
            ),
            child: Text(
              _uretilenRapor!.aiHukmu,
              style: TextStyle(color: textMain, fontSize: 13, height: 1.6, fontWeight: FontWeight.w500, fontFamily: 'Avenir'),
            ),
          ),
          const SizedBox(height: 40),
          
          // PDF İndirme Butonu (Mock)
          SizedBox(
            width: double.infinity,
            height: 60,
            child: OutlinedButton.icon(
              onPressed: () {
                _uyariGoster("PDF OLUŞTURULDU", "Rapor cihazınıza mahkeme formatında kaydedildi.", primaryTeal);
              },
              icon: Icon(Icons.picture_as_pdf, color: primaryTeal),
              label: Text("ADLİ DOSYAYI (PDF) İNDİR", style: TextStyle(color: primaryTeal, fontWeight: FontWeight.w900, letterSpacing: 1)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primaryTeal.withOpacity(0.5), width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => setState(() => _uretilenRapor = null),
              child: Text("YENİ İNCELEME BAŞLAT", style: TextStyle(color: textMuted, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildKusurCemberi(String baslik, int oran, Color renk) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                value: oran / 100,
                color: renk,
                backgroundColor: renk.withOpacity(0.1),
                strokeWidth: 8,
              ),
            ),
            Text("%$oran", style: TextStyle(color: textMain, fontWeight: FontWeight.w900, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 12),
        Text(baslik, style: TextStyle(color: textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
