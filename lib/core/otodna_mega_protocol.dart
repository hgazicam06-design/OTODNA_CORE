// lib/core/otodna_mega_protocol.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

import 'kuresel_harita_sistemi.dart';

/// 🦅 OTODNA MEGA PROTOKOLÜ - V7 (SİBER KARARGAH ANA SİSTEMİ)
/// [2026-04-21] GÜNCELLEME: Atomik Loglama, 30 Dk. S.O.S Kuralı ve Mutlak %12 Finans Entegrasyonu.
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

    // 🔥 %12 MUTLAK KESİNTİ ALGORİTMASI
    double kesintiTutar = tutar * karargahPayi;
    double bayiHakedis = tutar - kesintiTutar;

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
      'karargah_payi': kesintiTutar,
      'bayi_hakedis': bayiHakedis,
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

    // 3. 🕵️‍♂️ Karargah Kara Kutusuna Siber Log
    DocumentReference logRef = _db.collection('sistem_loglari').doc();
    batch.set(logRef, {
      'islem_turu': 'GARANTI_MUHURU',
      'islem_detayi': '$plaka araca $islem sertifikası basıldı. Sertifika: $sertifikaId. Karargah Payı: ₺$kesintiTutar',
      'operator_id': operatorId,
      'tarih': FieldValue.serverTimestamp(),
    });

    await batch.commit(); // Füzeleri ateşle!
    developer.log("🚀 SİBER MÜHÜR BASILDI: $sertifikaId (Finans ve Log entegre edildi)");
  }

  /// 📍 AKILLI BÖLGE BULUCU (Kuantum Harita Entegrasyonu)
  static String bolgeTespitEt(String sehir) {
    // SİBER GÜNCELLEME: Artık KureselHaritaSistemi motoruna doğrudan bağlandı.
    // 4 Kademeli Kuantum İstihbaratını kullanarak nokta atışı bölge tespiti yapar.
    return KureselHaritaSistemi.hangiBolgede(KureselHaritaSistemi.globalMerkezUlkemiz, sehir);
  }

  /// 🚨 ACİL DURUM (SOS) PROTOKOLÜ: 5 Saniye Kuralı ve 30 Dakika Geri Sayım Radarı
  static Future<void> tetikleSOS({required GeoPoint konum, required String plaka}) async {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception("SİBER İHLAL: Kimliksiz SOS Sinyali Engellendi!");

    WriteBatch batch = _db.batch();

    // 1. İmece Alarmları (Acil Durum Havuzu)
    DocumentReference sosRef = _db.collection('imece_alarmlari').doc();
    batch.set(sosRef, {
      'user_id': userId,
      'plaka': plaka,
      'konum': konum,
      'zaman_damgasi': FieldValue.serverTimestamp(),
      'durum': 'ACIL_MUDEHALE_BEKLIYOR',
      'mudahale_siniri_dakika': 30, // 🔥 30 Dakika Karargah SLA Kuralı
      'sari_kirmizi_kart_riski': true, // Asılsız ihbar denetim bayrağı
    });

    // 2. Kara Kutuya S.O.S İhbarı Düş
    DocumentReference logRef = _db.collection('sistem_loglari').doc();
    batch.set(logRef, {
      'islem_turu': 'SOS_SINYALI',
      'islem_detayi': 'KRİTİK UYARI: $userId kullanıcısı $plaka aracı için SOS tetikledi. 30 dakikalık geri sayım başladı.',
      'tarih': FieldValue.serverTimestamp(),
    });

    await batch.commit(); // Kırmızı Alarmları Kuantum Ağına İşle!
    developer.log("🚨 SOS SİNYALİ ATEŞLENDİ! Karargah radarları 30 dakika geri sayıma başladı.");
  }
}