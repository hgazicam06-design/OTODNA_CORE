import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM PDF ÜRÜN VE STOK YÜKLEME SERVİSİ
/// Bayi yetki seviyesine (Normal, VIP, Ultra VIP) göre stok limitlerini denetler,
/// PDF'ten ayıklanan verileri Kuantum Ağının stoklarına atomik füzelerle mühürler.
class UrunYuklemeServisi {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 📊 BAYİ YETKİ VE SİBER LİMİT KONTROLÜ ────────────────────────────────
  static int _getPaketLimiti(String bayiTipi) {
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

  // ── 🚀 SİBER PDF OKUMA VE ATOMİK YÜKLEME MOTORU ──────────────────────────
  static Future<void> pdfIleUrunYukle({
    required String bayiId,
    required String bayiTipi,
    required File pdfFile,
    required List<Map<String, dynamic>> ayiklananUrunler, // SİBER NOT: AI OCR işlemi arayüzde veya fonksiyonda yapılıp buraya liste olarak fırlatılmalıdır.
  }) async {
    try {
      int maksLimit = _getPaketLimiti(bayiTipi);
      developer.log("SİBER RADAR: $bayiId ID'li bayi ($bayiTipi) için stok yükleme protokolü başlatıldı. Kapasite: $maksLimit");

      // 1. Bayinin Mevcut Ürün Sayısını Kuantum Ağından Gerçek Zamanlı Say
      AggregateQuerySnapshot countSnapshot = await _db.collection('bayi_stoklari')
          .where('bayi_id', isEqualTo: bayiId)
          .count()
          .get();

      int mevcutUrunSayisi = countSnapshot.count ?? 0;
      developer.log("SİBER İSTİHBARAT: Bayinin Karargahtaki mevcut stok adedi -> $mevcutUrunSayisi");

      if (mevcutUrunSayisi >= maksLimit) {
        developer.log("SİBER ENGEL: $bayiId Kuantum limitlerini doldurdu!");
        throw Exception("SİBER İHLAL: Sistemde zaten $maksLimit (Maksimum) ürününüz var. Yeni mühimmat eklemek için yetkinizi yükseltin veya eski ürünleri silin!");
      }

      // 2. Kalan Siber Kapasiteyi Hesapla
      int kalanKapasite = maksLimit - mevcutUrunSayisi;
      var islenecekUrunler = ayiklananUrunler.take(kalanKapasite).toList();

      if (islenecekUrunler.isEmpty) {
        throw Exception("SİBER HATA: PDF dosyasından Karargahın okuyabileceği geçerli bir ürün çıkarılamadı!");
      }

      // ⛓️ ATOMİK ZIRH: WriteBatch Başlatıldı (İşlemi Yarıda Bırakma, Hepsini Aynı Anda Yaz!)
      WriteBatch batch = _db.batch();

      // 3. Ürünleri Kuantum Stoklarına Mühürle
      for (var urun in islenecekUrunler) {
        DocumentReference urunRef = _db.collection('bayi_stoklari').doc();
        batch.set(urunRef, {
          'urun_id': urunRef.id,
          'bayi_id': bayiId,
          'bayi_tipi': bayiTipi,
          'urun_adi': urun['ad'] ?? 'Tanımsız Mühimmat',
          'urun_fiyati': urun['fiyat'] ?? 0.0,
          'stok_durumu': 'AKTIF',
          'yukleme_kaynagi': 'PDF_OCR',
          'eklenme_tarihi': FieldValue.serverTimestamp(),
        });
      }

      // 4. Kara Kutuya (Sistem Logları) Büyük Operasyonu Bildir
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'PDF_STOK_YUKLEME',
        'islem_detayi': 'SİBER HAREKAT: $bayiId ID\'li bayi ($bayiTipi) PDF üzerinden ${islenecekUrunler.length} adet yeni ürün mühürledi.',
        'tarih': FieldValue.serverTimestamp(),
      });

      // TÜM FÜZELERİ AYNI ANDA ATEŞLE!
      await batch.commit();

      developer.log("SİBER ONAY: ✅ ${islenecekUrunler.length} adet ürün başarıyla Karargah stoklarına kilitlendi!");

      // Eğer limit yetmediği için dışarıda kalan ürün varsa uyar
      if (ayiklananUrunler.length > islenecekUrunler.length) {
        int disaridaKalan = ayiklananUrunler.length - islenecekUrunler.length;
        developer.log("SİBER UYARI: Kapasite yetersizliği sebebiyle $disaridaKalan ürün mühürlenemedi ve dışarıda kaldı!");
      }

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: PDF yükleme motoru arızalandı!", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ: UI'a Kırmızı Alarm Fırlat!
      String hataMesaji = e.toString().replaceAll('Exception: ', '');
      throw Exception("STOK YÜKLEME BAŞARISIZ: $hataMesaji");
    }
  }
}