import 'package:cloud_firestore/cloud_firestore.dart';

class ReturnInvoiceEngine {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Geri iade sürecini başlatır ve bakiyeleri Kuantum hızıyla mahsuplaşır.
  Future<void> processReturn({
    required String transactionId,
    required String dealerId,
    required double grossPrice,
    required bool isCorporate,
  }) async {
    final double gaziPayi = grossPrice * 0.12;
    final double dealerHakedisi = grossPrice - gaziPayi;
    
    final batch = _db.batch();
    
    // İşlemi İptal Edildi olarak işaretle
    final transactionRef = _db.collection('finansal_islemler').doc(transactionId);
    batch.update(transactionRef, {
      'is_returned': true,
      'return_type': isCorporate ? 'Iade_Faturasi_Bekleniyor' : 'Gider_Pusulasi_Olusturuldu',
      'logistics_status': 'returned_to_stock',
    });
    
    // Bayi Bakiyesinden geri çek
    final dealerRef = _db.collection('firma_cuzdanlari').doc(dealerId);
    batch.set(dealerRef, {
      'bakiye': FieldValue.increment(-dealerHakedisi), // Bayiden geri alındı
    }, SetOptions(merge: true));
    
    // Gazi Payını 'İptal Edilen Kazanç' a kaydır (Muhasebe şeffaflığı için)
    final karargahRef = _db.collection('siber_merkez').doc('iptal_edilen_kazanclar');
    batch.set(karargahRef, {
      'toplam_iptal': FieldValue.increment(gaziPayi),
      'son_guncelleme': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    
    // Toplam reel kazançtan düşürüyoruz ki Karargah kasasında açık çıkmasın
    final gaziAnaRef = _db.collection('siber_merkez').doc('gazi_bakiye');
    batch.set(gaziAnaRef, {
      'toplam_kazanc': FieldValue.increment(-gaziPayi),
    }, SetOptions(merge: true));

    await batch.commit();
  }
}
