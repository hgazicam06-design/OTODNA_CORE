import 'package:cloud_firestore/cloud_firestore.dart';

class BayiEkosistemi {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. BAYİ ÇIKARINI KOLLAYAN İŞLEM MODELİ (EŞİTLİK PROTOKOLÜ)
  Future<void> islemBaslat({
    required String bayiId,
    required String bayiAdi,
    required double islemTutari // Bu tutar müşterinin ödediği SON fiyattır (KDV dahil)
  }) async {

    // 🔥 SİBER KURAL: Murat Plaza imtiyazı YIKILDI! Herkesten net %12 OtoDNA payı kesilir.
    double gaziPayi = islemTutari * 0.12; // OtoDNA'nın %12'lik komisyonu
    double bayiPayi = islemTutari * 0.88; // Bayinin hesabına yatacak net tutar (Kendi KDV'si ve gideri içinden)

    try {
      // SİBER ZIRH: Atomik WriteBatch Başlatıldı
      WriteBatch batch = _db.batch();

      // Kuantum Defterine (Finansal Kayıtlara) İşlemi Yaz
      DocumentReference finansRef = _db.collection('finansal_islemler').doc();
      batch.set(finansRef, {
        "bayi_id": bayiId,
        "bayi_adi": bayiAdi,
        "toplam_tutar": islemTutari,
        "bayi_hesabina_yatacak": bayiPayi,
        "otodna_kesintisi": gaziPayi, // Komutan Gazi Payı (%12)
        "tarih": FieldValue.serverTimestamp(),
      });

      // Bayinin cüzdan bakiyesini ve itibar puanını artır
      DocumentReference bayiRef = _db.collection('bayiler').doc(bayiId);
      batch.update(bayiRef, {
        "toplam_kazanc": FieldValue.increment(bayiPayi),
        "itibar_puani": FieldValue.increment(10), // Dürüst işlem ödülü
        "son_islem_tarihi": FieldValue.serverTimestamp(),
      });

      // Füzeleri aynı anda ateşle!
      await batch.commit();

    } catch (e) {
      // Print yerine Karargahın Kara Kutusuna raporla
      await _db.collection('sistem_loglari').add({
        'islem_turu': 'hata',
        'islem_detayi': 'KRİTİK FİNANSAL HATA: $bayiAdi işlemi mühürlenemedi! $e',
        'tarih': FieldValue.serverTimestamp(),
      });
    }
  }

  // 2. ŞEFFAF ÜRÜN LİSTELEME (GİZLİLİK KALKTI, HERKES KENDİ ADIYLA ÇIKAR)
  Future<void> urunListele({
    required String saticiId,
    required String saticiAdi,
    required String urunAd,
    required double girilenFiyat,
    required bool kdvDahilMi, // UI'dan %20 KDV dahil mi hariç mi seçeneği gelecek
    required String kategori
  }) async {

    try {
      // KDV Hesaplaması: Eğer hariç girildiyse %20 ekle, dahilse aynen bırak.
      double satisFiyati = kdvDahilMi ? girilenFiyat : girilenFiyat * 1.20;

      // Satış gerçekleştiğinde kesilecek OtoDNA bedeli (%12)
      double otodnaBedeli = satisFiyati * 0.12;
      // Satıcıya kalacak net tutar (Kendi KDV'sini bu paranın içinden ödeyecek)
      double saticiyaYatacak = satisFiyati - otodnaBedeli;

      await _db.collection('yedek_parcalar').add({
        "isim": urunAd,
        "kategori": kategori,
        "girilen_ham_fiyat": girilenFiyat,
        "kdv_durumu": kdvDahilMi ? "Dahil (%20)" : "Hariç (Sistem %20 Ekledi)",
        "satis_fiyati": satisFiyati, // Müşterinin göreceği ve ödeyeceği tutar
        "otodna_komisyonu_beklenen": otodnaBedeli, // Satılınca kesilecek Karargah payı
        "saticiya_yatacak_tutar": saticiyaYatacak, // Satıcının göreceği net kazanç
        "satici_id": saticiId,
        "satici_adi": saticiAdi, // 🔥 ARTIK HERKES KENDİ İSMİYLE VİTRİNDE!
        "eklenme_tarihi": FieldValue.serverTimestamp(),
        "statu": "Aktif"
      });
    } catch (e) {
      await _db.collection('sistem_loglari').add({
        'islem_turu': 'hata',
        'islem_detayi': 'ÜRÜN LİSTELEME HATASI: $urunAd vitrine çıkarılamadı! $e',
        'tarih': FieldValue.serverTimestamp(),
      });
    }
  }
}