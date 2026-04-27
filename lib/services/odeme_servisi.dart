import 'dart:developer' as developer;
import 'core_database_service.dart'; // 🚀 MAKET YIKILDI: Karargah havuzu bağlantısı aktif!

/// 🛡️ KUANTUM ÖDEME VE TAHSİLAT MOTORU (OdemeServisi)
/// Müşteri kaporalarını Kuantum Havuzuna kilitler ve caydırıcı siber yargı uyarılarını yönetir.
class OdemeServisi {

  // ── 💰 SİBER KAPORA VE HAVUZ PROTOKOLÜ (GERÇEK BAĞLANTI) ─────────────────
  /// Müşteriden kaporayı otonom olarak alır, Karargah kilitlerine alır ve oranları hesaplar.
  Future<void> kaporaAl({
    required String musteriId,
    required String ustaId,
    required double tutar,
  }) async {
    try {
      if (tutar <= 0) {
        throw Exception("SİBER İHLAL: Kapora tutarı sıfır veya negatif olamaz!");
      }

      developer.log("SİBER FİNANS: ₺$tutar tutarındaki kapora OtoDNA Kuantum Havuzuna kilitleniyor...");

      // ⚖️ KARARGAH YARGISI (Otonom Ceza Paylaştırma):
      // Tutar ne olursa olsun, randevu ihlalinde bedel yarı yarıya (%50) bölünür.
      double cezaPayi = tutar / 2;

      // SİBER UYARI MEKANİZMASI
      developer.log("SİBER YARGI (MÜŞTERİ BİLDİRİMİ): Randevuya gelmemeniz durumunda siber kaporanızı kaybedersiniz.");
      developer.log("İSTİHBARAT: İhlal durumunda kaporanın ₺$cezaPayi kadarı Ustaya, ₺$cezaPayi kadarı Karargah (OtoDNA) sistemine kalacaktır.");

      // 🚀 GERÇEK VERİTABANI ATEŞLEMESİ
      // Yorum satırları imha edildi, doğrudan Atomik FirestoreServis Kalkanı tetikleniyor!
      await CoreDatabaseService().kaporaKaydet(musteriId, ustaId, tutar: tutar);

      developer.log("SİBER ONAY: Kapora tahsilatı ve havuz kilitleme işlemi kusursuz tamamlandı.");

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Ödeme havuzuna ulaşılamadı!", error: e);
      throw Exception("SİSTEMSEL HATA: Kapora işlemi mühürlenemedi. Lütfen finans ağını kontrol edin.");
    }
  }
}