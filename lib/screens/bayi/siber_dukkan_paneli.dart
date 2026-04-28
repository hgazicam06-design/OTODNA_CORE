import 'package:otodna/core/siber_tema.dart';
// lib/screens/bayi/siber_dukkan_paneli.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

/// 🛡️ KUANTUM DÜKKAN TERMİNALİ (SiberDukkanPaneli V2)
/// Bayinin ürün eklerken kâr marjını yönettiği ve %12 OtoDNA kesintisini otonom hesaplayan komuta merkezi.
class SiberDukkanPaneli extends StatefulWidget {
  SiberDukkanPaneli({super.key});

  @override
  State<SiberDukkanPaneli> createState() => _SiberDukkanPaneliState();
}

class _SiberDukkanPaneliState extends State<SiberDukkanPaneli> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _bayiId = FirebaseAuth.instance.currentUser?.uid ?? "BILINMEYEN_BAYI";

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("DİJİTAL DÜKKAN & FİNANSAL RADAR",
              style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 13, fontFamily: 'Avenir')),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: SiberTema.kuantumCyan),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: SiberTema.kuantumCyan),
              onPressed: () => setState(() {}),
            )
          ],
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 💰 1. BAYİ GENEL KAZANÇ RADARI ──
              Text("BAYİ KAZANÇ ANALİZİ", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
              SizedBox(height: 12),
              _buildFinansalOzet(),

              SizedBox(height: 32),

              // ── 📦 2. SİBER STOK VE FİYAT DNA'SI ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text("ÜRÜN ENVANTERİ VE FİYAT DNA'SI", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir'))),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: SiberTema.kuantumCyan,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                    ),
                    onPressed: () => _yeniUrunEkleDialog(),
                    icon: Icon(Icons.add_shopping_cart, size: 16),
                    label: Text("YENİ ÜRÜN", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                  )
                ],
              ),
              SizedBox(height: 12),
              _buildStokListesi(),
            ],
          ),
        ),
      ),
    );
  }

  // ── 🔧 FİNANSAL ÖZET MOTORU ──
  Widget _buildFinansalOzet() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('bayi_stoklari').doc(_bayiId).collection('urunler').snapshots(),
      builder: (context, snapshot) {
        double potansiyelCiro = 0;
        double potansiyelNetKar = 0;

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            var data = doc.data() as Map<String, dynamic>;
            int miktar = data['miktar'] ?? 0;
            // 🛡️ SİBER DÜZELTME: Veritabanından gelen INT'leri DOUBLE'a çevir, yoksa sistem çöker!
            double vitrinFiyati = (data['vitrin_fiyati'] ?? 0).toDouble();
            double netBayiKazanci = (data['net_bayi_kazanci'] ?? 0).toDouble();

            potansiyelCiro += (vitrinFiyati * miktar);
            potansiyelNetKar += (netBayiKazanci * miktar);
          }
        }

        return Container(
          padding: EdgeInsets.all(20),
          decoration: SiberTema.siberCamZirh(renk: SiberTema.matGrey),
          child: Column(
            children: [
              _buildFinansSatiri("TOPLAM STOK DEĞERİ (VİTRİN)", potansiyelCiro, Colors.white),
              Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: SiberTema.textMuted)),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.2))),
                child: _buildFinansSatiri("POTANSİYEL NET KAZANCINIZ", potansiyelNetKar, SiberTema.kuantumCyan, isBold: true),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── 🔧 STOK LİSTESİ VE FİYAT DETAYI (SİBER MATRİS) ──
  Widget _buildStokListesi() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('bayi_stoklari').doc(_bayiId).collection('urunler').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Padding(padding: EdgeInsets.all(40), child: Text("ENVANTER BOŞ", style: TextStyle(color: SiberTema.textMuted, letterSpacing: 2, fontFamily: 'Avenir'))));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var urun = snapshot.data!.docs[index].data() as Map<String, dynamic>;

            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SiberTema.matGrey,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(urun['urun_adi'].toString().toUpperCase(), style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1, fontFamily: 'Avenir'))),
                      Text("${urun['miktar']} ADET", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'Avenir')),
                    ],
                  ),
                  SizedBox(height: 12),
                  Divider(color: SiberTema.textMuted),
                  SizedBox(height: 8),

                  // 🛡️ ÜRÜN FİNANSAL ANALİZİ (Bayi Ekranı Özel)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _fiyatKapsulu("GELİŞ", "₺${(urun['gelis_fiyati'] ?? 0).toDouble().toStringAsFixed(2)}", Colors.white54),
                      _fiyatKapsulu("Kâr %", "%${urun['kar_marji']}", Colors.amberAccent),
                      _fiyatKapsulu("KESİNTİ %12", "-₺${(urun['otodna_kesintisi'] ?? 0).toDouble().toStringAsFixed(2)}", SiberTema.kritikRed),
                    ],
                  ),
                  SizedBox(height: 12),

                  // VİTRİN VE NET KAZANÇ
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("MÜŞTERİ SATIŞ FİYATI:", style: TextStyle(color: SiberTema.textMuted, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                        Text("₺${(urun['vitrin_fiyati'] ?? 0).toDouble().toStringAsFixed(2)}", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w900, fontSize: 14, fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("SİZİN KAZANCINIZ: ", style: TextStyle(color: SiberTema.textMuted, fontSize: 9, fontFamily: 'Avenir')),
                      Text("₺${(urun['net_bayi_kazanci'] ?? 0).toDouble().toStringAsFixed(2)}", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, fontSize: 12, fontFamily: 'monospace')),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── 🛡️ ATOMİK ÜRÜN EKLEME VE FİNANSAL HESAP MOTORU ──
  void _yeniUrunEkleDialog() {
    final adCtrl = TextEditingController();
    final gelisCtrl = TextEditingController();
    final marjCtrl = TextEditingController(); // % üzerinden kâr
    final miktarCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SiberTema.matGrey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: SiberTema.kuantumCyan, width: 2)),
        title: Text("YENİ ÜRÜN VE MARJ TANIMLA", style: TextStyle(color: SiberTema.textMain, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _siberInput(adCtrl, "Ürün Adı (Örn: Bosch Fren Balatası)"),
              SizedBox(height: 12),
              _siberInput(gelisCtrl, "Birim Geliş Fiyatı (₺)", isNumber: true),
              SizedBox(height: 12),
              _siberInput(marjCtrl, "Hedef Kâr Marjı (%)", isNumber: true),
              SizedBox(height: 12),
              _siberInput(miktarCtrl, "Stok Miktarı", isNumber: true),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("İPTAL", style: TextStyle(color: SiberTema.textMuted, fontFamily: 'Avenir'))),
          ElevatedButton(
            style: SiberTema.kuantumButonStili(),
            onPressed: () async {
              if (adCtrl.text.isEmpty || gelisCtrl.text.isEmpty || marjCtrl.text.isEmpty) return;

              // 🧠 SİBER FİNANS HESAPLAMASI
              double gelis = double.tryParse(gelisCtrl.text.replaceAll(',', '.')) ?? 0;
              double marjYuzde = double.tryParse(marjCtrl.text.replaceAll(',', '.')) ?? 0;

              // 1. Adım: Bayinin istediği satış fiyatı (Kesintisiz)
              double bayiHedefSatis = gelis * (1 + (marjYuzde / 100));

              // 2. Adım: %12 OtoDNA kesintisiyle vitrin fiyatını hesapla
              // Formül: Müşterinin ödediği tutarın %88'i Bayi Hedefine eşit olmalı.
              double vitrinFiyati = bayiHedefSatis / 0.88;

              // 3. Adım: Veri doğruluğu için kesintiyi ve net kazancı hesapla
              double kesintiTutari = vitrinFiyati * 0.12;
              double netKazanc = vitrinFiyati - kesintiTutari;

              WriteBatch batch = _db.batch();
              DocumentReference urunRef = _db.collection('bayi_stoklari').doc(_bayiId).collection('urunler').doc();

              batch.set(urunRef, {
                'urun_adi': adCtrl.text,
                'gelis_fiyati': gelis,
                'kar_marji': marjYuzde,
                'vitrin_fiyati': double.parse(vitrinFiyati.toStringAsFixed(2)),
                'otodna_kesintisi': double.parse(kesintiTutari.toStringAsFixed(2)),
                'net_bayi_kazanci': double.parse(netKazanc.toStringAsFixed(2)),
                'miktar': int.tryParse(miktarCtrl.text) ?? 0,
                'eklenme_tarihi': FieldValue.serverTimestamp(),
              });

              // Kara Kutu Logu
              DocumentReference logRef = _db.collection('siber_istihbarat_loglari').doc();
              batch.set(logRef, {
                'islem_turu': 'FINANSAL_STOK_GIRISI',
                'islem_detayi': 'SİBER TİCARET: $_bayiId yeni ürün ekledi. Geliş: ₺$gelis, Marj: %$marjYuzde. Vitrin: ₺${vitrinFiyati.toStringAsFixed(2)} mühürlendi.',
                'tarih': FieldValue.serverTimestamp(),
              });

              await batch.commit();
              if (mounted) Navigator.pop(ctx);
            },
            child: Text("MÜHÜRLE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
          )
        ],
      ),
    );
  }

  // ── 🔧 ARAYÜZ YARDIMCILARI ──
  Widget _fiyatKapsulu(String baslik, String deger, Color renk) {
    return Column(
      children: [
        Text(baslik, style: TextStyle(color: SiberTema.textMuted, fontSize: 8, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
        SizedBox(height: 4),
        Text(deger, style: TextStyle(color: renk, fontWeight: FontWeight.w900, fontSize: 11, fontFamily: 'monospace')),
      ],
    );
  }

  Widget _buildFinansSatiri(String baslik, double deger, Color renk, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(baslik, style: TextStyle(color: isBold ? renk : Colors.white70, fontSize: 11, fontWeight: isBold ? FontWeight.w900 : FontWeight.bold, fontFamily: 'Avenir'))),
        Text("₺${deger.toStringAsFixed(2)}", style: TextStyle(color: renk, fontWeight: FontWeight.w900, fontSize: isBold ? 16 : 13, fontFamily: 'monospace')),
      ],
    );
  }

  Widget _siberInput(TextEditingController controller, String hint, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: TextStyle(color: SiberTema.textMuted, fontSize: 12, fontFamily: 'Avenir'),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: SiberTema.textMuted)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: SiberTema.kuantumCyan, width: 2)),
      ),
    );
  }
}