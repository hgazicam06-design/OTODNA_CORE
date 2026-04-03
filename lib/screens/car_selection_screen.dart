import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import 'bildirim_detay_screen.dart';

class BildirimlerScreen extends StatelessWidget {
  final String saseNo;
  final String plaka;

  const BildirimlerScreen({super.key, required this.saseNo, required this.plaka});

  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  static const Color bgColor = Color(0xFF000000);
  static const Color surfaceColor = Color(0xFF111111);
  static const Color primaryCyan = Color(0xFF00FFC2);
  static const Color dangerColor = Colors.redAccent;

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;
    final notifService = NotificationService();
    final isDesktop = MediaQuery.of(context).size.width > 800; // 💻 Web uyumluluk filtresi

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('A Ğ   B İ L D İ R İ M L E R İ', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2)),
            const SizedBox(height: 2),
            Text('HEDEF: ${plaka.toUpperCase()}', style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 2, fontFamily: 'monospace')),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: TextButton.icon(
              onPressed: () async {
                final snap = await db
                    .collection('vehicles')
                    .doc(saseNo)
                    .collection('bildirimler')
                    .where('okundu', isEqualTo: false)
                    .get();

                if (snap.docs.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tüm bildirimler zaten okundu.", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: primaryCyan));
                  return;
                }

                WriteBatch batch = db.batch();
                for (final doc in snap.docs) {
                  batch.update(doc.reference, {'okundu': true});
                }
                await batch.commit(); // 🚀 Siber Kural: Atomik (Toplu) Güncelleme
              },
              icon: const Icon(Icons.done_all, color: primaryCyan, size: 16),
              label: const Text('TÜMÜNÜ ONAYLA', style: TextStyle(color: primaryCyan, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000), // Web ekranlarında içerik çok yayılmasın
          child: StreamBuilder<QuerySnapshot>(
            stream: db
                .collection('vehicles')
                .doc(saseNo)
                .collection('bildirimler')
                .orderBy('tarih', descending: true)
                .snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: primaryCyan, strokeWidth: 2));
              }
              final docs = snap.data?.docs ?? [];

              if (docs.isEmpty) {
                return _buildBosEkran();
              }

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0), // Web'de geniş, mobilde dar padding
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final doc = docs[i];
                  final data = doc.data() as Map<String, dynamic>;
                  final okundu = data['okundu'] == true;
                  final tur = data['tur'] ?? 'diger';
                  final tarih = (data['tarih'] as Timestamp?)?.toDate();
                  final ip = data['gonderenIp'] ?? 'BİLİNMİYOR';

                  return _buildBildirimKarti(context, doc, data, okundu, tur, ip, tarih, notifService);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: BOŞ EKRAN
  Widget _buildBosEkran() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.05)), color: surfaceColor),
            child: const Icon(Icons.notifications_off_outlined, color: Colors.white24, size: 64),
          ),
          const SizedBox(height: 24),
          const Text('BİLDİRİM RADARI BOŞ', style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 8),
          const Text('Aracınızın kuantum ağına henüz bir sinyal düşmedi.', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: BİLDİRİM KARTI
  Widget _buildBildirimKarti(BuildContext context, QueryDocumentSnapshot doc, Map<String, dynamic> data, bool okundu, String tur, String ip, DateTime? tarih, NotificationService notifService) {
    Color cardBorderColor = okundu ? Colors.white.withOpacity(0.05) : primaryCyan.withOpacity(0.5);
    Color cardBgColor = okundu ? surfaceColor : primaryCyan.withOpacity(0.05);

    return GestureDetector(
      onTap: () {
        if (!okundu) doc.reference.update({'okundu': true});
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BildirimDetayScreen(
              saseNo: saseNo,
              bildirimId: doc.id,
              data: data,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: cardBgColor,
          border: Border.all(color: cardBorderColor, width: okundu ? 1 : 1.5),
          boxShadow: okundu ? [] : [BoxShadow(color: primaryCyan.withOpacity(0.05), blurRadius: 20)],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // İkon Kutusu
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: okundu ? bgColor : primaryCyan.withOpacity(0.1),
                border: Border.all(color: okundu ? Colors.white12 : primaryCyan.withOpacity(0.3)),
              ),
              child: Center(
                child: Text(notifService.turIcon(tur), style: TextStyle(fontSize: 24, opacity: okundu ? 0.5 : 1)),
              ),
            ),
            const SizedBox(width: 20),

            // İçerik
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notifService.turLabel(tur).toUpperCase(),
                          style: TextStyle(
                            color: okundu ? Colors.white54 : Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      if (!okundu)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: primaryCyan, borderRadius: BorderRadius.circular(8)),
                          child: const Text("YENİ", style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.w900)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // IP ve Güvenlik Logu
                  Row(
                    children: [
                      const Icon(Icons.radar, size: 14, color: dangerColor),
                      const SizedBox(width: 6),
                      Text(
                        ip,
                        style: const TextStyle(color: dangerColor, fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ],
                  ),

                  // Tarih
                  if (tarih != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 12, color: Colors.white.withOpacity(0.3)),
                        const SizedBox(width: 6),
                        Text(
                          _formatDate(tarih),
                          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Sağ Ok (Sadece Masaüstünde daha belirgin)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Icon(Icons.arrow_forward_ios, color: okundu ? Colors.white.withOpacity(0.1) : primaryCyan, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year} | '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}