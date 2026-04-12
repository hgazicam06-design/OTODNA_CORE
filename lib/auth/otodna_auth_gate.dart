import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🚀 SİBER KÖPRÜLER VE TEMA
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

// 🚀 EKRANLAR
import '../screens/login_screen.dart';
import '../admin/super_admin_screen.dart'; // Super Admin modülüne yönlendirildi
import '../screens/usta_panel_screen.dart'; // Bayi/Usta Paneline yönlendirildi
import '../screens/siber_kokpit_screen.dart'; // Standart Kullanıcı Kokpitine yönlendirildi

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
            return const _KuantumYuklemeEkrani(mesaj: "SİBER PROTOKOLLER TARANIYOR...");
          }

          // Eğer kullanıcı hiç giriş yapmamışsa Zırhlı LoginScreen'e fırlat!
          if (!authSnapshot.hasData || authSnapshot.data == null) {
            return const LoginScreen();
          }

          final User currentUser = authSnapshot.data!;

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('kullanicilar').doc(currentUser.uid).get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const _KuantumYuklemeEkrani(mesaj: "KARARGAH YETKİLERİ DOĞRULANIYOR...");
              }

              // Kullanıcı Firebase Auth'ta var ama Firestore'da kaydı yoksa
              if (userSnapshot.hasError || !userSnapshot.hasData || !userSnapshot.data!.exists) {
                return _buildSiberHataEkrani("SİCİL BULUNAMADI - AĞDAN ÇIK");
              }

              var userData = userSnapshot.data!.data() as Map<String, dynamic>;

              String role = (userData['rol'] ?? "USER").toString().toUpperCase();
              bool isBlacklisted = userData['is_blacklisted'] ?? userData['kara_liste'] ?? false;

              if (isBlacklisted) {
                return _buildSiberHataEkrani("KARALİSTE (BLACK STAR): ZORUNLU ÇIKIŞ YAP");
              }

              // 🧠 KUANTUM YÖNLENDİRME MERKEZİ
              if (role == "ADMIN" || role == "BOLGE_KOMUTANI" || role == "SUPER_ADMIN") {
                return const SuperAdminScreen();
              } else if (role == "BAYI" || role == "USTA") {
                return const UstaPanelScreen();
              } else {
                return const SiberKokpitScreen();
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => FirebaseAuth.instance.signOut(),
          icon: const Icon(Icons.warning_amber_rounded),
          label: Text(butonMetni, style: const TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 1)),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// 🌑 YENİ KURUMSAL MİMARİ: V.I.P. KUANTUM YÜKLEME EKRANI
// -------------------------------------------------------------
class _KuantumYuklemeEkrani extends StatelessWidget {
  final String mesaj;
  const _KuantumYuklemeEkrani({required this.mesaj});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SiberTema.oledBlack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3), width: 1.5),
                boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.1), blurRadius: 20, spreadRadius: 5)],
              ),
              child: const Icon(Icons.shield_outlined, size: 56, color: SiberTema.kuantumCyan),
            ),
            const SizedBox(height: 40),

            const Text(
              'OtoDNA',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Avenir', letterSpacing: 4.0),
            ),
            const SizedBox(height: 8),
            const Text(
              'SİBER KARARGAH BAĞLANTISI',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: SiberTema.kuantumCyan, fontFamily: 'Avenir', letterSpacing: 3.0),
            ),

            const SizedBox(height: 64),

            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(color: SiberTema.kuantumCyan, strokeWidth: 2.5),
            ),
            const SizedBox(height: 24),

            Text(
              mesaj,
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Avenir', letterSpacing: 1.5),
            )
          ],
        ),
      ),
    );
  }
}