import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ OTODNA KUANTUM FİNANSAL TERMİNAL SERVİSİ (KARA KASA)
/// Tüm bayiler için %12 kesinti ve anlık ciro dağıtımını otonom yönetir.
class FinansalTerminalServisi {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- 💰 SİBER KASA: ANLIK PAY HESAPLAMA VE DAĞITIM MOTORU ---
  Future<void> islemKaydetVeHakedisDagit({
    required String bayiId,
    required String bayiAdi,
    required String sehir,
    required double islemTutari,
    required String islemTipi,
  }) async {
    try {
      developer.log("SİBER FİNANS: $bayiAdi ($sehir) için ₺$islemTutari tutarında işlem mühürleniyor...");

      // 1. Kuantum Algoritması: Pay Dağılımı
      // 🔥 SİBER KURAL: İSTİSNA YOK! Tüm bayiler için Mutlak Pay %12'dir (%10 Net Kâr + %2 Vergi).
      double vergiPayi = islemTutari * 0.02; // Devletin vergisi sabit %2
      double gaziNet = islemTutari * 0.10;   // Standart Karargah Payı (%10)
      double bayiKalan = islemTutari - (gaziNet + vergiPayi);

      // ⛓️ SİBER ZIRH (WriteBatch): Eğer internet koparsa ya hiçbiri yazılmaz ya da hepsi birden yazılır.
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

      developer.log("SİBER BİLGİ: Finansal operasyon başarıyla Kuantum Ağına mühürlendi.");

    } catch (e) {
      developer.log("SİBER İHLAL: Kasa işlemi başarısız oldu!", error: e);
      // 🚨 Sessiz Çöküş Engellendi! Arayüze (UI) Kırmızı Alarm Fırlatıyoruz.
      throw Exception("FİNANSAL MOTOR ARIZASI: İşlem ağa kaydedilemedi!");
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