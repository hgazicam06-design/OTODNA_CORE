import 'package:cloud_firestore/cloud_firestore.dart';

class OtoDnaEcoSystem {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. GALERİ VE PARÇA ENTEGRASYONU (GERÇEK FİREBASE MOTORU)
  // Usta muayenede Kırmızı X (❌) bastığı an bu motor tetiklenir.
  Future<void> parcaOner({
    required String plakaID,
    required String sorunluParca,
    required double parcaAlisFiyati,
    required String saticiBayiAdi,
  }) async {
    try {
      // ⚙️ TİCARET MOTORU: Kâr Marjı ve Komisyon Hesaplaması
      // 🔥 SİBER KURAL: İMTİYAZ YOK! HERKESTEN %10 KÂR + %2 VERGİ = %12 KESİLİR!
      double komutanGaziPayi = parcaAlisFiyati * 0.12;
      double musteriSatisFiyati = parcaAlisFiyati + komutanGaziPayi;

      // ⚙️ GİZLİLİK PROTOKOLÜ: Orijinal tedarikçi gizlenir, ürün işlemi yapan bayinin kendi adıyla sunulur.
      String gorunenTedarikci = saticiBayiAdi;

      // 🚀 FİREBASE'E GERÇEK KAYIT BAŞLIYOR (WriteBatch ile Kuantum Mührü)
      WriteBatch batch = _firestore.batch();
      DocumentReference oneriRef = _firestore.collection('yedek_parca_onerileri').doc();

      batch.set(oneriRef, {
        'arac_plaka': plakaID,
        'sorunlu_parca': sorunluParca,
        'orijinal_alis_fiyati': parcaAlisFiyati, // Sadece Admin Görebilir
        'gazi_komisyon_vergi_payi': komutanGaziPayi, // Sadece Admin Görebilir
        'musteri_satis_fiyati': double.parse(musteriSatisFiyati.toStringAsFixed(2)), // Kuruşları yuvarla
        'sunan_bayi': gorunenTedarikci,
        'garanti': '1 Yıl OtoDNA Garantili',
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