// lib/screens/qr_tarama.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:developer' as developer;

// SİBER NOT: Arıza kayıt sayfasının gerçek Karargah yolu
// import 'ariza_kaydi.dart';

/// 🛡️ KUANTUM KİMLİK TARAYICI (SiberQRTaramaSayfasi)
/// Araca basılan mührü okur, Karargahtan (Firebase) doğrular ve onaylanırsa sistemi açar.
class SiberQRTaramaSayfasi extends StatefulWidget {
  const SiberQRTaramaSayfasi({super.key});

  @override
  State<SiberQRTaramaSayfasi> createState() => _SiberQRTaramaSayfasiState();
}

class _SiberQRTaramaSayfasiState extends State<SiberQRTaramaSayfasi> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _islemSuruyor = false;

  // ── 🎨 KARARGAH TASARIM DOKTRİNİ ──
  static const Color _oledBlack = Color(0xFF000000);
  static const Color _matGrey = Color(0xFF111111);
  static const Color _kuantumCyan = Color(0xFF00FFC2);

  // ── 🚀 FİREBASE KİMLİK DOĞRULAMA MOTORU ──
  Future<void> _muhruSorgula(String okunanKod) async {
    if (_islemSuruyor) return;
    setState(() => _islemSuruyor = true);

    HapticFeedback.heavyImpact();
    developer.log("📡 SİBER TARAMA: Barkod yakalandı! Matrix'te sorgulanıyor: $okunanKod");

    try {
      // 1. Karargah veri tabanından bu kripto kodu ara
      DocumentSnapshot aracKimligi = await _db.collection('arac_kimlikleri').doc(okunanKod).get();

      if (!aracKimligi.exists) {
        throw Exception("SAHTE MÜHÜR! Bu kod Karargah veri tabanında bulunamadı.");
      }

      var aracVerisi = aracKimligi.data() as Map<String, dynamic>;
      String plaka = aracVerisi['plaka'] ?? "BİLİNMİYOR";

      HapticFeedback.vibrate();
      developer.log("✅ ONAY: Araç Tanındı -> $plaka. Sisteme giriş yapılıyor.");

      if (mounted) {
        _siberUyariGoster("KİMLİK DOĞRULANDI", "$plaka plakalı araç sisteme alındı.", _kuantumCyan);

        // 2. Doğrulama başarılıysa arıza kayıt terminaline geç (Araç verisini de göndererek)
        /*
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ArizaKayitSayfasi(aracKimlikVerisi: aracVerisi)),
        );
        */

        // SİBER NOT: Gerçek sayfa bağlanana kadar tarayıcıyı kapatıyoruz
        Navigator.pop(context);
      }

    } catch (e) {
      HapticFeedback.heavyImpact();
      developer.log("🚨 GÜVENLİK İHLALİ!", error: e);
      if (mounted) {
        _siberUyariGoster("KİMLİK REDDEDİLDİ", e.toString().replaceAll("Exception:", "").trim(), Colors.redAccent);
        // Hatalı kod okutulduğunda tarayıcının tekrar çalışması için kilidi aç
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _islemSuruyor = false);
        });
      }
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _oledBlack,
      appBar: AppBar(
        title: const Text("SİBER MÜHÜR RADARI", style: TextStyle(color: _kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 14)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kuantumCyan),
      ),
      body: Stack(
        children: [
          // 📸 CANLI TARAYICI
          MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null && !_islemSuruyor) {
                  _muhruSorgula(barcode.rawValue!);
                  break; // Sadece ilk okunan kodu işleme al
                }
              }
            },
          ),

          // 🛡️ SİBER ZIRH (HEDEF GÖSTERGESİ)
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                  border: Border.all(color: _islemSuruyor ? Colors.orangeAccent : _kuantumCyan.withOpacity(0.8), width: 3),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: (_islemSuruyor ? Colors.orangeAccent : _kuantumCyan).withOpacity(0.2), blurRadius: 40, spreadRadius: 5),
                  ]
              ),
              child: Stack(
                children: [
                  Positioned(top: 0, left: 0, child: _buildKose(top: true, left: true)),
                  Positioned(top: 0, right: 0, child: _buildKose(top: true, left: false)),
                  Positioned(bottom: 0, left: 0, child: _buildKose(top: false, left: true)),
                  Positioned(bottom: 0, right: 0, child: _buildKose(top: false, left: false)),
                ],
              ),
            ),
          ),

          // 📜 BİLGİ PANELİ
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _matGrey.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: const Column(
                children: [
                  Icon(Icons.radar, color: _kuantumCyan, size: 40),
                  SizedBox(height: 12),
                  Text("ARACIN SİBER MÜHRÜNÜ OKUTUN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 12)),
                  SizedBox(height: 8),
                  Text("Okunan QR kod Karargah veri tabanında canlı olarak sorgulanacak ve onaylanırsa giriş izni verilecektir.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.5)),
                ],
              ),
            ),
          ),

          // ⏳ İSTİHBARAT SORGULAMA EKRANI
          if (_islemSuruyor)
            Container(
              color: _oledBlack.withOpacity(0.85),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: _kuantumCyan),
                    SizedBox(height: 16),
                    Text("KİMLİK MATRIX'TE DOĞRULANIYOR...", style: TextStyle(color: _kuantumCyan, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }

  // Kamera köşe animasyonları
  Widget _buildKose({required bool top, required bool left}) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: top ? const BorderSide(color: Colors.white, width: 4) : BorderSide.none,
          bottom: !top ? const BorderSide(color: Colors.white, width: 4) : BorderSide.none,
          left: left ? const BorderSide(color: Colors.white, width: 4) : BorderSide.none,
          right: !left ? const BorderSide(color: Colors.white, width: 4) : BorderSide.none,
        ),
      ),
    );
  }
}