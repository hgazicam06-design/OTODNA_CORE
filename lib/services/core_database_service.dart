import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import '../models/service_model.dart';
import '../models/dukkan_model.dart';
import 'google_hub_service.dart';
import 'corporate_audit_logger.dart';

// ============================================================================
// DOSYA AMACI: 
// Bu servis, OtoDNA sisteminin Çekirdek Veritabanı (Core Database) motorudur.
// Araç DNA kayıtları, bayi (dükkan) verileri, dış ekspertiz entegrasyonları
// ve küresel şase sorgulama işlemleri bu merkezi sınıftan yönetilir.
// Eski FirebaseServis, FirestoreServis, DataService, SorguMerkezi ve
// VeriAktarimMerkezi bu yapı altında birleştirilmiştir.
// ============================================================================

class CoreDatabaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =======================================================================
  // 1. ARAÇ DNA SİCİL MERKEZİ
  // =======================================================================
  
  /// Araca yeni servis/bakım verisi ekler (Kuantum Mühür)
  static Future<void> servisKaydiEkle(ServiceRecord model) async {
    try {
      await _db.collection('servis_kayitlari').add(model.toMap());

      CorporateAuditLogger.logSystem(
        "DNA_KAYDI", 
        "Şase: ${model.saseNo} için yeni sicil mühürlendi."
      );
    } catch (e) {
      developer.log("OTODNA HATA: Servis kaydı eklenemedi!", error: e);
      throw Exception("Sistem Hatası: Araç DNA'sı kaydedilemedi.");
    }
  }

  /// Şase numarasına göre aracın servis geçmişini çeker
  static Future<List<ServiceRecord>> saseIleSorgula(String saseNo) async {
    try {
      var snapshot = await _db
          .collection('servis_kayitlari')
          .where('saseNo', isEqualTo: saseNo.toUpperCase())
          .orderBy('kilometre', descending: true)
          .get();

      return snapshot.docs.map((doc) => ServiceRecord.fromFirestore(doc)).toList();
    } catch (e) {
      developer.log("OTODNA HATA: Şase sorgulama başarısız!", error: e);
      throw Exception("Sistem Hatası: Araç geçmişine ulaşılamıyor.");
    }
  }

  // =======================================================================
  // 2. KAPSAMLI İSTİHBARAT VE SORGULAMA (Global Hub Destekli)
  // =======================================================================
  static Future<Map<String, dynamic>> tamKapsamliSorgula(String saseNo) async {
    String siberSase = saseNo.trim().toUpperCase();

    if (siberSase.isEmpty) {
      throw Exception("Şase numarası boş bırakılamaz.");
    }

    Map<String, dynamic> yerelVeri = {};
    Map<String, dynamic> hubVerisi = {};

    // 1. Yerel Veritabanını Tara
    try {
      var doc = await _db.collection('araclar').doc(siberSase).get();
      if (doc.exists) yerelVeri = doc.data()!;
    } catch (e) {
      developer.log("OTODNA HATA: Yerel veritabanına ulaşılamadı!", error: e);
    }

    // 2. Dış Global Hub'ı Tara
    try {
      var hubSonuc = await GoogleHubService.fetchGlobalData(siberSase);
      if (hubSonuc != null) hubVerisi = hubSonuc;
    } catch (e) {
      developer.log("OTODNA BİLGİ: Dış istihbarat ağı kullanılamıyor, yerel ile devam ediliyor.");
    }

    // 3. Verileri Birleştir
    return {
      "sase_no": siberSase,
      "marka_model": hubVerisi['title'] ?? yerelVeri['marka_model'] ?? "BİLİNMEYEN ARAÇ",
      "teknik": hubVerisi['specs'] ?? yerelVeri['teknik_bilgi'] ?? "Teknik veri dış istihbarattan alınamadı.",
      "hasar_gecmisi": hubVerisi['history'] ?? yerelVeri['hasar_gecmisi'] ?? "Kayıtlı hasar verisi bulunamadı.",
      "otodna_notu": yerelVeri.isNotEmpty
          ? (yerelVeri['not'] ?? "Bu aracın Kurumsal kayıtları mevcuttur. Detaylar için DNA Raporuna bakınız.")
          : "⚠️ Bu araç henüz güvenli OtoDNA limanına (bayisine) yanaşmamıştır."
    };
  }

  // =======================================================================
  // 3. ARAÇ KATALOĞU (Marka / Model)
  // =======================================================================
  static Future<List<String>> markalariGetir() async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('arac_markalari')
          .where('aktif', isEqualTo: true)
          .get();

      List<String> markalar = snapshot.docs.map((doc) => doc.id.toUpperCase()).toList();
      markalar.sort();
      return markalar;
    } catch (e) {
      throw Exception("Sistem Hatası: Marka kataloğuna ulaşılamadı!");
    }
  }

  static Future<List<String>> modelleriGetir(String marka) async {
    try {
      DocumentSnapshot doc = await _db.collection('arac_markalari').doc(marka.toUpperCase()).get();
      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<String> modeller = List<String>.from(data['modeller'] ?? []);
        modeller.sort();
        return modeller;
      }
      return [];
    } catch (e) {
      throw Exception("Sistem Hatası: $marka modellerine ulaşılamadı!");
    }
  }

  // =======================================================================
  // 4. BAYİ (DÜKKAN) SİSTEMİ VE FİNANSAL HAVUZ
  // =======================================================================
  Stream<List<Dukkan>> dukkanlariGetir(String sehir) {
    return _db
        .collection('dukkanlar')
        .where('sehir', isEqualTo: sehir.toUpperCase())
        .where('onayliMi', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Dukkan.fromFirestore(doc)).toList();
        });
  }

  Future<void> kaporaKaydet(String musteriId, String ustaId, {double tutar = 200.0}) async {
    try {
      double merkezPayi = tutar * 0.12; // %12 Kuralı
      WriteBatch batch = _db.batch();

      DocumentReference havuzRef = _db.collection('finans_havuzu').doc();
      batch.set(havuzRef, {
        'musteriId': musteriId,
        'ustaId': ustaId,
        'islem_tutari': tutar,
        'merkezPayi': merkezPayi,
        'tarih': FieldValue.serverTimestamp(),
        'durum': 'BEKLEMEDE',
      });

      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'KAPORA_ALINDI',
        'kategori': 'FINANS',
        'islem_detayi': 'Müşteri ($musteriId), Usta ($ustaId) için ₺$tutar kapora kilitledi.',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      throw Exception("Finansal Hata: Kapora havuzuna kaydedilemedi.");
    }
  }

  // =======================================================================
  // 5. DIŞ VERİ ENTEGRASYONU
  // =======================================================================
  static Future<void> disEkspertizVerisiIsle(Map<String, dynamic> disRapor) async {
    try {
      String muhurluSase = (disRapor['vin_code'] ?? '').trim().toUpperCase();
      if (muhurluSase.isEmpty) throw Exception("Şase numarası boş olamaz.");

      double uygulanacakKomisyon = 0.12;
      String kaynakSube = disRapor['servis_adi'] ?? "Bilinmeyen Dış Kaynak";

      WriteBatch batch = _db.batch();

      DocumentReference havuzRef = _db.collection('dis_ekspertiz_havuzu').doc();
      batch.set(havuzRef, {
        'sase_no': muhurluSase,
        'motor_durumu': disRapor['engine_score'] ?? "Belirtilmemiş",
        'kaporta_boya': disRapor['body_report'] ?? "Belirtilmemiş",
        'kaynak': kaynakSube,
        'uygulanan_komisyon_orani': uygulanacakKomisyon,
        'tarih': disRapor['test_date'] ?? FieldValue.serverTimestamp(),
        'otodna_onayi': false,
        'aktarim_tarihi': FieldValue.serverTimestamp(),
      });

      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'DIS_VERI_AKTARIMI',
        'kategori': 'ENTEGRASYON',
        'islem_detayi': '$muhurluSase şaseli araç için "$kaynakSube" operasoyonu eklendi.',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      throw Exception("Entegrasyon Hatası: Dış veri sisteme aktarılamadı.");
    }
  }
}
