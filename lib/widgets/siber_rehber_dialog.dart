import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/siber_tema.dart';

/// 🧠 OTODNA SİBER ASİSTAN VE EĞİTİM MODÜLÜ
/// Uygulamanın derinliğini ve zenginliğini kullanıcıya anlatan,
/// "Bir daha gösterme" yeteneğine sahip, her ekrana eklenebilir modüler rehber.
class SiberRehber {
  /// Bir ekrana girildiğinde otomatik olarak rehberi başlatır.
  /// [screenKey] : Hangi ekran olduğunu belirten eşsiz anahtar (örn: 'musteri_cuzdan_rehber')
  /// [baslik] : Rehber popup başlığı
  /// [icerik] : Rehberin kullanıcıya sunacağı salt okunur açıklama
  static Future<void> otomatikGoster({
    required BuildContext context,
    required String screenKey,
    required String baslik,
    required String icerik,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final bool tekrarGosterme = prefs.getBool(screenKey) ?? false;

    if (tekrarGosterme) return; // Kullanıcı "bir daha gösterme" demişse çık.

    // Rehberi göster
    if (context.mounted) {
      await goster(context: context, screenKey: screenKey, baslik: baslik, icerik: icerik);
    }
  }

  /// Manuel olarak rehberi (soru işaretine basıldığında vb.) açar.
  /// "Bir daha gösterme" işlevini yoksayar, zorla gösterir.
  static Future<void> goster({
    required BuildContext context,
    required String screenKey,
    required String baslik,
    required String icerik,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // Kullanıcı okumak zorunda, dışarı tıklayıp geçemez.
      builder: (context) => _SiberRehberDialogWidget(screenKey: screenKey, baslik: baslik, icerik: icerik),
    );
  }
}

class _SiberRehberDialogWidget extends StatefulWidget {
  final String screenKey;
  final String baslik;
  final String icerik;

  const _SiberRehberDialogWidget({
    required this.screenKey,
    required this.baslik,
    required this.icerik,
  });

  @override
  State<_SiberRehberDialogWidget> createState() => _SiberRehberDialogWidgetState();
}

class _SiberRehberDialogWidgetState extends State<_SiberRehberDialogWidget> {
  bool _birDahaGosterme = false;

  Future<void> _kapat() async {
    if (_birDahaGosterme) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(widget.screenKey, true);
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.95),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: SiberTema.kuantumCyan, width: 2),
          boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.15), blurRadius: 40)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline_rounded, color: SiberTema.kuantumCyan, size: 56),
            const SizedBox(height: 16),
            Text(widget.baslik, textAlign: TextAlign.center, style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: Colors.white12, thickness: 1),
            ),
            
            // İÇERİK METNİ (Salt Okunur ve Kaydırılabilir)
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                  widget.icerik,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.6, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // "BİR DAHA GÖSTERME" CHECKBOX'I
            GestureDetector(
              onTap: () => setState(() => _birDahaGosterme = !_birDahaGosterme),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _birDahaGosterme ? SiberTema.kuantumCyan : Colors.white12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_birDahaGosterme ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded, color: _birDahaGosterme ? SiberTema.kuantumCyan : Colors.white38, size: 20),
                    const SizedBox(width: 8),
                    const Text("Bu paneli bir daha gösterme", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // ONAY BUTONU
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _kapat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SiberTema.kuantumCyan,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("ANLADIM, DEVAM ET", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 14)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
