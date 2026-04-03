// lib/screens/qr_olusturma.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM DİJİTAL KİMLİK VE MÜHÜR MATBAASI
/// Aracın plaka ve şase bilgilerini alır, Firebase'e kaydeder ve araca özel kriptolu QR mühür basar.
class SiberQrOlusturmaSayfasi extends StatefulWidget {
  final String basanUstaId; // Mührü basan ustanın/bayinin Karargah Kimliği

  const SiberQrOlusturmaSayfasi({super.key, required this.basanUstaId});

  @override
  State<SiberQrOlusturmaSayfasi> createState() => _SiberQrOlusturmaSayfasiState();
}

class _SiberQrOlusturmaSayfasiState extends State<SiberQrOlusturmaSayfasi> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final TextEditingController _plakaController = TextEditingController();
  final TextEditingController _saseController = TextEditingController();
  final TextEditingController _markaModelController = TextEditingController();

  String _qrData = ""; // Üretilen kriptolu veri
  bool _islemSuruyor = false;

  // ── 🎨 KARARGAH TASARIM DOKTRİNİ ──
  static const Color _oledBlack = Color(0xFF000000);
  static const Color _matGrey = Color(0xFF111111);
  static const Color _kuantumCyan = Color(0xFF00FFC2);

  // ── 🚀 FİREBASE MÜHÜR MOTORU ──
  Future<void> _muhurAtesle() async {
    String plaka = _plakaController.text.trim().toUpperCase();
    String sase = _saseController.text.trim().toUpperCase();
    String marka = _markaModelController.text.trim();

    if (plaka.isEmpty || sase.isEmpty || marka.isEmpty) {
      HapticFeedback.heavyImpact();
      _siberUyariGoster("SİBER İHLAL", "Plaka, Şase ve Marka bilgileri boş bırakılamaz!", Colors.redAccent);
      return;
    }

    if (_islemSuruyor) return;
    setState(() => _islemSuruyor = true);
    HapticFeedback.lightImpact();

    // Benzersiz Kripto Mühür Oluştur (Örn: OTODNA-34XX123-A1B2C3D4E5)
    String zamanDamgasi = DateTime.now().millisecondsSinceEpoch.toString();
    String kriptoVeri = "OTODNA-$plaka-$sase-$zamanDamgasi";

    developer.log("🚀 SİBER MÜHÜR: $kriptoVeri Karargaha işleniyor...");

    try {
      // 1. Veriyi Doğrudan Karargaha (Firebase) Yaz
      await _db.collection('arac_kimlikleri').doc(kriptoVeri).set({
        'kripto_kod': kriptoVeri,
        'plaka': plaka,
        'sase_no': sase,
        'marka_model': marka,
        'olusturan_bayi_id': widget.basanUstaId,
        'olusturulma_tarihi': FieldValue.serverTimestamp(),
        'durum': 'AKTIF_MUHUR',
        'dna_skoru': 100, // Yeni araç sisteme 100 puanla başlar
      });

      HapticFeedback.vibrate();
      developer.log("✅ ONAY: Dijital kimlik Matrix'e kazındı.");

      // 2. Ekranda QR Kodu Göster
      setState(() {
        _qrData = kriptoVeri;
      });

      _siberUyariGoster("MÜHÜR BASILDI", "Aracın dijital kimliği Karargaha kaydedildi.", _kuantumCyan);

    } catch (e) {
      HapticFeedback.heavyImpact();
      developer.log("🚨 AĞ ÇÖKTÜ: Mühür Karargaha iletilemedi!", error: e);
      _siberUyariGoster("BAĞLANTI HATASI", "Mühür oluşturulamadı.", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _islemSuruyor = false);
    }
  }

  // ── 🚨 ARAYÜZ YARDIMCILARI ──
  void _siberUyariGoster(String baslik, String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _matGrey,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: renk, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            const SizedBox(height: 4),
            Text(mesaj, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _plakaController.dispose();
    _saseController.dispose();
    _markaModelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _oledBlack,
      appBar: AppBar(
        title: const Text("YENİ ARAÇ MÜHRÜ BAS", style: TextStyle(color: _kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 14)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kuantumCyan),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BİLGİ PANELİ
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: _kuantumCyan.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _kuantumCyan.withOpacity(0.3), width: 1.5)
                ),
                child: const Row(
                  children: [
                    Icon(Icons.qr_code_scanner, color: _kuantumCyan, size: 28),
                    SizedBox(width: 12),
                    Expanded(child: Text("Aracın fiziksel kimliğini dijital bir OtoDNA mührüne dönüştürün. Bu mühür ömür boyu Karargah veri tabanında saklanır.", style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.5, letterSpacing: 0.5))),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // FORM ALANLARI
              _buildSiberGirdiAlan("ARAÇ PLAKASI", "Örn: 34 DNA 1923", Icons.pin_outlined, _plakaController),
              const SizedBox(height: 16),
              _buildSiberGirdiAlan("ŞASE NUMARASI", "Aracın 17 haneli DNA'sı", Icons.fingerprint, _saseController),
              const SizedBox(height: 16),
              _buildSiberGirdiAlan("MARKA & MODEL", "Örn: Tesla Model 3", Icons.directions_car_outlined, _markaModelController),
              const SizedBox(height: 30),

              // ATEŞLEME BUTONU
              SizedBox(
                height: 60,
                width: double.infinity,
                child: _islemSuruyor
                    ? const Center(child: CircularProgressIndicator(color: _kuantumCyan))
                    : ElevatedButton.icon(
                  icon: const Icon(Icons.qr_code, color: Colors.black, size: 24),
                  label: const Text("SİBER MÜHRÜ BAS VE KAYDET", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kuantumCyan,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 10,
                    shadowColor: _kuantumCyan.withOpacity(0.5),
                  ),
                  onPressed: _muhurAtesle,
                ),
              ),

              // MÜHÜR EKRANI (QR GÖSTERİMİ)
              if (_qrData.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Divider(color: Colors.white24, height: 1),
                ),
                Center(
                  child: Column(
                    children: [
                      const Text("ARACIN DİJİTAL KİMLİĞİ (QR)", style: TextStyle(color: _kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 12)),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: _kuantumCyan.withOpacity(0.2), blurRadius: 40, spreadRadius: 10)
                            ]
                        ),
                        child: QrImageView(
                          data: _qrData,
                          version: QrVersions.auto,
                          size: 200.0,
                          backgroundColor: Colors.white,
                          eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                          dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text("Bu siber mührü yazdırıp aracın ilgili bölgesine yapıştırın.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  // ── 🔧 ÖZEL SİBER İNPUT WIDGET'I ──
  Widget _buildSiberGirdiAlan(String baslik, String ipucu, IconData ikon, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(baslik, style: const TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _matGrey,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24, width: 1.5),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 1),
            decoration: InputDecoration(
              prefixIcon: Icon(ikon, color: _kuantumCyan, size: 22),
              hintText: ipucu,
              hintStyle: const TextStyle(color: Colors.white30, letterSpacing: 1, fontSize: 12),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}