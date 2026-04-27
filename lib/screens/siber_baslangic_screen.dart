import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🔥 SİBER KÖPRÜLER VE TEMA (Zırh v2.0)
import '../core/siber_tema.dart';
import '../auth/otodna_auth_gate.dart';

class SiberBaslangicScreen extends StatefulWidget {
  const SiberBaslangicScreen({super.key});

  @override
  State<SiberBaslangicScreen> createState() => _SiberBaslangicScreenState();
}

class _SiberBaslangicScreenState extends State<SiberBaslangicScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();

    // Kalkan için Kuantum Nefes Animasyonu (Görsel İşçilik)
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    // Siber Yönlendirme Motorunu Ateşle
    _kuantumHologramKontrolu();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // --- 🎆 HOLOGRAM VE KAPI KONTROL MOTORU ---
  Future<void> _kuantumHologramKontrolu() async {
    // Sürücüye Karargahın gücünü hissettirmek için 1.5 saniyelik tarama süresi
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    try {
      // Firebase'den "genel_ayarlar" altındaki hologram verisini çek
      DocumentSnapshot ayarlar = await _db.collection('sistem_ayarlari').doc('genel_ayarlar').get();

      bool hologramGosterilsinMi = false;
      String baslik = "";
      String mesaj = "";

      if (ayarlar.exists) {
        var data = ayarlar.data() as Map<String, dynamic>;
        hologramGosterilsinMi = data['hologram_aktif'] ?? false;
        baslik = data['hologram_baslik'] ?? "OTODNA BİLDİRİMİ";
        mesaj = data['hologram_mesaj'] ?? "";
      }

      if (hologramGosterilsinMi && mesaj.isNotEmpty) {
        _hologramGoster(baslik, mesaj);
      } else {
        _anaKapiyaGecisYap();
      }

    } catch (e) {
      // Herhangi bir ağ hatasında sistem kilitlenmez, güvenli kapıya geçer
      _anaKapiyaGecisYap();
    }
  }

  void _anaKapiyaGecisYap() {
    if (!mounted) return;
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OtoDnaAuthGate())
    );
  }

  // --- 🎇 BAYRAM/DUYURU HOLOGRAMI EKRANI (Glassmorphism) ---
  void _hologramGoster(String baslik, String mesaj) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: SiberTema.oledBlack.withOpacity(0.85),
                    border: Border.all(color: SiberTema.altinSari.withOpacity(0.5), width: 2),
                    boxShadow: [
                      BoxShadow(color: SiberTema.altinSari.withOpacity(0.1), blurRadius: 40, spreadRadius: 10)
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.celebration_rounded, color: SiberTema.altinSari, size: 50),
                      const SizedBox(height: 24),
                      Text(
                        baslik.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: SiberTema.altinSari, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Divider(color: SiberTema.textMuted, height: 1),
                      ),
                      Text(
                        mesaj,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: SiberTema.textMain, fontSize: 14, height: 1.5, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: SiberTema.kuantumButonStili().copyWith(
                            backgroundColor: WidgetStateProperty.all(SiberTema.altinSari),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _anaKapiyaGecisYap();
                          },
                          child: const Text("KARARGAHA GEÇ", style: TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.w900)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SiberTema.oledBlack,
      body: Container(
        decoration: SiberTema.siberArkaPlan,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: const Icon(Icons.security, color: SiberTema.kuantumCyan, size: 100),
                  );
                },
              ),
              const SizedBox(height: 40),
              const Text(
                "OTODNA KARARGAHI ÇEVRİMİÇİ",
                style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 3),
              ),
              const SizedBox(height: 12),
              Text(
                "Siber Kalkanlar Aktif, Emir Bekleniyor...",
                style: TextStyle(color: SiberTema.textMain.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 60),
              const CircularProgressIndicator(color: SiberTema.kuantumCyan, strokeWidth: 3),
            ],
          ),
        ),
      ),
    );
  }
}