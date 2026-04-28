// lib/widgets/category_card.dart
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM KATEGORİ MODÜLÜ (SiberKategoriKarti)
/// Ana üs (Home Screen) üzerinde yer alan, uzmanlık alanlarına ve Firebase rotalarına hızlı geçiş sağlayan Siber Buton.
class SiberKategoriKarti extends StatelessWidget {
  final String baslik;
  final IconData ikon;
  final VoidCallback onTap;

  SiberKategoriKarti({
    super.key,
    required this.baslik,
    required this.ikon,
    required this.onTap,
  });

  // ── 🎨 KARARGAH TASARIM DOKTRİNİ ──
  static Color _matGrey = Color(0xFF111111);
  static Color _kuantumCyan = Color(0xFF00FFC2);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        developer.log("🚀 SİBER YÖNLENDİRME: ${baslik.toUpperCase()} modülüne geçiş yapılıyor...");
        onTap(); // Gerçek Firebase veya Navigasyon rotasını tetikler
      },
      borderRadius: BorderRadius.circular(16),
      splashColor: _kuantumCyan.withOpacity(0.3), // Kuantum dalgalanma efekti
      highlightColor: _kuantumCyan.withOpacity(0.1),
      child: Container(
        decoration: BoxDecoration(
          color: _matGrey,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12, width: 1.5), // İnce siber çerçeve
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Siber İkon Kalkanı
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _kuantumCyan.withOpacity(0.05),
                shape: BoxShape.circle,
                border: Border.all(color: _kuantumCyan.withOpacity(0.3)),
              ),
              child: Icon(ikon, size: 36, color: _kuantumCyan),
            ),
            SizedBox(height: 16),

            // Kategori Başlığı (Military Format)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                baslik.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}