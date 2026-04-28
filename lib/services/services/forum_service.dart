import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM SOSYAL GARAJ (Canlı Forum Arayüzü)
/// Maket verileri reddeder, doğrudan Firebase'den akarak Siber Cam (Glassmorphism) içinde listeler.
class ForumMainPage extends StatelessWidget {
  ForumMainPage({super.key});

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 🌑 Derin Karargah Siyahı
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
            "OtoDNA Sosyal Garaj",
            style: TextStyle(color: Color(0xFF00FFC2), fontWeight: FontWeight.bold, letterSpacing: 1.5) // Kuantum Turkuazı
        ),
        iconTheme: IconThemeData(color: Color(0xFF00FFC2)),
      ),
      // 📡 SİBER RADAR: Firebase'den canlı veri akışı (Maket Yok!)
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('sosyal_garaj').orderBy('tarih', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("SİBER AĞ ÇÖKTÜ!", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Color(0xFF00FFC2)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("KARARGAH GARAJI ŞU AN BOŞ", style: TextStyle(color: Colors.white54, letterSpacing: 2)));
          }

          return ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              return _forumPostCard(snapshot.data!.docs[index]);
            },
          );
        },
      ),
      // 🚀 Kuantum Ateşleme Butonu
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF00FFC2), // Neon Turkuaz
        elevation: 10,
        onPressed: () {
          developer.log("SİBER HAREKAT: Yeni Soru Sorma Mühimmatı hazırlandı!");
          // Navigator.push ile hedef ekrana yönlendirilecek
        },
        child: Icon(Icons.add_comment, color: Colors.black, size: 28),
      ),
    );
  }

  // ── 💎 SİBER CAM EFEKTİ (GLASSMORPHISM) İLE ZIRHLANMIŞ KART ──────────────
  Widget _forumPostCard(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>? ?? {};

    // Güvenlik Kalkanı: Veri boşsa varsayılan değerleri bas
    String grup = data['grup'] ?? "KAYITSIZ BÖLGE";
    String baslik = data['baslik'] ?? "İstihbarat Bekleniyor";
    String icerik = data['icerik'] ?? "Siber sinyal okunamadı...";
    int ayniDert = data['ayni_dert_sayisi'] ?? 0;
    bool ustaCevapladi = data['usta_cevapladi'] ?? false;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), // 🌫️ Siber Bulanıklık
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03), // Cam Zemin
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Color(0xFF00FFC2).withValues(alpha: 0.3), width: 1.5), // Turkuaz Çerçeve
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    grup.toUpperCase(),
                    style: TextStyle(color: Color(0xFF00FFC2), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)
                ),
                SizedBox(height: 8),
                Text(
                    baslik,
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                ),
                SizedBox(height: 8),
                Text(
                    icerik,
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(color: Colors.white24, thickness: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 🤝 Aynı Dert Butonu
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        developer.log("SİBER ETKİLEŞİM: 'Benimle Aynı' sinyali fırlatıldı.");
                        // SİBER NOT: Burada Firebase Update (Atomik Artış) tetiklenecek
                      },
                      icon: Icon(Icons.handshake_outlined, size: 20, color: Color(0xFF00FFC2)),
                      label: Text("Benimle Aynı ($ayniDert)", style: TextStyle(color: Color(0xFF00FFC2), fontWeight: FontWeight.bold)),
                    ),

                    // ✅ Siber Usta Onayı (Şartlı Gösterim)
                    if (ustaCevapladi)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.verified_user_outlined, color: Colors.greenAccent, size: 14),
                            SizedBox(width: 4),
                            Text("USTA BİLDİRDİ", style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}