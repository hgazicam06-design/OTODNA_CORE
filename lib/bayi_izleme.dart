// lib/screens/bayi_izleme.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import 'dart:developer' as developer;

/// 🛡️ KUANTUM BAYİ YÖNETİM PANELİ VE SİBER RADAR (BayiDashboard)
/// Firebase'i canlı dinler, saha sakinse radar çizer, S.O.S düşerse kırmızı alarma geçer.
class BayiDashboard extends StatefulWidget {
  final String bayiId; // Bu paneli açan bayinin Karargah kimliği

  const BayiDashboard({super.key, required this.bayiId});

  @override
  State<BayiDashboard> createState() => _BayiDashboardState();
}

class _BayiDashboardState extends State<BayiDashboard> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late AnimationController _radarController;

  // ── 🎨 KARARGAH TASARIM DOKTRİNİ ──
  static const Color _oledBlack = Color(0xFF000000);
  static const Color _matGrey = Color(0xFF111111);
  static const Color _kuantumCyan = Color(0xFF00FFC2);

  @override
  void initState() {
    super.initState();
    // 📡 Sürekli Dönen Siber Radar Animasyonu
    _radarController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _oledBlack,
      appBar: AppBar(
        title: const Text("KUANTUM BAYİ TERMİNALİ", style: TextStyle(color: _kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kuantumCyan),
      ),
      body: Column(
        children: [
          // ── 🚨 1. KRİTİK S.O.S RADARI (CANLI DİNLEME) ──
          StreamBuilder<QuerySnapshot>(
            stream: _db.collection('sos_sinyalleri')
                .where('hedef_bayi_1', isEqualTo: widget.bayiId)
                .where('durum', isEqualTo: 'YENI_SINYAL')
                .snapshots(),
            builder: (context, snapshot) {
              int aktifSosSayisi = 0;
              if (snapshot.hasData) {
                aktifSosSayisi = snapshot.data!.docs.length;
              }

              // Sinyal Varsa Kırmızı Alarm, Yoksa Sakin Radar
              return Container(
                height: 200,
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: aktifSosSayisi > 0 ? Colors.redAccent.withOpacity(0.1) : _matGrey,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: aktifSosSayisi > 0 ? Colors.redAccent : _kuantumCyan.withOpacity(0.3), width: 2),
                ),
                child: aktifSosSayisi > 0
                    ? _buildKirmiziAlarmKarti(aktifSosSayisi)
                    : _buildSakinRadarSimulasyonu(),
              );
            },
          ),

          // ── 📊 2. GÜNLÜK İSTİHBARAT PANOSU (DİĞER MODÜLLER) ──
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const Text("SİBER İSTİHBARAT ÖZETİ", style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // Canlı Arıza Bekleme Modülü
                _buildCanliIstatistikKarti(
                  koleksiyon: 'ariza_kayitlari',
                  filtreAlani: 'durum',
                  filtreDegeri: 'BEKLIYOR',
                  baslik: "BEKLEYEN ARIZA TESPİTLERİ",
                  ikon: Icons.pending_actions_outlined,
                  renk: Colors.orangeAccent,
                ),

                const SizedBox(height: 12),

                // Canlı Aktif Bakım Modülü
                _buildCanliIstatistikKarti(
                  koleksiyon: 'ariza_kayitlari', // İş emrine dönenler
                  filtreAlani: 'durum',
                  filtreDegeri: 'BAKIMDA',
                  baslik: "LİFTTEKİ (AKTİF) ARAÇLAR",
                  ikon: Icons.build_circle_outlined,
                  renk: _kuantumCyan,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ── 📡 ARAYÜZ YARDIMCILARI ───────────────────────────────────────────────

  /// S.O.S Sinyali yoksa dönen Siber Radar Animasyonu
  Widget _buildSakinRadarSimulasyonu() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _radarController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _radarController.value * 2 * math.pi,
              child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _kuantumCyan.withOpacity(0.5)),
                  gradient: SweepGradient(
                    colors: [Colors.transparent, _kuantumCyan.withOpacity(0.8)],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        const Text("RADAR TEMİZ. YAKINDA S.O.S SİNYALİ YOK.", style: TextStyle(color: _kuantumCyan, letterSpacing: 1, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  /// S.O.S geldiğinde Radarı kapatıp Kırmızıya boyayan Panik Kalkanı
  Widget _buildKirmiziAlarmKarti(int sinyalSayisi) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.redAccent.withOpacity(0.2),
            boxShadow: [BoxShadow(color: Colors.redAccent.withOpacity(0.5), blurRadius: 20)],
          ),
          child: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 50),
        ),
        const SizedBox(height: 16),
        Text("🚨 $sinyalSayisi AKTİF S.O.S SİNYALİ 🚨", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2)),
        const SizedBox(height: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          onPressed: () {
            developer.log("SİBER BİLGİ: S.O.S Müdahale ekranına (AdminSirenEkrani) yönlendiriliyor...");
            // Navigator.push(...);
          },
          child: const Text("MÜDAHALE ET", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        )
      ],
    );
  }

  /// Veritabanındaki belgeleri sayıp canlı gösteren Kuantum Kartı
  Widget _buildCanliIstatistikKarti({
    required String koleksiyon,
    required String filtreAlani,
    required String filtreDegeri,
    required String baslik,
    required IconData ikon,
    required Color renk,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection(koleksiyon).where('bayi_id', isEqualTo: widget.bayiId).where(filtreAlani, isEqualTo: filtreDegeri).snapshots(),
      builder: (context, snapshot) {
        String adet = "...";
        if (snapshot.hasData) {
          adet = snapshot.data!.docs.length.toString();
        }

        return Container(
          decoration: BoxDecoration(
            color: _matGrey,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: renk.withOpacity(0.3)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: Icon(ikon, color: renk, size: 32),
            title: Text(baslik, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 12)),
            trailing: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: renk.withOpacity(0.1), shape: BoxShape.circle),
              child: Text(adet, style: TextStyle(color: renk, fontWeight: FontWeight.w900, fontSize: 18)),
            ),
            onTap: () {
              developer.log("SİBER GEÇİŞ: $baslik listesine gidiliyor...");
            },
          ),
        );
      },
    );
  }
}