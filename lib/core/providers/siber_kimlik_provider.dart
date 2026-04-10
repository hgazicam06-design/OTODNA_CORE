import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 📡 1. FİREBASE KİMLİK RADARI
/// Karargah kapısındaki nöbetçidir. Kullanıcı giriş/çıkışlarını anlık dinler.
final authDurumProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// 🛡️ 2. KARARGAH SİCİL MOTORU (REAKTİF)
/// Kullanıcının Firestore'daki rolünü ve verilerini (DNA) tüm ağa dağıtır.
/// FutureProvider yerine StreamProvider kullanarak veritabanındaki değişiklikleri anlık izler.
final siberSicilProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  // Kimlik radarını izler. Eğer personel kapıdan geçmediyse (null) sicili kapatır.
  final user = ref.watch(authDurumProvider).value;

  if (user == null) {
    developer.log("🛑 RİVERPOD: Aktif siber kimlik bulunamadı. Erişim reddedildi.");
    return Stream.value(null);
  }

  developer.log("📡 RİVERPOD: ${user.uid} kimlikli personelin Kuantum Sicili dinleniyor...");

  // 🔥 CANLI BAĞLANTI: Veritabanında bir değişiklik (Örn: Banlanma veya Rol Değişimi)
  // olduğu an tüm uygulama otomatik olarak tepki verir (Reaktif Koruma).
  return FirebaseFirestore.instance
      .collection('kullanicilar')
      .doc(user.uid)
      .snapshots()
      .map((doc) {
    if (doc.exists) {
      developer.log("✅ RİVERPOD ONAYI: Sicil başarıyla ağa bağlandı!");
      return doc.data();
    }
    developer.log("⚠️ RİVERPOD İHLALİ: Karargahta sicil kaydı bulunamadı!");
    return null;
  });
});

/// 🎖️ 3. RÜTBE (ROL) SAĞLAYICI
/// Uygulama içinde personelin "admin", "bayi" veya "user" olduğunu hızlıca kontrol eder.
final siberRolProvider = Provider<String?>((ref) {
  final sicil = ref.watch(siberSicilProvider).value;
  return sicil?['rol'] as String?;
});