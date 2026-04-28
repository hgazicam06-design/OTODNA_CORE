import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

class AccountingEngine {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // %12 Komisyon Kuralı (OtoDNA Kurumsal Hizmet Bedeli)
  static const double kurumsalKomisyonOrani = 0.12;

  Future<void> processSale({
    required String transactionId,
    required String dealerId,
    required double grossPrice,
    required String itemDetails,
  }) async {
    final double kurumsalPay = grossPrice * kurumsalKomisyonOrani;
    final double dealerHakedisi = grossPrice - kurumsalPay;
    
    final batch = _db.batch();
    
    final transactionRef = _db.collection('finansal_islemler').doc(transactionId);
    batch.set(transactionRef, {
      'transaction_id': transactionId,
      'dealer_id': dealerId,
      'gross_price': grossPrice,
      'gazi_payi_12': kurumsalPay, // DB Şeması bozulmasın diye aynı bırakıldı
      'dealer_hakedisi': dealerHakedisi,
      'logistics_status': 'in_transit', // Başlangıç lojistik durumu
      'created_at': FieldValue.serverTimestamp(),
      'item_details': itemDetails,
      'is_returned': false,
    });
    
    // Bayi bakiyesini güncelle
    final dealerRef = _db.collection('firma_cuzdanlari').doc(dealerId);
    batch.set(dealerRef, {
      'bakiye': FieldValue.increment(dealerHakedisi),
      'son_guncelleme': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    
    // Kurumsal Merkez bakiyesini güncelle
    final karargahRef = _db.collection('siber_merkez').doc('gazi_bakiye');
    batch.set(karargahRef, {
      'toplam_kazanc': FieldValue.increment(kurumsalPay),
      'son_guncelleme': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    
    await batch.commit();
  }

  // 15 Günlük Lojistik Kırmızı Alarm Kontrolü
  Future<void> checkLogisticsAlarms() async {
    try {
      final threshold15Days = DateTime.now().subtract(Duration(days: 15));
      final query = await _db.collection('finansal_islemler')
        .where('logistics_status', isEqualTo: 'in_transit')
        .where('created_at', isLessThanOrEqualTo: Timestamp.fromDate(threshold15Days))
        .get();
        
      for (var doc in query.docs) {
        await doc.reference.update({'logistics_status': 'pending_15_days_red_alert'});
        // Not: Burada NotificationService çağrılarak bayiye ve merkeze kurumsal bildirim atılabilir.
      }
    } catch (e) {
      developer.log("OtoDNA Kurumsal Finans: Lojistik Alarm Tarama Hatası -> $e");
    }
  }

  // ── 📊 TEK VE MUTLAK BAYİ HESAPLAMASI (%12 KESİNTİ) ──────────────────────
  static Map<String, double> bayiSatisHesapla(double satisFiyati) {
    if (satisFiyati <= 0) {
      throw Exception("FİNANSAL HATA: Satış fiyatı 0 veya negatif olamaz!");
    }

    double otodnaNetPay = satisFiyati * 0.10;   // Net %10 Karargah
    double toplamKesinti = satisFiyati * kurumsalKomisyonOrani; // %12 (KDV dahil komisyon)
    double kdvPayi = toplamKesinti - otodnaNetPay; // %2
    double esnafaKalan = satisFiyati - toplamKesinti;

    return {
      'satis_fiyati': satisFiyati,
      'otodna_net_pay': otodnaNetPay,
      'kdv_tutari': kdvPayi,
      'toplam_kesinti': toplamKesinti,
      'esnafa_kalan_net': esnafaKalan,
    };
  }
}
