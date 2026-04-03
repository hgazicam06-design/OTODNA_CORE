// -----------------------------------------------------------------------------------------
// 🚀 SİBER YARDIMCI BİLEŞEN: OTODNA AKILLI FİYAT KARTI (Ayrı bir Widget olarak yazıldı)
// Bunu catalog_screen.dart içine veya widget klasörüne koyabilirsin.
// Kullanımı: SiberFiyatKarti(satisFiyati: 1500.0)
// -----------------------------------------------------------------------------------------

import 'package:flutter/material.dart';

class SiberFiyatKarti extends StatelessWidget {
  final double satisFiyati; // Bu değer veritabanından veya Textfield'dan dinamik gelecek

  const SiberFiyatKarti({super.key, required this.satisFiyati});

  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  static const Color bgColor = Color(0xFF000000);
  static const Color surfaceColor = Color(0xFF111111);
  static const Color primaryCyan = Color(0xFF00FFC2);
  static const Color dangerColor = Colors.redAccent;

  @override
  Widget build(BuildContext context) {
    // 💥 %12 ACIMASIZ KUANTUM KESİNTİSİ (%10 Kâr + %2 Vergi)
    final double komisyonOrani = 0.12;
    final double hizmetBedeli = satisFiyati * komisyonOrani;
    final double esnafaKalan = satisFiyati - hizmetBedeli;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryCyan.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined, color: primaryCyan, size: 20),
              const SizedBox(width: 12),
              const Text(
                "SİBER FİYATLANDIRMA PROTOKOLÜ",
                style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 1. ÜRÜN SATIŞ FİYATI
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("ÜRÜN SATIŞ FİYATI", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1)),
              Text("₺${satisFiyati.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.white12),
          ),

          // 2. OTODNA HİZMET BEDELİ (%12)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text("SİBER AĞ KESİNTİSİ ", style: TextStyle(color: dangerColor, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: dangerColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: const Text("%12", style: TextStyle(color: dangerColor, fontSize: 9, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
                  )
                ],
              ),
              Text("- ₺${hizmetBedeli.toStringAsFixed(2)}", style: TextStyle(color: dangerColor.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
            ],
          ),

          const SizedBox(height: 16),

          // 3. ESNAFA KALACAK NET TUTAR
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryCyan.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryCyan.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("ESNAFA GEÇECEK NET TUTAR", style: TextStyle(color: Color(0xFF00FFC2), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
                Text("₺${esnafaKalan.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFF00FFC2), fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'monospace', letterSpacing: 1)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}