import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';
import '../../services/siber_adli_motor.dart';
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
      _uyariGoster("SİBER İHLAL", "Şase ve Parça/Tedarikçi Kodu zorunludur.", Colors.orangeAccent);
      return;
    }

    if (!_fotoYuklendi || !_videoYuklendi || !_sensorVerisiVar) {
      _uyariGoster("EKSİK KANIT", "Montaj öncesi foto, montaj anı video ve test verisi (ısı/basınç) olmadan Adli Rapor üretilemez.", SiberTema.kanKirmizi);
      return;
    }

    setState(() => _islemSuruyor = true);

    try {
      String davaTuru = _tabController.index == 0 ? "Kusur Hakemliği" : "Değer Kaybı Davası";
      
      AdliRaporModel rapor = await SiberAdliMotor.aiAnaliziYap(
        aracSaseNo: _saseCtrl.text.trim(),
        ustaUid: widget.ustaUid,
        tedarikciKodu: _parcaKoduCtrl.text.trim(),
        davaTuru: davaTuru,
        fotolar: ["kanit_foto_1.jpg"], // Mock
        videolar: ["kanit_video_1.mp4"], // Mock
        testVerileri: ["tork_analizi.json"], // Mock
      );

      // Veritabanına şifrele
      await SiberAdliMotor.raporuMasaustuneKilitle(rapor);

      setState(() {
        _uretilenRapor = rapor;
      });

      HapticFeedback.vibrate();

    } catch (e) {
      _uyariGoster("AĞ ÇÖKTÜ", "AI Motoruna ulaşılamadı.", SiberTema.kanKirmizi);
    } finally {
      setState(() => _islemSuruyor = false);
    }
  }

  void _uyariGoster(String baslik, String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SiberTema.matGrey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: renk, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
            Text(mesaj, style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Avenir')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent, // Arka plan ResponsiveKalkan'dan gelir
        appBar: AppBar(
          title: const Text("⚖️ SİBER MAHKEME", style: TextStyle(color: SiberTema.kanKirmizi, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
          backgroundColor: Colors.black.withOpacity(0.8),
          elevation: 0,
          iconTheme: const IconThemeData(color: SiberTema.kanKirmizi),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: SiberTema.kanKirmizi,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
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
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        // Siber Mahkeme Uyarı Kalkanı
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SiberTema.kanKirmizi.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SiberTema.kanKirmizi.withOpacity(0.3), width: 1.5),
          ),
          child: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: SiberTema.kanKirmizi, size: 30),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "DİKKAT: Sisteme yükleyeceğiniz dijital kanıtlar (foto, video, sensör verisi) Mahkemede delil olarak kullanılacaktır. Asılsız beyan Usta DNA puanını sıfırlar.",
                  style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.5, fontFamily: 'Avenir'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Araç ve Parça Kimliği
        TextField(
          controller: _saseCtrl,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            labelText: "Aracın Şase Numarası",
            labelStyle: const TextStyle(color: SiberTema.kuantumCyan),
            prefixIcon: const Icon(Icons.directions_car, color: SiberTema.kuantumCyan),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white24)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: SiberTema.kuantumCyan)),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _parcaKoduCtrl,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            labelText: "Takılan Parça QR/Barkod Kodu (Örn: ORG-123 veya YAN-456)",
            labelStyle: const TextStyle(color: SiberTema.kuantumCyan),
            prefixIcon: const Icon(Icons.qr_code_scanner, color: SiberTema.kuantumCyan),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white24)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: SiberTema.kuantumCyan)),
          ),
        ),
        const SizedBox(height: 30),

        // Kanıt Yükleme Paneli
        const Text("DİJİTAL DELİL (KANIT) DOSYALARI", style: TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text("Montaj Öncesi ve Sonrası Fotoğraflar Yüklendi", style: TextStyle(color: Colors.white, fontSize: 12)),
          value: _fotoYuklendi,
          activeColor: SiberTema.kuantumCyan,
          onChanged: (v) => setState(() => _fotoYuklendi = v),
        ),
        SwitchListTile(
          title: const Text("Montaj Anı (Torklama vb.) Video Yüklendi", style: TextStyle(color: Colors.white, fontSize: 12)),
          value: _videoYuklendi,
          activeColor: SiberTema.kuantumCyan,
          onChanged: (v) => setState(() => _videoYuklendi = v),
        ),
        SwitchListTile(
          title: const Text("ECU Isı ve Basınç Sensör Verisi Okundu", style: TextStyle(color: Colors.white, fontSize: 12)),
          value: _sensorVerisiVar,
          activeColor: SiberTema.kuantumCyan,
          onChanged: (v) => setState(() => _sensorVerisiVar = v),
        ),
        const SizedBox(height: 30),

        // Yasal Uyarı Zırhı
        Container(
          decoration: BoxDecoration(
            color: SiberTema.matGrey,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _yasalUyariKabul ? SiberTema.kuantumCyan : SiberTema.kanKirmizi),
          ),
          child: CheckboxListTile(
            title: Text(AdliRaporModel.yasalUyariMetni, style: TextStyle(color: _yasalUyariKabul ? Colors.white : Colors.white54, fontSize: 10, height: 1.5, fontFamily: 'Avenir')),
            value: _yasalUyariKabul,
            activeColor: SiberTema.kuantumCyan,
            checkColor: Colors.black,
            onChanged: (v) => setState(() => _yasalUyariKabul = v!),
          ),
        ),
        const SizedBox(height: 30),

        // Mühürleme Butonu
        SizedBox(
          height: 60,
          child: _islemSuruyor
              ? const Center(child: CircularProgressIndicator(color: SiberTema.kanKirmizi))
              : ElevatedButton.icon(
                  onPressed: _yasalUyariKabul ? _adliRaporUret : null,
                  icon: const Icon(Icons.precision_manufacturing, color: Colors.black),
                  label: const Text("SİBER BİLİRKİŞİ RAPORU ÜRET", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _yasalUyariKabul ? SiberTema.kanKirmizi : Colors.white10,
                    foregroundColor: Colors.black,
                  ),
                ),
        )
      ],
    );
  }

  // ── 📄 HÜKÜM EKRANI (AI RAPORU SONUCU) ──
  Widget _buildRaporGorunumu() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Icon(
              _uretilenRapor!.kusurOraniUsta == 0 ? Icons.verified_user : Icons.dangerous,
              color: _uretilenRapor!.kusurOraniUsta == 0 ? SiberTema.kuantumCyan : SiberTema.kanKirmizi,
              size: 80,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              _uretilenRapor!.kusurOraniUsta == 0 ? "USTA KUSURSUZ (AKLANDI)" : "USTA KUSURLU",
              style: TextStyle(
                color: _uretilenRapor!.kusurOraniUsta == 0 ? SiberTema.kuantumCyan : SiberTema.kanKirmizi,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                fontFamily: 'Avenir'
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Kusur Oranları
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildKusurCemberi("Usta", _uretilenRapor!.kusurOraniUsta, SiberTema.kanKirmizi),
              _buildKusurCemberi("Parça", _uretilenRapor!.kusurOraniParca, Colors.orange),
              _buildKusurCemberi("Kullanıcı", _uretilenRapor!.kusurOraniKullanici, SiberTema.kuantumCyan),
            ],
          ),
          const SizedBox(height: 30),

          // AI Gerekçesi
          const Text("SİBER BİLİRKİŞİ (AI) GEREKÇELİ KARARI", style: TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              _uretilenRapor!.aiHukmu,
              style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.6, fontFamily: 'Avenir'),
            ),
          ),
          const SizedBox(height: 30),
          
          // PDF İndirme Butonu (Mock)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {
                _uyariGoster("PDF OLUŞTURULDU", "Rapor cihazınıza mahkeme formatında kaydedildi.", SiberTema.kuantumCyan);
              },
              icon: const Icon(Icons.picture_as_pdf, color: SiberTema.kuantumCyan),
              label: const Text("ADLİ DOSYAYI (PDF) İNDİR", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.bold, letterSpacing: 1)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: SiberTema.kuantumCyan),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => setState(() => _uretilenRapor = null),
              child: const Text("YENİ İNCELEME BAŞLAT", style: TextStyle(color: Colors.white54)),
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
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: oran / 100,
                color: renk,
                backgroundColor: Colors.white10,
                strokeWidth: 6,
              ),
            ),
            Text("%$oran", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 8),
        Text(baslik, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
