import 'dart:developer' as developer;
import 'city_service.dart'; // Şehir verilerini asıl kaynağından çekmek için

/// 🛡️ KÜRESEL KARARGAH YÖNETİCİSİ (GlobalYonetici)
/// Sistemin operasyon ülkesini, para birimini ve global ayarlarını kontrol eder.
class GlobalYonetici {
  // 🌍 SİBER OPERASYON MERKEZİ (Varsayılan olarak Ankara/Türkiye ayarlıdır)
  static String _aktifUlke = "TÜRKİYE";

  // 💰 KÜRESEL FİNANS BİRİMLERİ (Kuantum Para Birimi Sözlüğü)
  static Map<String, String> _paraBirimleri = {
    "TÜRKİYE": "₺",
    "ALMANYA": "€",
    "İNGİLTERE": "£",
    "ABD": "\$",
  };

  // ── ⚙️ SİBER KONFİGÜRASYON VE ERİŞİM PROTOKOLLERİ ──────────────────────────

  /// Karargahın şu an hangi ülkede operasyon yürüttüğünü söyler
  static String get aktifUlke => _aktifUlke;

  /// Bulunulan ülkeye göre otonom olarak para birimini (₺, €, £) verir
  static String get aktifParaBirimi => _paraBirimleri[_aktifUlke] ?? "₺";

  /// Karargahın operasyon ülkesini değiştirir ve sistemi otonom günceller.
  static void operasyonUlkesiniDegistir(String yeniUlke) {
    String formatliUlke = yeniUlke.trim().toUpperCase();

    if (_paraBirimleri.containsKey(formatliUlke)) {
      _aktifUlke = formatliUlke;
      developer.log("SİBER BİLGİ: Karargah operasyon merkezi '$formatliUlke' olarak güncellendi. Para Birimi: $aktifParaBirimi");
    } else {
      developer.log("SİBER İHLAL: '$formatliUlke' ağı henüz Kuantum Radarına tanımlanmadı! İşlem reddedildi.");
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ: UI'a (Arayüze) Kırmızı Alarm Fırlat!
      throw Exception("KÜRESEL AĞ HATASI: Desteklenmeyen operasyon bölgesi ($formatliUlke)!");
    }
  }

  // ── 🗺️ KÜRESEL HARİTA İSTİHBARATI (DRY PRENSİBİ KORUMASI) ────────────────

  /// Aktif ülkenin şehirlerini, verinin asıl sahibi olan CityService'den çeker.
  /// Kendi içinde şehir listesi tutmaz, böylece veri tekrarı (sızıntı) engellenir.
  static List<String> mevcutSehirleriGetir() {
    developer.log("SİBER İSTİHBARAT: $_aktifUlke için şehir radarı tetiklendi.");
    return CityService.tumIlleriGetir(ulke: _aktifUlke);
  }

  /// İstihbarat: Bir şehrin hangi bölgede olduğunu CityService üzerinden tespit eder.
  static String bolgeyiGetir(String sehir) {
    developer.log("SİBER RADAR: ${sehir.toUpperCase()} şehri için bölge taranıyor...");
    // 🚀 MAKET YOK! Doğrudan CityService üzerinden Tersine İstihbarat araması yapılır.
    return CityService.sehirdenBolgeBul(sehir, ulke: _aktifUlke);
  }
}