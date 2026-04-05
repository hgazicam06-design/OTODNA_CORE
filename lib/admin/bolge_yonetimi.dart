import 'package:cloud_firestore/cloud_firestore.dart';

// --- 1. MODEL KATMANI: BÖLGE KOMUTANI (VERİ YAPISI) ---
class BolgeKomutani {
  final String id;
  final String isim;
  final String sorumluOlduguBolge;
  final String rutbe;

  BolgeKomutani({
    required this.id,
    required this.isim,
    required this.sorumluOlduguBolge,
    required this.rutbe,
  });

  // Kuantum Ağına (Firebase) yazmak için veriyi dönüştürür
  Map<String, dynamic> toMap() {
    return {
      'isim': isim,
      'sorumlu_bolge': sorumluOlduguBolge,
      'rutbe': rutbe,
      'atanma_tarihi': FieldValue.serverTimestamp(),
      'yetki_seviyesi': 2, // 1: Gazi (Süper Admin), 2: Bölge Komutanı, 3: Standart Kullanıcı
      'aktif': true,
    };
  }
}

// --- 2. SERVİS KATMANI: SİBER YETKİ VE ATAMA MOTORU ---
class AdminYetkiServisi {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// SİBER KOMUTAN GAZİ TARAFINDAN BÖLGE KOMUTANI ATAMA PROTOKOLÜ (ATOMİK - WRITEBATCH)
  Future<Map<String, dynamic>> bolgeKomutaniAta({
    required String kullaniciId,
    required String isim,
    required String bolge
  }) async {
    try {
      WriteBatch batch = _db.batch(); // 🔥 Kuantum Mührü Başlatıldı

      // 1. ADIM: Kullanıcının genel profilini güncelle (Yetkisini Admin/Bölge Sorumlusu yap)
      DocumentReference kullaniciRef = _db.collection('kullanicilar').doc(kullaniciId);
      batch.set(kullaniciRef, {
        'rol': 'bolge_komutani',
        'sorumlu_bolge': bolge,
        'rutbe_guncelleme_tarihi': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 2. ADIM: Karargah Temsilcileri (Bölge Komutanları) özel listesine mühürle
      BolgeKomutani yeniKomutan = BolgeKomutani(
        id: kullaniciId,
        isim: isim,
        sorumluOlduguBolge: bolge,
        rutbe: 'Bölge Sorumlusu',
      );
      DocumentReference komutanRef = _db.collection('bolge_komutanlari').doc(kullaniciId);
      batch.set(komutanRef, yeniKomutan.toMap());

      // 3. ADIM: Admin Kara Kutu (Sistem Logları) ekranına bu atamayı yaz!
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'basarili',
        'islem_detayi': 'MÜHÜR: $isim, $bolge Bölge Komutanı olarak Kuantum Ağına atanmıştır.',
        'bayi_isim': 'ANKARA MERKEZ KARARGAH',
        'tarih': FieldValue.serverTimestamp(),
      });

      // 🔥 Tüm işlemleri tek seferde Karargaha ateşle! (Ya hep, ya hiç!)
      await batch.commit();

      return {'basarili': true, 'mesaj': 'Operasyon Başarılı: $isim, $bolge komutanı olarak yetkilendirildi.'};
    } catch (e) {
      return {'basarili': false, 'mesaj': 'SİBER AĞ HATASI: Atama başarısız oldu. $e'};
    }
  }

  /// YETKİ ALMA (İHRAÇ) PROTOKOLÜ (ATOMİK - WRITEBATCH)
  Future<Map<String, dynamic>> komutanliktanIhracEt(String kullaniciId, String isim) async {
    try {
      WriteBatch batch = _db.batch(); // 🔥 Kuantum Mührü Başlatıldı

      // 1. Yetkiyi geri alıp standart kullanıcıya düşür
      DocumentReference kullaniciRef = _db.collection('kullanicilar').doc(kullaniciId);
      batch.update(kullaniciRef, {
        'rol': 'kullanici',
        'sorumlu_bolge': FieldValue.delete(), // Sorumlu olduğu bölgeyi sil
      });

      // 2. Bölge komutanları listesinden durumu pasife çek
      DocumentReference komutanRef = _db.collection('bolge_komutanlari').doc(kullaniciId);
      batch.update(komutanRef, {
        'aktif': false,
        'gorevden_alinma_tarihi': FieldValue.serverTimestamp(),
      });

      // 3. Loglara işle
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'hata', // Kırmızı alarm yaksın diye
        'islem_detayi': 'İHRAÇ: $isim adlı personelin Bölge Komutanlığı yetkileri elinden alındı.',
        'bayi_isim': 'ANKARA MERKEZ KARARGAH',
        'tarih': FieldValue.serverTimestamp(),
      });

      // 🔥 Kalkanları kapat ve işlemi tek seferde ateşle!
      await batch.commit();

      return {'basarili': true, 'mesaj': '$isim başarıyla görevden alındı ve yetkileri sıfırlandı.'};
    } catch (e) {
      return {'basarili': false, 'mesaj': 'SİBER AĞ HATASI: İhraç işlemi başarısız. $e'};
    }
  }
}