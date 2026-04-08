import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// 🔥 SİBER KÖPRÜLER
import '../../core/siber_tema.dart';

/// 🦅 KARGO KİMLİK EŞLEŞTİRME PROTOKOLÜ
/// Sipariş teslimatını QR ile mühürleyen ve kimlik doğrulaması yapan siber ünite.
class KargoTeslimatQrScreen extends StatefulWidget {
  final String kullaniciId; // Kamerayı açan alıcının Karargah kimliği

  const KargoTeslimatQrScreen({super.key, required this.kullaniciId});

  @override
  State<KargoTeslimatQrScreen> createState() => _KargoTeslimatQrScreenState();
}

class _KargoTeslimatQrScreenState extends State<KargoTeslimatQrScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _islemSuruyor = false;

  // 🚀 KİMLİK EŞLEŞTİRME VE QR İMHA PROTOKOLÜ
  Future<void> _qrTeslimatiOnayla(String okunanQrVerisi) async {
    if (_islemSuruyor) return;
    setState(() => _islemSuruyor = true);
    HapticFeedback.heavyImpact();

    try {
      // QR Kodun içinden Sipariş ID'sini çek (Örn: KARGO_SIPARIS123)
      String siparisId = okunanQrVerisi.replaceAll("KARGO_", "");
      DocumentReference siparisRef = _db.collection('siparisler').doc(siparisId);

      // 🔐 ACID Transaction: Atomik veri bütünlüğü koruması
      await _db.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(siparisRef);

        if (!snapshot.exists) {
          throw Exception("SİBER İHLAL: Bu koda ait bir sipariş bulunamadı!");
        }

        var data = snapshot.data() as Map<String, dynamic>;

        // 🛡️ ZIRH 1: KİMLİK EŞLEŞMESİ (Siparişi veren ile okutan aynı mı?)
        String siparisSahibi = data['alici_id'] ?? "";
        if (siparisSahibi != widget.kullaniciId) {
          throw Exception("KİMLİK REDDEDİLDİ: Bu kargo sizin adınıza kayıtlı değil!");
        }

        // 🛡️ ZIRH 2: ÇİFT OKUMA KORUMASI
        if (data['durum'] == 'TESLİM EDİLDİ') {
          throw Exception("GEÇERSİZ QR: Bu kod daha önce kullanılmış ve imha edilmiştir.");
        }

        // 🚀 İŞLEM ONAYI VE VERİ MÜHÜRLENMESİ
        transaction.update(siparisRef, {
          'durum': 'TESLİM EDİLDİ',
          'qr_kullanildi': true,
          'teslim_alan_id': widget.kullaniciId,
          'teslim_tarihi': FieldValue.serverTimestamp(),
          'iade_baslangic_tarihi': FieldValue.serverTimestamp(), // 15 Günlük Koruma Başladı
        });
      });

      HapticFeedback.vibrate();

      if (mounted) {
        _siberUyariGoster("KİMLİK EŞLEŞTİ VE QR İMHA EDİLDİ\nÜrün teslim alındı. 15 günlük güvenceniz aktif.", SiberTema.kuantumCyan);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      }

    } catch (e) {
      HapticFeedback.heavyImpact();
      if (mounted) {
        _siberUyariGoster("SİSTEM REDDETTİ: ${e.toString().replaceAll("Exception:", "").trim()}", SiberTema.kanKirmizi);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _islemSuruyor = false);
        });
      }
    }
  }

  void _siberUyariGoster(String mesaj, Color renk) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: TextStyle(color: renk == SiberTema.kanKirmizi ? Colors.white : SiberTema.oledBlack, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
      backgroundColor: renk,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SiberTema.oledBlack,
      appBar: AppBar(
        title: const Text("KARGO KİMLİK EŞLEŞTİRME", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 14, fontFamily: 'Avenir')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: SiberTema.kuantumCyan), onPressed: () => Navigator.pop(context)),
      ),
      body: Stack(
        children: [
          // 📸 SİBER KAMERA TARAYICI (MobileScanner v3+)
          MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && barcodes.first.rawValue != null && !_islemSuruyor) {
                _qrTeslimatiOnayla(barcodes.first.rawValue!);
              }
            },
          ),

          // 🛡️ HOLOGRAFİK HEDEF GÖSTERGESİ
          Center(
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(
                  border: Border.all(color: _islemSuruyor ? Colors.orangeAccent : SiberTema.kuantumCyan.withOpacity(0.8), width: 3),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [BoxShadow(color: (_islemSuruyor ? Colors.orangeAccent : SiberTema.kuantumCyan).withOpacity(0.2), blurRadius: 50, spreadRadius: 5)]
              ),
            ),
          ),

          // 📜 ALT BİLGİ PANELİ (Siber Cam Efekti)
          Positioned(
            bottom: 40, left: 20, right: 20,
            child: SiberTema.siberCamKalkan(
              padding: const EdgeInsets.all(24),
              child: const Column(
                children: [
                  Icon(Icons.fingerprint, color: SiberTema.kuantumCyan, size: 48),
                  SizedBox(height: 16),
                  Text("DOĞRULAMA BEKLENİYOR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12)),
                  const SizedBox(height: 12),
                  Text(
                    "Kargonun üzerindeki QR kod sadece siparişi veren Karargah hesabı ile eşleşir. Onay anında sistem güncellenir.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.6),
                  ),
                ],
              ),
            ),
          ),

          // ⏳ İŞLEM SÜRÜYOR KATMANI
          if (_islemSuruyor)
            Container(
              color: SiberTema.oledBlack.withOpacity(0.9),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: SiberTema.kuantumCyan, strokeWidth: 4),
                    SizedBox(height: 24),
                    Text("KİMLİK DOĞRULANIYOR...", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}