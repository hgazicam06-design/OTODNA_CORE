// lib/screens/arac_profil_ekrani.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

/// 🛡️ KUANTUM ARAÇ DNA PROFİLİ
/// Siber Göz'ün (QR Radar) bulduğu şase numarasını Matrix'te sorgular ve sicilini döker.
class AracProfilEkrani extends StatefulWidget {
  final String saseNo; // Radardan gelen kripto şase numarası

  const AracProfilEkrani({super.key, required this.saseNo});

  @override
  State<AracProfilEkrani> createState() => _AracProfilEkraniState();
}

class _AracProfilEkraniState extends State<AracProfilEkrani> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("SİBER SİCİL RAPORU", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
        ),
        body: StreamBuilder<DocumentSnapshot>(
          // 📡 MATRIX SORGUSU: Aracın ana kimlik dökümü
          stream: _db.collection('arac_kimlikleri').doc(widget.saseNo).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan, strokeWidth: 2));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return _buildKritikIhlalEkrani();
            }

            var aracData = snapshot.data!.data() as Map<String, dynamic>;

            // 🔥 GERÇEK VERİ ANALİZİ
            int dnaSkoru = (aracData['dna_skoru'] ?? 0).toInt();
            String muayeneDurumu = aracData['muayene_durumu'] ?? "BELİRSİZ";
            String plaka = (aracData['plaka'] ?? "PLAKA GİZLİ").toString().toUpperCase();
            String markaModel = (aracData['marka_model'] ?? "Bilinmeyen Kasa").toString().toUpperCase();

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. OTONOM DNA SKOR RADARI (Görsel İşçilik: Kuantum Halka)
                  _buildKuantumSkorRadari(dnaSkoru, muayeneDurumu),
                  const SizedBox(height: 32),

                  // 2. KİMLİK BİLGİLERİ (Siber Cam Kalkanı)
                  _buildBilgiKapsulu(aracData, plaka, markaModel),
                  const SizedBox(height: 32),

                  // 3. GEÇMİŞ İHLALLER VE BAKIMLAR (Canlı İstihbarat Akışı)
                  const Row(
                    children: [
                      Icon(Icons.history_edu_rounded, color: SiberTema.kuantumCyan, size: 18),
                      SizedBox(width: 10),
                      Text("SİBER BAKIM GEÇMİŞİ", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildGecmisIslemlerListesi(),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- 📡 SİBER BİLGİ KAPSÜLÜ ---
  Widget _buildBilgiKapsulu(Map<String, dynamic> data, String plaka, String markaModel) {
    return SiberTema.siberCamKalkan(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildSiberSatir("KAYITLI PLAKA", plaka, isBuyuk: true),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.white12, thickness: 1)),
          _buildSiberSatir("MARKA / MODEL", markaModel),
          _buildSiberSatir("KRİPTO ŞASE NO", widget.saseNo),
          _buildSiberSatir(
              "SON GÜNCELLEME",
              data['son_muayene_zaman_damgasi'] != null
                  ? (data['son_muayene_zaman_damgasi'] as Timestamp).toDate().toString().split('.')[0]
                  : "KAYIT YOK"
          ),
          _buildSiberSatir("TOPLAM KM", "${data['guncel_km'] ?? '---'} KM"),
        ],
      ),
    );
  }

  // --- 🔴 KRİTİK İHLAL EKRANI (VERİ YOKSA) ---
  Widget _buildKritikIhlalEkrani() {
    return Center(
      child: SiberTema.siberCamKalkan(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.gavel_rounded, color: SiberTema.kanKirmizi, size: 64),
            const SizedBox(height: 20),
            const Text("SİCİL KAYDI YOK!", style: TextStyle(color: SiberTema.kanKirmizi, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2)),
            const SizedBox(height: 12),
            Text(
              "Şase: ${widget.saseNo}\n\nBu araç henüz Kuantum Ağına entegre edilmemiş veya sahte şase girişi tespit edildi.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.6), height: 1.6, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // --- 🎡 KUANTUM SKOR RADARI ---
  Widget _buildKuantumSkorRadari(int skor, String durum) {
    Color skorRengi = skor >= 85 ? SiberTema.kuantumCyan : (skor >= 60 ? SiberTema.altinSari : SiberTema.kanKirmizi);

    return Stack(
      alignment: Alignment.center,
      children: [
        // Dış Işıma
        Container(
          width: 180, height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: skorRengi.withOpacity(0.15), blurRadius: 50, spreadRadius: 5)],
          ),
        ),
        // Ana Radar
        Container(
          width: 160, height: 160,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: SiberTema.oledBlack,
            border: Border.all(color: skorRengi.withOpacity(0.4), width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("$skor", style: TextStyle(color: skorRengi, fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -2)),
              const Text("DNA SKORU", style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: skorRengi.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: skorRengi.withOpacity(0.5))
                ),
                child: Text(durum.toUpperCase(), style: TextStyle(color: skorRengi, fontSize: 8, fontWeight: FontWeight.w900)),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSiberSatir(String etiket, String deger, {bool isBuyuk = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiket, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
          Flexible(
            child: Text(
                deger,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: isBuyuk ? SiberTema.kuantumCyan : Colors.white70,
                  fontSize: isBuyuk ? 16 : 12,
                  fontWeight: isBuyuk ? FontWeight.w900 : FontWeight.bold,
                  letterSpacing: isBuyuk ? 1 : 0,
                )
            ),
          ),
        ],
      ),
    );
  }

  // --- 🛠️ SİBER BAKIM GEÇMİŞİ LİSTESİ ---
  Widget _buildGecmisIslemlerListesi() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('arac_bakimlari')
          .where('sase_no', isEqualTo: widget.saseNo)
          .orderBy('olusturulma_zaman_damgasi', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox();

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12)
            ),
            child: const Column(
              children: [
                Icon(Icons.layers_clear_outlined, color: Colors.white12, size: 32),
                SizedBox(height: 12),
                Text("BU ARACA AİT GEÇMİŞ KAYIT BULUNAMADI", textAlign: TextAlign.center, style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var islem = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            bool tamamlandi = islem['durum'] == "TAMAMLANDI";
            Color durumRenk = tamamlandi ? SiberTema.kuantumCyan : SiberTema.altinSari;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SiberTema.matGrey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: durumRenk.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: durumRenk.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(tamamlandi ? Icons.verified_user_outlined : Icons.pending_outlined, color: durumRenk, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(islem['islem_adi'] ?? "GENEL KONTROL", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5)),
                        const SizedBox(height: 4),
                        Text(
                            "KM: ${islem['baslangic_km'] ?? '---'}  |  BAYİ: ${islem['bayi_isim'] ?? 'MERKEZ'}",
                            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.bold)
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.1), size: 14)
                ],
              ),
            );
          },
        );
      },
    );
  }
}