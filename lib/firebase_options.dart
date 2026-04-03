import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => web;
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCytgYszMPX1EQs_oCVt8f_ze9_xPOBCXI",
    appId: '1:605026201993:web:7218ad6403197ec839f158',
    messagingSenderId: '605026201993',
    projectId: 'otodna-c3747',
    authDomain: 'otodna-c3747.firebaseapp.com',
    storageBucket: 'otodna-c3747.appspot.com',
  );
}