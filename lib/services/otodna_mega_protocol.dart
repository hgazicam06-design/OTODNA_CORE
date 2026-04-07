import 'package:cloud_firestore/cloud_firestore.dart';

/// 🚀 OTODNA MEGA PROTOKOLÜ: S.O.S VE ACIMASIZ CEZA MOTORU
/// Bu sınıf, acil durum sinyallerini yönetir ve asılsız ihbarlarda kullanıcıyı sistemden tecrit eder.
class OtoDnaMegaProtocol {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ====================================================================
  // 1. SİBER S.O.S FÜZESİNİ ATEŞLE (5 Saniye Protokolü)
  // ====================================================================
  static Future<Map<String, dynamic>> sosSinyaliAtesle({
    required String kullaniciId,
    required String plaka,
    required String qrData,
    required String konum, // Koordinat verisi
  }) async {
    try {
      // 🛡️ SİBER KONTROL: Kullanıcı Kırmızı Kart (2 Ceza Puanı) yemiş mi?
      DocumentSnapshot userDoc = await _db.collection('kullanicilar').doc(kullaniciId).get();
      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>;
        int cezaPuan = data['sos_ceza_puani'] ?? 0;

        if (cezaPuan >= 2) {
          return {
            'basarili': false,
            'mesaj': 'SİSTEM KİLİTLİ: Asılsız ihbarlar nedeniyle S.O.S yetkiniz kalıcı olarak askıya alınmıştır!'
          };
        }
      }

      // ⛓️ ATOMİK ZIRH: WriteBatch Başlatıldı
      WriteBatch batch = _db.batch();

      // S.O.S Sinyalini Kuantum Ağına Bırak
      DocumentReference sosRef = _db.collection('sos_sinyalleri').doc();
      batch.set(sosRef, {
        'kullanici_id': kullaniciId,
        'kullanici_maske': 'OTODNA_SÜRÜCÜSÜ', // Güvenlik protokolü gereği
        'plaka': plaka,
        'qr_veri': qrData,
        'konum': konum,
        'durum': 'Bekliyor', // Bekliyor, Müdahale Edildi, Asılsız İhbar
        'sinyal_zamani': FieldValue.serverTimestamp(),
      });

      // Amiral Gemisi Radarına (Sistem Logları) Kırmızı Alarm Gönder
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'sos',
        'islem_detayi': '🚨 ACİL DURUM: $plaka plakalı araçtan S.O.S alındı! Mevki: $konum',
        'birim': 'MERKEZ_RADARI',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      return {'basarili': true, 'mesaj': 'S.O.S Sinyali Kuantum Radarlarına Ulaştı! Karargah teyakkuzda.'};

    } catch (e) {
      return {'basarili': false, 'mesaj': 'Sinyal Hatası: Karargahla bağlantı kurulamadı! $e'};
    }
  }

  // ====================================================================
  // 2. ASILSIZ İHBAR CEZA MOTORU (SARI VE KIRMIZI KART SİSTEMİ)
  // ====================================================================
  static Future<void> asilsizIhbarCezasiKes(String kullaniciId, String sosDocId) async {
    try {
      WriteBatch batch = _db.batch();

      // 1. S.O.S Kaydını "Asılsız" olarak işaretle ve mühürle
      DocumentReference sosRef = _db.collection('sos_sinyalleri').doc(sosDocId);
      batch.update(sosRef, {'durum': 'Asılsız İhbar'});

      // 2. Kullanıcının Siber Siciline Ceza Puanını İşle
      DocumentReference userRef = _db.collection('kullanicilar').doc(kullaniciId);
      batch.update(userRef, {
        'sos_ceza_puani': FieldValue.increment(1), // +1 Ceza Puanı
      });

      // 3. Adalet Divanı Loglarına İhlali Kaydet
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'ceza',
        'islem_detayi': 'SİBER İHLAL: $kullaniciId ID\'li kullanıcıya asılsız ihbar cezası kesildi.',
        'birim': 'ADALET_DİVANI',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();

    } catch (e) {
      // Hata durumunda sistem loglarına sessizce raporla
      FirebaseFirestore.instance.collection('sistem_loglari').add({
        'islem_turu': 'hata',
        'islem_detayi': 'CEZA MOTORU ARIZASI: $e',
        'tarih': FieldValue.serverTimestamp(),
      });
    }
  }
}