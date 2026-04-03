import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🚀 DOĞRU ROTALAR (Gerçek dosya yolları)
import 'package:otodna/screens/auth/siber_giris_screen.dart'; // Giriş ekranı
import 'package:otodna/admin/admin_control_center.dart'; // Gerçek Admin dosyanızın yolu

class OtoDnaAuthGate extends StatelessWidget {
  const OtoDnaAuthGate({super.key});

  static const Color _oledBlack = Color(0xFF000000);
  static const Color _kanKirmizi = Colors.redAccent;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {

        // 1. AŞAMA: Firebase bağlantısı beklenirken Tesla Yükleme Ekranı
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _TeslaYuklemeEkrani(mesaj: "SİBER PROTOKOLLER TARANIYOR...");
        }

        // 2. AŞAMA: Kullanıcı giriş yapmamışsa anında Login'e at
        if (!authSnapshot.hasData || authSnapshot.data == null) {
          return const SiberGirisScreen();
        }

        final User currentUser = authSnapshot.data!;

        // 3. AŞAMA: Kullanıcı Firebase'de var, şimdi Rolünü kontrol et
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('kullanicilar').doc(currentUser.uid).get(),
          builder: (context, userSnapshot) {

            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const _TeslaYuklemeEkrani(mesaj: "KARARGAH YETKİLERİ DOĞRULANIYOR...");
            }

            // Hata varsa veya adam veritabanından silinmişse
            if (userSnapshot.hasError || !userSnapshot.hasData || !userSnapshot.data!.exists) {
              return _buildSiberHataEkrani("SİCİL BULUNAMADI - AĞDAN ÇIK");
            }

            var userData = userSnapshot.data!.data() as Map<String, dynamic>;

            // 🔥 ROL VE KARALİSTE MÜHRÜNÜ OKU
            String role = (userData['rol'] ?? "USER").toString().toUpperCase();
            bool isBlacklisted = userData['isBlacklisted'] ?? userData['kara_liste'] ?? false;

            if (isBlacklisted) {
              return _buildSiberHataEkrani("KARALİSTE: ZORUNLU ÇIKIŞ YAP");
            }

            // 🚀 GÜVENLİK GEÇİLDİ -> İLGİLİ EKRANA FIRLAT!
            // SİBER NOT: Şu an bayi_paneli.dart olmadığı için çökmesin diye herkesi Admin Paneline atıyoruz.
            // İleride o ekranları kodladığımızda buradaki rotaları ayıracağız.
            if (role == "ADMIN") {
              return const AdminControlCenter();
            } else if (role == "BAYI" || role == "USTA") {
              return const AdminControlCenter(); // TODO: Bayi Paneli yapılınca değiştir
            } else {
              return const AdminControlCenter(); // TODO: Kullanıcı Kokpiti yapılınca değiştir
            }
          },
        );
      },
    );
  }

  // --- SİBER HATA ZIRHI ---
  Widget _buildSiberHataEkrani(String butonMetni) {
    return Scaffold(
      backgroundColor: _oledBlack,
      body: Center(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: _kanKirmizi,
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

// --- 🌑 TESLA MİMARİSİ: GÖRSEL YÜKLEME MOTORU ---
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
    const Color primaryCyan = Color(0xFF00FFC2);
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
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
                        color: primaryCyan.withOpacity(0.05),
                        border: Border.all(color: primaryCyan.withOpacity(0.5), width: 2),
                        boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.2), blurRadius: 40, spreadRadius: 10)],
                      ),
                      child: const Icon(Icons.fingerprint, size: 80, color: primaryCyan),
                    ),
                    const SizedBox(height: 48),
                    const Text('OTODNA', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 8.0)),
                    const SizedBox(height: 12),
                    const Text('DİJİTAL REFERANS PROTOKOLÜ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: primaryCyan, letterSpacing: 2.0)),
                    const SizedBox(height: 64),
                    const CircularProgressIndicator(color: primaryCyan, strokeWidth: 2),
                    const SizedBox(height: 24),
                    Text(widget.mesaj, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2))
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