import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  static const Color bgColor = Color(0xFF000000);
  static const Color surfaceColor = Color(0xFF111111);
  static const Color primaryCyan = Color(0xFF00FFC2);
  static const Color dangerColor = Colors.redAccent;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  // 🚀 FİREBASE: TÜM SİNYALLERİ OKUNDU OLARAK İŞARETLE (ATOMİK BATCH)
  Future<void> _tumuOkunduIsaretle() async {
    if (_user == null) return;

    try {
      var snapshot = await _db.collection('kullanicilar')
          .doc(_user!.uid)
          .collection('bildirimler')
          .where('okundu', isEqualTo: false)
          .get();

      if (snapshot.docs.isEmpty) {
        _uyariGoster("RADAR TEMİZ: OKUNMAMIŞ SİNYAL BULUNMUYOR.", isError: false);
        return;
      }

      // Kuantum Ağı: Çoklu veriyi tek seferde güncelle
      WriteBatch batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'okundu': true});
      }
      await batch.commit();

      _uyariGoster("TÜM SİBER SİNYALLER OKUNDU OLARAK MÜHÜRLENDİ! 🦅");
    } catch (e) {
      _uyariGoster("AĞ ÇÖKTÜ: Sinyaller güncellenemedi!", isError: true);
    }
  }

  void _uyariGoster(String mesaj, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, color: Colors.black)),
        backgroundColor: isError ? dangerColor : primaryCyan,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(
        backgroundColor: bgColor,
        body: Center(child: Text("SİBER İHLAL: KULLANICI KİMLİĞİ BULUNAMADI!", style: TextStyle(color: dangerColor, fontWeight: FontWeight.w900, letterSpacing: 2))),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: primaryCyan, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text("SİBER SİNYAL MERKEZİ", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: primaryCyan),
            onPressed: _tumuOkunduIsaretle,
            tooltip: "TÜMÜNÜ MÜHÜRLE",
          )
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800), // 🖥️ Web / Double Teyp Kalkanı
            child: StreamBuilder<QuerySnapshot>(
              stream: _db.collection('kullanicilar')
                  .doc(_user!.uid)
                  .collection('bildirimler')
                  .orderBy('tarih', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: primaryCyan));
                }

                // EĞER HİÇ BİLDİRİM YOKSA (Sıfır Durumu)
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.radar, color: primaryCyan.withOpacity(0.2), size: 80),
                        const SizedBox(height: 24),
                        const Text("RADAR TEMİZ", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 4)),
                        const SizedBox(height: 8),
                        const Text("GELEN BİR SİBER SİNYAL BULUNMUYOR", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      ],
                    ),
                  );
                }

                // 🚀 GERÇEK FİREBASE VERİSİ
                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  physics: const BouncingScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    var data = doc.data() as Map<String, dynamic>;

                    String baslik = data['baslik'] ?? 'BİLİNMEYEN SİNYAL';
                    String mesaj = data['mesaj'] ?? 'Detay yok.';
                    String tip = data['tip'] ?? 'SISTEM';
                    bool okundu = data['okundu'] ?? false;

                    return _buildBildirimKarti(doc.id, baslik, mesaj, tip, okundu);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: SİBER SİNYAL KARTI
  Widget _buildBildirimKarti(String id, String baslik, String mesaj, String tip, bool okundu) {
    IconData icon;
    Color iconColor;

    // Gelen sinyalin tipine göre dinamik renk ve ikon ataması
    switch (tip) {
      case "ODEME":
        icon = Icons.account_balance_wallet;
        iconColor = primaryCyan;
        break;
      case "RANDEVU":
        icon = Icons.calendar_today;
        iconColor = Colors.blueAccent;
        break;
      case "SOS":
        icon = Icons.warning_amber_rounded;
        iconColor = dangerColor;
        break;
      default:
        icon = Icons.memory;
        iconColor = Colors.white54;
    }

    return InkWell(
      onTap: () async {
        // Okunmamışsa tıklandığında anında Firebase'de okundu olarak mühürler
        if (!okundu) {
          await _db.collection('kullanicilar').doc(_user!.uid).collection('bildirimler').doc(id).update({'okundu': true});
        }
        _uyariGoster("SİNYAL DETAYI: $baslik", isError: false);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: okundu ? surfaceColor : primaryCyan.withOpacity(0.05), // Okunmamış olan parlar
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: okundu ? Colors.white.withOpacity(0.05) : primaryCyan.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(baslik.toUpperCase(), style: TextStyle(color: okundu ? Colors.white70 : Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Text(mesaj, style: TextStyle(color: okundu ? Colors.white38 : Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, height: 1.5)),
                ],
              ),
            ),
            // Okunmamış mesajlar için parlayan Kuantum Işığı
            if (!okundu)
              Container(
                margin: const EdgeInsets.only(left: 12, top: 4),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: primaryCyan, shape: BoxShape.circle, boxShadow: [BoxShadow(color: primaryCyan, blurRadius: 6)]),
              )
          ],
        ),
      ),
    );
  }
}