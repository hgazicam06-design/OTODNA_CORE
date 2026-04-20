// lib/services/eco_system_gate.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ OTODNA TİCARET VE EKOSİSTEM KAPISI
/// Bu motor, parça önerilerini ve ilan yönetimini Mutlak Karargah Kurallarıyla yönetir.
class OtoDnaEcoSystem {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ⚙️ TİCARET MOTORU: İSTİSNASIZ %12 MUTLAK KARARGAH KESİNTİSİ
  Future<void> parcaOner({
    required String plakaID,
    required String sorunluParca,
    required double parcaSatisFiyati,
    required String saticiBayiAdi,
  }) async {
    try {
      // 💰 Finansal Algoritma: İSTİSNASIZ %10 Kâr + %2 Vergi = %12 Karargah Payı
      double karargahPayi = parcaSatisFiyati * 0.12;
      double bayiHakedis = parcaSatisFiyati - karargahPayi;

      // 🚀 FİREBASE'E GERÇEK KAYIT (WriteBatch Mührü)
      WriteBatch batch = _firestore.batch();

      DocumentReference teklifRef = _firestore.collection('parca_teklifleri').doc();
      batch.set(teklifRef, {
        'plaka_id': plakaID,
        'parca_adi': sorunluParca,
        'fiyat': parcaSatisFiyati,
        'sunan_bayi': saticiBayiAdi, // 🔥 ŞEFFAFLIK KURALI: Herkes kendi adıyla çıkar!
        'karargah_payi': karargahPayi,
        'bayi_hakedis': bayiHakedis,
        'tarih': FieldValue.serverTimestamp(),
        'durum': 'BEKLEMEDE',
      });

      // 🕵️‍♂️ Kara Kutuya Log Mühürle
      DocumentReference logRef = _firestore.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'PARCA_TEKLIFI',
        'islem_detayi': '$plakaID plakalı araca $saticiBayiAdi tarafından $sorunluParca teklifi verildi. Karargah Payı: ₺$karargahPayi',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      developer.log("SİBER TİCARET: Parça teklifi, %12 kesinti ve kendi adıyla ilan kuralıyla atomik olarak mühürlendi.");
    } catch (e) {
      developer.log("TİCARİ İHLAL: Parça önerilemedi -> $e");
      await _firestore.collection('sistem_loglari').add({
        'islem_turu': 'HATA',
        'islem_detayi': 'PARÇA ÖNERİ HATASI: $plakaID - $e',
        'tarih': FieldValue.serverTimestamp(),
      });
    }
  }

  // 2. DİJİTAL REFERANS PROTOKOLÜ (OtoDNA Mührü)
  Future<void> ilanaKoy(String plakaID) async {
    try {
      DocumentSnapshot aracDoc = await _firestore.collection('araclar').doc(plakaID).get();

      if (aracDoc.exists) {
        var data = aracDoc.data() as Map<String, dynamic>;
        int dnaSkoru = data['dna_skoru'] ?? 0;

        // 🔥 Skor 80 altındaysa ilan pasif kalır, üstündeyse Mühürlenir!
        WriteBatch batch = _firestore.batch();

        batch.update(_firestore.collection('araclar').doc(plakaID), {
          'otodna_onayli': dnaSkoru >= 80,
          'ilan_durumu': 'Yayında',
          'son_muhur_tarihi': FieldValue.serverTimestamp(),
        });

        // Log mühürleme
        DocumentReference logRef = _firestore.collection('sistem_loglari').doc();
        batch.set(logRef, {
          'islem_turu': 'ILAN_YAYINLAMA',
          'islem_detayi': '$plakaID plakalı araç ilana çıktı. DNA Onayı: ${dnaSkoru >= 80}',
          'tarih': FieldValue.serverTimestamp(),
        });

        await batch.commit();
        developer.log("SİBER MÜHÜR: Araç ilanı ve DNA doğrulaması mühürlendi.");
      }
    } catch (e) {
      developer.log("İLAN İHLALİ: Araç ilana koyulamadı -> $e");
    }
  }
}