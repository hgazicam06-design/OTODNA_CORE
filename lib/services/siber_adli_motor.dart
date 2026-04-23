import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import '../models/adli_rapor_model.dart';

/// ⚖️ SİBER ADLİ MOTOR (AI BİLİRKİŞİ)
/// Mahkeme düzeyinde raporlar ve AI destekli kusur oranları hesaplar.
class SiberAdliMotor {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 🧠 YAPAY ZEKA KUSUR ANALİZİ (MOCK) ──
  /// Ustanın yüklediği verileri (foto, video, sensör) AI ağına gönderir.
  static Future<AdliRaporModel> aiAnaliziYap({
    required String aracSaseNo,
    required String ustaUid,
    required String tedarikciKodu,
    required String davaTuru,
    required List<String> fotolar,
    required List<String> videolar,
    required List<String> testVerileri,
  }) async {
    developer.log("🤖 SİBER BİLİRKİŞİ: AI Olay Yeri İncelemesi başlatıldı...");
    
    // Gerçek bir sistemde bu veriler Kuantum AI sunucusuna gider.
    // Şimdilik Kuantum Simülasyonu yapıyoruz.
    
    await Future.delayed(const Duration(seconds: 3)); // AI Düşünme Süresi

    bool parcaOrijinalMi = tedarikciKodu.toUpperCase().startsWith("ORG");
    
    String aiHukmu;
    int kusurUsta = 0;
    int kusurParca = 0;
    int kusurKullanici = 0;

    if (parcaOrijinalMi) {
      // Örnek Senaryo 1: Kullanıcı Hatası
      aiHukmu = "SİBER BİLİRKİŞİ (AI) ANALİZİ: Isı haritası ve ECU tork değerleri incelendi. Ustanın montajı (torklama) fabrika standartlarındadır. Ancak sensör verileri, aracın uzun süre hararette ve limitlerin üzerinde kullanıldığını (kullanıcı hatası) göstermektedir.";
      kusurKullanici = 100;
    } else {
      // Örnek Senaryo 2: Parça Hatası
      aiHukmu = "SİBER BİLİRKİŞİ (AI) ANALİZİ: Kırık parça fotoğrafları global veri tabanındaki 10.000+ vaka ile karşılaştırıldı. Kırılma noktası ustanın müdahale alanında değil, parçanın döküm dikişindedir. Metal yorgunluğu ve fabrikasyon üretim hatası tespit edilmiştir.";
      kusurParca = 100;
    }

    developer.log("⚖️ HÜKÜM VERİLDİ: Usta %$kusurUsta | Parça %$kusurParca | Kullanıcı %$kusurKullanici");

    return AdliRaporModel(
      davaTuru: davaTuru,
      aracSaseNo: aracSaseNo,
      ustaUid: ustaUid,
      tedarikciKodu: tedarikciKodu,
      olayTarihi: DateTime.now(),
      montajOncesiFotolar: fotolar,
      montajAniVideolar: videolar,
      testVerileri: testVerileri,
      aiHukmu: aiHukmu,
      kusurOraniUsta: kusurUsta,
      kusurOraniParca: kusurParca,
      kusurOraniKullanici: kusurKullanici,
      yasalUyariOkundu: true, // UI katmanında zorunlu tik atılacak
    );
  }

  // ── 🖨️ ADLİ DOSYA (PDF) MÜHÜRLEME VE KARARGAHA YAZMA ──
  static Future<void> raporuMasaustuneKilitle(AdliRaporModel rapor) async {
    developer.log("🔒 DOSYA KİLİTLENİYOR: Mahkeme dosyası Karargah veri tabanına işleniyor...");
    
    try {
      DocumentReference docRef = _db.collection('adli_dosyalar').doc();
      await docRef.set(rapor.toMap());
      developer.log("✅ BAŞARILI: Adli dosya oluşturuldu. Kasa ID: ${docRef.id}");
      
      // TODO: 'pdf' kütüphanesi aktif edildiğinde, bu model UI üzerinden PDF olarak dışa aktarılacak.
    } catch (e) {
      developer.log("🚨 SİBER HATA: Adli dosya oluşturulamadı!", error: e);
      rethrow;
    }
  }
}
