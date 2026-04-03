import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ---------------------------------------------------------
// 1. KUANTUM FORUM VERİ MODELİ (FİREBASE UYUMLU)
// ---------------------------------------------------------
class ForumPost {
  final String? id;
  final String yazarId;
  final String yazarAdi;
  final String aracModeli; // Örn: Fiat Egea (2023)
  final String baslik;
  final String icerik;
  final int ayniDertSayisi; // "Aynı dert bende de var" sayacı
  final DateTime tarih;

  ForumPost({
    this.id,
    required this.yazarId,
    required this.yazarAdi,
    required this.aracModeli,
    required this.baslik,
    required this.icerik,
    this.ayniDertSayisi = 0,
    DateTime? tarih,
  }) : tarih = tarih ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'yazar_id': yazarId,
      'yazar_adi': yazarAdi,
      'arac_modeli': aracModeli,
      'baslik': baslik,
      'icerik': icerik,
      'ayni_dert_sayisi': ayniDertSayisi,
      'tarih': FieldValue.serverTimestamp(),
    };
  }

  factory ForumPost.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ForumPost(
      id: doc.id,
      yazarId: data['yazar_id'] ?? '',
      yazarAdi: data['yazar_adi'] ?? 'Gizli Kullanıcı',
      aracModeli: data['arac_modeli'] ?? 'Bilinmeyen Araç',
      baslik: data['baslik'] ?? '',
      icerik: data['icerik'] ?? '',
      ayniDertSayisi: data['ayni_dert_sayisi'] ?? 0,
      tarih: (data['tarih'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

// ---------------------------------------------------------
// 2. SİBER KULLANICI FORUM EKRANI (CANLI AKIŞ)
// ---------------------------------------------------------
class OtoDnaForumScreen extends StatefulWidget {
  final String aktifKullaniciId;
  final String aktifKullaniciAdi;
  final String kullaniciAraci; // Örn: "Fiat Egea (2023)"

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
  bool _sadeceBenimAracim = true; // Kuantum Filtre Şalteri

  // Siber Renk Paleti
  static const _neonGreen = Color(0xFF00FFCC);
  static const _cyberBlack = Color(0xFF0D0D0D);
  static const _cyberCard = Color(0xFF1E1E2E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cyberBlack,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Row(
          children: [
            Icon(Icons.forum, color: _neonGreen),
            SizedBox(width: 10),
            Text('Kullanıcı Forumu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
      body: Column(
        children: [
          // 🚀 FİLTRELEME ALANI
          Container(
            padding: const EdgeInsets.all(12),
            color: _cyberCard,
            child: Row(
              children: [
                const Icon(Icons.directions_car, color: _neonGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Filtre: ${widget.kullaniciAraci}",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                Switch(
                  activeColor: _neonGreen,
                  value: _sadeceBenimAracim,
                  onChanged: (val) {
                    setState(() {
                      _sadeceBenimAracim = val;
                    });
                  },
                ),
              ],
            ),
          ),

          // 📡 FİREBASE CANLI FORUM AKIŞI
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _sadeceBenimAracim
                  ? _db.collection('kullanici_forumu').where('arac_modeli', isEqualTo: widget.kullaniciAraci).orderBy('tarih', descending: true).snapshots()
                  : _db.collection('kullanici_forumu').orderBy('tarih', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: _neonGreen));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Bu araç için henüz bir konu açılmamış.", style: TextStyle(color: Colors.white54)));
                }

                var gonderiler = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  physics: const BouncingScrollPhysics(),
                  itemCount: gonderiler.length,
                  itemBuilder: (context, index) {
                    var post = ForumPost.fromFirestore(gonderiler[index]);
                    return _buildForumKarti(post);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _neonGreen,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text("Konu Aç", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        onPressed: () => _yeniKonuDialog(),
      ),
    );
  }

  // ─── 🛠️ GÖNDERİ KARTI VE AYNI DERT SAYACI ───
  Widget _buildForumKarti(ForumPost post) {
    return Card(
      color: _cyberCard,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.white12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.baslik, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(post.aracModeli, style: const TextStyle(color: _neonGreen, fontSize: 11)),
            const SizedBox(height: 8),
            Text(post.icerik, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 12),
            const Divider(color: Colors.white12),
            Row(
              children: [
                const Icon(Icons.person, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(post.yazarAdi, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const Spacer(),

                // 🚀 FİREBASE "AYNI DERT" TETİKLEYİCİSİ
                InkWell(
                  onTap: () async {
                    if (post.id != null) {
                      await _db.collection('kullanici_forumu').doc(post.id).update({
                        'ayni_dert_sayisi': FieldValue.increment(1)
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("OtoDNA Kuantum Algoritmasına kaydedildi."),
                          backgroundColor: _neonGreen,
                        ));
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.thumb_up_alt_outlined, size: 14, color: Colors.blueAccent),
                        const SizedBox(width: 4),
                        Text("Aynı dert bende de var (${post.ayniDertSayisi})", style: const TextStyle(fontSize: 11, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── 🤖 YENİ KONU AÇMA (YAPAY ZEKA SANSÜRLÜ) ───
  void _yeniKonuDialog() {
    final baslikCtrl = TextEditingController();
    final icerikCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: _cyberCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Kronik Bir Sorun Mu Var?", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              TextField(
                controller: baslikCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Başlık",
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: _neonGreen), borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: icerikCtrl,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Sorunu Detaylı Anlat...",
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: _neonGreen), borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: _neonGreen, padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () async {
                    String baslik = baslikCtrl.text.trim();
                    String icerik = icerikCtrl.text.trim();

                    if (baslik.isEmpty || icerik.isEmpty) return;

                    // AI SANSÜR KONTROLÜ
                    bool ihlalVar = icerik.contains(RegExp(r'[0-9]{10}')) || icerik.toLowerCase().contains("iban");
                    if (ihlalVar) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🚨 Kurallara aykırı içerik tespit edildi!"), backgroundColor: Colors.redAccent));
                      return;
                    }

                    await _db.collection('kullanici_forumu').add(ForumPost(
                      yazarId: widget.aktifKullaniciId,
                      yazarAdi: widget.aktifKullaniciAdi,
                      aracModeli: widget.kullaniciAraci,
                      baslik: baslik,
                      icerik: icerik,
                    ).toMap());

                    if (context.mounted) Navigator.pop(ctx);
                  },
                  child: const Text("Kuantum Ağına Gönder", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}