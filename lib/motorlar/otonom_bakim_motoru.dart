// lib/motorlar/otonom_bakim_motoru.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

/// 🛡️ KUANTUM TAHMİN VE BAKIM MOTORU
/// Aracın KM artış hızını hesaplar, Triger (Kayış/Zincir) tipini ayırır ve OtoDNA satış reklamlarını tetikler.
class OtonomBakimMotoru extends StatefulWidget {
  final String saseNo;

  const OtonomBakimMotoru({super.key, required this.saseNo});

  @override
  State<OtonomBakimMotoru> createState() => _OtonomBakimMotoruState();
}

class _OtonomBakimMotoruState extends State<OtonomBakimMotoru> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── SİBER SİMÜLASYON VERİLERİ (Gerçekte Fabrika API'sinden çekilecek) ──
  int _guncelKm = 85000;
  int _aylikOrtalamaKm = 1500;
  String _motorTipi = "KAYIŞ"; // VEYA "ZİNCİR"
  int _son10kBakimKm = 82000;
  int _son50kBakimKm = 48000;

  @override
  Widget build(BuildContext context) {
    // 🧠 YAPAY ZEKA HESAPLAMALARI
    int siradaki10k = _son10kBakimKm + 10000;
    int kalanKm10k = siradaki10k - _guncelKm;
    int tahminiGun10k = (kalanKm10k / (_aylikOrtalamaKm / 30)).round();

    int siradaki50k = _son50kBakimKm + 50000;
    int kalanKm50k = siradaki50k - _guncelKm;

    // Triger Kuralı (Kayış 60k-80k / Zincir 120k-150k)
    int trigerOmru = _motorTipi == "KAYIŞ" ? 80000 : 150000;
    int kalanTrigerKm = trigerOmru - (_guncelKm % trigerOmru);

    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("KUANTUM BAKIM RADARI", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 13)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          children: [
            // ── 🏎️ ARAÇ DNA ÖZETİ ──
            _buildAracDnaPaneli(),
            const SizedBox(height: 24),

            // ── ⏱️ OTONOM TAHMİN MATRİSİ ──
            const Text("YAPAY ZEKA TAHMİN MATRİSİ", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
            const SizedBox(height: 12),
            _buildTahminKarti("10.000 KM PERİYODİK BAKIM", "Tahmini Süre: $tahminiGun10k Gün Sonra", kalanKm10k, 10000, SiberTema.kuantumCyan),
            const SizedBox(height: 12),
            _buildTahminKarti("50.000 KM AĞIR BAKIM", "Büyük Bakıma Doğru", kalanKm50k, 50000, Colors.amberAccent),
            const SizedBox(height: 12),
            _buildTahminKarti("TRİGER KONTROLÜ (${_motorTipi})", _motorTipi == "KAYIŞ" ? "Kopma Riski Yaklaşıyor!" : "Zincir Sesi Kontrolü", kalanTrigerKm, trigerOmru, SiberTema.kanKirmizi),

            const SizedBox(height: 32),

            // ── 💰 OTODNA REKLAM VE TEDARİK AĞI (Para Kazanma Noktamız) ──
            if (tahminiGun10k <= 30) // Bakıma 1 ay kala reklamı bas!
              _buildSponsorluUrunKarti(),
          ],
        ),
      ),
    );
  }

  // ── 🔧 ARAÇ DNA BİLGİ KAPSÜLÜ ──
  Widget _buildAracDnaPaneli() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: SiberTema.siberCamZirh(renk: SiberTema.matGrey),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("GÜNCEL KİLOMETRE", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
              Text("$_guncelKm KM", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
            ],
          ),
          const Divider(color: Colors.white10, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("AYLIK ORTALAMA KULLANIM", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
              Text("$_aylikOrtalamaKm KM / AY", style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // ── ⏱️ TAHMİN KARTI ──
  Widget _buildTahminKarti(String baslik, String altBaslik, int kalanKm, int toplamKm, Color renk) {
    double yuzde = 1.0 - (kalanKm / toplamKm);
    if (yuzde > 1.0) yuzde = 1.0;
    if (yuzde < 0) yuzde = 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(baslik, style: TextStyle(color: renk, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
              Text("$kalanKm KM KALDI", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
            ],
          ),
          const SizedBox(height: 4),
          Text(altBaslik, style: const TextStyle(color: Colors.white38, fontSize: 10)),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: yuzde, backgroundColor: Colors.white10, color: renk, minHeight: 6, borderRadius: BorderRadius.circular(3)),
        ],
      ),
    );
  }

  // ── 💰 OTODNA TEDARİK & REKLAM (GERÇEK GELİR MODELİ) ──
  Widget _buildSponsorluUrunKarti() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SiberTema.kuantumCyan.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: SiberTema.kuantumCyan, size: 16),
              const SizedBox(width: 8),
              const Text("YAKLAŞAN BAKIMINIZ İÇİN OTODNA TAVSİYESİ", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 12),
          const Text("Castrol EDGE 5W-30 Tam Sentetik Motor Yağı", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text("Fabrika standartlarına %100 uygun. Karargah onaylı tedarikçi.", style: TextStyle(color: Colors.white54, fontSize: 10)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: SiberTema.kuantumButonStili(),
              onPressed: () {
                developer.log("SİBER SATIŞ: Castrol yağ satışı tetiklendi. OtoDNA %12 komisyonu kazandı.");
                // Burada doğrudan satış modülüne gider.
              },
              child: const Text("SİSTEM ÜZERİNDEN SİPARİŞ VER (₺1.250)", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
            ),
          )
        ],
      ),
    );
  }
}