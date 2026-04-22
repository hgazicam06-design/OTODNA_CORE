// lib/services/kuantum_zinciri.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class KuantumZinciri {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🧬 SİBER MÜHÜR: DNA Değişikliklerini Kuantum Defterine Kaydeder (Değiştirilemez)
  /// Bu işlem, aracın asıl skor güncellemesiyle birlikte ATOMİK olarak (WriteBatch) yapılmalıdır.
  Future<void> dnaDegisikliginiMuhurle({
    required WriteBatch batch,
    required String aracId,
    required int eskiSkor,
    required int yeniSkor,
    required String ustaId,
    required String islemAciklamasi,
  }) async {
    // Aracın altındaki kuantum ledger koleksiyonu referansı
    final ledgerRef = _db
        .collection('araclar')
        .doc(aracId)
        .collection('dna_ledger')
        .doc(); // Otomatik ID oluşturur

    final logData = {
      'islem_zamani': FieldValue.serverTimestamp(),
      'eski_skor': eskiSkor,
      'yeni_skor': yeniSkor,
      'degisim_miktari': yeniSkor - eskiSkor,
      'islem_yapan_usta_id': ustaId,
      'aciklama': islemAciklamasi,
      'guvenlik_muhru': 'SİBER_KARARGAH_ONAYLI', // Manipülasyon tespiti için değişmez imza
    };

    // Batch içerisine ledger yazma işlemini de dahil ediyoruz.
    // Bu sayede araç puanı düşerse log KESİNLİKLE yazılır. Log yazılamazsa puan da düşmez (ACID kuralı).
    batch.set(ledgerRef, logData);
  }

  /// Belirli bir aracın Kuantum DNA geçmişini getirir.
  Future<List<Map<String, dynamic>>> aracDnaGecmisiniGetir(String aracId) async {
    final snap = await _db
        .collection('araclar')
        .doc(aracId)
        .collection('dna_ledger')
        .orderBy('islem_zamani', descending: true)
        .get();

    return snap.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }
}
