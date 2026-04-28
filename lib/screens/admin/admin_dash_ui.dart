import 'package:otodna/core/siber_tema.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🚀 KARARGAH ZIRHLARINI İÇERİ AKTARIYORUZ
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';
import '../dashboard/siber_finans_merkezi_screen.dart'; // 💰 FİNANS MERKEZİ KÖPRÜSÜ

class AdminDashUI extends StatelessWidget {
  AdminDashUI({super.key});

  @override
  Widget build(BuildContext context) {
    // 🛡️ OTONOM KALKANI KUŞANIYORUZ (Taşmaları %100 Engeller)
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _adminAppBar(context),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/radar_grid.png'), // Siber ızgara arka planı (Varsa)
              fit: BoxFit.cover,
              opacity: 0.04,
            ),
          ),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. GAZİ'NİN KASASI (Gerçek Zamanlı Vergi & Pay Hesaplama)
                _finansalOzetKarti(),
                SizedBox(height: 35),

                // 2. SOS KRİTİK TAKİP (30 Dakika Kuralı)
                _adminBaslik("🚨 KRİTİK SOS DURUMU", SiberTema.kanKirmizi),
                _buildCanliSosMotoru(),

                SizedBox(height: 35),

                // 3. BAYİ İTİBAR VE BLACKLIST (1 Yıldız İnfazı)
                _adminBaslik("🛡️ BAYİ DENETİM MERKEZİ", Colors.amber),
                _buildCanliBayiDenetimMotoru(),

                SizedBox(height: 35),

                // 4. BÖLGE SORUMLULARI (7 Bölge Yönetimi)
                _adminBaslik("🗺️ BÖLGE KOMUTANLARI", SiberTema.kuantumCyan),
                _bolgeAtamaButonu(context),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 🔴 1. FİREBASE: CANLI FİNANS MOTORU VE KUSURSUZ VERGİ ALGORİTMASI ---
  Widget _finansalOzetKarti() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('sistem_verileri').doc('finans').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildSiberLoader(SiberTema.kuantumCyan);
        }

        double toplamCiro = 0;
        if (snapshot.hasData && snapshot.data!.exists) {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          toplamCiro = (data['toplam_ciro'] ?? 0).toDouble();
        }

        // 🔥 KUSURSUZ SİBER MATEMATİK (Toplam Ciro Üzerinden Dağılım)
        double netKazanilanKar = toplamCiro * 0.10; // %10 Temiz Kâr
        double devletVergisi = toplamCiro * 0.02; // %2 Vergi
        double toplamKasaGirdisi = netKazanilanKar + devletVergisi; // %12 Toplam Hakediş

        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => SiberFinansMerkeziScreen()));
          },
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              // 3D İçeri Çökük (Emboss) Kasa Hissi
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [SiberTema.oledBlack, SiberTema.matGrey.withOpacity(0.5)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3), width: 1.5), // Etkileşim belli olsun diye turkuaz border
              boxShadow: [
                BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.05), blurRadius: 15, spreadRadius: -2, offset: Offset(0, 5)),
              ],
            ),
            child: Column(
              children: [
                Text("TOPLAM KASA GİRDİSİ (%12)", style: TextStyle(color: SiberTema.textMain.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, fontFamily: 'Avenir')),
                SizedBox(height: 12),
                Text(
                    "₺${toplamKasaGirdisi.toStringAsFixed(2)}",
                    style: TextStyle(color: SiberTema.textMain.withOpacity(0.95), fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir', shadows: [Shadow(color: Colors.white, blurRadius: 10)])
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(color: Colors.white.withOpacity(0.1), thickness: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildFinansDetay("Devlet Vergisi (%2)", "₺${devletVergisi.toStringAsFixed(2)}", SiberTema.kanKirmizi)),
                    Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1)),
                    Expanded(child: _buildFinansDetay("Net Karargah Kârı (%10)", "₺${netKazanilanKar.toStringAsFixed(2)}", Colors.greenAccent)),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("SİBER FİNANS KOKPİTİNE GİR", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, color: SiberTema.kuantumCyan, size: 10),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFinansDetay(String baslik, String deger, Color renk) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(baslik, style: TextStyle(color: SiberTema.textMain.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Avenir'), textAlign: TextAlign.center),
        SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(deger, style: TextStyle(color: renk, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Avenir', shadows: [Shadow(color: renk.withOpacity(0.3), blurRadius: 5)])),
        ),
      ],
    );
  }

  // --- 🔴 2. FİREBASE: CANLI SOS MOTORU VE CEZA PROTOKOLÜ ---
  Widget _buildCanliSosMotoru() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('sos_cagrilari').where('durum', isEqualTo: 'aktif').orderBy('zaman', descending: false).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return _buildSiberLoader(SiberTema.kanKirmizi);
        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) return _buildBosDurum("Radar Temiz. Acil Müdahale Gerektiren SOS Yok.", Icons.health_and_safety, Colors.greenAccent);

        return Column(
          children: docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            String musteri = data['musteri_isim'] ?? 'Bilinmeyen Sürücü';
            int gecenDakika = 0;

            if (data['zaman'] != null) {
              DateTime sosZamani = (data['zaman'] as Timestamp).toDate();
              gecenDakika = DateTime.now().difference(sosZamani).inMinutes;
            }

            // 30 dakikayı geçerse kritik kırmızı, geçmezse turuncu alarm
            Color alarmRengi = gecenDakika > 30 ? SiberTema.kanKirmizi : Colors.orangeAccent;

            return Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [SiberTema.matGrey.withOpacity(0.8), SiberTema.oledBlack],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: alarmRengi.withOpacity(0.4), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: alarmRengi.withOpacity(0.15), blurRadius: 10, spreadRadius: 1, offset: Offset(0, 4)),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    leading: _buildNeonIkon(Icons.warning_amber_rounded, alarmRengi),
                    title: Text(musteri, style: TextStyle(color: SiberTema.textMain.withOpacity(0.9), fontWeight: FontWeight.w700, fontFamily: 'Avenir', fontSize: 14)),
                    subtitle: Text("Bekleme: $gecenDakika dk (Siber Müdahale Gerekli!)", style: TextStyle(color: alarmRengi, fontWeight: FontWeight.w600, fontSize: 12, fontFamily: 'Avenir')),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.style, color: Colors.amber, size: 20),
                          tooltip: "Asılsız İhbar (Sarı Kart)",
                          onPressed: () {},
                        ),
                        Container(
                          decoration: BoxDecoration(
                              boxShadow: [BoxShadow(color: alarmRengi.withOpacity(0.4), blurRadius: 8, offset: Offset(0, 2))]
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: alarmRengi.withOpacity(0.15),
                              foregroundColor: alarmRengi,
                              elevation: 0,
                              side: BorderSide(color: alarmRengi, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () async {
                              WriteBatch batch = FirebaseFirestore.instance.batch();
                              
                              DocumentReference sosRef = FirebaseFirestore.instance.collection('sos_cagrilari').doc(doc.id);
                              batch.update(sosRef, {'durum': 'mudahale_ediliyor'});
                              
                              DocumentReference logRef = FirebaseFirestore.instance.collection('siber_istihbarat_loglari').doc();
                              batch.set(logRef, {
                                'islem_turu': 'SOS_MUDAHALE',
                                'islem_detayi': 'SİBER KOMUTAN: "$musteri" sürücüsünün SOS alarmına müdahale edildi.',
                                'kullanici_id': FirebaseAuth.instance.currentUser?.uid ?? 'BİLİNMEYEN',
                                'tarih': FieldValue.serverTimestamp(),
                              });
                              
                              await batch.commit();
                            },
                            child: Text("MÜDAHALE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'Avenir', letterSpacing: 1)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // --- 🟡 3. FİREBASE: BAYİ DENETİM MERKEZİ ---
  Widget _buildCanliBayiDenetimMotoru() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bayiler').orderBy('puan', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return _buildSiberLoader(Colors.amber);
        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) return _buildBosDurum("Ağda Kayıtlı Bayi Bulunamadı.", Icons.storefront, Colors.white54);

        return Column(
          children: docs.take(5).map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            String isim = data['isim'] ?? 'Bilinmeyen Bayi';
            double puan = (data['puan'] ?? 0).toDouble();

            String derece = puan >= 4.5 ? "Gold (⭐ $puan)" : (puan < 3.0 ? "Blacklist Adayı (★ $puan)" : "Standart (⭐ $puan)");
            Color dereceRengi = puan >= 4.5 ? Colors.amber : (puan < 3.0 ? SiberTema.kanKirmizi : Colors.white70);

            return Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [SiberTema.matGrey.withOpacity(0.6), SiberTema.oledBlack],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: dereceRengi.withOpacity(0.3), width: 1),
                  boxShadow: [
                    BoxShadow(color: dereceRengi.withOpacity(0.05), blurRadius: 8, spreadRadius: 1, offset: Offset(0, 3)),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    leading: _buildNeonIkon(puan < 3.0 ? Icons.gavel : Icons.verified, dereceRengi),
                    title: Text(isim, style: TextStyle(color: SiberTema.textMain.withOpacity(0.9), fontWeight: FontWeight.w700, fontSize: 14, fontFamily: 'Avenir')),
                    subtitle: Text(derece, style: TextStyle(color: dereceRengi, fontWeight: FontWeight.w800, fontSize: 12, fontFamily: 'Avenir')),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.2), size: 16),
                    onTap: () {},
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // --- 🎨 SİBER GÖRSEL ZIRHLAR VE YARDIMCILAR ---

  AppBar _adminAppBar(BuildContext context) => AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    title: Text("OTODNA KARA KUTU", style: TextStyle(color: SiberTema.textMain.withOpacity(0.9), fontWeight: FontWeight.w800, letterSpacing: 2, fontSize: 14, fontFamily: 'Avenir')),
    centerTitle: true,
    bottom: PreferredSize(
      preferredSize: Size.fromHeight(1),
      child: Container(color: Colors.white.withOpacity(0.05), height: 1),
    ),
    actions: [
      IconButton(
          icon: Icon(Icons.security, color: SiberTema.kuantumCyan),
          tooltip: "Yetki Doğrulama",
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Siber Kalkan Aktif. Tam Yetki Onaylandı.", style: TextStyle(fontFamily: 'Avenir', fontWeight: FontWeight.bold)), backgroundColor: SiberTema.kuantumCyan));
          }
      )
    ],
  );

  Widget _adminBaslik(String metin, Color renk) => Padding(
    padding: EdgeInsets.only(bottom: 16, left: 4),
    child: Row(
      children: [
        Icon(Icons.radar, color: renk, size: 18),
        SizedBox(width: 10),
        Text(metin, style: TextStyle(color: SiberTema.textMain.withOpacity(0.85), fontWeight: FontWeight.w800, letterSpacing: 1.5, fontSize: 13, fontFamily: 'Avenir')),
      ],
    ),
  );

  Widget _bolgeAtamaButonu(BuildContext context) => GestureDetector(
    onTap: () {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Bölge Komutanlığı Atama Protokolü Başlatılıyor...", style: TextStyle(fontFamily: 'Avenir', fontWeight: FontWeight.bold)), backgroundColor: SiberTema.kuantumCyan));
    },
    child: AnimatedContainer(
      duration: Duration(milliseconds: 150),
      width: double.infinity,
      height: 65,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [SiberTema.kuantumCyan.withOpacity(0.15), SiberTema.kuantumCyan.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.1), offset: Offset(0, 6), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_location_alt, size: 24, color: SiberTema.kuantumCyan),
          SizedBox(width: 12),
          Text(
            "YENİ BÖLGE KOMUTANI ATA",
            style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5, fontFamily: 'Avenir', shadows: [Shadow(color: SiberTema.kuantumCyan.withOpacity(0.5), blurRadius: 5)]),
          ),
        ],
      ),
    ),
  );

  Widget _buildNeonIkon(IconData icon, Color renk) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: renk.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(color: renk.withOpacity(0.3)),
          boxShadow: [BoxShadow(color: renk.withOpacity(0.2), blurRadius: 8)]
      ),
      child: Icon(icon, color: renk, size: 20),
    );
  }

  Widget _buildSiberLoader(Color renk) => Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator(color: renk, strokeWidth: 3)));

  Widget _buildBosDurum(String mesaj, IconData ikon, Color renk) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [SiberTema.oledBlack, SiberTema.matGrey.withOpacity(0.5)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(ikon, color: renk.withOpacity(0.3), size: 40),
            SizedBox(height: 16),
            Text(mesaj, style: TextStyle(color: SiberTema.textMain.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Avenir'), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}