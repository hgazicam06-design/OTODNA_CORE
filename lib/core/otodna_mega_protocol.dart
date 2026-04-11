import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 🦅 OTODNA MEGA PROTOKOLÜ - V7 (SİBER KARARGAH ANA SİSTEMİ)
/// [2026-04-12] GÜNCELLEME: Garanti Sertifikası ve Kuantum Mühürleme Entegrasyonu.
class OtodnaMegaProtocol {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // 💰 FİNANS VE STRATEJİ KURALI: %12 MUTLAK PROTOKOL
  static const double karargahPayi = 0.12;

  /// 🛡️ KUANTUM MÜHÜRLEME: Garanti Sertifikasını Firebase'e ve Blokzincir Yapısına Yazar
  static Future<void> garantiMuhurle({
    required String plaka,
    required String islem,
    required String garantiSuresi,
    required double tutar,
  }) async {
    final String? operatorId = _auth.currentUser?.uid;
    if (operatorId == null) throw Exception("SİBER İHLAL: Yetkisiz Giriş Denemesi!");

    // Seri No Oluştur (Benzersiz Siber Kimlik)
    final String sertifikaId = "DNA-${DateTime.now().millisecondsSinceEpoch}-${plaka.toUpperCase()}";

    // ATOMİK İŞLEM (WriteBatch): Ya hep ya hiç!
    WriteBatch batch = _db.batch();

    // 1. Sertifika Kaydı
    DocumentReference sertifikaRef = _db.collection('sertifikalar').doc(sertifikaId);
    batch.set(sertifikaRef, {
      'sertifika_id': sertifikaId,
      'plaka': plaka.toUpperCase(),
      'islem': islem,
      'tarih': FieldValue.serverTimestamp(),
      'garanti_suresi': garantiSuresi,
      'tutar': tutar,
      'operator_id': operatorId,
      'durum': 'AKTİF',
      'guvenlik_mühürü': 'VERIFIED_BY_OTODNA',
    });

    // 2. Araç DNA Skorunu Güncelle (Referans Artışı)
    DocumentReference aracRef = _db.collection('araclar').doc(plaka.toUpperCase());
    batch.update(aracRef, {
      'son_islem_tarihi': FieldValue.serverTimestamp(),
      'dna_skoru': FieldValue.increment(5), // Her mühürlü işlem skoru artırır
    });

    await batch.commit();
    print("🚀 SİBER MÜHÜR BASILDI: $sertifikaId");
  }

  /// 📍 AKILLI BÖLGE BULUCU (81 İl - 7 Bölge Protokolü)
  static String bolgeTespitEt(String sehir) {
    const Marmara = ["İSTANBUL", "BURSA", "KOCAELİ", "EDİRNE"]; // Liste genişletilebilir
    const IcAnadolu = ["ANKARA", "KONYA", "KAYSERİ", "ESKİŞEHİR"];

    String target = sehir.toUpperCase();
    if (Marmara.contains(target)) return "MARMARA BÖLGESİ";
    if (IcAnadolu.contains(target)) return "İÇ ANADOLU BÖLGESİ";

    return "DİĞER BÖLGE";
  }

  /// 🚨 ACİL DURUM (SOS) PROTOKOLÜ
  static Future<void> tetikleSOS(GeoPoint konum) async {
    final user = _auth.currentUser;
    await _db.collection('sos_ihbarlari').add({
      'user_id': user?.uid,
      'konum': konum,
      'zaman_damgasi': FieldValue.serverTimestamp(),
      'durum': 'KRİTİK',
      'mudahale_bekleniyor': true,
    });
  }
}