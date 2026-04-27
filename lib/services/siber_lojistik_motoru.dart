import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🚀 OTO ÇIĞIR SİBER LOJİSTİK VE FİNANS MOTORU
/// Taksiciler ve müşteriler arasındaki fiyat, ceza, gizlilik ve sadakat işlemlerinin
/// Firestore tabanlı arka uç (Backend) servisi.
class SiberLojistikMotoru {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =======================================================================
  // 1. GİZLİLİK VE MASKELEME (KVKK & TACİZ KALKANI)
  // =======================================================================
  
  /// İsmin sadece ilk harfini bırakıp gerisini yıldızlar (Örn: Gazi Yılmaz -> Gazi Y***)
  static String isimMaskele(String tamIsim) {
    if (tamIsim.isEmpty) return "Bilinmeyen";
    List<String> parcalar = tamIsim.split(' ');
    if (parcalar.length == 1) {
      if (parcalar[0].length <= 2) return parcalar[0];
      return "${parcalar[0].substring(0, 2)}***";
    }
    
    String ad = parcalar[0];
    String soyad = parcalar.sublist(1).join(' ');
    String maskeliSoyad = soyad.isNotEmpty ? "${soyad[0]}***" : "";
    
    return "$ad $maskeliSoyad";
  }

  // =======================================================================
  // 2. SADAKAT PROGRAMI VE DİNAMİK İNDİRİM HESAPLAYICI
  // =======================================================================

  /// Müşterinin sadakat puanına göre %2 ile %10 arası değişken indirim oranı verir.
  /// Her 100 puan = +%0.5 indirim. (Maksimum %10).
  static double sadakatIndirimOraniHesapla(int yolcuPuani) {
    double bazIndirim = 0.02; // Varsayılan %2 (OtoDNA Yeni Üye İndirimi)
    double ekstraIndirim = (yolcuPuani / 100) * 0.005; // 1000 puan = %5 ekstra
    
    double toplamIndirim = bazIndirim + ekstraIndirim;
    if (toplamIndirim > 0.10) {
      toplamIndirim = 0.10; // Max %10 indirim sınırı (Şirket zararına girmesin)
    }
    return toplamIndirim;
  }

  // =======================================================================
  // 3. ŞOFÖR CEZA & ADLİ BİLİŞİM MOTORU
  // =======================================================================

  /// Şoför çağrıyı reddettiğinde veya kural ihlali yaptığında çalışır.
  /// Hem Kuantum puanını düşürür hem de Siber İstihbarat Logu atar.
  Future<void> soforCezaKes(String soforUid, int cezaPuani, String sebep) async {
    try {
      DocumentReference soforRef = _db.collection('kullanicilar').doc(soforUid);
      
      await _db.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(soforRef);
        if (!snapshot.exists) return;

        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        int mevcutPuan = data['cigirPuani'] ?? 100;
        int yeniPuan = mevcutPuan - cezaPuani;
        if (yeniPuan < 0) yeniPuan = 0;

        // Puanı güncelle
        transaction.update(soforRef, {'cigirPuani': yeniPuan});

        // Adli Bilişim Logu (Immutable Security Log)
        DocumentReference logRef = _db.collection('siber_istihbarat_loglari').doc();
        transaction.set(logRef, {
          'tip': 'CEZA',
          'hedefUid': soforUid,
          'sebep': sebep,
          'cezaMiktari': cezaPuani,
          'eskiPuan': mevcutPuan,
          'yeniPuan': yeniPuan,
          'tarih': FieldValue.serverTimestamp(),
          'sistemTetikleyicisi': 'SiberLojistikMotoru'
        });
      });
      developer.log("🚨 ŞOFÖR CEZALANDIRILDI: $cezaPuani Puan Kesildi.");
    } catch (e) {
      developer.log("Ceza Kesme Hatası: $e");
    }
  }

  // =======================================================================
  // 4. KÖR NOKTA (TACİZ KALKANI) - KARA LİSTE
  // =======================================================================

  /// Yolcunun şoförü, veya şoförün yolcuyu engellemesini sağlar.
  Future<void> karaListeyeEkle(String kimEngellediUid, String engellenenUid) async {
    try {
      await _db.collection('kullanicilar').doc(kimEngellediUid).update({
        'kara_liste': FieldValue.arrayUnion([engellenenUid])
      });
    } catch (e) {
      developer.log("Kara Liste Hatası: $e");
    }
  }

  // =======================================================================
  // 5. 5 KM RADAR SİMÜLASYONU VE ARAMA
  // =======================================================================
  
  /// (GeoFlutterFire veya benzeri bir algoritma ile çalışır. 
  /// Burada sistem mimarisini oturtmak için taslak stream dönülmüştür.)
  Stream<List<Map<String, dynamic>>> getYakindakiSoforler(double musteriLat, double musteriLon, {int maxMesafeKm = 5}) {
    // Gerçek senaryoda burada GeoPoint sorgusu yapılır.
    // Şimdilik Kuantum Radar UI'ını besleyecek Mock data akışı:
    return Stream.value([
      {
        "uid": "SOFOR_001",
        "plaka": "34 TAK 01", 
        "soforAdi": isimMaskele("Ali Kaptan"), 
        "durakAdi": "Kuantum Merkez Taksi",
        "arac": "Renault Megane", 
        "mesafe": 1.2, 
        "puan": 98, 
        "yildiz": 4.9,
        "yorumSayisi": 124,
        "dnaRaporuTemiz": true,
        "isVip": true
      },
      {
        "uid": "SOFOR_002",
        "plaka": "34 SBR 99", 
        "soforAdi": isimMaskele("Hasan Şahin"), 
        "durakAdi": "Siber Kalkan Durağı",
        "arac": "Fiat Egea", 
        "mesafe": 3.4, 
        "puan": 88, 
        "yildiz": 4.1,
        "yorumSayisi": 45,
        "dnaRaporuTemiz": true,
        "isVip": false
      },
      {
        "uid": "SOFOR_003",
        "plaka": "34 KRM 05", 
        "soforAdi": isimMaskele("Mehmet Kara"), 
        "durakAdi": "Bağımsız Şoför",
        "arac": "Ford Tourneo", 
        "mesafe": 4.1, 
        "puan": 65, 
        "yildiz": 3.2,
        "yorumSayisi": 12,
        "dnaRaporuTemiz": false,
        "isVip": false
      }
    ]);
  }
}
