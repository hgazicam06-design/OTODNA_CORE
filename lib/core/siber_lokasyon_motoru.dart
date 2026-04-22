// lib/core/siber_lokasyon_motoru.dart
import 'package:flutter/material.dart';

import 'siber_tema.dart';
import 'kuresel_harita_sistemi.dart';

class SiberLokasyonMotoru extends StatefulWidget {
  final void Function(String ulke, String sehir, String bolge) onLokasyonSecildi;

  const SiberLokasyonMotoru({super.key, required this.onLokasyonSecildi});

  @override
  State<SiberLokasyonMotoru> createState() => _SiberLokasyonMotoruState();
}

class _SiberLokasyonMotoruState extends State<SiberLokasyonMotoru> {
  String _seciliUlke = KureselHaritaSistemi.globalMerkezUlkemiz;
  String? _seciliYer;

  @override
  Widget build(BuildContext context) {
    List<String> siraliSehirler = KureselHaritaSistemi.tumSehirleriGetir(_seciliUlke);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [Color(0xFF2A2C30), Color(0xFF131518), Color(0xFF08090C)],
          ),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.15), width: 1.5),
            left: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
            right: BorderSide(color: Colors.black.withOpacity(0.8), width: 1.5),
            bottom: BorderSide(color: Colors.black.withOpacity(0.8), width: 2),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.9), blurRadius: 15, offset: const Offset(0, 10)),
            // 🔥 'const' İhlali Yaratabilecek Siber Zafiyet Kaldırıldı
            BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.05), blurRadius: 30, spreadRadius: -5),
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.radar, color: SiberTema.kuantumCyan.withOpacity(0.8), size: 24, shadows: [Shadow(color: SiberTema.kuantumCyan.withOpacity(0.5), blurRadius: 10)]),
              const SizedBox(width: 12),
              const Text("KÜRESEL LOKASYON RADARI", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.white12, thickness: 1.5),
          ),

          // 1. ÜLKE SEÇİM SİBER BUTONLARI (Dinamik Kaydırılabilir Liste)
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: SiberTema.oledBlack,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 8)]
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: KureselHaritaSistemi.ulkeleriGetir().map((ulke) {
                  return _buildUlkeToggle(ulke, ulke == "Türkiye" ? Icons.star_border : Icons.public);
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 2. ŞEHİR / EYALET SEÇİM DROPDOWN
          const Text("OPERASYON BÖLGESİ / ŞEHİR", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
          const SizedBox(height: 8),

          Container(
            decoration: BoxDecoration(
                color: SiberTema.oledBlack,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 5)]
            ),
            child: DropdownButtonFormField<String>(
              value: _seciliYer,
              dropdownColor: SiberTema.matGrey,
              icon: const Icon(Icons.location_on, color: SiberTema.kuantumCyan),
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              hint: Text("BİR LOKASYON SEÇİN...", style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),

              // 🔥 TİP UYUŞMAZLIĞINA KARŞI KATİ MÜHÜR EKLENDİ
              items: siraliSehirler.map<DropdownMenuItem<String>>((String yer) {
                return DropdownMenuItem<String>(
                  value: yer,
                  child: Text(yer.toUpperCase(), style: const TextStyle(letterSpacing: 1)),
                );
              }).toList(),

              onChanged: (yeniYer) {
                setState(() { _seciliYer = yeniYer; });
                if (yeniYer != null) {
                  String otonomBolge = KureselHaritaSistemi.hangiBolgede(_seciliUlke, yeniYer);
                  widget.onLokasyonSecildi(_seciliUlke, yeniYer, otonomBolge);
                }
              },
            ),
          ),

          // 3. SEÇİLEN BÖLGE İSTİHBARATI
          if (_seciliYer != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: SiberTema.kuantumCyan.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3)),
                    boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.05), blurRadius: 15)]
                ),
                child: Row(
                  children: [
                    const Icon(Icons.my_location, color: SiberTema.kuantumCyan, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "BAĞLI DİSTRİBÜTÖRLÜK: ${KureselHaritaSistemi.hangiBolgede(_seciliUlke, _seciliYer!).toUpperCase()}",
                        style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUlkeToggle(String ulkeAdi, IconData icon) {
    bool isSelected = _seciliUlke == ulkeAdi;
    return GestureDetector(
        onTap: () {
          if (!isSelected) {
            setState(() {
              _seciliUlke = ulkeAdi;
              _seciliYer = null;
            });
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            gradient: isSelected ? const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1E2026), Color(0xFF0F1014)]) : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? SiberTema.kuantumCyan.withOpacity(0.5) : Colors.transparent),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 5, offset: const Offset(0, 3))] : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔥 GÖLGE CONST İHLALİ KALDIRILDI
              Icon(icon, color: isSelected ? SiberTema.kuantumCyan : Colors.white38, size: 16, shadows: isSelected ? [Shadow(color: SiberTema.kuantumCyan, blurRadius: 10)] : []),
              const SizedBox(width: 8),
              Text(
                ulkeAdi.toUpperCase(),
                style: TextStyle(color: isSelected ? SiberTema.kuantumCyan : Colors.white38, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}