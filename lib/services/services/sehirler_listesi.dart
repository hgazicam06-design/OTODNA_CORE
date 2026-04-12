import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM KÜRESEL KONUM MOTORU (KureselKonumMotoru)
/// OtoDNA'nın faaliyet gösterdiği ülke, bölge ve şehir haritalarını
/// Kuantum Ağından (Firebase) çeker ve Karargah operasyonlarına sunar.
class KureselKonumMotoru {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 🌍 1. FİREBASE CANLI LİSTELEYİCİ (SESSİZ ÇÖKÜŞ İMHA EDİLDİ) ──────────
  /// Cihazı yormaz, sadece seçilen ülkeye ait şehirleri anında çeker.
  static Future<List<String>> sehirleriGetir(String ulkeKodu) async {
    try {
      developer.log("SİBER RADAR: '$ulkeKodu' kodlu ülke için Kuantum Haritası taranıyor...");

      QuerySnapshot snapshot = await _db.collection('kuresel_harita')
          .where('code', isEqualTo: ulkeKodu.toUpperCase())
          .where('operasyona_acik_mi', isEqualTo: true) // Operasyon durdurulmuşsa veri çekme!
          .get();

      if (snapshot.docs.isEmpty) {
        developer.log("SİBER UYARI: '$ulkeKodu' için operasyonel harita bulunamadı veya ağ kapalı!");
        return [];
      }

      // Kuantum Çözümleme: Ülke -> Bölgeler -> Şehirler
      List<String> tumSehirler = [];
      var ulkeData = snapshot.docs.first.data() as Map<String, dynamic>;
      var regions = ulkeData['regions'] as List<dynamic>? ?? [];

      for (var region in regions) {
        var cities = region['cities'] as List<dynamic>? ?? [];
        for (var city in cities) {
          tumSehirler.add(city['name'] ?? 'Bilinmeyen Şehir');
        }
      }

      tumSehirler.sort(); // Kullanıcılar kolay bulsun diye A-Z alfabetik sıralama
      developer.log("SİBER İSTİHBARAT: $ulkeKodu için ${tumSehirler.length} şehir başarıyla radara alındı.");
      return tumSehirler;

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Harita Kuantum Bağlantı Hatası!", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ: UI'a Kırmızı Alarm Fırlat!
      throw Exception("SİBER HARİTA HATASI: Küresel Konum Motoru arızalandı. Lütfen ağınızı kontrol edin!");
    }
  }

  // ── 🚀 2. SİBER HARİTA YÜKLEYİCİ VE TOHUMLAMA (SADECE ADMİN) ─────────────
  /// Admin panelinde bir butona basılır ve bu sabit liste Firebase'e sonsuza dek mühürlenir.
  static Future<void> haritayiFirebaseeBas({required String adminId}) async {
    try {
      developer.log("SİBER HAREKAT: $adminId yetkilisi Ana Karargah Kuantum Haritasını tohumluyor...");

      // Sabit Listeler (Veritabanına Tohumlanacak Kaynak Veriler)
      final Map<String, String> turkiyeSehirleri = {
        "01 Adana": "Akdeniz",
        "06 Ankara": "İç Anadolu",
        "34 İstanbul": "Marmara",
        "40 Kırşehir": "İç Anadolu",
      };

      final Map<String, String> almanyaEyaletleri = {
        "Berlin": "Kuzey Almanya",
        "Münih": "Bavyera",
        "Hamburg": "Kuzey Almanya",
        "Frankfurt": "Hessen",
        "Stuttgart": "Baden-Württemberg",
      };

      // ⛓️ ATOMİK ZIRH: WriteBatch (Verileri yarım yamalak değil, tek hamlede yazar)
      WriteBatch batch = _db.batch();

      // 🇹🇷 TÜRKİYE'Yİ İNŞA ET VE KASAYA KOY
      DocumentReference trRef = _db.collection('kuresel_harita').doc('TR_HQ');
      batch.set(trRef, _ulkeVerisiniHazirla("Türkiye", "TR", turkiyeSehirleri));

      // 🇩🇪 ALMANYA'YI İNŞA ET VE KASAYA KOY
      DocumentReference deRef = _db.collection('kuresel_harita').doc('DE_OP');
      batch.set(deRef, _ulkeVerisiniHazirla("Almanya", "DE", almanyaEyaletleri));

      // 🚨 KARARGAH KURALI: KAYIT DIŞI OPERASYON YASAKTIR (Loglama Eklendi)
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'KURESEL_HARITA_TOHUMLAMA',
        'islem_detayi': 'SİBER HAREKAT: $adminId ID\'li Admin, TR ve DE operasyon bölgelerini Kuantum Ağına mühürledi.',
        'tarih': FieldValue.serverTimestamp(),
      });

      // 🚀 FÜZELERİ ATEŞLE (Canlı Kayıt)
      await batch.commit();
      developer.log("SİBER ONAY: ✅ KÜRESEL HARİTA FİREBASE'E BAŞARIYLA YÜKLENDİ VE LOGLANDI!");

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Siber Harita Yükleme Hatası!", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ
      throw Exception("KARARGAH HATASI: Küresel harita tohumlaması başarısız oldu!");
    }
  }

  // ── 🧠 YARDIMCI KUANTUM ZEKA: Hiyerarşik Veri Çözümleyici ───────────────
  static Map<String, dynamic> _ulkeVerisiniHazirla(String ulkeAdi, String ulkeKodu, Map<String, String> sehirBolgeMap) {
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
        // 🚨 SİBER ANA KARARGAH KONTROLÜ (Ankara'yı otonom tanır)
        'merkez_us_mu': sehirAd.contains("Ankara"),
      });
    });

    // Kuantum Ağı yapısına tam uygun hale getir
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