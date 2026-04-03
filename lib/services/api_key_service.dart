import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM KASA: API anahtarlarını donanım seviyesinde (Keystore/Keychain) şifreler.
/// Kodun içinde hiçbir açık metin (plaintext) anahtar barınamaz!
class ApiKeyService {
  // 🌑 SİBER ZIRH KONFİGÜRASYONU
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock), // Apple Kalkanı
  );

  static const _geminiKey = 'gemini_api_key';

  // ── Gemini API Key İstihbarat Protokolleri ────────────────────────────────────────

  /// Anahtarı Kuantum Kasasına Mühürler
  static Future<void> geminiKeyKaydet(String key) async {
    try {
      await _storage.write(key: _geminiKey, value: key.trim());
      developer.log("SİBER BİLGİ: Gemini Key başarıyla kasaya mühürlendi.");
    } catch (e) {
      developer.log("SİBER İHLAL: Key kasaya yazılamadı!", error: e);
    }
  }

  /// Anahtarı Kasadan Çıkarır (Sadece yetkili anlarda)
  static Future<String?> geminiKeyOku() async {
    try {
      return await _storage.read(key: _geminiKey);
    } catch (e) {
      developer.log("SİBER İHLAL: Key kasadan okunamadı!", error: e);
      return null;
    }
  }

  /// Anahtarı Sistemden Tamamen İmha Eder
  static Future<void> geminiKeySil() async {
    try {
      await _storage.delete(key: _geminiKey);
      developer.log("SİBER BİLGİ: Gemini Key kasadan imha edildi.");
    } catch (e) {
      developer.log("SİBER İHLAL: Key imha edilemedi!", error: e);
    }
  }

  /// Kasada Anahtar Var mı Radarı
  static Future<bool> geminiKeyVarMi() async {
    final k = await geminiKeyOku();
    return k != null && k.isNotEmpty;
  }
}