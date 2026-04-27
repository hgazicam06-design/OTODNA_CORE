// lib/screens/bayi_izleme.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI VE MERKEZİ TEMA BAĞLANTISI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

/// 🛡️ KUANTUM BAYİ YÖNETİM PANELİ VE SİBER RADAR (BayiDashboard)
/// Firebase'i canlı dinler, saha sakinse radar çizer, S.O.S düşerse kırmızı alarma geçer.
class BayiDashboard extends StatefulWidget {
  final String bayiId;

  const BayiDashboard({super.key, required this.bayiId});

  @override
  State<BayiDashboard> createState() => _BayiDashboardState();
}

class _BayiDashboardState extends State<BayiDashboard> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late AnimationController _radarController;

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
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("KUANTUM BAYİ TERMİNALİ", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 13)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: SiberTema.kuantumCyan),
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
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: 200,
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: aktifSosSayisi > 0 ? SiberTema.kanKirmizi.withOpacity(0.1) : SiberTema.matGrey,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: aktifSosSayisi > 0 ? SiberTema.kanKirmizi : SiberTema.kuantumCyan.withOpacity(0.3), width: 2),
                    boxShadow: aktifSosSayisi > 0 ? [BoxShadow(color: SiberTema.kanKirmizi.withOpacity(0.3), blurRadius: 20, spreadRadius: 2)] : [],
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
                  const Text("SİBER İSTİHBARAT ÖZETİ", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),

                  _buildCanliIstatistikKarti(
                    koleksiyon: 'ariza_kayitlari',
                    filtreAlani: 'durum',
                    filtreDegeri: 'BEKLIYOR',
                    baslik: "BEKLEYEN ARIZA TESPİTLERİ",
                    ikon: Icons.pending_actions_outlined,
                    renk: Colors.amberAccent,
                  ),

                  const SizedBox(height: 12),

                  _buildCanliIstatistikKarti(
                    koleksiyon: 'ariza_kayitlari',
                    filtreAlani: 'durum',
                    filtreDegeri: 'BAKIMDA',
                    baslik: "LİFTTEKİ (AKTİF) ARAÇLAR",
                    ikon: Icons.build_circle_outlined,
                    renk: SiberTema.kuantumCyan,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ── 📡 ARAYÜZ YARDIMCILARI ──

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
                  border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5)),
                  gradient: SweepGradient(
                    colors: [Colors.transparent, SiberTema.kuantumCyan.withOpacity(0.8)],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        const Text("RADAR TEMİZ. YAKINDA S.O.S SİNYALİ YOK.", style: TextStyle(color: SiberTema.kuantumCyan, letterSpacing: 1, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildKirmiziAlarmKarti(int sinyalSayisi) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(shape: BoxShape.circle, color: SiberTema.kanKirmizi.withOpacity(0.2)),
          child: const Icon(Icons.warning_amber_rounded, color: SiberTema.kanKirmizi, size: 50),
        ),
        const SizedBox(height: 16),
        Text("🚨 $sinyalSayisi AKTİF S.O.S SİNYALİ 🚨", style: const TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2)),
        const SizedBox(height: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: SiberTema.kanKirmizi, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          onPressed: () {
            developer.log("SİBER BİLGİ: S.O.S Müdahale ekranına yönlendiriliyor...");
            
            // 📡 SİBER RADARA BİLDİR (Bayi Müdahalesi)
            FirebaseFirestore.instance.collection('siber_istihbarat_loglari').add({
              'kategori': 'GÜVENLİK',
              'seviye': 'BİLGİ',
              'mesaj': 'S.O.S MÜDAHALESİ: Bayi acil durum sinyaline müdahale başlattı.',
              'hedef_id': 'SOS_MÜDAHALE',
              'tarih': FieldValue.serverTimestamp(),
            });
            
            // TODO: Müdahale sayfasına Navigator ile geçiş
          },
          child: const Text("MÜDAHALE ET", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        )
      ],
    );
  }

  Widget _buildCanliIstatistikKarti({required String koleksiyon, required String filtreAlani, required String filtreDegeri, required String baslik, required IconData ikon, required Color renk}) {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection(koleksiyon).where('bayi_id', isEqualTo: widget.bayiId).where(filtreAlani, isEqualTo: filtreDegeri).snapshots(),
      builder: (context, snapshot) {
        String adet = "...";
        if (snapshot.hasData) adet = snapshot.data!.docs.length.toString();

        return Container(
          decoration: BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.circular(12), border: Border.all(color: renk.withOpacity(0.3))),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: Icon(ikon, color: renk, size: 32),
            title: Text(baslik, style: const TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 11)),
            trailing: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: renk.withOpacity(0.1), shape: BoxShape.circle),
              child: Text(adet, style: TextStyle(color: renk, fontWeight: FontWeight.w900, fontSize: 16)),
            ),
          ),
        );
      },
    );
  }
}