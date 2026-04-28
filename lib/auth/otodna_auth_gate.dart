import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// 🚀 SİBER KÖPRÜLER VE TEMA
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';
import '../core/providers/siber_kimlik_provider.dart';
import '../core/main_engine.dart';

// 🚀 EKRANLAR (YENİ KARARGAH MİMARİSİNE GÖRE)
import '../screens/login_screen.dart';
import '../screens/super_admin_screen.dart';
import '../screens/usta_panel_screen.dart';
import '../screens/home_screen.dart';
import '../bayi/bayi_merkez.dart';
import '../bayi/belge_dogrulama.dart';
import '../screens/auth/kvkk_onay_screen.dart'; // YASAL ZIRH

/// 🛡️ KUANTUM GİRİŞ KAPISI VE RÜTBE YÖNLENDİRİCİSİ (RIVERPOD DESTEKLİ)
class OtoDnaAuthGate extends ConsumerWidget {
  const OtoDnaAuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 📡 1. FİREBASE KİMLİK RADARINI DİNLE
    final authState = ref.watch(authDurumProvider);

    return ResponsiveKalkan(
      isOledBackground: true,
      child: authState.when(
        loading: () => const _KuantumYuklemeEkrani(mesaj: "SİBER PROTOKOLLER TARANIYOR..."),
        error: (error, stack) => _KuantumYuklemeEkrani(mesaj: "SİBER İHLAL: $error"),
        data: (user) {
          // Eğer kullanıcı hiç giriş yapmamışsa Zırhlı LoginScreen'e fırlat!
          if (user == null) {
            return const LoginScreen();
          }

          // 🛡️ 2. KARARGAH SİCİL MOTORUNU DİNLE
          final sicilState = ref.watch(siberSicilProvider);

          return sicilState.when(
            loading: () => const _KuantumYuklemeEkrani(mesaj: "KARARGAH YETKİLERİ DOĞRULANIYOR..."),
            error: (error, stack) => _KuantumYuklemeEkrani(mesaj: "SİCİL HATASI: $error"),
            data: (userData) {
              if (userData == null) {
                // 🛡️ OTONOM SİCİL İNŞASI: Auth var ama Firestore verisi yoksa, sistemi onar!
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  FirebaseFirestore.instance.collection('kullanicilar').doc(user.uid).set({
                    'email': user.email ?? 'isimsiz_ajan@otodna.com',
                    'rol': 'USER',
                    'kayit_tarihi': FieldValue.serverTimestamp(),
                  });
                });
                return const _KuantumYuklemeEkrani(mesaj: "SİCİL OTONOM OLARAK İNŞA EDİLİYOR...");
              }

              // 🛡️ BLACK STAR PROTOKOLÜ: Kullanıcı Karalistede mi?
              bool isBlacklisted = userData['is_blacklisted'] ?? false;
              if (isBlacklisted) {
                return const _KaraListeEkrani();
              }

              // 📡 FCM TOKEN MÜHÜRLEME (Kullanıcı giriş yaptığında token güncellenir)
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                try {
                  String? token = await FirebaseMessaging.instance.getToken();
                  if (token != null && userData['fcmToken'] != token) {
                    await FirebaseFirestore.instance.collection('kullanicilar').doc(user.uid).update({'fcmToken': token});
                  }

                  // 🚀 MOTOR ATEŞLEME (SADECE ADMİNLER İÇİN)
                  String userRole = (userData['rol'] ?? userData['rutbe'] ?? "USER").toString().toUpperCase();
                  if (userRole == "ADMIN" || userRole == "BOLGE_KOMUTANI" || userRole == "SUPER_ADMIN" || userRole == "BASKAN") {
                    SiberAnaMotor.sistemiBaslat(user.uid);
                  }
                } catch (e) {
                  // İzin verilmediyse sessizce geç
                }
              });

              // Rol veya Rutbe değişkenlerini destekler (Geriye dönük uyumluluk)
              String role = (userData['rol'] ?? userData['rutbe'] ?? "USER").toString().toUpperCase();

              // 🛡️ YASAL ZIRH: KVKK Onay Kontrolü (Hukuk Kalkanı)
              bool kvkkOnayli = userData['kvkk_onay'] ?? false;
              if (!kvkkOnayli) {
                return const KvkkOnayScreen(hedefRota: '/home'); 
              }

              // 🧠 KUANTUM YÖNLENDİRME MERKEZİ (Özgür Kullanım Protokolü)
              if (role == "ADMIN" || role == "BOLGE_KOMUTANI" || role == "SUPER_ADMIN" || role == "BASKAN") {
                return const SuperAdminScreen();
              } else if (role == "BAYI") {
                // 🛡️ SİBER ZIRH: Bayi belgelerini Karargaha mühürledi mi?
                bool belgelerYuklendi = userData['belgeler_yuklendi'] ?? false;
                if (!belgelerYuklendi) {
                  return BelgeDogrulama(bayiId: user.uid);
                } else {
                  return BayiMerkezi(bayiId: user.uid);
                }
              } else if (role == "USTA") {
                return const UstaPanelScreen();
              } else {
                return const HomeScreen();
              }
            },
          );
        },
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

// -------------------------------------------------------------
// 🚨 BLACK STAR PROTOKOLÜ (KARALİSTE / SİBER ENGEL)
// -------------------------------------------------------------
class _KaraListeEkrani extends StatelessWidget {
  const _KaraListeEkrani();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SiberTema.oledBlack,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: SiberTema.kanKirmizi, width: 2),
                  boxShadow: [BoxShadow(color: SiberTema.kanKirmizi.withOpacity(0.2), blurRadius: 40, spreadRadius: 10)],
                ),
                child: const Icon(Icons.block, size: 70, color: SiberTema.kanKirmizi),
              ),
              const SizedBox(height: 40),
              const Text(
                'SİSTEM ERİŞİMİ REDDEDİLDİ',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: SiberTema.kanKirmizi, fontFamily: 'Avenir', letterSpacing: 2.0),
              ),
              const SizedBox(height: 16),
              const Text(
                'Siber Sicilinizde tespit edilen ihlaller nedeniyle Kuantum Ağına erişiminiz kalıcı olarak engellenmiştir. (BLACK STAR MÜHRÜ)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70, fontFamily: 'Avenir', height: 1.5),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: SiberTema.kanKirmizi.withOpacity(0.1),
                  foregroundColor: SiberTema.kanKirmizi,
                  side: const BorderSide(color: SiberTema.kanKirmizi),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => FirebaseAuth.instance.signOut(),
                icon: const Icon(Icons.power_settings_new),
                label: const Text("BAĞLANTIYI KES", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
              )
            ],
          ),
        ),
      ),
    );
  }
}