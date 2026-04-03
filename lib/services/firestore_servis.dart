import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import '../models/dukkan_model.dart';

/// 🛡️ KUANTUM VERİTABANI VE FİNANS MOTORU (FirestoreServis)
/// Ankara Merkez mühürlü dükkanları tarar ve finansal kapora havuzunu yönetir.
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
      return <Dukkan>[]; // Sistem çökmesini engellemek için boş liste fırlat
    });
  }

  // ── 💰 02. SİBER FİNANS HAVUZU (KAPORA MÜHÜRLEME) ────────────────────────
  /// Müşterinin kaporasını Karargah Havuzuna alır, %12 komisyonu otonom keser.
  Future<void> kaporaKaydet(String musteriId, String ustaId, {double tutar = 200.0}) async {
    try {
      // 🚀 KUSURSUZ ÇARK: Karargahın %12'lik net komisyonu otonom hesaplanır.
      double merkezPayi = tutar * 0.12; // Örn: 200 TL'nin %12'si = 24 TL

      await _db.collection('finans_havuzu').add({
        'musteriId': musteriId,
        'ustaId': ustaId,
        'islem_tutari': tutar,
        'merkezPayi': merkezPayi,
        'tarih': FieldValue.serverTimestamp(),
        'durum': 'BEKLEMEDE', // İşlem bitene kadar Karargah havuzunda kilitli kalır
        'siber_onay': false,
      });

      developer.log("SİBER FİNANS: ₺$tutar kapora Kuantum Havuzuna mühürlendi! Karargah Payı: ₺$merkezPayi");
    } catch (e) {
      developer.log("FİNANSAL İHLAL: Kapora Karargah havuzuna mühürlenemedi!", error: e);
      throw Exception("SİBER HATA: Finans ağına ulaşılamıyor.");
    }
  }
}