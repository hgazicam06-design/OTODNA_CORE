import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM PAKET VE CEPHANELİK MOTORU
/// Ustanın teklif ekranı için hazır bakım paketlerini doğrudan Karargah veritabanından çeker.
class PackageService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 📦 CANLI PAKET İSTİHBARATI (MAKET YIKILDI) ──────────────────────────
  static Future<List<Map<String, dynamic>>> getPackageItems(String packageType) async {
    try {
      developer.log("SİBER RADAR: '$packageType' paketi Karargah cephaneliğinden (Firebase) çekiliyor...");

      // 'hazir_paketler' koleksiyonundan ilgili paketin güncel içeriklerini çeker
      QuerySnapshot snapshot = await _db.collection('hazir_paketler')
          .where('paket_turu', isEqualTo: packageType)
          .get();

      if (snapshot.docs.isEmpty) {
        developer.log("SİBER UYARI: '$packageType' paketi Kuantum Ağında bulunamadı!");
        return [];
      }

      // Paketin içindeki parçaları liste olarak döndür
      List<Map<String, dynamic>> items = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      developer.log("SİBER İSTİHBARAT: $packageType paketi için ${items.length} adet güncel mühimmat/parça bulundu.");
      return items;

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Hazır paket servisi arızalandı!", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ: UI'a Kırmızı Alarm Fırlat!
      throw Exception("SİSTEMSEL HATA: '$packageType' paketi Karargahtan çekilemedi. Bağlantınızı kontrol edin!");
    }
  }
}