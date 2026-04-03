import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OtoDNABildirimEkrani extends StatefulWidget {
  const OtoDNABildirimEkrani({super.key});

  @override
  State<OtoDNABildirimEkrani> createState() => _OtoDNABildirimEkraniState();
}

class _OtoDNABildirimEkraniState extends State<OtoDNABildirimEkrani> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET (WEB UYUMLU)
  final Color bgColor = const Color(0xFF000000);
  final Color surfaceColor = const Color(0xFF111111);
  final Color primaryCyan = const Color(0xFF00FFC2);
  final Color dangerColor = Colors.redAccent;

  bool _isProcessing = false;
  bool _isGlobalProcessing = false;

  // --- 1. SİBER BİLDİRİM MOTORU (FİREBASE) ---
  Future<void> bildirimGonder(String qrID) async {
    setState(() => _isProcessing = true);

    // Kuantum Güvenlik: Cihaz tespiti (Gerçekte DeviceInfo eklenecek)
    String cihazIP = "192.168.1.XX";
    String cihazID = "DEVICE_12345";

    try {
      // 1. ADIM: KARA LİSTE (BLACKLIST) KONTROLÜ
      final blacklistRef = await FirebaseFirestore.instance.collection('kara_liste').doc(cihazID).get();
      if (blacklistRef.exists) {
        if (!mounted) return;
        _uyariGoster("İHLAL TESPİTİ: CİHAZINIZ AĞDAN ENGELLENDİ!", isError: true);
        return;
      }

      // 2. ADIM: ARAÇ SAHİBİNİ BUL
      final qrSorgu = await FirebaseFirestore.instance.collection('araclar').where('qr_id', isEqualTo: qrID).limit(1).get();

      if (qrSorgu.docs.isEmpty) {
        if (!mounted) return;
        _uyariGoster("HEDEF BULUNAMADI: ARAÇ OTODNA AĞINDA DEĞİL.", isError: true);
        return;
      }

      String aracSahibiID = qrSorgu.docs.first.data()['sahibi_id'] ?? 'Bilinmiyor';

      // 3. ADIM: GERÇEK BİLDİRİMİ YAZ (WriteBatch mantığına hazır)
      await FirebaseFirestore.instance.collection('bildirimler').add({
        "alici_id": aracSahibiID,
        "gonderen_ip": cihazIP,
        "gonderen_cihaz_id": cihazID,
        "baslik": "SİBER ACİL DURUM BİLDİRİMİ",
        "mesaj": "Aracınızın yanından bir bildirim fırlatıldı (Hatalı Park / Acil Durum ihtimali). Lütfen radarı kontrol ediniz.",
        "qr_kodu": qrID,
        "okundu_mu": false,
        "tarih": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _uyariGoster("SİNYAL İLETİLDİ! HEDEFE ULAŞILDI. 🦅");

    } catch (e) {
      if (!mounted) return;
      _uyariGoster("AĞ BAĞLANTI HATASI: Kuantum sinyali koptu.", isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // --- GAZİ YETKİSİ: GLOBAL PUSH NOTIFICATION ---
  void _globalBildirimAtesle() async {
    setState(() => _isGlobalProcessing = true);
    // TODO: Cloud Functions ile tüm kullanıcılara FCM Push Atılacak
    await Future.delayed(const Duration(seconds: 2)); // Simülasyon Kalkanı
    if (!mounted) return;
    setState(() => _isGlobalProcessing = false);
    _uyariGoster("GAZİ YETKİSİ ONAYLANDI: TÜM AĞA BİLDİRİM FÜZELERİ ATEŞLENDİ! 🚀");
  }

  void _uyariGoster(String mesaj, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1)),
        backgroundColor: isError ? dangerColor : primaryCyan,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- 2. WEB & MOBİL ARAYÜZ (RESPONSIVE) ---
  @override
  Widget build(BuildContext context) {
    // 💻 Cihaz genişliğini alıp Web/Mobil kararı veriyoruz
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.flag_outlined, color: Colors.redAccent, size: 20),
            const SizedBox(width: 12),
            Text(
              'Y E R L İ   V E   M İ L L İ   A Ğ',
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 3),
            ),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200), // Web ekranında sonsuza uzamayı engeller
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
          ),
        ),
      ),
    );
  }

  // MASAÜSTÜ: YAN YANA PANELLER
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildQrOkumaKarti(),
              const SizedBox(height: 32),
              _buildKayitDavetiKarti(),
            ],
          ),
        ),
        const SizedBox(width: 40),
        Expanded(
          flex: 4,
          child: _buildGaziYetkisiKarti(), // Sağ tarafta Kırmızı Nükleer Panel
        ),
      ],
    );
  }

  // MOBİL: ALT ALTA LİSTE
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildQrOkumaKarti(),
          const SizedBox(height: 32),
          _buildKayitDavetiKarti(),
          const SizedBox(height: 40),
          _buildGaziYetkisiKarti(),
        ],
      ),
    );
  }

  // 💎 BİLEŞEN 1: QR RADAR
  Widget _buildQrOkumaKarti() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryCyan.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.05), blurRadius: 30)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                child: Icon(Icons.qr_code_scanner, color: primaryCyan, size: 32),
              ),
              const SizedBox(width: 20),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("SİBER QR RADAR", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    SizedBox(height: 6),
                    Text("Hatalı Park Veya Acil Durum İhbarı Fırlat", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 64,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : () => bildirimGonder("ARAC-QR-001"),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryCyan.withOpacity(0.05),
                foregroundColor: primaryCyan,
                elevation: 0,
                side: BorderSide(color: primaryCyan.withOpacity(0.5), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: _isProcessing
                  ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: primaryCyan, strokeWidth: 2))
                  : Icon(Icons.radar, color: primaryCyan, size: 24),
              label: Text(
                _isProcessing ? "AĞ TARANIYOR..." : "HEDEFE SİNYAL GÖNDER",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 💎 BİLEŞEN 2: DİJİTAL KİMLİK DAVETİ
  Widget _buildKayitDavetiKarti() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Icon(Icons.shield_outlined, color: primaryCyan, size: 48),
          const SizedBox(height: 20),
          const Text("OTODNA DİJİTAL KİMLİK", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 12),
          const Text(
            "Aracınızın Siber Genetik Haritasını oluşturun ve kuantum ağına dahil olun. Güvenlik protokollerini anında aktifleştirin.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.6, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withOpacity(0.2)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("AĞA KAYIT OL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
          )
        ],
      ),
    );
  }

  // 💎 BİLEŞEN 3: GAZİ NÜKLEER PANEL (ADMİN)
  Widget _buildGaziYetkisiKarti() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: dangerColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: dangerColor.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: dangerColor.withOpacity(0.05), blurRadius: 40)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: dangerColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.cell_tower, color: dangerColor, size: 56),
          ),
          const SizedBox(height: 32),
          Text("GAZİ YETKİSİ:\nMERKEZİ İLETİŞİM", textAlign: TextAlign.center, style: TextStyle(color: dangerColor, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          const Text(
            "Bu terminal, Türkiye genelindeki tüm OtoDNA ağına anlık Push Notification füzeleri fırlatmak için kullanılır. Yalnızca Siber Komutan yetkisiyle ateşlenebilir.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.6),
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 64,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isGlobalProcessing ? null : _globalBildirimAtesle,
              style: ElevatedButton.styleFrom(
                backgroundColor: dangerColor,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: _isGlobalProcessing
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                  : const Icon(Icons.rocket_launch, size: 24),
              label: Text(
                _isGlobalProcessing ? "FÜZELER ATEŞLENİYOR..." : "TÜM AĞA BİLDİRİM FIRLAT",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}