import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:otodna/core/siber_tema.dart';
import 'package:otodna/core/responsive_kalkan.dart';

/// 👁️ SİBER İSTİHBARAT LOGLARI (SİSTEM KARA KUTUSU)
/// Sistemdeki tüm kritik olayların (para transferi, kayıtlar, hileli işlemler) gerçek zamanlı aktığı terminal.
class SiberIstihbaratLoglari extends StatefulWidget {
  const SiberIstihbaratLoglari({super.key});

  @override
  State<SiberIstihbaratLoglari> createState() => _SiberIstihbaratLoglariState();
}

class _SiberIstihbaratLoglariState extends State<SiberIstihbaratLoglari> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String _filtre = "TÜMÜ"; // TÜMÜ, FİNANS, GÜVENLİK, KULLANICI

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20), onPressed: () => context.pop()),
          title: Text("SİBER İSTİHBARAT AĞI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 2.0, fontSize: 13)),
          centerTitle: true,
          actions: [
            PopupMenuButton<String>(
              icon: Icon(Icons.filter_list, color: SiberTema.kuantumCyan),
              color: SiberTema.oledBlack,
              onSelected: (val) => setState(() => _filtre = val),
              itemBuilder: (context) => [
                PopupMenuItem(value: "TÜMÜ", child: Text("Tüm Sinyaller", style: TextStyle(color: Colors.white))),
                PopupMenuItem(value: "FİNANS", child: Text("Finansal Sinyaller", style: TextStyle(color: SiberTema.siberGold))),
                PopupMenuItem(value: "GÜVENLİK", child: Text("Güvenlik İhlalleri", style: TextStyle(color: SiberTema.kanKirmizi))),
              ],
            )
          ],
        ),
        body: Column(
          children: [
            // SİBER RADAR BAŞLIĞI
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: SiberTema.kuantumCyan.withOpacity(0.3)))),
              child: Row(
                children: [
                  Icon(Icons.radar, color: SiberTema.kuantumCyan, size: 28),
                  const SizedBox(width: 12),
                  Text("CANLI LOG AKIŞI: $_filtre", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
                ],
              ),
            ),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _db.collection('sistem_loglari').orderBy('tarih', descending: true).limit(50).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Text("SİNYAL YOK", style: TextStyle(color: Colors.white54, letterSpacing: 2)));

                  var loglar = snapshot.data!.docs;
                  if (_filtre != "TÜMÜ") {
                    loglar = loglar.where((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      String tur = data['islem_turu'] ?? '';
                      if (_filtre == "FİNANS") return tur.contains("FINANS") || tur.contains("HAKEDIS");
                      if (_filtre == "GÜVENLİK") return tur.contains("IHLAL") || tur.contains("BLACK_STAR");
                      return true;
                    }).toList();
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: loglar.length,
                    itemBuilder: (context, index) {
                      var data = loglar[index].data() as Map<String, dynamic>;
                      return _buildSiberLogSatiri(data);
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSiberLogSatiri(Map<String, dynamic> data) {
    String tur = data['islem_turu'] ?? 'SİNYAL';
    String detay = data['islem_detayi'] ?? 'Bilinmeyen işlem';
    Timestamp? ts = data['tarih'] as Timestamp?;
    String saat = ts != null ? DateFormat('HH:mm:ss').format(ts.toDate()) : '--:--:--';

    Color islemRengi = SiberTema.kuantumCyan;
    if (tur.contains("FINANS") || tur.contains("HAKEDIS")) islemRengi = SiberTema.siberGold;
    if (tur.contains("IHLAL") || tur.contains("BLACK_STAR") || tur.contains("HATA")) islemRengi = SiberTema.kanKirmizi;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SiberTema.matGrey.withOpacity(0.5),
        border: Border(left: BorderSide(color: islemRengi, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(saat, style: TextStyle(color: Colors.white54, fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tur, style: TextStyle(color: islemRengi, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                const SizedBox(height: 4),
                Text(detay, style: TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'monospace')),
              ],
            ),
          )
        ],
      ),
    );
  }
}
