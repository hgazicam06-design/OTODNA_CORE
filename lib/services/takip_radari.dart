import 'package:cloud_firestore/cloud_firestore.dart';

class TakipRadari {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> yorumOrtalamasiAl(String islemId, String bayiId, double ilkPuan, double ikinciPuan) async {
    try {
      double nihaiPuan = (ilkPuan + ikinciPuan) / 2;
      WriteBatch batch = _db.batch();

      // ✅ HATA ÇÖZÜLDÜ: DocumentRef -> DocumentReference
      DocumentReference islemRef = _db.collection('islemler').doc(islemId);
      batch.update(islemRef, {
        'ilk_puan': ilkPuan,
        'ikinci_puan': ikinciPuan,
        'nihai_puan': nihaiPuan,
        'adalet_motoru_calisti': true,
        'guncelleme_tarihi': FieldValue.serverTimestamp(),
      });

      // ✅ HATA ÇÖZÜLDÜ: DocumentRef -> DocumentReference
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'basarili',
        'bayi_isim': bayiId,
        'islem_detayi': 'ADALET MOTORU: İlk($ilkPuan) / Son($ikinciPuan) -> Nihai: $nihaiPuan',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      return {'basarili': true, 'nihai_puan': nihaiPuan, 'mesaj': 'Siber Adalet Motoru: Nihai Puan $nihaiPuan olarak mühürlendi.'};
    } catch (e) {
      return {'basarili': false, 'mesaj': 'SİBER HATA: Adalet Motoru Çöktü -> $e'};
    }
  }

  Future<void> dnaSkoruHesapla(String aracId, bool isKirmiziCarpiVar) async {
    try {
      DocumentReference aracRef = _db.collection('araclar').doc(aracId);
      await _db.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(aracRef);
        if (!snapshot.exists) return;

        double mevcutSkor = (snapshot.data() as Map<String, dynamic>)['dna_skoru']?.toDouble() ?? 100.0;
        double yeniSkor = isKirmiziCarpiVar ? (mevcutSkor - 15.0) : (mevcutSkor + 5.0);

        if (yeniSkor > 100) yeniSkor = 100;
        if (yeniSkor < 0) yeniSkor = 0;
        bool trafikRiski = yeniSkor < 60;

        transaction.update(aracRef, {
          'dna_skoru': yeniSkor,
          'trafik_riski': trafikRiski,
          'son_ekspertiz_tarihi': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) { print("SİBER HATA (DNA Motoru İşlem Göremedi): $e"); }
  }

  Future<void> araMuayeneKur(String aracId, String plaka, String parcaAdi, int omurAyi) async {
    try {
      DateTime bitisTarihi = DateTime.now().add(Duration(days: omurAyi * 30));
      await _db.collection('ara_muayeneler').add({
        'arac_id': aracId,
        'plaka': plaka,
        'parca_adi': parcaAdi,
        'muayene_tarihi': Timestamp.fromDate(bitisTarihi),
        'durum': 'Radarda Bekliyor',
        'olusturulma': FieldValue.serverTimestamp(),
      });
    } catch (e) { print("SİBER HATA (Radar Planlayıcı Çöktü): $e"); }
  }
}