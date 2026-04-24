import 'package:cloud_firestore/cloud_firestore.dart';

class AccountingEngine {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // %12 Komisyon Kuralı (Siber Komutan Payı)
  static const double gaziKomisyonOrani = 0.12;

  Future<void> processSale({
    required String transactionId,
    required String dealerId,
    required double grossPrice,
    required String itemDetails,
  }) async {
    final double gaziPayi = grossPrice * gaziKomisyonOrani;
    final double dealerHakedisi = grossPrice - gaziPayi;
    
    final batch = _db.batch();
    
    final transactionRef = _db.collection('finansal_islemler').doc(transactionId);
    batch.set(transactionRef, {
      'transaction_id': transactionId,
      'dealer_id': dealerId,
      'gross_price': grossPrice,
      'gazi_payi_12': gaziPayi,
      'dealer_hakedisi': dealerHakedisi,
      'logistics_status': 'in_transit', // Başlangıç lojistik durumu
      'created_at': FieldValue.serverTimestamp(),
      'item_details': itemDetails,
      'is_returned': false,
    });
    
    // Dealer bakiyesini güncelle
    final dealerRef = _db.collection('firma_cuzdanlari').doc(dealerId);
    batch.set(dealerRef, {
      'bakiye': FieldValue.increment(dealerHakedisi),
      'son_guncelleme': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    
    // Karargah bakiyesini güncelle
    final karargahRef = _db.collection('siber_merkez').doc('gazi_bakiye');
    batch.set(karargahRef, {
      'toplam_kazanc': FieldValue.increment(gaziPayi),
      'son_guncelleme': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    
    await batch.commit();
  }

  // 15 Günlük Lojistik Kırmızı Alarm Kontrolü
  Future<void> checkLogisticsAlarms() async {
    try {
      final threshold15Days = DateTime.now().subtract(const Duration(days: 15));
      final query = await _db.collection('finansal_islemler')
        .where('logistics_status', isEqualTo: 'in_transit')
        .where('created_at', isLessThanOrEqualTo: Timestamp.fromDate(threshold15Days))
        .get();
        
      for (var doc in query.docs) {
        await doc.reference.update({'logistics_status': 'pending_15_days_red_alert'});
        // Not: Burada NotificationService çağrılarak bayiye ve merkeze push notification atılabilir.
      }
    } catch (e) {
      print("Siber Karargah: Lojistik Alarm Tarama Hatası -> $e");
    }
  }
}
