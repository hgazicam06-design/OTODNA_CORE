import 'package:otodna/core/siber_tema.dart';
// lib/bayi/bayi_merkez.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import 'package:go_router/go_router.dart';


// 🚀 KARARGAH ZIRHLARI VE MERKEZİ TEMA BAĞLANTISI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

import '../widgets/premium_rozet_widget.dart';

/// 🛡️ KUANTUM BAYİ YÖNETİM PANELİ (BayiMerkezi)
/// Bayinin kasasındaki parayı (Sıfır İşçilik Kesintisi ve Dinamik Karargah Payıyla) CANLI hesaplayan gerçek terminal.
class BayiMerkezi extends StatefulWidget {
  final String bayiId; // Oturum açan bayinin Karargah kimliği

  BayiMerkezi({super.key, required this.bayiId});

  @override
  State<BayiMerkezi> createState() => _BayiMerkeziState();
}

class _BayiMerkeziState extends State<BayiMerkezi> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late TabController _tabController;
  bool _islemSuruyor = false; // 🔒 DOUBLE SPEND KORUMASI

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1); // Varsayılan: Siparişler
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        HapticFeedback.selectionClick();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── 🚀 PARA ÇEKME (HAKEDİŞ TALEBİ) ATOMİK MOTORU ──
  Future<void> _hakedisTalebiOlustur(double cekilebilirBakiye) async {
    if (_islemSuruyor) return; // 🔒 SPAM ENGELİ
    
    HapticFeedback.heavyImpact();

    if (cekilebilirBakiye <= 0) {
      _siberUyariGoster("SİBER İHLAL", "Kasada çekilebilir bakiye bulunmamaktadır.", SiberTema.kanKirmizi);
      return;
    }

    setState(() => _islemSuruyor = true);
    developer.log("🚀 FİNANSAL TALEP: $cekilebilirBakiye TL için Karargaha para çekme talebi fırlatıldı.");

    try {
      WriteBatch batch = _db.batch();

      // 1. Talebi Finans Merkezine İlet
      DocumentReference talepRef = _db.collection('odeme_talepleri').doc();
      batch.set(talepRef, {
        'bayi_id': widget.bayiId,
        'talep_edilen_tutar': cekilebilirBakiye,
        'talep_tarihi': FieldValue.serverTimestamp(),
        'durum': 'KARARGAH_ONAYI_BEKLIYOR',
      });

      // 2. Kara Kutuya Log Düş (Siber Fiş)
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'HAKEDIS_TALEBI',
        'islem_detayi': 'SİBER FİNANS: ${widget.bayiId}, ₺${cekilebilirBakiye.toStringAsFixed(2)} tutarında hakediş talebi oluşturdu.',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      HapticFeedback.vibrate();
      if (mounted) {
        _siberUyariGoster("TALEP MÜHÜRLENDİ!", "₺${cekilebilirBakiye.toStringAsFixed(2)} aktarım talebi Finans Merkezine ulaştı.", SiberTema.kuantumCyan);
      }

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Para çekme talebi başarısız!", error: e);
      if (mounted) _siberUyariGoster("AĞ HATASI", "Talep Karargaha iletilemedi.", SiberTema.kanKirmizi);
    } finally {
      if (mounted) setState(() => _islemSuruyor = false);
    }
  }

  // ── 🚨 ARAYÜZ YARDIMCILARI ──
  void _siberUyariGoster(String baslik, String mesaj, Color renk) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SiberTema.matGrey,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: renk, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
            SizedBox(height: 4),
            Text(mesaj, style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Avenir')),
          ],
        ),
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
          title: Text("BAYİ YÖNETİM PANELİ", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14, fontFamily: 'Avenir')),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: SiberTema.kuantumCyan),
          actions: [
            IconButton(
              icon: Icon(Icons.people_alt_outlined, color: SiberTema.kuantumCyan),
              tooltip: 'Personel Ağı',
              onPressed: () {
                HapticFeedback.lightImpact();
                context.push('/personel_yonetimi', extra: widget.bayiId);
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: SiberTema.kuantumCyan,
            indicatorWeight: 3,
            labelColor: SiberTema.kuantumCyan,
            unselectedLabelColor: Colors.white30,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 11, fontFamily: 'Avenir'),
            tabs: [
              Tab(icon: Icon(Icons.shopping_cart_outlined), text: "SEPETİM"),
              Tab(icon: Icon(Icons.inventory_2_outlined), text: "SİPARİŞLER"),
              Tab(icon: Icon(Icons.account_balance_wallet_outlined), text: "KASAM"),
            ],
          ),
        ),
        body: Column(
          children: [
            // 🛡️ SİBER BAYİ ROZETİ (CANLI)
            StreamBuilder<DocumentSnapshot>(
              stream: _db.collection('bayiler').doc(widget.bayiId).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) return SizedBox.shrink();
                var bayi = snapshot.data!.data() as Map<String, dynamic>;
                String rozet = bayi['rozet'] ?? "Boş";
                int yildiz = (bayi['yildiz_sayisi'] ?? 2).toInt();

                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border(bottom: BorderSide(color: SiberTema.kuantumCyan.withOpacity(0.3), width: 1)),
                  ),
                  child: Row(
                    children: [
                      PremiumRozet(rozetTipi: rozet, boyut: 28),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("SİSTEM DURUMU: ${rozet.toUpperCase()}", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
                          SizedBox(height: 4),
                          Row(
                            children: List.generate(5, (starIdx) {
                              return Icon(
                                starIdx < yildiz ? Icons.star : Icons.star_border,
                                color: starIdx < yildiz ? SiberTema.altinSari : Colors.white24,
                                size: 14,
                              );
                            }),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
            
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSepetSekmesi(),
                  _buildCanliSiparisSekmesi(),
                  _buildCanliKasaSekmesi(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 📦 1. SEKME: SEPETİM (TEDARİK) ──
  Widget _buildSepetSekmesi() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_checkout, color: SiberTema.kuantumCyan.withOpacity(0.3), size: 80),
          SizedBox(height: 16),
          Text("SİBER SEPET BOŞ", style: TextStyle(color: Colors.white54, letterSpacing: 2, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
          SizedBox(height: 8),
          Text("Firmalar arası B2B tedarik ağı buraya düşer.", style: TextStyle(color: Colors.white30, fontSize: 11, fontFamily: 'Avenir')),
        ],
      ),
    );
  }

  // ── 🚚 2. SEKME: CANLI SİPARİŞLER (SIFIR MAKET) ──
  Widget _buildCanliSiparisSekmesi() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('siparisler').where('bayi_id', isEqualTo: widget.bayiId).orderBy('tarih', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
        }

        // 🛡️ DÜZELTME: Veri Yoksa Güvenli Boş Ekran Döndür
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, color: Colors.white12, size: 80),
                SizedBox(height: 16),
                Text("SİPARİŞ BULUNAMADI", style: TextStyle(color: Colors.white54, letterSpacing: 2, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
              ],
            ),
          );
        }

        // Veri Varsa ListView Döndür
        return ListView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.all(16),
          children: snapshot.data!.docs.map((doc) => _buildSiparisKartiFromDoc(doc)).toList(),
        );
      },
    );
  }

  Widget _buildSiparisKartiFromDoc(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return _buildSiberSiparisKarti(
        data['plaka'] ?? "PLAKA YOK",
        data['urun_adi'] ?? "ÜRÜN",
        data['durum'] ?? "BEKLIYOR",
        SiberTema.kuantumCyan
    );
  }

  Widget _buildSiberSiparisKarti(String plaka, String urun, String durum, Color renk) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: SiberTema.matGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: renk.withOpacity(0.3)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(color: renk.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(Icons.directions_car_outlined, color: renk, size: 24),
        ),
        title: Text(plaka, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(urun, style: TextStyle(color: Colors.white54, fontSize: 11, fontFamily: 'Avenir')),
            SizedBox(height: 4),
            Text("DURUM: $durum", style: TextStyle(color: renk, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 16),
      ),
    );
  }

  // ── 💰 3. SEKME: YENİ DOKTRİN FİNANS KASASI (İŞÇİLİKTEN KESİNTİ YOK!) ──
  Widget _buildCanliKasaSekmesi() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('finans_havuzu').where('bayi_id', isEqualTo: widget.bayiId).snapshots(),
      builder: (context, snapshot) {

        double toplamIscilik = 0.0; // %100 Bayinin
        double toplamParcaSatisi = 0.0; // Karargah payı alınacak kısım
        double bekleyenHakedis = 0.0;

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          for(var doc in snapshot.data!.docs){
            var data = doc.data() as Map<String, dynamic>;
            double iscilik = (data['iscilik_tutari'] ?? 0.0).toDouble();
            double parcaTutari = (data['parca_satis_tutari'] ?? 0.0).toDouble();
            String durum = data['durum'] ?? 'BEKLIYOR';

            if (durum == 'TAMAMLANDI') {
              toplamIscilik += iscilik;
              toplamParcaSatisi += parcaTutari;
            } else {
              bekleyenHakedis += (iscilik + parcaTutari);
            }
          }
        }

        // ⚖️ EVRENSEL TİCARET DOKTRİNİ: Tüm bayiler için B2B Parça Satışından %12 Kesinti!
        const double kesintiOrani = 0.12;
        double otodnaKesintisi = toplamParcaSatisi * kesintiOrani;

        // Net Kasa = (Tüm İşçilik) + (Parça Satışı - Kesinti) + Bekleyenler
        double netKasa = toplamIscilik + (toplamParcaSatisi - otodnaKesintisi) + bekleyenHakedis;

        return Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              _buildFinansOzetPaneli("SAF İŞÇİLİK GELİRİ (%100 SİZİN)", toplamIscilik, SiberTema.kuantumCyan),
              SizedBox(height: 12),
              _buildFinansOzetPaneli("PARÇA SATIŞ GELİRİ", toplamParcaSatisi, Colors.white),
              SizedBox(height: 12),
              _buildFinansOzetPaneli("OTODNA TEDARİK PAYI (%${(kesintiOrani * 100).toInt()})", otodnaKesintisi, SiberTema.kanKirmizi, isNegative: true),
              SizedBox(height: 12),
              _buildFinansOzetPaneli("BEKLEYEN HAKEDİŞ (PROVİZYON)", bekleyenHakedis, Colors.amberAccent),

              SizedBox(height: 24),
              Divider(color: Colors.white24, height: 1),
              SizedBox(height: 24),

              // SİBER NET KASA KARTI
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: SiberTema.kuantumCyan.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5), width: 2),
                ),
                child: Column(
                  children: [
                    Text("NET ÇEKİLEBİLİR BAKİYE", style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                    SizedBox(height: 8),
                    Text("₺${netKasa.toStringAsFixed(2)}", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 32, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
                  ],
                ),
              ),

              Spacer(),

              // ATEŞLEME BUTONU
              SizedBox(
                width: double.infinity,
                height: 60,
                child: _islemSuruyor
                    ? Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan))
                    : ElevatedButton.icon(
                  icon: Icon(Icons.account_balance_outlined, color: Colors.black),
                  label: Text("HAKEDİŞİ BANKAYA AKTAR", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13, fontFamily: 'Avenir')),
                  style: SiberTema.kuantumButonStili(),
                  onPressed: () => _hakedisTalebiOlustur(netKasa),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildFinansOzetPaneli(String baslik, double tutar, Color renk, {bool isNegative = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(color: SiberTema.matGrey.withOpacity(0.5), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(baslik, style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.bold, fontFamily: 'Avenir'))),
          Text("${isNegative ? '-' : ''}₺${tutar.toStringAsFixed(2)}", style: TextStyle(color: renk, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}