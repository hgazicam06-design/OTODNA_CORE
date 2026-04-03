import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class CarQueryScreen extends StatefulWidget {
  const CarQueryScreen({super.key});

  @override
  State<CarQueryScreen> createState() => _CarQueryScreenState();
}

class _CarQueryScreenState extends State<CarQueryScreen> {
  final TextEditingController _plateController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  final Color bgColor = const Color(0xFF000000);
  final Color surfaceColor = const Color(0xFF111111);
  final Color primaryCyan = const Color(0xFF00FFC2);

  bool _isLoading = false;
  bool _isSearched = false;
  Map<String, dynamic>? _aracData;

  // 💎 KUANTUM AĞI SORGULAMA MOTORU
  Future<void> _searchCar() async {
    String plaka = _plateController.text.trim().toUpperCase().replaceAll(' ', '');

    if (plaka.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Geçersiz Plaka! Hedef girilmedi.", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: Colors.redAccent));
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ağ Hatası: $e", style: const TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('İ S T İ H B A R A T   A Ğ I', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 3)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            // =================================================================
            // 1. SİBER PLAKA GİRİŞ TERMİNALİ
            // =================================================================
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("HEDEF PLAKA", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _plateController,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2),
                    decoration: InputDecoration(
                      hintText: "ÖRN: 06DNA06",
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.1), fontSize: 24, letterSpacing: 2),
                      prefixIcon: const Icon(Icons.radar, color: primaryCyan, size: 28),
                      filled: true,
                      fillColor: bgColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primaryCyan, width: 2)),
                    ),
                    onSubmitted: (_) => _searchCar(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity, height: 56,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryCyan, foregroundColor: Colors.black, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _isLoading ? null : _searchCar,
                      icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)) : const Icon(Icons.search, size: 20),
                      label: Text(_isLoading ? "AĞ TARANIYOR..." : "SİSTEMDE SORGULA", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),

            // =================================================================
            // 2. SONUÇ EKRANI (KUANTUM RAPOR)
            // =================================================================
            Expanded(
              child: _buildSonucEkrani(),
            ),
          ],
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
            Icon(Icons.policy_outlined, color: Colors.white.withOpacity(0.05), size: 80),
            const SizedBox(height: 16),
            const Text("Siber Ağa Bağlı.\nHedef plaka bekleniyor.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold, height: 1.5)),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryCyan),
            SizedBox(height: 24),
            Text("GENETİK VERİ TABANI TARANIYOR...", style: TextStyle(color: primaryCyan, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
          ],
        ),
      );
    }

    if (_aracData == null) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.05), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.redAccent.withOpacity(0.3))),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              SizedBox(height: 16),
              Text("KAYIT BULUNAMADI", style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
              SizedBox(height: 8),
              Text("Bu plaka OtoDNA Siber Ağında mühürlenmemiş. Araç sisteme yabancı.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.5)),
            ],
          ),
        ),
      );
    }

    // --- EĞER ARAÇ BULUNDUYSA KUANTUM RAPORU HAZIRLA ---
    String marka = _aracData!['marka'] ?? 'Bilinmiyor';
    String model = _aracData!['model'] ?? '';
    int km = _aracData!['km'] ?? 0;
    bool isKaraListe = _aracData!['is_kara_liste'] ?? false; // Kara liste kontrolü

    // Siber Analiz: Triger ve Yağ Kontrolü (Basit Simülasyon / Gerçek veriye bağlanabilir)
    bool trigerRiskli = km > 60000 && (_aracData!['triger_degisimi_km'] == null || (km - (_aracData!['triger_degisimi_km'] as int)) > 60000);
    bool yagRiskli = _aracData!['son_yag_bakimi_km'] == null || (km - (_aracData!['son_yag_bakimi_km'] as int)) > 10000;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("SİBER İSTİHBARAT SONUCU", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 16),

          // ARAÇ KÜNYESİ
          Container(
            width: double.infinity, padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle, border: Border.all(color: primaryCyan.withOpacity(0.3))), child: const Icon(Icons.directions_car_outlined, color: primaryCyan, size: 32)),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("$marka $model".toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                      const SizedBox(height: 4),
                      Text("Güncel Kilometre: $km KM", style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
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
              decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.redAccent.withOpacity(0.5))),
              child: const Row(
                children: [
                  Icon(Icons.gpp_bad_outlined, color: Colors.redAccent, size: 28),
                  SizedBox(width: 16),
                  Expanded(child: Text("DİKKAT! BU ARAÇ KARA LİSTEDE. DOLANDIRICILIK VEYA AĞIR HASAR RİSKİ YÜKSEK.", style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, height: 1.5))),
                ],
              ),
            ),

          // KRİTİK BAKIM ANALİZLERİ
          Row(
            children: [
              Expanded(child: _buildAnalizKarti(Icons.build_circle_outlined, "TRİGER\nDURUMU", trigerRiskli ? "RİSKLİ" : "NORMAL", trigerRiskli ? Colors.orangeAccent : primaryCyan)),
              const SizedBox(width: 12),
              Expanded(child: _buildAnalizKarti(Icons.oil_barrel_outlined, "YAĞ\nBAKIMI", yagRiskli ? "SÜRESİ DOLMUŞ" : "GÜNCEL", yagRiskli ? Colors.redAccent : primaryCyan)),
            ],
          ),
          const SizedBox(height: 32),

          // AKSİYON BUTONU
          SizedBox(
            width: double.infinity, height: 56,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(side: BorderSide(color: primaryCyan.withOpacity(0.5)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ekspertiz Paneli Başlatılıyor...", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: primaryCyan)),
              icon: const Icon(Icons.science_outlined, color: primaryCyan, size: 20),
              label: const Text("YENİ EKSPERTİZ BAŞLAT", style: TextStyle(color: primaryCyan, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAnalizKarti(IconData ikon, String baslik, String durum, Color renk) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: renk.withOpacity(0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, color: renk, size: 24),
          const SizedBox(height: 16),
          Text(baslik, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, height: 1.4)),
          const SizedBox(height: 8),
          Text(durum, style: TextStyle(color: renk, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        ],
      ),
    );
  }
}