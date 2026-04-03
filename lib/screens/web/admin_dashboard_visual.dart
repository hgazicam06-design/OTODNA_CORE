import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardVisual extends StatefulWidget {
  const AdminDashboardVisual({super.key});

  @override
  State<AdminDashboardVisual> createState() => _AdminDashboardVisualState();
}

class _AdminDashboardVisualState extends State<AdminDashboardVisual> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  final Color bgColor = const Color(0xFF000000);
  final Color surfaceColor = const Color(0xFF111111);
  final Color primaryCyan = const Color(0xFF00FFC2);

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Row(
        children: [
          // =================================================================
          // 1. SOL SİBER MENÜ (NAVİGASYON)
          // =================================================================
          _buildSideMenu(),

          // =================================================================
          // 2. ANA TERMİNAL PANELİ
          // =================================================================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopHeader(),
                  const SizedBox(height: 40),
                  _buildStatCards(),
                  const SizedBox(height: 40),
                  _buildDealerTable(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // 💎 YARDIMCI BİLEŞENLER: SOL MENÜ
  // -------------------------------------------------------------------------
  Widget _buildSideMenu() {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // LOGO ALANI
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.radar, color: primaryCyan, size: 32),
              const SizedBox(width: 12),
              const Text("O T O D N A", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 4)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text("MERKEZ KARARGAH", style: TextStyle(color: primaryCyan, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2)),
          ),
          const SizedBox(height: 60),

          // MENÜ BUTONLARI
          _buildMenuButton(Icons.dashboard_outlined, "Siber Ağ Özeti", true),
          _buildMenuButton(Icons.account_balance_wallet_outlined, "OtoDNA Siber Kasa", false),
          _buildMenuButton(Icons.verified_user_outlined, "Liyakat & Bayiler", false),
          _buildMenuButton(Icons.gpp_bad_outlined, "Kara Liste Yönetimi", false),

          const Spacer(),
          const Divider(color: Colors.white12),
          _buildMenuButton(Icons.logout, "Ağdan Çıkış Yap", false, isDanger: true),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuButton(IconData ikon, String baslik, bool isAktif, {bool isDanger = false}) {
    Color renk = isDanger ? Colors.redAccent : (isAktif ? primaryCyan : Colors.white54);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isAktif ? primaryCyan.withOpacity(0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isAktif ? Border.all(color: primaryCyan.withOpacity(0.3)) : Border.all(color: Colors.transparent),
      ),
      child: ListTile(
        leading: Icon(ikon, color: renk, size: 20),
        title: Text(baslik, style: TextStyle(color: renk, fontSize: 13, fontWeight: isAktif ? FontWeight.w900 : FontWeight.bold, letterSpacing: 0.5)),
        onTap: () {},
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        hoverColor: isDanger ? Colors.redAccent.withOpacity(0.1) : Colors.white.withOpacity(0.05),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // 💎 YARDIMCI BİLEŞENLER: ÜST BAŞLIK
  // -------------------------------------------------------------------------
  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("OTODNA MERKEZ YÖNETİM", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1)),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: primaryCyan, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                const Text("SİSTEM ÇEVRİMİÇİ | DİSTRİBÜTÖR: GAZİ | ANKARA HQ", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ],
            )
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(32), border: Border.all(color: Colors.white.withOpacity(0.05))),
          child: Row(
            children: [
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Komutan Gazi", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  Text("Siber CTO", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ],
              ),
              const SizedBox(width: 16),
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: primaryCyan.withOpacity(0.5))), child: Icon(Icons.security, color: primaryCyan, size: 20)),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // 💎 YARDIMCI BİLEŞENLER: İSTATİSTİK KARTLARI
  // -------------------------------------------------------------------------
  Widget _buildStatCards() {
    return Row(
      children: [
        Expanded(child: _buildSingleStat("SİBER KASA (NET KÂR)", "₺1.250.400", Icons.account_balance_wallet, primaryCyan, "+%14 Bu Ay")),
        const SizedBox(width: 24),
        Expanded(child: _buildSingleStat("AKTİF BAYİ AĞI", "124 Nokta", Icons.share_location_outlined, Colors.amber, "8 Yeni Katılım")),
        const SizedBox(width: 24),
        Expanded(child: _buildSingleStat("KUANTUM İŞLEM HACMİ", "4.8M TL", Icons.data_usage, Colors.blueAccent, "Son 30 Gün")),
        const SizedBox(width: 24),
        Expanded(child: _buildSingleStat("KARA LİSTE", "12 Engelli", Icons.gpp_bad_outlined, Colors.redAccent, "Güvenlik İhlali")),
      ],
    );
  }

  Widget _buildSingleStat(String baslik, String deger, IconData ikon, Color renk, String altBilgi) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: renk.withOpacity(0.02), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(baslik, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
              Icon(ikon, color: renk, size: 20),
            ],
          ),
          const SizedBox(height: 24),
          Text(deger, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1)),
          const SizedBox(height: 8),
          Text(altBilgi, style: TextStyle(color: renk.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // 💎 YARDIMCI BİLEŞENLER: FİREBASE LİYAKAT TABLOSU
  // -------------------------------------------------------------------------
  Widget _buildDealerTable() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("BAYİ LİYAKAT VE PERFORMANS AĞI", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: primaryCyan.withOpacity(0.5))), child: const Text("CANLI VERİ AKIŞI", style: TextStyle(color: primaryCyan, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1))),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),

          // TABLO BAŞLIKLARI
          Row(
            children: [
              Expanded(flex: 2, child: Text("BAYİ ÜNVANI", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1))),
              Expanded(flex: 1, child: Text("LOKASYON", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1))),
              Expanded(flex: 1, child: Text("DNA LİYAKATI", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1))),
              Expanded(flex: 1, child: Text("SİBER DURUM", textAlign: TextAlign.right, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1))),
            ],
          ),
          const SizedBox(height: 16),

          // 🚀 FİREBASE CANLI TABLO
          StreamBuilder<QuerySnapshot>(
              stream: _db.collection('bayiler').orderBy('puan', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: primaryCyan)));

                // Eğer veritabanı boşsa geçici görsel (Mock) listeyi Kuantum formatında göster
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Column(
                    children: [
                      _buildDealerRow("GAZİ OTOMOTİV HQ", "Ankara, Merkez", "ELİT KADEME", Colors.amber, 5),
                      _buildDealerRow("OTODNA İSTANBUL", "İstanbul, Maslak", "GÜMÜŞ AĞ", Colors.blueGrey, 4),
                      _buildDealerRow("İZMİR KUVVETLERİ", "İzmir, Bornova", "STANDART", Colors.orangeAccent, 3),
                      _buildDealerRow("XYZ MERDİVENALTI", "Bilinmiyor", "KARA LİSTE", Colors.redAccent, 1),
                    ],
                  );
                }

                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    String ad = data['ad'] ?? 'İsimsiz Bayi';
                    String sehir = data['sehir'] ?? 'Bilinmiyor';
                    int puan = data['puan'] ?? 3;

                    String durum = "STANDART";
                    Color renk = Colors.orangeAccent;

                    if (puan == 5) { durum = "ELİT KADEME"; renk = Colors.amber; }
                    else if (puan == 4) { durum = "GÜMÜŞ AĞ"; renk = Colors.blueGrey; }
                    else if (puan <= 1) { durum = "KARA LİSTE"; renk = Colors.redAccent; }

                    return _buildDealerRow(ad, sehir, durum, renk, puan);
                  }).toList(),
                );
              }
          ),
        ],
      ),
    );
  }

  Widget _buildDealerRow(String name, String city, String status, Color color, int stars) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.02))),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(name.toUpperCase(), style: TextStyle(color: color == Colors.redAccent ? Colors.redAccent : Colors.white, fontSize: 13, fontWeight: FontWeight.bold, decoration: color == Colors.redAccent ? TextDecoration.lineThrough : TextDecoration.none))),
          Expanded(flex: 1, child: Row(children: [Icon(Icons.location_on_outlined, color: Colors.white24, size: 14), const SizedBox(width: 6), Text(city, style: const TextStyle(color: Colors.white54, fontSize: 12))])),
          Expanded(flex: 1, child: Row(children: List.generate(5, (i) => Icon(i < stars ? Icons.star : Icons.star_border, color: i < stars ? color : Colors.white12, size: 16)))),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.5))),
                child: Text(status, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}