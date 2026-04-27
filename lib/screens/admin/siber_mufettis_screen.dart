import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';
import '../../models/dukkan_model.dart';

/// 👁️ SİBER MÜFETTİŞ KARARGAHI (YAPAY ZEKA RİSK PANELİ)
/// Ana Distribütörün (Admin) ağdaki tüm esnafların AI Risk Skorlarını izlediği
/// ve gerektiğinde "Siber Kilit" (Ban) vurduğu kokpit.
class SiberMufettisScreen extends StatefulWidget {
  const SiberMufettisScreen({super.key});

  @override
  State<SiberMufettisScreen> createState() => _SiberMufettisScreenState();
}

class _SiberMufettisScreenState extends State<SiberMufettisScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _islemSuruyor = false;

  // SİBER İSTİHBARAT: Mock Esnaf Listesi (Gerçekte Firestore'dan Dukkan.fromFirestore ile çekilecek)
  final List<Dukkan> _istihbaratListesi = [
    Dukkan(
      id: "shop_1",
      ad: "Murat Auto Performans",
      countryId: "Türkiye", regionId: "Marmara", cityId: "İstanbul", districtId: "Maslak",
      aiRiskSkoru: 12.5,
      siberIhlalDurumu: false,
      evrakOnayDurumu: "onaylandi",
      puan: 4.8,
    ),
    Dukkan(
      id: "shop_2",
      ad: "Korsan Garaj (Şüpheli)",
      countryId: "Türkiye", regionId: "Marmara", cityId: "İstanbul", districtId: "Bağcılar",
      aiRiskSkoru: 85.0, // RİSKLİ!
      siberIhlalDurumu: true,
      evrakOnayDurumu: "bekliyor",
      puan: 2.1,
    ),
    Dukkan(
      id: "shop_3",
      ad: "Vip Elektronik",
      countryId: "Türkiye", regionId: "Ege", cityId: "İzmir", districtId: "Bornova",
      aiRiskSkoru: 45.0, // ORTA RİSK
      siberIhlalDurumu: false,
      evrakOnayDurumu: "onaylandi",
      puan: 4.0,
    ),
  ];

  void _siberUyari(String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: TextStyle(color: renk, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
      backgroundColor: Colors.black87,
      shape: RoundedRectangleBorder(side: BorderSide(color: renk), borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ── SİBER KİLİT (ESNAFI BANLAMA) İŞLEMİ ──
  Future<void> _siberKilitVur(int index) async {
    setState(() => _islemSuruyor = true);
    HapticFeedback.heavyImpact();

    // SİBER SİMÜLASYON
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _istihbaratListesi.removeAt(index);
      _islemSuruyor = false;
    });

    _siberUyari("SİBER KİLİT AKTİF: İşletme Kuantum Ağından tamamen silindi!", SiberTema.kanKirmizi);
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.8),
          elevation: 0,
          title: const Text("👁️ SİBER MÜFETTİŞ (AI)", style: TextStyle(color: SiberTema.kanKirmizi, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
          centerTitle: true,
          iconTheme: const IconThemeData(color: SiberTema.kanKirmizi),
          actions: [
            IconButton(
              icon: const Icon(Icons.radar, color: SiberTema.kanKirmizi),
              onPressed: () => _siberUyari("Yapay Zeka Taraması Yenileniyor...", SiberTema.kuantumCyan),
            )
          ],
        ),
        body: Column(
          children: [
            // ── AI GENEL DURUM ÖZETİ ──
            _buildSiberRadarPaneli(),

            // ── RİSKLİ ESNAF LİSTESİ ──
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                itemCount: _istihbaratListesi.length,
                itemBuilder: (context, index) {
                  final dukkan = _istihbaratListesi[index];
                  return _buildMufettisKarti(dukkan, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSiberRadarPaneli() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: SiberTema.kanKirmizi, width: 2)),
      ),
      child: Column(
        children: [
          Icon(Icons.policy_rounded, color: SiberTema.kanKirmizi.withOpacity(0.8), size: 48),
          const SizedBox(height: 16),
          const Text("KUANTUM İSTİHBARAT AĞI", style: TextStyle(color: SiberTema.textMuted, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 8),
          const Text("3 AKTİF İZLEME", style: TextStyle(color: SiberTema.textMain, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMiniBilgi("Yüksek Risk", "1 Adet", SiberTema.kanKirmizi),
              const SizedBox(width: 24),
              _buildMiniBilgi("Güvenli", "2 Adet", SiberTema.kuantumCyan),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMiniBilgi(String baslik, String deger, Color renk) {
    return Column(
      children: [
        Text(baslik, style: TextStyle(color: renk, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: renk.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Text(deger, style: TextStyle(color: renk, fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildMufettisKarti(Dukkan dukkan, int index) {
    // Risk Skoru Renklendirmesi
    Color riskRengi;
    if (dukkan.aiRiskSkoru >= 80) {
      riskRengi = SiberTema.kanKirmizi;
    } else if (dukkan.aiRiskSkoru >= 40) {
      riskRengi = Colors.orangeAccent;
    } else {
      riskRengi = SiberTema.kuantumCyan;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: SiberTema.matGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: riskRengi.withOpacity(0.5), width: dukkan.aiRiskSkoru >= 80 ? 2.0 : 1.0),
        boxShadow: dukkan.aiRiskSkoru >= 80 ? [BoxShadow(color: SiberTema.kanKirmizi.withOpacity(0.1), blurRadius: 20)] : [],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // RİSK DAİRESİ
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 60, height: 60,
                      child: CircularProgressIndicator(
                        value: dukkan.aiRiskSkoru / 100,
                        backgroundColor: Colors.white12,
                        color: riskRengi,
                        strokeWidth: 6,
                      ),
                    ),
                    Text("%${dukkan.aiRiskSkoru.toInt()}", style: TextStyle(color: riskRengi, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const SizedBox(width: 20),
                
                // ESNAF BİLGİLERİ
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dukkan.ad, style: const TextStyle(color: SiberTema.textMain, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      const SizedBox(height: 4),
                      Text("📍 ${dukkan.cityId} / ${dukkan.districtId}", style: const TextStyle(color: SiberTema.textMuted, fontSize: 11)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, color: SiberTema.sariAltin, size: 14),
                          const SizedBox(width: 4),
                          Text("${dukkan.puan} Puan", style: const TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 12),
                          Icon(dukkan.evrakOnayDurumu == "onaylandi" ? Icons.verified : Icons.pending, color: dukkan.evrakOnayDurumu == "onaylandi" ? SiberTema.kuantumCyan : Colors.orange, size: 14),
                          const SizedBox(width: 4),
                          Text(dukkan.evrakOnayDurumu.toUpperCase(), style: const TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          
          // AKSİYON BUTONLARI
          if (dukkan.aiRiskSkoru >= 80)
            Container(
              width: double.infinity,
              height: 48,
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: SiberTema.textMuted)),
              ),
              child: InkWell(
                onTap: _islemSuruyor ? null : () => _siberKilitVur(index),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                child: Center(
                  child: _islemSuruyor 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: SiberTema.kanKirmizi, strokeWidth: 2))
                    : const Text("🚨 SİBER KİLİT VUR (AĞDAN AT)", style: TextStyle(color: SiberTema.kanKirmizi, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
