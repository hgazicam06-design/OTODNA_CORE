import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🚀 ROTALAR: İleride gideceğimiz hedeflerin importları (Kendi dosya yollarına göre açarsın)
// import 'auth_login_screen.dart'; // Giriş yapılmamışsa gideceği yer
// import 'siber_kokpit_screen.dart'; // Normal kullanıcı ise gideceği yer
// import 'kara_kutu_screen.dart'; // ADMİN ise gideceği Kara Kutu

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

  // --- 🔴 FİREBASE: ROL BAZLI SİBER YÖNLENDİRME MOTORU ---
  Future<void> _kuantumKapilariniAc() async {
    // Sürücüye Karargahın gücünü hissettirmek için 2 saniye bekle
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // 1. İHTİMAL: ASKER KAYITLI DEĞİL (LOGIN EKRANINA GÖNDER)
      debugPrint("SİBER UYARI: Kimlik bulunamadı, giriş kapısına yönlendiriliyor.");
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthLoginScreen()));
    } else {
      // 2. İHTİMAL: ASKER İÇERİDE, RÜTBESİNİ KONTROL ET
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('kullanicilar').doc(currentUser.uid).get();

        if (doc.exists && doc.data() != null) {
          String role = (doc.data() as Map<String, dynamic>)['role'] ?? 'user';

          if (role == 'admin') {
            debugPrint("KARARGAH KOMUTANI GİRİŞ YAPTI! Kara Kutuya yönlendiriliyor...");
            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const KaraKutuScreen()));
          } else {
            debugPrint("BİRLİK ONAYLANDI. Kullanıcı kokpitine yönlendiriliyor...");
            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SiberKokpitScreen()));
          }
        } else {
          // Kullanıcı belgesi yoksa varsayılan olarak sivil kokpite gönder
          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SiberKokpitScreen()));
        }
      } catch (e) {
        debugPrint("SİBER AĞ HATASI: Rütbe okunamadı. $e");
        // Hata durumunda güvenli liman olarak giriş ekranına atabilirsin
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505), // Derin Karargah Siyahı
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
                        BoxShadow(color: const Color(0xFF00F0FF).withOpacity(0.5), blurRadius: 40, spreadRadius: 10)
                      ],
                    ),
                    child: const Icon(Icons.security, color: Color(0xFF00F0FF), size: 80),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),

            // KARARGAH METİNLERİ
            const Text(
              "OTODNA KARARGAHI ÇEVRİMİÇİ",
              style: TextStyle(
                color: Color(0xFF00F0FF), // Kuantum Turkuazı
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                fontFamily: 'Avenir', // Siber font
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
                color: Color(0xFF00F0FF),
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}