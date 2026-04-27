import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

class BolgeBayiTerminali extends StatefulWidget {
  const BolgeBayiTerminali({super.key});

  @override
  State<BolgeBayiTerminali> createState() => _BolgeBayiTerminaliState();
}

class _BolgeBayiTerminaliState extends State<BolgeBayiTerminali> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Sahte Veri
  int bekleyenOnay = 14;
  int stokMiktari = 1450;

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 18), onPressed: () => Navigator.pop(context)),
          title: const Text("BÖLGE / ÜLKE YÖNETİMİ", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 3, fontFamily: 'Avenir')),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStokDurumPaneli(),
              const SizedBox(height: 32),
              const Text("ALT BAYİ ONAY BEKLEYENLER", style: TextStyle(color: SiberTema.textMuted, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 16),
              _buildOnayListesi(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStokDurumPaneli() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.1), blurRadius: 20)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("BÖLGE STOK HACMİ", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("$stokMiktari KİT", style: const TextStyle(color: SiberTema.textMain, fontSize: 28, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.inventory_2, color: SiberTema.kuantumCyan, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildOnayListesi() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3, // Örnek olarak 3 bayi
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(16), border: Border.all(color: SiberTema.textMuted)),
          child: Row(
            children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.handyman, color: Colors.amber, size: 18)),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Kadıköy Yetkili Servisi", style: TextStyle(color: SiberTema.textMain, fontSize: 13, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text("LPG Montaj Onayı Bekliyor", style: TextStyle(color: SiberTema.textMuted, fontSize: 11)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bölge Onayı Verildi ve Mühürlendi!"), backgroundColor: SiberTema.kuantumCyan));
                },
                style: ElevatedButton.styleFrom(backgroundColor: SiberTema.kuantumCyan, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: const Text("ONAYLA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
              )
            ],
          ),
        );
      },
    );
  }
}
