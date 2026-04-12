import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';
import 'bildirim_detay_screen.dart';

/// 🦅 OTODNA BİLDİRİM RADARI
/// Aracın tüm siber sinyallerini (Hatalı Park, SOS, Servis Notu) listeler.
class BildirimlerScreen extends StatelessWidget {
  final String saseNo;
  final String plaka;

  const BildirimlerScreen({super.key, required this.saseNo, required this.plaka});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildSiberAppBar(context, db),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: StreamBuilder<QuerySnapshot>(
              stream: db
                  .collection('vehicles')
                  .doc(saseNo)
                  .collection('bildirimler')
                  .orderBy('tarih', descending: true)
                  .snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan, strokeWidth: 2));
                }

                final docs = snap.data?.docs ?? [];

                if (docs.isEmpty) {
                  return _buildBosRadar();
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final doc = docs[i];
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildBildirimKarti(context, doc, data);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // --- 🛰️ SİBER APPBAR ---
  PreferredSizeWidget _buildSiberAppBar(BuildContext context, FirebaseFirestore db) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('AĞ BİLDİRİMLERİ', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2)),
          Text('HEDEF: ${plaka.toUpperCase()}', style: TextStyle(color: SiberTema.kuantumCyan.withOpacity(0.7), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontFamily: 'monospace')),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: TextButton.icon(
            onPressed: () => _tumunuOnayla(context, db),
            icon: const Icon(Icons.done_all, color: SiberTema.kuantumCyan, size: 18),
            label: const Text('ONAYLA', style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 10, fontWeight: FontWeight.w900)),
          ),
        ),
      ],
    );
  }

  // --- ⚔️ ATOMİK ONAY MOTORU (WRITEBATCH) ---
  Future<void> _tumunuOnayla(BuildContext context, FirebaseFirestore db) async {
    final snap = await db.collection('vehicles').doc(saseNo).collection('bildirimler').where('okundu', isEqualTo: false).get();

    if (snap.docs.isEmpty) return;

    WriteBatch batch = db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'okundu': true});
    }
    await batch.commit();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("TÜM SİNYALLER ARŞİVLENDİ VE MÜHÜRLENDİ.", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
          backgroundColor: SiberTema.kuantumCyan,
          behavior: SnackBarBehavior.floating,
        )
    );
  }

  // --- 💎 BİLDİRİM KARTI (SİBER CAM) ---
  Widget _buildBildirimKarti(BuildContext context, QueryDocumentSnapshot doc, Map<String, dynamic> data) {
    final bool okundu = data['okundu'] == true;
    final String baslik = data['baslik'] ?? 'SİSTEM MESAJI';
    final String mesaj = data['mesaj'] ?? 'Detaylar için dokunun.';
    final String tip = data['tip'] ?? 'GENEL';
    final Timestamp? ts = data['tarih'] as Timestamp?;

    return GestureDetector(
      onTap: () {
        // 🛰️ ANLIK GÜNCELLEME: Dokunulduğu anda okundu mühürü basılır
        if (!okundu) doc.reference.update({'okundu': true});

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BildirimDetayScreen(
              bildirimId: doc.id, // 🔥 Hedef bildirimin benzersiz kimliği aktarıldı
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: SiberTema.siberCamKalkan(
          child: Row(
            children: [
              _buildTipIcon(tip, okundu),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(baslik.toUpperCase(), style: TextStyle(color: okundu ? Colors.white54 : Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        // ⚡ KUANTUM IŞIĞI: Okunmamış bildirimlerde yanar
                        if (!okundu)
                          Container(
                              width: 8, height: 8,
                              decoration: const BoxDecoration(
                                  color: SiberTema.kuantumCyan,
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: SiberTema.kuantumCyan, blurRadius: 4)]
                              )
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(mesaj, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white38, fontSize: 11, height: 1.4)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 10, color: SiberTema.kuantumCyan.withOpacity(0.5)),
                        const SizedBox(width: 6),
                        Text(ts != null ? _formatSiberTarih(ts.toDate()) : 'ZAMAN DAMGASI YOK', style: TextStyle(color: SiberTema.kuantumCyan.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.1), size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipIcon(String tip, bool okundu) {
    IconData icon;
    Color renk;

    switch (tip) {
      case 'SOS': icon = Icons.warning_amber_rounded; renk = SiberTema.kanKirmizi; break;
      case 'PARK': icon = Icons.local_parking_rounded; renk = Colors.orangeAccent; break;
      case 'SERVIS': icon = Icons.build_circle_outlined; renk = SiberTema.kuantumCyan; break;
      default: icon = Icons.notifications_none_rounded; renk = Colors.white24;
    }

    return Container(
      width: 50, height: 50,
      decoration: BoxDecoration(
        color: okundu ? Colors.transparent : renk.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: okundu ? Colors.white12 : renk.withOpacity(0.3), width: 1.5),
      ),
      child: Icon(icon, color: okundu ? Colors.white24 : renk, size: 24),
    );
  }

  Widget _buildBosRadar() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.radar_rounded, color: Colors.white.withOpacity(0.05), size: 80),
          const SizedBox(height: 24),
          const Text('RADAR TEMİZ', style: TextStyle(color: Colors.white24, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 4)),
          const SizedBox(height: 8),
          const Text('Henüz bir siber sinyal tespit edilmedi.', style: TextStyle(color: Colors.white10, fontSize: 11)),
        ],
      ),
    );
  }

  String _formatSiberTarih(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year} | ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}