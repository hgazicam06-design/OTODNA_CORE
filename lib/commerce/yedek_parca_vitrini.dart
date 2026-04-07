import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🔥 SİBER KÖPRÜLER VE TEMA
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

class YedekParcaVitriniScreen extends StatefulWidget {
  final String aracId;

  const YedekParcaVitriniScreen({
    super.key,
    required this.aracId,
  });

  @override
  State<YedekParcaVitriniScreen> createState() => _YedekParcaVitriniScreenState();
}

class _YedekParcaVitriniScreenState extends State<YedekParcaVitriniScreen> {
  bool _isProcessing = false;

  // --- 🔴 FİREBASE: SİPARİŞ MÜHÜRLEME MOTORU (ATOMİK) ---
  Future<void> _siparisiOnaylaVeMuhurle(String siparisId, String parca, double fiyat) async {
    setState(() => _isProcessing = true);

    try {
      final db = FirebaseFirestore.instance;
      WriteBatch batch = db.batch();

      // 1. Siparişin durumunu "Onaylandı" olarak güncelle
      DocumentReference siparisRef = db.collection('yedek_parca_onerileri').doc(siparisId);
      batch.update(siparisRef, {
        'durum': 'Sipariş Onaylandı - Kargoya Verilecek',
        'onay_tarihi': FieldValue.serverTimestamp(),
      });

      // 2. Karargah Finans (İşlem Kayıtları) Havuzuna %12'yi Aktar
      DocumentReference finansRef = db.collection('islem_kayitlari').doc();
      batch.set(finansRef, {
        'arac_id': widget.aracId,
        'siparis_id': siparisId,
        'islem_turu': 'Yedek Parça Satışı',
        'toplam_tutar': fiyat,
        'komutan_payi': fiyat * 0.12, // %12 KARARGAH PAYI (Kâr + Vergi)
        'tarih': FieldValue.serverTimestamp(),
      });

      // 3. Admin Kara Kutu Logu
      DocumentReference logRef = db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'basarili',
        'islem_detayi': 'TİCARET ONAYI: $parca siparişi onaylandı. %12 Karargah payı kasaya eklendi.',
        'bayi_isim': 'SİBER EKOSİSTEM',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit(); // Füzeyi ateşle!

      if (!mounted) return;
      _siberUyariVer("SİPARİŞ ONAYLANDI: Tedarikçi bilgilendirildi!", false);

    } catch (e) {
      if (!mounted) return;
      _siberUyariVer("SİBER AĞ HATASI: Sipariş mühürlenemedi! $e", true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _siberUyariVer(String mesaj, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir', fontSize: 12)),
        backgroundColor: isError ? const Color(0xFFFF0040) : const Color(0xFF00FFC2).withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF00FFC2)), onPressed: () => Navigator.pop(context)),
          title: const Text("AKILLI KÂR EKOSİSTEMİ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13, fontFamily: 'Avenir')),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // İnce, Şık Güvence Bandı
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white12, width: 1)),
                color: Color(0xFF0A0A0C),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield, color: Color(0xFF00FFC2), size: 16),
                  SizedBox(width: 8),
                  Expanded(child: Text("TÜM İŞLEMLER OTODNA %12 GÜVENCE BEDELİ İLE KORUNMAKTADIR", style: TextStyle(color: Color(0xFF00FFC2), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir'))),
                ],
              ),
            ),

            // Canlı Sipariş Radarı (Firebase StreamBuilder)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('yedek_parca_onerileri')
                    .where('arac_plaka', isEqualTo: widget.aracId)
                    .where('durum', isEqualTo: 'Müşteri Onayı Bekliyor')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF00FFC2), strokeWidth: 2));
                  }

                  final siparisler = snapshot.data?.docs ?? [];

                  if (siparisler.isEmpty) {
                    return Center(
                      child: Text("Bekleyen Yedek Parça Siparişi Yok.", style: TextStyle(color: Colors.white.withOpacity(0.4), fontFamily: 'Avenir', fontWeight: FontWeight.bold, letterSpacing: 1)),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: siparisler.length,
                    itemBuilder: (context, index) {
                      var data = siparisler[index].data() as Map<String, dynamic>;
                      String docId = siparisler[index].id;

                      String parca = data['sorunlu_parca'] ?? 'Bilinmeyen Parça';
                      String bayi = data['sunan_bayi'] ?? 'Bağımsız Tedarikçi';
                      double fiyat = (data['musteri_satis_fiyati'] ?? 0).toDouble();

                      // SİBER ROZET SİSTEMİ (Satıcının adına göre otomatik rütbe)
                      bool isYetkili = bayi.toUpperCase().contains("YETKİLİ") || bayi.toUpperCase().contains("DİSTRİBÜTÖR");

                      return _buildKompaktTicaretSatiri(docId, parca, bayi, fiyat, isYetkili);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 💎 TESLA STANDARTLARINDA SADE VE ŞIK TİCARET KARTI
  Widget _buildKompaktTicaretSatiri(String siparisId, String parca, String bayi, double fiyat, bool isYetkili) {
    Color rozetRengi = isYetkili ? const Color(0xFFFFB300) : const Color(0xFF00FFC2); // Yetkiliyse Altın, Değilse Turkuaz
    String rozetMetni = isYetkili ? "ORİJİNAL ÜRETİCİ" : "ONAYLI TEDARİKÇİ";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141518), // Fırçalanmış koyu titanyum
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ÜST BÖLÜM: Rozet ve Satıcı İsmi (Şeffaflık Protokolü)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: rozetRengi.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: rozetRengi.withOpacity(0.5)),
                ),
                child: Text(rozetMetni, style: TextStyle(color: rozetRengi, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  bayi.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir'),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ORTA BÖLÜM: Parça ve Fiyat
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Tedarik Edilecek Parça:", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9, fontFamily: 'Avenir')),
                    const SizedBox(height: 2),
                    Text(parca, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("TUTAR", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9, fontFamily: 'Avenir', letterSpacing: 1)),
                  const SizedBox(height: 2),
                  Text(
                    "₺${fiyat.toStringAsFixed(2)}",
                    style: const TextStyle(color: Color(0xFF00FFC2), fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Courier', shadows: [Shadow(color: Color(0xFF00FFC2), blurRadius: 10)]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ALT BÖLÜM: Sipariş Butonu
          SizedBox(
            width: double.infinity,
            height: 40, // İnce ve Şık Buton
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A0A0C), // Siyah Zemin
                foregroundColor: const Color(0xFF00FFC2),
                side: const BorderSide(color: Color(0xFF00FFC2), width: 1), // Turkuaz Çerçeve
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: _isProcessing ? null : () => _siparisiOnaylaVeMuhurle(siparisId, parca, fiyat),
              icon: _isProcessing
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Color(0xFF00FFC2), strokeWidth: 2))
                  : const Icon(Icons.check_circle_outline, size: 18),
              label: Text(
                  _isProcessing ? "ONAYLANIYOR..." : "SİPARİŞİ ONAYLA",
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5, fontFamily: 'Avenir')
              ),
            ),
          ),
        ],
      ),
    );
  }
}