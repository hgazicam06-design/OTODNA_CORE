import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHavuzTakip extends StatefulWidget {
  const AdminHavuzTakip({super.key});

  @override
  State<AdminHavuzTakip> createState() => _AdminHavuzTakipState();
}

class _AdminHavuzTakipState extends State<AdminHavuzTakip> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  final Color bgColor = const Color(0xFF000000);
  final Color surfaceColor = const Color(0xFF111111);
  final Color primaryCyan = const Color(0xFF00FFC2);

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Sayıları formatlamak için yardımcı fonksiyon (Örn: 1.250.000,00)
  String _formatCurrency(double amount) {
    String formatted = amount.toStringAsFixed(2);
    formatted = formatted.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('M E R K E Z   C A N L I   H A V U Z', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 3)),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.sync, color: primaryCyan, size: 18), // Canlı dinleme ikonu
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 🚀 FİREBASE 'Havuz' KOLEKSİYONUNU CANLI DİNLİYORUZ
        stream: _db.collection('Havuz').orderBy('tarih', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00FFC2)));
          }

          double toplamCiro = 0;
          double merkezKar = 0;

          // Eğer veri varsa Kuantum Matematiği başlasın
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            for (var doc in snapshot.data!.docs) {
              var data = doc.data() as Map<String, dynamic>;
              double tutar = (data['tutar'] ?? 0.0).toDouble();
              toplamCiro += tutar;
              // 💰 SİBER PROTOKOL: %12 ACIKASIZ KESİNTİ MOTORU
              merkezKar += (tutar * 0.12);
            }
          }

          return Column(
            children: [
              // =================================================================
              // 1. ÜST FİNANSAL PANELLER
              // =================================================================
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildFinanceCard(
                          "TOPLAM SİBER HAVUZ",
                          "₺${_formatCurrency(toplamCiro)}",
                          Icons.waves,
                          Colors.blueAccent,
                          "Kilitli Ağ Bakiyesi"
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildFinanceCard(
                          "MERKEZ HAKEDİŞ (%12)",
                          "₺${_formatCurrency(merkezKar)}",
                          Icons.account_balance_wallet,
                          primaryCyan,
                          "Net Ağ Kârı"
                      ),
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("CANLI İŞLEM AKIŞI", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    Icon(Icons.fiber_manual_record, color: Colors.redAccent, size: 12), // Canlı kayıt ikonu
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // =================================================================
              // 2. CANLI İŞLEM LİSTESİ
              // =================================================================
              Expanded(
                child: (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_balance_outlined, color: Colors.white.withOpacity(0.05), size: 80),
                      const SizedBox(height: 16),
                      const Text("AĞDA HENÜZ İŞLEM YOK", style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ],
                  ),
                )
                    : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    var data = doc.data() as Map<String, dynamic>;
                    double islemTutari = (data['tutar'] ?? 0.0).toDouble();
                    double islemKari = islemTutari * 0.12; // %12 Kâr

                    // Firebase ID'sinin ilk 8 hanesini TXN (Transaction) ID olarak alıyoruz
                    String islemId = doc.id.length >= 8 ? doc.id.substring(0, 8).toUpperCase() : doc.id.toUpperCase();

                    return _buildTransactionRow(islemTutari, islemKari, islemId);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: FİNANS KARTI
  Widget _buildFinanceCard(String baslik, String deger, IconData ikon, Color renk, String altBilgi) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: renk.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: renk.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: renk.withOpacity(0.1), shape: BoxShape.circle), child: Icon(ikon, color: renk, size: 18)),
              Icon(Icons.trending_up, color: renk.withOpacity(0.5), size: 16),
            ],
          ),
          const SizedBox(height: 16),
          Text(baslik, style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(deger, style: TextStyle(color: renk, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Text(altBilgi, style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: İŞLEM SATIRI (LOG)
  Widget _buildTransactionRow(double tutar, double kar, String islemId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: primaryCyan.withOpacity(0.3))),
            child: const Icon(Icons.currency_exchange, color: primaryCyan, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("YENİ GÜVENLİ HAVUZ İŞLEMİ", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("TXN: $islemId", style: const TextStyle(color: Colors.white38, fontSize: 10, fontFamily: 'monospace', letterSpacing: 1)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("₺${_formatCurrency(tutar)}", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text("KÂR: ", style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w900)),
                  Text("+ ₺${_formatCurrency(kar)}", style: const TextStyle(color: primaryCyan, fontSize: 11, fontWeight: FontWeight.w900)),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}