import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';

/// 🦅 SİBER CHAT TERMİNALİ
/// Bu ünite, usta ve kullanıcı arasındaki dijital köprüyü siber zırhla kurar.
class SiberChatScreen extends StatefulWidget {
  final String ustaId;
  final String ustaAdi;

  const SiberChatScreen({super.key, required this.ustaId, required this.ustaAdi});

  @override
  State<SiberChatScreen> createState() => _SiberChatScreenState();
}

class _SiberChatScreenState extends State<SiberChatScreen> {
  final TextEditingController _mesajKutusu = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late final String currentUserId;
  late final String sohbetId;

  @override
  void initState() {
    super.initState();
    // 🛡️ SİBER GÜVENLİK: Benzersiz Sohbet Anahtarı Oluşturma
    // Alfabetik sıralama yapılarak, kim başlatırsa başlatsın aynı ID elde edilir.
    currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'BILINMEYEN_AJAN';
    sohbetId = currentUserId.compareTo(widget.ustaId) > 0
        ? '${currentUserId}_${widget.ustaId}'
        : '${widget.ustaId}_$currentUserId';
  }

  @override
  void dispose() {
    _mesajKutusu.dispose();
    super.dispose();
  }

  // 🚀 FİREBASE ATEŞLEME MOTORU (GERÇEK ZAMANLI VERİ YAZMA)
  Future<void> _mesajGonder() async {
    final mesaj = _mesajKutusu.text.trim();
    if (mesaj.isEmpty) return;

    // Mesaj fırlatıldığı an kutuyu temizle
    _mesajKutusu.clear();

    try {
      await _db.collection('sohbet_aglari').doc(sohbetId).collection('mesajlar').add({
        'gonderen_id': currentUserId,
        'alici_id': widget.ustaId,
        'mesaj': mesaj,
        'zaman_damgasi': FieldValue.serverTimestamp(),
        'tip': 'metin',
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('SİBER BAĞLANTI HATASI: $e', style: const TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: Colors.redAccent
          )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SiberTema.oledBlack,
      appBar: AppBar(
        backgroundColor: SiberTema.matGrey.withOpacity(0.1),
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20),
            onPressed: () => Navigator.pop(context)
        ),
        title: _buildAppBarTitle(),
      ),
      body: Column(
        children: [
          _buildKriptoBar(),
          Expanded(child: _buildMesajListesi()),
          _buildAteslemePaneli(),
        ],
      ),
    );
  }

  // 💎 APPBAR BAŞLIK ÜNİTESİ
  Widget _buildAppBarTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.verified_user_outlined, color: SiberTema.kuantumCyan, size: 16),
            const SizedBox(width: 8),
            Text(widget.ustaAdi.toUpperCase(),
                style: const TextStyle(color: SiberTema.textMain, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
                width: 6, height: 6,
                decoration: const BoxDecoration(color: SiberTema.kuantumCyan, shape: BoxShape.circle)
            ),
            const SizedBox(width: 6),
            const Text("KUANTUM AĞINA BAĞLI",
                style: TextStyle(color: SiberTema.textMuted, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 2)),
          ],
        )
      ],
    );
  }

  // 💎 ŞİFRELEME BİLGİ BARI
  Widget _buildKriptoBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: SiberTema.kuantumCyan.withOpacity(0.05),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, color: SiberTema.kuantumCyan, size: 12),
          SizedBox(width: 8),
          Text("BU SOHBET OTODNA TARAFINDAN UÇTAN UCA ŞİFRELENMİŞTİR",
              style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ],
      ),
    );
  }

  // 💎 MESAJ LİSTESİ MOTORU (CANLI AKIŞ)
  Widget _buildMesajListesi() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('sohbet_aglari').doc(sohbetId).collection('mesajlar')
          .orderBy('zaman_damgasi', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
        }

        if (snapshot.hasError) {
          return const Center(child: Text("SİBER AĞ KOPUKLUĞU", style: TextStyle(color: Colors.redAccent)));
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return _buildBosSohbet();

        return ListView.builder(
          reverse: true, // En yeni mesaj en altta görünür (Chat mantığı)
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            bool isMe = data['gonderen_id'] == currentUserId;

            // Zaman damgasını biçimlendirme
            DateTime? dt = (data['zaman_damgasi'] as Timestamp?)?.toDate();
            String zamanStr = dt != null ? "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2,'0')}" : "--:--";

            return _buildSiberBalon(data['mesaj'] ?? '', isMe, zamanStr);
          },
        );
      },
    );
  }

  // 💎 SİBER MESAJ BALONU
  Widget _buildSiberBalon(String metin, bool isMe, String zaman) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? SiberTema.kuantumCyan.withOpacity(0.1) : SiberTema.matGrey.withOpacity(0.1),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(20),
          ),
          border: Border.all(color: isMe ? SiberTema.kuantumCyan.withOpacity(0.3) : Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(metin, style: const TextStyle(color: SiberTema.textMain, fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(zaman, style: TextStyle(color: isMe ? SiberTema.kuantumCyan : Colors.white38, fontSize: 9, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // 💎 BOŞ SOHBET GÖRÜNÜMÜ
  Widget _buildBosSohbet() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined, color: Colors.white.withOpacity(0.05), size: 80),
          const SizedBox(height: 16),
          const Text("SİBER İLETİŞİM HATTI GÜVENLİ",
              style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 8),
          const Text("Sohbeti başlatmak için bir mesaj ateşleyin.",
              style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // 💎 ATEŞLEME PANELİ (Girdi Alanı)
  Widget _buildAteslemePaneli() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: SiberTema.matGrey.withOpacity(0.05),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: SiberTema.oledBlack,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: TextField(
                controller: _mesajKutusu,
                style: const TextStyle(color: SiberTema.textMain, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Siber ileti gönder...',
                  hintStyle: TextStyle(color: SiberTema.textMuted, fontSize: 13, fontWeight: FontWeight.bold),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _mesajGonder(), // Klavyeden enter'a basınca da gönder
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _mesajGonder,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: SiberTema.kuantumCyan, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}