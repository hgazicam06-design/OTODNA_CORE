import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Siber yetki kontrolü doğrudan auth_gate içinde yapılıyor

// 🚀 KARARGAH ZIRHLARI VE TEMASI
import 'package:otodna/core/siber_tema.dart';

// 🔥 SİBER KAPININ (AUTH GATE) GERÇEK BAĞLANTISI
import 'package:otodna/screens/auth/otodna_auth_gate.dart';

void main() async {
  // 1. SİBER MOTORLARI HAZIRLA
  WidgetsFlutterBinding.ensureInitialized();

  // 2. FIREBASE KUANTUM AĞINA CANLI BAĞLANTI (Maket yok, %100 Gerçek Veri!)
  // Not: Mevcut google-services.json mimarisi için bu ateşleme kodu kusursuzdur.
  await Firebase.initializeApp();

  // 3. KARARGAHI ATEŞLE
  runApp(const OtoDNAKarargah());
}

class OtoDNAKarargah extends StatelessWidget {
  const OtoDNAKarargah({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OtoDNA Kuantum Ağı',
      debugShowCheckedModeBanner: false,
      theme: SiberTema.tema, // Kuantum Turkuazı ve Derin Siyah zırhımız

      // 🔥 İŞTE SİBER KİLİDİ AÇAN KOD:
      // Sabit ve cansız maket ekran tamamen imha edildi.
      // Sistem artık doğrudan Firebase kimlik doğrulama radarına (OtoDnaAuthGate) bağlanıyor!
      home: const OtoDnaAuthGate(),
    );
  }
}