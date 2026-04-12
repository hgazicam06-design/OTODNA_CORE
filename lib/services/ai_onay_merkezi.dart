import 'package:cloud_firestore/cloud_firestore.dart';

class AiOnayMerkezi {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ===========================================================================
  // 🤖 1. SİBER YAPAY ZEKA: BEYAN VE FABRİKA VERİSİ ÇARPIŞTIRMASI
  // ===========================================================================
  Future<Map<String, dynamic>> onayaHazirla(String saseNo, Map<String, dynamic> userEntry) async {
    try {
      // 1. Kuantum Ağından Fabrika Verisini Çek (Global Hub Simülasyonu)
      // İleride buraya gerçek bir şase sorgulama API'si (Örn: GlobalHub.getSpecs) bağlanacak.
      Map<String, dynamic> hubVerisi = {
        "motor_kodu": "K9K", // Temsili doğru veri
        "renk": "Gümüş Gri",
        "kasa_tipi": "Hatchback"
      };

      bool uyumsuzlukVarMi = false;
      String aiNotu = "KARARGAH AI ONAYI: Fabrika verilerine göre motor kodu ve şase uyumlu. Usta, fiziksel işlem öncesi sadece şase kaynaklarını gözle kontrol etmelidir.";

      // 2. Siber İstihbarat Analizi: Kullanıcı beyanı ile fabrika verisi eşleşiyor mu?
      if (userEntry['motor_kodu'] != hubVerisi['motor_kodu']) {
        uyumsuzlukVarMi = true;
        aiNotu = "SİBER İHLAL TESPİTİ: Kullanıcı beyanındaki motor kodu (${userEntry['motor_kodu']}) ile fabrika verisi (${hubVerisi['motor_kodu']}) UYUŞMUYOR! Usta, motor bloğunu ve ruhsatı kesinlikle fiziksel olarak incelemelidir.";
      }

      // 3. ATOMİK MÜHÜR (WriteBatch): Analiz Raporunu Firebase'e Zırhlı Kaydet
      WriteBatch batch = _db.batch();
      DocumentReference analizRef = _db.collection('ai_analiz_raporlari').doc();

      batch.set(analizRef, {
        'sase_no': saseNo,
        'kullanici_beyani': userEntry,
        'fabrika_verisi': hubVerisi,
        'ai_notu': aiNotu,
        'risk_durumu': uyumsuzlukVarMi ? 'YÜKSEK RİSK (KIRMIZI)' : 'GÜVENLİ (YEŞİL)',
        'durum': 'USTA_ONAYI_BEKLIYOR',
        'olusturulma_tarihi': FieldValue.serverTimestamp(),
      });

      await batch.commit(); // Zırhlı Paketi Fırlat!

      // 4. Analiz sonucunu arayüze döndür
      return {
        "analiz_id": analizRef.id,
        "beyan": userEntry,
        "ai_notu": aiNotu,
        "risk_durumu": uyumsuzlukVarMi ? 'YÜKSEK RİSK' : 'GÜVENLİ',
        "onay_bekleyen": true
      };

    } catch (e) {
      throw Exception("SİBER AI MOTORU ÇÖKTÜ: Analiz işlemi tamamlanamadı! Hata: $e");
    }
  }

  // ===========================================================================
  // 🛠️ 2. KUANTUM MÜHRÜ: USTANIN HIZLI ONAYI (Dijital Referans Protokolü)
  // ===========================================================================
  Future<void> ustaHizliOnay({
    required String analizId,
    required String ustaId,
    required bool onaylandi,
    String? ekstraNot
  }) async {
    try {
      String guncelDurum = onaylandi ? "USTA_TARAFINDAN_ONAYLANDI" : "REDDEDILDI_FIZIKSEL_KONTROL_SART";

      // ATOMİK MÜHÜR (WriteBatch): Firebase'deki o kaydı bul ve Zırhlı Güncelle!
      WriteBatch batch = _db.batch();
      DocumentReference docRef = _db.collection('ai_analiz_raporlari').doc(analizId);

      batch.update(docRef, {
        'durum': guncelDurum,
        'onaylayan_usta_id': ustaId,
        'usta_notu': ekstraNot ?? (onaylandi ? "Usta gözle teyit etti, siber mühür vuruldu." : "Fiziksel uyuşmazlık tespit edildi, işlem reddedildi."),
        'onay_tarihi': FieldValue.serverTimestamp(),
        'dijital_referans_muhru': onaylandi, // true/false olarak Boolean tutulması daha sağlıklıdır
      });

      await batch.commit(); // Mührü Ağ'a İşle!

      // SİBER NOT: İleride Blockchain altyapısına geçildiğinde aşağıdaki kod aktif edilecek:
      // if(onaylandi) await BlockchainService.muhurle(analizId, "USTA_TEYIDI");

    } catch (e) {
      throw Exception("AĞ ÇÖKTÜ: Usta onayı veritabanına mühürlenemedi! Hata: $e");
    }
  }
}