import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnkaraMerkezAdmin extends StatefulWidget {
  const AnkaraMerkezAdmin({super.key});

  @override
  State<AnkaraMerkezAdmin> createState() => _AnkaraMerkezAdminState();
}

class _AnkaraMerkezAdminState extends State<AnkaraMerkezAdmin> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  static const Color bgColor = Color(0xFF000000);
  static const Color surfaceColor = Color(0xFF111111);
  static const Color primaryCyan = Color(0xFF00FFC2);
  static const Color dangerColor = Colors.redAccent;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('A N K A R A   M E R K E Z   K A R A R G A H', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2)),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: dangerColor.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: dangerColor.withOpacity(0.5))),
            child: const Icon(Icons.security, color: dangerColor, size: 16),
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =================================================================
            // 1. 81 İL VE %12 KÂR ÖZETİ (Acımasız Kuantum Kesintisi)
            // =================================================================
            Row(
              children: [
                Expanded(child: _buildAdminStat("TÜRKİYE CİRO AĞI", "₺2.450.000", Colors.white, Icons.account_balance_wallet_outlined)),
                const SizedBox(width: 16),
                Expanded(child: _buildAdminStat("SİBER KÂR (%12)", "₺294.000", primaryCyan, Icons.diamond_outlined)),
              ],
            ),
            const SizedBox(height: 32),

            // =================================================================
            // 2. ONAY BEKLEYEN BAYİLER (Canlı Firebase Bağlantısı)
            // =================================================================
            Row(
              children: [
                Icon(Icons.hourglass_top, color: Colors.white.withOpacity(0.3), size: 20),
                const SizedBox(width: 12),
                const Text("ONAY BEKLEYEN BAYİ BAŞVURULARI", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              ],
            ),
            const SizedBox(height: 16),

            // 🚀 FİREBASE: CANLI VERİTABANI DİNLEYİCİSİ
            StreamBuilder<QuerySnapshot>(
                stream: _db.collection('bayi_basvurulari').where('durum', isEqualTo: 'Bekliyor').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: primaryCyan)));
                  }

                  // 🛡️ SİBER KALKAN: Eğer ağda hata varsa veya veri yoksa
                  if (snapshot.hasError) {
                    return const Padding(padding: EdgeInsets.all(20), child: Text("AĞ İHLALİ: Veritabanına ulaşılamıyor.", style: TextStyle(color: dangerColor, fontWeight: FontWeight.bold)));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    // Veri yoksa bile Karargah boş durmasın, Kripto Otonom Mesaj göstersin
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
                      child: const Column(
                        children: [
                          Icon(Icons.radar, color: Colors.white12, size: 48),
                          SizedBox(height: 16),
                          Text("RADAR TEMİZ", style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w900, letterSpacing: 2)),
                          Text("Onay bekleyen siber sinyal bulunmuyor.", style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  }

                  // 🚀 GERÇEK FİREBASE VERİSİ EKRANA BASILIYOR
                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      String bayiIsmi = data['isim'] ?? 'İSİMSİZ BAYİ';
                      return _buildApprovalItem(
                          bayiIsmi,
                          data['bolge'] ?? 'BİLİNMEYEN BÖLGE',
                          data['not'] ?? 'İNCELEME BEKLİYOR',
                          primaryCyan,
                          doc.id // Firebase belge ID'si (Mühürleme işlemi için)
                      );
                    }).toList(),
                  );
                }
            ),
            const SizedBox(height: 40),

            // =================================================================
            // 3. GLOBAL HARİTA BUTONU
            // =================================================================
            SizedBox(
              width: double.infinity, height: 64,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: surfaceColor,
                  foregroundColor: primaryCyan,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryCyan.withOpacity(0.3))),
                ),
                icon: const Icon(Icons.public, size: 24),
                label: const Text("KÜRESEL DİSTRİBÜTÖR HARİTASINA GEÇİŞ YAP", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("GLOBAL UYDU BAĞLANTISI KURULUYOR... 🌍", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: primaryCyan));
                  // TODO: Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminGlobalPanel()));
                },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: SİBER İSTATİSTİK KARTI
  Widget _buildAdminStat(String title, String val, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 24)),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(val, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        ],
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: ONAY SATIRI VE MÜHÜRLEME MOTORU
  Widget _buildApprovalItem(String isim, String bolge, String durum, Color durumRengi, String docId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: durumRengi.withOpacity(0.3))),
            child: Icon(Icons.business_outlined, color: durumRengi, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isim.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text(bolge.toUpperCase(), style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(durum.toUpperCase(), style: TextStyle(color: durumRengi.withOpacity(0.8), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryCyan.withOpacity(0.1),
              foregroundColor: primaryCyan,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: primaryCyan.withOpacity(0.5))),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text("MÜHÜRLE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
            onPressed: () async {
              // 🚀 GERÇEK ONAY MOTORU (Firebase Update)
              try {
                await _db.collection('bayi_basvurulari').doc(docId).update({'durum': 'Onaylandi'});
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$isim KUANTUM AĞINA MÜHÜRLENDİ! 🦅", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: primaryCyan));
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("SİBER İHLAL: Mühürleme Başarısız!", style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: dangerColor));
              }
            },
          ),
        ],
      ),
    );
  }
}