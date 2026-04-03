import 'package:cloud_firestore/cloud_firestore.dart';

class KureselKonumMotoru {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------------------------------------------------
  // 🌍 1. FİREBASE CANLI LİSTELEYİCİ (Dropdown/Arama İçin)
  // ---------------------------------------------------------
  // Cihazı yormaz, sadece seçilen ülkeye ait şehirleri anında çeker.
  Future<List<String>> sehirleriGetir(String ulkeKodu) async {
    try {
      QuerySnapshot snapshot = await _db.collection('kuresel_harita')
          .where('code', isEqualTo: ulkeKodu)
          .where('operasyona_acik_mi', isEqualTo: true) // Operasyon durdurulmuşsa veri çekme!
          .get();

      if (snapshot.docs.isEmpty) return [];

      // Kuantum Çözümleme: Ülke -> Bölgeler -> Şehirler
      List<String> tumSehirler = [];
      var ulkeData = snapshot.docs.first.data() as Map<String, dynamic>;
      var regions = ulkeData['regions'] as List<dynamic>? ?? [];

      for (var region in regions) {
        var cities = region['cities'] as List<dynamic>? ?? [];
        for (var city in cities) {
          tumSehirler.add(city['name']);
        }
      }

      tumSehirler.sort(); // Kullanıcılar kolay bulsun diye A-Z alfabetik sıralama
      return tumSehirler;
    } catch (e) {
      print("Harita Kuantum Bağlantı Hatası: $e");
      return [];
    }
  }

  // ---------------------------------------------------------
  // 🚀 2. SİBER HARİTA YÜKLEYİCİ (SADECE ADMİN KULLANIR)
  // ---------------------------------------------------------
  // Admin panelinde bir butona basılır ve bu sabit liste Firebase'e sonsuza dek mühürlenir.
  Future<void> haritayiFirebaseeBas() async {
    // Sabit Listeler (Veritabanına Tohumlanacak Kaynak Veriler)
    final Map<String, String> turkiyeSehirleri = {
      "01 Adana": "Akdeniz",
      "06 Ankara": "İç Anadolu",
      "34 İstanbul": "Marmara",
      "40 Kırşehir": "İç Anadolu",
      // İleride diğer şehirler de buraya eklenip basılabilir
    };

    final Map<String, String> almanyaEyaletleri = {
      "Berlin": "Kuzey Almanya",
      "Münih": "Bavyera",
      "Hamburg": "Kuzey Almanya",
      "Frankfurt": "Hessen",
      "Stuttgart": "Baden-Württemberg",
    };

    // Kuantum Çelik Kasa (Batch): Verileri yarım yamalak değil, tek hamlede yazar.
    WriteBatch batch = _db.batch();

    try {
      // 🇹🇷 TÜRKİYE'Yİ İNŞA ET VE KASAYA KOY
      DocumentReference trRef = _db.collection('kuresel_harita').doc('TR_HQ');
      batch.set(trRef, _ulkeVerisiniHazirla("Türkiye", "TR", turkiyeSehirleri));

      // 🇩🇪 ALMANYA'YI İNŞA ET VE KASAYA KOY
      DocumentReference deRef = _db.collection('kuresel_harita').doc('DE_OP');
      batch.set(deRef, _ulkeVerisiniHazirla("Almanya", "DE", almanyaEyaletleri));

      // 🚀 FÜZELERİ ATEŞLE (Canlı Kayıt)
      await batch.commit();
      print("🌍 SİBER HARİTA FİREBASE'E BAŞARIYLA YÜKLENDİ!");

    } catch (e) {
      print("Siber Harita Yükleme Hatası: $e");
    }
  }

  // ---------------------------------------------------------
  // 🧠 YARDIMCI KUANTUM ZEKA: Düz Map'i Firebase'in İç İçe (Nested) Yapısına Çevirir
  // ---------------------------------------------------------
  Map<String, dynamic> _ulkeVerisiniHazirla(String ulkeAdi, String ulkeKodu, Map<String, String> sehirBolgeMap) {
    // Bölgelere göre şehirleri grupla
    Map<String, List<Map<String, dynamic>>> bolgeGruplari = {};

    sehirBolgeMap.forEach((sehirAd, bolgeAd) {
      if (!bolgeGruplari.containsKey(bolgeAd)) {
        bolgeGruplari[bolgeAd] = [];
      }

      bolgeGruplari[bolgeAd]!.add({
        'name': sehirAd,
        'plate_code': 0, // Plaka kodu ileride güncellenebilir
        'districts': [],
        // 🚨 SİBER ANA KARARGAH KONTROLÜ
        'merkez_us_mu': sehirAd.contains("Ankara"),
      });
    });

    // location_model.dart yapısına tam uygun hale getir
    List<Map<String, dynamic>> regionsList = bolgeGruplari.entries.map((entry) {
      return {
        'name': entry.key,
        'cities': entry.value,
      };
    }).toList();

    return {
      'name': ulkeAdi,
      'code': ulkeKodu,
      'regions': regionsList,
      'operasyona_acik_mi': true,
      'guncelleme_tarihi': FieldValue.serverTimestamp(),
    };
  }
}