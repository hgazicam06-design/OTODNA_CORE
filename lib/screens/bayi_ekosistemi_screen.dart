import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// 🚀 KARARGAH ZIRHLARI VE MOTORLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';
import '../services/takip_radari.dart';

class BayiEkosistemiScreen extends StatefulWidget {
  const BayiEkosistemiScreen({super.key});

  @override
  State<BayiEkosistemiScreen> createState() => _BayiEkosistemiScreenState();
}

class _BayiEkosistemiScreenState extends State<BayiEkosistemiScreen> {
  final TakipRadari _takipRadari = TakipRadari();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _aracIdController = TextEditingController();

  bool _isProcessing = false;

  // Kontrol Edilecek Kritik Parçalar
  final List<String> _kritikParcalar = [
    "Fren Sistemi & Balatalar",
    "Şase & Direk Kontrolü",
    "Motor Bloğu & Yağ Kaçağı",
    "Otomatik Şanzıman Geçişleri",
    "Radyatör & Soğutma",
  ];

  // Parçaların anlık durumlarını tutar (null: Bekliyor, true: Sağlam, false: Riskli)
  final Map<String, bool?> _parcaDurumlari = {};
  final Map<String, String> _parcaKanitlari = {}; // Fotoğraf yolları

  @override
  void initState() {
    super.initState();
    for (var parca in _kritikParcalar) {
      _parcaDurumlari[parca] = null;
    }
  }

  @override
  void dispose() {
    _aracIdController.dispose();
    super.dispose();
  }

  // --- ✅ ZORUNLU FOTOĞRAFLI YEŞİL TIK (SAĞLAM) MÜHRÜ ---
  Future<void> _yesilTikAt(String parcaAdi) async {
    if (_aracIdController.text.trim().isEmpty) {
      _siberUyariVer("SİBER İHLAL: Önce işlem yapılacak Araç ID / Plaka giriniz!", isError: true);
      return;
    }

    // 📸 Siber Kural: Yeşil tık için fotoğraf ZORUNLUDUR!
    final XFile? foto = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);

