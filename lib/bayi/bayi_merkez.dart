// lib/bayi/bayi_merkez.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI VE MERKEZİ TEMA BAĞLANTISI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

/// 🛡️ KUANTUM BAYİ YÖNETİM PANELİ (BayiMerkezi)
/// Bayinin kasasındaki parayı (Sıfır İşçilik Kesintisi ve Dinamik Karargah Payıyla) CANLI hesaplayan gerçek terminal.
class BayiMerkezi extends StatefulWidget {
  final String bayiId; // Oturum açan bayinin Karargah kimliği

  const BayiMerkezi({super.key, required this.bayiId});

  @override
  State<BayiMerkezi> createState() => _BayiMerkeziState();
}

class _BayiMerkeziState extends State<BayiMerkezi> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late TabController _tabController;

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
    HapticFeedback.heavyImpact();

    if (cekilebilirBakiye <= 0) {
      _siberUyariGoster("SİBER İHLAL", "Kasada çekilebilir bakiye bulunmamaktadır.", SiberTema.kanKirmizi);
      return;
    }

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
            const SizedBox(height: 4),
            Text(mesaj, style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Avenir')),
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
          title: const Text("BAYİ YÖNETİM PANELİ", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14, fontFamily: 'Avenir')),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: SiberTema.kuantumCyan),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: SiberTema.kuantumCyan,
            indicatorWeight: 3,
            labelColor: SiberTema.kuantumCyan,
            unselectedLabelColor: Colors.white30,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 11, fontFamily: 'Avenir'),
            tabs: const [
              Tab(icon: Icon(Icons.shopping_cart_outlined), text: "SEPETİM"),
              Tab(icon: Icon(Icons.inventory_2_outlined), text: "SİPARİŞLER"),
              Tab(icon: Icon(Icons.account_balance_wallet_outlined), text: "KASAM"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildSepetSekmesi(),
            _buildCanliSiparisSekmesi(),
            _buildCanliKasaSekmesi(),
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
          const SizedBox(height: 16),
          const Text("SİBER SEPET BOŞ", style: TextStyle(color: Colors.white54, letterSpacing: 2, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
          const SizedBox(height: 8),
          const Text("Firmalar arası B2B tedarik ağı buraya düşer.", style: TextStyle(color: Colors.white30, fontSize: 11, fontFamily: 'Avenir')),
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
          return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
        }

        // 🛡️ DÜZELTME: Veri Yoksa Güvenli Boş Ekran Döndür
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inventory_2_outlined, color: Colors.white12, size: 80),
                const SizedBox(height: 16),
                const Text("SİPARİŞ BULUNAMADI", style: TextStyle(color: Colors.white54, letterSpacing: 2, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
              ],
            ),
          );
        }

        // Veri Varsa ListView Döndür
        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: SiberTema.matGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: renk.withOpacity(0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: renk.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(Icons.directions_car_outlined, color: renk, size: 24),
        ),
        title: Text(plaka, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(urun, style: const TextStyle(color: Colors.white54, fontSize: 11, fontFamily: 'Avenir')),
            const SizedBox(height: 4),
            Text("DURUM: $durum", style: TextStyle(color: renk, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 16),
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

        // ⚖️ YENİ TİCARET DOKTRİNİ: Sadece B2B Parça Satışından Kesinti!
        double kesintiOrani = (widget.bayiId == "MURAT_PLAZA") ? 0.30 : 0.12;
        double otodnaKesintisi = toplamParcaSatisi * kesintiOrani;

        // Net Kasa = (Tüm İşçilik) + (Parça Satışı - Kesinti) + Bekleyenler
        double netKasa = toplamIscilik + (toplamParcaSatisi - otodnaKesintisi) + bekleyenHakedis;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildFinansOzetPaneli("SAF İŞÇİLİK GELİRİ (%100 SİZİN)", toplamIscilik, SiberTema.kuantumCyan),
              const SizedBox(height: 12),
              _buildFinansOzetPaneli("PARÇA SATIŞ GELİRİ", toplamParcaSatisi, Colors.white),
              const SizedBox(height: 12),
              _buildFinansOzetPaneli("OTODNA TEDARİK PAYI (%${(kesintiOrani * 100).toInt()})", otodnaKesintisi, SiberTema.kanKirmizi, isNegative: true),
              const SizedBox(height: 12),
              _buildFinansOzetPaneli("BEKLEYEN HAKEDİŞ (PROVİZYON)", bekleyenHakedis, Colors.amberAccent),

              const SizedBox(height: 24),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 24),

              // SİBER NET KASA KARTI
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: SiberTema.kuantumCyan.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5), width: 2),
                ),
                child: Column(
                  children: [
                    const Text("NET ÇEKİLEBİLİR BAKİYE", style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                    const SizedBox(height: 8),
                    Text("₺${netKasa.toStringAsFixed(2)}", style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 32, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
                  ],
                ),
              ),

              const Spacer(),

              // ATEŞLEME BUTONU
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.account_balance_outlined, color: Colors.black),
                  label: const Text("HAKEDİŞİ BANKAYA AKTAR", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13, fontFamily: 'Avenir')),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(color: SiberTema.matGrey.withOpacity(0.5), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(baslik, style: const TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.bold, fontFamily: 'Avenir'))),
          Text("${isNegative ? '-' : ''}₺${tutar.toStringAsFixed(2)}", style: TextStyle(color: renk, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}