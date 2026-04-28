import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class MusteriGarajScreen extends StatefulWidget {
  const MusteriGarajScreen({super.key});

  @override
  State<MusteriGarajScreen> createState() => _MusteriGarajScreenState();
}

class _MusteriGarajScreenState extends State<MusteriGarajScreen> {
  // 🏢 FİLDİŞİ SEDEF & METALİK GOLD PALET
  final Color bgColor = const Color(0xFFFAFAFC);
  final Color surfaceColor = Colors.white;
  final Color primaryGold = const Color(0xFFB8860B);
  final Color lightGold = const Color(0xFFF3E5AB);
  final Color textMuted = const Color(0xFF64748B);
  final Color textMain = const Color(0xFF2C2519);

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Geçerli kullanıcının ID'sini al (Test için fallback eklendi)
  String get _currentUserId => _auth.currentUser?.uid ?? "TEST_MUSTERI_ID";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textMain, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('K U A N T U M   G A R A J', style: TextStyle(color: textMain, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 3, fontFamily: 'Avenir')),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
                color: primaryGold.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: primaryGold.withOpacity(0.3))
            ),
            child: IconButton(
                icon: Icon(Icons.add, color: primaryGold, size: 20),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Araç Ekleme Terminali Başlatılıyor...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Avenir')), backgroundColor: primaryGold));
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
              return Center(child: CircularProgressIndicator(color: primaryGold));
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
        Text("AKTİF SİBER BAĞLANTI", style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: primaryGold.withOpacity(0.1), width: 1.5),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 30, spreadRadius: 5)
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
                            border: Border.all(color: primaryGold.withOpacity(0.1))
                        ),
                        child: Icon(Icons.directions_car_outlined, color: primaryGold, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: primaryGold.withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: primaryGold.withOpacity(0.2))),
                            child: Text(plaka.toUpperCase(), style: TextStyle(color: primaryGold, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
                          ),
                          const SizedBox(height: 8),
                          Text("$marka $model • $yil", style: TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                        ],
                      ),
                    ],
                  ),
                  // Siber Göz (QR) İkonu
                  Icon(Icons.qr_code_scanner_outlined, color: primaryGold, size: 24),
                ],
              ),
              const SizedBox(height: 24),
              Divider(color: Colors.black.withOpacity(0.05)),
              const SizedBox(height: 20),

              // DNA SCORE BAR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("SİBER GENETİK SKORU", style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                  Text("%${dnaSkoru.toInt()}", style: TextStyle(color: primaryGold, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: dnaYuzdesi,
                  minHeight: 6,
                  backgroundColor: bgColor,
                  color: primaryGold,
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
            Expanded(child: _buildQuickAction(Icons.science_outlined, "EKSPERTİZ\nRAPORU", Colors.purple)),
            const SizedBox(width: 16),
            Expanded(child: _buildQuickAction(Icons.build_circle_outlined, "SİBER\nSERVİS", Colors.blueGrey)),
            const SizedBox(width: 16),
            Expanded(child: _buildQuickAction(Icons.sell_outlined, "AĞA\nSAT", Colors.green.shade700)),
          ],
        ),
        const SizedBox(height: 48),

        // =================================================================
        // 3. SİCİL VE GEÇMİŞ ZAMAN ÇİZELGESİ (Firebase'den Dinamik)
        // =================================================================
        Text("ARAÇ SİCİLİ & GEÇMİŞ", style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
        const SizedBox(height: 16),

        if (sicilGecmisi.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black.withOpacity(0.05))),
            child: Center(child: Text("Siber ağda henüz kayıtlı bir işlem bulunmuyor.", style: TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Avenir'))),
          )
        else
          ...sicilGecmisi.map((islem) {
            String islemTip = islem['tip'] ?? 'diger';
            Color islemRenk = islemTip == 'servis' ? Colors.blueGrey : (islemTip == 'ekspertiz' ? Colors.purple : primaryGold);
            IconData islemIkon = islemTip == 'servis' ? Icons.build_circle_outlined : (islemTip == 'ekspertiz' ? Icons.gpp_good_outlined : Icons.verified_outlined);

            String tarihMetni = "Bilinmiyor";
            if (islem['tarih'] != null && islem['tarih'] is Timestamp) {
              DateTime dt = (islem['tarih'] as Timestamp).toDate();
              tarihMetni = DateFormat('dd MMM yyyy, HH:mm', 'tr_TR').format(dt);
            } else if (islem['tarih'] is String) {
              tarihMetni = islem['tarih'];
            }

            return _buildHistoryItem(islemIkon, islem['baslik'] ?? 'İşlem', islem['kurum'] ?? 'OtoDNA Ağı', tarihMetni, islemRenk);
          }).toList(),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildQuickAction(IconData icon, String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryGold.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(IconData icon, String title, String subtitle, String time, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryGold.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]
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
                Text(title, style: TextStyle(color: textMain, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: -0.5, fontFamily: 'Avenir')),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: textMuted, fontSize: 11, fontFamily: 'Avenir')),
              ],
            ),
          ),
          Text(time, style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
        ],
      ),
    );
  }

  Widget _buildBosGarajEkrani() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: primaryGold.withOpacity(0.05), shape: BoxShape.circle, border: Border.all(color: primaryGold.withOpacity(0.3), width: 2)),
              child: Icon(Icons.car_rental, color: primaryGold, size: 64),
            ),
            const SizedBox(height: 24),
            Text("GARAJ BOŞ", style: TextStyle(color: textMain, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
            const SizedBox(height: 12),
            Text("Sistem üzerinde size ait bir araç bulunamadı. Hemen yeni bir araç ekleyin.", textAlign: TextAlign.center, style: TextStyle(color: textMuted, fontSize: 12, height: 1.5, fontFamily: 'Avenir')),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: primaryGold, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: () {},
                icon: const Icon(Icons.add, size: 20),
                label: const Text("ARAÇ EKLE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1, fontFamily: 'Avenir')),
              ),
            )
          ],
        ),
      ),
    );
  }
}