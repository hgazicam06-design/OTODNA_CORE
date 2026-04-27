import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

// ============================================================================
// DOSYA AMACI: 
// Bu servis, OtoDNA sisteminin Kurumsal Loglama ve Denetim (Audit) Motorudur.
// Tüm finansal, güvenlik, bayi ve AI işlemlerini şeffaf bir şekilde
// Firebase veritabanına mühürler. Sistemin kara kutusudur (Blackbox).
// Eski "Siber İstihbarat Log Motoru"nun kurumsal versiyonudur.
// ============================================================================

class CorporateAuditLogger {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── TEMEL DENETİM GÜNLÜĞÜ (AUDIT LOG) METODU ──────────────────────────
  /// Kurumsal ağda gerçekleşen her önemli aksiyonu veritabanına kaydeder.
  static Future<void> logAction({
    required String category, // FINANS, GUVENLIK, KULLANICI, BAYI, AI_SISTEMI, ENTEGRASYON vb.
    required String actionTitle,
    required String details,
    String? actorId, // İşlemi yapan kişinin ID'si
    String? actorName, // İşlemi yapan kişinin adı veya bayi adı
  }) async {
    try {
      await _db.collection('sistem_loglari').add({
        'kategori': category,
        'islem_basligi': actionTitle,
        'detay': details,
        'fail_id': actorId ?? 'SİSTEM_OTONOM',
        'fail_adi': actorName ?? 'KARARGAH_AI',
        'tarih': FieldValue.serverTimestamp(),
      });
      // WriteBatch veya Asenkron background task olarak bırakılır.
    } catch (e) {
      developer.log("OTODNA KRİTİK HATA: Denetim (Audit) logu yazılamadı -> $e");
    }
  }

  // ── HAZIR KURUMSAL ŞABLONLAR ──────────────────────────────────────────
  static void logFinancial(String title, String details, {String? actorId, String? actorName}) {
    logAction(category: 'FINANS', actionTitle: title, details: details, actorId: actorId, actorName: actorName);
  }

  static void logSecurity(String title, String details, {String? actorId, String? actorName}) {
    logAction(category: 'GUVENLIK', actionTitle: title, details: details, actorId: actorId, actorName: actorName);
  }

  static void logUserAction(String title, String details, {String? actorId, String? actorName}) {
    logAction(category: 'KULLANICI', actionTitle: title, details: details, actorId: actorId, actorName: actorName);
  }

  static void logSystem(String title, String details) {
    logAction(category: 'AI_SISTEMI', actionTitle: title, details: details);
  }
}
