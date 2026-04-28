import 'package:otodna/core/siber_tema.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// 🚀 KARARGAH ZIRHLARI VE MERKEZİ TEMA
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

class RandevuYonetimiScreen extends StatefulWidget {
  RandevuYonetimiScreen({super.key});

  @override
  State<RandevuYonetimiScreen> createState() => _RandevuYonetimiScreenState();
}

class _RandevuYonetimiScreenState extends State<RandevuYonetimiScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _siberUyari(String mesaj, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: TextStyle(color: isError ? Colors.white : SiberTema.oledBlack, fontWeight: FontWeight.bold)),
      backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
    ));
  }

  // FİREBASE RANDEVU ONAYLAMA / İPTAL MOTORU (ATOMİK MÜHÜR)
  Future<void> _randevuDurumGuncelle(String randevuId, String yeniDurum) async {
    try {
      WriteBatch batch = _db.batch();

      DocumentReference randevuRef = _db.collection('randevular').doc(randevuId);
      batch.update(randevuRef, {
        'durum': yeniDurum,
        'guncellenme_tarihi': FieldValue.serverTimestamp(),
      });

      DocumentReference logRef = _db.collection('siber_istihbarat_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'RANDEVU_DURUM_GUNCELLEMESI',
        'islem_detayi': 'SİBER RANDEVU: Randevu ($randevuId) durumu "$yeniDurum" olarak güncellendi.',
        'randevu_id': randevuId,
        'yeni_durum': yeniDurum,
        'bayi_id': _currentUser?.uid,
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      _siberUyari(yeniDurum == 'Onaylandı' ? 'Randevu Müşteriye Onaylandı! ✅' : 'Randevu İptal Edildi ❌', isError: yeniDurum != 'Onaylandı');
    } catch (e) {
      _siberUyari("Ağ Hatası: $e", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = SiberTema.oledBlack;
    const primaryCyan = SiberTema.kuantumCyan;
    const cardColor = SiberTema.matGrey;

    if (_currentUser == null) return Scaffold(backgroundColor: bgColor, body: Center(child: Text("Kimlik Hatası!", style: TextStyle(color: SiberTema.kanKirmizi))));

    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent, elevation: 0,
        title: Text('Randevu & Takvim Radarı', style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold)),
        centerTitle: true, iconTheme: IconThemeData(color: primaryCyan),
        bottom: TabBar(
          controller: _tabController, indicatorColor: primaryCyan, labelColor: primaryCyan, unselectedLabelColor: Colors.white54,
          tabs: [Tab(text: "Bekleyen İstekler"), Tab(text: "Onaylı Takvim")],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Sadece bu ustaya ait randevuları dinle
          stream: _db.collection('randevular').where('bayi_id', isEqualTo: _currentUser!.uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: primaryCyan));

            var tumRandevular = snapshot.data?.docs ?? [];
            var bekleyenler = tumRandevular.where((doc) => doc['durum'] == 'Bekliyor').toList();
            var onaylilar = tumRandevular.where((doc) => doc['durum'] == 'Onaylandı').toList();

            return TabBarView(
              controller: _tabController,
              children: [
                // 1. BEKLEYEN RANDEVULAR
                bekleyenler.isEmpty
                    ? Center(child: Text("Bekleyen randevu talebi yok.", style: TextStyle(color: SiberTema.textMuted)))
                    : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: bekleyenler.length,
                  itemBuilder: (context, index) {
                    var doc = bekleyenler[index];
                    var data = doc.data() as Map<String, dynamic>;
                    return _buildRandevuKarti(doc.id, data, cardColor, primaryCyan, bgColor, isOnayli: false);
                  },
                ),

                // 2. ONAYLI RANDEVULAR
                onaylilar.isEmpty
                    ? Center(child: Text("Onaylanmış randevunuz bulunmuyor.", style: TextStyle(color: SiberTema.textMuted)))
                    : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: onaylilar.length,
                  itemBuilder: (context, index) {
                    var doc = onaylilar[index];
                    var data = doc.data() as Map<String, dynamic>;
                    return _buildRandevuKarti(doc.id, data, cardColor, primaryCyan, bgColor, isOnayli: true);
                  },
                ),
              ],
            );
          }
      ),
      ),
    );
  }

  Widget _buildRandevuKarti(String id, Map<String, dynamic> data, Color cardColor, Color primaryCyan, Color bgColor, {required bool isOnayli}) {
    String formatliTarih = data['tarih'] ?? "Tarih Belirsiz"; // Örn: 15 Ekim 2026 - 14:00

    return Container(
      margin: EdgeInsets.only(bottom: 16), padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: isOnayli ? primaryCyan.withOpacity(0.5) : Colors.orangeAccent.withOpacity(0.5), width: 1.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(data['plaka'] ?? 'Plaka Yok', style: TextStyle(color: SiberTema.textMain, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)), Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: isOnayli ? primaryCyan.withOpacity(0.1) : Colors.orangeAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(isOnayli ? "ONAYLI" : "BEKLİYOR", style: TextStyle(color: isOnayli ? primaryCyan : Colors.orangeAccent, fontSize: 10, fontWeight: FontWeight.bold)))]),
          SizedBox(height: 12),
          Row(children: [Icon(Icons.person, color: SiberTema.textMuted, size: 16), SizedBox(width: 8), Text("Müşteri: ${data['musteri_adi'] ?? 'Bilinmiyor'}", style: TextStyle(color: SiberTema.textMuted, fontSize: 14))]),
          SizedBox(height: 4),
          Row(children: [Icon(Icons.build_circle, color: SiberTema.textMuted, size: 16), SizedBox(width: 8), Text("İşlem: ${data['islem_tipi'] ?? 'Genel Bakım'}", style: TextStyle(color: SiberTema.textMuted, fontSize: 14))]),
          SizedBox(height: 12),
          Container(width: double.infinity, padding: EdgeInsets.all(12), decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)), child: Row(children: [Icon(Icons.calendar_month, color: isOnayli ? primaryCyan : Colors.orangeAccent, size: 18), SizedBox(width: 8), Text("Tarih: $formatliTarih", style: TextStyle(color: isOnayli ? primaryCyan : Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 13))])),

          if (!isOnayli) ...[
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(side: BorderSide(color: SiberTema.kanKirmizi), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () => _randevuDurumGuncelle(id, 'İptal Edildi'), child: Text("Reddet", style: TextStyle(color: SiberTema.kanKirmizi)))),
                SizedBox(width: 12),
                Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: primaryCyan, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () => _randevuDurumGuncelle(id, 'Onaylandı'), child: Text("Onayla", style: TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.bold)))),
              ],
            )
          ]
        ],
      ),
    );
  }
}