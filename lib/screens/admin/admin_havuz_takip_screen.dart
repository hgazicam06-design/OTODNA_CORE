import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🛡️ KARARGAH ZIRHLARI VE MUTLAK ROTA
import '../../../core/siber_tema.dart';
import '../../../core/responsive_kalkan.dart';

class AdminHavuzTakip extends StatefulWidget {
  const AdminHavuzTakip({super.key});

  @override
  State<AdminHavuzTakip> createState() => _AdminHavuzTakipState();
}

class _AdminHavuzTakipState extends State<AdminHavuzTakip> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  final Color _bgColor = SiberTema.oledBlack;
  final Color _surfaceColor = SiberTema.matGrey.withOpacity(0.1);
  final Color _primaryCyan = SiberTema.kuantumCyan;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Sayıları formatlamak için siber yardımcı fonksiyon (Örn: 1.250,00 ₺)
  String _formatCurrency(double amount) {
    String formatted = amount.toStringAsFixed(2);
    formatted = formatted.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return "$formatted ₺";
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context)),
          title: const Text('H A V U Z   T A K İ P',
              style: TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 3,
                  fontFamily: 'Avenir')),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: _primaryCyan, size: 20),
              onPressed: () => setState(() {}),
            )
          ],
        ),
        body: Column(
          children: [
            _siberOzetKarti(),
            Expanded(child: _islemListesi()),
          ],
        ),
      ),
    );
  }

  // 💰 ÜST ÖZET: SİSTEMDE BİRİKEN TOPLAM GAZİ PAYI
  Widget _siberOzetKarti() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _primaryCyan.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: _primaryCyan.withOpacity(0.05), blurRadius: 20)
        ],
      ),
      child: Column(
        children: [
          const Text("MERKEZİ HAVUZ BİRİKİMİ",
              style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: _db.collection('transactions').where('durum', isEqualTo: 'Onaylandı').snapshots(),
            builder: (context, snapshot) {
              double toplamGaziPayi = 0;
              if (snapshot.hasData) {
                for (var doc in snapshot.data!.docs) {
                  toplamGaziPayi += (doc['otodna_payi'] ?? 0).toDouble();
                }
              }
              return Text(
                _formatCurrency(toplamGaziPayi),
                style: TextStyle(color: _primaryCyan, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1),
              );
            },
          ),
        ],
      ),
    );
  }

  // 📜 CANLI İŞLEM AKIŞI
  Widget _islemListesi() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('transactions').orderBy('tarih', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator(color: _primaryCyan));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var data = snapshot.data!.docs[index];
            return _islemKarti(data);
          },
        );
      },
    );
  }

  Widget _islemKarti(DocumentSnapshot doc) {
    bool isCompleted = doc['durum'] == 'Onaylandı';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isCompleted ? _primaryCyan.withOpacity(0.1) : Colors.white10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isCompleted ? _primaryCyan.withOpacity(0.1) : Colors.white10,
            child: Icon(isCompleted ? Icons.check : Icons.timer, color: isCompleted ? _primaryCyan : Colors.white30, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc['firm_adi'] ?? "Bilinmeyen Bayi", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                Text(doc['islem_tipi'] ?? "Genel İşlem", style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_formatCurrency(doc['toplam_tutar']), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
              Text("+${_formatCurrency(doc['otodna_payi'])}", style: TextStyle(color: _primaryCyan, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}