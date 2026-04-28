// lib/widgets/car_ad_card.dart
import 'package:flutter/material.dart';

/// 🛡️ KUANTUM İLAN VİTRİN KARTI (SiberIlanKarti)
/// Araç ilanlarını Kuantum Turkuazı ve OLED Siyahı ile sergiler, DNA skorunu vurgular.
class SiberIlanKarti extends StatelessWidget {
  final Map<String, dynamic> ilanVerisi;
  final VoidCallback? onTap;

  SiberIlanKarti({
    super.key,
    required this.ilanVerisi,
    this.onTap,
  });

  // ── 🎨 KARARGAH TASARIM DOKTRİNİ ──
  static Color _matGrey = Color(0xFF111111);
  static Color _kuantumCyan = Color(0xFF00FFC2);

  @override
  Widget build(BuildContext context) {
    // 📡 Veritabanı İstihbarat Değişkenleri (Zırhlı Null Kontrolü)
    String markaModel = ilanVerisi['marka_model']?.toString().toUpperCase() ?? "BİLİNMEYEN ARAÇ";
    String fiyat = ilanVerisi['fiyat']?.toString() ?? "0";
    bool guvenliKapora = ilanVerisi['guvenli_kapora'] ?? false;
    String resimUrl = ilanVerisi['resim_url']?.toString() ?? "";
    int dnaSkoru = int.tryParse(ilanVerisi['dna_skoru']?.toString() ?? '0') ?? 0;

    // ⚖️ DNA Skoruna göre zırh rengini belirleme motoru
    Color dnaRengi = dnaSkoru >= 80
        ? _kuantumCyan
        : (dnaSkoru >= 50 ? Colors.orangeAccent : Colors.redAccent);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: _matGrey,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: Offset(0, 5),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 📸 1. SİBER OPTİK (RESİM VE DNA ROZETİ) ──
            Stack(
              children: [
                // Araç Görseli
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                  child: resimUrl.isNotEmpty
                      ? Image.network(
                    resimUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildResimHatasi(),
                  )
                      : _buildResimHatasi(),
                ),

                // Kuantum DNA Skoru Rozeti
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF000000).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: dnaRengi, width: 1.5),
                      boxShadow: [BoxShadow(color: dnaRengi.withOpacity(0.4), blurRadius: 10)],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.radar, color: dnaRengi, size: 14),
                        SizedBox(width: 4),
                        Text(
                          "DNA %$dnaSkoru",
                          style: TextStyle(color: dnaRengi, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── 📊 2. ARAÇ İSTİHBARAT BİLGİLERİ ──
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    markaModel,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),

                  Text(
                    "₺$fiyat",
                    style: TextStyle(color: _kuantumCyan, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),

                  SizedBox(height: 12),

                  // Kuantum Güvenli Kapora Çipi
                  if (guvenliKapora)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _kuantumCyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _kuantumCyan.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_user_outlined, size: 14, color: _kuantumCyan),
                          SizedBox(width: 6),
                          Text("SİBER GÜVENLİ KAPORA", style: TextStyle(color: _kuantumCyan, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        ],
                      ),
                    ),

                  SizedBox(height: 12),
                  Divider(color: Colors.white12, height: 1),
                  SizedBox(height: 12),

                  // Yasal Mühür Uyarı
                  Row(
                    children: [
                      Icon(Icons.gavel_outlined, color: Colors.white30, size: 12),
                      SizedBox(width: 4),
                      Text("SORUMLULUK SATICI BEYANINA AİTTİR.", style: TextStyle(fontSize: 9, color: Colors.white30, letterSpacing: 1)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Resim yüklenemediğinde çıkacak Siber Yedek (Fallback) Ekranı
  Widget _buildResimHatasi() {
    return Container(
      height: 180,
      width: double.infinity,
      color: Colors.black54,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.car_crash_outlined, color: Colors.white30, size: 40),
          SizedBox(height: 8),
          Text("GÖRSEL SİNYALİ YOK", style: TextStyle(color: Colors.white30, fontSize: 10, letterSpacing: 2)),
        ],
      ),
    );
  }
}