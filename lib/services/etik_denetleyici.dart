import 'package:cloud_firestore/cloud_firestore.dart';

class EtikDenetleyici {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🦅 SİBER KARDEŞLİK VE ETİK KONTROLÜ
  Future<bool> mesajEtikMi(String mesaj) async {
    // Kötüleme, hakaret ve rakip bayiyi hedef alan anahtar kelime radarı
    List<String> yasakliKelimeler = [
      "beceriksiz", "dolandırıcı", "sahtekar", "kötü yapmış", 
      "yanlış usta", "gitmeyin", "rezalet", "hırsız"
    ];

    for (var kelime in yasakliKelimeler) {
      if (mesaj.toLowerCase().contains(kelime)) {
        print("🚨 SİBER İHLAL: Kardeşlik protokolüne aykırı içerik tespit edildi!");
        return false;
      }
    }
    return true; // Mesaj temiz, kardeşlik baki.
  }

  // 🛡️ İHLAL DURUMUNDA SARI KART CEZASI
  Future<void> ihlalKaydet(String bayiId, String mesaj) async {
    await _db.collection('etik_ihlalleri').add({
      'bayi_id': bayiId,
      'hatali_mesaj': mesaj,
      'tarih': FieldValue.serverTimestamp(),
      'islem': 'SARI_KART', // Tekrarda Kırmızı Kart ve Blacklist
    });
  }
}
