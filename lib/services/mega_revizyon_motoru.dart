import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:developer' as developer;

class MegaRevizyonMotoru {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🔴 SİBER WRITEBATCH PROTOKOLÜ VE %12 FİNANS MOTORU
  Future<void> islemMuhurle({
    required String bayiId,
    required String bayiIsim,
    required String plaka,
    required String aracTipi,
    required double toplamMaliyet,
    required List<Map<String, dynamic>> degisenParcalar,
  }) async {
    try {
      developer.log("SİBER PROTOKOL: $plaka plakalı araç için Mega Revizyon başlatıldı...");

      // 1. KİLİTLİ KOORDİNAT (Siber Noter - Çift Yönlü Onayın İlk Adımı)
      // Kullanıcıdan konum izni alındığı varsayılmıştır.
      developer.log("SİBER RADAR: GPS Kanıt Koordinatları aranıyor...");
      Position pozisyon = await Geolocator.getCurrentPosition(locationSettings: LocationSettings(accuracy: LocationAccuracy.high));

      // 2. FİNANSAL HESAPLAMA (%12 Karargah Payı - Asla Değişmez)
      double komutanPayi = toplamMaliyet * 0.12;

      // 3. ATOMİK WRITEBATCH ATEŞLEMESİ (Ya Hep Ya Hiç!)
      WriteBatch siberTop = _db.batch();

      // Ana İşlem Referansı oluştur (Otomatik ID ile) - DÜZELTME: DocumentReference
      DocumentReference islemRef = _db.collection('islemler').doc();

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

      // 4. SİSTEM LOGLARINA KARA KUTU KAYDI (Admin İstihbaratı) - DÜZELTME: DocumentReference
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      siberTop.set(logRef, {
        'islem_turu': 'MEGA_REVIZYON',
        'islem_detayi': 'MÜHÜR: $plaka ($aracTipi). Ciro: ₺$toplamMaliyet | Komutan Payı: ₺$komutanPayi',
        'bayi_isim': bayiIsim,
        'tarih': FieldValue.serverTimestamp()
      });

      // Bütün verileri aynı anda Kuantum Ağına sapla!
      await siberTop.commit();

      developer.log("SİBER MÜHÜR BASILDI: Revizyon işlemi Kuantum Ağına kilitlendi!");

    } catch (e) {
      developer.log("SİBER İHLAL: Mega Revizyon işlemi çöktü!", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ: UI tarafına kırmızı alarm fırlatılır.
      throw Exception("REVİZYON HATASI: İşlem mühürlenemedi. İnternet bağlantınızı ve GPS (Konum) izinlerinizi kontrol edin!");
    }
  }
}
