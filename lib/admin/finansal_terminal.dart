import 'package:cloud_firestore/cloud_firestore.dart';

/// OTODNA KUANTUM FİNANSAL TERMİNAL SERVİSİ (KARA KASA)
class FinansalTerminalServisi {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- 💰 SİBER KASA: ANLIK PAY HESAPLAMA VE DAĞITIM MOTORU ---
  Future<Map<String, dynamic>> islemKaydetVeHakedisDagit({
    required String bayiId,
    required String bayiAdi,
    required String sehir,
    required double islemTutari,
    required String islemTipi,
  }) async {
    try {
      // 1. Kuantum Algoritması: Pay Dağılımı
      // 🔥 SİBER KURAL: Murat Plaza'dan %30 (%28 Kâr + %2 Vergi), Diğerlerinden %12 (%10 Kâr + %2 Vergi) kesilir!
      double vergiPayi = islemTutari * 0.02; // Devletin vergisi sabit %2
      double gaziNet = 0.0;

      if (bayiAdi.toUpperCase().contains('MURAT PLAZA')) {
        gaziNet = islemTutari * 0.28; // Murat Plaza VIP Kesintisi (%30'a tamamlar, Kasa Kazanır!)
      } else {
        gaziNet = islemTutari * 0.10; // Standart Karargah Payı (%12'ye tamamlar)
      }

      double bayiKalan = islemTutari - (gaziNet + vergiPayi);

      // SİBER ZIRH (WriteBatch): Eğer internet koparsa ya hiçbiri yazılmaz ya da hepsi birden yazılır.
      // Kuruş şaşmaz, kasa açık vermez!
      WriteBatch batch = _db.batch();

      // 2. İşlemi Veritabanı Loglarına Mühürle
      DocumentReference islemRef = _db.collection('finansal_islemler').doc();
      batch.set(islemRef, {
        'bayi_id': bayiId,
        'bayi_adi': bayiAdi,
        'sehir': sehir,
        'islem_tipi': islemTipi,
        'brut_tutar': islemTutari,
        'gazi_payi': gaziNet,
        'vergi_payi': vergiPayi,
        'bayi_hakedis': bayiKalan,
        'islem_tarihi': FieldValue.serverTimestamp(),
      });

      // 3. Amiral Gemisi Kasasını Güncelle (Gazi Payı ve Toplam Sistem Cirosu)
      DocumentReference sistemFinansRef = _db.collection('sistem_verileri').doc('finans');
      batch.set(sistemFinansRef, {
        'gunluk_ciro': FieldValue.increment(islemTutari), // Amiral gemisindeki o dev yazıyı tetikler
        'toplam_ciro': FieldValue.increment(islemTutari),
        'toplam_gazi_payi': FieldValue.increment(gaziNet),
        'toplam_vergi': FieldValue.increment(vergiPayi),
      }, SetOptions(merge: true));

      // 4. Bayinin Kendi Cirosunu Güncelle
      DocumentReference bayiRef = _db.collection('bayiler').doc(bayiId);
      batch.set(bayiRef, {
        'aylik_ciro': FieldValue.increment(islemTutari),
        'toplam_hakedis': FieldValue.increment(bayiKalan),
      }, SetOptions(merge: true));

      // 5. 81 İl Liderlik Tablosu İçin Şehir Cirosunu Güncelle
      DocumentReference sehirRef = _db.collection('sehir_istatistikleri').doc(sehir);
      batch.set(sehirRef, {
        'toplam_ciro': FieldValue.increment(islemTutari),
        'komutan_payi': FieldValue.increment(gaziNet),
      }, SetOptions(merge: true));

      // TÜM FÜZELERİ AYNI ANDA ATEŞLE!
      await batch.commit();

      return {'basarili': true, 'mesaj': 'Finansal işlem başarıyla Kuantum Ağına mühürlendi.'};
    } catch (e) {
      // Hata olursa işlemi geri aldırırız, kasa asla eksiye düşmez.
      return {'basarili': false, 'mesaj': 'SİBER AĞ HATASI: Kasa işlemi başarısız oldu. $e'};
    }
  }

  // --- 🗺️ SİBER RÖNTGEN: AYLIK 81 İL PERFORMANS RADARI ---
  // Amiral ekranında hangi şehrin daha çok kazandırdığını canlı (Stream) olarak listelemek için kullanılır
  Stream<QuerySnapshot> sehirBazliCiroRaporuCanli() {
    return _db
        .collection('sehir_istatistikleri')
        .orderBy('toplam_ciro', descending: true)
        .snapshots();
  }
}