// lib/screens/bayi_merkez.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Siber Titreşim (Haptic) için eklendi
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM BAYİ YÖNETİM PANELİ (BayiMerkezi)
/// Bayinin kasasındaki parayı (Dinamik %12 veya %30 Karargah kesintisiyle) CANLI hesaplayan gerçek terminal.
class BayiMerkezi extends StatefulWidget {
  final String bayiId; // Oturum açan bayinin Karargah kimliği

  const BayiMerkezi({super.key, required this.bayiId});

  @override
  State<BayiMerkezi> createState() => _BayiMerkeziState();
}

class _BayiMerkeziState extends State<BayiMerkezi> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late TabController _tabController;

  // ── 🎨 KARARGAH TASARIM DOKTRİNİ ──
  static const Color _oledBlack = Color(0xFF000000);
  static const Color _matGrey = Color(0xFF111111);
  static const Color _kuantumCyan = Color(0xFF00FFC2);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1); // Varsayılan: Siparişler
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        HapticFeedback.selectionClick(); // Sekme geçişlerinde hafif siber titreşim
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── 🚀 PARA ÇEKME (HAKEDİŞ TALEBİ) MOTORU ──
  Future<void> _hakedisTalebiOlustur(double cekilebilirBakiye) async {
    HapticFeedback.heavyImpact(); // Buton hissiyatı

    if (cekilebilirBakiye <= 0) {
      _siberUyariGoster("SİBER İHLAL", "Kasada çekilebilir bakiye bulunmamaktadır.", Colors.redAccent);
      return;
    }

    developer.log("🚀 FİNANSAL TALEP: $cekilebilirBakiye TL için Karargaha para çekme talebi fırlatıldı.");

    try {
      // 1. Talebi Karargaha İlet
      await _db.collection('odeme_talepleri').add({
        'bayi_id': widget.bayiId,
        'talep_edilen_tutar': cekilebilirBakiye,
        'talep_tarihi': FieldValue.serverTimestamp(),
        'durum': 'KARARGAH_ONAYI_BEKLIYOR',
      });

      HapticFeedback.vibrate(); // Onay Titreşimi
      _siberUyariGoster(
          "TALEP MÜHÜRLENDİ!",
          "₺${cekilebilirBakiye.toStringAsFixed(2)} aktarım talebi Finans Merkezine ulaştı.",
          _kuantumCyan
      );

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Para çekme talebi başarısız!", error: e);
      _siberUyariGoster("AĞ HATASI", "Talep Karargaha iletilemedi.", Colors.redAccent);
    }
  }

  // ── 🚨 ARAYÜZ YARDIMCILARI ──
  void _siberUyariGoster(String baslik, String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _matGrey,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: renk, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            const SizedBox(height: 4),
            Text(mesaj, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _oledBlack,
      appBar: AppBar(
        title: const Text("BAYİ YÖNETİM PANELİ", style: TextStyle(color: _kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kuantumCyan),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _kuantumCyan,
          indicatorWeight: 3,
          labelColor: _kuantumCyan,
          unselectedLabelColor: Colors.white30,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 12),
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
    );
  }

  // ── 📦 1. SEKME: SEPETİM (TEDARİK) ──
  Widget _buildSepetSekmesi() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_checkout, color: _kuantumCyan.withOpacity(0.3), size: 80),
          const SizedBox(height: 16),
          const Text("SİBER SEPET BOŞ", style: TextStyle(color: Colors.white54, letterSpacing: 2, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Firmalar arası B2B tedarik ağı buraya düşer.", style: TextStyle(color: Colors.white30, fontSize: 11)),
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
          return const Center(child: CircularProgressIndicator(color: _kuantumCyan));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, color: Colors.white12, size: 80),
                const SizedBox(height: 16),
                const Text("SİPARİŞ BULUNAMADI", style: TextStyle(color: Colors.white54, letterSpacing: 2, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }

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
        _kuantumCyan
    );
  }

  Widget _buildSiberSiparisKarti(String plaka, String urun, String durum, Color renk) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _matGrey,
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
        title: Text(plaka, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(urun, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 4),
            Text("DURUM: $durum", style: TextStyle(color: renk, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 16),
      ),
    );
  }

  // ── 💰 3. SEKME: CANLI FİNANS KASASI (DİNAMİK %12 VEYA %30 HESAPLAMA) ──
  Widget _buildCanliKasaSekmesi() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('finans_havuzu').where('bayi_id', isEqualTo: widget.bayiId).snapshots(),
      builder: (context, snapshot) {

        double alinmisOdemeler = 0.0;
        double bekleyenHakedis = 0.0;

        // Gerçek Veritabanı Okuması
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          for(var doc in snapshot.data!.docs){
            var data = doc.data() as Map<String, dynamic>;
            double islemTutari = (data['toplam_tutar'] ?? 0.0).toDouble();
            String durum = data['durum'] ?? 'BEKLIYOR';

            if (durum == 'TAMAMLANDI') {
              alinmisOdemeler += islemTutari;
            } else {
              bekleyenHakedis += islemTutari;
            }
          }
        }

        // ⚖️ KARARGAH FİNANS KURALI: Murat Plaza %30, diğerleri %12 kesinti!
        double kesintiOrani = (widget.bayiId == "MURAT_PLAZA") ? 0.30 : 0.12;
        double toplamBrutKasa = alinmisOdemeler + bekleyenHakedis;
        double otodnaKesintisi = toplamBrutKasa * kesintiOrani;
        double netKasa = toplamBrutKasa - otodnaKesintisi;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildFinansOzetPaneli("ALINAN TOPLAM ÖDEMELER", alinmisOdemeler, Colors.greenAccent),
              const SizedBox(height: 12),
              _buildFinansOzetPaneli("BEKLEYEN HAKEDİŞ (PROVİZYON)", bekleyenHakedis, Colors.orangeAccent),
              const SizedBox(height: 12),
              _buildFinansOzetPaneli("OTODNA KESİNTİSİ (%${(kesintiOrani * 100).toInt()})", otodnaKesintisi, Colors.redAccent, isNegative: true),

              const SizedBox(height: 24),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 24),

              // SİBER NET KASA KARTI
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _kuantumCyan.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _kuantumCyan.withOpacity(0.5), width: 2),
                ),
                child: Column(
                  children: [
                    const Text("NET ÇEKİLEBİLİR BAKİYE", style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("₺${netKasa.toStringAsFixed(2)}", style: const TextStyle(color: _kuantumCyan, fontSize: 32, fontWeight: FontWeight.w900)),
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
                  label: const Text("HAKEDİŞİ BANKAYA AKTAR", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kuantumCyan,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 10,
                    shadowColor: _kuantumCyan.withOpacity(0.5),
                  ),
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
      decoration: BoxDecoration(color: _matGrey, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(baslik, style: const TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.bold)),
          Text("${isNegative ? '-' : ''}₺${tutar.toStringAsFixed(2)}", style: TextStyle(color: renk, fontSize: 16, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}