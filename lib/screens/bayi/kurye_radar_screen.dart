// lib/screens/bayi/kurye_radar_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import 'dart:math' as math;

// 🚀 KARARGAH ZIRHLARI VE MERKEZİ TEMA
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

/// 🛡️ KUANTUM LOJİSTİK VE KURYE RADARI
/// Ustanın sipariş ettiği parçayı getiren kuryeyi canlı olarak izlediği siber terminal.
class KuryeRadarScreen extends StatefulWidget {
  final String siparisId; // İzlenecek lojistik operasyonunun kimliği

  const KuryeRadarScreen({super.key, required this.siparisId});

  @override
  State<KuryeRadarScreen> createState() => _KuryeRadarScreenState();
}

class _KuryeRadarScreenState extends State<KuryeRadarScreen> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    // 🛰️ Siber Radar Dönüş Animasyonu
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
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
          title: const Text("SİBER LOJİSTİK RADARI", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: SiberTema.kuantumCyan),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          // 📡 GERÇEK ZAMANLI GPS DİNLEMESİ (Kurye verileri canlı akar)
          stream: _db.collection('lojistik_radari').doc(widget.siparisId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return _buildKayıpSinyalEkrani();
            }

            var lojistikVerisi = snapshot.data!.data() as Map<String, dynamic>;

            String kuryeAdi = lojistikVerisi['kurye_adi'] ?? "Bilinmeyen Kurye";
            String plaka = lojistikVerisi['plaka'] ?? "00 XXX 000";
            int kalanSureDk = (lojistikVerisi['kalan_sure_dk'] ?? 0).toInt();
            double kalanMesafeKm = (lojistikVerisi['kalan_mesafe_km'] ?? 0.0).toDouble();
            String durum = lojistikVerisi['durum'] ?? "YOLDA"; // HAZIRLANIYOR, YOLDA, TESLİM EDİLDİ

            bool teslimEdildi = durum == "TESLİM EDİLDİ";

            return SafeArea(
              child: Column(
                children: [
                  // 🚁 SİBER RADAR EKRANI
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Radar Arka Plan Halkaları
                          Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.1), width: 1))),
                          Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.2), width: 1))),

                          // Radar Dönüş Animasyonu
                          if (!teslimEdildi)
                            AnimatedBuilder(
                              animation: _radarController,
                              builder: (_, child) {
                                return Transform.rotate(
                                  angle: _radarController.value * 2 * math.pi,
                                  child: Container(
                                    width: 250,
                                    height: 250,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: SweepGradient(
                                        colors: [Colors.transparent, SiberTema.kuantumCyan.withOpacity(0.5)],
                                        stops: const [0.5, 1.0],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                          // Merkez Kurye İkonu
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: teslimEdildi ? SiberTema.kuantumCyan : SiberTema.oledBlack,
                              shape: BoxShape.circle,
                              border: Border.all(color: SiberTema.kuantumCyan, width: 2),
                              boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.5), blurRadius: 20, spreadRadius: 2)],
                            ),
                            child: Icon(
                              teslimEdildi ? Icons.check_circle : Icons.two_wheeler,
                              color: teslimEdildi ? SiberTema.oledBlack : SiberTema.kuantumCyan,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ⏱️ ZAMAN VE MESAFE PANELİ
                  if (!teslimEdildi)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildRadarBilgi("KALAN SÜRE", "$kalanSureDk DK", Icons.timer_outlined),
                          Container(width: 2, height: 40, color: SiberTema.textMuted),
                          _buildRadarBilgi("MESAFE", "${kalanMesafeKm.toStringAsFixed(1)} KM", Icons.route_outlined),
                        ],
                      ),
                    ),

                  const SizedBox(height: 30),

                  // 🏍️ KURYE BİLGİ KARTI (Siber Cam)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: SiberTema.matGrey.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: teslimEdildi ? SiberTema.kuantumCyan : Colors.white12, width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.person_pin, color: SiberTema.kuantumCyan, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(kuryeAdi, style: const TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
                                  const SizedBox(height: 4),
                                  Text("PLAKA: $plaka", style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                                ],
                              ),
                            ),
                            // İLETİŞİM BUTONU
                            if (!teslimEdildi)
                              IconButton(
                                onPressed: () {
                                  // SİBER NOT: Burada url_launcher ile kurye aranabilir.
                                  developer.log("📞 KIZIL HAT: Kurye aranıyor...");
                                },
                                icon: const Icon(Icons.phone_in_talk, color: SiberTema.kuantumCyan),
                                style: IconButton.styleFrom(backgroundColor: SiberTema.kuantumCyan.withOpacity(0.1)),
                              )
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(color: SiberTema.textMuted),
                        const SizedBox(height: 16),

                        // DURUM ÇUBUĞU
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.info_outline, color: SiberTema.textMuted, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              teslimEdildi ? "OPERASYON TAMAMLANDI" : "HEDEF BÖLGEYE İLERLİYOR...",
                              style: TextStyle(color: teslimEdildi ? SiberTema.kuantumCyan : Colors.white70, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── 🔧 ARAYÜZ YARDIMCILARI ──
  Widget _buildRadarBilgi(String baslik, String deger, IconData ikon) {
    return Column(
      children: [
        Icon(ikon, color: SiberTema.textMuted, size: 24),
        const SizedBox(height: 8),
        Text(deger, style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(baslik, style: const TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
      ],
    );
  }

  Widget _buildKayıpSinyalEkrani() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.satellite_alt_outlined, color: SiberTema.kanKirmizi, size: 60),
          const SizedBox(height: 16),
          const Text("SİNYAL KAYBI", style: TextStyle(color: SiberTema.kanKirmizi, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2)),
          const SizedBox(height: 8),
          Text("Lojistik radarına ulaşılamıyor veya sipariş tamamlanmış olabilir.", textAlign: TextAlign.center, style: TextStyle(color: SiberTema.textMain.withOpacity(0.5), fontSize: 12)),
        ],
      ),
    );
  }
}