import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM BÖLGESEL İSTİHBARAT VE ANALİZ MOTORU (RegionAnalytics)
/// 7 Bölge ve 81 ildeki parça taleplerini Kuantum Ağından canlı analiz eder,
/// bayiler için otonom stok ve satış stratejileri (tavsiyeler) üretir.
class RegionAnalytics {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 🌍 1. SİBER BÖLGE İSTİHBARATI (MAKET YIKILDI) ──────────────────────
  static Future<int> _yogunlukSorgula(String bolge, String kategori) async {
    try {
      developer.log("SİBER RADAR: '$bolge' bölgesi için '$kategori' talebi Kuantum Ağında taranıyor...");

      // Karargahın canlı talep haritası koleksiyonuna bağlanır
      DocumentSnapshot doc = await _db.collection('bolgesel_talep_haritasi').doc(bolge.toUpperCase()).get();

      if (!doc.exists) {
        developer.log("SİBER UYARI: '$bolge' bölgesi için Karargah verisi bulunamadı! Taktiksel standart (50) atanıyor.");
        return 50; // Sistem çökmez, taktiksel orta seviye ile devam eder
      }

      var veriler = doc.data() as Map<String, dynamic>;
      int yogunluk = (veriler[kategori] ?? 50).toInt();

      developer.log("SİBER BİLGİ: $bolge bölgesinde '$kategori' talep yoğunluğu %$yogunluk olarak ölçüldü.");
      return yogunluk;

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Bölgesel radar arızalandı!", error: e);
      throw Exception("SİSTEMSEL HATA: Bölgesel analiz verilerine ulaşılamıyor. Lütfen Kuantum Ağınızı kontrol edin!");
    }
  }

  // ── 📊 2. TAKTİKSEL TAVSİYE MOTORU VE ATOMİK LOGLAMA ─────────────────────
  static Future<String> tavsiyeGetir({
    required String bolge,
    required String kategori,
    required String bayiId,
  }) async {
    try {
      // 1. Canlı yoğunluğu Karargahtan çek
      int yogunluk = await _yogunlukSorgula(bolge, kategori);
      String sonucMesaji;

      // 2. Kuantum Tavsiye Çarkı
      if (yogunluk > 90) {
        sonucMesaji = "🔥 KIZIL ALARM: BU BÖLGEDE ÇOK YÜKSEK TALEP! STOKLARI DOLDUR!";
      } else if (yogunluk > 70) {
        sonucMesaji = "✅ SÜREKLİ HAREKAT: Düzenli Satış Potansiyeli. İkmal hattını koru.";
      } else {
        sonucMesaji = "ℹ️ STANDART SEYİR: Normal Talep Seviyesi. Rutin stok yeterli.";
      }

      // ⛓️ ATOMİK ZIRH: İstihbarat sorgusunu Karargah Kara Kutusuna logla!
      await _db.collection('sistem_loglari').add({
        'islem_turu': 'BOLGESEL_ISTIHBARAT_SORGUSU',
        'islem_detayi': 'SİBER ANALİZ: $bayiId yetkilisi $bolge bölgesinde "$kategori" için taktiksel durum raporu çekti. Ölçülen Yoğunluk: %$yogunluk',
        'tarih': FieldValue.serverTimestamp(),
      });

      developer.log("SİBER ONAY: ✅ Taktiksel rapor oluşturuldu ve Karargaha mühürlendi.");
      return sonucMesaji;

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Tavsiye motoru başarısız!", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ: UI tarafına kırmızı alarm fırlatılır!
      throw Exception("SİBER İSTİHBARAT HATASI: Taktiksel tavsiye raporu Kuantum Ağından alınamadı!");
    }
  }
}