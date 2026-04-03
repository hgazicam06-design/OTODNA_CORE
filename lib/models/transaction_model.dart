import 'package:cloud_firestore/cloud_firestore.dart';

// transaction_model.dart - Kuantum Siber Kasa ve Muhasebe Motoru

class TransactionRecord {
  final String? id; // Firebase Document ID
  final String firmId;
  final String firmAdi;
  final String islemTipi; // Örn: "Yedek Parça Satışı", "Randevu Bedeli", "VIP Abonelik"

  // 💰 FİNANSAL BÖLÜNME (MUHASEBE MÜHRÜ)
  final double toplamTutar; // Müşterinin kartından çekilen toplam para
  final double otodnaPayi; // Bize kalan net kazanç (%12 Komisyon, Randevu Bedeli vb.)
  final double esnafHakedisi; // Esnafın hesabına (IBAN'a) yatacak net para

  final String durum; // 'Bekliyor', 'Onaylandı', 'Tamamlandı', 'İptal'
  final DateTime tarih;

  TransactionRecord({
    this.id,
    required this.firmId,
    required this.firmAdi,
    required this.islemTipi,
    required this.toplamTutar,
    required this.otodnaPayi,
    required this.esnafHakedisi,
    this.durum = 'Bekliyor',
    DateTime? tarih,
  }) : tarih = tarih ?? DateTime.now();

  // 🚀 FİREBASE'E YAZMA MOTORU (İşlem Gerçekleştiği An Kilitlenir)
  Map<String, dynamic> toMap() {
    return {
      'firm_id': firmId,
      'firm_adi': firmAdi,
      'islem_tipi': islemTipi,
      'toplam_tutar': toplamTutar,
      'otodna_payi': otodnaPayi,
      'esnaf_hakedisi': esnafHakedisi,
      'durum': durum,
      'tarih': FieldValue.serverTimestamp(),
    };
  }

  // 📥 FİREBASE'DEN OKUMA MOTORU (Admin veya Esnaf Kendi Cüzdanına Baktığında)
  factory TransactionRecord.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return TransactionRecord(
      id: doc.id,
      firmId: data['firm_id'] ?? '',
      firmAdi: data['firm_adi'] ?? 'Gizli Firma',
      islemTipi: data['islem_tipi'] ?? 'Bilinmeyen İşlem',
      toplamTutar: (data['toplam_tutar'] ?? 0).toDouble(),
      otodnaPayi: (data['otodna_payi'] ?? 0).toDouble(),
      esnafHakedisi: (data['esnaf_hakedisi'] ?? 0).toDouble(),
      durum: data['durum'] ?? 'Bekliyor',
      tarih: (data['tarih'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}