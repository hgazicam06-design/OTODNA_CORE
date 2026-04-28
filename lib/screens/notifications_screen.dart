import 'package:otodna/core/siber_tema.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

/// 🦅 OTO DNA SİBER SİNYAL MERKEZİ - BİLDİRİM VE TAKİP RADARI
/// [2026-03-28] GÜNCELLEME: ATOMİK BATCH MÜHÜRLEME SİSTEMİ
class NotificationsScreen extends StatefulWidget {
  NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  // 🚀 FİREBASE: TÜM SİNYALLERİ OKUNDU OLARAK MÜHÜRLE (ATOMİK BATCH)
  Future<void> _tumuOkunduIsaretle() async {
    if (_user == null) return;

    try {
      var snapshot = await _db.collection('kullanicilar')
          .doc(_user!.uid)
          .collection('bildirimler')
          .where('okundu', isEqualTo: false)
          .get();

      if (snapshot.docs.isEmpty) {
        _siberMesajGoster("RADAR TEMİZ: OKUNMAMIŞ SİNYAL BULUNMUYOR.", isError: false);
        return;
      }

      // Kuantum Ağı: Çoklu veriyi tek bir atomik işlemle güncelle
      WriteBatch batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'okundu': true});
      }
      await batch.commit();

      _siberMesajGoster("TÜM SİBER SİNYALLER MÜHÜRLENDİ! 🦅");
    } catch (e) {
      _siberMesajGoster("AĞ İLETİŞİM HATASI: $e", isError: true);
    }
  }

  void _siberMesajGoster(String mesaj, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
        backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(
        backgroundColor: SiberTema.oledBlack,
        body: Center(child: Text("SİBER İHLAL: KİMLİK BULUNAMADI!", style: TextStyle(color: SiberTema.kanKirmizi, fontWeight: FontWeight.w900))),
      );
    }

    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20), onPressed: () => Navigator.pop(context)),
          title: Text("SİBER SİNYAL MERKEZİ", style: TextStyle(color: SiberTema.textMuted, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.done_all, color: SiberTema.kuantumCyan),
              onPressed: _tumuOkunduIsaretle,
              tooltip: "TÜMÜNÜ MÜHÜRLE",
            )
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 800),
            child: StreamBuilder<QuerySnapshot>(
              stream: _db.collection('kullanicilar')
                  .doc(_user!.uid)
                  .collection('bildirimler')
                  .orderBy('tarih', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildBosDurum();
                }

                return ListView.builder(
                  padding: EdgeInsets.all(24),
                  physics: BouncingScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    var data = doc.data() as Map<String, dynamic>;
                    return _buildSinyalKarti(
                        doc.id,
                        data['baslik'] ?? 'SİNYAL',
                        data['mesaj'] ?? '-',
                        data['tip'] ?? 'SISTEM',
                        data['okundu'] ?? false
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBosDurum() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.radar, color: SiberTema.kuantumCyan.withOpacity(0.1), size: 100),
          SizedBox(height: 24),
          Text("RADAR TEMİZ", style: TextStyle(color: SiberTema.textMuted, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 4)),
        ],
      ),
    );
  }

  Widget _buildSinyalKarti(String id, String baslik, String mesaj, String tip, bool okundu) {
    IconData icon;
    Color iconColor;

    switch (tip) {
      case "ODEME": icon = Icons.account_balance_wallet; iconColor = SiberTema.kuantumCyan; break;
      case "RANDEVU": icon = Icons.calendar_today; iconColor = Colors.blueAccent; break;
      case "SOS": icon = Icons.warning_amber_rounded; iconColor = SiberTema.kanKirmizi; break;
      default: icon = Icons.memory; iconColor = Colors.white54;
    }

    return InkWell(
      onTap: () async {
        if (!okundu) {
          await _db.collection('kullanicilar').doc(_user!.uid).collection('bildirimler').doc(id).update({'okundu': true});
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: okundu ? SiberTema.matGrey.withOpacity(0.05) : SiberTema.kuantumCyan.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: okundu ? Colors.white10 : SiberTema.kuantumCyan.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(baslik.toUpperCase(), style: TextStyle(color: okundu ? Colors.white70 : Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  SizedBox(height: 8),
                  Text(mesaj, style: TextStyle(color: okundu ? Colors.white24 : Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, height: 1.4)),
                ],
              ),
            ),
            if (!okundu)
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(color: SiberTema.kuantumCyan, shape: BoxShape.circle, boxShadow: [BoxShadow(color: SiberTema.kuantumCyan, blurRadius: 8)]),
              )
          ],
        ),
      ),
    );
  }
}