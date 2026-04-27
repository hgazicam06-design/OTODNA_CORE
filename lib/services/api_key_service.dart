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

  static const String _geminiKey = 'gemini_api_key';

  // ── Gemini API Key İstihbarat Protokolleri ────────────────────────────────────────

  /// Anahtarı Kuantum Kasasına Mühürler
  static Future<void> geminiKeyKaydet(String key) async {
    try {
      if (key.trim().isEmpty) {
        developer.log("SİBER İHLAL: Boş anahtar kasaya mühürlenemez!");
        return;
      }
      await _storage.write(key: _geminiKey, value: key.trim());
      developer.log("SİBER BİLGİ: Gemini Key başarıyla Kuantum Kasasına mühürlendi.");
    } catch (e) {
      developer.log("SİBER İHLAL: Key kasaya yazılamadı! Ağ hatası: $e", error: e);
    }
  }

  /// Anahtarı Kasadan Çıkarır (Sadece yetkili anlarda)
  static Future<String?> geminiKeyOku() async {
    try {
      final key = await _storage.read(key: _geminiKey);
      if (key == null || key.isEmpty) {
        developer.log("SİBER BİLGİ: Kasa boş, mühürlü anahtar bulunamadı.");
        return null;
      }
      return key;
    } catch (e) {
      developer.log("SİBER İHLAL: Key kasadan okunamadı! Kripto hatası: $e", error: e);
      return null;
    }
  }

  /// Anahtarı Sistemden Tamamen İmha Eder
  static Future<void> geminiKeySil() async {
    try {
      await _storage.delete(key: _geminiKey);
      developer.log("SİBER BİLGİ: Gemini Key kasadan tamamen imha edildi.");
    } catch (e) {
      developer.log("SİBER İHLAL: Key imha edilemedi! Hata: $e", error: e);
    }
  }

  /// Kasada Anahtar Var mı Radarı
  static Future<bool> geminiKeyVarMi() async {
    final k = await geminiKeyOku();
    return k != null && k.isNotEmpty;
  }
}
