import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🚀 SİBER KÖPRÜLER VE TEMA
import '../core/siber_tema.dart'; // ✅ Merkezi Renkler ve Zırh
import '../core/responsive_kalkan.dart'; // ✅ Tüm Ekranlara Uyum

import 'login_screen.dart';
import '../admin/admin_control_center.dart';
import '../screens/bayi_paneli.dart';
import '../screens/kullanici_paneli_screen.dart';

class OtoDnaAuthGate extends StatelessWidget {
  const OtoDnaAuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const _TeslaYuklemeEkrani(mesaj: "SİBER PROTOKOLLER TARANIYOR...");
          }

          // Eğer kullanıcı hiç giriş yapmamışsa Login (Giriş) ekranına fırlat!
          if (!authSnapshot.hasData || authSnapshot.data == null) {
            return const LoginScreen();
          }

          final User currentUser = authSnapshot.data!;

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('kullanicilar').doc(currentUser.uid).get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const _TeslaYuklemeEkrani(mesaj: "KARARGAH YETKİLERİ DOĞRULANIYOR...");
              }

              if (userSnapshot.hasError || !userSnapshot.hasData || !userSnapshot.data!.exists) {
                return _buildSiberHataEkrani("SİCİL BULUNAMADI - AĞDAN ÇIK");
              }

              var userData = userSnapshot.data!.data() as Map<String, dynamic>;

              String role = (userData['rol'] ?? "USER").toString().toUpperCase();
              bool isBlacklisted = userData['is_blacklisted'] ?? userData['kara_liste'] ?? false;

              if (isBlacklisted) {
                return _buildSiberHataEkrani("KARALİSTE: ZORUNLU ÇIKIŞ YAP");
              }

              // 🧠 KUANTUM YÖNLENDİRME MERKEZİ
              if (role == "ADMIN" || role == "BOLGE_KOMUTANI") {
                return const AdminControlCenter();
              } else if (role == "BAYI" || role == "USTA") {
                return BayiPaneliScreen(bayiId: currentUser.uid);
              } else {
                return const KullaniciPaneliScreen();
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildSiberHataEkrani(String butonMetni) {
    return Scaffold(
      backgroundColor: SiberTema.oledBlack,
      body: Center(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: SiberTema.kanKirmizi,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          onPressed: () => FirebaseAuth.instance.signOut(),
          icon: const Icon(Icons.warning_amber_rounded),
          label: Text(butonMetni, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// 🌑 TESLA MİMARİSİ: OLED SİYAHI VE KUANTUM YÜKLEME EKRANI
// -------------------------------------------------------------
class _TeslaYuklemeEkrani extends StatefulWidget {
  final String mesaj;
  const _TeslaYuklemeEkrani({required this.mesaj});
  @override
  State<_TeslaYuklemeEkrani> createState() => _TeslaYuklemeEkraniState();
}

class _TeslaYuklemeEkraniState extends State<_TeslaYuklemeEkrani> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this)..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _opacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SiberTema.oledBlack,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: SiberTema.kuantumCyan.withOpacity(0.05),
                            border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5), width: 2),
                            boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.2), blurRadius: 40, spreadRadius: 10)]
                        ),
                        child: const Icon(Icons.fingerprint, size: 80, color: SiberTema.kuantumCyan)
                    ),
                    const SizedBox(height: 48),
                    const Text('OTODNA', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 8.0, fontFamily: 'Avenir')),
                    const SizedBox(height: 12),
                    const Text('DİJİTAL REFERANS PROTOKOLÜ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: SiberTema.kuantumCyan, letterSpacing: 2.0, fontFamily: 'Avenir')),
                    const SizedBox(height: 64),
                    const CircularProgressIndicator(color: SiberTema.kuantumCyan, strokeWidth: 2),
                    const SizedBox(height: 24),
                    Text(widget.mesaj, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2, fontFamily: 'Avenir'))
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}