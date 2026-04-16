// lib/bayi/davet_sistemi.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI VE MERKEZİ TEMA BAĞLANTISI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

/// 🛡️ KUANTUM DAVET VE REFERANS MOTORU (DavetSistemiPaneli)
/// Sektör paydaşlarına Karargahın davetiyesini fırlatır ve bu eylemi Atomik olarak Firebase'e mühürler.
class DavetSistemiPaneli extends StatefulWidget {
  final String gonderenId; // Daveti fırlatan Karargah mensubunun ID'si

  const DavetSistemiPaneli({super.key, required this.gonderenId});

  @override
  State<DavetSistemiPaneli> createState() => _DavetSistemiPaneliState();
}

class _DavetSistemiPaneliState extends State<DavetSistemiPaneli> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _islemSuruyor = false;

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

  // ── 🚀 FİREBASE VE GERÇEK PAYLAŞIM MOTORU (ATOMİK ZIRHLI) ──
  Future<void> _davetiyeFirlat() async {
    HapticFeedback.heavyImpact();
    setState(() => _islemSuruyor = true);
    developer.log("🚀 SİBER RADAR: Davetiye fırlatma protokolü başlatıldı...");

    try {
      // 1. Cihazın Gerçek Paylaşım Ekranını Aç (WhatsApp, SMS, vs.)
      await Share.share(_davetMetni, subject: 'OtoDNA Karargah Daveti');

      // 2. ATOMİK MÜHÜRLEME DEVREDE (WriteBatch)
      WriteBatch batch = _db.batch();

      // Davet Logunu İşle
      DocumentReference davetRef = _db.collection('davet_loglari').doc();
      batch.set(davetRef, {
        'gonderen_id': widget.gonderenId,
        'davet_metni': 'STANDART_SEKTOR_DAVETI',
        'zaman_damgasi': FieldValue.serverTimestamp(),
      });

      // Kara Kutuya Rapor Ver
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'DAVETIYE_FIRLATILDI',
        'islem_detayi': 'SİBER BÜYÜME: ${widget.gonderenId} kimlikli bayi, sektöre Kuantum Davetiyesi fırlattı.',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit(); // Tüm füzeleri ateşle!

      HapticFeedback.vibrate(); // Başarı titreşimi
      developer.log("✅ ONAY: Davetiye fırlatıldı ve Karargaha mühürlendi.");

      if (mounted) {
        _siberUyariGoster("DAVET FIRLATILDI!", "Kuantum Ağı genişliyor. Operasyon loglara işlendi.", SiberTema.kuantumCyan);
      }

    } catch (e) {
      HapticFeedback.heavyImpact();
      developer.log("🚨 AĞ ÇÖKTÜ: Davet paylaşılamadı!", error: e);
      if (mounted) {
        _siberUyariGoster("SİSTEM HATASI", "Davetiye paylaşım motoru tetiklenemedi.", SiberTema.kanKirmizi);
      }
    } finally {
      if (mounted) setState(() => _islemSuruyor = false);
    }
  }

  // ── 🚨 ARAYÜZ YARDIMCILARI ──
  void _siberUyariGoster(String baslik, String mesaj, Color renk) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SiberTema.matGrey,
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
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("KARARGAH DAVET SİSTEMİ", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: SiberTema.kuantumCyan),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _talimatKutusu("SİBER PROTOKOL: Otomotiv sektöründeki paydaşları Kuantum Ağına katarak Karargahın gücünü artırabilirsiniz."),
                const SizedBox(height: 30),

                // 📜 DAVET METNİ ÖNİZLEMESİ (Cam Efektli Kutu)
                const Text("GÖNDERİLECEK ŞİFRELİ METİN:", style: TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: SiberTema.matGrey.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3), width: 1.5),
                      boxShadow: [
                        BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.05), blurRadius: 20, spreadRadius: 2),
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
                      ? const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan))
                      : ElevatedButton.icon(
                    icon: const Icon(Icons.send_to_mobile, color: Colors.black, size: 24),
                    label: const Text("DAVETİYEYİ FIRLAT", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14)),
                    style: SiberTema.kuantumButonStili(),
                    onPressed: _davetiyeFirlat,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _talimatKutusu(String metin) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
        color: SiberTema.kuantumCyan.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5), width: 1.5)
    ),
    child: Row(
      children: [
        const Icon(Icons.radar, color: SiberTema.kuantumCyan, size: 30),
        const SizedBox(width: 12),
        Expanded(child: Text(metin, style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.5, letterSpacing: 1, fontWeight: FontWeight.bold))),
      ],
    ),
  );
}