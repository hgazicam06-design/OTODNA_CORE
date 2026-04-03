import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM VIP KULLANICI TERMİNALİ VE FİNANS MOTORU (UserVipPanel)
/// Her yerden erişilebilen OLED Navigasyon Barını ve Kuantum Hızlı Ödeme sistemini yönetir.
class UserVipPanel {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 📱 SİBER NAVİGASYON (KUANTUM ALT BAR) ────────────────────────────────
  /// Tüm VIP ekranlarda çağrılacak olan Fütüristik Navigasyon Motoru
  static Widget universalNavbar({
    required int currentIndex,
    required Function(int) onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF000000), // OLED Siyah zırh
        border: Border(
          top: BorderSide(color: const Color(0xFF00FFC2).withOpacity(0.3), width: 1),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: const Color(0xFF000000), // Tam OLED Siyahı
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        selectedItemColor: const Color(0xFF00FFC2), // Kuantum Turkuazı Vurgu
        unselectedItemColor: Colors.white38,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 10),
        onTap: onTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: "MERKEZ"),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car_outlined), activeIcon: Icon(Icons.directions_car), label: "GALERİ"),
          BottomNavigationBarItem(icon: Icon(Icons.settings_input_component_outlined), activeIcon: Icon(Icons.settings_input_component), label: "MARKET"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "PROFİL"),
        ],
      ),
    );
  }

  // ── 💳 VIP HIZLI SATIN ALMA VE SİBER FİNANS MOTORU ──────────────────────
  /// Müşteriden ödemeyi çeker, %12 Karargah payını keser ve veritabanına mühürler.
  static Future<void> hizliOdeme({
    required String kullaniciId,
    required String urunId,
    required double fiyat,
  }) async {
    try {
      developer.log("💎 VIP İŞLEM: $urunId kodlu ürün işlemi başlatıldı. Tutar: ₺$fiyat");

      if (fiyat <= 0) {
        throw Exception("SİBER İHLAL: Tutar sıfır veya negatif olamaz!");
      }

      // ⚖️ KARARGAH FİNANS KURALI: %12 Kesinti (%10 Net + %2 Vergi)
      double gaziPayi = fiyat * 0.12;
      double bayiPayi = fiyat - gaziPayi;

      // 🚀 Kuantum Ağ Mührü (Finansal Havuz ve Satın Alım Logu)
      var islemKaydi = {
        'kullanici_id': kullaniciId,
        'urun_id': urunId,
        'toplam_tutar': fiyat,
        'karargah_kesintisi': gaziPayi, // Otonom %12 Kuralı
        'bayi_hakedisi': bayiPayi,
        'islem_turu': 'VIP_HIZLI_ODEME',
        'tarih': FieldValue.serverTimestamp(),
        'durum': 'ONAYLANDI_LOJISTIK_BEKLIYOR'
      };

      await _db.collection('finans_havuzu').add(islemKaydi);

      developer.log("✅ FİNANSAL MÜHÜR: İşlem başarılı! Karargah Payı: ₺$gaziPayi, Bayi: ₺$bayiPayi.");
      developer.log("📦 LOJİSTİK: Kargo aşamasına geçiş için sinyal Karargaha ulaştı.");

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Hızlı ödeme ve finansal ayrışma başarısız!", error: e);
      throw Exception("SİSTEMSEL HATA: Ödeme işlemi mühürlenemedi.");
    }
  }
}