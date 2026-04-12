import 'dart:developer' as developer;
import 'global_yonetici.dart'; // Para birimi istihbaratını buradan çekecek

/// 🛡️ KUANTUM YERELLEŞTİRME VE FORMAT MOTORU (LocalizationService)
/// Karargahın dil, para birimi ve tarih gösterim standartlarını belirler.
class LocalizationService {

  // ── 💰 SİBER FİNANS FORMATLAYICI ──────────────────────────────────────────
  /// Tutarları aktif ülkenin para birimine (₺, €, £) göre Karargah formatına sokar.
  static String fiyatFormatla(double tutar) {
    try {
      // İstihbaratı Kuantum Yöneticisinden çek! (Veri tekrarı yok)
      String aktifBirim = GlobalYonetici.aktifParaBirimi;

      // Örn: 1500.50 ₺
      return "${tutar.toStringAsFixed(2)} $aktifBirim";
    } catch (e) {
      developer.log("SİBER FORMAT HATASI: Finansal veri maskelenemedi!", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ: Para birimsiz yalan yanlış rakam göstermek yerine hata fırlat!
      throw Exception("FİNANSAL FORMAT HATASI: Tutar siber ekrana yansıtılamadı!");
    }
  }

  // ── 📅 KRONOLOJİK SİBER FORMAT (TARİH) ───────────────────────────────────
  /// Veritabanından gelen soğuk tarihleri (2026-03-26) Karargahın okuyabileceği net Türkçe formata çevirir.
  static String tarihFormatla(DateTime tarih) {
    try {
      // İleride 'intl' paketi eklenebilir, şimdilik otonom Karargah zırhı devrede:
      List<String> aylar = [
        "", "Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran",
        "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"
      ];

      String gun = tarih.day.toString().padLeft(2, '0');
      String ay = aylar[tarih.month];
      String yil = tarih.year.toString();

      // Örn: 26 Mart 2026
      return "$gun $ay $yil";
    } catch (e) {
      developer.log("SİBER ZAMAN HATASI: Tarih verisi çözülemedi!", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ: "Bilinmeyen Tarih" yalanı yerine sistemi uyar!
      throw Exception("ZAMAN ÇİZELGESİ HATASI: Tarih verisi Karargah standartlarına çevrilemedi!");
    }
  }

// SİBER NOT: 'globalAyaraGec' fonksiyonu imha edildi!
// Sistemin ülkesini değiştirmek için artık mimari olarak sadece
// GlobalYonetici.operasyonUlkesiniDegistir() komutu kullanılmalıdır.
}