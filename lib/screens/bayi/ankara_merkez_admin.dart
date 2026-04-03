import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnkaraMerkezAdmin extends ConsumerStatefulWidget {
  const AnkaraMerkezAdmin({super.key});

  @override
  ConsumerState<AnkaraMerkezAdmin> createState() => _AnkaraMerkezAdminState();
}

class _AnkaraMerkezAdminState extends ConsumerState<AnkaraMerkezAdmin> {
  final Color bgColor = const Color(0xFF0F172A);
  final Color primaryCyan = const Color(0xFF00FFC2);
  final Color surfaceColor = Colors.white.withOpacity(0.05);
  final Color alertRed = Colors.redAccent;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🧠 KUANTUM VERİ TOPLAYICI (SUNUCUYU YORMAYAN COUNT SORGULARI)
  Future<Map<String, dynamic>> _getSiberIstatistikler() async {
    // 1. Bayi Sayısı
    var bayiSnapshot = await _db.collection('kullanicilar').where('rol', isEqualTo: 'bayi').count().get();
    // 2. Karaliste
    var blacklistSnapshot = await _db.collection('kullanicilar').where('is_blacklisted', isEqualTo: true).count().get();
    // 3. Araç Sayısı
    var aracSnapshot = await _db.collection('araclar').count().get();

    // 4. Kuantum Finans Kasası (%12 Komisyon Toplamları)
    var kasaDoc = await _db.collection('sistem_verileri').doc('merkez_kasa').get();
    double siberPay = 0;
    double vergiFonu = 0;

    if (kasaDoc.exists) {
      siberPay = (kasaDoc.data()?['toplam_net_pay'] ?? 0).toDouble();
      vergiFonu = (kasaDoc.data()?['toplam_vergi'] ?? 0).toDouble();
    }

    return {
      'bayi_sayisi': bayiSnapshot.count ?? 0,
      'karaliste': blacklistSnapshot.count ?? 0,
      'arac_sayisi': aracSnapshot.count ?? 0,
      'siber_pay': siberPay,
      'vergi_fonu': vergiFonu,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Icon(Icons.public, color: primaryCyan, size: 28),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ANKARA MERKEZ KOMUTA', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
                Text('OtoDNA Global Yönetim Paneli', style: TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 1.5)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_system_daydream, color: Colors.white),
            onPressed: () {}, // TODO: Gelişmiş sistem ayarlarına git
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // =========================================================
              // 🚨 1. KRİTİK SOS ALARMLARI (CANLI FİREBASE RADARI)
              // =========================================================
              _buildSectionTitle('KRİTİK MÜDAHALE (SÜRE AŞIMI)', Icons.warning_amber_rounded, alertRed),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot>(
                // Sadece durumu 'Kritik' veya 'Zaman Asimi' olan acil durumları dinle
                stream: _db.collection('sos_alarmlari').where('durum', isEqualTo: 'zaman_asimi').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildSistemTemizKarti(); // SOS yoksa yeşil ekran!
                  }

                  // Kritik SOS varsa listele
                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildAdminSOSCard(
                          plaka: data['plaka'] ?? 'BİLİNMİYOR',
                          bayiAdi: data['sorumlu_bayi_adi'] ?? 'Atanmamış Bayi',
                          gecikmeZamani: 'ZAMAN AŞIMI!',
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),

              // =========================================================
              // 📊 2, 3 ve 4. BÖLÜMLER (FUTURE BUILDER İLE CANLI VERİ ÇEKİMİ)
              // =========================================================
              FutureBuilder<Map<String, dynamic>>(
                future: _getSiberIstatistikler(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: Center(child: CircularProgressIndicator(color: Color(0xFF00FFC2))),
                    );
                  }

                  var stats = snapshot.data ?? {};

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 💰 2. FİNANS VE KOMİSYON AĞI
                      _buildSectionTitle('FİNANS & KOMİSYON AĞI', Icons.account_balance, primaryCyan),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFinanceCard(
                              title: 'OtoDNA Net Pay (%10)',
                              amount: '₺${stats['siber_pay']?.toStringAsFixed(2) ?? "0.00"}',
                              color: primaryCyan,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildFinanceCard(
                              title: 'Vergi Fonu (%2)',
                              amount: '₺${stats['vergi_fonu']?.toStringAsFixed(2) ?? "0.00"}',
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 🌍 3. 7 BÖLGE HARİTASI (Şimdilik Statik Görsel, İleride Canlı Harita)
                      _buildSectionTitle('TÜRKİYE BÖLGESEL AKTİVİTE', Icons.map, Colors.white),
                      const SizedBox(height: 12),
                      _buildRegionGrid(),
                      const SizedBox(height: 24),

                      // 📈 4. BAYİ VE KULLANICI İSTATİSTİKLERİ
                      _buildSectionTitle('SİSTEM İSTATİSTİKLERİ', Icons.analytics, primaryCyan),
                      const SizedBox(height: 12),
                      _buildStatTile('Aktif Bayi Sayısı', '${stats['bayi_sayisi']} Bayi', Icons.store),
                      _buildStatTile('Kara Liste (Engellenenler)', '${stats['karaliste']} Kullanıcı / Bayi', Icons.block, isAlert: true),
                      _buildStatTile('OtoDNA Referanslı Araç', '${stats['arac_sayisi']} Araç', Icons.directions_car),
                    ],
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Yardımcı Widget: Bölüm Başlığı
  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
      ],
    );
  }

  // Yardımcı Widget: SOS Temiz Kartı (Radar Boşsa Çıkar)
  Widget _buildSistemTemizKarti() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryCyan.withOpacity(0.3))),
      child: const Row(
        children: [
          Icon(Icons.check_circle, color: Color(0xFF00FFC2), size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SİSTEM TEMİZ - RADAR BOŞ', style: TextStyle(color: Color(0xFF00FFC2), fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Bekleyen kritik acil durum bulunmamaktadır.', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Yardımcı Widget: Admin SOS Kartı
  Widget _buildAdminSOSCard({required String plaka, required String bayiAdi, required String gecikmeZamani}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: alertRed.withOpacity(0.15), borderRadius: BorderRadius.circular(16), border: Border.all(color: alertRed), boxShadow: [BoxShadow(color: alertRed.withOpacity(0.2), blurRadius: 20, spreadRadius: -5)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.sos, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  Text(plaka, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8)),
                child: Text(gecikmeZamani, style: TextStyle(color: alertRed, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Sorumlu Bayi: $bayiAdi - 30 Dk limiti aşıldı!', style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {}, // TODO: Emniyet protokolü
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                  icon: const Icon(Icons.call, size: 16),
                  label: const Text('EMNİYET / AMBULANS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {}, // TODO: Kullanıcı arama protokolü
                  style: ElevatedButton.styleFrom(backgroundColor: alertRed, foregroundColor: Colors.white),
                  icon: const Icon(Icons.phone_in_talk, size: 16),
                  label: const Text('KULLANICIYI ARA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // Yardımcı Widget: Finans Kartı
  Widget _buildFinanceCard({required String title, required String amount, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(amount, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Yardımcı Widget: 7 Bölge Grid
  Widget _buildRegionGrid() {
    final bolgeler = ['İç Anadolu', 'Marmara', 'Ege', 'Akdeniz', 'Karadeniz', 'Doğu A.', 'G.Doğu A.'];
    return Wrap(
      spacing: 12, runSpacing: 12,
      children: bolgeler.map((bolge) {
        bool isMerkez = bolge == 'İç Anadolu';
        return Container(
          width: (MediaQuery.of(context).size.width - 52) / 2,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: isMerkez ? primaryCyan.withOpacity(0.1) : surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: isMerkez ? primaryCyan : Colors.white12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(bolge, style: TextStyle(color: isMerkez ? primaryCyan : Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(isMerkez ? 'Merkez Aktif' : 'Sistem Normal', style: TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Yardımcı Widget: İstatistik Satırı
  Widget _buildStatTile(String title, String value, IconData icon, {bool isAlert = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: isAlert ? alertRed.withOpacity(0.5) : Colors.white12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: isAlert ? alertRed : primaryCyan, size: 20),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
          Text(value, style: TextStyle(color: isAlert ? alertRed : Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}