// lib/widgets/siber_fiyat_karti.dart
import 'package:flutter/material.dart';
import '../core/siber_tema.dart';

/// 🦅 OTODNA AKILLI FİYAT KARTI (ZIRHLI V2)
/// Bu bileşen, ağdaki her işlemin finansal DNA'sını kullanıcıya ve bayiye şeffafça sunar.
class SiberFiyatKarti extends StatelessWidget {
  final double satisFiyati;
  const SiberFiyatKarti({
    super.key,
    required this.satisFiyati,
  });

  @override
  Widget build(BuildContext context) {
    // 🛡️ SİBER FİNANS PROTOKOLÜ
    // Evrensel Karargah Payı: %12 (%10 Kar + %2 Vergi)
    const double komisyonOrani = 0.12;
    final double hizmetBedeli = satisFiyati * komisyonOrani;
    final double esnafaKalan = satisFiyati - hizmetBedeli;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SiberTema.matGrey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: SiberTema.kuantumCyan.withOpacity(0.3),
            width: 1.5
        ),
        boxShadow: [
          BoxShadow(
              color: SiberTema.kuantumCyan.withOpacity(0.05),
              blurRadius: 20,
              spreadRadius: -5
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📡 BAŞLIK: SİBER PROTOKOLLER
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined, color: SiberTema.kuantumCyan, size: 20),
              const SizedBox(width: 12),
              const Text(
                "SİBER FİYATLANDIRMA PROTOKOLÜ",
                style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 1. ÜRÜN SATIŞ FİYATI
          _fiyatSatiri(
              baslik: "ÜRÜN SATIŞ FİYATI",
              deger: satisFiyati,
              renk: Colors.white,
              isMain: true
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.white10, thickness: 1),
          ),

          // 2. KESİNTİ MOTORU
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                      "SİBER AĞ KESİNTİSİ ",
                      style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4)
                    ),
                    child: Text(
                        "%${(komisyonOrani * 100).toInt()}",
                        style: const TextStyle(color: Colors.redAccent, fontSize: 9, fontWeight: FontWeight.w900, fontFamily: 'monospace')
                    ),
                  )
                ],
              ),
              Text(
                  "- ₺${hizmetBedeli.toStringAsFixed(2)}",
                  style: TextStyle(color: Colors.redAccent.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w900, fontFamily: 'monospace')
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 3. NET KAZANÇ (ESNAFA KALAN)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SiberTema.kuantumCyan.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                    "NET HAKEDİŞ (CÜZDAN)",
                    style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)
                ),
                Text(
                    "₺${esnafaKalan.toStringAsFixed(2)}",
                    style: const TextStyle(
                        color: SiberTema.kuantumCyan,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                        letterSpacing: 1
                    )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🛠️ YARDIMCI SATIR MOTORU
  Widget _fiyatSatiri({required String baslik, required double deger, required Color renk, bool isMain = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
            baslik,
            style: TextStyle(color: renk, fontSize: isMain ? 12 : 11, fontWeight: FontWeight.w900, letterSpacing: 1)
        ),
        Text(
            "₺${deger.toStringAsFixed(2)}",
            style: TextStyle(color: renk, fontSize: isMain ? 16 : 13, fontWeight: FontWeight.w900, fontFamily: 'monospace')
        ),
      ],
    );
  }
}