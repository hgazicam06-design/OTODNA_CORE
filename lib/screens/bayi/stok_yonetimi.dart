// lib/screens/bayi/stok_yonetimi.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI VE MERKEZİ TEMA BAĞLANTISI (2 Kat Yukarı)
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

/// 🛡️ KUANTUM STOK VE ENVANTER RADARI (SiberStokPaneli)
/// Bayinin envanterini canlı izler, kritik seviyeleri uyarır ve barkodla otonom satış yapar.
class SiberStokPaneli extends StatefulWidget {
  final String bayiId; // Stoku izlenen bayinin Karargah kimliği

  const SiberStokPaneli({super.key, required this.bayiId});

  @override
  State<SiberStokPaneli> createState() => _SiberStokPaneliState();
}

class _SiberStokPaneliState extends State<SiberStokPaneli> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 🚀 BARKOD İLE STOKTAN DÜŞME MOTORU ──
  void _barkodTarayiciAc(BuildContext context) {
    HapticFeedback.heavyImpact();
    developer.log("📡 SİBER TARAMA: Kamera radarı başlatılıyor...");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _SiberStokTarayiciEkrani(bayiId: widget.bayiId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent, // Kalkan aydınlatması arkadan vurur
        appBar: AppBar(
          title: const Text("ENVANTER VE STOK RADARI", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: SiberTema.kuantumCyan),
        ),
        body: StreamBuilder<QuerySnapshot>(
          // 📡 SİBER NOT: Bayinin stokları Karargahtan canlı dinleniyor!
          stream: _db.collection('bayi_stoklari').where('bayi_id', isEqualTo: widget.bayiId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
            }

            List<DocumentSnapshot> stokListesi = snapshot.hasData ? snapshot.data!.docs : [];

            // 🧠 Otonom Özet Hesaplamaları
            int toplamCesit = stokListesi.length;
            int kritikUrunSayisi = 0;
            double toplamDeger = 0.0;

            for (var doc in stokListesi) {
              var veri = doc.data() as Map<String, dynamic>;
              int adet = (veri['adet'] ?? 0).toInt();
              int kritikSinir = (veri['kritik_seviye'] ?? 5).toInt();
              double fiyat = (veri['fiyat'] ?? 0.0).toDouble();

              if (adet <= kritikSinir) kritikUrunSayisi++;
              toplamDeger += (adet * fiyat);
            }

            return Column(
              children: [
                // 📊 SİBER ÖZET PANELİ
                _buildSiberOzetPaneli(toplamCesit, kritikUrunSayisi, toplamDeger),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(color: SiberTema.textMuted, height: 1),
                ),

                // 📦 STOK LİSTESİ
                if (stokListesi.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text("SİBER ONAY: Envanterde ürün bulunmuyor.", style: TextStyle(color: SiberTema.textMuted, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: stokListesi.length,
                      itemBuilder: (context, index) {
                        var urunVerisi = stokListesi[index].data() as Map<String, dynamic>;
                        return _buildSiberUrunKarti(urunVerisi);
                      },
                    ),
                  ),

                // 🚀 ATEŞLEME BUTONU (Barkod Oku)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 60,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _barkodTarayiciAc(context),
                      icon: const Icon(Icons.qr_code_scanner, color: SiberTema.oledBlack, size: 24),
                      label: const Text("SİBER BARKOD OKU VE DÜŞ", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13, color: SiberTema.oledBlack)),
                      style: SiberTema.kuantumButonStili(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── 🛡️ ARAYÜZ MOTORLARI ──

  Widget _buildSiberOzetPaneli(int cesit, int kritik, double deger) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: SiberTema.matGrey.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SiberTema.textMuted),
          boxShadow: [
            BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.05), blurRadius: 15, spreadRadius: 1)
          ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildOzetKart("STOK ÇEŞİDİ", "$cesit", Colors.white),
          _buildOzetKart("KRİTİK ALARM", "$kritik", SiberTema.kanKirmizi),
          _buildOzetKart("ENVANTER DEĞERİ", "₺${deger.toStringAsFixed(0)}", SiberTema.kuantumCyan),
        ],
      ),
    );
  }

  Widget _buildOzetKart(String baslik, String deger, Color renk) {
    return Column(
      children: [
        Text(baslik, style: const TextStyle(fontSize: 9, color: SiberTema.textMuted, fontWeight: FontWeight.w900, letterSpacing: 1)),
        const SizedBox(height: 8),
        Text(deger, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: renk, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildSiberUrunKarti(Map<String, dynamic> urun) {
    int adet = (urun['adet'] ?? 0).toInt();
    int kritikSinir = (urun['kritik_seviye'] ?? 5).toInt();
    double fiyat = (urun['fiyat'] ?? 0.0).toDouble();
    bool kritikDurum = adet <= kritikSinir;

    Color kartRengi = kritikDurum ? SiberTema.kanKirmizi : SiberTema.kuantumCyan;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kritikDurum ? SiberTema.kanKirmizi.withOpacity(0.05) : SiberTema.matGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kartRengi.withOpacity(0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: kartRengi.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(kritikDurum ? Icons.warning_amber_rounded : Icons.inventory_2_outlined, color: kartRengi),
        ),
        title: Text(urun['urun_adi'] ?? "Bilinmeyen Ürün", style: const TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text("Stokta: $adet Adet (Sınır: $kritikSinir)", style: TextStyle(color: kritikDurum ? SiberTema.kanKirmizi : Colors.white70, fontSize: 11, fontWeight: kritikDurum ? FontWeight.w900 : FontWeight.bold)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("₺${fiyat.toStringAsFixed(2)}", style: const TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, fontSize: 14)),
            if (kritikDurum) ...[
              const SizedBox(height: 4),
              const Text("STOK ALARMI!", style: TextStyle(color: SiberTema.kanKirmizi, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ]
          ],
        ),
      ),
    );
  }
}

// ── 📸 GİZLİ SİBER TARAYICI EKRANI (Barkod Okuyucu) ──
class _SiberStokTarayiciEkrani extends StatefulWidget {
  final String bayiId;

  const _SiberStokTarayiciEkrani({required this.bayiId});

  @override
  State<_SiberStokTarayiciEkrani> createState() => _SiberStokTarayiciEkraniState();
}

class _SiberStokTarayiciEkraniState extends State<_SiberStokTarayiciEkrani> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _islemSuruyor = false;

  Future<void> _stoktanDus(String okunanBarkod) async {
    if (_islemSuruyor) return;
    setState(() => _islemSuruyor = true);
    HapticFeedback.heavyImpact();

    developer.log("📡 SİBER ONAY: $okunanBarkod kodlu ürün stoktan düşürülüyor...");

    try {
      // 1. Barkoda ait ürünü Karargah veritabanında bul
      QuerySnapshot urunSorgusu = await _db.collection('bayi_stoklari')
          .where('bayi_id', isEqualTo: widget.bayiId)
          .where('barkod', isEqualTo: okunanBarkod)
          .limit(1)
          .get();

      if (urunSorgusu.docs.isEmpty) {
        throw Exception("Bu barkoda ait ürün Karargah envanterinde bulunamadı!");
      }

      DocumentSnapshot urunDoc = urunSorgusu.docs.first;
      int mevcutAdet = (urunDoc['adet'] ?? 0).toInt();

      if (mevcutAdet <= 0) {
        throw Exception("STOK TÜKENDİ: Bu üründen envanterde kalmadı!");
      }

      // 2. Ürünün adetini 1 eksilt (Otonom düşüm - Atomik)
      // 🛡️ ZIRH: Aynı anda okutulsa bile eksiye düşmez
      WriteBatch batch = _db.batch();

      DocumentReference urunRef = _db.collection('bayi_stoklari').doc(urunDoc.id);
      batch.update(urunRef, {
        'adet': FieldValue.increment(-1),
        'son_satis_tarihi': FieldValue.serverTimestamp(),
      });

      // 3. İstihbarat Kara Kutusuna Mühürle
      DocumentReference logRef = _db.collection('siber_istihbarat_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'STOK_DUSUM_MUHURU',
        'seviye': 'BİLGİ',
        'islem_detayi': 'SİBER BARKOD: Bayi (${widget.bayiId}), "$okunanBarkod" barkodlu ürünü stoktan düştü.',
        'bayi_id': widget.bayiId,
        'vaka_id': okunanBarkod,
        'urun_id': urunDoc.id,
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      HapticFeedback.vibrate();
      developer.log("✅ İŞLEM ONAYLANDI: Ürün stoktan başarıyla düşüldü.");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("SİBER ONAY: Ürün stoktan düşüldü.", style: TextStyle(fontWeight: FontWeight.bold, color: SiberTema.oledBlack)), backgroundColor: SiberTema.kuantumCyan));
        Navigator.pop(context); // Tarayıcıyı kapat
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      developer.log("🚨 AĞ ÇÖKTÜ: Stok düşülemedi!", error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll("Exception:", "").trim(), style: const TextStyle(fontWeight: FontWeight.bold, color: SiberTema.textMain)), backgroundColor: SiberTema.kanKirmizi));
        setState(() => _islemSuruyor = false); // Hata varsa tekrar okumaya izin ver
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("SİBER SATIŞ RADARI", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13)),
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: SiberTema.kuantumCyan),
        ),
        body: Stack(
          children: [
            MobileScanner(
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null && !_islemSuruyor) {
                    _stoktanDus(barcode.rawValue!);
                    break;
                  }
                }
              },
            ),
            if (_islemSuruyor)
              Container(
                color: SiberTema.oledBlack.withOpacity(0.85), // Tarayıcıyı siber bir şekilde karart
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: SiberTema.kuantumCyan),
                      SizedBox(height: 16),
                      Text("STOKTAN DÜŞÜLÜYOR...", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}