import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Firebase otonom yapılandırma dosyası

// 🔥 SİBER KÖPRÜLER VE TEMA (Zırh v2.0)
import 'core/siber_tema.dart';

// 🚀 AUTH VE GİRİŞ EKRANLARI (Tüm kablolar buraya çekildi)
import 'auth/siber_baslangic_screen.dart';
import 'auth/otodna_auth_gate.dart';
import 'auth/login_screen.dart';
import 'auth/siber_kayit_screen.dart';
import 'auth/sifre_sifirla_screen.dart';
import 'auth/siber_sms_screen.dart';

void main() async {
  // 1. Flutter Motorunu Emniyete Al
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Kuantum Firebase Ağını Ateşle
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Karargahı Başlat
  runApp(const OtoDnaApp());
}

class OtoDnaApp extends StatelessWidget {
  const OtoDnaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OtoDNA Karargahı',
      debugShowCheckedModeBanner: false, // Sağ üstteki "Debug" kırmızı bandını yokedip atar

      // 💎 3D KUANTUM ZIRHI BURADAN TÜM UYGULAMAYA DAĞILIR!
      theme: SiberTema.tema,

      // 🚀 İLK AÇILIŞ EKRANI (SPLASH & HOLOGRAM ŞOVU)
      home: const SiberBaslangicScreen(),

      // 🧠 SİBER ROTALAR (Uygulama içi ışınlanma koordinatları)
      routes: {
        // '/home' rotası direkt AuthGate'e atar. AuthGate kişinin rütbesine bakıp
        // Admin, Bayi veya Kullanıcı Paneline otonom olarak fırlatır!
        '/home': (context) => const OtoDnaAuthGate(),

        '/login': (context) => const LoginScreen(),
        '/kayit_ol': (context) => const SiberKayitScreen(),
        '/sifre_sifirlama': (context) => const SifreSifirlaScreen(),
        '/sms_dogrulama': (context) => const SiberSmsScreen(),
      },
    );
  }
}