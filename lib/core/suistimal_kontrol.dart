// lib/core/suistimal_kontrol.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM ADALET VE HAKEM MOTORU (SiberSuistimalKontrol) - V2 (Yol ve Yıpranma Analizi)
/// Kullanıcıya "Araç Sağlık Asistanı" gibi görünür, arkada Karargah için yol tiplerini (Otoyol, Arazi vb.)
/// oranlayıp Yıpranma Skoru (%) çıkararak garanti kararı verir.
class SiberSuistimalKontrol {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── ⚖️ ŞEFFAF GARANTİ VE OTONOM YIPRANMA ANALİZİ ──
  static Future<Map<String, dynamic>> kapsamliHataAnaliziYAP({
    required String saseNo,
    required String oncekiIslemId, // Ustanın parçayı taktığı orijinal işlem
  }) async {
    developer.log("📡 SİBER HAKEM: $saseNo şaseli araç için Yol/Yıpranma Analizi başlatıldı...");

    try {
      // 1. Önceki İşlem (Montaj) Verisini Çek
      DocumentSnapshot islemDoc = await _db.collection('islem_gecmisi').doc(oncekiIslemId).get();
      if (!islemDoc.exists) {
        return _sonucUret("BİLİNMİYOR", "İşlem geçmişi bulunamadı. Siber analiz yapılamıyor.", true);
      }

      var islemVerisi = islemDoc.data() as Map<String, dynamic>;
      Timestamp islemTarihi = islemVerisi['tarih'] ?? FieldValue.serverTimestamp();
      int islemKm = islemVerisi['kilometre'] ?? 0;
      int garantiKmLimiti = islemVerisi['garanti_km_limiti'] ?? 20000;
      int garantiAyLimiti = islemVerisi['garanti_ay_limiti'] ?? 12;

      // 2. Aracın Güncel Verisini ve Yıpranma Matrisini Çek
      DocumentSnapshot aracDoc = await _db.collection('vehicles').doc(saseNo).get();
      var aracVerisi = aracDoc.data() as Map<String, dynamic>;
      int guncelKm = aracVerisi['guncel_km'] ?? islemKm;

      // 🔥 SİBER YOL ANALİZİ: Kullanıcının sürüş profili (Otonom arka plan verisi)
      // Karargah bu veriyi arka planda GPS hız/sarsıntı analizinden besler
      double otoyolOrani = (aracVerisi['yol_otoyol_yuzdesi'] ?? 60.0).toDouble(); // %60
      double sehirIciOrani = (aracVerisi['yol_sehir_ici_yuzdesi'] ?? 30.0).toDouble(); // %30
      double koyYoluOrani = (aracVerisi['yol_koy_yuzdesi'] ?? 8.0).toDouble(); // %8
      double araziOrani = (aracVerisi['yol_arazi_yuzdesi'] ?? 2.0).toDouble(); // %2

      // 🧠 Kuantum Yıpranma Formülü (Katsayılar: Otoyol=0.5x, Şehir=1x, Köy=2.5x, Arazi=5x)
      double yipranmaSkoru = (otoyolOrani * 0.5) + (sehirIciOrani * 1.0) + (koyYoluOrani * 2.5) + (araziOrani * 5.0);
      double yipranmaYuzdesi = (yipranmaSkoru / 100).clamp(0.0, 1.0) * 100; // 0-100 arası normalize edilir

      developer.log("📊 SİBER YIPRANMA: Araç Yıpranma Oranı: %${yipranmaYuzdesi.toStringAsFixed(1)} (Arazi Kullanımı: %$araziOrani)");

      int gecenGun = DateTime.now().difference(islemTarihi.toDate()).inDays;
      int yapilanKm = guncelKm - islemKm;

      // ── 🛑 SENARYO 1: GARANTİ SÜRESİ/KM DOLMUŞ ──
      if (gecenGun > (garantiAyLimiti * 30) || yapilanKm > garantiKmLimiti) {
        await _karaKutuyaMuhurle('GARANTI_SURESI_DOLDU', saseNo, '$oncekiIslemId numaralı işlem için süre/KM limiti aşıldı.');
        return _sonucUret("GARANTI_DISI", "⚠️ BİLGİLENDİRME: Bu parçanın OtoDNA Garanti süresi veya kilometre limiti dolmuştur. İşlem ücrete tabidir.", true);
      }

      // ── 🛑 SENARYO 2: AĞIR YIPRANMA / ARAZİ SUİSTİMALİ (KULLANICI HATASI) ──
      // Eğer araç %20'den fazla ağır araziye girmişse VEYA genel yıpranma %80'in üzerindeyse ve parça bozulduysa:
      if (araziOrani >= 20.0 || yipranmaYuzdesi >= 80.0) {
        await _karaKutuyaMuhurle('GARANTI_IPTALI_SUISTIMAL', saseNo, 'Ağır Yıpranma İhlali: Yıpranma Oranı %${yipranmaYuzdesi.toStringAsFixed(1)}. Usta korumaya alındı.');
        return _sonucUret(
            "KULLANICI_HATASI",
            "⚠️ SİBER UYARI: Aracınızın yol analiz raporunda 'Yıpranma Oranı' %${yipranmaYuzdesi.toStringAsFixed(1)} (Ağır Koşul/Arazi) olarak hesaplanmıştır. Kötü yol şartlarından kaynaklı arızalar garanti kapsamı dışındadır.",
            true
        );
      }

      // ── 🛑 SENARYO 3: USTA / MONTAJ HATASI ŞÜPHESİ (ERKEN ÇÖKÜŞ) ──
      // Yıpranma normal ama parça çok erken bozuldu (15 gün veya 1000 KM altı)
      if (gecenGun < 15 || yapilanKm < 1000) {
        await _karaKutuyaMuhurle('USTA_MONTAJ_HATASI_SUPHESI', saseNo, '$oncekiIslemId işleminden sadece $gecenGun gün sonra arıza! Yıpranma: Normal (%${yipranmaYuzdesi.toStringAsFixed(1)}).');
        return _sonucUret(
            "USTA_HATASI_SUPHESI",
            "🔍 SİBER UYARI: Yol kullanım profiliniz (Yıpranma %${yipranmaYuzdesi.toStringAsFixed(1)}) stabil olmasına rağmen erken arıza tespit edildi. Montaj hatası incelemesi için Karargah bildirim gönderdi.",
            true
        );
      }

      // ── ✅ SENARYO 4: NORMAL GARANTİ TALEBİ (ONAY) ──
      await _karaKutuyaMuhurle('GARANTI_TALEBI_ACILDI', saseNo, 'Normal arıza, stabil yıpranma (%${yipranmaYuzdesi.toStringAsFixed(1)}). $oncekiIslemId için Karargah onayında.');
      return _sonucUret(
          "GARANTI_INCELEMESI",
          "✅ SİBER ONAY: Yıpranma oranınız %${yipranmaYuzdesi.toStringAsFixed(1)} (Normal). Aracınız garanti içindedir. Tespit için servise girin.",
          false
      );

    } catch (e) {
      developer.log("🚨 AĞ ÇÖKTÜ: Yıpranma Analizi yapılamadı!", error: e);
      return _sonucUret("HATA", "SİBER KESİNTİ: Karargah ile bağlantı kurulamadı.", false);
    }
  }

  // ── 📦 YARDIMCI MODÜLLER ──

  static Map<String, dynamic> _sonucUret(String durum, String mesaj, bool ihlalVeyaInceleme) {
    return {"durum": durum, "mesaj": mesaj, "ihlalli_mi": ihlalVeyaInceleme};
  }

  static Future<void> _karaKutuyaMuhurle(String islemTuru, String saseNo, String detay) async {
    try {
      await _db.collection('sistem_loglari').add({
        'islem_turu': islemTuru,
        'sase_no': saseNo,
        'islem_detayi': detay,
        'tarih': FieldValue.serverTimestamp(),
        'otonom_kayit': true,
      });
    } catch (e) {
      developer.log("🚨 KARA KUTU ÇÖKTÜ: Log yazılamadı!", error: e);
    }
  }
}