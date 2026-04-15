// lib/bayi/siber_servis_kabul_paneli.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

/// 🛡️ KUANTUM SERVİS KABUL VE CARİ TERMİNALİ
/// Dev butonların olmadığı, göz yormayan, tüm araçların ve cari işlemlerin tek ekranda aktığı kompakt komuta merkezi.
class SiberServisKabulPaneli extends StatefulWidget {
  const SiberServisKabulPaneli({super.key});

  @override
  State<SiberServisKabulPaneli> createState() => _SiberServisKabulPaneliState();
}

class _SiberServisKabulPaneliState extends State<SiberServisKabulPaneli> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _bayiId = FirebaseAuth.instance.currentUser?.uid ?? "BILINMEYEN_BAYI";
  final TextEditingController _aramaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("SERVİS KABUL VE CARİ İŞLEMLER",
              style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: _buildSiberAramaMotoru(),
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 12),
            _buildKompaktOzetMatrisi(),
            const SizedBox(height: 16),

            // ── LİSTE BAŞLIĞI ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("AKTİF İŞLEMLER VE İÇERİDEKİ ARAÇLAR", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  InkWell(
                    onTap: () {
                      developer.log("SİBER GEÇİŞ: Yeni Araç Kabul Motoru Tetiklendi.");
                      // Yeni araç kayıt modülüne yönlendir
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.add_box_outlined, color: SiberTema.kuantumCyan, size: 14),
                        SizedBox(width: 4),
                        Text("YENİ KABUL", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                ],
              ),
            ),

            // ── KOMPAKT ARAÇ/CARİ LİSTESİ ──
            Expanded(child: _buildKompaktIslemListesi()),
          ],
        ),
      ),
    );
  }

  // ── 🔍 SİBER ARAMA MOTORU (Devasa olmayan, zarif arama) ──
  Widget _buildSiberAramaMotoru() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: SizedBox(
        height: 40, // Göz yormayan ince tasarım
        child: TextField(
          controller: _aramaController,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            hintText: "Şase No, Plaka veya Müşteri Ara...",
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
            prefixIcon: const Icon(Icons.search, color: SiberTema.kuantumCyan, size: 18),
            filled: true,
            fillColor: SiberTema.matGrey.withOpacity(0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: SiberTema.kuantumCyan, width: 1)),
          ),
          onChanged: (value) => setState(() {}), // Arama tetikleyici
        ),
      ),
    );
  }

  // ── 📊 KOMPAKT ÖZET MATRİSİ (Her şey ortada) ──
  Widget _buildKompaktOzetMatrisi() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildMiniKapsul("İÇERİDEKİ ARAÇ", "12", SiberTema.kuantumCyan),
          const SizedBox(width: 12),
          _buildMiniKapsul("BEKLEYEN TAHSİLAT", "₺4.500", Colors.amberAccent),
          const SizedBox(width: 12),
          _buildMiniKapsul("BUGÜN BİTEN", "3", Colors.white54),
        ],
      ),
    );
  }

  Widget _buildMiniKapsul(String baslik, String deger, Color renk) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: SiberTema.matGrey,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: const TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(deger, style: TextStyle(color: renk, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
          ],
        ),
      ),
    );
  }

  // ── 🏎️ İÇERİDEKİ ARAÇLAR LİSTESİ (Yoğun Veri, Temiz Görünüm) ──
  Widget _buildKompaktIslemListesi() {
    // SİBER NOT: Canlı Firebase entegrasyonu buraya bağlanacak.
    // Şimdilik kompakt arayüz mimarisini mühürlüyoruz.
    final List<Map<String, dynamic>> mockIslemler = [
      {"plaka": "06 ABC 123", "musteri": "Ahmet Yılmaz", "durum": "LİFTTE", "tutar": "₺1.200", "renk": Colors.amberAccent},
      {"plaka": "34 XYZ 987", "musteri": "Gazi Auto", "durum": "PARÇA BEKLİYOR", "tutar": "₺0", "renk": Colors.redAccent},
      {"plaka": "06 KNT 001", "musteri": "Murat Plaza", "durum": "TESLİME HAZIR", "tutar": "₺4.500", "renk": SiberTema.kuantumCyan},
      {"plaka": "35 SBR 99", "musteri": "Mehmet Demir", "durum": "LİFTTE", "tutar": "₺850", "renk": Colors.amberAccent},
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      physics: const BouncingScrollPhysics(),
      itemCount: mockIslemler.length,
      separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
      itemBuilder: (context, index) {
        var islem = mockIslemler[index];
        return InkWell(
          onTap: () {
            developer.log("SİBER BİLGİ: ${islem['plaka']} detayına girildi.");
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                // Durum Rengi İndikatörü (Sol ince çizgi)
                Container(width: 3, height: 32, decoration: BoxDecoration(color: islem['renk'], borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 12),

                // Araç ve Müşteri
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(islem['plaka'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
                      const SizedBox(height: 2),
                      Text(islem['musteri'], style: const TextStyle(color: Colors.white54, fontSize: 10)),
                    ],
                  ),
                ),

                // Durum Etiketi
                Expanded(
                  flex: 3,
                  child: Text(islem['durum'], style: TextStyle(color: islem['renk'], fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),

                // Tutar ve İkon
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(islem['tutar'], style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, color: Colors.white24, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}