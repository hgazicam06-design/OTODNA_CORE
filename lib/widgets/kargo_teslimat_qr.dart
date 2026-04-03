// lib/screens/kargo_teslimat_qr.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // Siber Kamera Mühimmatı
import 'dart:developer' as developer;

/// 🛡️ KUANTUM KARGO QR TESLİMAT VE İMHA MOTORU
/// Sadece siparişi veren kişi okutabilir. Okutma başarılı olursa QR kod sistemden SİLİNİR!
class KargoTeslimatQrEkrani extends StatefulWidget {
  final String kullaniciId; // Kamerayı açan kullanıcının Karargah kimliği

  const KargoTeslimatQrEkrani({super.key, required this.kullaniciId});

  @override
  State<KargoTeslimatQrEkrani> createState() => _KargoTeslimatQrEkraniState();
}

class _KargoTeslimatQrEkraniState extends State<KargoTeslimatQrEkrani> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _islemSuruyor = false;

  // ── 🎨 KARARGAH TASARIM DOKTRİNİ ──
  static const Color _oledBlack = Color(0xFF000000);
  static const Color _matGrey = Color(0xFF111111);
  static const Color _kuantumCyan = Color(0xFF00FFC2);

  // ── 🚀 KİMLİK EŞLEŞTİRME VE QR İMHA PROTOKOLÜ ──
  Future<void> _qrTeslimatiOnayla(String okunanQrVerisi) async {
    if (_islemSuruyor) return;
    setState(() => _islemSuruyor = true);

    HapticFeedback.heavyImpact();
    developer.log("📡 SİBER TARAMA: QR Kod yakalandı! Veri: $okunanQrVerisi");

    try {
      // SİBER NOT: QR Kodun içinde siparişin ID'si şifrelenmiş olmalı.
      String siparisId = okunanQrVerisi;
      DocumentReference siparisRef = _db.collection('siparisler').doc(siparisId);

      // ACID Transaction: İnternet kopsa bile veri bütünlüğü korunur
      await _db.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(siparisRef);

        if (!snapshot.exists) {
          throw Exception("SİBER İHLAL: Bu koda ait bir sipariş bulunamadı!");
        }

        var data = snapshot.data() as Map<String, dynamic>;

        // 🛡️ ZIRH 1: KİMLİK EŞLEŞMESİ (Siparişi veren ile okutan aynı mı?)
        String siparisSahibi = data['siparis_veren_id'] ?? "";
        if (siparisSahibi != widget.kullaniciId) {
          throw Exception("KİMLİK REDDEDİLDİ: Bu kargo sizin adınıza kayıtlı değil! Eşleşme başarısız.");
        }

        // 🛡️ ZIRH 2: DAHA ÖNCE İMHA EDİLMİŞ Mİ KONTROLÜ
        if (data['qr_kullanildi'] == true || !data.containsKey('qr_kripto_kodu')) {
          throw Exception("GEÇERSİZ QR: Bu kod daha önce okutulmuş ve sistemden tamamen SİLİNMİŞTİR.");
        }

        // 🚀 İŞLEM ONAYI, SAYAÇ BAŞLATMA VE VERİ İMHASI!
        transaction.update(siparisRef, {
          'kargo_durumu': 'TESLİM EDİLDİ',
          'qr_kullanildi': true,
          'qr_kripto_kodu': FieldValue.delete(), // 🔥 KRİTİK HAMLE: QR KOD VERİTABANINDAN SİLİNİR!
          'teslim_alan_id': widget.kullaniciId,
          'teslim_tarihi': FieldValue.serverTimestamp(),
          'iade_baslangic_tarihi': FieldValue.serverTimestamp(), // 15 Günlük Kalkan Başladı
        });
      });

      HapticFeedback.vibrate();
      developer.log("✅ TESLİMAT ONAYLANDI: Kimlik eşleşti, QR kodu imha edildi, İade Kalkanı Devrede!");

      if (mounted) {
        _siberUyariGoster("KİMLİK EŞLEŞTİ VE QR SİLİNDİ", "Ürün adınıza teslim edildi. 15 günlük Karargah güvenceniz başladı.", _kuantumCyan);
        Navigator.pop(context); // İşlem bitince tarayıcıyı otonom kapatır
      }

    } catch (e) {
      HapticFeedback.heavyImpact();
      developer.log("🚨 SİBER GÜVENLİK İHLALİ!", error: e);
      if (mounted) {
        _siberUyariGoster("SİSTEM REDDETTİ", e.toString().replaceAll("Exception:", "").trim(), Colors.redAccent);
        // Hata durumunda (örneğin başkası okuttuysa) kamerayı tekrar açmak için state'i sıfırlıyoruz
        setState(() => _islemSuruyor = false);
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
        title: const Text("KARGO KİMLİK EŞLEŞTİRME", style: TextStyle(color: _kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 14)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kuantumCyan),
      ),
      body: Stack(
        children: [
          // 📸 SİBER KAMERA TARAYICI
          MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null && !_islemSuruyor) {
                  _qrTeslimatiOnayla(barcode.rawValue!);
                  break; // İlk kodu yakaladığında dur
                }
              }
            },
          ),

          // 🛡️ HEDEF GÖSTERGESİ (Siber Zırh Görünümü)
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

          // 📜 ALT BİLGİ PANELİ
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
                  Icon(Icons.fingerprint, color: _kuantumCyan, size: 40),
                  SizedBox(height: 12),
                  Text("KİMLİK DOĞRULAMA BEKLENİYOR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 12)),
                  SizedBox(height: 8),
                  Text("Kargonun üzerindeki QR kod sadece siparişi veren hesapla eşleşir. Okutma başarılı olduğunda kod imha edilir.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.5)),
                ],
              ),
            ),
          ),

          // ⏳ YÜKLENİYOR EKRANI
          if (_islemSuruyor)
            Container(
              color: _oledBlack.withOpacity(0.85),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: _kuantumCyan),
                    SizedBox(height: 16),
                    Text("KİMLİK EŞLEŞTİRİLİYOR VE KOD SİLİNİYOR...", style: TextStyle(color: _kuantumCyan, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }

  // Kamera köşe animasyonları için yardımcı widget
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