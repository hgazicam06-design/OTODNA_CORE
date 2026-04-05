import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🔥 SİBER KÖPRÜLER VE TEMA (Zırh v2.0)
import '../core/siber_tema.dart';
import 'otodna_auth_gate.dart';

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

    // Kalkan için Kuantum Nefes Animasyonu
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    // Siber Yönlendirme Motorunu Ateşle (Önce Hologram Kontrolü)
    _kuantumHologramKontrolu();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // --- 🎆 HOLOGRAM VE KAPI KONTROL MOTORU ---
  Future<void> _kuantumHologramKontrolu() async {
    // Sürücüye Karargahın gücünü hissettirmek için en az 1.5 saniye bekle
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    try {
      // Admin Panelinden ayarlanan Hologram verisini çek
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

      // Eğer Admin şalteri açmışsa Hologramı (Pop-up) fırlat
      if (hologramGosterilsinMi && mesaj.isNotEmpty) {
        _hologramGoster(baslik, mesaj);
      } else {
        // Şalter kapalıysa direkt Ana Kapıya geç
        _anaKapiyaGecisYap();
      }

    } catch (e) {
      // İnternet yoksa veya ağ çöktüyse takılma, Ana Kapıya geç
      _anaKapiyaGecisYap();
    }
  }

  // 🚀 ASIL KAPIYA GEÇİŞ (OtoDnaAuthGate)
  void _anaKapiyaGecisYap() {
    if (!mounted) return;
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OtoDnaAuthGate())
    );
  }

  // --- 🎇 BAYRAM/DUYURU HOLOGRAMI EKRANI (Glassmorphism & 3D Netlik) ---
  void _hologramGoster(String baslik, String mesaj) {
    showDialog(
        context: context,
        barrierDismissible: false, // Ekrana basıp geçemez, mecbur okuyacak!
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
                    // 💎 3D Derinlik Gölgesi
                    boxShadow: SiberTema.siberGolgeDerin.map((s) => s.copyWith(color: SiberTema.altinSari.withOpacity(0.1))).toList(),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 🎆 3D Hisli Kutlama İkonu
                      Icon(Icons.celebration_rounded, color: SiberTema.altinSari, size: 50, shadows: [Shadow(color: SiberTema.altinSari.withOpacity(0.8), blurRadius: 10)]),
                      const SizedBox(height: 24),
                      Text(
                        baslik.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: SiberTema.altinSari, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: SiberTema.siberFont),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Divider(color: Colors.white24, height: 1),
                      ),
                      Text(
                        mesaj,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, height: 1.5, fontFamily: SiberTema.siberFont, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          // 🔘 Merkezi Buton Stili (3D)
                          style: SiberTema.kuantumButonStili().copyWith(backgroundColor: MaterialStateProperty.all(SiberTema.altinSari)),
                          onPressed: () {
                            Navigator.pop(context); // Pop-up'ı kapat
                            _anaKapiyaGecisYap(); // Karargaha gir
                          },
                          icon: const Icon(Icons.check_circle_outline, size: 20, color: SiberTema.oledBlack),
                          label: const Text("KARARGAHA GEÇ", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: SiberTema.siberFont, color: SiberTema.oledBlack)),
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
      backgroundColor: Colors.transparent, // Arka planı container'a bırak
      body: Container(
        decoration: SiberTema.siberArkaPlan, // 🔥 YENİ 3D ARKA PLAN
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🛡️ NEFES ALAN 3D SİBER KALKAN
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 80,
                      height: 90,
                      decoration: BoxDecoration(
                        // 💎 3D Derinlik Gölgesi
                        boxShadow: SiberTema.siberGolgeDerin,
                      ),
                      // 🛡️ Hafif parlayan 3D kalkan ikonu
                      child: const Icon(Icons.security, color: SiberTema.kuantumCyan, size: 80, shadows: [Shadow(color: SiberTema.kuantumCyan, blurRadius: 10)]),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),

              // KARARGAH METİNLERİ
              const Text(
                "OTODNA KARARGAHI ÇEVRİMİÇİ",
                style: TextStyle(
                  color: SiberTema.kuantumCyan,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                  fontFamily: SiberTema.siberFont,
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
                  fontFamily: SiberTema.siberFont,
                ),
              ),

              const SizedBox(height: 60),

              // YÜKLENİYOR RADARI
              const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  color: SiberTema.kuantumCyan,
                  strokeWidth: 3, // Biraz daha kalın, net
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}