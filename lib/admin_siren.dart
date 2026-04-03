// lib/widgets/admin_siren.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Siber Titreşim (Haptic) için eklendi
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM KARARGAH KIRMIZI ALARM MODÜLÜ (AdminSirenEkrani)
/// S.O.S sinyali alındığında Karargah ekranlarını kırmızıya boyayan ve müdahaleyi veritabanına mühürleyen sistem.
class AdminSirenEkrani extends StatefulWidget {
  final String sinyalId;
  final String bolgeBilgisi;
  final String saseNo;

  const AdminSirenEkrani({
    super.key,
    required this.sinyalId,
    required this.bolgeBilgisi,
    required this.saseNo,
  });

  @override
  State<AdminSirenEkrani> createState() => _AdminSirenEkraniState();
}

class _AdminSirenEkraniState extends State<AdminSirenEkrani> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _mudahaleEdiliyor = false;

  @override
  void initState() {
    super.initState();
    developer.log("🚨 KRİZ MERKEZİ: ${widget.sinyalId} kodlu S.O.S sinyali için sirenler devreye girdi!");

    // Siber Parlama Animasyonu (Siyah ve Kan Kırmızı arasında gidip gelir)
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..repeat(reverse: true);

    // İlk açılışta Karargahı titret (Kriz Hissiyatı)
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── 🛡️ MÜDAHALE PROTOKOLÜ (FIREBASE BAĞLANTISI) ──
  Future<void> _kriziSonlandirVeMudahaleEt() async {
    setState(() => _mudahaleEdiliyor = true);
    HapticFeedback.vibrate(); // Butona basılınca siber onay titreşimi
    developer.log("SİBER BİLGİ: Kriz müdahale protokolü başlatıldı, Karargaha bağlanılıyor...");

    try {
      // S.O.S Sinyalini Karargah veritabanında "MÜDAHALE_EDİLDİ" olarak mühürle
      await FirebaseFirestore.instance.collection('sos_sinyalleri').doc(widget.sinyalId).update({
        'durum': 'MUDAHALE_EDILDI',
        'mudahale_eden_admin': 'KARARGAH_MERKEZ',
        'mudahale_zaman_damgasi': FieldValue.serverTimestamp(),
      });

      developer.log("✅ SİBER ONAY: Kriz yönetimi başarılı. Sinyal kapatıldı ve loglara şifrelendi.");

      // Animasyonu durdur ve ekranı kapat
      _controller.stop();
      if (mounted) Navigator.pop(context);

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Sinyal kapatılamadı, internet bağlantısını kontrol edin!", error: e);
      if (mounted) setState(() => _mudahaleEdiliyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          // Kuantum Alarm Renk Geçişi
          backgroundColor: Color.lerp(const Color(0xFF000000), Colors.red.shade900, _controller.value),
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Siber Kalkan İkonu
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.5), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 10,
                          )
                        ],
                      ),
                      child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 100),
                    ),
                    const SizedBox(height: 40),

                    const Text(
                        "🚨 KRİTİK S.O.S SİNYALİ 🚨",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 3)
                    ),
                    const SizedBox(height: 30),

                    // Dinamik İstihbarat Panosu
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111).withOpacity(0.8), // Mat Cam Efekti
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.redAccent.withOpacity(0.5), width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBilgiSatiri(Icons.location_on_outlined, "BÖLGE", widget.bolgeBilgisi),
                          const Divider(color: Colors.white24, height: 24),
                          _buildBilgiSatiri(Icons.directions_car_outlined, "ARAÇ (DNA)", widget.saseNo),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Siber Müdahale Butonu
                    SizedBox(
                      width: double.infinity,
                      height: 65,
                      child: _mudahaleEdiliyor
                          ? const Center(child: CircularProgressIndicator(color: Colors.white))
                          : ElevatedButton.icon(
                        onPressed: _kriziSonlandirVeMudahaleEt,
                        icon: const Icon(Icons.gpp_good_outlined, color: Colors.black, size: 28),
                        label: const Text(
                            "SİRENİ DURDUR VE MÜDAHALE ET",
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5)
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00FFC2), // Kuantum Turkuazı
                          foregroundColor: Colors.black, // Yazı Rengi
                          elevation: 10,
                          shadowColor: const Color(0xFF00FFC2).withOpacity(0.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── 🔧 ARAYÜZ YARDIMCISI: İSTİHBARAT SATIRI (KOPAN KISIM TAMAMLANDI) ──
  Widget _buildBilgiSatiri(IconData ikon, String baslik, String deger) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(ikon, color: Colors.white54, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                baslik.toUpperCase(),
                style: const TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                deger,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}