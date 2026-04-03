import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MusteriGarajScreen extends StatefulWidget {
  const MusteriGarajScreen({super.key});

  @override
  State<MusteriGarajScreen> createState() => _MusteriGarajScreenState();
}

class _MusteriGarajScreenState extends State<MusteriGarajScreen> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  final Color bgColor = const Color(0xFF000000);
  final Color surfaceColor = const Color(0xFF111111);
  final Color primaryCyan = const Color(0xFF00FFC2);
  final Color textMuted = Colors.white54;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Geçerli kullanıcının ID'sini al (Test için fallback eklendi)
  String get _currentUserId => _auth.currentUser?.uid ?? "TEST_MUSTERI_ID";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('K U A N T U M   G A R A J', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 3)),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
                color: primaryCyan.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: primaryCyan.withOpacity(0.5))
            ),
            child: IconButton(
                icon: const Icon(Icons.add, color: Color(0xFF00FFC2), size: 20),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Araç Ekleme Terminali Başlatılıyor...", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Color(0xFF00FFC2)));
                }
            ),
          ),
        ],
      ),
      // 💎 FİREBASE CANLI VERİ AKIŞI (STREAM)
      body: StreamBuilder<QuerySnapshot>(
          stream: _db.collection('araclar').where('sahip_id', isEqualTo: _currentUserId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF00FFC2)));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildBosGarajEkrani();
            }

            var araclar = snapshot.data!.docs;

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              itemCount: araclar.length,
              itemBuilder: (context, index) {
                var aracData = araclar[index].data() as Map<String, dynamic>;
                return _buildAracKarti(aracData);
              },
            );
          }
      ),
    );
  }

  // 💎 1. AKTİF ARAÇ KARTI (Firebase'den Beslenen Kuantum Modülü)
  Widget _buildAracKarti(Map<String, dynamic> data) {
    String plaka = data['plaka'] ?? 'BİLİNMİYOR';
    String marka = data['marka'] ?? 'Marka Yok';
    String model = data['model'] ?? 'Model Yok';
    String yil = data['yil']?.toString() ?? 'YYYY';
    double dnaSkoru = (data['dna_skoru'] ?? 0.0).toDouble();
    double dnaYuzdesi = dnaSkoru / 100.0;

    // Geçmiş işlemleri NoSQL array içinden çekiyoruz
    List<dynamic> sicilGecmisi = data['son_islemler'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("AKTİF SİBER BAĞLANTI", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: primaryCyan.withOpacity(0.3), width: 1.5),
              boxShadow: [
                BoxShadow(color: primaryCyan.withOpacity(0.05), blurRadius: 30, spreadRadius: 5)
              ]
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.1))
                        ),
                        child: const Icon(Icons.directions_car_outlined, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.white24)),
                            child: Text(plaka.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2)),
                          ),
                          const SizedBox(height: 8),
                          Text("$marka $model • $yil", style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  // Siber Göz (QR) İkonu
                  const Icon(Icons.qr_code_scanner_outlined, color: primaryCyan, size: 24),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.white12),
              const SizedBox(height: 20),

              // DNA SCORE BAR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("SİBER GENETİK SKORU", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  Text("%${dnaSkoru.toInt()}", style: TextStyle(color: primaryCyan, fontSize: 18, fontWeight: FontWeight.w900, shadows: [BoxShadow(color: primaryCyan.withOpacity(0.5), blurRadius: 10)])),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: dnaYuzdesi,
                  minHeight: 6,
                  backgroundColor: Colors.white.withOpacity(0.05),
                  color: primaryCyan,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // =================================================================
        // 2. HIZLI İŞLEMLER (Yan Yana Siber Tuşlar)
        // =================================================================
        Row(
          children: [
            Expanded(child: _buildQuickAction(Icons.science_outlined, "EKSPERTİZ\nRAPORU", Colors.purpleAccent)),
            const SizedBox(width: 16),
            Expanded(child: _buildQuickAction(Icons.build_circle_outlined, "SİBER\nSERVİS", Colors.orangeAccent)),
            const SizedBox(width: 16),
            Expanded(child: _buildQuickAction(Icons.sell_outlined, "AĞA\nSAT", Colors.greenAccent)),
          ],
        ),
        const SizedBox(height: 48),

        // =================================================================
        // 3. SİCİL VE GEÇMİŞ ZAMAN ÇİZELGESİ (Firebase'den Dinamik)
        // =================================================================
        const Text("ARAÇ SİCİLİ & GEÇMİŞ", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
        const SizedBox(height: 16),

        if (sicilGecmisi.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
            child: const Center(child: Text("Siber ağda henüz kayıtlı bir işlem bulunmuyor.", style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold))),
          )
        else
          ...sicilGecmisi.map((islem) {
            // Örnek Firestore verisi: { "baslik": "Bakım", "kurum": "Murat Plaza", "tip": "servis", "tarih": Timestamp }
            String islemTip = islem['tip'] ?? 'diger';
            Color islemRenk = islemTip == 'servis' ? Colors.orangeAccent : (islemTip == 'ekspertiz' ? Colors.purpleAccent : primaryCyan);
            IconData islemIkon = islemTip == 'servis' ? Icons.build_circle_outlined : (islemTip == 'ekspertiz' ? Icons.gpp_good_outlined : Icons.verified_outlined);

            String tarihMetni = "Bilinmiyor";
            if (islem['tarih'] != null && islem['tarih'] is Timestamp) {
              DateTime dt = (islem['tarih'] as Timestamp).toDate();
              tarihMetni = DateFormat('dd MMM yyyy, HH:mm', 'tr_TR').format(dt);
            } else if (islem['tarih'] is String) {
              tarihMetni = islem['tarih']; // Fallback string tarih
            }

            return _buildHistoryItem(islemIkon, islem['baslik'] ?? 'İşlem', islem['kurum'] ?? 'OtoDNA Ağı', tarihMetni, islemRenk);
          }).toList(),

        const SizedBox(height: 40),
      ],
    );
  }

  // 🛡️ YARDIMCI WIDGET: HIZLI İŞLEM BUTONU (Minimalist Tesla)
  Widget _buildQuickAction(IconData icon, String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ],
      ),
    );
  }

  // 🛡️ YARDIMCI WIDGET: SİCİL GEÇMİŞİ SATIRI
  Widget _buildHistoryItem(IconData icon, String title, String subtitle, String time, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: iconColor.withOpacity(0.3))
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // 🛡️ YARDIMCI WIDGET: BOŞ GARAJ EKRANI
  Widget _buildBosGarajEkrani() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: primaryCyan.withOpacity(0.05), shape: BoxShape.circle, border: Border.all(color: primaryCyan.withOpacity(0.3), width: 2)),
              child: const Icon(Icons.car_rental, color: primaryCyan, size: 64),
            ),
            const SizedBox(height: 24),
            const Text("SİBER GARAJ BOŞ", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2)),
            const SizedBox(height: 12),
            const Text("Kuantum ağında üzerinize kayıtlı bir araç bulunamadı. Hemen yeni bir araç ekleyip DNA oluşturun.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: primaryCyan, foregroundColor: Colors.black, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: () {},
                icon: const Icon(Icons.add, size: 20),
                label: const Text("ARAÇ EKLE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
              ),
            )
          ],
        ),
      ),
    );
  }
}