    if (foto == null) {
      _siberUyariVer("SİBER RED: Geçerli kanıt (fotoğraf) sunulmadan Yeşil Tık atılamaz!", isError: true);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // DNA Skorunu Yükselt (+5)
      await _takipRadari.dnaSkoruHesapla(_aracIdController.text.trim(), false);

      // İleriye dönük Akıllı Ara-Muayene Planla (Örn: Fren için 12 ay sonra alarm kur)
      await _takipRadari.araMuayeneKur(_aracIdController.text.trim(), "GİRİLEN_PLAKA", parcaAdi, 12);

      setState(() {
        _parcaDurumlari[parcaAdi] = true;
        _parcaKanitlari[parcaAdi] = foto.path;
      });

      _siberUyariVer("$parcaAdi: MÜHÜRLENDİ! Dijital İmza ve Kanıt Ağa İşlendi.", isError: false);
    } catch (e) {
      _siberUyariVer("SİBER HATA: İşlem başarısız.", isError: true);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  // --- ❌ ACIMASIZ KIRMIZI X (RİSKLİ) MÜHRÜ ---
  Future<void> _kirmiziCarpiAt(String parcaAdi) async {
    if (_aracIdController.text.trim().isEmpty) {
      _siberUyariVer("SİBER İHLAL: Önce işlem yapılacak Araç ID / Plaka giriniz!", isError: true);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // DNA Skorunu Düşür (-15 Puan ve olası Karaliste)
      await _takipRadari.dnaSkoruHesapla(_aracIdController.text.trim(), true);

      setState(() {
        _parcaDurumlari[parcaAdi] = false;
      });

      _siberUyariVer("KRİTİK RİSK ($parcaAdi): DNA Skoru düşürüldü ve araç işaretlendi!", isError: true);
    } catch (e) {
      _siberUyariVer("SİBER HATA: İşlem başarısız.", isError: true);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _siberUyariVer(String mesaj, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: TextStyle(color: isError ? Colors.white : SiberTema.oledBlack, fontWeight: FontWeight.bold, fontFamily: 'Avenir', fontSize: 12)),
      backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: SiberTema.kuantumCyan), onPressed: () => Navigator.pop(context)),
          title: Text("DİJİTAL REFERANS (EKSPERTİZ)", style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2, fontFamily: 'Avenir')),
          centerTitle: true,
          bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: Colors.white.withOpacity(0.05), height: 1)),
        ),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/radar_grid.png'), fit: BoxFit.cover, opacity: 0.05)),
              child: Column(
                children: [
                  // ── 1. HEDEF ARAÇ BİLGİSİ GİRİŞİ ──
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SiberTema.siberCamKalkan(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: TextField(
                        controller: _aracIdController,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2, fontFamily: 'Avenir'),
                        decoration: InputDecoration(
                          labelText: "HEDEF ARAÇ ID / PLAKA",
                          labelStyle: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 12, letterSpacing: 1),
                          prefixIcon: const Icon(Icons.directions_car, color: SiberTema.kuantumCyan),
                          border: InputBorder.none,
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: SiberTema.kuantumCyan.withOpacity(0.5))),
                        ),
                      ),
                    ),
                  ),

                  // ── 2. DİJİTAL KONTROL LİSTESİ ──
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _kritikParcalar.length,
                      itemBuilder: (context, index) {
                        String parca = _kritikParcalar[index];
                        bool? durum = _parcaDurumlari[parca];

                        Color cerceveRengi = durum == null
                            ? Colors.white.withOpacity(0.1)
                            : (durum ? SiberTema.kuantumCyan : SiberTema.kanKirmizi);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [SiberTema.matGrey.withOpacity(0.8), SiberTema.oledBlack]),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: cerceveRengi, width: durum == null ? 1 : 2),
                            boxShadow: durum != null ? [BoxShadow(color: cerceveRengi.withOpacity(0.2), blurRadius: 10)] : [],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: Text(parca, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'Avenir'))),
                                    if (durum != null)
                                      Icon(durum ? Icons.verified : Icons.warning_amber_rounded, color: cerceveRengi, size: 24),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // ONAY / RED BUTONLARI
                                Row(
                                  children: [
                                    // KIRMIZI X BUTONU
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: _isProcessing ? null : () => _kirmiziCarpiAt(parca),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          decoration: BoxDecoration(color: SiberTema.kanKirmizi.withOpacity(durum == false ? 0.3 : 0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: SiberTema.kanKirmizi.withOpacity(0.5))),
                                          child: const Icon(Icons.close, color: SiberTema.kanKirmizi, size: 24),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // YEŞİL TIK VE KAMERA BUTONU
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: _isProcessing ? null : () => _yesilTikAt(parca),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(durum == true ? 0.3 : 0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5))),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.camera_alt, color: SiberTema.kuantumCyan, size: 18),
                                              const SizedBox(width: 8),
                                              const Icon(Icons.check, color: SiberTema.kuantumCyan, size: 24),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // FOTOĞRAF KANITI EKLENDİYSE GÖSTER
                                if (_parcaKanitlari.containsKey(parca)) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.image_search, color: SiberTema.kuantumCyan, size: 14),
                                      const SizedBox(width: 8),
                                      Text("Siber Kanıt Mühürlendi", style: TextStyle(color: SiberTema.kuantumCyan.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                                    ],
                                  )
                                ]
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // SİBER İŞLEM YÜKLENİYOR KALKANI
            if (_isProcessing)
              Container(
                color: SiberTema.oledBlack.withOpacity(0.8),
                child: const Center(
                  child: CircularProgressIndicator(color: SiberTema.kuantumCyan, strokeWidth: 3),
                ),
              ),
          ],
        ),
      ),
    );
  }
}