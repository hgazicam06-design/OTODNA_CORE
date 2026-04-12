import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer; // 🚀 SİBER LOGLAMA ZIRHI EKLENDİ

class TakipRadari {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── ⚖️ SİBER ADALET MOTORU ──────────────────────────────────────────────
  Future<Map<String, dynamic>> yorumOrtalamasiAl(String islemId, String bayiId, double ilkPuan, double ikinciPuan) async {
    try {
      developer.log("SİBER ADALET: $bayiId için adalet terazisi çalıştırılıyor... İlk: $ilkPuan, Son: $ikinciPuan");

      double nihaiPuan = (ilkPuan + ikinciPuan) / 2;
      WriteBatch batch = _db.batch();

      // İşlem Kodu Mühürleme
      DocumentReference islemRef = _db.collection('islemler').doc(islemId);
      batch.update(islemRef, {
        'ilk_puan': ilkPuan,
        'ikinci_puan': ikinciPuan,
        'nihai_puan': nihaiPuan,
        'adalet_motoru_calisti': true,
        'guncelleme_tarihi': FieldValue.serverTimestamp(),
      });

      // Kara Kutu (Sistem Logları) Mühürleme
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'ADALET_MOTORU',
        'bayi_isim': bayiId,
        'islem_detayi': 'ADALET MOTORU: İlk($ilkPuan) / Son($ikinciPuan) -> Nihai: $nihaiPuan',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      developer.log("SİBER MÜHÜR: Nihai puan $nihaiPuan olarak Kuantum Ağına kilitlendi.");
      return {'basarili': true, 'nihai_puan': nihaiPuan, 'mesaj': 'Siber Adalet Motoru: Nihai Puan $nihaiPuan olarak mühürlendi.'};

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Adalet Motoru arızalandı!", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ: UI Tarafına Kırmızı Alarm Fırlat!
      throw Exception("SİBER ADALET HATASI: Nihai puan Karargaha işlenemedi!");
    }
  }

  // ── 🧬 KUANTUM DNA SKORU HESAPLAYICI ─────────────────────────────────────
  Future<void> dnaSkoruHesapla(String aracId, bool isKirmiziCarpiVar) async {
    try {
      developer.log("SİBER RADAR: $aracId şaseli aracın DNA Skoru hesaplanıyor...");
      DocumentReference aracRef = _db.collection('araclar').doc(aracId);

      await _db.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(aracRef);
        if (!snapshot.exists) {
          developer.log("SİBER İHLAL: Araç Karargah radarında bulunamadı!");
          throw Exception("İSTİHBARAT HATASI: Hedef araç Kuantum Ağında yok!");
        }

        double mevcutSkor = (snapshot.data() as Map<String, dynamic>)['dna_skoru']?.toDouble() ?? 100.0;
        double yeniSkor = isKirmiziCarpiVar ? (mevcutSkor - 15.0) : (mevcutSkor + 5.0);

        if (yeniSkor > 100) yeniSkor = 100;
        if (yeniSkor < 0) yeniSkor = 0;
        bool trafikRiski = yeniSkor < 60; // 60'ın altı kırmızı alarm (Trafik Riski)

        transaction.update(aracRef, {
          'dna_skoru': yeniSkor,
          'trafik_riski': trafikRiski,
          'son_ekspertiz_tarihi': FieldValue.serverTimestamp(),
        });

        developer.log("SİBER DNA: Yeni skor -> $yeniSkor | Trafik Riski -> $trafikRiski");
      });

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: DNA Motoru İşlem Göremedi!", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ (PRINT) ENGELLENDİ: Sistemi Uyar!
      throw Exception("KUANTUM DNA HATASI: Aracın skoru Karargaha işlenemedi!");
    }
  }

  // ── ⏱️ AKILLI ARA-MUAYENE PLANLAYICI ─────────────────────────────────────
  Future<void> araMuayeneKur(String aracId, String plaka, String parcaAdi, int omurAyi) async {
    try {
      developer.log("SİBER RADAR: $plaka ($aracId) aracı için '$parcaAdi' ara-muayene planlanıyor...");

      DateTime bitisTarihi = DateTime.now().add(Duration(days: omurAyi * 30));

      await _db.collection('ara_muayeneler').add({
        'arac_id': aracId,
        'plaka': plaka,
        'parca_adi': parcaAdi,
        'muayene_tarihi': Timestamp.fromDate(bitisTarihi),
        'durum': 'Radarda Bekliyor',
        'olusturulma': FieldValue.serverTimestamp(),
      });

      developer.log("SİBER PLANLAYICI: $omurAyi ay sonrası için muayene radarı kuruldu ve mühürlendi!");

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Radar Planlayıcı Çöktü!", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ (PRINT) ENGELLENDİ
      throw Exception("RADAR HATASI: Ara-Muayene planı Kuantum Ağına kilitlenemedi!");
    }
  }
}