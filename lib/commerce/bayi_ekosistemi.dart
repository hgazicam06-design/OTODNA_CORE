// lib/commerce/bayi_ekosistemi.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// 🛡️ BAYİ YILDIZ VE ROZET SİSTEMİ (Altın, Gümüş, Bronz, Boş ve Blacklist)
class BayiEkosistemi {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> bayiPuaniGuncelle(String bayiId, int yeniYildiz) async {
    String rozet = "Boş"; // 2 Yıldız durumu için siber varsayılan
    bool blacklist = false;

    if (yeniYildiz == 5) {
      rozet = "Altın";
    } else if (yeniYildiz == 4) {
      rozet = "Gümüş";
    } else if (yeniYildiz == 3) {
      rozet = "Bronz";
    } else if (yeniYildiz <= 1) {
      rozet = "Blacklist";
      blacklist = true; // 🚨 Sistemden siber men etme sinyali
    }

    // 🔥 Firebase'e Kuantum Mührünü Vur
    await _db.collection('bayiler').doc(bayiId).update({
      'yildiz_sayisi': yeniYildiz,
      'rozet': rozet,
      'is_blacklisted': blacklist,
      'son_guncelleme': FieldValue.serverTimestamp(),
    });
  }
}