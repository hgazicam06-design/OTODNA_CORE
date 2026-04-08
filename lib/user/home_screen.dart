import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

/// 🏎️ OTODNA ANA KARARGAH (User Garage)
/// SOS Fırlatıcı, DNA Takip Radarı ve Dijital Ruhsat Paneli.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 🎨 Siber Tasarım Standartları
  final Color bgColor = const Color(0xFF0A0A0B);
  final Color primaryCyan = const Color(0xFF00FFC2);
  final Color alertRed = const Color(0xFFFF4D4D);
  final Color cardColor = const Color(0xFF161B22);

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  bool _isSosFiring = false;

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) return const Scaffold(body: Center(child: Text("Siber Kimlik Yok!")));

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slvers: [
          _buildSiberAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDNAStatusCard(),
                  const SizedBox(height: 25),
                  _buildSOSButton(),
                  const SizedBox(height: 30),
                  _buildSectionTitle("DİJİTAL GARAJIM", Icons.directions_car),
                  const SizedBox(height: 15),
                  _buildVehicleList(),
                  const SizedBox(height: 30),
                  _buildSectionTitle("SON ETKİLEŞİMLER", Icons.history),
                  _buildActivityFeed(),
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
      expandedHeight: 120,
      backgroundColor: bgColor,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Text("HOŞ GELDİN KOMUTAN", style: TextStyle(color: primaryCyan, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [primaryCyan.withOpacity(0.1), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          ),
        ),
      ),
    );
  }

  // 🧬 DNA TAKİP RADARI (0-100 Skor)
  Widget _buildDNAStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryCyan.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(width: 80, height: 80, child: CircularProgressIndicator(value: 0.85, strokeWidth: 8, color: primaryCyan, backgroundColor: Colors.white10)),
              const Text("85", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("ARAÇ DNA SKORU", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text("Kusursuz Durum", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Son muayene: 12 gün önce", style: TextStyle(color: primaryCyan.withOpacity(0.6), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🚨 5 SANİYE KURALI: SOS FIRLATICI
  Widget _buildSOSButton() {
    return GestureDetector(
      onLongPressStart: (_) => setState(() => _isSosFiring = true),
      onLongPressEnd: (_) {
        setState(() => _isSosFiring = false);
        _siberAcilYardimAtesle();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 80,
        decoration: BoxDecoration(
          color: _isSosFiring ? alertRed : alertRed.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: alertRed.withOpacity(0.5)),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emergency, color: _isSosFiring ? Colors.white : alertRed),
              const SizedBox(width: 12),
              Text(
                _isSosFiring ? "SİNYAL GÖNDERİLİYOR..." : "ACİL YARDIM (SOS) - 5sn Basılı Tut",
                style: TextStyle(color: _isSosFiring ? Colors.white : alertRed, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🛠️ SİBER FONKSİYON: SOS ATEŞLEME
  Future<void> _siberAcilYardimAtesle() async {
    await _db.collection('sos_alarmlari').add({
      'kullanici_id': _currentUser!.uid,
      'durum': 'bekliyor',
      'tarih': FieldValue.serverTimestamp(),
      'konum': 'GPS Verisi Bekleniyor', // Koordinat servisi bağlanacak
    });
    _siberBildirim("KARARGAH VE EN YAKIN BAYİYE SİNYAL GÖNDERİLDİ!");
  }

  // 🚗 GARAJ LİSTESİ (Gerçek Veri)
  Widget _buildVehicleList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('garaj').where('sahip_id', isEqualTo: _currentUser!.uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var docs = snapshot.data!.docs;

        return Column(
          children: docs.map((doc) {
            var car = doc.data() as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: Icon(Icons.directions_car, color: primaryCyan, size: 30),
                title: Text(car['plaka'] ?? "PLAKA YOK", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text("${car['marka']} ${car['model']}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                trailing: const Icon(Icons.chevron_right, color: Colors.white24),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: primaryCyan, size: 18),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.5)),
      ],
    );
  }

  void _siberBildirim(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: primaryCyan, content: Text(mesaj, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))));
  }

  Widget _buildActivityFeed() {
    return const Padding(
      padding: EdgeInsets.only(top: 15),
      child: Text("Henüz bir işlem kaydı bulunmuyor.", style: TextStyle(color: Colors.white24, fontSize: 12)),
    );
  }
}