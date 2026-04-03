import 'package:flutter/material.dart';

// Gerçek projede 'qr_flutter' paketini eklemeyi unutma:
// import 'package:qr_flutter/qr_flutter.dart';

class GarantiSertifikasi extends StatelessWidget {
  final String plaka;
  final String islem;
  final String tarih;
  final String garantiSuresi;
  final String sertifikaId;

  const GarantiSertifikasi({
    super.key,
    required this.plaka,
    required this.islem,
    required this.tarih,
    required this.garantiSuresi,
    required this.sertifikaId,
  });

  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  static const Color bgColor = Color(0xFF000000);
  static const Color surfaceColor = Color(0xFF111111);
  static const Color primaryCyan = Color(0xFF00FFC2);
  static const Color goldBadge = Color(0xFFFFD700);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('D İ J İ T A L   M Ü H Ü R', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 3)),
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSiberSertifikaKarti(),
              const SizedBox(height: 40),
              // İndir / Paylaş Butonları
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAksiyonButonu(Icons.download_rounded, "CİHAZA KAYDET"),
                  const SizedBox(width: 16),
                  _buildAksiyonButonu(Icons.share_rounded, "KRİPTOLU PAYLAŞ", isPrimary: true),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: SİBER SERTİFİKA KARTI
  Widget _buildSiberSertifikaKarti() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: goldBadge.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(color: goldBadge.withOpacity(0.1), blurRadius: 50, spreadRadius: 5),
          BoxShadow(color: primaryCyan.withOpacity(0.05), blurRadius: 20, spreadRadius: -5),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Üst Rozet
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: goldBadge.withOpacity(0.1),
              border: Border.all(color: goldBadge.withOpacity(0.5), width: 1.5),
            ),
            child: const Icon(Icons.shield_outlined, color: goldBadge, size: 64),
          ),
          const SizedBox(height: 24),
          const Text("OTODNA ONAYLI", style: TextStyle(color: goldBadge, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 3)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text("SİBER GÜVENCE: AKTİF", style: TextStyle(color: primaryCyan, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2)),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Divider(color: Colors.white12, thickness: 1),
          ),

          // Bilgi Satırları
          _buildBilgiSatiri("ARAÇ PLAKASI", plaka.toUpperCase(), isMonospace: true),
          _buildBilgiSatiri("YAPILAN İŞLEM", islem.toUpperCase()),
          _buildBilgiSatiri("MÜHÜR TARİHİ", tarih, isMonospace: true),
          _buildBilgiSatiri("GARANTİ SÜRESİ", garantiSuresi.toUpperCase(), color: primaryCyan),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Divider(color: Colors.white12, thickness: 1),
          ),

          // Kriptolu QR Kod (Lokal Paket Simülasyonu)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            // Gerçekte buraya QrImageView gelecek:
            // child: QrImageView(data: sertifikaId, version: QrVersions.auto, size: 150),
            child: const Icon(Icons.qr_code_2, color: Colors.black, size: 120),
          ),

          const SizedBox(height: 16),
          Text("SERİ NO: $sertifikaId", style: const TextStyle(color: Colors.white38, fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold, letterSpacing: 2)),

          const SizedBox(height: 24),
          const Text(
              "Bu belge OtoDNA Dijital Referans Protokolü ile Kuantum Ağına mühürlenmiştir. Taklit edilemez ve kırılamaz.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 9, color: Colors.white38, height: 1.5, fontWeight: FontWeight.bold)
          ),
        ],
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: BİLGİ SATIRI
  Widget _buildBilgiSatiri(String baslik, String deger, {bool isMonospace = false, Color color = Colors.white}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(baslik, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              deger,
              textAlign: TextAlign.right,
              style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  fontFamily: isMonospace ? 'monospace' : null
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: AKSİYON BUTONU
  Widget _buildAksiyonButonu(IconData icon, String label, {bool isPrimary = false}) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: isPrimary ? bgColor : primaryCyan,
          backgroundColor: isPrimary ? primaryCyan : Colors.transparent,
          side: BorderSide(color: primaryCyan.withOpacity(0.5), width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
      ),
    );
  }
}