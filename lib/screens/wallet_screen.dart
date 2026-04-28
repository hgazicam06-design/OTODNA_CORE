import 'package:otodna/core/siber_tema.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🔥 SİBER KÖPRÜLER VE TEMA
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

class WalletScreen extends StatefulWidget {
  WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _siberUyariGoster(String mesaj) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: TextStyle(fontWeight: FontWeight.w900, color: SiberTema.oledBlack, letterSpacing: 1, fontFamily: 'Avenir')),
        backgroundColor: SiberTema.kuantumCyan,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    String uid = user?.uid ?? "BILINMEYEN_KOMUTAN";

    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20), onPressed: () => Navigator.pop(context)),
          title: Text("SİBER CÜZDAN", style: TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600), // 🖥️ Web / Double Teyp Kalkanı
              child: Column(
                children: [
                  // =================================================================
                  // 1. CANLI BAKİYE EKRANI (Holografik Kasa)
                  // =================================================================
                  StreamBuilder<DocumentSnapshot>(
                      stream: _db.collection('kullanicilar').doc(uid).snapshots(),
                      builder: (context, snapshot) {
                        double bakiye = 0.0;
                        if (snapshot.hasData && snapshot.data!.exists) {
                          var data = snapshot.data!.data() as Map<String, dynamic>;
                          bakiye = (data['cuzdan_bakiyesi'] ?? 0.0).toDouble();
                        }

                        return ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              margin: EdgeInsets.all(24),
                              padding: EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: SiberTema.matGrey.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5), width: 2),
                                boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.15), blurRadius: 40, spreadRadius: 10)],
                              ),
                              child: Column(
                                children: [
                                  Text("KUANTUM AĞI KULLANILABİLİR BAKİYE", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
                                  SizedBox(height: 16),
                                  Text(
                                    "₺ ${bakiye.toStringAsFixed(2)}",
                                    style: TextStyle(color: SiberTema.textMain, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir'),
                                  ),
                                  SizedBox(height: 32),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(backgroundColor: SiberTema.kuantumCyan.withOpacity(0.1), foregroundColor: SiberTema.kuantumCyan, elevation: 0, padding: EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: SiberTema.kuantumCyan.withOpacity(0.5)))),
                                          onPressed: () => _siberUyariGoster("FİNANSAL YÜKLEME PROTOKOLÜ BAŞLATILIYOR..."),
                                          icon: Icon(Icons.add_card, size: 18),
                                          label: Text("AĞA YÜKLE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(backgroundColor: SiberTema.kuantumCyan, foregroundColor: Colors.white, elevation: 0, padding: EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                          onPressed: () => _siberUyariGoster("İBAN TRANSFERİ MÜHÜRLENİYOR..."),
                                          icon: Icon(Icons.account_balance, size: 18),
                                          label: Text("İBANA AKTAR", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                  ),

                  // =================================================================
                  // 2. FİNANSAL İSTİHBARAT (İşlem Geçmişi) BAŞLIĞI
                  // =================================================================
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.history, color: SiberTema.kuantumCyan.withOpacity(0.5), size: 20),
                        SizedBox(width: 12),
                        Text("SİBER İŞLEM LOGLARI", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Divider(color: SiberTema.textMuted, thickness: 1),
                  ),

                  // =================================================================
                  // 3. FİREBASE CANLI İŞLEM AKIŞI
                  // =================================================================
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _db.collection('kullanicilar').doc(uid).collection('islemler')
                          .orderBy('tarih', descending: true).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
                        }

                        // 🚨 MAKET (MOCKUP) VERİ YASAK! EĞER İŞLEM YOKSA RADAR TEMİZ EKRANI ÇIKACAK
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.account_balance_wallet_outlined, color: SiberTema.kuantumCyan.withOpacity(0.2), size: 64),
                                SizedBox(height: 16),
                                Text("CÜZDAN TEMİZ", style: TextStyle(color: SiberTema.textMain.withOpacity(0.5), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2, fontFamily: 'Avenir')),
                                SizedBox(height: 8),
                                Text("Henüz ağ üzerinde finansal bir işlem mühürlenmedi.", style: TextStyle(color: SiberTema.textMain.withOpacity(0.3), fontSize: 12, fontFamily: 'Avenir')),
                              ],
                            ),
                          );
                        }

                        // 🚀 GERÇEK FİREBASE VERİ DÖNGÜSÜ
                        return ListView.builder(
                          physics: BouncingScrollPhysics(),
                          padding: EdgeInsets.all(24),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;

                            String tarihStr = "BİLİNMİYOR";
                            if (data['tarih'] != null) {
                              DateTime dt = (data['tarih'] as Timestamp).toDate();
                              tarihStr = "${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')} ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}";
                            }

                            double tutar = (data['tutar'] ?? 0.0).toDouble();

                            return _buildIslemSatiri(
                              data['baslik'] ?? 'SİBER İŞLEM',
                              data['alt_baslik'] ?? 'DETAY YOK',
                              tutar,
                              tarihStr,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: SİBER İŞLEM SATIRI
  Widget _buildIslemSatiri(String baslik, String detay, double tutar, String tarih) {
    bool isGelir = tutar > 0;
    Color islemRengi = isGelir ? Colors.greenAccent : SiberTema.kanKirmizi;
    String isaret = isGelir ? "+" : "";

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SiberTema.matGrey.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: islemRengi.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(isGelir ? Icons.arrow_downward : Icons.arrow_upward, color: islemRengi, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(baslik.toUpperCase(), style: TextStyle(color: SiberTema.textMain, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
                SizedBox(height: 6),
                Row(
                  children: [
                    Text(detay.toUpperCase(), style: TextStyle(color: SiberTema.textMain.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
                    SizedBox(width: 8),
                    Text("•  $tarih", style: TextStyle(color: SiberTema.textMain.withOpacity(0.2), fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Text(
            "$isaret₺${tutar.abs().toStringAsFixed(2)}",
            style: TextStyle(color: islemRengi, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir'),
          ),
        ],
      ),
    );
  }
}