import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chronic_issue_model.dart';

class ChronicRadarService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Kronik arızaları getir
  Future<List<ChronicIssueModel>> getChronicIssues({
    String? brand,
    String? model,
    String? engineType,
    String? transmissionType,
  }) async {
    Query query = _firestore.collection('chronic_issues');

    if (brand != null && brand.isNotEmpty) {
      query = query.where('brand', isEqualTo: brand);
    }
    if (model != null && model.isNotEmpty) {
      query = query.where('model', isEqualTo: model);
    }
    if (engineType != null && engineType.isNotEmpty) {
      query = query.where('engine_type', isEqualTo: engineType);
    }
    if (transmissionType != null && transmissionType.isNotEmpty) {
      query = query.where('transmission_type', isEqualTo: transmissionType);
    }

    try {
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ChronicIssueModel.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print("Siber Karargah: Kronik arıza çekme hatası: $e");
      return [];
    }
  }

  // Yeni kronik arıza kaydı (Bilirkişi / AI tarafından)
  Future<void> addChronicIssue(ChronicIssueModel issue) async {
    try {
      await _firestore.collection('chronic_issues').add(issue.toMap());
    } catch (e) {
      print("Siber Karargah: Kronik arıza ekleme hatası: $e");
    }
  }

  // Arka planda lokasyon bazlı vaka raporlama (İl/İlçe Haritası)
  Future<void> logGeographicFault(String issueId, String province, String district) async {
    try {
      final docRef = _firestore.collection('chronic_issues').doc(issueId);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;

        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> provinceStats = Map<String, dynamic>.from(data['province_stats'] ?? {});
        
        String locKey = '${province}_$district';
        int currentCount = (provinceStats[locKey] ?? 0) as int;
        provinceStats[locKey] = currentCount + 1;

        transaction.update(docRef, {'province_stats': provinceStats});
      });
    } catch (e) {
      print("Siber Karargah: Lokasyon hata kaydı hatası: $e");
    }
  }
}
