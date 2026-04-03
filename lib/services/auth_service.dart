import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;

// 🚀 SİBER SAĞLAYICI (Riverpod ile her yerden erişim için)
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// 🛡️ KUANTUM KİMLİK MOTORU (AuthService)
/// Karargaha giriş, çıkış ve SMS yakalama protokollerini yönetir.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // ── 1. SİBER E-POSTA PROTOKOLÜ (Kayıt / Giriş) ──────────────────────────
  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      developer.log("SİBER BİLGİ: Yeni Kuantum Kimliği oluşturuluyor...");
      return await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password.trim());
    } on FirebaseAuthException catch (e) {
      developer.log("AĞ ÇÖKTÜ: Kayıt işlemi başarısız. Hata: ${e.code}");
      throw Exception(_getTurkishErrorMessage(e.code));
    }
  }

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      developer.log("SİBER BİLGİ: Karargaha sızma girişimi başlatıldı...");
      return await _auth.signInWithEmailAndPassword(email: email.trim(), password: password.trim());
    } on FirebaseAuthException catch (e) {
      developer.log("ERİŞİM İHLALİ: Giriş başarısız. Hata: ${e.code}");
      throw Exception(_getTurkishErrorMessage(e.code));
    }
  }

  // ── 2. OTONOM SMS RADARI (Kodu Havada Yakalama) ─────────────────────────
  Future<void> verifySiberPhone({
    required String phoneNumber,
    required Function(PhoneAuthCredential) onAutoVerify,
    required Function(FirebaseAuthException) onFailed,
    required Function(String, int?) onCodeSent,
  }) async {
    developer.log("SİBER BİLGİ: $phoneNumber numarasına onay sinyali fırlatılıyor...");

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,

      // 1. SİHİRLİ NOKTA: Android cihazlarda SMS gelince kodu otomatik okuyup burayı tetikler!
      verificationCompleted: (PhoneAuthCredential credential) async {
        developer.log('⚡ SİBER RADAR: SMS Kodu havada yakalandı! Otonom giriş mühürleniyor...');
        onAutoVerify(credential); // Kodu alıp Karargah kapılarını açar
      },

      // 2. Doğrulama başarısız olursa
      verificationFailed: (FirebaseAuthException e) {
        developer.log("AĞ ÇÖKTÜ: SMS Doğrulama Sinyali koptu!", error: e);
        onFailed(e);
      },

      // 3. SMS başarıyla gönderildiğinde (Kullanıcı manuel girmek isterse)
      codeSent: (String verificationId, int? resendToken) {
        developer.log("SİBER BİLGİ: Doğrulama sinyali (SMS) hedefe ulaştı.");
        onCodeSent(verificationId, resendToken);
      },

      // 4. Otomatik okuma süresi (Zaman aşımı) dolarsa
      codeAutoRetrievalTimeout: (String verificationId) {
        developer.log("SİBER UYARI: Otonom radar zaman aşımına uğradı. Manuel giriş bekleniyor.");
      },
    );
  }

  // ── 3. YAKALANAN VEYA YAZILAN KOD İLE GİRİŞİ TAMAMLAMA ──────────────────
  Future<UserCredential?> signInWithPhoneCredential(PhoneAuthCredential credential) async {
    try {
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getTurkishErrorMessage(e.code));
    }
  }

  // ── 4. SİSTEMDEN GÜVENLİ ÇIKIŞ PROTOKOLÜ ────────────────────────────────
  Future<void> signOut() async {
    developer.log("SİBER BİLGİ: Karargahtan güvenli çıkış yapılıyor...");
    await _auth.signOut();
  }

  // ── 🛠️ FİREBASE KODLARINI SİBER DİLE ÇEVİREN TERCÜMAN ───────────────────
  String _getTurkishErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'SİBER İHLAL: Sistemde böyle bir Dijital Kimlik bulunamadı.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'ERİŞİM REDDEDİLDİ: Hatalı şifre veya kimlik!';
      case 'email-already-in-use':
        return 'AĞ ÇAKIŞMASI: Bu E-Posta zaten Karargaha mühürlü!';
      case 'invalid-phone-number':
        return 'HATALI SİNYAL: Geçersiz telefon numarası. (+90 ile deneyin)';
      case 'quota-exceeded':
        return 'RADAR TIKANDI: SMS kotası aşıldı. Lütfen bekleyin Ortak.';
      case 'network-request-failed':
        return 'AĞ ÇÖKTÜ: Karargah ile bağlantı koptu. İnternetinizi kontrol edin.';
      case 'too-many-requests':
        return 'ŞÜPHELİ AKTİVİTE: Çok fazla istek attınız. Sistem geçici olarak kilitlendi.';
      default:
        return 'SİSTEMSEL ANOMALİ: Bilinmeyen bir siber hata oluştu ($errorCode).';
    }
  }
}