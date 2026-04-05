import 'package:cloud_firestore/cloud_firestore.dart';

/// 🚀 OTODNA MEGA PROTOKOLÜ: S.O.S VE ACIMASIZ CEZA MOTORU
class OtoDnaMegaProtocol {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ====================================================================
  // 1. SİBER S.O.S FÜZESİNİ ATEŞLE (5 Saniye Basılı Tutulduğunda Tetiklenir)
  // ====================================================================
  static Future<Map<String, dynamic>> sosSinyaliAtesle({
    required String kullaniciId,
    required String plaka,
    required String qrData,
    required String konum, // GeoPoint veya String koordinat
  }) async {
    try {
      // 🛡️ Önce Kontrol Et: Bu adam Kırmızı Kart yemiş mi?
      DocumentSnapshot userDoc = await _db.collection('kullanicilar').doc(kullaniciId).get();
      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>;
        int cezaPuan = data['sos_ceza_puani'] ?? 0;

        if (cezaPuan >= 2) {
          return {'basarili': false, 'mesaj': 'SİSTEM KİLİTLİ: Asılsız ihbarlar nedeniyle (Kırmızı Kart) S.O.S yetkiniz alınmıştır!'};
        }
      }

      WriteBatch batch = _db.batch(); // 🔥 Kuantum Mührü

      // Sinyali Ağ'a Bırak
      DocumentReference sosRef = _db.collection('sos_sinyalleri').doc();
      batch.set(sosRef, {
        'kullanici_id': kullaniciId,
        'kullanici': 'OTODNA SÜRÜCÜSÜ', // Gizlilik için maskeli
        'plaka': plaka,
        'qr_veri': qrData,
        'konum': konum,
        'durum': 'Bekliyor', // Bekliyor, Müdahale Edildi, Asılsız İhbar
        'sinyal_zamani': FieldValue.serverTimestamp(),
      });

      // Amiral Gemisine (Loglara) Kırmızı Alarm Gönder
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'sos',
        'islem_detayi': '🚨 SİBER S.O.S: $plaka plakalı araçtan acil durum sinyali alındı! Konum: $konum',
        'bayi_isim': 'MERKEZ RADARI',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      return {'basarili': true, 'mesaj': 'S.O.S Sinyali Kuantum Radarlarına Ulaştı! Bekleyin.'};
    } catch (e) {
      return {'basarili': false, 'mesaj': 'Ağ Hatası: $e'};
    }
  }

  // ====================================================================
  // 2. ASILSIZ İHBAR CEZA MOTORU (SARI VE KIRMIZI KART SİSTEMİ)
  // ====================================================================
  static Future<void> asilsizIhbarCezasiKes(String kullaniciId, String sosDocId) async {
    try {
      WriteBatch batch = _db.batch();

      // 1. S.O.S Kaydını "Asılsız" olarak işaretle
      DocumentReference sosRef = _db.collection('sos_sinyalleri').doc(sosDocId);
      batch.update(sosRef, {'durum': 'Asılsız İhbar'});

      // 2. Kullanıcının sicilini çek ve ceza puanını (Sarı/Kırmızı Kart) ayarla
      DocumentReference userRef = _db.collection('kullanicilar').doc(kullaniciId);

      batch.update(userRef, {
        // Mevcut ceza puanını 1 artır
        'sos_ceza_puani': FieldValue.increment(1),
        // Eğer 2 olursa otomatik olarak üyeliği tehlikeye girer (Arayüzde okuyacağız)
      });

      // 3. Loglara Acımasızca Mühürle
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'hata',
        'islem_detayi': 'SİBER CEZA: Kullanıcıya asılsız SOS ihbarından dolayı SARI/KIRMIZI KART verildi!',
        'bayi_isim': 'ADALET DİVANI',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      // Sessiz hata yakalama (Sistem çökmesin diye)
      print("Siber Ceza Motoru Hatası: $e");
    }
  }
}