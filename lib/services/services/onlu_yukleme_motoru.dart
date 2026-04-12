import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM KADEMELİ YÜKLEME VE FİNANS MOTORU
/// Bayi yetki seviyesine göre (10, 50, 100) PDF verilerini işler ve
/// Karargahın %12 (%10 Net + %2 Vergi) mali kuralını otonom uygular.
class KuantumYuklemeMotoru {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 📊 BAYİ YETKİ VE LİMİT KONTROLÜ ─────────────────────────────────────
  static int getPaketLimiti(String bayiTipi) {
    switch (bayiTipi.toUpperCase()) {
      case 'ULTRA_VIP':
        return 100;
      case 'VIP':
        return 50;
      case 'NORMAL':
      default:
        return 10;
    }
  }

  // ── 🚀 SİBER PAKETLEME VE HUB ENTEGRASYONU ──────────────────────────────
  static Future<void> siberVeriTransferi({
    required List<Map<String, dynamic>> hamVeriler,
    required String ustaId,
    required String bayiTipi,
  }) async {
    try {
      int limit = getPaketLimiti(bayiTipi);

      if (hamVeriler.isEmpty) {
        throw Exception("SİBER İHLAL: İşlenecek veri bulunamadı, operasyon durduruldu!");
      }

      developer.log("SİBER RADAR: 📦 $bayiTipi seviyesi için $limit'lik transfer protokolü başlatıldı.");

      // 🛡️ LİMİT ZIRHI: Sadece yetki dahilindeki miktar işlenir
      var islenecekPaket = hamVeriler.take(limit).toList();

      // ⛓️ ATOMİK ZIRH: WriteBatch Başlatıldı
      WriteBatch batch = _db.batch();

      for (var urun in islenecekPaket) {
        // ⚖️ FİNANSAL ÇARK (KARARGAHIN MUTLAK %12 PAYI)
        double urunFiyati = (urun['fiyat'] ?? 0).toDouble();
        double karargahPayi = urunFiyati * 0.12; // %10 Kâr + %2 Vergi

        DocumentReference urunRef = _db.collection('bayi_stoklari').doc();
        batch.set(urunRef, {
          'usta_id': ustaId,
          'bayi_tipi': bayiTipi,
          'sase_no': (urun['vin'] ?? 'BILINMIYOR').toString().toUpperCase(),
          'urun_adi': urun['name'] ?? 'Adsız Parça',
          'ham_fiyat': urunFiyati,
          'karargah_payi': karargahPayi,
          'toplam_maliyet': urunFiyati + karargahPayi,
          'hub_dogrulama': true, // Google Hub üzerinden çekildiği mühürü
          'onay_durumu': 'USTA_ONAYI_BEKLIYOR',
          'tarih': FieldValue.serverTimestamp(),
        });
      }

      // Kara Kutuya (Sistem Logları) Büyük Operasyonu Bildir
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'TOPLU_HUB_AKTARIMI',
        'islem_detayi': 'SİBER BİLGİ: $bayiTipi seviyesinde ${islenecekPaket.length} ürün mühürlendi.',
        'usta_id': ustaId,
        'tarih': FieldValue.serverTimestamp(),
      });

      // TÜM FÜZELERİ AYNI ANDA ATEŞLE!
      await batch.commit();

      developer.log("SİBER ONAY: ✅ $bayiTipi yetkisiyle ${islenecekPaket.length} ürün Karargah kasasına ve stoklarına mühürlendi!");

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Kademeli yükleme motoru arızalandı!", error: e);
      throw Exception("SİBER HATA: Veri transferi başarısız! Yetki seviyenizi veya ağ bağlantınızı kontrol edin.");
    }
  }
}