import 'package:cloud_firestore/cloud_firestore.dart';

/// ⚖️ SİBER HUKUK MOTORU (Tramer SMS NLP & Değer Kaybı Algoritması)
/// Kullanıcının yapıştırdığı 5664 SMS'ini okuyarak Ağır Hasar (Pert) tespiti yapar.
/// Eğer Pert ise işlemi bloke eder. Değilse kilometre ve kusur oranına göre
/// Yargıtay emsal simülasyonu yaparak tahmini değer kaybı tutarını ₺ olarak çıkarır.
class SiberHukukMotoru {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =======================================================================
  // 1. TRAMER SMS ZEKASI (Doğal Dil İşleme - NLP)
  // =======================================================================
  Future<Map<String, dynamic>> tramerAnaliziYap({
    required String smsMetni,
    required String saseNo,
    required int kilometre,
    required int kusurOrani,
  }) async {
    String ustMetin = smsMetni.toUpperCase();

    // 🚨 KURAL 1: AĞIR HASAR / PERT KALKANI
    // Hukuken ağır hasar kayıtlı araca değer kaybı ÇIKMAZ!
    if (ustMetin.contains("AĞIR HASARLI") || ustMetin.contains("PERT") || ustMetin.contains("AGIR HASAR")) {
      return {
        'basarili': false,
        'pertMi': true,
        'mesaj': "SİBER RED: Yapıştırdığınız mesajda 'Ağır Hasarlı (Pert)' kaydı tespit edilmiştir. Kanunen bu araca Değer Kaybı Davası AÇILAMAZ."
      };
    }

    // 🕵️ KURAL 2: GEÇMİŞ KAZA SAYISI İSTİHBARATI
    // "Carpma", "Carpisma" kelimelerinin geçiş sayısına bakarak kazaları say.
    int kazaSayisi = 0;
    kazaSayisi += _kelimeSay(ustMetin, "CARPMA");
    kazaSayisi += _kelimeSay(ustMetin, "CARPISMA");
    kazaSayisi += _kelimeSay(ustMetin, "KAZA");
    
    // (Gerçek projede Regex ile ₺/TL tutarları toplanıp araca işlenecek)

    // 🧠 KURAL 3: ARKA PLANDA OTO-DNA VERİTABANINA MÜHÜRLE
    // Kullanıcının haberi olmadan bu değerli kaza bilgisini aracın siciline işliyoruz.
    try {
      await _db.collection('araclar').doc(saseNo).set({
        'tramerKazaSayisi': kazaSayisi,
        'sonTramerSorguTarihi': FieldValue.serverTimestamp(),
        'agirHasarKaydiVarMi': false,
      }, SetOptions(merge: true));
    } catch (e) {
      print("Araç verisi güncellenemedi: $e");
    }

    // ⚖️ KURAL 4: YARGITAY DEĞER KAYBI ALGORİTMASI HESABI
    double tahminiTutar = _degerKaybiHesapla(kilometre, kusurOrani, kazaSayisi);

    if (tahminiTutar <= 0) {
      return {
        'basarili': false,
        'pertMi': false,
        'mesaj': "Kusur oranınız çok yüksek veya aracınızın kilometresi/geçmiş hasarları sınırın üzerinde olduğu için tazminat çıkmamıştır."
      };
    }

    return {
      'basarili': true,
      'tahminiTutar': tahminiTutar,
      'kazaSayisi': kazaSayisi,
      'mesaj': "Analiz Başarılı. Emsal tutar hesaplandı."
    };
  }

  // =======================================================================
  // 2. YARGITAY ALGORİTMASI HESAPLAMA MOTORU
  // =======================================================================
  double _degerKaybiHesapla(int km, int kusurOrani, int gecmisKazaSayisi) {
    // Kusur Oranı %100 ise Değer Kaybı YOKTUR.
    if (kusurOrani >= 100) return 0.0;

    // Temel Kuantum Değer Kaybı (Sanal Tutar)
    double bazTutar = 60000.0; 

    // Kusur Çarpanı (Örn: Kusur %25 ise paranin %75'ini alır)
    double kusurCarpani = (100 - kusurOrani) / 100;
    double tutar = bazTutar * kusurCarpani;

    // Kilometre Çarpanı (Araba eskiyse tazminat düşer)
    if (km < 30000) {
      tutar *= 1.2; // Yeni araba, değer kaybı daha çok yakar.
    } else if (km > 150000) {
      tutar *= 0.4; // Eski araba, değer çoktan düşmüş.
    } else if (km > 250000) {
      return 0.0; // 250bin KM üstüne genelde tazminat verilmez.
    }

    // Geçmiş Kaza Çarpanı (Araba zaten kazalıysa yeni kazada fazla değer kaybetmez)
    if (gecmisKazaSayisi == 1) {
      tutar *= 0.8;
    } else if (gecmisKazaSayisi >= 2) {
      tutar *= 0.5;
    }

    return tutar;
  }

  // =======================================================================
  // 3. AVUKATA SİBER DOSYA GÖNDERME
  // =======================================================================
  Future<bool> avukataDosyaAc(String saseNo, double tutar, String smsMetni) async {
    try {
      await _db.collection('siber_hukuk_dosyalari').add({
        'saseNo': saseNo,
        'tramerMesaji': smsMetni,
        'hesaplananTutar': tutar,
        'durum': 'Avukat Ataması Bekliyor',
        'acilisTarihi': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  int _kelimeSay(String metin, String aranan) {
    int sayac = 0;
    int index = metin.indexOf(aranan);
    while (index != -1) {
      sayac++;
      index = metin.indexOf(aranan, index + aranan.length);
    }
    return sayac;
  }
}
