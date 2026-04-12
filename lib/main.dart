import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 🛰️ KUANTUM VERİ AĞI

import 'core/siber_tema.dart';
import 'core/app_router.dart'; // 🚀 Kuantum Rota Merkezi Eklendi
import 'auth/otodna_auth_gate.dart';
import 'firebase_options.dart'; // 🔥 FİREBASE YAPILANDIRMASI

void main() async {
  // 🛡️ SİBER ÇEKİRDEK BAŞLATILIYOR
  WidgetsFlutterBinding.ensureInitialized();

  // 🚀 FIREBASE KUANTUM MOTORUNU ATEŞLE
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Riverpod ProviderScope ile tüm uygulamayı siber ağa bağlıyoruz
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
      theme: ThemeData(
        useMaterial3: true, // 🛠️ Yeni nesil siber arayüz motoru
        brightness: Brightness.dark,
        scaffoldBackgroundColor: SiberTema.oledBlack,
        colorScheme: ColorScheme.fromSeed(
          seedColor: SiberTema.kuantumCyan,
          brightness: Brightness.dark,
          surface: SiberTema.matGrey,
          primary: SiberTema.kuantumCyan,
        ),
        fontFamily: 'Avenir', // Kurumsal Karargah Fontu

        visualDensity: VisualDensity.adaptivePlatformDensity,

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
      ),

      // 🛡️ SİBER KAPI (ROUTER TARAFINDAN YÖNETİLİYOR, '/' ROTASI)
      home: const OtoDnaAuthGate(),
    );
  }
}