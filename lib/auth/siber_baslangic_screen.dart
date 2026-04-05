import 'package:flutter/material.dart';

// 🔥 SİBER KÖPRÜ: 2 saniyelik şovdan sonra asıl Güvenlik Kapısına gidilecek
import 'otodna_auth_gate.dart';

class SiberBaslangicScreen extends StatefulWidget {
  const SiberBaslangicScreen({super.key});

  @override
  State<SiberBaslangicScreen> createState() => _SiberBaslangicScreenState();
}

class _SiberBaslangicScreenState extends State<SiberBaslangicScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Kalkan için Kuantum Nefes Animasyonu
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    // Siber Yönlendirme Motorunu Ateşle
    _kuantumKapilariniAc();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // --- 🔴 ROL KONTROLÜNÜ ANA KAPIYA DEVRETME MOTORU ---
  Future<void> _kuantumKapilariniAc() async {
    // Sürücüye Karargahın gücünü hissettirmek için 2 saniye bekle
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // 🔥 SİBER YÖNLENDİRME: İşin geri kalanını OtoDnaAuthGate (Ana Kapı) halledecek!
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OtoDnaAuthGate())
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🌑 TESLA MİMARİSİ
    const Color oledBlack = Color(0xFF000000);
    const Color primaryCyan = Color(0xFF00FFC2);

    return Scaffold(
      backgroundColor: oledBlack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // NEFES ALAN SİBER KALKAN
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 80,
                    height: 90,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(color: primaryCyan.withOpacity(0.5), blurRadius: 40, spreadRadius: 10)
                      ],
                    ),
                    child: const Icon(Icons.security, color: primaryCyan, size: 80),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),

            // KARARGAH METİNLERİ
            const Text(
              "OTODNA KARARGAHI ÇEVRİMİÇİ",
              style: TextStyle(
                color: primaryCyan,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                fontFamily: 'Avenir',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Siber Kalkanlar Aktif, Emir Bekleniyor...",
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                fontFamily: 'Avenir',
              ),
            ),

            const SizedBox(height: 60),

            // YÜKLENİYOR RADARI
            const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                color: primaryCyan,
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}