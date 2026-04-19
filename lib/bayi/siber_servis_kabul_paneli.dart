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

  String _aramaMetni = "";

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("SERVİS KABUL VE CARİ İŞLEMLER",
              style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13, fontFamily: 'Avenir')),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: SiberTema.kuantumCyan),
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
                  const Text("AKTİF İŞLEMLER VE İÇERİDEKİ ARAÇLAR", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
                  InkWell(
                    onTap: () {
                      developer.log("SİBER GEÇİŞ: Yeni Araç Kabul Motoru Tetiklendi.");
                      // Yeni araç kayıt modülüne yönlendir (Navigator.push eklenebilir)
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.add_box_outlined, color: SiberTema.kuantumCyan, size: 14),
                        SizedBox(width: 4),
                        Text("YENİ KABUL", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                      ],
                    ),
                  )
                ],
              ),
            ),

            // ── GERÇEK FİREBASE CANLI LİSTESİ ──
            Expanded(child: _buildGercekCanliIslemListesi()),
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
          style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Avenir'),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            hintText: "Şase No, Plaka veya Müşteri Ara...",
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 12, fontFamily: 'Avenir'),
            prefixIcon: const Icon(Icons.search, color: SiberTema.kuantumCyan, size: 18),
            filled: true,
            fillColor: SiberTema.matGrey.withOpacity(0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: SiberTema.kuantumCyan, width: 1)),
          ),
          onChanged: (value) {
            setState(() {
              _aramaMetni = value.toUpperCase(); // Aramayı büyük harfe zorla (Firebase optimizasyonu)
            });
          },
        ),
      ),
    );
  }

  // ── 📊 KOMPAKT ÖZET MATRİSİ (Canlı Verilerle) ──
  Widget _buildKompaktOzetMatrisi() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('servis_kayitlari').where('bayi_id', isEqualTo: _bayiId).snapshots(),
      builder: (context, snapshot) {
        int iceridekiArac = 0;
        double bekleyenTahsilat = 0.0;
        int bugunBiten = 0;

        if (snapshot.hasData) {
          DateTime now = DateTime.now();
          DateTime bugunBaslangic = DateTime(now.year, now.month, now.day);

          for (var doc in snapshot.data!.docs) {
            var data = doc.data() as Map<String, dynamic>;
            String durum = data['durum'] ?? 'BEKLIYOR';
            double tutar = (data['toplam_tutar'] ?? 0.0).toDouble();
            Timestamp? islemTarihi = data['tarih'] as Timestamp?;

            if (durum != 'TAMAMLANDI') {
              iceridekiArac++;
              bekleyenTahsilat += tutar;
            } else if (islemTarihi != null && islemTarihi.toDate().isAfter(bugunBaslangic)) {
              bugunBiten++;
            }
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _buildMiniKapsul("İÇERİDEKİ ARAÇ", iceridekiArac.toString(), SiberTema.kuantumCyan),
              const SizedBox(width: 12),
              _buildMiniKapsul("BEKLEYEN TAHSİLAT", "₺${bekleyenTahsilat.toStringAsFixed(0)}", SiberTema.altinSari),
              const SizedBox(width: 12),
              _buildMiniKapsul("BUGÜN BİTEN", bugunBiten.toString(), Colors.white54),
            ],
          ),
        );
      },
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
            Text(baslik, style: const TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5, fontFamily: 'Avenir'), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(deger, style: TextStyle(color: renk, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
          ],
        ),
      ),
    );
  }

  // ── 🏎️ İÇERİDEKİ ARAÇLAR LİSTESİ (MAKET YOK - GERÇEK FİREBASE DİNLEME) ──
  Widget _buildGercekCanliIslemListesi() {
    return StreamBuilder<QuerySnapshot>(
      // 🛡️ SİBER DÜZELTME: Sadece bu bayinin araçlarını getirir ve tarihe göre sıralar
      stream: _db.collection('servis_kayitlari')
          .where('bayi_id', isEqualTo: _bayiId)
          .orderBy('tarih', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("SİSTEMDE ARAÇ BULUNMUYOR", style: TextStyle(color: Colors.white24, letterSpacing: 2, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
          );
        }

        // Siber Arama Filtresi Uygulama (Plaka veya Müşteriye Göre)
        var filtrelenmisDocs = snapshot.data!.docs.where((doc) {
          if (_aramaMetni.isEmpty) return true;
          var data = doc.data() as Map<String, dynamic>;
          String plaka = (data['plaka'] ?? '').toString().toUpperCase();
          // NOT: Müşteri adı veritabanında varsa o da buraya eklenebilir. Şu an plaka üzerinden arama yapar.
          return plaka.contains(_aramaMetni);
        }).toList();

        if (filtrelenmisDocs.isEmpty) {
          return const Center(
            child: Text("ARANAN KRİTERDE ARAÇ YOK", style: TextStyle(color: Colors.white24, letterSpacing: 2, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          physics: const BouncingScrollPhysics(),
          itemCount: filtrelenmisDocs.length,
          separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
          itemBuilder: (context, index) {
            var islem = filtrelenmisDocs[index].data() as Map<String, dynamic>;

            String plaka = islem['plaka'] ?? "PLAKA YOK";
            String durum = islem['durum'] ?? "BEKLIYOR";
            double tutar = (islem['toplam_tutar'] ?? 0.0).toDouble();

            // SİBER RENK MOTORU: Duruma göre otonom renk ataması
            Color durumRengi = _durumRengiBelirle(durum);

            return InkWell(
              onTap: () {
                developer.log("SİBER BİLGİ: $plaka detayına girildi. (Firebase ID: ${filtrelenmisDocs[index].id})");
                // Detay sayfasına yönlendirme eklenebilir
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    // Durum Rengi İndikatörü (Sol ince çizgi)
                    Container(width: 3, height: 32, decoration: BoxDecoration(color: durumRengi, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 12),

                    // Araç ve Bakım Tipi
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(plaka, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1, fontFamily: 'Avenir')),
                          const SizedBox(height: 2),
                          Text(islem['bakim_tipi'] ?? "GENEL ONARIM", style: const TextStyle(color: Colors.white54, fontSize: 10, fontFamily: 'Avenir'), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),

                    // Durum Etiketi
                    Expanded(
                      flex: 3,
                      child: Text(durum, style: TextStyle(color: durumRengi, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                    ),

                    // Tutar ve İkon
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("₺${tutar.toStringAsFixed(0)}", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
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
      },
    );
  }

  // Duruma göre otonom renk veren yardımcı fonksiyon
  Color _durumRengiBelirle(String durum) {
    switch (durum.toUpperCase()) {
      case 'TAMAMLANDI':
        return SiberTema.kuantumCyan;
      case 'LİFTTE':
      case 'BEKLIYOR':
        return SiberTema.altinSari;
      case 'PARÇA BEKLİYOR':
      case 'IPTAL':
        return SiberTema.kritikRed;
      default:
        return Colors.white54;
    }
  }
}