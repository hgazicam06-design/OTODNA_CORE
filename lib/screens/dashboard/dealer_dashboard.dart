import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🚀 KARARGAH ZIRHLARI VE MERKEZİ TEMA
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

/// 🏢 OTODNA BAYİ HAREKAT MERKEZİ (Dashboard)
/// Bayi Puanı, Karargah Payı (%12 Sabit) ve SOS Radarı Entegre Edildi.
class DealerDashboard extends StatefulWidget {
  const DealerDashboard({super.key});

  @override
  State<DealerDashboard> createState() => _DealerDashboardState();
}

class _DealerDashboardState extends State<DealerDashboard> {
  // 🎨 Siber Renk Paleti (Karargah Standartları)
  final Color bgColor = SiberTema.oledBlack; // Derin Karargah Siyahı
  final Color primaryCyan = SiberTema.kuantumCyan; // Kuantum Turkuazı
  final Color surfaceColor = SiberTema.matGrey;
  final Color alertRed = SiberTema.kanKirmizi;
  final Color goldColor = const Color(0xFFFFD700);

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  void _siberUyari(String mesaj) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      backgroundColor: primaryCyan,
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) return Scaffold(backgroundColor: bgColor, body: const Center(child: Text("Siber Kimlik Hatası!", style: TextStyle(color: SiberTema.kanKirmizi))));

    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
                      style: const TextStyle(color: SiberTema.textMain, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            }
        ),
        actions: [
          // ⭐ CANLI BAYİ ROZET SİSTEMİ (Altın, Gümüş, Bronz)
          StreamBuilder<DocumentSnapshot>(
              stream: _db.collection('kullanicilar').doc(_currentUser!.uid).snapshots(),
              builder: (context, snapshot) {
                double puan = 5.0;
                if (snapshot.hasData && snapshot.data!.exists) {
                  var data = snapshot.data!.data() as Map<String, dynamic>;
                  puan = (data['puan'] ?? 5.0).toDouble();
                }
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                      color: goldColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: goldColor.withOpacity(0.5))
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.workspace_premium, color: goldColor, size: 16),
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
              // 1. REKLAM ALANI (Siber Gelir Kapısı)
              _buildAdBanner('OtoDNA Premium Bayi Avantajları', 'Toptan alımlarda ekstra indirimleri keşfedin.'),
              const SizedBox(height: 24),

              // 2. SOS RADARI (5 Saniye Kuralı ile gelen alarmlar)
              _buildSectionTitle('BÖLGESEL SOS RADARI', Icons.radar, alertRed),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot>(
                stream: _db.collection('sos_alarmlari').where('durum', isEqualTo: 'bekliyor').limit(1).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: primaryCyan.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryCyan.withOpacity(0.2))),
                      child: Row(children: [Icon(Icons.shield, color: primaryCyan, size: 20), const SizedBox(width: 12), Text("Bölgeniz güvenli. Aktif SOS yok.", style: TextStyle(color: primaryCyan, fontSize: 13))]),
                    );
                  }

                  var sosData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                  return _buildSOSCard(
                    sosId: snapshot.data!.docs.first.id,
                    plaka: sosData['plaka'] ?? 'BİLİNMİYOR',
                    mesafe: 'Yakınınızda',
                    zaman: 'ACİL MÜDAHALE!',
                    isKritik: true,
                  );
                },
              ),
              const SizedBox(height: 24),

              // 3. FİNANSAL VERİ MERKEZİ (%12 Sabit Pay Hesaplayıcı)
              _buildSectionTitle('FİNANSAL ANALİZ', Icons.payments_outlined, primaryCyan),
              const SizedBox(height: 12),
              StreamBuilder<DocumentSnapshot>(
                stream: _db.collection('kullanicilar').doc(_currentUser!.uid).snapshots(),
                builder: (context, snapshot) {
                  double aylikCiro = 0.0;

                  if (snapshot.hasData && snapshot.data!.exists) {
                    var data = snapshot.data!.data() as Map<String, dynamic>;
                    aylikCiro = (data['aylik_ciro'] ?? 0).toDouble();
                  }

                  // ⚖️ YENİ EŞİTLİK KURALI: Herkese sabit %12 Karargah Kesintisi
                  double platformPayi = aylikCiro * 0.12;
                  double bayiNetKazanc = aylikCiro - platformPayi;

                  return Row(
                    children: [
                      Expanded(child: _buildFinanceCard('Bayi Net Kâr', '₺${bayiNetKazanc.toStringAsFixed(0)}', Colors.greenAccent)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildFinanceCard('Karargah Payı (%12)', '₺${platformPayi.toStringAsFixed(0)}', Colors.orangeAccent)),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // 4. ENVANTER AKIŞI (Canlı Market Verileri)
              _buildSectionTitle('AKTİF ÜRÜNLER (ONAYLI)', Icons.inventory_2_outlined, primaryCyan),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot>(
                  stream: _db.collection('market_urunleri').where('bayi_id', isEqualTo: _currentUser!.uid).limit(3).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Text("Market henüz boş.", style: TextStyle(color: SiberTema.textMuted));

                    return Column(
                      children: snapshot.data!.docs.map((doc) {
                        var urun = doc.data() as Map<String, dynamic>;
                        return _buildProductTile(
                            urun['urun_adi'] ?? 'Ürün',
                            "Stok: ${urun['stok'] ?? 0} | ${urun['vitrin_etiketi'] ?? 'OtoDNA'}", // Kendi dükkanının adını çeker
                            "₺${urun['satis_fiyati'] ?? 0}"
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
      ),
    );
  }

  // ─── YARDIMCI SİBER BİLEŞENLER ───

  Widget _buildAdBanner(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryCyan.withOpacity(0.1), Colors.transparent], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryCyan.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DUYURU', style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: SiberTema.textMain, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(color: SiberTema.textMuted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: SiberTema.textMain, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildSOSCard({required String sosId, required String plaka, required String mesafe, required String zaman, required bool isKritik}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: alertRed.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: alertRed.withOpacity(0.4))),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: alertRed.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.emergency, color: Colors.redAccent)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(plaka, style: const TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, fontSize: 16)), Text(mesafe, style: const TextStyle(color: SiberTema.textMuted, fontSize: 12))])),
          ElevatedButton(
            onPressed: () async {
              try {
                WriteBatch batch = _db.batch();
                DocumentReference sosRef = _db.collection('sos_alarmlari').doc(sosId);
                batch.update(sosRef, {'durum': 'mudahale_edildi', 'mudahale_eden': _currentUser!.uid});
                
                DocumentReference logRef = _db.collection('siber_istihbarat_loglari').doc();
                batch.set(logRef, {
                  'islem_turu': 'SOS_MUDAHALE',
                  'seviye': 'KRİTİK',
                  'islem_detayi': 'SOS MÜDAHALE: Bayi (${_currentUser!.uid}), "$plaka" plakalı aracın SOS sinyaline müdahale başlattı.',
                  'vaka_id': sosId,
                  'bayi_id': _currentUser!.uid,
                  'tarih': FieldValue.serverTimestamp(),
                });
                
                await batch.commit();
                _siberUyari("SOS Operasyonu Karargaha İşlendi!");
              } catch (e) {
                _siberUyari("Müdahale Hatası: $e");
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: alertRed, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('MÜDAHALE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceCard(String title, String amount, Color amountColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: SiberTema.textMuted)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: SiberTema.textMuted, fontSize: 11)),
          const SizedBox(height: 8),
          Text(amount, style: TextStyle(color: amountColor, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildProductTile(String title, String subtitle, String price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold)), Text(subtitle, style: TextStyle(color: primaryCyan, fontSize: 11))]),
          Text(price, style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}