// lib/screens/davet_sistemi.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM DAVET VE REFERANS MOTORU (DavetSistemiPaneli)
/// Sektör paydaşlarına Karargahın davetiyesini fırlatır ve bu eylemi Firebase'e mühürler.
class DavetSistemiPaneli extends StatefulWidget {
  final String gonderenId; // Daveti fırlatan Karargah mensubunun ID'si

  const DavetSistemiPaneli({super.key, required this.gonderenId});

  @override
  State<DavetSistemiPaneli> createState() => _DavetSistemiPaneliState();
}

class _DavetSistemiPaneliState extends State<DavetSistemiPaneli> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _islemSuruyor = false;

  // ── 🎨 KARARGAH TASARIM DOKTRİNİ ──
  static const Color _oledBlack = Color(0xFF000000);
  static const Color _matGrey = Color(0xFF111111);
  static const Color _kuantumCyan = Color(0xFF00FFC2);

  static const String _davetMetni = """
🛡️ OTODNA DİJİTAL REFERANS PROTOKOLÜNE DAVETLİSİNİZ!

Değerli Sektör Paydaşı;
OtoDNA, otomotiv dünyasındaki hantallığı, güvensizliği ve sahipsizliği bitirmek için doğdu. 
Servislerden sürücü kurslarına, rent a carlardan beyincilere kadar tüm sektörü tek bir 'Mühürlü Çatı' altında topluyoruz.

✅ Siber İmece ile Güvendesiniz.
✅ Dijital Noter ile Referanslısınız.
✅ Global Market ile Her Yerdesiniz.

Sektörün geleceğine beraber imza atalım.
Hemen Kaydolun: https://otodna.com/davet
""";

  // ── 🚀 FİREBASE VE GERÇEK PAYLAŞIM MOTORU ──
  Future<void> _davetiyeFirlat() async {
    HapticFeedback.heavyImpact();
    setState(() => _islemSuruyor = true);
    developer.log("🚀 SİBER RADAR: Davetiye fırlatma protokolü başlatıldı...");

    try {
      // 1. Cihazın Gerçek Paylaşım Ekranını Aç (WhatsApp, SMS, vs.)
      await Share.share(_davetMetni, subject: 'OtoDNA Karargah Daveti');

      // 2. Karargah Veritabanına (Firebase) Logla
      await _db.collection('davet_loglari').add({
        'gonderen_id': widget.gonderenId,
        'davet_metni': 'STANDART_SEKTOR_DAVETI',
        'zaman_damgasi': FieldValue.serverTimestamp(),
      });

      HapticFeedback.vibrate(); // Başarı titreşimi
      developer.log("✅ ONAY: Davetiye fırlatıldı ve Karargaha mühürlendi.");

      if (mounted) {
        _siberUyariGoster("DAVET FIRLATILDI!", "Kuantum Ağı genişliyor. Operasyon loglara işlendi.", _kuantumCyan);
      }

    } catch (e) {
      HapticFeedback.heavyImpact();
      developer.log("AĞ ÇÖKTÜ: Davet paylaşılamadı!", error: e);
      if (mounted) {
        _siberUyariGoster("SİSTEM HATASI", "Davetiye paylaşım motoru tetiklenemedi.", Colors.redAccent);
      }
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _oledBlack,
      appBar: AppBar(
        title: const Text("KARARGAH DAVET SİSTEMİ", style: TextStyle(color: _kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kuantumCyan),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _talimatKutusu("SİBER PROTOKOL: Otomotiv sektöründeki paydaşları Kuantum Ağına katarak sistem DNA puanınızı artırabilirsiniz."),
              const SizedBox(height: 30),

              // 📜 DAVET METNİ ÖNİZLEMESİ (Cam Efektli Kutu)
              const Text("GÖNDERİLECEK ŞİFRELİ METİN:", style: TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _matGrey,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _kuantumCyan.withOpacity(0.3), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: _kuantumCyan.withOpacity(0.05), blurRadius: 20, spreadRadius: 2),
                    ],
                  ),
                  child: const SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Text(
                      _davetMetni,
                      style: TextStyle(color: Colors.white, fontSize: 13, height: 1.6, letterSpacing: 0.5),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 🚀 ATEŞLEME BUTONU
              SizedBox(
                height: 60,
                width: double.infinity,
                child: _islemSuruyor
                    ? const Center(child: CircularProgressIndicator(color: _kuantumCyan))
                    : ElevatedButton.icon(
                  icon: const Icon(Icons.send_to_mobile, color: Colors.black, size: 24),
                  label: const Text("DAVETİYEYİ FIRLAT", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kuantumCyan,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 10,
                    shadowColor: _kuantumCyan.withOpacity(0.5),
                  ),
                  onPressed: _davetiyeFirlat,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _talimatKutusu(String metin) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
        color: _kuantumCyan.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kuantumCyan.withOpacity(0.5), width: 1.5)
    ),
    child: Row(
      children: [
        const Icon(Icons.radar, color: _kuantumCyan, size: 30),
        const SizedBox(width: 12),
        Expanded(child: Text(metin, style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.5, letterSpacing: 1))),
      ],
    ),
  );
}