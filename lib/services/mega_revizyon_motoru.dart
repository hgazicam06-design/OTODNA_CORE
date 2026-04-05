import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class MegaRevizyonMotoru {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🔴 SİBER WRITEBATCH PROTOKOLÜ VE %12 FİNANS MOTORU
  Future<Map<String, dynamic>> islemMuhurle({
    required String bayiId,
    required String bayiIsim,
    required String plaka,
    required String aracTipi,
    required double toplamMaliyet,
    required List<Map<String, dynamic>> degisenParcalar,
  }) async {
    try {
      // 1. KİLİTLİ KOORDİNAT (Siber Noter - Çift Yönlü Onayın İlk Adımı)
      // Kullanıcıdan konum izni alındığı varsayılmıştır.
      Position pozisyon = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      // 2. FİNANSAL HESAPLAMA (%12 Karargah Payı - Asla Değişmez)
      double komutanPayi = toplamMaliyet * 0.12;

      // 3. ATOMİK WRITEBATCH ATEŞLEMESİ (Ya Hep Ya Hiç!)
      WriteBatch siberTop = _db.batch();

      // Ana İşlem Referansı oluştur (Otomatik ID ile)
      DocumentRef islemRef = _db.collection('islemler').doc();

      siberTop.set(islemRef, {
        'islem_id': islemRef.id,
        'bayi_id': bayiId,
        'bayi_isim': bayiIsim,
        'plaka': plaka,
        'arac_tipi': aracTipi,
        'toplam_maliyet': toplamMaliyet,
        'komutan_payi': komutanPayi, // Doğrudan kasaya
        'tarih': FieldValue.serverTimestamp(),
        'bayi_onay': true, // Bayi kendi yüklediği için peşinen el sıkışmış sayılır
        'bayi_konum': GeoPoint(pozisyon.latitude, pozisyon.longitude), // Kanıt Koordinatı
        'kullanici_onay': false, // Müşteri paneline "Onay Bekliyor" olarak düşecek
        'onay_durumu': 'musteri_onayi_bekliyor',
        'parcalar': degisenParcalar, // İçinde parça adı ve varsa görsel yolu var
      });

      // 4. SİSTEM LOGLARINA KARA KUTU KAYDI (Admin İstihbaratı)
      DocumentRef logRef = _db.collection('sistem_loglari').doc();
      siberTop.set(logRef, {
        'islem_turu': 'basarili',
        'islem_detayi': 'MEGA REVİZYON: $plaka ($aracTipi). Ciro: ₺$toplamMaliyet | Komutan Payı: ₺$komutanPayi',
        'bayi_isim': bayiIsim,
        'tarih': FieldValue.serverTimestamp()
      });

      // Bütün verileri aynı anda Kuantum Ağına sapla!
      await siberTop.commit();

      return {'basarili': true, 'mesaj': 'SİBER MÜHÜR BASILDI: İşlem ağa kilitlendi.'};

    } catch (e) {
      return {'basarili': false, 'mesaj': 'SİBER HATA: Kayıt başarısız. $e'};
    }
  }
}