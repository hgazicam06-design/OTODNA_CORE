// lib/widgets/hasar_kartlari.dart
import 'package:flutter/material.dart';

/// 🛡️ KUANTUM HASAR GÖRSELLEŞTİRME MODÜLÜ (SiberHasarKarti)
/// Aracın ekspertiz durumunu (Orijinal/Boya/Değişen) Karargah renk kodlarıyla ekrana mühürler.
class SiberHasarKarti extends StatelessWidget {
  final String parcaAdi;
  final String hasarDurumu;

  SiberHasarKarti({
    super.key,
    required this.parcaAdi,
    required this.hasarDurumu,
  });

  // ── 🎨 KARARGAH TASARIM DOKTRİNİ ──
  static Color _matGrey = Color(0xFF111111);
  static Color _kuantumCyan = Color(0xFF00FFC2);

  @override
  Widget build(BuildContext context) {
    Color durumRengi;
    String formatliDurum = hasarDurumu.trim().toUpperCase();

    // ⚖️ OTONOM SİBER RENK MOTORU (Kelime Avcısı)
    if (formatliDurum.contains('DEĞİŞEN') || formatliDurum.contains('DEGISEN')) {
      durumRengi = Colors.redAccent; // Ağır Kusur - Kan Kırmızı
      formatliDurum = "DEĞİŞEN";
    } else if (formatliDurum.contains('LOKAL')) {
      durumRengi = Colors.yellowAccent; // Hafif Kusur - Neon Sarı
      formatliDurum = "LOKAL BOYA";
    } else if (formatliDurum.contains('BOYA')) {
      durumRengi = Colors.orangeAccent; // Orta Kusur - Neon Turuncu
      formatliDurum = "BOYALI";
    } else {
      durumRengi = _kuantumCyan; // Kusursuz - Kuantum Turkuazı
      formatliDurum = "ORİJİNAL";
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _matGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: durumRengi.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: durumRengi.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── PARÇA ADI (ASKERİ FORMAT) ──
          Expanded(
            child: Text(
              parcaAdi.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),
          ),

          // ── DURUM MÜHRÜ (SİBER ÇİP) ──
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: durumRengi.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: durumRengi, width: 1.5),
            ),
            child: Text(
              formatliDurum,
              style: TextStyle(
                color: durumRengi,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}