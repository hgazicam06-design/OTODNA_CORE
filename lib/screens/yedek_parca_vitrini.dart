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
  Future<void> _siparisiOnaylaVeMuhurle({
    required String siparisId,
    required String parca,
    required double fiyat,
    required String bayiId,
  }) async {
    setState(() => _isProcessing = true);

    try {
      final db = FirebaseFirestore.instance;
      WriteBatch batch = db.batch();

      // 1. Karargah Finans Algoritması: %10 Kâr + %2 Vergi = %12 Mutlak Pay
      double karargahPayi = fiyat * 0.12;

      // Murat Plaza Kuralı: Bayi Murat Plaza ise %30 hakediş marjı (İç mantıkta saklı)
      // Genel Bayi Hakedişi: Satış Fiyatı - Karargah Payı
      double bayiHakedis = fiyat - karargahPayi;

      // 2. Siparişin durumunu "Mühürlendi" olarak güncelle
      DocumentReference siparisRef = db.collection('parca_teklifleri').doc(siparisId);
      batch.update(siparisRef, {
        'durum': 'ONAYLANDI - SEVK BEKLİYOR',
        'onay_tarihi': FieldValue.serverTimestamp(),
        'karargah_payi': karargahPayi,
        'bayi_hakedis': bayiHakedis,
      });

      // 3. Karargah Finans Havuzuna (Siber Cüzdan) Kaydı İşle
      DocumentReference finansRef = db.collection('islem_kayitlari').doc();
      batch.set(finansRef, {
        'arac_id': widget.aracId,
        'siparis_id': siparisId,
        'islem_turu': 'Yedek Parça Ticareti',
        'toplam_tutar': fiyat,
        'komutan_payi': karargahPayi,
        'tarih': FieldValue.serverTimestamp(),
      });

      // 4. Admin Kara Kutu Logu
      DocumentReference logRef = db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'ticaret_onayi',
        'islem_detayi': 'SATIŞ ONAYI: $parca için ₺$fiyat tahsil edildi. Karargah Payı: ₺$karargahPayi',
        'bayi_id': bayiId,
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit(); // Kuantum Ağına ateşle!

      if (!mounted) return;
      _siberUyariVer("SİPARİŞ MÜHÜRLENDİ: Tedarik Süreci Başladı!", false);

    } catch (e) {
      if (!mounted) return;
      _siberUyariVer("SİBER AĞ HATASI: Mühürleme Başarısız! $e", true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _siberUyariVer(String mesaj, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir', fontSize: 12)),
        backgroundColor: isError ? const Color(0xFFFF0040) : SiberTema.kuantumCyan,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          leading: IconButton(icon: const Icon(Icons.shield, color: SiberTema.kuantumCyan), onPressed: () => Navigator.pop(context)),
          title: const Text("AKILLI KÂR EKOSİSTEMİ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14, fontFamily: 'Avenir')),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // 🛡️ SİBER GÜVENCE BANDI
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: SiberTema.kuantumCyan.withOpacity(0.2), width: 1)),
                color: SiberTema.oledBlack.withOpacity(0.8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_user_outlined, color: SiberTema.kuantumCyan, size: 14),
                  SizedBox(width: 10),
                  Expanded(child: Text("TÜM SİPARİŞLER %12 KARARGAH GÜVENCESİ ALTINDADIR", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.2, fontFamily: 'Avenir'))),
                ],
              ),
            ),

            // Canlı Sipariş Radarı
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('parca_teklifleri')
                    .where('plaka_id', isEqualTo: widget.aracId)
                    .where('durum', isEqualTo: 'BEKLEMEDE')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan, strokeWidth: 2));
                  }

                  final siparisler = snapshot.data?.docs ?? [];

                  if (siparisler.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.radar, color: Colors.white10, size: 64),
                          const SizedBox(height: 16),
                          Text("RADAR TEMİZ: BEKLEYEN TEKLİF YOK", style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 10)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: siparisler.length,
                    itemBuilder: (context, index) {
                      var data = siparisler[index].data() as Map<String, dynamic>;
                      String docId = siparisler[index].id;
                      return _buildSiberTicaretKarti(docId, data);
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

  Widget _buildSiberTicaretKarti(String siparisId, Map<String, dynamic> data) {
    String parca = data['parca_adi'] ?? 'Bilinmeyen Parça';
    String bayi = data['sunan_bayi'] ?? 'İsimsiz Tedarikçi';
    String bayiId = data['bayi_id'] ?? 'UNKNOWN';
    double fiyat = (data['fiyat'] ?? 0).toDouble();
    bool isMuratPlaza = bayi.contains("Murat Plaza");

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: SiberTema.matGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isMuratPlaza ? SiberTema.kuantumCyan.withOpacity(0.3) : Colors.white10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(bayi.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    if (isMuratPlaza)
                      const Icon(Icons.stars, color: SiberTema.kuantumCyan, size: 18),
                  ],
                ),
                const SizedBox(height: 15),
                Text("ÖNERİLEN PARÇA", style: TextStyle(color: Colors.white30, fontSize: 10, letterSpacing: 1)),
                Text(parca, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("MÜHÜR BEDELİ", style: TextStyle(color: SiberTema.kuantumCyan.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.bold)),
                        Text("₺${fiyat.toStringAsFixed(2)}", style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Courier')),
                      ],
                    ),
                    ElevatedButton(
                      style: SiberTema.kuantumButonStili(),
                      onPressed: _isProcessing ? null : () => _siparisiOnaylaVeMuhurle(
                          siparisId: siparisId,
                          parca: parca,
                          fiyat: fiyat,
                          bayiId: bayiId
                      ),
                      child: const Text("SİPARİŞİ MÜHÜRLE", style: TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.w900, fontSize: 11)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}