import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/forum_model.dart'; // Model yolunu kontrol et!

/// 🛡️ SİBER KULLANICI FORUM EKRANI
class OtoDnaForumScreen extends StatefulWidget {
  final String aktifKullaniciId;
  final String aktifKullaniciAdi;
  final String kullaniciAraci;

  const OtoDnaForumScreen({
    super.key,
    required this.aktifKullaniciId,
    required this.aktifKullaniciAdi,
    required this.kullaniciAraci,
  });

  @override
  State<OtoDnaForumScreen> createState() => _OtoDnaForumScreenState();
}

class _OtoDnaForumScreenState extends State<OtoDnaForumScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _sadeceBenimAracim = true;

  static const Color _neonGreen = Color(0xFF00FFCC);
  static const Color _cyberBlack = Color(0xFF000000); // Derin Karargah Siyahı
  static const Color _cyberCard = Color(0xFF111111);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cyberBlack,
      appBar: AppBar(
        backgroundColor: _cyberBlack,
        elevation: 0,
        title: const Text('KUANTUM FORUM', style: TextStyle(color: _neonGreen, fontWeight: FontWeight.w900, letterSpacing: 2)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFilterPanel(),
          Expanded(child: _buildForumStream()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _neonGreen,
        icon: const Icon(Icons.bolt, color: Colors.black),
        label: const Text("SORUN BİLDİR", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        onPressed: () => _yeniKonuDialog(),
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _cyberCard,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _neonGreen.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.radar, color: _neonGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _sadeceBenimAracim ? "RADAR: ${widget.kullaniciAraci}" : "RADAR: TÜM ARAÇLAR",
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          Switch(
            activeColor: _neonGreen,
            value: _sadeceBenimAracim,
            onChanged: (val) => setState(() => _sadeceBenimAracim = val),
          ),
        ],
      ),
    );
  }

  Widget _buildForumStream() {
    Query query = _db.collection('kullanici_forumu');
    if (_sadeceBenimAracim) {
      query = query.where('arac_modeli', isEqualTo: widget.kullaniciAraci);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.orderBy('tarih', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text("Sinyal Hatası: ${snapshot.error}", style: TextStyle(color: Colors.red)));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: _neonGreen));

        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Siber ağda henüz kayıt yok.", style: TextStyle(color: Colors.white38)));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final post = ForumPost.fromFirestore(snapshot.data!.docs[index]);
            return _buildForumKarti(post);
          },
        );
      },
    );
  }

  Widget _buildForumKarti(ForumPost post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cyberCard,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(post.baslik.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: _neonGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
                child: Text(post.aracModeli, style: const TextStyle(color: _neonGreen, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(post.icerik, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
          const SizedBox(height: 15),
          Row(
            children: [
              const Icon(Icons.account_circle_outlined, size: 14, color: Colors.white38),
              const SizedBox(width: 5),
              Text(post.yazarAdi, style: const TextStyle(color: Colors.white38, fontSize: 11)),
              const Spacer(),
              _buildAyniDertButonu(post),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAyniDertButonu(ForumPost post) {
    return InkWell(
      onTap: () async {
        if (post.id != null) {
          await _db.collection('kullanici_forumu').doc(post.id).update({
            'ayni_dert_sayisi': FieldValue.increment(1)
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.blueAccent),
            const SizedBox(width: 6),
            Text("KRÖNİK ANALİZ (${post.ayniDertSayisi})", style: const TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _yeniKonuDialog() {
    final baslikCtrl = TextEditingController();
    final icerikCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: _cyberCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("SİBER ARIZA KAYDI", style: TextStyle(color: _neonGreen, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            _buildInput("Sorun Başlığı (Örn: Turbo Islığı)", baslikCtrl),
            const SizedBox(height: 12),
            _buildInput("Detaylı Açıklama", icerikCtrl, maxLines: 4),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _neonGreen, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                onPressed: () async {
                  if (baslikCtrl.text.isEmpty || icerikCtrl.text.isEmpty) return;

                  // SİBER SANSÜR MOTORU
                  if (icerikCtrl.text.contains(RegExp(r'[0-9]{10}')) || icerikCtrl.text.toLowerCase().contains("iban")) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🚨 GÜVENLİK İHLALİ: İletişim bilgisi paylaşamazsınız!"), backgroundColor: Colors.red));
                    return;
                  }

                  await _db.collection('kullanici_forumu').add(ForumPost(
                    yazarId: widget.aktifKullaniciId,
                    yazarAdi: widget.aktifKullaniciAdi,
                    aracModeli: widget.kullaniciAraci,
                    baslik: baslikCtrl.text.trim(),
                    icerik: icerikCtrl.text.trim(),
                  ).toMap());
                  Navigator.pop(ctx);
                },
                child: const Text("AĞA GÖNDER", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String hint, TextEditingController ctrl, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}