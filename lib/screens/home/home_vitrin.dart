import 'package:otodna/core/siber_tema.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../lojistik/otodna_cigir_screen.dart'; // MÜŞTERİ TAKSİ ÇAĞIRMA KÖPRÜSÜ

class HomeVitrin extends StatefulWidget {
  HomeVitrin({super.key});

  @override
  State<HomeVitrin> createState() => _HomeVitrinState();
}

class _HomeVitrinState extends State<HomeVitrin> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  final Color bgColor = Color(0xFF0F172A);
  final Color primaryCyan = Color(0xFF00FFC2);
  final Color cardColor = Color(0xFF1E293B);

  void _siberUyari(String mesaj) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      backgroundColor: primaryCyan,
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) return Container(color: bgColor, child: Center(child: Text("Kimlik Hatası!")));

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [bgColor, cardColor.withOpacity(0.5)], // Kuantum Geçişi
        ),
      ),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeroSection(), // Canlı Hoşgeldin ve Araç Bilgisi
            SizedBox(height: 16),
            _buildQuickActions(), // Hızlı İkonlar
            _buildSectionTitle("OtoDNA Tavsiyesi (Altın Mühürlüler)"),
            _buildFeaturedFirms(), // Firebase'den VIP Bayi Çekimi
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // =====================================================================
  // 1. ÜST BÖLÜM: CANLI KİMLİK VE ARAÇ HOLOGRAMI
  // =====================================================================
  Widget _buildHeroSection() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KULLANICI ADI ÇEKİMİ
          StreamBuilder<DocumentSnapshot>(
              stream: _db.collection('kullanicilar').doc(_currentUser!.uid).snapshots(),
              builder: (context, snapshot) {
                String isim = "Sürücü";
                if (snapshot.hasData && snapshot.data!.exists) {
                  isim = (snapshot.data!.data() as Map<String, dynamic>)['ad_soyad'] ?? "Sürücü";
                }
                return Text(
                    "Hoş geldin, ${isim.split(' ').first}",
                    style: TextStyle(color: SiberTema.textMain, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1)
                );
              }
          ),
          SizedBox(height: 16),

          // ARAÇ DURUMU ÇEKİMİ
          StreamBuilder<QuerySnapshot>(
              stream: _db.collection('araclar').where('sahibiUid', isEqualTo: _currentUser!.uid).limit(1).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return CircularProgressIndicator();

                bool aracVar = snapshot.hasData && snapshot.data!.docs.isNotEmpty;
                String plaka = "ARAÇ YOK";
                String durumMetni = "Kayıt Bekliyor";
                Color durumRengi = Colors.orangeAccent;

                if (aracVar) {
                  var aracData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                  plaka = aracData['plaka'] ?? "PLAKA YOK";
                  int dnaSkoru = aracData['dna_skoru'] ?? 100;

                  if (dnaSkoru > 80) {
                    durumMetni = "Siber Kalkan OK";
                    durumRengi = primaryCyan;
                  } else {
                    durumMetni = "Risk Saptandı ($dnaSkoru)";
                    durumRengi = Colors.redAccent;
                  }
                }

                return Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: durumRengi.withOpacity(0.05),
                    border: Border.all(color: durumRengi.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.directions_car, color: durumRengi, size: 40),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Aktif Araç Yuvasi", style: TextStyle(color: SiberTema.textMuted, fontSize: 12)),
                          SizedBox(height: 4),
                          Text(plaka, style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5)),
                        ],
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: durumRengi.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(durumMetni, style: TextStyle(color: durumRengi, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ],
                  ),
                );
              }
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // 2. HIZLI ERİŞİM: LASTİK, JANT, AKÜ, SATIŞ
  // =====================================================================
  Widget _buildQuickActions() {
    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _actionItem(Icons.local_taxi, "Taksi Çığır", primaryCyan, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => OtoDnaCigirScreen()));
          }),
          _actionItem(Icons.tire_repair, "Lastik", Colors.blueGrey, () => _siberUyari("Siber Lastik Radarı Açılıyor...")),
          _actionItem(Icons.battery_charging_full, "Akü & EV", primaryCyan, () => _siberUyari("Elektrik/Akü İstasyonları Aranıyor...")),
          _actionItem(Icons.sell, "Hemen Sat", Colors.redAccent, () => _siberUyari("İkinci El İlan Platformuna Geçiş...")),
        ],
      ),
    );
  }

  Widget _actionItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle, border: Border.all(color: color.withOpacity(0.3))),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 8),
          Text(label, style: TextStyle(color: SiberTema.textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // =====================================================================
  // 3. ALTIN ROZETLİ FİRMALAR LİSTESİ (FİREBASE CANLI)
  // =====================================================================
  Widget _buildFeaturedFirms() {
    return Container(
      height: 230,
      padding: EdgeInsets.only(left: 20),
      child: StreamBuilder<QuerySnapshot>(
        // Firebase'den yalnızca VIP (Altın) olan bayileri çekiyoruz
          stream: _db.collection('kullanicilar').where('rol', isEqualTo: 'bayi').where('is_vip', isEqualTo: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Text("Şu an bölgenizde VIP bayi bulunmuyor.", style: TextStyle(color: SiberTema.textMuted)));

            var vipFirmalar = snapshot.data!.docs;

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              itemCount: vipFirmalar.length,
              itemBuilder: (context, index) {
                var firma = vipFirmalar[index].data() as Map<String, dynamic>;
                String firmaAdi = firma['ad'] ?? "İsimsiz Firma";
                double puan = (firma['puan'] ?? 5.0).toDouble();

                return Container(
                  width: 170,
                  margin: EdgeInsets.only(right: 16, bottom: 10),
                  decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.withOpacity(0.5), width: 1.5), // Altın çerçeve
                      boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.1), blurRadius: 10)]
                  ),
                  child: Column(
                    children: [
                      // Firma Görseli (Simülasyon)
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                        child: Container(
                            height: 100,
                            width: double.infinity,
                            color: bgColor,
                            child: Icon(Icons.store, color: Colors.amber, size: 50)
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Text(firmaAdi, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, fontSize: 13)),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.stars, color: Colors.amber, size: 16),
                                SizedBox(width: 4),
                                Text("ALTIN ROZET | $puan", style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(height: 12),
                            SizedBox(
                              height: 30,
                              width: double.infinity,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: primaryCyan, padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                  onPressed: () => _siberUyari("$firmaAdi için randevu alınıyor..."),
                                  child: Text("Randevu Al", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Align(
          alignment: Alignment.centerLeft,
          child: Text(title, style: TextStyle(color: SiberTema.textMain, fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 1.2))
      ),
    );
  }
}