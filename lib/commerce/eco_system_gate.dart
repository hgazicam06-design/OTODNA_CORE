import 'package:cloud_firestore/cloud_firestore.dart';

class OtoDnaEcoSystem {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. GALERİ VE PARÇA ENTEGRASYONU (GERÇEK FİREBASE MOTORU)
  // Usta muayenede Kırmızı X (❌) bastığı an bu motor tetiklenir.
  Future<void> parcaOner({
    required String plakaID,
    required String sorunluParca,
    required double parcaSatisFiyati, // Firmanın kendi vitrinine yazdığı özgür fiyat!
    required String saticiBayiAdi,
  }) async {
    try {
      // ⚙️ TİCARET MOTORU: %12 MUTLAK KARARGAH KESİNTİSİ
      // Firma fiyatı kendi belirler, OtoDNA bu fiyattan %12 (%10 Kâr + %2 Vergi) komisyonunu keser.
      double karargahPayi = parcaSatisFiyati * 0.12;
      double bayininElineGecen = parcaSatisFiyati - karargahPayi;

      // ⚙️ VİTRİN PROTOKOLÜ: Herkes kendi adıyla sahaya çıkar! İsim gizleme veya maskeleme YOKTUR.
      String sunanBayi = saticiBayiAdi;

      // 🚀 FİREBASE'E GERÇEK KAYIT BAŞLIYOR (WriteBatch ile Kuantum Mührü)
      WriteBatch batch = _firestore.batch();
      DocumentReference oneriRef = _firestore.collection('yedek_parca_onerileri').doc();

      batch.set(oneriRef, {
        'arac_plaka': plakaID,
        'sorunlu_parca': sorunluParca,
        'musteri_satis_fiyati': double.parse(parcaSatisFiyati.toStringAsFixed(2)), // Müşterinin gördüğü fiyat
        'karargah_komisyonu': double.parse(karargahPayi.toStringAsFixed(2)), // Bizim %12'miz
        'bayi_net_kazanci': double.parse(bayininElineGecen.toStringAsFixed(2)), // Firmanın net aldığı
        'sunan_bayi': sunanBayi, // Kendi orijinal ismiyle vitrinde
        'garanti': 'OtoDNA Referanslı Satış',
        'durum': 'Müşteri Onayı Bekliyor',
        'olusturulma_tarihi': FieldValue.serverTimestamp(),
      });

      await batch.commit(); // Füzeyi ateşle

    } catch (e) {
      // 🚨 HATA DURUMUNDA KARA KUTUYA YAZ (Print yerine güvenli log)
      await _firestore.collection('sistem_loglari').add({
        'islem_turu': 'hata',
        'islem_detayi': 'PARÇA ÖNERİ HATASI: $plakaID plakalı araca parça önerilemedi. $e',
        'bayi_isim': saticiBayiAdi,
        'tarih': FieldValue.serverTimestamp(),
      });
    }
  }

  // 2. DİJİTAL REFERANS PROTOKOLÜ (OtoDNA Mührü)
  // Araç testten geçip Galeriye eklendiğinde mühür vurulur.
  Future<void> ilanaKoy(String plakaID) async {
    try {
      // Aracın Kuantum DNA Kaydını Veritabanından Çek
      DocumentSnapshot aracDoc = await _firestore.collection('araclar').doc(plakaID).get();

      if (aracDoc.exists) {
        int dnaSkoru = (aracDoc.data() as Map<String, dynamic>)['dna_skoru'] ?? 0;

        // Eğer usta Kırmızı X atmamışsa ve skor yüksekse Mühürle!
        if (dnaSkoru >= 80) {
          await _firestore.collection('araclar').doc(plakaID).update({
            'otodna_onayli': true,
            'ilan_durumu': 'Yayında',
            'dijital_muhur_tarihi': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      // 🚨 HATA DURUMUNDA KARA KUTUYA YAZ
      await _firestore.collection('sistem_loglari').add({
        'islem_turu': 'hata',
        'islem_detayi': 'DİJİTAL MÜHÜR HATASI: $plakaID plakalı araç ilana çıkarılamadı. $e',
        'bayi_isim': 'OTOMATİK SİSTEM',
        'tarih': FieldValue.serverTimestamp(),
      });
    }
  }
}