import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class RandevuYonetimiScreen extends StatefulWidget {
  const RandevuYonetimiScreen({super.key});

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
      content: Text(mesaj, style: TextStyle(color: isError ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
      backgroundColor: isError ? Colors.redAccent : const Color(0xFF00FFC2),
    ));
  }

  // FİREBASE RANDEVU ONAYLAMA / İPTAL MOTORU
  Future<void> _randevuDurumGuncelle(String randevuId, String yeniDurum) async {
    try {
      await _db.collection('randevular').doc(randevuId).update({
        'durum': yeniDurum,
        'guncellenme_tarihi': FieldValue.serverTimestamp(),
      });
      _siberUyari(yeniDurum == 'Onaylandı' ? 'Randevu Müşteriye Onaylandı! ✅' : 'Randevu İptal Edildi ❌', isError: yeniDurum != 'Onaylandı');
    } catch (e) {
      _siberUyari("Ağ Hatası: $e", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0F172A);
    const primaryCyan = Color(0xFF00FFC2);
    const cardColor = Color(0xFF1E293B);

    if (_currentUser == null) return const Scaffold(backgroundColor: bgColor, body: Center(child: Text("Kimlik Hatası!")));

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor, elevation: 0,
        title: const Text('Randevu & Takvim Radarı', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true, iconTheme: const IconThemeData(color: primaryCyan),
        bottom: TabBar(
          controller: _tabController, indicatorColor: primaryCyan, labelColor: primaryCyan, unselectedLabelColor: Colors.white54,
          tabs: const [Tab(text: "Bekleyen İstekler"), Tab(text: "Onaylı Takvim")],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Sadece bu ustaya ait randevuları dinle
          stream: _db.collection('randevular').where('bayi_id', isEqualTo: _currentUser!.uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: primaryCyan));

            var tumRandevular = snapshot.data?.docs ?? [];
            var bekleyenler = tumRandevular.where((doc) => doc['durum'] == 'Bekliyor').toList();
            var onaylilar = tumRandevular.where((doc) => doc['durum'] == 'Onaylandı').toList();

            return TabBarView(
              controller: _tabController,
              children: [
                // 1. BEKLEYEN RANDEVULAR
                bekleyenler.isEmpty
                    ? const Center(child: Text("Bekleyen randevu talebi yok.", style: TextStyle(color: Colors.white54)))
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bekleyenler.length,
                  itemBuilder: (context, index) {
                    var doc = bekleyenler[index];
                    var data = doc.data() as Map<String, dynamic>;
                    return _buildRandevuKarti(doc.id, data, cardColor, primaryCyan, bgColor, isOnayli: false);
                  },
                ),

                // 2. ONAYLI RANDEVULAR
                onaylilar.isEmpty
                    ? const Center(child: Text("Onaylanmış randevunuz bulunmuyor.", style: TextStyle(color: Colors.white54)))
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
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
    );
  }

  Widget _buildRandevuKarti(String id, Map<String, dynamic> data, Color cardColor, Color primaryCyan, Color bgColor, {required bool isOnayli}) {
    String formatliTarih = data['tarih'] ?? "Tarih Belirsiz"; // Örn: 15 Ekim 2026 - 14:00

    return Container(
      margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: isOnayli ? primaryCyan.withOpacity(0.5) : Colors.orangeAccent.withOpacity(0.5), width: 1.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(data['plaka'] ?? 'Plaka Yok', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: isOnayli ? primaryCyan.withOpacity(0.1) : Colors.orangeAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(isOnayli ? "ONAYLI" : "BEKLİYOR", style: TextStyle(color: isOnayli ? primaryCyan : Colors.orangeAccent, fontSize: 10, fontWeight: FontWeight.bold)))]),
          const SizedBox(height: 12),
          Row(children: [const Icon(Icons.person, color: Colors.white54, size: 16), const SizedBox(width: 8), Text("Müşteri: ${data['musteri_adi'] ?? 'Bilinmiyor'}", style: const TextStyle(color: Colors.white70, fontSize: 14))]),
          const SizedBox(height: 4),
          Row(children: [const Icon(Icons.build_circle, color: Colors.white54, size: 16), const SizedBox(width: 8), Text("İşlem: ${data['islem_tipi'] ?? 'Genel Bakım'}", style: const TextStyle(color: Colors.white70, fontSize: 14))]),
          const SizedBox(height: 12),
          Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)), child: Row(children: [Icon(Icons.calendar_month, color: isOnayli ? primaryCyan : Colors.orangeAccent, size: 18), const SizedBox(width: 8), Text("Tarih: $formatliTarih", style: TextStyle(color: isOnayli ? primaryCyan : Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 13))])),

          if (!isOnayli) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () => _randevuDurumGuncelle(id, 'İptal Edildi'), child: const Text("Reddet", style: TextStyle(color: Colors.redAccent)))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: primaryCyan, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () => _randevuDurumGuncelle(id, 'Onaylandı'), child: const Text("Onayla", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))),
              ],
            )
          ]
        ],
      ),
    );
  }
}