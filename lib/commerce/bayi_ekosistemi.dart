import 'package:cloud_firestore/cloud_firestore.dart';

/// BAYİ YILDIZ VE ROZET SİSTEMİ (Altın, Gümüş, Bronz ve Blacklist)
class BayiEkosistemi {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> bayiPuaniGuncelle(String bayiId, int yeniYildiz) async {
    String rozet = "Bronz";
    bool blacklist = false;

    if (yeniYildiz == 5) rozet = "Altın";
    else if (yeniYildiz == 4) rozet = "Gümüş";
    else if (yeniYildiz <= 1) {
      rozet = "Blacklist";
      blacklist = true;
    }

    await _db.collection('bayiler').doc(bayiId).update({
      'yildiz_sayisi': yeniYildiz,
      'rozet': rozet,
      'is_blacklisted': blacklist,
      'son_guncelleme': FieldValue.serverTimestamp(),
    });
  }
}