import 'package:flutter/material.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  final Color bgColor = const Color(0xFF000000);
  final Color surfaceColor = const Color(0xFF111111);
  final Color primaryCyan = const Color(0xFF00FFC2);
  final Color dangerColor = Colors.redAccent;

  final double caymaBedeli = 200.0;
  bool _isProcessing = false;

  void _odemeVeMuhurlemeBaslat() async {
    setState(() => _isProcessing = true);

    // Siber ağa bağlanma ve Iyzico yönlendirme simülasyonu
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isProcessing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('GÜVENLİ ÖDEME AĞINA BAĞLANILIYOR...', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: primaryCyan,
      ),
    );
    // TODO: Finans modülüne (02_Finans / Iyzico) yönlendirme burada yapılacak.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('R A N D E V U   M Ü H R Ü', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 3)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // =================================================================
            // 1. SİBER ADALET / GÜVENCE İKONU
            // =================================================================
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryCyan.withOpacity(0.05),
                shape: BoxShape.circle,
                border: Border.all(color: primaryCyan.withOpacity(0.3), width: 2),
                boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.1), blurRadius: 40)],
              ),
              child: const Icon(Icons.gavel_rounded, size: 64, color: Color(0xFF00FFC2)),
            ),
            const SizedBox(height: 32),

            // =================================================================
            // 2. TUTAR VE BAŞLIK
            // =================================================================
            const Text(
              "SİBER GÜVENCE BEDELİ",
              style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2),
            ),
            const SizedBox(height: 12),
            Text(
              "₺${caymaBedeli.toStringAsFixed(0)}",
              style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.w900, letterSpacing: -2),
            ),
            const SizedBox(height: 16),
            const Text(
              "Bu randevuyu Kuantum Ağına mühürlemek ve işlem sırasını rezerve etmek için yukarıdaki güvence bedeli bloke edilecektir.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),

            // =================================================================
            // 3. ACIKASIZ KESİNTİ UYARISI (Kırmızı Kuantum Kalkanı)
            // =================================================================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: dangerColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: dangerColor.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, color: dangerColor, size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "İHLAL PROTOKOLÜ UYARISI",
                          style: TextStyle(color: dangerColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Randevuya gelinmediği veya son anda iptal edildiği takdirde bu bedelin ₺100'si Usta Tazminatı, ₺100'si OtoDNA İşletme Bedeli olarak kesin kesintiye uğrayacaktır.",
                          style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.5, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // =================================================================
            // 4. GÜVENLİ MÜHÜRLEME BUTONU
            // =================================================================
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryCyan,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _isProcessing ? null : _odemeVeMuhurlemeBaslat,
                icon: _isProcessing
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : const Icon(Icons.lock_outline, size: 24),
                label: Text(
                  _isProcessing ? "AĞA BAĞLANILIYOR..." : "₺200 ÖDE VE MÜHÜRLE",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}