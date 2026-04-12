import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import '../models/dukkan_model.dart';

/// 🛡️ KUANTUM VERİTABANI VE FİNANS MOTORU (FirestoreServis)
/// Ankara Merkez mühürlü dükkanları tarar ve finansal kapora havuzunu atomik yönetir.
class FirestoreServis {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 🏢 01. SİBER FİRMA/DÜKKAN RADARI ─────────────────────────────────────
  /// Sadece Karargah (Ankara Merkez) tarafından "Onaylı" mühürü almış dükkanları çeker.
  Stream<List<Dukkan>> dukkanlariGetir(String sehir) {
    developer.log("SİBER RADAR: ${sehir.toUpperCase()} bölgesindeki mühürlü dükkanlar taranıyor...");

    return _db
        .collection('dukkanlar') // Koleksiyon adları Karargahta küçük harfle standartlaştırıldı
        .where('sehir', isEqualTo: sehir.toUpperCase())
        .where('onayliMi', isEqualTo: true) // Yalnızca Ankara Merkez Onaylılar!
        .snapshots()
        .map((snapshot) {
      developer.log("SİBER İSTİHBARAT: $sehir için ${snapshot.docs.length} adet mühürlü bayi bulundu.");
      return snapshot.docs
          .map((doc) => Dukkan.fromMap(doc.data(), doc.id))
          .toList();
    })
        .handleError((error) {
      developer.log("AĞ ÇÖKTÜ: Dükkan istihbaratı radara düşmedi!", error: error);
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ: UI'a "dükkan yok" yalanını söylemek yerine hata fırlat!
      throw Exception("RADAR ÇÖKTÜ: Kuantum Ağına bağlanılamadı!");
    });
  }

  // ── 💰 02. SİBER FİNANS HAVUZU VE ATOMİK KAPORA MÜHÜRLEME ────────────────
  /// Müşterinin kaporasını Karargah Havuzuna alır, %12 komisyonu otonom keser ve zırhlar.
  Future<void> kaporaKaydet(String musteriId, String ustaId, {double tutar = 200.0}) async {
    try {
      // 🚀 KUSURSUZ ÇARK: Karargahın %12'lik net komisyonu otonom hesaplanır.
      double merkezPayi = tutar * 0.12; // Örn: 200 TL'nin %12'si = 24 TL

      // ⛓️ SİBER ZIRH: Atomik WriteBatch Başlatıldı
      WriteBatch batch = _db.batch();

      // 1. İşlemi Finans Havuzuna (Kasa) Mühürle
      DocumentReference havuzRef = _db.collection('finans_havuzu').doc();
      batch.set(havuzRef, {
        'musteriId': musteriId,
        'ustaId': ustaId,
        'islem_tutari': tutar,
        'merkezPayi': merkezPayi,
        'tarih': FieldValue.serverTimestamp(),
        'durum': 'BEKLEMEDE', // İşlem bitene kadar Karargah havuzunda kilitli kalır
        'siber_onay': false,
      });

      // 2. Kara Kutuya (Sistem Logları) Kayıt Düş
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'KAPORA_ALINDI',
        'islem_detayi': 'Müşteri ($musteriId), Usta ($ustaId) için ₺$tutar kapora kilitledi.',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit(); // Füzeleri ateşle! (Kayıtlar aynı saniyede mühürlenir)

      developer.log("SİBER FİNANS: ₺$tutar kapora Kuantum Havuzuna atomik olarak mühürlendi! Karargah Payı: ₺$merkezPayi");
    } catch (e) {
      developer.log("FİNANSAL İHLAL: Kapora Karargah havuzuna mühürlenemedi!", error: e);
      throw Exception("SİBER HATA: Finans ağına ulaşılamıyor. İşlem reddedildi.");
    }
  }
}