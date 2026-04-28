import 'package:otodna/core/siber_tema.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🚀 KARARGAH ZIRHLARI VE TEMASI
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';
import '../../services/siber_istihbarat_log_motoru.dart';

class BayiBasvuruMerkeziScreen extends StatefulWidget {
  BayiBasvuruMerkeziScreen({super.key});

  @override
  State<BayiBasvuruMerkeziScreen> createState() => _BayiBasvuruMerkeziScreenState();
}

class _BayiBasvuruMerkeziScreenState extends State<BayiBasvuruMerkeziScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- 📡 FİREBASE: CANLI CİRO VE KÂR MOTORU ---
  // Ağdaki finansal_islemler tablosundan Gazi'nin %12'lik payını hesaplar
  Stream<Map<String, double>> _siberFinansRadar() {
    return _db.collection('finansal_islemler').snapshots().map((snapshot) {
      double toplamCiro = 0;
      double komutanPayi = 0;
      
      for (var doc in snapshot.docs) {
        var data = doc.data();
        toplamCiro += (data['brut_tutar'] ?? 0).toDouble();
        komutanPayi += (data['gazi_payi_12'] ?? 0).toDouble();
      }
      return {
        'ciro': toplamCiro,
        'kar': komutanPayi, 
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('B A Y İ   B A Ş V U R U   M E R K E Z İ',
              style: TextStyle(color: SiberTema.textMuted, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2)),
          centerTitle: true,
          actions: [
            Container(
              margin: EdgeInsets.only(right: 16),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: SiberTema.kanKirmizi.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: SiberTema.kanKirmizi.withOpacity(0.5))),
              child: Icon(Icons.security, color: SiberTema.kanKirmizi, size: 16),
            )
          ],
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =================================================================
              // 1. CANLI CİRO VE %12 KÂR ÖZETİ (FİNANSAL İŞLEMLERDEN)
              // =================================================================
              StreamBuilder<Map<String, double>>(
                  stream: _siberFinansRadar(),
                  builder: (context, snapshot) {
                    final data = snapshot.data ?? {'ciro': 0.0, 'kar': 0.0};
                    return Row(
                      children: [
                        Expanded(
                            child: _buildAdminStat("TÜRKİYE CİRO AĞI", "₺\${data['ciro']?.toStringAsFixed(0)}",
                                Colors.white, Icons.account_balance_wallet_outlined)),
                        SizedBox(width: 16),
                        Expanded(
                            child: _buildAdminStat("SİBER KÂR (%12)", "₺\${data['kar']?.toStringAsFixed(0)}",
                                SiberTema.kuantumCyan, Icons.diamond_outlined)),
                      ],
                    );
                  }
              ),
              SizedBox(height: 32),

              // =================================================================
              // 2. ONAY BEKLEYEN BAYİLER
              // =================================================================
              Row(
                children: [
                  Icon(Icons.hourglass_top, color: Colors.white.withOpacity(0.3), size: 20),
                  SizedBox(width: 12),
                  Text("ONAY BEKLEYEN BAYİ BAŞVURULARI",
                      style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                ],
              ),
              SizedBox(height: 16),

              StreamBuilder<QuerySnapshot>(
                  stream: _db.collection('bayi_basvurulari').where('durum', isEqualTo: 'Bekliyor').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: SiberTema.kuantumCyan)));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return _buildEmptyState();
                    }

                    return Column(
                      children: snapshot.data!.docs.map((doc) {
                        var data = doc.data() as Map<String, dynamic>;
                        return _buildApprovalItem(
                            data['isim'] ?? 'İSİMSİZ BAYİ',
                            data['bolge'] ?? 'BİLİNMEYEN BÖLGE',
                            data['not'] ?? 'İNCELEME BEKLİYOR',
                            doc.id);
                      }).toList(),
                    );
                  }),
              SizedBox(height: 40),

              // =================================================================
              // 3. GLOBAL HARİTA VE DENETİM BUTONU
              // =================================================================
              _buildGlobalMapButton(context),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
          color: SiberTema.matGrey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(
        children: [
          Icon(Icons.radar, color: SiberTema.textMuted, size: 50),
          SizedBox(height: 16),
          Text("RADAR TEMİZ", style: TextStyle(color: SiberTema.textMuted, fontWeight: FontWeight.w900, letterSpacing: 2)),
          Text("Ağda bekleyen bayi başvuru sinyali yok.", style: TextStyle(color: SiberTema.textMuted, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildAdminStat(String title, String val, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SiberTema.matGrey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.02), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: 16),
          Text(title, style: TextStyle(color: SiberTema.textMuted, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
          SizedBox(height: 6),
          Text(val, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -1)),
        ],
      ),
    );
  }

  Widget _buildApprovalItem(String isim, String bolge, String durum, String docId) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SiberTema.matGrey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: SiberTema.kuantumCyan.withOpacity(0.1),
            child: Icon(Icons.business_center, color: SiberTema.kuantumCyan, size: 18),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isim.toUpperCase(), style: TextStyle(color: SiberTema.textMain, fontSize: 12, fontWeight: FontWeight.w900)),
                Text(bolge.toUpperCase(), style: TextStyle(color: SiberTema.textMuted, fontSize: 9, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: SiberTema.kuantumCyan,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onPressed: () => _muhurle(docId, isim),
            child: Text("MÜHÜRLE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Future<void> _muhurle(String docId, String isim) async {
    try {
      WriteBatch batch = _db.batch();

      DocumentReference basvuruRef = _db.collection('bayi_basvurulari').doc(docId);
      batch.update(basvuruRef, {'durum': 'Onaylandi'});
      
      DocumentReference logRef = _db.collection('siber_istihbarat_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'YENI_BAYI_ONAYI',
        'islem_detayi': 'SİBER KOMUTAN: "$isim" yetkili bayi ağına eklendi.',
        'bayi_id': docId,
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("$isim SİBER AĞA MÜHÜRLENDİ! 🦅"),
          backgroundColor: SiberTema.kuantumCyan));
    } catch (e) {
      debugPrint("Mühürleme hatası: $e");
    }
  }

  Widget _buildGlobalMapButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: [SiberTema.kuantumCyan.withOpacity(0.1), Colors.transparent]),
        border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("GLOBAL HARİTA AKTİF EDİLİYOR..."))),
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.public, color: SiberTema.kuantumCyan, size: 20),
              SizedBox(width: 12),
              Text("KÜRESEL DİSTRİBÜTÖR HARİTASI", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            ],
          ),
        ),
      ),
    );
  }
}
