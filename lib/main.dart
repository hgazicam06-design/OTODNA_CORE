// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:seo/seo.dart'; // 🚀 SİBER SEO KÜTÜPHANESİ

// 🚀 KARARGAH BİLEŞENLERİ
import 'core/siber_tema.dart';
import 'core/routing/siber_router.dart';
import 'firebase_options.dart'; // Bu dosyanın Firebase CLI ile oluşturulmuş olması gerekir

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
    
    // 🦇 YERALTI RADARI: Çevrimdışı Bellek (Offline Persistence) Aktif Ediliyor
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
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
    return SeoController(
      enabled: true,
      tree: WidgetTree(context: context),
      child: MaterialApp(
        title: 'OtoDNA Kuantum Ağı',
        debugShowCheckedModeBanner: false,

        // 🚀 YÖNLENDİRME MERKEZİ (GO_ROUTER ZIRHI)
        routerConfig: SiberRouter.router,

        // 🎨 SİBER TEMA ENJEKSİYONU (OLED ve Kuantum Renkleri)
        theme: SiberTema.kuantumTemasi(),
      ),
    );
  }
}