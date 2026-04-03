import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// TODO: Kendi Admin Karargahı ekranını buraya import etmeyi unutma
// import '../screens/admin/master_gate.dart';

class AuthManager {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------------------------------------------------
  // 🛡️ 1. İKİ AŞAMALI KİMLİK DOĞRULAMA (2FA) MOTORU
  // ---------------------------------------------------------
  // Kuantum veritabanındaki şifreyi ve 3 dakikalık süreyi gerçek zamanlı kontrol eder.
  Future<bool> verifyTwoFactor({
    required String kullaniciId,
    required String girilenKod
  }) async {
    try {
      DocumentSnapshot userDoc = await _db.collection('kullanicilar').doc(kullaniciId).get();

      if (!userDoc.exists) return false;

      var data = userDoc.data() as Map<String, dynamic>;
      String gercekKod = data['iki_asamali_kod'] ?? "";
      Timestamp? kodZamani = data['kod_zaman_damgasi'];

      // Veritabanında kod yoksa veya silinmişse doğrudan reddet
      if (gercekKod.isEmpty || kodZamani == null) return false;

      // ⏱️ 3 DAKİKA (180 SANİYE) KURALI KONTROLÜ
      DateTime olusturulmaVakti = kodZamani.toDate();
      DateTime suAn = DateTime.now();
      Duration fark = suAn.difference(olusturulmaVakti);

      if (fark.inSeconds <= 180 && girilenKod == gercekKod) {
        // Kalkanlar indirildi! Kod doğru ve süresi dolmamış.
        // GÜVENLİK PROTOKOLÜ: Tek kullanımlık olduğu için kodu veritabanından hemen imha et!
        await _db.collection('kullanicilar').doc(kullaniciId).update({
          'iki_asamali_kod': FieldValue.delete(),
          'kod_zaman_damgasi': FieldValue.delete(),
        });
        return true;
      } else {
        print("Siber Güvenlik İhlali: Kod yanlış veya 3 dakikalık süre dolmuş!");
        return false;
      }
    } catch (e) {
      print("2FA Doğrulama Hatası: $e");
      return false;
    }
  }

  // ---------------------------------------------------------
  // 🦅 2. GİZLİ SİBER KARARGAH TETİKLEYİCİ (GHOST ADMIN PORTALI)
  // ---------------------------------------------------------
  // Ekranda gizli bir noktaya 5 saniye basılı tutulduğunda çalışır.
  Future<void> openGaziKarargah({
    required BuildContext context,
    required Duration pressDuration,
    required String kullaniciId
  }) async {

    // Sadece 5 saniye veya daha fazla basılırsa motoru ateşle
    if (pressDuration.inSeconds >= 5) {
      try {
        // Her 5 saniye basanı içeri alma! Gerçekten Kuantum Ağında ADMIN mi diye teyit et.
        DocumentSnapshot userDoc = await _db.collection('kullanicilar').doc(kullaniciId).get();

        if (userDoc.exists && userDoc.get('rol') == 'ADMIN') {
          print("Şifre Çözüldü. Siber Karargah Kilitleri Açılıyor...");

          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Siber Komutan Gazi, Karargaha Hoş Geldiniz! 🦅", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
              backgroundColor: Color(0xFF00FFC2),
              duration: Duration(seconds: 2),
            ),
          );

          // 🚀 YÖNLENDİRME FÜZESİ (Baştaki import'u ve bu satırı kendi ekranına göre aç)
          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MasterGateScreen()));
        } else {
          print("SİBER ALARM: Yetkisiz Karargah Erişim Girişimi Engellendi!");
        }
      } catch (e) {
        print("Karargah Bağlantı Hatası: $e");
      }
    }
  }
}