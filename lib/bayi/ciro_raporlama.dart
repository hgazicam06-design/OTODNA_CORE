// lib/bayi/ciro_raporlama.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI VE MERKEZİ TEMA BAĞLANTISI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

/// 🛡️ KUANTUM CİRO VE FİNANSAL RAPORLAMA MERKEZİ (CiroRaporPaneli)
/// Bayinin kasasındaki canlı işlem hacmini (İşçilik ayrı, Parça ayrı) ve otonom Karargah payını sunar.
class CiroRaporPaneli extends StatefulWidget {
  final String bayiId; // Raporu çeken bayinin Karargah kimliği

  const CiroRaporPaneli({super.key, required this.bayiId});

  @override
  State<CiroRaporPaneli> createState() => _CiroRaporPaneliState();
}

class _CiroRaporPaneliState extends State<CiroRaporPaneli> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void _raporIndir() {
    HapticFeedback.heavyImpact();
    developer.log("SİBER RAPOR: ${widget.bayiId} için PDF muhasebe dökümü Karargahtan talep edildi.");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SiberTema.kuantumCyan,
        content: const Text("SİBER ONAY: Mühürlü PDF raporu hazırlanıyor...", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("GÜNLÜK FİNANSAL RAPOR", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 13)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: SiberTema.kuantumCyan),
        ),
        body: StreamBuilder<QuerySnapshot>(
          // SİBER NOT: Canlı sistemde bu sorguya gün (zaman) filtresi de eklenir.
          stream: _db.collection('finans_havuzu').where('bayi_id', isEqualTo: widget.bayiId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
            }

            double toplamIscilikCirosu = 0.0;
            double toplamParcaCirosu = 0.0;
            int servisSayisi = 0;

            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              servisSayisi = snapshot.data!.docs.length;
              for (var doc in snapshot.data!.docs) {
                var data = doc.data() as Map<String, dynamic>;
                toplamIscilikCirosu += (data['iscilik_tutari'] ?? 0.0).toDouble();
                toplamParcaCirosu += (data['parca_satis_tutari'] ?? 0.0).toDouble();
              }
            }

            double genelCiro = toplamIscilikCirosu + toplamParcaCirosu;

            // ⚖️ YENİ TİCARET DOKTRİNİ: Sadece B2B Parça Satışından Kesinti!
            double kesintiOrani = (widget.bayiId == "MURAT_PLAZA") ? 0.30 : 0.12;
            double sistemPayi = toplamParcaCirosu * kesintiOrani;
            double bayiNetKazanci = genelCiro - sistemPayi; // İşçilik tam kalır, parça karından kesinti düşer

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _anaKasaKarti(genelCiro),
                  const SizedBox(height: 24),

                  _detayliRaporSatiri("TAMAMLANAN İŞLEM", "$servisSayisi ARAÇ", Icons.directions_car_outlined, Colors.white),
                  const SizedBox(height: 12),

                  _detayliRaporSatiri("SAF İŞÇİLİK (%100 BAYİNİN)", "₺${toplamIscilikCirosu.toStringAsFixed(2)}", Icons.build_circle_outlined, SiberTema.kuantumCyan),
                  const SizedBox(height: 12),

                  _detayliRaporSatiri("OTODNA TEDARİK PAYI (%${(kesintiOrani * 100).toInt()})", "- ₺${sistemPayi.toStringAsFixed(2)}", Icons.account_balance_outlined, SiberTema.kanKirmizi),
                  const SizedBox(height: 12),

                  _detayliRaporSatiri("NET BAYİ KAZANCI", "₺${bayiNetKazanci.toStringAsFixed(2)}", Icons.wallet_outlined, SiberTema.altinSari, isLarge: true),

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
                      label: const Text("SİBER RAPORU (PDF) İNDİR", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13)),
                      style: SiberTema.kuantumButonStili(),
                      onPressed: _raporIndir,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _anaKasaKarti(double miktar) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: SiberTema.matGrey.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5), width: 2),
        boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.1), blurRadius: 20, spreadRadius: 5)],
      ),
      child: Column(
        children: [
          const Text("TOPLAM BRÜT GÜNLÜK CİRO", style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Text("₺${miktar.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _detayliRaporSatiri(String baslik, String deger, IconData ikon, Color degerRengi, {bool isLarge = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(color: SiberTema.matGrey.withOpacity(0.5), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
      child: Row(
        children: [
          Icon(ikon, color: Colors.white54, size: 24),
          const SizedBox(width: 16),
          Expanded(child: Text(baslik, style: const TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.bold))),
          Text(deger, style: TextStyle(color: degerRengi, fontSize: isLarge ? 20 : 16, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _imeceDurumKarti() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: SiberTema.siberCamZirh(renk: Colors.black),
      child: const Row(
        children: [
          Icon(Icons.handshake_outlined, color: SiberTema.kuantumCyan, size: 30),
          SizedBox(width: 16),
          Expanded(
              child: Text(
                  "SİBER ONAY: Bugün 1 İmece işlemine destek oldunuz. Karargah DNA Skorunuza +100 Puan eklendi.",
                  style: TextStyle(color: Colors.white70, fontSize: 10, height: 1.5, letterSpacing: 0.5, fontWeight: FontWeight.bold)
              )
          ),
        ],
      ),
    );
  }
}