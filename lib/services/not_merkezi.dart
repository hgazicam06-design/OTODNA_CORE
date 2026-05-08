import 'package:cloud_firestore/cloud_firestore.dart';

class NotMerkezi {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🛡️ USTA VE KULLANICI İÇİN TAKİP NOTU OLUŞTURMA
  Future<void> takipNotuMuhurle({
    required String aracId,
    required String ustaNotu,
    required String kullaniciHatirlatma,
    required bool supheliDurum, // True ise sistem radar takibine alır
  }) async {
    
    // ⚔️ Karargah Kuralı: Boş veriyle mühürleme yapılamaz!
    if (ustaNotu.isEmpty) return;

    try {
      WriteBatch batch = _db.batch();
      DocumentReference aracRef = _db.collection('otodna_kayitlari').doc(aracId);

      // 1. Usta Görüşünü Aracın Genetiğine İşle
      batch.update(aracRef, {
        'son_islem_notu': ustaNotu,
        'siber_radar_durumu': supheliDurum ? 'TAKİPTE' : 'GÜVENLİ',
        'takip_tarihi': FieldValue.serverTimestamp(),
      });

      // 2. Kullanıcı İçin Özel Hatırlatıcı Kur (Notification Engine)
      batch.set(_db.collection('hatirlatmalar').doc(), {
        'arac_id': aracId,
        'mesaj': kullaniciHatirlatma,
        'durum': 'BEKLEMEDE',
        'olusturan': 'USTA_SİSTEMİ',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      print("Siber Notlar Mühürlendi! 🦅");
    } catch (e) {
      print("Mühürleme Hatası: $e");
    }
  }
}
