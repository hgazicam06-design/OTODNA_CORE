import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 🛰️ KUANTUM VERİ AĞI
import 'core/siber_tema.dart';
import 'auth/otodna_auth_gate.dart';

void main() async {
  // 🛡️ SİBER ÇEKİRDEK BAŞLATILIYOR
  WidgetsFlutterBinding.ensureInitialized();

  // 🚀 FIREBASE KUANTUM MOTORUNU ATEŞLE
  await Firebase.initializeApp();

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

      // 🎨 SİBER TEMA ENJEKSİYONU
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: SiberTema.oledBlack,
        primaryColor: SiberTema.kuantumCyan,
        fontFamily: 'Avenir', // Kurumsal Karargah Fontu

        // Kaydırma efektlerini siber akıcılığa uyarla
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      // 🛡️ SİBER KAPI (OTODNA AUTH GATE)
      // Bu kapı artık siber_kimlik_provider üzerinden yetki kontrolü yapacak.
      home: const OtoDnaAuthGate(),
    );
  }
}