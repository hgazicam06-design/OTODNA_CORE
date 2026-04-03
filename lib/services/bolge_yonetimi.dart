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

  /// SİBER KOMUTAN GAZİ TARAFINDAN BÖLGE KOMUTANI ATAMA PROTOKOLÜ
  Future<Map<String, dynamic>> bolgeKomutaniAta({
    required String kullaniciId,
    required String isim,
    required String bolge
  }) async {
    try {
      // 1. ADIM: Kullanıcının genel profilini güncelle (Yetkisini Admin/Bölge Sorumlusu yap)
      await _db.collection('kullanicilar').doc(kullaniciId).set({
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

      await _db.collection('bolge_komutanlari').doc(kullaniciId).set(yeniKomutan.toMap());

      // 3. ADIM: Admin Kara Kutu (Sistem Logları) ekranına bu atamayı yaz!
      await _db.collection('sistem_loglari').add({
        'islem_turu': 'basarili',
        'islem_detayi': 'MÜHÜR: $isim, $bolge Bölge Komutanı olarak Kuantum Ağına atanmıştır.',
        'bayi_isim': 'ANKARA MERKEZ KARARGAH',
        'tarih': FieldValue.serverTimestamp(),
      });

      return {'basarili': true, 'mesaj': 'Operasyon Başarılı: $isim, $bolge komutanı olarak yetkilendirildi.'};
    } catch (e) {
      return {'basarili': false, 'mesaj': 'SİBER AĞ HATASI: Atama başarısız oldu. $e'};
    }
  }

  /// YETKİ ALMA (İHRAÇ) PROTOKOLÜ
  Future<Map<String, dynamic>> komutanliktanIhracEt(String kullaniciId, String isim) async {
    try {
      // 1. Yetkiyi geri alıp standart kullanıcıya düşür
      await _db.collection('kullanicilar').doc(kullaniciId).update({
        'rol': 'kullanici',
        'sorumlu_bolge': FieldValue.delete(), // Sorumlu olduğu bölgeyi sil
      });

      // 2. Bölge komutanları listesinden durumu pasife çek
      await _db.collection('bolge_komutanlari').doc(kullaniciId).update({
        'aktif': false,
        'gorevden_alinma_tarihi': FieldValue.serverTimestamp(),
      });

      // 3. Loglara işle
      await _db.collection('sistem_loglari').add({
        'islem_turu': 'hata', // Kırmızı alarm yaksın diye
        'islem_detayi': 'İHRAÇ: $isim adlı personelin Bölge Komutanlığı yetkileri elinden alındı.',
        'bayi_isim': 'ANKARA MERKEZ KARARGAH',
        'tarih': FieldValue.serverTimestamp(),
      });

      return {'basarili': true, 'mesaj': '$isim başarıyla görevden alındı ve yetkileri sıfırlandı.'};
    } catch (e) {
      return {'basarili': false, 'mesaj': 'SİBER AĞ HATASI: İhraç işlemi başarısız. $e'};
    }
  }
}