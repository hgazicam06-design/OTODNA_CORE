import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import '../models/adli_rapor_model.dart';

// ============================================================================
// DOSYA AMACI: 
// Bu servis, OtoDNA platformunun Hukuk ve Bilirkişi algoritmalarını içerir.
// 1. Tramer SMS analizi yaparak araçların Ağır Hasar (Pert) durumlarını denetler
//    ve Yargıtay emsal kararlarına göre Değer Kaybı tazminatı hesaplar.
// 2. Olay Yeri İnceleme (Bilirkişi) verilerini analiz ederek usta, parça ve 
//    kullanıcı arasındaki kusur oranlarını yapay zeka mantığıyla (mock) dağıtır.
// ============================================================================

class CorporateLegalEngine {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =======================================================================
  // 1. TRAMER SMS ANALİZİ VE DEĞER KAYBI HESAPLAMA
  // =======================================================================
  Future<Map<String, dynamic>> tramerAnaliziYap({
    required String smsMetni,
    required String saseNo,
    required int kilometre,
    required int kusurOrani,
  }) async {
    String ustMetin = smsMetni.toUpperCase();

    // KURAL 1: Ağır Hasarlı (Pert) araçlara değer kaybı davası açılamaz.
    if (ustMetin.contains("AĞIR HASARLI") || ustMetin.contains("PERT") || ustMetin.contains("AGIR HASAR")) {
      return {
        'basarili': false,
        'pertMi': true,
        'mesaj': "HUKUKİ RED: Araçta 'Ağır Hasarlı (Pert)' kaydı tespit edilmiştir. Yasal olarak bu araca Değer Kaybı Davası açılamaz."
      };
    }

    // KURAL 2: Geçmiş kaza sayısını analiz et.
    int kazaSayisi = 0;
    kazaSayisi += _kelimeSay(ustMetin, "CARPMA");
    kazaSayisi += _kelimeSay(ustMetin, "CARPISMA");
    kazaSayisi += _kelimeSay(ustMetin, "KAZA");

    // Aracın siciline bu veriyi kalıcı olarak işle
    try {
      await _db.collection('araclar').doc(saseNo).set({
        'tramerKazaSayisi': kazaSayisi,
        'sonTramerSorguTarihi': FieldValue.serverTimestamp(),
        'agirHasarKaydiVarMi': false,
      }, SetOptions(merge: true));
    } catch (e) {
      developer.log("OTODNA HATA: Araç verisi güncellenemedi: $e");
    }

    // KURAL 3: Yargıtay Emsal Algoritması
    double tahminiTutar = _degerKaybiHesapla(kilometre, kusurOrani, kazaSayisi);

    if (tahminiTutar <= 0) {
      return {
        'basarili': false,
        'pertMi': false,
        'mesaj': "Kusur oranınız yüksek veya aracınızın kilometresi sınırın üzerinde olduğu için değer kaybı tazminatı oluşmamaktadır."
      };
    }

    return {
      'basarili': true,
      'tahminiTutar': tahminiTutar,
      'kazaSayisi': kazaSayisi,
      'mesaj': "Hukuki analiz başarılı. Emsal değer kaybı hesaplandı."
    };
  }

  double _degerKaybiHesapla(int km, int kusurOrani, int gecmisKazaSayisi) {
    if (kusurOrani >= 100) return 0.0; // Tam kusurlu tazminat alamaz

    double bazTutar = 60000.0; 
    double kusurCarpani = (100 - kusurOrani) / 100;
    double tutar = bazTutar * kusurCarpani;

    // Kilometre Çarpanı (Düşük KM daha çok değer kaybeder)
    if (km < 30000) {
      tutar *= 1.2; 
    } else if (km > 150000) {
      tutar *= 0.4; 
    } else if (km > 250000) {
      return 0.0; // Genelde 250bin KM üstüne tazminat verilmez
    }

    // Geçmiş Kaza Çarpanı (Önceden kazalı araç daha az değer kaybeder)
    if (gecmisKazaSayisi == 1) {
      tutar *= 0.8;
    } else if (gecmisKazaSayisi >= 2) {
      tutar *= 0.5;
    }

    return tutar;
  }

  Future<bool> avukataDosyaAc(String saseNo, double tutar, String smsMetni) async {
    try {
      await _db.collection('hukuk_dosyalari').add({
        'saseNo': saseNo,
        'tramerMesaji': smsMetni,
        'hesaplananTutar': tutar,
        'durum': 'Avukat Ataması Bekliyor',
        'acilisTarihi': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  int _kelimeSay(String metin, String aranan) {
    int sayac = 0;
    int index = metin.indexOf(aranan);
    while (index != -1) {
      sayac++;
      index = metin.indexOf(aranan, index + aranan.length);
    }
    return sayac;
  }

  // =======================================================================
  // 2. BİLİRKİŞİ VE KUSUR ANALİZİ (YAPAY ZEKA SİMÜLASYONU)
  // =======================================================================
  static Future<AdliRaporModel> aiAnaliziYap({
    required String aracSaseNo,
    required String ustaUid,
    required String tedarikciKodu,
    required String davaTuru,
    required List<String> fotolar,
    required List<String> videolar,
    required List<String> testVerileri,
  }) async {
    developer.log("OTODNA BİLGİ: Bilirkişi analizi başlatıldı...");
    
    // Gerçek sistemde Gemini/AI çağrısı yapılır, burada 3 sn mock bekliyoruz.
    await Future.delayed(Duration(seconds: 3)); 

    bool parcaOrijinalMi = tedarikciKodu.toUpperCase().startsWith("ORG");
    
    String aiHukmu;
    int kusurUsta = 0;
    int kusurParca = 0;
    int kusurKullanici = 0;

    if (parcaOrijinalMi) {
      aiHukmu = "BİLİRKİŞİ RAPORU: Isı haritası ve ECU tork değerleri incelendi. Ustanın montajı standartlarındadır. Sensör verileri, aracın uzun süre hararette kullanıldığını (kullanıcı hatası) göstermektedir.";
      kusurKullanici = 100;
    } else {
      aiHukmu = "BİLİRKİŞİ RAPORU: Kırık parça fotoğrafları incelendi. Metal yorgunluğu ve fabrikasyon üretim hatası tespit edilmiştir. Usta hatası bulunmamaktadır.";
      kusurParca = 100;
    }

    developer.log("OTODNA HUKUK: Kusur Dağılımı -> Usta %$kusurUsta | Parça %$kusurParca | Kullanıcı %$kusurKullanici");

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
      yasalUyariOkundu: true, 
    );
  }

  static Future<void> raporuMasaustuneKilitle(AdliRaporModel rapor) async {
    try {
      DocumentReference docRef = _db.collection('adli_dosyalar').doc();
      await docRef.set(rapor.toMap());
      developer.log("OTODNA BİLGİ: Adli dosya kilitlendi. Dosya ID: ${docRef.id}");
    } catch (e) {
      developer.log("OTODNA HATA: Adli dosya oluşturulamadı!", error: e);
      rethrow;
    }
  }
}
