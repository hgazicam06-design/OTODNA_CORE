import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

// --- 1. MODEL KATMANI: BÖLGE KOMUTANI ---
class BolgeKomutani {
  final String id;
  final String isim;
  final String sorumluOlduguBolge;
  final String rutbe;

  BolgeKomutani({
    required this.id,
    required this.isim,
    required this.sorumluOlduguBolge,
    required this.rutbe,
  });

  Map<String, dynamic> toMap() {
    return {
      'isim': isim,
      'sorumlu_bolge': sorumluOlduguBolge,
      'rutbe': rutbe,
      'atanma_tarihi': FieldValue.serverTimestamp(),
      'yetki_seviyesi': 2,
      'aktif': true,
    };
  }
}

// --- 2. SERVİS KATMANI: KUANTUM İSTİHBARAT VE YETKİ MOTORU ---
class BolgeYonetimServisi {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- 📡 SİBER RÖNTGEN: İL BAZLI CANLI FİREBASE ANALİZİ ---
  Future<Map<String, dynamic>> ilAnaliziYap(String sehir) async {
    try {
      developer.log("SİBER RADAR: $sehir için Bölge İstihbarat taraması başlatıldı...");

      // 1. O şehre ait aktif tüm bayileri Kuantum Ağında tara
      final querySnapshot = await _db
          .collection('bayiler')
          .where('il', isEqualTo: sehir)
          .where('aktif_mi', isEqualTo: true)
          .get();

      double sehirToplamCiro = 0.0;
      int kritikBayiSayisi = 0;
      List<Map<String, dynamic>> riskliBayiler = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        double bayiCiro = (data['aylik_ciro'] ?? 0).toDouble();
        sehirToplamCiro += bayiCiro;

        int sikayet = data['sikayet_sayisi'] ?? 0;
        if (sikayet >= 5) {
          kritikBayiSayisi++;
          riskliBayiler.add({
            'firma_adi': data['firma_adi'] ?? 'Gizli Bayi',
            'sikayet': sikayet,
          });
        }
      }

      developer.log("SİBER BİLGİ: $sehir taraması tamamlandı. Aktif Bayi: ${querySnapshot.docs.length}");

      return {
        'basarili': true,
        'sehir': sehir,
        'aktif_bayi_sayisi': querySnapshot.docs.length,
        'toplam_ciro': sehirToplamCiro,
        'komutan_payi': sehirToplamCiro * 0.12, // 💸 Değişmez %12 Pay
        'kritik_bayi_sayisi': kritikBayiSayisi,
        'riskli_bayiler': riskliBayiler,
      };
    } catch (e) {
      developer.log("SİBER İHLAL: Bölge röntgeni çekilemedi!", error: e);
      // Ekranda sonsuz dönmeyi engellemek için hatayı UI'a fırlatıyoruz!
      throw Exception("SİBER AĞ HATASI: $sehir bölgesi taranamadı!");
    }
  }

  // --- 🛡️ ATAMA PROTOKOLÜ (ATOMİK - WRITEBATCH) ---
  Future<void> bolgeKomutaniAta({
    required String kullaniciId,
    required String isim,
    required String bolge
  }) async {
    try {
      developer.log("SİBER BİLGİ: $isim, $bolge bölgesi için komutan olarak atanıyor...");
      WriteBatch batch = _db.batch();

      // 1. Kullanıcı Profilini Mühürle
      DocumentReference userRef = _db.collection('kullanicilar').doc(kullaniciId);
      batch.set(userRef, {
        'rol': 'bolge_komutani',
        'sorumlu_bolge': bolge,
        'rutbe_guncelleme_tarihi': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 2. Komutanlar Listesine Ekle
      BolgeKomutani yeni = BolgeKomutani(
        id: kullaniciId,
        isim: isim,
        sorumluOlduguBolge: bolge,
        rutbe: 'Bölge Sorumlusu',
      );
      DocumentReference komutanRef = _db.collection('bolge_komutanlari').doc(kullaniciId);
      batch.set(komutanRef, yeni.toMap());

      // 3. Kara Kutu Logu
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'ATAMA_BASARILI',
        'islem_detayi': 'MÜHÜR: $isim, $bolge Komutanı olarak atandı.',
        'bayi_isim': 'ANKARA MERKEZ KARARGAH',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      developer.log("SİBER BİLGİ: Atama işlemi Kuantum Ağına mühürlendi.");

    } catch (e) {
      developer.log("SİBER İHLAL: Atama işlemi başarısız oldu!", error: e);
      throw Exception("ATAMA BAŞARISIZ: Yetki protokolü mühürlenemedi!");
    }
  }

  // --- ❌ İHRAÇ PROTOKOLÜ (ATOMİK - WRITEBATCH) ---
  Future<void> komutanliktanIhracEt(String kullaniciId, String isim) async {
    try {
      developer.log("SİBER BİLGİ: $isim için İhraç Protokolü devrede...");
      WriteBatch batch = _db.batch();

      // 1. Kullanıcı rolünü düşür
      batch.update(_db.collection('kullanicilar').doc(kullaniciId), {
        'rol': 'kullanici',
        'sorumlu_bolge': FieldValue.delete(),
      });

      // 2. Komutanı pasife çek
      batch.update(_db.collection('bolge_komutanlari').doc(kullaniciId), {
        'aktif': false,
        'gorevden_alinma_tarihi': FieldValue.serverTimestamp(),
      });

      // 3. Kara Kutu Logu
      batch.set(_db.collection('sistem_loglari').doc(), {
        'islem_turu': 'IHRAC_EDILDI',
        'islem_detayi': 'İHRAÇ: $isim adlı personelin yetkileri sıfırlandı.',
        'bayi_isim': 'ANKARA MERKEZ KARARGAH',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      developer.log("SİBER BİLGİ: İhraç işlemi tamamlandı ve ağa mühürlendi.");

    } catch (e) {
      developer.log("SİBER İHLAL: İhraç operasyonu başarısız!", error: e);
      throw Exception("İHRAÇ BAŞARISIZ: Personel yetkileri sıfırlanamadı!");
    }
  }
}