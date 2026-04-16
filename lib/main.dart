// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

// 🚀 KARARGAH BİLEŞENLERİ
import 'core/siber_tema.dart';
import 'core/app_router.dart';
import 'auth/otodna_auth_gate.dart';
import 'firebase_options.dart';

void main() async {
  // 🛡️ SİBER ÇEKİRDEK BAŞLATILIYOR
  WidgetsFlutterBinding.ensureInitialized();

  // 📡 EKRAN DİSİPLİNİ: Dikey mod kilidi
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 🔥 FIREBASE KUANTUM MOTORUNU ATEŞLE
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("✅ SİBER ONAY: Firebase Kuantum Ağına bağlantı sağlandı.");
  } catch (e) {
    debugPrint("🚨 BAĞLANTI İHLALİ: Firebase başlatılamadı -> $e");
  }

  // ProviderScope ile tüm uygulamayı siber ağa bağlıyoruz
  runApp(
    const ProviderScope(
      child: OtoDNA(),
    ),
  );
}

class OtoDNA extends StatelessWidget {
  const OtoDNA({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OtoDNA Kuantum Ağı',
      debugShowCheckedModeBanner: false,

      // 🚀 YÖNLENDİRME MERKEZİ (ROUTER)
      initialRoute: '/',
      onGenerateRoute: KuantumRota.atesle,

      // 🎨 SİBER TEMA ENJEKSİYONU (OLED ve Kuantum Renkleri)
      theme: SiberTema.kuantumTemasi(), // Merkezi tema motorundan çekilir

      // 🛡️ SİBER KAPI (ROUTER TARAFINDAN YÖNETİLİYOR)
      // initialRoute '/' üzerinden AuthGate tetiklenir.
    );
  }
}