import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🔥 SİBER KÖPRÜLER - YÖNETİM KULESİ BAĞLANTISI AKTİF EDİLDİ!
import '../yonetim_kulesi/admin_global_panel.dart';
import '../core/siber_tema.dart';

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
        // GÜVENLİK PROTOKOLÜ: Tek kullanımlık kod imha ediliyor...
        await _db.collection('kullanicilar').doc(kullaniciId).update({
          'iki_asamali_kod': FieldValue.delete(),
          'kod_zaman_damgasi': FieldValue.delete(),
        });
        return true;
      } else {
        debugPrint("SİBER UYARI: Geçersiz Kod veya Zaman Aşımı!");
        return false;
      }
    } catch (e) {
      debugPrint("2FA KRİTİK HATA: $e");
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
        // Kuantum Ağında yetki kontrolü
        DocumentSnapshot userDoc = await _db.collection('kullanicilar').doc(kullaniciId).get();

        if (userDoc.exists) {
          var data = userDoc.data() as Map<String, dynamic>;
          String rol = data['rol'] ?? 'USER';

          if (rol == 'ADMIN' || rol == 'BAŞKAN') {

            if (!context.mounted) return;

          // Siber Karargah Giriş Efekti
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "Siber Komutan Gazi, Karargaha Hoş Geldiniz! 🦅",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Avenir')
              ),
              backgroundColor: SiberTema.kuantumCyan,
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );

          // 🚀 YÖNLENDİRME FÜZESİ ATEŞLENDİ: YÖNETİM KULESİNE NAKİL
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminGlobalPanel())
          );

        } else {
          debugPrint("SİBER ALARM: Yetkisiz Erişim Girişimi!");
        }
      } catch (e) {
        debugPrint("KARARGAH BAĞLANTISI KOPTU: $e");
      }
    }
  }
}