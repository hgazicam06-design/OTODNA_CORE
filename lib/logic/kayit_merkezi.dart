import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// 🦅 OTODNA KAYIT VE İSTİHBARAT MERKEZİ (Siber Kalkan)
/// Tüm yeni kayıtların (Kullanıcı, Usta, Distribütör) Karargaha giriş yaptığı ana terminaldir.
/// Davetiye sistemiyle (B2B) veya doğrudan (B2C) kayıt olunabilir.
class KayitMerkezi {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Yeni bir Bireysel veya Kurumsal (Davetiye Kodlu) kayıt oluşturur.
  static Future<UserCredential?> siberKayitOlustur({
    required String email,
    required String password,
    required String adSoyad,
    String? davetKodu, // Eğer doluysa, yetki seviyesini değiştirir
  }) async {
    try {
      // 1. Firebase Auth Kalkanından Geçiş (Email/Şifre)
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;
      String yetkiSeviyesi = 'kullanici'; // Varsayılan Sivil Yetki
      String? bagliOlduguDistributorId;

      // 2. DAVET KODU İSTİHBARATI (B2B Modülü)
      if (davetKodu != null && davetKodu.trim().isNotEmpty) {
        // Davetiye kodunu Karargahta tara
        QuerySnapshot davetSorgusu = await _db
            .collection('davetiyeler')
            .where('kod', isEqualTo: davetKodu.trim())
            .where('kullanildi_mi', isEqualTo: false)
            .get();

        if (davetSorgusu.docs.isNotEmpty) {
          // Davetiye Geçerli!
          DocumentSnapshot davetDoc = davetSorgusu.docs.first;
          yetkiSeviyesi = davetDoc['yetki_turu'] ?? 'bayi'; // 'bayi', 'usta', vb.
          bagliOlduguDistributorId = davetDoc['olusturan_uid'];

          // 2.1 Davetiyeyi "Kullanıldı" olarak mühürle (Atomik)
          await _db.collection('davetiyeler').doc(davetDoc.id).update({
            'kullanildi_mi': true,
            'kullanan_uid': uid,
            'kullanma_tarihi': FieldValue.serverTimestamp(),
          });

          debugPrint("🚀 B2B DAVET BAŞARILI: $yetkiSeviyesi olarak atandı.");
        } else {
          // Hatalı davet kodu siber girişimi!
          throw Exception("GEÇERSİZ DAVET KODU: Karargah bu kodu reddetti!");
        }
      }

      // 3. KULLANICI DNA'SINI VERİTABANINA YAZ (Siber Profil)
      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'ad_soyad': adSoyad,
        'yetki': yetkiSeviyesi,
        'bagli_distributor_id': bagliOlduguDistributorId,
        'siber_genetik_skor': 100, // Karargah Başlangıç Güven Skoru
        'kayit_tarihi': FieldValue.serverTimestamp(),
        'bakiye': 0.0,
      });

      debugPrint("🛡️ KAYIT MERKEZİ: SİBER KİMLİK OLUŞTURULDU -> [$email] Yetki: $yetkiSeviyesi");
      
      return userCredential;
      
    } on FirebaseAuthException catch (e) {
      debugPrint("FIREBASE AUTH HATASI: ${e.code}");
      String hataMesaji = "Siber Kayıt Reddedildi: Bilinmeyen Hata";
      
      if (e.code == 'weak-password') hataMesaji = "Siber Şifre Zayıf: En az 6 karakter kullanın.";
      else if (e.code == 'email-already-in-use') hataMesaji = "İstihbarat Çakışması: Bu e-posta zaten kullanımda.";
      else if (e.code == 'invalid-email') hataMesaji = "Geçersiz İstihbarat: E-posta formatı hatalı.";
      
      throw Exception(hataMesaji);
    } catch (e) {
      debugPrint("SİSTEM ÇÖKTÜ: $e");
      throw Exception(e.toString());
    }
  }

  /// Mevcut kullanıcılar için Şifre Sıfırlama İstihbaratı gönderir.
  static Future<void> sifreSifirlamaGonder(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint("📧 SİBER POSTA: Şifre sıfırlama kalkanı $email adresine fırlatıldı.");
    } catch (e) {
      throw Exception("Şifre sıfırlama bağlantısı gönderilemedi.");
    }
  }
}