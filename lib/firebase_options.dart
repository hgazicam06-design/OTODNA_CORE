// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// 🛡️ KUANTUM BAĞLANTI ANAHTARLARI
/// SİBER NOT: Gerçek anahtarları Firebase Console üzerinden alıp buraya yerleştirin.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Bu platform Karargah ağını desteklemiyor.');
    }
  }

  static FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSy_GECICI_SİBER_ANAHTAR_123456",
    appId: "1:605026201993:web:7218ad6403197ec839f158",
    messagingSenderId: "605026201993",
    projectId: "otodna-c3747",
    authDomain: "otodna-c3747.firebaseapp.com",
    storageBucket: "otodna-c3747.appspot.com",
  );

  static FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSy_GECICI_ANDROID_ANAHTARI_7890",
    appId: "1:605026201993:android:farkli_id_buraya",
    messagingSenderId: "605026201993",
    projectId: "otodna-c3747",
    storageBucket: "otodna-c3747.appspot.com",
  );

  static FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSy_GECICI_IOS_ANAHTARI_5555",
    appId: "1:605026201993:ios:farkli_id_buraya",
    messagingSenderId: "605026201993",
    projectId: "otodna-c3747",
    storageBucket: "otodna-c3747.appspot.com",
    iosBundleId: "com.otodna.app",
  );
}