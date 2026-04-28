import 'package:otodna/core/siber_tema.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/siber_tema.dart';

class AdminDashboardVisual extends StatefulWidget {
  AdminDashboardVisual({super.key});

  @override
  State<AdminDashboardVisual> createState() => _AdminDashboardVisualState();
}

class _AdminDashboardVisualState extends State<AdminDashboardVisual> {
  // 🏢 ULTRA PROFESYONEL KURUMSAL PALET (PLATINUM WEB DASHBOARD)
  final Color bgColor = SiberTema.oledBlack; // Fildişi Arka Plan
  final Color surfaceColor = SiberTema.matGrey; // Beyaz Yüzey
  final Color primaryTeal = SiberTema.kuantumCyan; // Kurumsal Zümrüt
  final Color dangerColor = SiberTema.kanKirmizi; // Kurumsal Kırmızı

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Row(
        children: [
          // =================================================================
          // 1. SOL KURUMSAL MENÜ (NAVİGASYON)
          // =================================================================
          _buildSideMenu(),

          // =================================================================
          // 2. ANA TERMİNAL PANELİ
          // =================================================================
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(40),
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopHeader(),
                  SizedBox(height: 40),
                  _buildStatCards(),
                  SizedBox(height: 40),
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
        border: Border(right: BorderSide(color: Colors.black.withOpacity(0.05))),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: Offset(4, 0))],
      ),
      child: Column(
        children: [
          SizedBox(height: 40),
          // LOGO ALANI
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.radar, color: primaryTeal, size: 28),
              ),
              SizedBox(width: 12),
              Text("OTODNA", style: TextStyle(color: SiberTema.textMain, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 4, fontFamily: 'Avenir')),
            ],
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: primaryTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text("MERKEZ KARARGAH", style: TextStyle(color: primaryTeal, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
          ),
          SizedBox(height: 60),

          // MENÜ BUTONLARI
          _buildMenuButton(Icons.dashboard_outlined, "Ağ Özeti", true),
          _buildMenuButton(Icons.account_balance_wallet_outlined, "Finans Merkezi", false),
          _buildMenuButton(Icons.verified_user_outlined, "Bayi Yönetimi", false),
          _buildMenuButton(Icons.gpp_bad_outlined, "Kara Liste", false),

          Spacer(),
          Divider(color: Colors.black12, height: 1),
          _buildMenuButton(Icons.logout, "Güvenli Çıkış", false, isDanger: true),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuButton(IconData ikon, String baslik, bool isAktif, {bool isDanger = false}) {
    Color renk = isDanger ? dangerColor : (isAktif ? primaryTeal : SiberTema.textMuted);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isAktif ? primaryTeal.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isAktif ? Border.all(color: primaryTeal.withOpacity(0.2)) : Border.all(color: Colors.transparent),
      ),
      child: ListTile(
        leading: Icon(ikon, color: renk, size: 20),
        title: Text(baslik, style: TextStyle(color: renk, fontSize: 13, fontWeight: isAktif ? FontWeight.w900 : FontWeight.bold, letterSpacing: 0.5, fontFamily: 'Avenir')),
        onTap: () {},
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        hoverColor: isDanger ? dangerColor.withOpacity(0.05) : Colors.black.withOpacity(0.02),
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
            Text("Merkez Yönetim Paneli", style: TextStyle(color: SiberTema.textMain, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 0.5, fontFamily: 'Avenir')),
            SizedBox(height: 8),
            Row(
              children: [
                Container(padding: EdgeInsets.all(4), decoration: BoxDecoration(color: primaryTeal, shape: BoxShape.circle)),
                SizedBox(width: 8),
                Text("SİSTEM ÇEVRİMİÇİ | ANKARA HQ", style: TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontFamily: 'Avenir')),
              ],
            )
          ],
        ),
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(32), border: Border.all(color: Colors.black.withOpacity(0.05)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
          child: Row(
            children: [
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Komutan Gazi", style: TextStyle(color: SiberTema.textMain, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                  Text("Siber CTO", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                ],
              ),
              SizedBox(width: 16),
              Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: primaryTeal.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: primaryTeal.withOpacity(0.2))), child: Icon(Icons.security, color: primaryTeal, size: 20)),
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
        Expanded(child: _buildSingleStat("SİBER KASA (NET KÂR)", "₺1.250.400", Icons.account_balance_wallet, primaryTeal, "+%14 Bu Ay")),
        SizedBox(width: 24),
        Expanded(child: _buildSingleStat("AKTİF BAYİ AĞI", "124 Nokta", Icons.share_location_outlined, Color(0xFFF57F17), "8 Yeni Katılım")),
        SizedBox(width: 24),
        Expanded(child: _buildSingleStat("İŞLEM HACMİ", "4.8M TL", Icons.data_usage, Color(0xFF1565C0), "Son 30 Gün")),
        SizedBox(width: 24),
        Expanded(child: _buildSingleStat("KARA LİSTE", "12 Engelli", Icons.gpp_bad_outlined, dangerColor, "Güvenlik İhlali")),
      ],
    );
  }

  Widget _buildSingleStat(String baslik, String deger, IconData ikon, Color renk, String altBilgi) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(baslik, style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
              Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: renk.withOpacity(0.1), shape: BoxShape.circle), child: Icon(ikon, color: renk, size: 20)),
            ],
          ),
          SizedBox(height: 24),
          Text(deger, style: TextStyle(color: SiberTema.textMain, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1, fontFamily: 'Avenir')),
          SizedBox(height: 8),
          Text(altBilgi, style: TextStyle(color: renk.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // 💎 YARDIMCI BİLEŞENLER: FİREBASE LİYAKAT TABLOSU
  // -------------------------------------------------------------------------
  Widget _buildDealerTable() {
    return Container(
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.black.withOpacity(0.05)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("BAYİ PERFORMANS AĞI", style: TextStyle(color: SiberTema.textMain, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
              Container(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: primaryTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: primaryTeal.withOpacity(0.3))), child: Text("CANLI VERİ", style: TextStyle(color: primaryTeal, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir'))),
            ],
          ),
          SizedBox(height: 24),
          Divider(color: Colors.black12),
          SizedBox(height: 12),

          // TABLO BAŞLIKLARI
          Row(
            children: [
              Expanded(flex: 2, child: Text("BAYİ ÜNVANI", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir'))),
              Expanded(flex: 1, child: Text("LOKASYON", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir'))),
              Expanded(flex: 1, child: Text("LİYAKAT", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir'))),
              Expanded(flex: 1, child: Text("DURUM", textAlign: TextAlign.right, style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir'))),
            ],
          ),
          SizedBox(height: 16),

          // 🚀 FİREBASE CANLI TABLO
          StreamBuilder<QuerySnapshot>(
              stream: _db.collection('bayiler').orderBy('puan', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: primaryTeal)));

                // Eğer veritabanı boşsa Mock listeyi göster
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Column(
                    children: [
                      _buildDealerRow("GAZİ OTOMOTİV HQ", "Ankara, Merkez", "ELİT KADEME", Color(0xFFF57F17), 5),
                      _buildDealerRow("OTODNA İSTANBUL", "İstanbul, Maslak", "GÜMÜŞ AĞ", Colors.blueGrey, 4),
                      _buildDealerRow("İZMİR KUVVETLERİ", "İzmir, Bornova", "STANDART", primaryTeal, 3),
                      _buildDealerRow("XYZ MERDİVENALTI", "Bilinmiyor", "KARA LİSTE", dangerColor, 1),
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
                    Color renk = primaryTeal;

                    if (puan == 5) { durum = "ELİT KADEME"; renk = Color(0xFFF57F17); }
                    else if (puan == 4) { durum = "GÜMÜŞ AĞ"; renk = Colors.blueGrey; }
                    else if (puan <= 1) { durum = "KARA LİSTE"; renk = dangerColor; }

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
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black.withOpacity(0.02))),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(name.toUpperCase(), style: TextStyle(color: color == dangerColor ? dangerColor : SiberTema.textMain, fontSize: 13, fontWeight: FontWeight.bold, decoration: color == dangerColor ? TextDecoration.lineThrough : TextDecoration.none, fontFamily: 'Avenir'))),
          Expanded(flex: 1, child: Row(children: [Icon(Icons.location_on_outlined, color: SiberTema.textMuted, size: 14), SizedBox(width: 6), Text(city, style: TextStyle(color: SiberTema.textMuted, fontSize: 12, fontFamily: 'Avenir'))])),
          Expanded(flex: 1, child: Row(children: List.generate(5, (i) => Icon(i < stars ? Icons.star : Icons.star_border, color: i < stars ? color : Colors.black12, size: 16)))),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.3))),
                child: Text(status, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}