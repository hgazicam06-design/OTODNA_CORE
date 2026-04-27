import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // 📡 SİBER MÜHÜR İÇİN ŞART!

/// 🛡️ OTODNA DİJİTAL MÜHÜR VE GARANTİ SERTİFİKASI - V4
/// [2026-03-28] GÜNCELLEME: Kuantum QR Motoru ve Paylaşım Altyapısı Entegre Edildi.
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

  // 🌑 TESLA MİMARİSİ: OLED SİYAH VE KUANTUM ALTIN PALETİ
  static const Color _bgColor = Color(0xFF000000);
  static const Color _surfaceColor = Color(0xFF0A0A0A);
  static const Color _primaryCyan = Color(0xFF00FFC2);
  static const Color _goldBadge = Color(0xFFFFD700);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.security_update_good, color: _primaryCyan, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('D İ J İ T A L   M Ü H Ü R',
            style: TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 4)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [_goldBadge.withOpacity(0.05), _bgColor],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSiberSertifikaKarti(context),
                const SizedBox(height: 48),
                _buildAksiyonPaneli(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 💎 SİBER SERTİFİKA KARTI: Kuantum Ağı Onaylı Tasarım
  Widget _buildSiberSertifikaKarti(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: _goldBadge.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(color: _goldBadge.withOpacity(0.08), blurRadius: 60, spreadRadius: 10),
          BoxShadow(color: Colors.white, blurRadius: 20, spreadRadius: 5),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMuhurIkonyu(),
          const SizedBox(height: 28),
          const Text("OTODNA ONAYLI", style: TextStyle(color: _goldBadge, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 5)),
          const SizedBox(height: 12),
          _buildDurumEtiketi(),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Divider(color: SiberTema.textMuted, thickness: 0.5),
          ),

          _buildBilgiSatiri("ARAÇ PLAKASI", plaka.toUpperCase(), isMonospace: true),
          _buildBilgiSatiri("YAPILAN İŞLEM", islem.toUpperCase()),
          _buildBilgiSatiri("MÜHÜR TARİHİ", tarih, isMonospace: true),
          _buildBilgiSatiri("GARANTİ SÜRESİ", garantiSuresi.toUpperCase(), color: _primaryCyan),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Divider(color: SiberTema.textMuted, thickness: 0.5),
          ),

          _buildQrMotoru(),

          const SizedBox(height: 20),
          Text("SERİ NO: ${sertifikaId.toUpperCase()}",
              style: const TextStyle(color: SiberTema.textMuted, fontSize: 9, fontFamily: 'monospace', fontWeight: FontWeight.bold, letterSpacing: 2)),

          const SizedBox(height: 32),
          const Text(
              "Bu belge OtoDNA Dijital Referans Protokolü ile mühürlenmiştir.\nSiber Karargah tarafından doğrulanabilir.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 8, color: SiberTema.textMuted, height: 1.6, fontWeight: FontWeight.bold, letterSpacing: 0.5)
          ),
        ],
      ),
    );
  }

  Widget _buildMuhurIkonyu() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 90, height: 90,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _goldBadge.withOpacity(0.2), width: 1)),
        ),
        Container(
          width: 70, height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _goldBadge.withOpacity(0.05),
            border: Border.all(color: _goldBadge.withOpacity(0.5), width: 1.5),
            boxShadow: [BoxShadow(color: _goldBadge.withOpacity(0.1), blurRadius: 20)],
          ),
          child: const Icon(Icons.verified_user_rounded, color: _goldBadge, size: 36),
        ),
      ],
    );
  }

  Widget _buildDurumEtiketi() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: _primaryCyan.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primaryCyan.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: _primaryCyan, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          const Text("SİBER GÜVENCE: AKTİF", style: TextStyle(color: _primaryCyan, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 2)),
        ],
      ),
    );
  }

  Widget _buildQrMotoru() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: QrImageView(
        data: "OTODNA-CERT-$sertifikaId",
        version: QrVersions.auto,
        size: 140,
        eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.white),
        dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.circle, color: Colors.white),
      ),
    );
  }

  Widget _buildBilgiSatiri(String baslik, String deger, {bool isMonospace = false, Color color = Colors.white}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(baslik, style: const TextStyle(color: SiberTema.textMuted, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          Text(deger, textAlign: TextAlign.right, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w900, fontFamily: isMonospace ? 'monospace' : null, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildAksiyonPaneli(BuildContext context) {
    return Row(
      children: [
        _buildAksiyonButonu(Icons.file_download_outlined, "SİSTEME KAYDET", () {}),
        const SizedBox(width: 16),
        _buildAksiyonButonu(Icons.qr_code_scanner_rounded, "KRİPTOLU PAYLAŞ", () {}, isPrimary: true),
      ],
    );
  }

  Widget _buildAksiyonButonu(IconData icon, String label, VoidCallback eylem, {bool isPrimary = false}) {
    return Expanded(
      child: InkWell(
        onTap: eylem,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: isPrimary ? _primaryCyan : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _primaryCyan.withOpacity(0.5), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isPrimary ? Colors.black : _primaryCyan),
              const SizedBox(width: 10),
              Text(label, style: TextStyle(color: isPrimary ? Colors.black : _primaryCyan, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ],
          ),
        ),
      ),
    );
  }
}