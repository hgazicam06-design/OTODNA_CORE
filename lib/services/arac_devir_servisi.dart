import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// 🦅 SİBER KARARGAH: Araç Devir Protokolü (Kuantum Zırhlı)
/// Bir araç satıldığında, aracın tüm DNA'sını (bakım geçmişi, mühürler vb.) 
/// yeni sahibine aktaran ve eski sahibinin yetkilerini iptal eden Atomik Motor.
class AracDevirServisi {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Aracı güvenli bir şekilde yeni sahibine devreder. İşlem başarısız olursa her şey geri alınır (Atomik).
  static Future<void> araciDevret({
    required String saseNo,
    required String eskiSahibiUid,
    required String yeniSahibiUid,
    required String yeniSahibiTc, // Güvenlik kalkanı için
  }) async {
    try {
      String muhurluSase = saseNo.toUpperCase();
      
      // 1. Döküman Referanslarını Hazırla
      DocumentReference aracRef = _db.collection('araclar').doc(muhurluSase);
      DocumentReference devirLogRef = _db.collection('sistem_loglari').doc();
      
      // 2. Kuantum Atomik Zırhını Başlat
      WriteBatch batch = _db.batch();

      // 3. Aracın sahibini güncelle
      batch.update(aracRef, {
        'sahibiUid': yeniSahibiUid,
        'sahibiTc': yeniSahibiTc,
        'sonDevirTarihi': FieldValue.serverTimestamp(),
        // Siber güvenlik: Fcm tokenları vb. temizle ki eski sahibe bildirim gitmesin
        'fcmToken': FieldValue.delete(), 
        'eskiSahibiUid': eskiSahibiUid, // Geriye dönük istihbarat için
      });

      // 4. Karargah Loglarına mühür vur (Yasal Takip)
      batch.set(devirLogRef, {
        'islem_turu': 'KUANTUM_DEVIR',
        'sase_no': muhurluSase,
        'eski_sahip': eskiSahibiUid,
        'yeni_sahip': yeniSahibiUid,
        'islem_tarihi': FieldValue.serverTimestamp(),
        'durum': 'BASARILI',
        'not': 'OtoDNA Sistem Zırhı ile araç ve DNA profili yeni sahibine devredildi.'
      });

      // 5. Zırhlı İşlemi Ateşle (Commit)
      await batch.commit();

      debugPrint("🚀 SİBER PROTOKOL: $muhurluSase şaseli araç BAŞARIYLA devredildi.");
    } catch (e) {
      debugPrint("SİBER HATA: Devir Protokolü çöktü. Tüm işlemler geri alındı! Hata: $e");
      throw Exception("Kuantum Devir Hatası: Araç aktarımı başarısız oldu.");
    }
  }

  /// Kullanıcının aracın gerçek sahibi olup olmadığını denetleyen siber kalkan
  static Future<bool> sahiplikDogrula(String saseNo, String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('araclar').doc(saseNo.toUpperCase()).get();
      if (!doc.exists) return false;
      
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      return data != null && data['sahibiUid'] == uid;
    } catch (e) {
      return false;
    }
  }
}
