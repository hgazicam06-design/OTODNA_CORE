// lib/services/ekspertiz_muhur_servisi.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM EKSPERTİZ MÜHÜR VE PDF SERVİSİ
/// Raporların 2 saatlik kilit mekanizmasını ve ücretli PDF çıktı operasyonunu yönetir.
class EkspertizMuhurServisi {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── ⏱️ ZAMAN VE MÜHÜR KONTROLÜ ──
  /// Raporun oluşturulma tarihine bakar. 2 saat (120 dakika) geçtiyse raporu kilitli kabul eder.
  bool isRaporMuhurlendi(Timestamp? olusturulmaTarihi) {
    if (olusturulmaTarihi == null) return false;

    DateTime creationDate = olusturulmaTarihi.toDate();
    DateTime now = DateTime.now();
    Duration difference = now.difference(creationDate);

    return difference.inHours >= 2;
  }

  // ── 📄 ÜCRETLİ PDF OLUŞTURMA VE FİNANSAL KESİNTİ (ATOMİK ZIRH) ──
  Future<void> ucretliPdfTalebiOlustur({
    required String raporId,
    required String kullaniciId,
    required double ucret, // Örn: 499 TL
  }) async {
    developer.log("📡 SİBER FİNANS: $raporId raporu için ücretli PDF talebi başlatılıyor...");

    try {
      // 🛡️ ATOMİK İŞLEM: Para kesintisi ve PDF onayı tek seferde Kuantum Ağına işlenir!
      WriteBatch batch = _db.batch();

      // 1. PDF İstekler Kuyruğuna Ekle (Cloud Functions bu kuyruğu dinleyip PDF üretecek)
      DocumentReference pdfTalebiRef = _db.collection('pdf_kuyrugu').doc();
      batch.set(pdfTalebiRef, {
        'rapor_id': raporId,
        'kullanici_id': kullaniciId,
        'durum': 'HAZIRLANIYOR',
        'talep_tarihi': FieldValue.serverTimestamp(),
      });

      // 2. Karargah Finans Havuzuna Ücreti İşle
      DocumentReference finansRef = _db.collection('finans_havuzu').doc();
      batch.set(finansRef, {
        'kullanici_id': kullaniciId,
        'islem_turu': 'RESMI_PDF_CIKTI',
        'islem_tutari': ucret,
        'karargah_payi': ucret, // PDF hizmeti doğrudan Karargaha aittir (%100)
        'tarih': FieldValue.serverTimestamp(),
      });

      // 3. Raporun kendi içine "PDF Alındı" mührü vur
      DocumentReference raporRef = _db.collection('ekspertiz_raporlari').doc(raporId);
      batch.update(raporRef, {
        'pdf_satildi': true,
        'son_pdf_talep_tarihi': FieldValue.serverTimestamp(),
      });

      // 4. Sistem Loglarına İşle
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'PDF_SATISI',
        'islem_detayi': '$kullaniciId kullanıcısı, $raporId sicili için ₺$ucret ödeyerek PDF aldı.',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit(); // Füzeleri ateşle!

      developer.log("✅ GÖREV TAMAM: PDF ödemesi alındı ve oluşturma emri Karargaha iletildi.");

    } catch (e) {
      developer.log("🚨 AĞ ÇÖKTÜ: PDF talebi ve ödeme başarısız!", error: e);
      throw Exception("SİBER HATA: Ödeme alınamadı, PDF oluşturma durduruldu.");
    }
  }
}