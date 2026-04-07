import 'package:cloud_firestore/cloud_firestore.dart';

/// OTODNA TİCARET VE EKOSİSTEM KAPISI
/// Bu motor, parça önerilerini ve ilan yönetimini Karargah kurallarıyla yönetir.
class OtoDnaEcoSystem {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ⚙️ TİCARET MOTORU: %12 MUTLAK KARARGAH KESİNTİSİ & MURAT PLAZA ÖZEL MARJI
  Future<void> parcaOner({
    required String plakaID,
    required String sorunluParca,
    required double parcaSatisFiyati,
    required String saticiBayiAdi,
    required String bayiId,
  }) async {
    try {
      // Finansal Algoritma: %10 Kâr + %2 Vergi = %12 Karargah Payı
      double karargahPayi = parcaSatisFiyati * 0.12;

      // Murat Plaza Kuralı: Eğer bayi Murat Plaza ise %30 kâr marjı uygulanır
      double bayiKari = (bayiId == "MURAT_PLAZA_ID") ? (parcaSatisFiyati * 0.30) : (parcaSatisFiyati * 0.10);

      // 🚀 FİREBASE'E GERÇEK KAYIT (WriteBatch Mührü)
      WriteBatch batch = _firestore.batch();

      DocumentReference teklifRef = _firestore.collection('parca_teklifleri').doc();
      batch.set(teklifRef, {
        'plaka_id': plakaID,
        'parca_adi': sorunluParca,
        'fiyat': parcaSatisFiyati,
        'sunan_bayi': (bayiId == "MURAT_PLAZA_ID") ? "Murat Plaza" : saticiBayiAdi,
        'karargah_payi': karargahPayi,
        'bayi_hakedis': parcaSatisFiyati - karargahPayi,
        'tarih': FieldValue.serverTimestamp(),
        'durum': 'BEKLEMEDE',
      });

      await batch.commit();
    } catch (e) {
      await _firestore.collection('sistem_loglari').add({
        'islem_turu': 'hata',
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
        int dnaSkoru = (aracDoc.data() as Map<String, dynamic>)['dna_skoru'] ?? 0;

        // Skor 80 altındaysa ilan pasif kalır, üstündeyse Mühürlenir!
        await _firestore.collection('araclar').doc(plakaID).update({
          'otodna_onayli': dnaSkoru >= 80,
          'ilan_durumu': 'Yayında',
          'son_mühür_tarihi': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print("İlan Hatası: $e");
    }
  }
}