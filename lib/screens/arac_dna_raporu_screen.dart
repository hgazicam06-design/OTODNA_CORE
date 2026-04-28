import 'package:otodna/core/siber_tema.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

class AracDnaRaporuScreen extends StatefulWidget {
  final String plaka;
  AracDnaRaporuScreen({super.key, required this.plaka});

  @override
  State<AracDnaRaporuScreen> createState() => _AracDnaRaporuScreenState();
}

class _AracDnaRaporuScreenState extends State<AracDnaRaporuScreen> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 3 Sayfalık Siber DNA Kitapçığı: Sicil, Ekspertiz ve Revizyon
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: SiberTema.oledBlack,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: SiberTema.kuantumCyan),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "ULTRA DNA KİTAPÇIĞI",
            style: TextStyle(
              color: SiberTema.textMain.withOpacity(0.9),
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 1.5,
              fontFamily: 'Avenir',
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: SiberTema.kuantumCyan,
            indicatorWeight: 3,
            labelColor: SiberTema.kuantumCyan,
            unselectedLabelColor: Colors.white54,
            labelStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, fontFamily: 'Avenir', letterSpacing: 1),
            tabs: [
              Tab(text: "SİCİL & KİMLİK", icon: Icon(Icons.fingerprint, size: 20)),
              Tab(text: "EKSPERTİZ", icon: Icon(Icons.analytics, size: 20)),
              Tab(text: "REVİZYON", icon: Icon(Icons.history, size: 20)),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/radar_grid.png'),
              fit: BoxFit.cover,
              opacity: 0.05,
            ),
          ),
          child: TabBarView(
            controller: _tabController,
            physics: BouncingScrollPhysics(),
            children: [
              _buildSicilVeKimlikSayfasi(), // Sayfa 1: Kimlik & İstihbarat
              _buildEkspertizSayfasi(),     // Sayfa 2: Mekanik & Kaporta Testi
              _buildRevizyonSayfasi(),      // Sayfa 3: Servis & Parça Geçmişi
            ],
          ),
        ),
      ),
    );
  }

  // ── SAYFA 1: SİCİL VE KİMLİK ──
  Widget _buildSicilVeKimlikSayfasi() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('araclar').where('plaka', isEqualTo: widget.plaka).limit(1).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return _buildSiberUyari("ARACA AİT SİCİL BULUNAMADI.");

        var aracData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        double dnaSkoru = (aracData['dna_skoru'] ?? 100).toDouble();
        String saseNo = aracData['sase_no'] ?? 'BİLİNMİYOR';
        bool isRiskli = aracData['trafik_riski'] ?? (dnaSkoru < 60);
        Color skorRengi = dnaSkoru >= 80 ? SiberTema.kuantumCyan : (dnaSkoru >= 60 ? Colors.orange : SiberTema.kanKirmizi);

        return ListView(
          padding: EdgeInsets.all(20),
          physics: BouncingScrollPhysics(),
          children: [
            // KİMLİK KARTI
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [SiberTema.matGrey.withOpacity(0.8), SiberTema.oledBlack],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: skorRengi.withOpacity(0.5), width: 2),
                boxShadow: [BoxShadow(color: skorRengi.withOpacity(0.15), blurRadius: 20, spreadRadius: 2)],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.plaka, style: TextStyle(color: SiberTema.textMain, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2)),
                            SizedBox(height: 4),
                            Text(aracData['model'] ?? 'Bilinmeyen Model', style: TextStyle(color: SiberTema.textMain.withOpacity(0.5), fontSize: 14)),
                            SizedBox(height: 8),
                            Text("ŞASE: $saseNo", style: TextStyle(color: SiberTema.altinSari, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(color: skorRengi.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: skorRengi)),
                        child: Column(
                          children: [
                            Text(dnaSkoru.toStringAsFixed(0), style: TextStyle(color: skorRengi, fontSize: 24, fontWeight: FontWeight.w900)),
                            Text("DNA", style: TextStyle(color: skorRengi.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isRiskli ? SiberTema.kanKirmizi.withOpacity(0.2) : SiberTema.kuantumCyan.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isRiskli ? SiberTema.kanKirmizi : SiberTema.kuantumCyan.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(isRiskli ? Icons.warning_amber_rounded : Icons.verified_user, color: isRiskli ? SiberTema.kanKirmizi : SiberTema.kuantumCyan, size: 18),
                        SizedBox(width: 8),
                        Text(isRiskli ? "TRAFİĞE ÇIKIŞI RİSKLİ" : "KARARGAH ONAYLI", style: TextStyle(color: isRiskli ? SiberTema.kanKirmizi : SiberTema.kuantumCyan, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 30),
            _buildPanelBaslik("SİBER İSTİHBARAT: ŞEHİR & PLAKA GEÇMİŞİ", Icons.travel_explore),
            StreamBuilder<QuerySnapshot>(
              stream: _db.collection('arac_gecmisi').where('plaka', isEqualTo: widget.plaka).orderBy('tarih', descending: true).snapshots(),
              builder: (context, gecmisSnapshot) {
                if (gecmisSnapshot.connectionState == ConnectionState.waiting) return Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator(color: SiberTema.altinSari)));
                final gecmisList = gecmisSnapshot.data?.docs ?? [];

                if (gecmisList.isEmpty) {
                  return Container(
                    margin: EdgeInsets.only(top: 12),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(color: SiberTema.matGrey.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
                    child: Text("Karargah kayıtlarında henüz bir plaka/il değişikliği bulunmuyor.", style: TextStyle(color: SiberTema.textMain.withOpacity(0.5), fontSize: 12)),
                  );
                }

                return Column(
                  children: gecmisList.map((doc) {
                    var islem = doc.data() as Map<String, dynamic>;
                    String tur = islem['islem_turu'] ?? 'Kayıt';
                    String detay = islem['detay'] ?? '';
                    Timestamp? tarih = islem['tarih'];
                    String tarihStr = tarih != null ? DateFormat('dd.MM.yyyy').format(tarih.toDate()) : '';

                    return Container(
                      margin: EdgeInsets.only(top: 12),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(color: SiberTema.matGrey.withOpacity(0.5), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.1))),
                      child: Row(
                        children: [
                          Icon(tur.contains('Plaka') ? Icons.pin : Icons.location_city, color: SiberTema.altinSari, size: 24),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tur, style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, fontSize: 12)),
                                SizedBox(height: 4),
                                Text(detay, style: TextStyle(color: SiberTema.altinSari, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
                              ],
                            ),
                          ),
                          Text(tarihStr, style: TextStyle(color: SiberTema.textMain.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // ── SAYFA 2: DETAYLI EKSPERTİZ TESTLERİ ──
  Widget _buildEkspertizSayfasi() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('ekspertiz_raporlari').where('plaka', isEqualTo: widget.plaka).orderBy('rapor_tarihi', descending: true).limit(1).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return _buildSiberUyari("ARACA AİT DETAYLI EKSPERTİZ RAPORU BULUNMUYOR.");

        var rapor = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        double motorYuzde = (rapor['motor_performansi'] ?? 0).toDouble();
        double frenYuzde = (rapor['fren_verimi'] ?? 0).toDouble();
        double suspansiyonYuzde = (rapor['suspansiyon_durumu'] ?? 0).toDouble();
        List<dynamic> kaportaListesi = rapor['kaporta_degisenler'] ?? [];

        return ListView(
          padding: EdgeInsets.all(20),
          physics: BouncingScrollPhysics(),
          children: [
            _buildPanelBaslik("DİNAMOMETRE & TEST SONUÇLARI", Icons.speed),
            SizedBox(height: 16),
            _buildTestBar("Motor Performansı (Dyno)", motorYuzde, SiberTema.kuantumCyan),
            _buildTestBar("Fren Verimliliği & Sapma", frenYuzde, Colors.orange),
            _buildTestBar("Süspansiyon Sağlamlığı", suspansiyonYuzde, SiberTema.altinSari),
            SizedBox(height: 30),
            _buildPanelBaslik("KAPORTA & ŞASE ANALİZİ", Icons.car_crash),
            SizedBox(height: 16),
            kaportaListesi.isEmpty
                ? Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5))),
              child: Row(
                children: [
                  Icon(Icons.verified, color: SiberTema.kuantumCyan),
                  SizedBox(width: 12),
                  Text("Orijinal: Boya veya Değişen tespit edilmedi.", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            )
                : Column(
              children: kaportaListesi.map((parca) {
                bool isDegisen = parca.toString().toLowerCase().contains("değişen");
                Color pColor = isDegisen ? SiberTema.kanKirmizi : Colors.orange;
                return Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(color: pColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: pColor.withOpacity(0.5))),
                  child: Row(
                    children: [
                      Icon(isDegisen ? Icons.warning : Icons.brush, color: pColor, size: 16),
                      SizedBox(width: 12),
                      Text(parca.toString(), style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTestBar(String baslik, double yuzde, Color renk) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(baslik, style: TextStyle(color: SiberTema.textMain.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold)),
              Text("%${yuzde.toInt()}", style: TextStyle(color: renk, fontSize: 14, fontWeight: FontWeight.w900)),
            ],
          ),
          SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: yuzde / 100,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(renk),
              minHeight: 12,
            ),
          )
        ],
      ),
    );
  }

  // ── SAYFA 3: MEGA REVİZYON ZAMAN ÇİZELGESİ ──
  Widget _buildRevizyonSayfasi() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('islem_kayitlari').where('plaka', isEqualTo: widget.plaka).orderBy('islem_tarihi', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: SiberTema.altinSari));
        final islemler = snapshot.data?.docs ?? [];
        if (islemler.isEmpty) return _buildSiberUyari("BU ARACA AİT MEGA REVİZYON KAYDI BULUNMUYOR.");

        return ListView.builder(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.all(20),
          itemCount: islemler.length,
          itemBuilder: (context, index) {
            var islem = islemler[index].data() as Map<String, dynamic>;
            List<dynamic> parcalar = islem['parcalar'] ?? [];
            Timestamp? tarih = islem['islem_tarihi'];
            String islemTarihi = tarih != null ? DateFormat('dd.MM.yyyy - HH:mm').format(tarih.toDate()) : 'Tarih Yok';
            double maliyet = (islem['toplam_maliyet'] ?? 0).toDouble();

            return Container(
              margin: EdgeInsets.only(bottom: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(width: 16, height: 16, decoration: BoxDecoration(color: SiberTema.kuantumCyan, shape: BoxShape.circle, boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.5), blurRadius: 10)])),
                      if (index != islemler.length - 1) Container(width: 2, height: 100, color: SiberTema.kuantumCyan.withOpacity(0.3)),
                    ],
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(color: SiberTema.matGrey.withOpacity(0.6), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(islemTarihi, style: TextStyle(color: SiberTema.textMain.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.bold)),
                              Text("₺${maliyet.toStringAsFixed(2)}", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 14, fontWeight: FontWeight.w900)),
                            ],
                          ),
                          SizedBox(height: 12),
                          ...parcalar.map((p) {
                            var parcaData = p as Map<String, dynamic>;
                            return Padding(
                              padding: EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.build_circle, color: SiberTema.kuantumCyan, size: 14),
                                  SizedBox(width: 8),
                                  Expanded(child: Text(parcaData['parca_adi'] ?? 'Parça', style: TextStyle(color: SiberTema.textMain.withOpacity(0.9), fontSize: 12))),
                                  if (parcaData['gorsel_url'] != null) Icon(Icons.image, color: SiberTema.altinSari, size: 14)
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPanelBaslik(String baslik, IconData ikon) {
    return Row(
      children: [
        Icon(ikon, color: SiberTema.kuantumCyan, size: 18),
        SizedBox(width: 8),
        Text(baslik, style: TextStyle(color: SiberTema.textMain.withOpacity(0.7), fontWeight: FontWeight.w800, letterSpacing: 1.5, fontSize: 11)),
      ],
    );
  }

  Widget _buildSiberUyari(String mesaj) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.radar, size: 48, color: Colors.white.withOpacity(0.2)),
            SizedBox(height: 16),
            Text(mesaj, textAlign: TextAlign.center, style: TextStyle(color: SiberTema.textMain.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }
}