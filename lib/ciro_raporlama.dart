// lib/screens/ciro_raporlama.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM CİRO VE FİNANSAL RAPORLAMA MERKEZİ (CiroRaporPaneli)
/// Bayinin kasasındaki canlı işlem hacmini, otonom Karargah payını ve net kazancı Firebase'den çekerek sunar.
class CiroRaporPaneli extends StatefulWidget {
  final String bayiId; // Raporu çeken bayinin Karargah kimliği

  const CiroRaporPaneli({super.key, required this.bayiId});

  @override
  State<CiroRaporPaneli> createState() => _CiroRaporPaneliState();
}

class _CiroRaporPaneliState extends State<CiroRaporPaneli> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 🎨 KARARGAH TASARIM DOKTRİNİ ──
  static const Color _oledBlack = Color(0xFF000000);
  static const Color _matGrey = Color(0xFF111111);
  static const Color _kuantumCyan = Color(0xFF00FFC2);

  void _raporIndir() {
    HapticFeedback.heavyImpact();
    developer.log("SİBER RAPOR: ${widget.bayiId} için PDF muhasebe dökümü Karargahtan talep edildi.");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _kuantumCyan,
        content: const Text("SİBER ONAY: Mühürlü PDF raporu hazırlanıyor...", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _oledBlack,
      appBar: AppBar(
        title: const Text("GÜNLÜK FİNANSAL RAPOR", style: TextStyle(color: _kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kuantumCyan),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // SİBER NOT: Canlı sistemde bu sorguya gün (zaman) filtresi de eklenir.
        stream: _db.collection('finans_havuzu').where('bayi_id', isEqualTo: widget.bayiId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _kuantumCyan));
          }

          double toplamCiro = 0.0;
          int servisSayisi = 0;

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            servisSayisi = snapshot.data!.docs.length;
            for (var doc in snapshot.data!.docs) {
              var data = doc.data() as Map<String, dynamic>;
              toplamCiro += (data['toplam_tutar'] ?? 0.0).toDouble();
            }
          }

          // ⚖️ KARARGAH FİNANS KURALI: Murat Plaza %30, diğerleri %12 kesinti!
          double kesintiOrani = (widget.bayiId == "MURAT_PLAZA") ? 0.30 : 0.12;
          double sistemPayi = toplamCiro * kesintiOrani;
          double bayiNet = toplamCiro - sistemPayi;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _anaKasaKarti(toplamCiro),
                const SizedBox(height: 24),

                _detayliRaporSatiri("TAMAMLANAN İŞLEM", "$servisSayisi ARAÇ / İŞLEM", Icons.directions_car_outlined, Colors.white),
                const SizedBox(height: 12),

                _detayliRaporSatiri("OTODNA PAYI (%${(kesintiOrani * 100).toInt()})", "- ₺${sistemPayi.toStringAsFixed(2)}", Icons.account_balance_outlined, Colors.redAccent),
                const SizedBox(height: 12),

                _detayliRaporSatiri("NET BAYİ KAZANCI", "₺${bayiNet.toStringAsFixed(2)}", Icons.wallet_outlined, _kuantumCyan),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Divider(color: Colors.white24, height: 2, thickness: 1),
                ),

                _imeceDurumKarti(),

                const SizedBox(height: 40),

                SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download_rounded, color: Colors.black, size: 24),
                    label: const Text("MUHASEBE RAPORUNU (PDF) İNDİR", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kuantumCyan,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 10,
                      shadowColor: _kuantumCyan.withOpacity(0.5),
                    ),
                    onPressed: _raporIndir,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _anaKasaKarti(double miktar) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: _matGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kuantumCyan.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(color: _kuantumCyan.withOpacity(0.1), blurRadius: 20, spreadRadius: 5),
        ],
      ),
      child: Column(
        children: [
          const Text("TOPLAM GÜNLÜK CİRO", style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text("₺${miktar.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _detayliRaporSatiri(String baslik, String deger, IconData ikon, Color degerRengi) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(color: _matGrey, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
      child: Row(
        children: [
          Icon(ikon, color: Colors.white54, size: 24),
          const SizedBox(width: 16),
          Expanded(child: Text(baslik, style: const TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.bold))),
          Text(deger, style: TextStyle(color: degerRengi, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _imeceDurumKarti() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFF00FFC2).withOpacity(0.05), // Kuantum Turkuazı transparan
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kuantumCyan.withOpacity(0.3), width: 1.5)
      ),
      child: Row(
        children: [
          const Icon(Icons.handshake_outlined, color: _kuantumCyan, size: 30),
          const SizedBox(width: 16),
          const Expanded(
              child: Text(
                  "SİBER ONAY: Bugün 1 İmece işlemine destek oldunuz. Karargah DNA Skorunuza +100 Puan eklendi.",
                  style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.5, letterSpacing: 0.5)
              )
          ),
        ],
      ),
    );
  }
}