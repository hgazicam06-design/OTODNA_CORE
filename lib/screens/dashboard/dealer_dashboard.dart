import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DealerDashboard extends StatefulWidget {
  const DealerDashboard({super.key});

  @override
  State<DealerDashboard> createState() => _DealerDashboardState();
}

class _DealerDashboardState extends State<DealerDashboard> {
  final Color bgColor = const Color(0xFF0F172A);
  final Color primaryCyan = const Color(0xFF00FFC2);
  final Color surfaceColor = Colors.white.withOpacity(0.05);
  final Color alertRed = Colors.redAccent;
  final Color goldColor = const Color(0xFFFFD700);

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  void _siberUyari(String mesaj) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      backgroundColor: primaryCyan,
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) return Scaffold(backgroundColor: bgColor, body: const Center(child: Text("Siber Kimlik Hatası!", style: TextStyle(color: Colors.redAccent))));

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: StreamBuilder<DocumentSnapshot>(
            stream: _db.collection('kullanicilar').doc(_currentUser!.uid).snapshots(),
            builder: (context, snapshot) {
              String firmaAdi = "Firma Yükleniyor...";
              if (snapshot.hasData && snapshot.data!.exists) {
                firmaAdi = (snapshot.data!.data() as Map<String, dynamic>)['ad'] ?? "İsimsiz Bayi";
              }
              return Row(
                children: [
                  Icon(Icons.storefront, color: primaryCyan),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      firmaAdi.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            }
        ),
        actions: [
          // CANLI BAYİ PUANLAMA SİSTEMİ
          StreamBuilder<DocumentSnapshot>(
              stream: _db.collection('kullanicilar').doc(_currentUser!.uid).snapshots(),
              builder: (context, snapshot) {
                double puan = 5.0; // Varsayılan Kuantum Puanı
                if (snapshot.hasData && snapshot.data!.exists) {
                  var data = snapshot.data!.data() as Map<String, dynamic>;
                  puan = (data['puan'] ?? 5.0).toDouble();
                }
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: goldColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: goldColor.withOpacity(0.5))),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: goldColor, size: 16),
                      const SizedBox(width: 4),
                      Text(puan.toStringAsFixed(1), style: TextStyle(color: goldColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. REKLAM ALANI (ÜST BANNER - PASİF GELİR KAPISI)
              _buildAdBanner('OtoDNA Premium Bayi Avantajları', 'Toptan alımlarda ekstra indirimleri keşfedin.'),
              const SizedBox(height: 24),

              // 2. SOS RADARI (CANLI FİREBASE DİNLEYİCİSİ)
              _buildSectionTitle('SOS BİLDİRİM RADARI', Icons.radar, alertRed),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot>(
                stream: _db.collection('sos_alarmlari').where('durum', isEqualTo: 'bekliyor').limit(1).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryCyan.withOpacity(0.3))),
                      child: const Row(children: [Icon(Icons.check_circle, color: primaryCyan), SizedBox(width: 12), Text("Bölgenizde acil durum yok. Sistem temiz.", style: TextStyle(color: primaryCyan, fontWeight: FontWeight.bold))]),
                    );
                  }

                  var sosData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                  return _buildSOSCard(
                    plaka: sosData['plaka'] ?? 'BİLİNMİYOR',
                    mesafe: 'Yakınınızda', // GPS entegrasyonu gelince dinamik olacak
                    zaman: 'HEMEN MÜDAHALE!',
                    isKritik: true,
                  );
                },
              ),
              const SizedBox(height: 24),

              // 3. FİNANS VE SATIŞ ÖZETİ (CANLI KUANTUM HESAPLAMASI)
              _buildSectionTitle('FİNANSAL DURUM', Icons.account_balance_wallet, primaryCyan),
              const SizedBox(height: 12),
              StreamBuilder<DocumentSnapshot>(
                stream: _db.collection('kullanicilar').doc(_currentUser!.uid).snapshots(),
                builder: (context, snapshot) {
                  double aylikCiro = 0.0;
                  String firmaAdi = "";

                  if (snapshot.hasData && snapshot.data!.exists) {
                    var data = snapshot.data!.data() as Map<String, dynamic>;
                    aylikCiro = (data['aylik_ciro'] ?? 0).toDouble();
                    firmaAdi = (data['ad'] ?? "").toUpperCase();
                  }

                  // 💰 ALTIN KURAL: Murat Plaza %30, Diğerleri %12
                  double komisyonOrani = firmaAdi.contains("MURAT PLAZA") ? 0.30 : 0.12;
                  double platformPayi = aylikCiro * komisyonOrani;
                  double bayiKari = aylikCiro - platformPayi;

                  return Row(
                    children: [
                      Expanded(child: _buildFinanceCard('Bayi Kârı', '₺${bayiKari.toStringAsFixed(0)}', Colors.greenAccent)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildFinanceCard('Platform (%${(komisyonOrani*100).toInt()})', '₺${platformPayi.toStringAsFixed(0)}', Colors.white54)),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // 4. REKLAM ALANI (ORTA BANNER)
              _buildAdBanner('Bölgenizdeki Sigorta Fırsatları', 'Müşterilerinize sunabileceğiniz kasko paketleri.', isSmall: true),
              const SizedBox(height: 24),

              // 5. ÜRÜN KATALOĞU (CANLI ENVANTER - Son 3 Ürün)
              _buildSectionTitle('GÜNCEL ÜRÜN KATALOĞU', Icons.inventory, primaryCyan),
              const Padding(
                padding: EdgeInsets.only(bottom: 16, top: 4),
                child: Text('Sisteme eklediğiniz en güncel yedek parçalar.', style: TextStyle(color: Colors.white54, fontSize: 12)),
              ),

              StreamBuilder<QuerySnapshot>(
                  stream: _db.collection('yedek_parcalar').where('satici_id', isEqualTo: _currentUser!.uid).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Text("Kataloğunuzda henüz ürün bulunmuyor.", style: TextStyle(color: Colors.white54));

                    // Firebase Index hatası almamak için Dart tarafında tarihe göre sıralayıp son 3'ü alıyoruz
                    var urunler = snapshot.data!.docs.toList();
                    urunler.sort((a, b) => (b['eklenme_tarihi'] as Timestamp?)?.compareTo(a['eklenme_tarihi'] as Timestamp? ?? Timestamp.now()) ?? 0);
                    var sonUrunler = urunler.take(3).toList();

                    return Column(
                      children: sonUrunler.map((doc) {
                        var urun = doc.data() as Map<String, dynamic>;
                        return _buildProductTile(
                            urun['urun_adi'] ?? 'İsimsiz Ürün',
                            "OEM: ${urun['oem_kodu'] ?? 'Yok'} | Stok: ${urun['stok'] ?? 0}",
                            "₺${urun['fiyat'] ?? 0}"
                        );
                      }).toList(),
                    );
                  }
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Yardımcı Widget: Reklam Alanı
  Widget _buildAdBanner(String title, String subtitle, {bool isSmall = false}) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 16 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryCyan.withOpacity(0.15), Colors.blueAccent.withOpacity(0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryCyan.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: bgColor.withOpacity(0.8), borderRadius: BorderRadius.circular(4)),
            child: const Text('SPONSORLU', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: Colors.white, fontSize: isSmall ? 16 : 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: Colors.white70, fontSize: isSmall ? 12 : 14)),
        ],
      ),
    );
  }

  // Yardımcı Widget: Bölüm Başlığı
  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      ],
    );
  }

  // Yardımcı Widget: Acil Durum SOS Kartı
  Widget _buildSOSCard({required String plaka, required String mesafe, required String zaman, required bool isKritik}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: alertRed.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: alertRed.withOpacity(0.5))),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: alertRed.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.sos, color: Colors.redAccent, size: 28)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plaka, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(children: [const Icon(Icons.location_on, color: Colors.white54, size: 14), const SizedBox(width: 4), Text(mesafe, style: const TextStyle(color: Colors.white54, fontSize: 13))]),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(zaman, style: TextStyle(color: alertRed, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _siberUyari("Müdahale Ekipleri Yönlendiriliyor!"),
                style: ElevatedButton.styleFrom(backgroundColor: alertRed, minimumSize: const Size(80, 30), padding: const EdgeInsets.symmetric(horizontal: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: const Text('MÜDAHALE ET', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Yardımcı Widget: Finans Kartı
  Widget _buildFinanceCard(String title, String amount, Color amountColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(amount, style: TextStyle(color: amountColor, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Yardımcı Widget: Ürün Listesi
  Widget _buildProductTile(String title, String subtitle, String price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: primaryCyan, fontSize: 11)),
              ],
            ),
          ),
          Text(price, style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}