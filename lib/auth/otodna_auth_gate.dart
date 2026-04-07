import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🚀 SİBER KÖPRÜLER VE TEMA
import '../core/siber_tema.dart'; // ✅ Merkezi Renkler ve Zırh
import '../core/responsive_kalkan.dart'; // ✅ Tüm Ekranlara Uyum

// ✅ YENİ ZIRHLI GİRİŞ EKRANIMIZA (LoginScreen) BAĞLANTI:
import '../screens/login_screen.dart';
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
            return const _KuantumYuklemeEkrani(mesaj: "SİBER PROTOKOLLER TARANIYOR...");
          }

          // Eğer kullanıcı hiç giriş yapmamışsa YENİ zırhlı LoginScreen'e fırlat!
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

              // Kullanıcı Firebase Auth'ta var ama Firestore 'kullanicilar' koleksiyonunda kaydı yoksa
              if (userSnapshot.hasError || !userSnapshot.hasData || !userSnapshot.data!.exists) {
                return _buildSiberHataEkrani("SİCİL BULUNAMADI - AĞDAN ÇIK");
              }

              var userData = userSnapshot.data!.data() as Map<String, dynamic>;

              String role = (userData['rol'] ?? "USER").toString().toUpperCase();
              bool isBlacklisted = userData['is_blacklisted'] ?? userData['kara_liste'] ?? false;

              if (isBlacklisted) {
                return _buildSiberHataEkrani("KARALİSTE (BLACK STAR): ZORUNLU ÇIKIŞ YAP");
              }

              // 🧠 KUANTUM YÖNLENDİRME MERKEZİ (%12 Kuralının Temeli Burada Atılıyor)
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
      backgroundColor: SiberTema.oledBlack, // True Black Zemin
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
          label: Text(butonMetni, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
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
      backgroundColor: SiberTema.oledBlack, // Saf Siyah Zemin
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Aşırı animasyonlu parmak izi yerine kurumsal, ağırbaşlı logo alanı
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3), width: 1.5),
                boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.1), blurRadius: 20, spreadRadius: 5)],
              ),
              child: const Icon(Icons.shield_outlined, size: 56, color: SiberTema.kuantumCyan), // Güvenlik Kalkanı
            ),
            const SizedBox(height: 40),

            // Kurumsal Font ve Hitap
            const Text(
              'OtoDNA',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 4.0),
            ),
            const SizedBox(height: 8),
            const Text(
              'SİBER KARARGAH BAĞLANTISI',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: SiberTema.kuantumCyan, letterSpacing: 3.0),
            ),

            const SizedBox(height: 64),

            // Minimalist Yükleme Göstergesi
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(color: SiberTema.kuantumCyan, strokeWidth: 2.5),
            ),
            const SizedBox(height: 24),

            // Durum Mesajı
            Text(
              mesaj,
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            )
          ],
        ),
      ),
    );
  }
}