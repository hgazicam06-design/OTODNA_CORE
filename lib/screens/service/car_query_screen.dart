import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

// 🔥 SİBER KÖPRÜLER
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

class CarQueryScreen extends StatefulWidget {
  const CarQueryScreen({super.key});

  @override
  State<CarQueryScreen> createState() => _CarQueryScreenState();
}

class _CarQueryScreenState extends State<CarQueryScreen> {
  final TextEditingController _plateController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🏢 FİLDİŞİ SEDEF PALET
  final Color bgColor = const Color(0xFFFDFBF7);
  final Color surfaceColor = Colors.white;
  final Color primaryTeal = Colors.teal.shade700;
  final Color textMain = const Color(0xFF1E293B);
  final Color textMuted = const Color(0xFF64748B);
  final Color dangerColor = SiberTema.kanKirmizi;

  bool _isLoading = false;
  bool _isSearched = false;
  Map<String, dynamic>? _aracData;

  // 💎 KUANTUM AĞI SORGULAMA MOTORU
  Future<void> _searchCar() async {
    String plaka = _plateController.text.trim().toUpperCase().replaceAll(' ', '');

    if (plaka.isEmpty) {
      _siberUyari("Geçersiz Plaka! Hedef girilmedi.", isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _isSearched = true;
      _aracData = null;
    });

    FocusScope.of(context).unfocus(); // Klavyeyi kapat
    HapticFeedback.mediumImpact(); // Titreşim

    try {
      // Firebase'den Plakayı Tara (Büyük harf ve boşluksuz formatta aranır)
      var snapshot = await _db.collection('araclar').where('plaka', isEqualTo: plaka).limit(1).get();

      // Gerçekçilik katmak için 1 saniyelik siber tarama efekti
      await Future.delayed(const Duration(milliseconds: 1000));

      if (snapshot.docs.isNotEmpty) {
        setState(() => _aracData = snapshot.docs.first.data());
        HapticFeedback.heavyImpact(); // Hedef Bulundu Titreşimi
      }
    } catch (e) {
      _siberUyari("Ağ Hatası: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _siberUyari(String mesaj, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: const TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
      backgroundColor: isError ? dangerColor : primaryTeal,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent, elevation: 0,
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: primaryTeal, size: 20), onPressed: () => context.pop()),
          title: Text('İ S T İ H B A R A T   A Ğ I', style: TextStyle(color: textMain, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 3, fontFamily: 'Avenir')),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // 1. SİBER PLAKA GİRİŞ TERMİNALİ
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                    boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.02), blurRadius: 40)]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("HEDEF PLAKA", style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _plateController,
                      textCapitalization: TextCapitalization.characters,
                      style: TextStyle(color: textMain, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir'),
                      decoration: InputDecoration(
                        hintText: "ÖRN: 06DNA06",
                        hintStyle: TextStyle(color: textMuted.withOpacity(0.3), fontSize: 24, letterSpacing: 2, fontFamily: 'Avenir'),
                        prefixIcon: Icon(Icons.radar, color: primaryTeal, size: 28),
                        filled: true,
                        fillColor: bgColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: primaryTeal.withOpacity(0.5), width: 2)),
                      ),
                      onSubmitted: (_) => _searchCar(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity, height: 56,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryTeal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0
                        ),
                        onPressed: _isLoading ? null : _searchCar,
                        icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.search, size: 20, color: Colors.white),
                        label: Text(_isLoading ? "AĞ TARANIYOR..." : "SİSTEMDE SORGULA", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 2. SONUÇ EKRANI (KUANTUM RAPOR)
              Expanded(
                child: _buildSonucEkrani(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSonucEkrani() {
    if (!_isSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.policy_outlined, color: textMuted.withOpacity(0.2), size: 80),
            const SizedBox(height: 16),
            Text("Siber Ağa Bağlı.\nHedef plaka bekleniyor.", textAlign: TextAlign.center, style: TextStyle(color: textMuted, fontSize: 12, fontWeight: FontWeight.bold, height: 1.5, fontFamily: 'Avenir')),
          ],
        ),
      );
    }

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryTeal),
            const SizedBox(height: 24),
            Text("GENETİK VERİ TABANI TARANIYOR...", style: TextStyle(color: primaryTeal, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
          ],
        ),
      );
    }

    if (_aracData == null) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: dangerColor.withOpacity(0.05), borderRadius: BorderRadius.circular(24), border: Border.all(color: dangerColor.withOpacity(0.3))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: dangerColor, size: 48),
              const SizedBox(height: 16),
              Text("KAYIT BULUNAMADI", style: TextStyle(color: dangerColor, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
              const SizedBox(height: 8),
              Text("Bu plaka OtoDNA Siber Ağında mühürlenmemiş. Araç sisteme yabancı.", textAlign: TextAlign.center, style: TextStyle(color: textMuted, fontSize: 11, height: 1.5, fontFamily: 'Avenir')),
            ],
          ),
        ),
      );
    }

    // --- EĞER ARAÇ BULUNDUYSA KUANTUM RAPORU HAZIRLA ---
    String marka = _aracData!['marka'] ?? 'Bilinmeyen';
    String model = _aracData!['model'] ?? '';
    int km = _aracData!['km'] ?? 0;
    bool isKaraListe = _aracData!['is_kara_liste'] ?? false;

    // Siber Analiz: Triger ve Yağ Kontrolü (Simülasyon)
    bool trigerRiskli = km > 60000 && (_aracData!['triger_degisimi_km'] == null || (km - (_aracData!['triger_degisimi_km'] as int)) > 60000);
    bool yagRiskli = _aracData!['son_yag_bakimi_km'] == null || (km - (_aracData!['son_yag_bakimi_km'] as int)) > 10000;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("SİBER İSTİHBARAT SONUCU", style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
          const SizedBox(height: 16),

          // ARAÇ KÜNYESİ
          Container(
            width: double.infinity, padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05)), boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.02), blurRadius: 10)]),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle, border: Border.all(color: primaryTeal.withOpacity(0.3))), child: Icon(Icons.directions_car_outlined, color: primaryTeal, size: 32)),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("$marka $model".toUpperCase(), style: TextStyle(color: textMain, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Avenir')),
                      const SizedBox(height: 4),
                      Text("GÜNCEL KM: $km KM", style: TextStyle(color: primaryTeal, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),

          // KARA LİSTE KONTROLÜ
          if (isKaraListe)
            Container(
              margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: dangerColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: dangerColor.withOpacity(0.5))),
              child: Row(
                children: [
                  Icon(Icons.gpp_bad_outlined, color: dangerColor, size: 28),
                  const SizedBox(width: 16),
                  Expanded(child: Text("DİKKAT! BU ARAÇ KARA LİSTEDE. DOLANDIRICILIK VEYA AĞIR HASAR RİSKİ YÜKSEK.", style: TextStyle(color: dangerColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, height: 1.5, fontFamily: 'Avenir'))),
                ],
              ),
            ),

          // KRİTİK BAKIM ANALİZLERİ
          Row(
            children: [
              Expanded(child: _buildAnalizKarti(Icons.build_circle_outlined, "TRİGER\nDURUMU", trigerRiskli ? "RİSKLİ" : "NORMAL", trigerRiskli ? Colors.orange.shade700 : primaryTeal)),
              const SizedBox(width: 12),
              Expanded(child: _buildAnalizKarti(Icons.oil_barrel_outlined, "YAĞ\nBAKIMI", yagRiskli ? "SÜRESİ DOLMUŞ" : "GÜNCEL", yagRiskli ? dangerColor : primaryTeal)),
            ],
          ),
          const SizedBox(height: 32),

          // AKSİYON BUTONU
          SizedBox(
            width: double.infinity, height: 56,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(side: BorderSide(color: primaryTeal.withOpacity(0.5)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              onPressed: () => _siberUyari("Ekspertiz Paneli Başlatılıyor... 🛡️", isError: false),
              icon: Icon(Icons.science_outlined, color: primaryTeal, size: 20),
              label: Text("YENİ EKSPERTİZ BAŞLAT", style: TextStyle(color: primaryTeal, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1, fontFamily: 'Avenir')),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAnalizKarti(IconData ikon, String baslik, String durum, Color renk) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: renk.withOpacity(0.3)), boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.02), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: renk.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(ikon, color: renk, size: 24),
          ),
          const SizedBox(height: 16),
          Text(baslik, style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, height: 1.4, fontFamily: 'Avenir')),
          const SizedBox(height: 8),
          Text(durum, style: TextStyle(color: renk, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.5, fontFamily: 'Avenir')),
        ],
      ),
    );
  }
}