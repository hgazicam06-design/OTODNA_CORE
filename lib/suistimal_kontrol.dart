// lib/core/suistimal_kontrol.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM SUİSTİMAL VE GARANTİ MOTORU (SiberSuistimalKontrol)
/// Müşterinin kullanım verilerini (GPS) analiz eder, ustayı ve Karargahı haksız iadelere karşı korur.
class SiberSuistimalKontrol {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 📡 GPS VE KULLANIM ŞARTLARI ANALİZİ ──
  /// Aracın Karargah loglarındaki son GPS verilerini tarayarak zorlu arazi kullanımını tespit eder.
  static Future<String> siberYolSartiAnalizi(String saseNo) async {
    developer.log("📡 SİBER İSTİHBARAT: $saseNo şaseli aracın GPS logları analiz ediliyor...");

    try {
      // 1. Aracın son 30 günlük GPS loglarını Firebase'den çek
      QuerySnapshot loglar = await _db.collection('arac_gps_loglari')
          .where('sase_no', isEqualTo: saseNo)
          .orderBy('zaman_damgasi', descending: true)
          .limit(50)
          .get();

      if (loglar.docs.isEmpty) {
        return "SİBER ONAY: Karargah loglarında anormal bir seyir tespit edilemedi. Normal Kullanım.";
      }

      int zorluAraziIhlali = 0;

      for (var doc in loglar.docs) {
        var data = doc.data() as Map<String, dynamic>;
        // SİBER NOT: Gerçek GPS algoritması enlem/boylamı dağlık bölge haritasıyla eşleştirir.
        // Burada Karargah simülasyon mantığı kullanıyoruz.
        if (data['arazi_vitesi_aktif'] == true || data['hiz_limiti_asimi'] > 3 || data['zorlu_arazi_kodu'] == true) {
          zorluAraziIhlali++;
        }
      }

      // 🛡️ BAYİ KORUMA KALKANI TETİKLENİYOR
      if (zorluAraziIhlali > 2) {
        developer.log("🚨 SUİSTİMAL TESPİTİ: Araç zorlu koşullarda limitleri zorlamış!");
        return "⚠️ SİBER İHLAL TESPİTİ: Zorlu arazi ve limit dışı kullanım logları bulundu. Arıza kuvvetle muhtemel **KULLANICI HATASI** kaynaklıdır. Usta veya parça kusuru şüphesi düşüktür.";
      }

      return "SİBER ONAY: Normal Şehir İçi Kullanım. Kullanıcı hatası tespit edilmedi.";

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: GPS logları okunamadı!", error: e);
      return "İSTİHBARAT EKSİK: GPS verilerine ulaşılamadı, manuel ekspertiz gereklidir.";
    }
  }

  // ── 📜 ÜRÜN BAZLI GARANTİ SORGULAMASI ──
  /// İlgili ürünün Karargah veritabanındaki garanti şartlarını çeker.
  static Future<Map<String, dynamic>> garantiKosuluGetir(String urunBarkodu) async {
    developer.log("📜 GARANTİ SORGUSU: $urunBarkodu kodlu ürün mühürleri taranıyor...");

    try {
      DocumentSnapshot urunDoc = await _db.collection('market_urunleri').doc(urunBarkodu).get();

      if (!urunDoc.exists) {
        return {
          "durum": "BULUNAMADI",
          "mesaj": "Bu ürüne ait Karargah garanti mührü bulunamadı.",
        };
      }

      var data = urunDoc.data() as Map<String, dynamic>;

      // Varsayılan Karargah Garanti Şartları (Eğer ürüne özel girilmemişse)
      String garantiSuresi = data['garanti_suresi'] ?? "1 Yıl / 20.000 KM";
      String ozelSart = data['garanti_sarti'] ?? "Zorlu arazi, yarış kullanımı veya yetkisiz müdahale garantiyi anında BOZAR.";
      bool garantiliMi = data['garantili_mi'] ?? true;

      if (!garantiliMi) {
        return {
          "durum": "GARANTISIZ",
          "mesaj": "Bu ürün 'Sarf Malzeme' statüsündedir ve Karargah garantisi KAPSAMINDA DEĞİLDİR.",
        };
      }

      return {
        "durum": "GARANTILI",
        "mesaj": "SİBER MÜHÜRLÜ: $garantiSuresi. $ozelSart",
      };

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Garanti verisi okunamadı!", error: e);
      return {
        "durum": "HATA",
        "mesaj": "Garanti sorgusu yapılamadı, Karargah ile iletişime geçin.",
      };
    }
  }
}