import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';
import 'dart:async';
import 'dart:developer' as developer;

/// 🏎️ OTODNA ANA KARARGAH (User Garage)
/// SOS Fırlatıcı, Canlı DNA Takip Radarı ve Dijital Ruhsat Paneli.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 🎨 Siber Tasarım Standartları (Komutan Teması)
  final Color bgColor = const Color(0xFF0A0A0B);
  final Color primaryCyan = const Color(0xFF00FFC2);
  final Color alertRed = const Color(0xFFFF4D4D);

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // 🚨 SOS Kuantum Sayacı Değişkenleri
  bool _isSosFiring = false;
  int _sosCounter = 0;
  Timer? _sosTimer;

  @override
  void dispose() {
    _sosTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: Text("SİBER KİMLİK YOK!", style: TextStyle(color: Colors.red))));
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [ // SİBER YAMA: 'slvers' hatası düzeltildi!
          _buildSiberAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDNAStatusCard(), // CANLI RADAR GELDİ
                  const SizedBox(height: 25),
                  _buildSOSButton(), // 5 SANİYE ZIRHLI SAYAÇ
                  const SizedBox(height: 30),
                  _buildSectionTitle("DİJİTAL GARAJIM", Icons.directions_car),
                  const SizedBox(height: 15),
                  _buildVehicleList(),
                  const SizedBox(height: 30),
                  _buildSectionTitle("SON ETKİLEŞİMLER", Icons.history),
                  _buildActivityFeed(), // CANLI LOG RADARI GELDİ
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🛰️ SİBER APPBAR (Holografik Başlık)
  Widget _buildSiberAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
      backgroundColor: bgColor,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Text("HOŞ GELDİN, KOMUTAN", style: TextStyle(color: primaryCyan, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2)),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [primaryCyan.withValues(alpha: 0.15), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          ),
        ),
      ),
    );
  }

  // 🧬 CANLI DNA TAKİP RADARI (MAKET YIKILDI!)
  Widget _buildDNAStatusCard() {
    return StreamBuilder<QuerySnapshot>(
        stream: _db.collection('araclar').where('sahip_id', isEqualTo: _currentUser!.uid).limit(1).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF00FFC2)));

          double dnaSkoru = 0.0;
          String plaka = "ARAÇ BULUNAMADI";

          if (snapshot.data!.docs.isNotEmpty) {
            var aracVeri = snapshot.data!.docs.first.data() as Map<String, dynamic>;
            dnaSkoru = (aracVeri['dna_skoru'] ?? 0.0).toDouble();
            plaka = aracVeri['plaka'] ?? "PLAKA YOK";
          }

          return ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Siber Cam Efekti (Glassmorphism)
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: primaryCyan.withValues(alpha: 0.3), width: 1.5),
                  boxShadow: [BoxShadow(color: primaryCyan.withValues(alpha: 0.05), blurRadius: 20)],
                ),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                            width: 80, height: 80,
                            child: CircularProgressIndicator(value: dnaSkoru / 100, strokeWidth: 8, color: primaryCyan, backgroundColor: Colors.white10)
                        ),
                        Text("${dnaSkoru.toInt()}", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("ARAÇ DNA SKORU ($plaka)", style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          const SizedBox(height: 4),
                          Text(dnaSkoru >= 80 ? "KUSURSUZ DURUM" : (dnaSkoru >= 50 ? "BAKIM GEREKLİ" : "KRİTİK RİSK"),
                              style: TextStyle(color: dnaSkoru >= 80 ? primaryCyan : (dnaSkoru >= 50 ? Colors.amber : alertRed), fontSize: 16, fontWeight: FontWeight.w900)
                          ),
                          const SizedBox(height: 4),
                          Text("Karargah radarına kilitli.", style: TextStyle(color: primaryCyan.withValues(alpha: 0.6), fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
    );
  }

  // 🚨 5 SANİYE KURALI: GERÇEK SOS FIRLATICI ZIRHI
  Widget _buildSOSButton() {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isSosFiring = true;
          _sosCounter = 0;
        });

        // GERÇEK 5 Saniye Radarı
        _sosTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() => _sosCounter++);
          if (_sosCounter >= 5) {
            timer.cancel();
            setState(() => _isSosFiring = false);
            _siberAcilYardimAtesle();
          }
        });
      },
      onTapUp: (_) => _sosIptalEt(),
      onTapCancel: () => _sosIptalEt(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 80,
        decoration: BoxDecoration(
          color: _isSosFiring ? alertRed.withValues(alpha: 0.8) : alertRed.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: alertRed.withValues(alpha: 0.8), width: _isSosFiring ? 2 : 1),
          boxShadow: _isSosFiring ? [BoxShadow(color: alertRed.withValues(alpha: 0.5), blurRadius: 15, spreadRadius: 2)] : [],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emergency, color: _isSosFiring ? Colors.white : alertRed, size: 28),
              const SizedBox(width: 12),
              Text(
                _isSosFiring ? "SİNYAL KİLİTLENİYOR: ${5 - _sosCounter}sn" : "ACİL YARDIM (SOS) - 5sn Basılı Tut",
                style: TextStyle(color: _isSosFiring ? Colors.white : alertRed, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sosIptalEt() {
    if (_sosCounter < 5) {
      _sosTimer?.cancel();
      setState(() {
        _isSosFiring = false;
        _sosCounter = 0;
      });
      developer.log("SİBER BİLGİ: SOS Fırlatması kullanıcı tarafından iptal edildi.");
    }
  }

  // 🛠️ SİBER FONKSİYON: ATOMİK SOS ATEŞLEME
  Future<void> _siberAcilYardimAtesle() async {
    try {
      developer.log("🔥 SİBER ALARM: SOS Sinyali Karargaha ateşleniyor!");

      // ⛓️ ATOMİK ZIRH: WriteBatch (Kayıt Dışılığı Engelle!)
      WriteBatch batch = _db.batch();

      // 1. SOS Sinyalini Ana Radara Düşür
      DocumentReference sosRef = _db.collection('sos_alarmlari').doc();
      batch.set(sosRef, {
        'kullanici_id': _currentUser!.uid,
        'durum': 'AKTİF',
        'tarih': FieldValue.serverTimestamp(),
        'konum': 'GPS_VERİSİ_BEKLENİYOR',
        'mudahale_suresi': 30, // 30 Dakika Kuralı Radarı
      });

      // 2. Kara Kutuya (Sistem Logları) İz Bırak (Sarı/Kırmızı Kart Motoru İçin)
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'ACİL_SOS_FİRLATMASI',
        'islem_detayi': 'SİBER ALARM: Kullanıcı 5 saniye kuralıyla SOS füzesini ateşledi!',
        'kullanici_id': _currentUser!.uid,
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      _siberBildirim("KARARGAH VE EN YAKIN BAYİYE SİNYAL GÖNDERİLDİ!", isError: true);

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: SOS Fırlatılamadı!", error: e);
      _siberBildirim("SİBER HATA: Sinyal Karargaha ulaşamadı. Lütfen doğrudan arayın!", isError: true);
    }
  }

  // 🚗 GARAJ LİSTESİ
  Widget _buildVehicleList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('araclar').where('sahip_id', isEqualTo: _currentUser!.uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF00FFC2)));
        var docs = snapshot.data!.docs;

        if (docs.isEmpty) return _buildEmptyStatus("Siber garajınızda kayıtlı araç bulunmuyor.");

        return Column(
          children: docs.map((doc) {
            var car = doc.data() as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: ListTile(
                leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: primaryCyan.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: Icon(Icons.directions_car, color: primaryCyan, size: 24)
                ),
                title: Text(car['plaka'] ?? "PLAKA YOK", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                subtitle: Text("${car['marka'] ?? 'Bilinmeyen'} ${car['model'] ?? 'Model'}", style: const TextStyle(color: Colors.white54, fontSize: 11)),
                trailing: const Icon(Icons.chevron_right, color: Colors.white24),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // 📡 CANLI İŞLEM RADARI (MAKET YIKILDI!)
  Widget _buildActivityFeed() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('sistem_loglari')
          .where('kullanici_id', isEqualTo: _currentUser!.uid)
          .orderBy('tarih', descending: true)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Padding(padding: EdgeInsets.only(top: 15), child: LinearProgressIndicator(color: Color(0xFF00FFC2)));
        var docs = snapshot.data!.docs;

        if (docs.isEmpty) return _buildEmptyStatus("Henüz bir siber etkileşiminiz bulunmuyor.");

        return Column(
          children: docs.map((doc) {
            var log = doc.data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(Icons.radar, color: primaryCyan, size: 16),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(log['islem_turu'] ?? "BİLİNMEYEN İŞLEM", style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ── 🔧 YARDIMCI SİBER ARAÇLAR ───────────────────────────────────────────
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: primaryCyan, size: 18),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5)),
      ],
    );
  }

  Widget _buildEmptyStatus(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.02), borderRadius: BorderRadius.circular(12)),
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  void _siberBildirim(String mesaj, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: isError ? alertRed : primaryCyan,
      content: Text(mesaj, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 1)),
      behavior: SnackBarBehavior.floating,
    ));
  }
}
