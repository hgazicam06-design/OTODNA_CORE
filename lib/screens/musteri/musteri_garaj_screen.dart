import 'package:otodna/core/siber_tema.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class MusteriGarajScreen extends StatefulWidget {
  MusteriGarajScreen({super.key});

  @override
  State<MusteriGarajScreen> createState() => _MusteriGarajScreenState();
}

class _MusteriGarajScreenState extends State<MusteriGarajScreen> {
  // 🏢 FİLDİŞİ SEDEF PALET (Siyah İptal)
  final Color bgColor = Color(0xFFFDFBF7);
  final Color surfaceColor = Colors.white;
  final Color primaryTeal = Colors.teal.shade700;
  final Color textMuted = Color(0xFF64748B);
  final Color textMain = Color(0xFF1E293B);

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
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
                color: primaryTeal.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: primaryTeal.withOpacity(0.3))
            ),
            child: IconButton(
                icon: Icon(Icons.add, color: primaryTeal, size: 20),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Araç Ekleme Terminali Başlatılıyor...", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold)), backgroundColor: primaryTeal));
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
              return Center(child: CircularProgressIndicator(color: primaryTeal));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildBosGarajEkrani();
            }

            var araclar = snapshot.data!.docs;

            return ListView.builder(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
        Text("AKTİF SİBER BAĞLANTI", style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
              boxShadow: [
                BoxShadow(color: Colors.white.withOpacity(0.03), blurRadius: 30, spreadRadius: 5)
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
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.05))
                        ),
                        child: Icon(Icons.directions_car_outlined, color: primaryTeal, size: 28),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: primaryTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: primaryTeal.withOpacity(0.2))),
                            child: Text(plaka.toUpperCase(), style: TextStyle(color: primaryTeal, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2)),
                          ),
                          SizedBox(height: 8),
                          Text("$marka $model • $yil", style: TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  // Siber Göz (QR) İkonu
                  Icon(Icons.qr_code_scanner_outlined, color: primaryTeal, size: 24),
                ],
              ),
              SizedBox(height: 24),
              Divider(color: Colors.white.withOpacity(0.05)),
              SizedBox(height: 20),

              // DNA SCORE BAR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("SİBER GENETİK SKORU", style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  Text("%${dnaSkoru.toInt()}", style: TextStyle(color: primaryTeal, fontSize: 18, fontWeight: FontWeight.w900)),
                ],
              ),
              SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: dnaYuzdesi,
                  minHeight: 6,
                  backgroundColor: Colors.black.withOpacity(0.05),
                  color: primaryTeal,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 32),

        // =================================================================
        // 2. HIZLI İŞLEMLER (Yan Yana Siber Tuşlar)
        // =================================================================
        Row(
          children: [
            Expanded(child: _buildQuickAction(Icons.science_outlined, "EKSPERTİZ\nRAPORU", Colors.purpleAccent.shade400)),
            SizedBox(width: 16),
            Expanded(child: _buildQuickAction(Icons.build_circle_outlined, "SİBER\nSERVİS", Colors.orange.shade700)),
            SizedBox(width: 16),
            Expanded(child: _buildQuickAction(Icons.sell_outlined, "AĞA\nSAT", Colors.green.shade600)),
          ],
        ),
        SizedBox(height: 48),

        // =================================================================
        // 3. SİCİL VE GEÇMİŞ ZAMAN ÇİZELGESİ (Firebase'den Dinamik)
        // =================================================================
        Text("ARAÇ SİCİLİ & GEÇMİŞ", style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
        SizedBox(height: 16),

        if (sicilGecmisi.isEmpty)
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
            child: Center(child: Text("Siber ağda henüz kayıtlı bir işlem bulunmuyor.", style: TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.bold))),
          )
        else
          ...sicilGecmisi.map((islem) {
            // Örnek Firestore verisi: { "baslik": "Bakım", "kurum": "Murat Plaza", "tip": "servis", "tarih": Timestamp }
            String islemTip = islem['tip'] ?? 'diger';
            Color islemRenk = islemTip == 'servis' ? Colors.orange.shade700 : (islemTip == 'ekspertiz' ? Colors.purpleAccent.shade400 : primaryTeal);
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

        SizedBox(height: 40),
      ],
    );
  }

  // 🛡️ YARDIMCI WIDGET: HIZLI İŞLEM BUTONU (Minimalist Tesla)
  Widget _buildQuickAction(IconData icon, String title, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.02), blurRadius: 10)]
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ],
      ),
    );
  }

  // 🛡️ YARDIMCI WIDGET: SİCİL GEÇMİŞİ SATIRI
  Widget _buildHistoryItem(IconData icon, String title, String subtitle, String time, Color iconColor) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.02), blurRadius: 10)]
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: iconColor.withOpacity(0.3))
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: textMain, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: textMuted, fontSize: 11)),
              ],
            ),
          ),
          Text(time, style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // 🛡️ YARDIMCI WIDGET: BOŞ GARAJ EKRANI
  Widget _buildBosGarajEkrani() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(color: primaryTeal.withOpacity(0.05), shape: BoxShape.circle, border: Border.all(color: primaryTeal.withOpacity(0.3), width: 2)),
              child: Icon(Icons.car_rental, color: primaryTeal, size: 64),
            ),
            SizedBox(height: 24),
            Text("SİBER GARAJ BOŞ", style: TextStyle(color: textMain, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2)),
            SizedBox(height: 12),
            Text("Kuantum ağında üzerinize kayıtlı bir araç bulunamadı. Hemen yeni bir araç ekleyip DNA oluşturun.", textAlign: TextAlign.center, style: TextStyle(color: textMuted, fontSize: 12, height: 1.5)),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: () {},
                icon: Icon(Icons.add, size: 20),
                label: Text("ARAÇ EKLE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
              ),
            )
          ],
        ),
      ),
    );
  }
}