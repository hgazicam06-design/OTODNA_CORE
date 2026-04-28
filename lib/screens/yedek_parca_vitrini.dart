import 'package:otodna/core/siber_tema.dart';
// lib/screens/yedek_parca_vitrini.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🔥 SİBER KÖPRÜLER VE TEMA
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

class YedekParcaVitriniScreen extends StatefulWidget {
  final String aracId;

  YedekParcaVitriniScreen({
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

      // 1. MUTLAK KARARGAH KURALI: İSTİSNASIZ %12 PAY (Kâr + Vergi)
      double karargahPayi = fiyat * 0.12;
      double bayiHakedis = fiyat - karargahPayi; // Kalan tutar satıcının net hakedişidir

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

      await batch.commit(); // Füzeleri Kuantum Ağına ateşle!

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
        content: Text(mesaj, style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir', fontSize: 11)),
        backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: Icon(Icons.radar, color: SiberTema.kuantumCyan), onPressed: () => Navigator.pop(context)),
          title: Text("AKILLI KÂR EKOSİSTEMİ", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 13, fontFamily: 'Avenir')),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // 🛡️ HUD SİBER GÜVENCE BANDI (Holografik Tarz)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [SiberTema.kuantumCyan.withOpacity(0.2), SiberTema.oledBlack.withOpacity(0.9)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border(bottom: BorderSide(color: SiberTema.kuantumCyan.withOpacity(0.5), width: 1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, color: SiberTema.kuantumCyan, size: 16),
                  SizedBox(width: 10),
                  Expanded(
                      child: Text(
                          "SİSTEMDEKİ TÜM TİCARİ İŞLEMLER %12 KARARGAH KESİNTİSİ İLE GÜVENCE ALTINDADIR",
                          style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.2, fontFamily: 'Avenir')
                      )
                  ),
                ],
              ),
            ),

            // 📡 CANLI SİPARİŞ RADARI
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('parca_teklifleri')
                    .where('plaka_id', isEqualTo: widget.aracId)
                    .where('durum', isEqualTo: 'BEKLEMEDE')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: SizedBox(
                          width: 40, height: 40,
                          child: CircularProgressIndicator(color: SiberTema.kuantumCyan, strokeWidth: 2),
                        )
                    );
                  }

                  final siparisler = snapshot.data?.docs ?? [];

                  if (siparisler.isEmpty) {
                    return _buildBosRadarEkran();
                  }

                  return ListView.builder(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.all(20),
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

  // 🎯 BOŞ RADAR TASARIMI (Ultra Profesyonel)
  Widget _buildBosRadarEkran() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.2), width: 2),
              boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.05), blurRadius: 30, spreadRadius: 10)],
            ),
            child: Icon(Icons.radar, color: SiberTema.kuantumCyan.withOpacity(0.5), size: 60),
          ),
          SizedBox(height: 24),
          Text("SİBER AĞ TEMİZ", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 3, fontSize: 14, fontFamily: 'Avenir')),
          SizedBox(height: 8),
          Text("Bu araca ait bekleyen bir tedarik teklifi bulunmuyor.", style: TextStyle(color: Colors.white30, fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 10, fontFamily: 'Avenir')),
        ],
      ),
    );
  }

  // 💳 ULTRA PROFESYONEL HUD TİCARET KARTI
  Widget _buildSiberTicaretKarti(String siparisId, Map<String, dynamic> data) {
    String parca = data['parca_adi'] ?? 'Bilinmeyen Parça';
    String bayi = data['sunan_bayi'] ?? 'İsimsiz Tedarikçi';
    String bayiId = data['bayi_id'] ?? 'UNKNOWN';
    double fiyat = (data['fiyat'] ?? 0).toDouble();

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: SiberTema.matGrey.withOpacity(0.6), // Koyu Titanyum Zemin
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3), width: 1.5), // Neon Çerçeve
        boxShadow: [
          BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.05), blurRadius: 15, spreadRadius: 2), // Siber Parlama
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Cam Efekti
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. SATICI VE BİLGİ BANTLARI
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5))),
                      child: Text("ONAYLI TEDARİKÇİ", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    ),
                    Text("ID: ${siparisId.substring(0, 6).toUpperCase()}", style: TextStyle(color: SiberTema.textMuted, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'Courier')),
                  ],
                ),
                SizedBox(height: 16),

                // 2. SATICI İSMİ (Şeffaf)
                Text(bayi.toUpperCase(), style: TextStyle(color: SiberTema.textMain, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: SiberTema.textMuted, height: 1, thickness: 1),
                ),

                // 3. PARÇA BİLGİSİ
                Text("HEDEF PARÇA", style: TextStyle(color: Colors.white30, fontSize: 9, letterSpacing: 2, fontFamily: 'Avenir', fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(parca, style: TextStyle(color: SiberTema.textMain, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),

                SizedBox(height: 24),

                // 4. FİYAT VE MÜHÜRLE BUTONU
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("MÜHÜR BEDELİ", style: TextStyle(color: SiberTema.kuantumCyan.withOpacity(0.7), fontSize: 9, fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 1.5)),
                        SizedBox(height: 4),
                        Text("₺${fiyat.toStringAsFixed(2)}", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'Courier', shadows: [Shadow(color: SiberTema.kuantumCyan, blurRadius: 10)])),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SiberTema.kuantumCyan,
                        foregroundColor: SiberTema.oledBlack,
                        elevation: 10,
                        shadowColor: SiberTema.kuantumCyan.withOpacity(0.5),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _isProcessing ? null : () => _siparisiOnaylaVeMuhurle(
                          siparisId: siparisId,
                          parca: parca,
                          fiyat: fiyat,
                          bayiId: bayiId
                      ),
                      icon: _isProcessing
                          ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: SiberTema.oledBlack, strokeWidth: 2))
                          : Icon(Icons.fingerprint, size: 18),
                      label: Text(
                          _isProcessing ? "MÜHÜRLENİYOR..." : "MÜHÜRLE",
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, fontFamily: 'Avenir', letterSpacing: 1.5)
                      ),
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