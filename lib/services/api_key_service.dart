import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM KASA: OtoDNA'nın Kalbi (API Anahtarları)
/// Anahtarlar cihazın donanım seviyesinde (Keystore/Keychain) AES-256 ile şifrelenir.
/// ÜNAL BEY DİKKAT: Anahtarları hiçbir dosyaya açık (plaintext) yazmayın!
/// Sadece uygulamanın ilk kurulumunda (veya yönetici panelinde) bu servisteki 
/// `siberKalkanKurulum` metodunu tetikleyerek anahtarları cihaza mühürleyin.
class ApiKeyService {
  // 🌑 SİBER ZIRH KONFİGÜRASYONU
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock), // Apple Kalkanı
  );

  // KASA MÜHÜR İSİMLERİ
  static const String _geminiKeyName = 'kuantum_gemini_key';
  static const String _mapsKeyName = 'kuantum_maps_key';
  static const String _saseKeyName = 'kuantum_sase_key';

  // ── SİBER KALKAN KURULUMU (TOPLU MÜHÜRLEME) ─────────────────────────────
  
  /// Geliştirici (Ünal Bey) bu metodu sadece 1 kez (Admin Panelinden veya 
  /// gizli bir menüden) çağırarak anahtarları cihaza/sunucuya mühürlemelidir.
  static Future<void> siberKalkanKurulum({
    required String geminiKey,
    required String mapsKey,
    required String saseKey,
  }) async {
    developer.log("🛡️ SİBER BİLGİ: Kuantum Kasa Toplu Mühürleme Başlatıldı...");
    await geminiKeyKaydet(geminiKey);
    await mapsKeyKaydet(mapsKey);
    await saseKeyKaydet(saseKey);
    developer.log("🛡️ SİBER BİLGİ: Tüm motor anahtarları donanıma kilitlendi.");
  }

  // ── 1. Gemini API (Akıllı Asistan) İstihbarat Protokolleri ──────────────

  static Future<void> geminiKeyKaydet(String key) async {
    try {
      if (key.trim().isEmpty) return;
      await _storage.write(key: _geminiKeyName, value: key.trim());
      developer.log("SİBER BİLGİ: Gemini Key Kuantum Kasasına mühürlendi.");
    } catch (e) {
      developer.log("SİBER İHLAL: Gemini Key yazılamadı! $e", error: e);
    }
  }

  static Future<String?> geminiKeyOku() async {
    try {
      return await _storage.read(key: _geminiKeyName);
    } catch (e) {
      developer.log("SİBER İHLAL: Gemini Key okunamadı! $e", error: e);
      return null;
    }
  }

  static Future<void> geminiKeySil() async {
    await _storage.delete(key: _geminiKeyName);
  }

  static Future<bool> geminiKeyVarMi() async {
    final k = await geminiKeyOku();
    return k != null && k.isNotEmpty;
  }

  // ── 2. Google Maps API (Siber Navigasyon) İstihbarat Protokolleri ───────

  static Future<void> mapsKeyKaydet(String key) async {
    try {
      if (key.trim().isEmpty) return;
      await _storage.write(key: _mapsKeyName, value: key.trim());
      developer.log("SİBER BİLGİ: Google Maps Key Kuantum Kasasına mühürlendi.");
    } catch (e) {
      developer.log("SİBER İHLAL: Maps Key yazılamadı! $e", error: e);
    }
  }

  static Future<String?> mapsKeyOku() async {
    try {
      return await _storage.read(key: _mapsKeyName);
    } catch (e) {
      developer.log("SİBER İHLAL: Maps Key okunamadı! $e", error: e);
      return null;
    }
  }

  static Future<void> mapsKeySil() async {
    await _storage.delete(key: _mapsKeyName);
  }

  static Future<bool> mapsKeyVarMi() async {
    final k = await mapsKeyOku();
    return k != null && k.isNotEmpty;
  }

  // ── 3. Şase Sorgulama API (OE Hub / Tramer) İstihbarat Protokolleri ─────

  static Future<void> saseKeyKaydet(String key) async {
    try {
      if (key.trim().isEmpty) return;
      await _storage.write(key: _saseKeyName, value: key.trim());
      developer.log("SİBER BİLGİ: Şase Sorgulama Key Kuantum Kasasına mühürlendi.");
    } catch (e) {
      developer.log("SİBER İHLAL: Şase Key yazılamadı! $e", error: e);
    }
  }

  static Future<String?> saseKeyOku() async {
    try {
      return await _storage.read(key: _saseKeyName);
    } catch (e) {
      developer.log("SİBER İHLAL: Şase Key okunamadı! $e", error: e);
      return null;
    }
  }

  static Future<void> saseKeySil() async {
    await _storage.delete(key: _saseKeyName);
  }

  static Future<bool> saseKeyVarMi() async {
    final k = await saseKeyOku();
    return k != null && k.isNotEmpty;
  }
}
