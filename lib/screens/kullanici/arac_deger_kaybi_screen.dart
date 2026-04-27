import 'package:flutter/material.dart';
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';
import '../../services/corporate_legal_engine.dart';

class AracDegerKaybiScreen extends StatefulWidget {
  const AracDegerKaybiScreen({super.key});

  @override
  State<AracDegerKaybiScreen> createState() => _AracDegerKaybiScreenState();
}

class _AracDegerKaybiScreenState extends State<AracDegerKaybiScreen> {
  bool _hesaplaniyor = false;
  bool _sonucGoster = false;
  double _hesaplananTutar = 0.0;
  
  final TextEditingController _smsController = TextEditingController();
  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _kusurController = TextEditingController();
  final TextEditingController _saseController = TextEditingController();

  final CorporateLegalEngine _hukukMotoru = CorporateLegalEngine();

  void _aiHesaplamaBaslat() async {
    if (_smsController.text.isEmpty || _kmController.text.isEmpty || _kusurController.text.isEmpty || _saseController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen SMS Metnini, Şase No, KM ve Kusur Oranını giriniz."), backgroundColor: Colors.redAccent));
      return;
    }

    setState(() { _hesaplaniyor = true; _sonucGoster = false; });
    
    int km = int.tryParse(_kmController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    int kusur = int.tryParse(_kusurController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    final sonuc = await _hukukMotoru.tramerAnaliziYap(
      smsMetni: _smsController.text,
      saseNo: _saseController.text,
      kilometre: km,
      kusurOrani: kusur,
    );

    if (!mounted) return;
    setState(() => _hesaplaniyor = false);

    if (sonuc['basarili'] == false) {
      // Pert engeli veya diğer hatalar
      bool isPert = sonuc['pertMi'] ?? false;
      _hataGoster(sonuc['mesaj'], isPert);
    } else {
      // Başarılı Hesaplama
      setState(() {
        _hesaplananTutar = sonuc['tahminiTutar'];
        _sonucGoster = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Kaza Analizi: ${sonuc['kazaSayisi']} Hasar Bulundu. Hesaplama Tamamlandı! 🧠"), backgroundColor: SiberTema.kuantumCyan, duration: const Duration(seconds: 4)));
    }
  }

  void _hataGoster(String mesaj, bool isPert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SiberTema.oledBlack,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: isPert ? SiberTema.kanKirmizi : Colors.orangeAccent)),
        title: Row(
          children: [
            Icon(isPert ? Icons.cancel : Icons.warning, color: isPert ? SiberTema.kanKirmizi : Colors.orangeAccent, size: 32),
            const SizedBox(width: 12),
            const Text("HUKUK MOTORU UYARISI", style: TextStyle(color: SiberTema.textMain, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(mesaj, style: const TextStyle(color: SiberTema.textMuted, fontSize: 12)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ANLADIM", style: TextStyle(color: SiberTema.textMuted)))
        ],
      )
    );
  }

  void _avukataGonder() async {
    bool basarili = await _hukukMotoru.avukataDosyaAc(_saseController.text, _hesaplananTutar, _smsController.text);
    if (!mounted) return;
    
    if (basarili) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Dosyanız Kuantum Hukuk Ağına İletildi! Avukatlarımız sizinle iletişime geçecektir. ⚖️"), backgroundColor: SiberTema.kuantumCyan));
      setState(() => _sonucGoster = false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ağ Hatası. Dosya gönderilemedi."), backgroundColor: Colors.redAccent));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.8),
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20), onPressed: () => Navigator.pop(context)),
          title: const Text("YAPAY ZEKA DEĞER KAYBI", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2)),
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
                  color: SiberTema.kuantumCyan.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.account_balance, color: SiberTema.kuantumCyan, size: 20),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Siber Hukuk Ağı: Senkronize", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, fontSize: 13)),
                          SizedBox(height: 4),
                          Text("Yargıtay emsalleri ile eşzamanlı TRAMER okuması yapılıyor.", style: TextStyle(color: SiberTema.textMuted, fontSize: 11)),
                        ],
                      ),
                    ),
                    const Icon(Icons.wifi_tethering, color: SiberTema.kuantumCyan, size: 18),
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
                            Text("Kazaya karışan aracınızın piyasa değer kaybını Kuantum AI motoru ile saniyeler içinde hesaplayın.", style: TextStyle(color: SiberTema.textMuted, fontSize: 11, height: 1.4))
                          ]
                      )
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 🛠️ 3. FORM ALANI (Glassmorphism Cam Efekti)
            const Text("KAZA VE HASAR DETAYLARI", style: TextStyle(color: SiberTema.textMuted, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
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
                        child: CircularProgressIndicator(color: SiberTema.kuantumCyan, strokeWidth: 3),
                      ),
                      const SizedBox(height: 16),
                      Text("Siber Hukuk Ağı Tramer Mesajını Analiz Ediyor...", style: TextStyle(color: SiberTema.kuantumCyan.withOpacity(0.8), fontWeight: FontWeight.bold, letterSpacing: 1))
                    ]
                )
            )
                : SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                    style: SiberTema.kuantumButonStili(),
                    onPressed: _aiHesaplamaBaslat,
                    icon: const Icon(Icons.psychology, size: 28, color: Colors.white),
                    label: const Text("SMS'İ OKU VE HESAPLA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1))
                )
            ),
            const SizedBox(height: 32),

            // 🛡️ 5. SONUÇ EKRANI (Başarı Hologramı)
            if (_sonucGoster)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                    color: SiberTema.matGrey,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5), width: 2),
                    boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.15), blurRadius: 30, spreadRadius: 5)]
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.check_circle, color: SiberTema.kuantumCyan, size: 48),
                    ),
                    const SizedBox(height: 20),
                    const Text("TAHMİNİ DEĞER KAYBI", style: TextStyle(color: SiberTema.textMuted, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    const SizedBox(height: 8),
                    Text("₺${_hesaplananTutar.toStringAsFixed(0)}", style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 44, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    const SizedBox(height: 20),
                    const Text("Bu tutarı karşı tarafın sigortasından tahsil etmek için OtoDNA Hukuk Departmanı'na tek tuşla dosya açabilirsiniz.", textAlign: TextAlign.center, style: TextStyle(color: SiberTema.textMuted, fontSize: 12, height: 1.5)),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                              side: BorderSide(color: SiberTema.kuantumCyan.withOpacity(0.5), width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              foregroundColor: SiberTema.kuantumCyan
                          ),
                          onPressed: _avukataGonder,
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
  Widget _buildSiberGirisAlani(String baslik, String hint, IconData ikon, TextEditingController controller, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: const TextStyle(color: SiberTema.textMain, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
                decoration: BoxDecoration(
                    color: SiberTema.matGrey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SiberTema.textMuted)
                ),
                child: TextField(
                    controller: controller,
                    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
                    style: const TextStyle(color: SiberTema.textMain, fontSize: 13, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                        prefixIcon: Icon(ikon, color: SiberTema.kuantumCyan.withOpacity(0.5), size: 18),
                        hintText: hint,
                        hintStyle: const TextStyle(color: SiberTema.textMuted, fontSize: 11),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14)
                    )
                )
            ),
          ]
      ),
    );
  }
}