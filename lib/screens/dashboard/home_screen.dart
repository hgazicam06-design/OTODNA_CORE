import 'package:otodna/core/siber_tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// 🚀 KARARGAH ZIRHLARI VE MERKEZİ TEMA
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

class HomeScreen extends ConsumerStatefulWidget {
  HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Renk Paletimiz
  final Color bgColor = SiberTema.oledBlack;
  final Color primaryCyan = SiberTema.kuantumCyan;
  final Color surfaceColor = SiberTema.matGrey;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  bool _isSosFiring = false;

  // 🚀 FİREBASE GERÇEK S.O.S ATEŞLEME MOTORU
  Future<void> _acilYardimFirlat(String plaka) async {
    if (_currentUser == null || _isSosFiring) return;

    setState(() => _isSosFiring = true);

    try {
      WriteBatch batch = _db.batch();

      DocumentReference sosRef = _db.collection('sos_alarmlari').doc();
      batch.set(sosRef, {
        'kullanici_id': _currentUser!.uid,
        'plaka': plaka, // Müşterinin garajındaki ilk aracın plakası
        'durum': 'bekliyor',
        'tarih': FieldValue.serverTimestamp(),
        // TODO: İleride Geolocator paketi ile gerçek GPS enlemi/boylamı eklenecek
        'konum_ozeti': 'Sistem GPS Konumu Bekleniyor...',
      });

      DocumentReference logRef = _db.collection('siber_istihbarat_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'MUSTERI_SOS_SINYALI',
        'seviye': 'KRİTİK',
        'islem_detayi': 'SİBER ALARM: Müşteri (${_currentUser!.uid}), "$plaka" plakalı aracı için S.O.S ateşledi.',
        'kullanici_id': _currentUser!.uid,
        'vaka_id': plaka,
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: SiberTema.kanKirmizi,
          content: Text('S.O.S SİNYALİ ATEŞLENDİ! Bölgedeki tüm yetkili bayiler uyarıldı. Lütfen aracınızda bekleyin.', style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold)),
          duration: Duration(seconds: 5),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ağ Hatası: Sinyal Gönderilemedi! ($e)'), backgroundColor: SiberTema.kanKirmizi));
      }
    } finally {
      if (mounted) setState(() => _isSosFiring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) return Scaffold(backgroundColor: bgColor, body: Center(child: Text("Siber Kimlik Hatası!", style: TextStyle(color: SiberTema.kanKirmizi))));

    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // Fütüristik Alt Navigasyon Çubuğu
        bottomNavigationBar: _buildBottomNav(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopHeader(),
              SizedBox(height: 30),

              // GARAJINDAKİ İLK ARACI ÇEKEN CANLI HOLOGRAM
              StreamBuilder<QuerySnapshot>(
                  stream: _db.collection('araclar').where('sahibiUid', isEqualTo: _currentUser!.uid).limit(1).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());

                    bool aracVar = snapshot.hasData && snapshot.data!.docs.isNotEmpty;
                    Map<String, dynamic>? aracData;
                    String plaka = "BİLİNMİYOR";

                    if (aracVar) {
                      aracData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                      plaka = aracData['plaka'] ?? "PLAKA YOK";
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildVehicleHologramCard(aracVar, aracData),
                        SizedBox(height: 30),
                        Text('HIZLI İŞLEMLER', style: TextStyle(color: SiberTema.textMuted, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        SizedBox(height: 16),
                        _buildQuickActionsGrid(aracVar ? plaka : "PLAKASIZ"),
                        SizedBox(height: 30),
                        _buildRecentActivityPanel(aracVar, plaka),
                      ],
                    );
                  }
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  // 1. Üst Karşılama Alanı (Canlı İsim Çekimi)
  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(radius: 24, backgroundColor: primaryCyan.withOpacity(0.2), child: Icon(Icons.person, color: primaryCyan)),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hoş Geldin,', style: TextStyle(color: SiberTema.textMuted, fontSize: 14)),
                StreamBuilder<DocumentSnapshot>(
                    stream: _db.collection('kullanicilar').doc(_currentUser!.uid).snapshots(),
                    builder: (context, snapshot) {
                      String isim = "Siber Sürücü";
                      if (snapshot.hasData && snapshot.data!.exists) {
                        var data = snapshot.data!.data() as Map<String, dynamic>;
                        isim = data['ad_soyad'] ?? "Sürücü";
                      }
                      return Text(
                        isim.split(' ').first, // Sadece ilk adını yazdır
                        style: TextStyle(color: SiberTema.textMain, fontSize: 20, fontWeight: FontWeight.bold, shadows: [Shadow(color: primaryCyan.withOpacity(0.5), blurRadius: 10)]),
                      );
                    }
                ),
              ],
            ),
          ],
        ),
        IconButton(onPressed: () {}, icon: Icon(Icons.notifications_outlined, color: Colors.white)),
      ],
    );
  }

  // 2. Ana Araç Durum Paneli (Hologram Hissi - CANLI VERİ)
  Widget _buildVehicleHologramCard(bool aracVar, Map<String, dynamic>? data) {
    String plaka = aracVar ? (data!['plaka'] ?? "PLAKA YOK") : "GARAJ BOŞ";
    int dnaSkoru = aracVar ? (data!['dna_skoru'] ?? 100) : 0;
    String markaModel = aracVar ? "${data!['marka']} ${data['model']}" : "Lütfen sisteme araç ekleyin.";

    return Container(
      width: double.infinity, height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(colors: [surfaceColor, surfaceColor.withOpacity(0.01)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        border: Border.all(color: primaryCyan.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.05), blurRadius: 30, spreadRadius: 10)],
      ),
      child: Stack(
        children: [
          Positioned(right: -20, bottom: -20, child: Icon(Icons.directions_car_filled, size: 200, color: Colors.white.withOpacity(0.03))),
          Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(plaka, style: TextStyle(color: SiberTema.textMain, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 2)),
                    if (aracVar)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: primaryCyan)),
                        child: Row(children: [Icon(Icons.health_and_safety, color: primaryCyan, size: 16), SizedBox(width: 6), Text('DNA: $dnaSkoru/100', style: TextStyle(color: primaryCyan, fontWeight: FontWeight.bold, fontSize: 12))]),
                      ),
                  ],
                ),
                Spacer(),
                Text(markaModel, style: TextStyle(color: SiberTema.textMuted, fontSize: 14)),
                SizedBox(height: 8),
                Text(aracVar ? 'OtoDNA Kalkanı Devrede' : 'Araç Bekleniyor', style: TextStyle(color: SiberTema.textMain, fontSize: 20, fontWeight: FontWeight.w300)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Hızlı İşlemler Butonları
  Widget _buildQuickActionsGrid(String plaka) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            title: 'QR Kimlik',
            icon: Icons.qr_code_scanner,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Aracınızın Dijital QR Kimliği Yükleniyor...', style: TextStyle(color: primaryCyan))));
            },
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            title: 'Servis Bul',
            icon: Icons.handyman_outlined,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Harita Radarı Açılıyor...', style: TextStyle(color: primaryCyan))));
            },
          ),
        ),
        SizedBox(width: 16),
        // Acil Yardım Butonu (GERÇEK FİREBASE TETİKLEYİCİ)
        Expanded(
          child: GestureDetector(
            onLongPress: () => _acilYardimFirlat(plaka),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hatalı alarmı önlemek için butona 5 saniye basılı tutunuz.')));
            },
            child: Container(
              height: 100,
              decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.redAccent.withOpacity(0.5))),
              child: _isSosFiring
                  ? Center(child: CircularProgressIndicator(color: Colors.redAccent))
                  : Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.sos, color: Colors.redAccent, size: 32), SizedBox(height: 12), Text('Acil Yardım', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600))]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({required String title, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 100,
        decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: SiberTema.textMuted)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: primaryCyan, size: 32), SizedBox(height: 12), Text(title, style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w600))]),
      ),
    );
  }

  // 4. Son Hareketler Paneli (CANLI FİREBASE SORGUSU)
  Widget _buildRecentActivityPanel(bool aracVar, String plaka) {
    if (!aracVar) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: SiberTema.textMuted)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ARACINIZIN SON DURUMU', style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              Icon(Icons.arrow_forward_ios, color: primaryCyan, size: 14),
            ],
          ),
          SizedBox(height: 16),

          StreamBuilder<QuerySnapshot>(
            // Bu araca ait en son 2 raporu çek (örneğin son ekspertiz veya muayene)
              stream: _db.collection('raporlar').where('plaka', isEqualTo: plaka).orderBy('tarih', descending: true).limit(2).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Text("Aracınız için henüz bir servis işlemi bulunmuyor.", style: TextStyle(color: SiberTema.textMuted));

                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    String tarih = data['tarih'] != null ? DateFormat('dd MMM').format((data['tarih'] as Timestamp).toDate()) : 'Yakın Zaman';

                    return Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: _buildActivityTile(data['rapor_tipi'] ?? 'Servis İşlemi', "Yeni DNA Skoru: ${data['yeni_dna_skoru'] ?? '-'}", tarih),
                    );
                  }).toList(),
                );
              }
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTile(String title, String subtitle, String time) {
    return Row(
      children: [
        Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), shape: BoxShape.circle), child: Icon(Icons.verified, color: primaryCyan, size: 20)),
        SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: SiberTema.textMain, fontSize: 16)), SizedBox(height: 4), Text(subtitle, style: TextStyle(color: SiberTema.textMuted, fontSize: 12))])),
        Text(time, style: TextStyle(color: primaryCyan.withOpacity(0.7), fontSize: 12)),
      ],
    );
  }

  // Fütüristik Alt Navigasyon
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(color: Color(0xFF0F172A), border: Border(top: BorderSide(color: SiberTema.textMuted))),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent, elevation: 0, selectedItemColor: primaryCyan, unselectedItemColor: Colors.white38, type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Garaj'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Usta Bul'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ayarlar'),
        ],
      ),
    );
  }
}