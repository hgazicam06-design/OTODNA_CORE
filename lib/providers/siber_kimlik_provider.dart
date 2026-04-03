// lib/core/providers/siber_kimlik_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 📡 1. FİREBASE KİMLİK RADARI (Kullanıcı giriş/çıkışlarını anlık dinler)
final authDurumProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// 🛡️ 2. KARARGAH SİCİL MOTORU (Kullanıcının Firestore'daki rolünü ve verilerini tüm ağa dağıtır)
final siberSicilProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  // Yukarıdaki radarı izler. Eğer kullanıcı yoksa sicil de yoktur.
  final user = ref.watch(authDurumProvider).value;

  if (user == null) {
    developer.log("🛑 RİVERPOD: Aktif siber kimlik bulunamadı.");
    return null;
  }

  try {
    developer.log("📡 RİVERPOD: ${user.uid} kimlikli personelin Kuantum Sicili çekiliyor...");

    final doc = await FirebaseFirestore.instance.collection('kullanicilar').doc(user.uid).get();

    if (doc.exists) {
      developer.log("✅ RİVERPOD ONAYI: Sicil başarıyla ağa yüklendi!");
      return doc.data();
    }

    developer.log("⚠️ RİVERPOD İHLALİ: Kullanıcı var ama Karargahta sicil kaydı yok!");
    return null;

  } catch (e) {
    developer.log("🚨 RİVERPOD ÇÖKTÜ: Sicil verisi çekilemedi!", error: e);
    return null;
  }
});