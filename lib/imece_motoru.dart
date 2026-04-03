// lib/utils/imece_motoru.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM İMECE OPERASYON MOTORU (SiberImeceMotoru)
/// Başka ildeki bayinin yaptığı telafi işlemini sisteme işler ve Finans Motorunu tetikler.
class SiberImeceMotoru {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 🔄 İMECE TELAFİ İŞLEMİ MÜHRÜ ──
  static Future<void> imeceIslemiKaydet({
    required String sorunluBayiId,
    required String cozenBayiId,
    required double tutar,
    required String aracSaseNo,
  }) async {
    developer.log("🚨 SİBER İMECE DEVREDE: $sorunluBayiId kodlu bayinin hatası için $cozenBayiId müdahale ediyor!");

    try {
      // İmece operasyonunu Karargah veritabanına mühürle
      DocumentReference imeceRaporu = await _db.collection('imece_operasyonlari').add({
        'sorunlu_bayi_id': sorunluBayiId,
        'cozen_bayi_id': cozenBayiId,
        'tutar': tutar,
        'arac_sase_no': aracSaseNo,
        'durum': 'MAHSUPLASMA_BEKLIYOR', // Finans motoru bu durumu okuyup parayı kesecek
        'islem_tarihi': FieldValue.serverTimestamp(),
      });

      developer.log("✅ İMECE ONAYI: ₺$tutar tutarındaki telafi işlemi [${imeceRaporu.id}] referansıyla mühürlendi.");
      developer.log("💰 SİBER NOT: Finans motoru bir sonraki hakedişte bu tutarı merkez havuz üzerinden mahsup edecektir.");

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: İmece işlemi Karargaha iletilemedi!", error: e);
      throw Exception("Kuantum İmece Motoru Başarısız: $e");
    }
  }
}