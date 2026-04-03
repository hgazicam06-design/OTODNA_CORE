import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SiberChatScreen extends StatefulWidget {
  final String ustaId;
  final String ustaAdi;

  const SiberChatScreen({super.key, required this.ustaId, required this.ustaAdi});

  @override
  State<SiberChatScreen> createState() => _SiberChatScreenState();
}

class _SiberChatScreenState extends State<SiberChatScreen> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  final Color bgColor = const Color(0xFF000000);
  final Color surfaceColor = const Color(0xFF111111);
  final Color primaryCyan = const Color(0xFF00FFC2);
  final Color dangerColor = Colors.redAccent;

  final TextEditingController _mesajKutusu = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late final String currentUserId;
  late final String sohbetId;

  @override
  void initState() {
    super.initState();
    // 🚀 SİBER GÜVENLİK: Sohbet ID oluşturma (Benzersiz ve Sıralı)
    currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'BILINMEYEN_AJAN';
    sohbetId = currentUserId.compareTo(widget.ustaId) > 0
        ? '${currentUserId}_${widget.ustaId}'
        : '${widget.ustaId}_$currentUserId';
  }

  // 🚀 FİREBASE MESAJ FIRLATMA MOTORU
  Future<void> _mesajGonder() async {
    final mesaj = _mesajKutusu.text.trim();
    if (mesaj.isEmpty) return;

    _mesajKutusu.clear(); // Hızlıca kutuyu boşalt ki asker beklemesin

    try {
      await _db.collection('sohbet_aglari').doc(sohbetId).collection('mesajlar').add({
        'gonderen_id': currentUserId,
        'alici_id': widget.ustaId,
        'mesaj': mesaj,
        'zaman_damgasi': FieldValue.serverTimestamp(),
        'tip': 'metin', // İleride fotoğraf gelirse 'gorsel' olacak
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('AĞ HATASI: $e', style: const TextStyle(fontWeight: FontWeight.bold)), backgroundColor: dangerColor));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.verified_user_outlined, color: Color(0xFF00FFC2), size: 16),
                const SizedBox(width: 8),
                Text(widget.ustaAdi.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(color: primaryCyan, shape: BoxShape.circle, boxShadow: [BoxShadow(color: primaryCyan, blurRadius: 4)])),
                const SizedBox(width: 6),
                const Text("KUANTUM AĞINA BAĞLI", style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 2)),
              ],
            )
          ],
        ),
        actions: [
          IconButton(icon: Icon(Icons.more_vert, color: primaryCyan), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // =================================================================
          // 1. KRİPTO BİLDİRİMİ (Üst Bar)
          // =================================================================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: primaryCyan.withOpacity(0.05),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, color: Color(0xFF00FFC2), size: 12),
                SizedBox(width: 8),
                Text("BU SOHBET OTODNA TARAFINDAN UÇTAN UCA ŞİFRELENMİŞTİR", style: TextStyle(color: Color(0xFF00FFC2), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ],
            ),
          ),

          // =================================================================
          // 2. MESAJ LİSTESİ (Canlı Firebase Stream)
          // =================================================================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db.collection('sohbet_aglari').doc(sohbetId).collection('mesajlar').orderBy('zaman_damgasi', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: primaryCyan, strokeWidth: 2));
                }

                if (snapshot.hasError) {
                  return const Center(child: Text("SİBER RADAR HATASI", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)));
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.05)), color: surfaceColor),
                          child: const Icon(Icons.speaker_notes_off_outlined, color: Colors.white24, size: 48),
                        ),
                        const SizedBox(height: 24),
                        const Text("İLETİŞİM AĞI TEMİZ", style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  reverse: true, // Yeni mesajlar alttan çıksın diye listeyi ters çeviriyoruz
                  padding: const EdgeInsets.all(24),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    bool isMe = data['gonderen_id'] == currentUserId;

                    // Kuantum Zaman Damgası (Tarih/Saat)
                    String zamanStr = "";
                    if (data['zaman_damgasi'] != null) {
                      DateTime dt = (data['zaman_damgasi'] as Timestamp).toDate();
                      zamanStr = "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
                    }

                    return _buildSiberBalon(data['mesaj'] ?? '', isMe, zamanStr);
                  },
                );
              },
            ),
          ),

          // =================================================================
          // 3. ATEŞLEME PANELİ (Mesaj Gönderme Kutusu)
          // =================================================================
          _buildAteslemePaneli(),
        ],
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: SİBER MESAJ BALONU
  Widget _buildSiberBalon(String metin, bool isMe, String zaman) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? primaryCyan.withOpacity(0.1) : surfaceColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(20),
          ),
          border: Border.all(color: isMe ? primaryCyan.withOpacity(0.3) : Colors.white.withOpacity(0.05)),
          boxShadow: isMe ? [BoxShadow(color: primaryCyan.withOpacity(0.05), blurRadius: 10)] : [],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(metin, style: TextStyle(color: isMe ? Colors.white : Colors.white70, fontSize: 13, height: 1.4, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(zaman, style: TextStyle(color: isMe ? primaryCyan : Colors.white38, fontSize: 9, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.done_all, color: Color(0xFF00FFC2), size: 12),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: MESAJ YAZMA PANELİ
  Widget _buildAteslemePaneli() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          // Mesaj Yazma Kutusu
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: TextField(
                controller: _mesajKutusu,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: 'İletiyi yazın...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Ateşleme (Gönder) Butonu
          GestureDetector(
            onTap: _mesajGonder,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryCyan,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.3), blurRadius: 10)],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.black, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}