import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🔥 SİBER BAĞLANTI: Komutanın oluşturduğu Siber Araç Kayıt Terminaline bağlandı!
import 'arac_kayit_screen.dart'; // 🛠️ DÜZELTİLDİ

class SiberKokpitScreen extends StatefulWidget {
  const SiberKokpitScreen({super.key});

  @override
  State<SiberKokpitScreen> createState() => _SiberKokpitScreenState();
}

class _SiberKokpitScreenState extends State<SiberKokpitScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // SİBER RENK PALETİ
  final Color _bgKaranlik = const Color(0xFF050505);
  final Color _neonCyan = const Color(0xFF00F0FF);
  final Color _kanKirmizi = const Color(0xFFFF2A2A);

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(body: Center(child: Text("SİBER İHLAL: Kimlik Bulunamadı.", style: TextStyle(color: SiberTema.textMain))));
    }

    return Scaffold(
      backgroundColor: _bgKaranlik,
      body: Stack(
        children: [
          // 1. ARKA PLAN RADAR EFEKTİ
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.asset('assets/images/radar_grid.png', fit: BoxFit.cover, errorBuilder: (c, e, s) => const SizedBox()),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. ÜST BİLGİ VE KARARGAH SELAMLAMASI
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("SİBER KOKPİT", style: TextStyle(color: _neonCyan, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, fontFamily: 'Avenir')),
                          const SizedBox(height: 4),
                          const Text("OtoDNA Çevrimiçi", style: TextStyle(color: SiberTema.textMain, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                        ],
                      ),
                      CircleAvatar(
                        backgroundColor: _neonCyan.withOpacity(0.2),
                        radius: 24,
                        child: Icon(Icons.person_outline, color: _neonCyan),
                      )
                    ],
                  ),
                ),

                // 3. CANLI ARAÇ VERİSİ VE DNA SKORU (FIREBASE STREAM)
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _db.collection('araclar')
                        .where('sahibiUid', isEqualTo: _currentUser!.uid) // 🔥 Komutanın modeline göre güncellendi
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator(color: _neonCyan));
                      }

                      if (snapshot.hasError) {
                        return const Center(child: Text("Ağ Hatası", style: TextStyle(color: Colors.red)));
                      }

                      final araclar = snapshot.data?.docs ?? [];

                      // ARAÇ YOKSA - KAYIT TERMİNALİNE YÖNLENDİR
                      if (araclar.isEmpty) {
                        return _buildAracYokKalkani(context);
                      }

                      // ARAÇ VARSA - DNA SKORUNU GÖSTER
                      final aktifArac = araclar.first.data() as Map<String, dynamic>;
                      return _buildAktifAracPaneli(aktifArac);
                    },
                  ),
                ),
              ],
            ),
          ),

          // 4. PANİK GEÇİRMEZ SOS BUTONU
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onLongPress: () {
                  _siberUyariVer("SİBER GÖZ AKTİF: 50KM Çapındaki Bayilere Acil Durum Sinyali Gönderiliyor!");
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _kanKirmizi,
                    boxShadow: [
                      BoxShadow(color: _kanKirmizi.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.sos_rounded, color: SiberTema.kuantumCyan, size: 40),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- SİBER CAM (GLASSMORPHISM) ARAÇ YOK EKRANI ---
  Widget _buildAracYokKalkani(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _neonCyan.withOpacity(0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.directions_car_outlined, size: 60, color: _neonCyan.withOpacity(0.5)),
                  const SizedBox(height: 24),
                  const Text("GARAJINIZ BOŞ", style: TextStyle(color: SiberTema.textMain, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
                  const SizedBox(height: 12),
                  Text("OtoDNA'nın Kuantum gücünden faydalanmak için aracınızı sisteme entegre edin.", textAlign: TextAlign.center, style: TextStyle(color: SiberTema.textMain.withOpacity(0.6), height: 1.5, fontFamily: 'Avenir')),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _neonCyan,
                      foregroundColor: _bgKaranlik,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      // 🔥 SİBER TETİKLEME: Komutanın dosyası açılıyor!
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AracKayitScreen())); // 🛠️ DÜZELTİLDİ
                    },
                    child: const Text("ARAÇ EKLE (DİJİTAL İKİZ OLUŞTUR)", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- CANLI DNA SKORU VE BAĞLAMSAL MENÜLER ---
  Widget _buildAktifAracPaneli(Map<String, dynamic> arac) {
    num dnaSkoru = arac['dna_skoru'] ?? 100;
    String plaka = arac['plaka'] ?? 'BİLİNMİYOR';
    String marka = arac['marka'] ?? '';
    String model = arac['model'] ?? '';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: dnaSkoru / 100,
                      strokeWidth: 12,
                      backgroundColor: Colors.white.withOpacity(0.05),
                      color: dnaSkoru > 70 ? _neonCyan : (dnaSkoru > 40 ? Colors.orange : _kanKirmizi),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(dnaSkoru.toStringAsFixed(0), style: const TextStyle(color: SiberTema.textMain, fontSize: 48, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                      Text("DNA SKORU", style: TextStyle(color: _neonCyan, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2, fontFamily: 'Avenir')),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),

            Text(plaka, style: const TextStyle(color: SiberTema.textMain, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 3, fontFamily: 'Avenir')),
            Text("$marka $model", style: TextStyle(color: SiberTema.textMain.withOpacity(0.6), fontSize: 14, fontFamily: 'Avenir')),
            const SizedBox(height: 40),

            Row(
              children: [
                _buildSiberKutu(Icons.document_scanner, "SİBER GÖZ", "Yapay Zeka Parça Tarayıcı"),
                const SizedBox(width: 16),
                _buildSiberKutu(Icons.health_and_safety, "DİJİTAL GARAJ", "Bakım ve Torpido Belgeleri"),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildSiberKutu(Icons.route, "SÜRÜŞ ASİSTANI", "Maliyet, Rota ve Hava Durumu"),
                const SizedBox(width: 16),
                _buildSiberKutu(Icons.pie_chart, "FİNANS RADARI", "Toplam Yatırım ve Değer"),
              ],
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSiberKutu(IconData icon, String baslik, String altBaslik) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: _neonCyan, size: 28),
                const SizedBox(height: 16),
                Text(baslik, style: const TextStyle(color: SiberTema.textMain, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                const SizedBox(height: 4),
                Text(altBaslik, style: TextStyle(color: SiberTema.textMain.withOpacity(0.5), fontSize: 10, fontFamily: 'Avenir')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _siberUyariVer(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
      backgroundColor: _neonCyan,
      behavior: SnackBarBehavior.floating,
    ));
  }
}