import 'package:cloud_firestore/cloud_firestore.dart';

/// 🦅 OTODNA BÖLGE YÖNETİM VE İSTİHBARAT SİSTEMİ
/// Bu motor, Türkiye'nin 81 ilindeki bayilerin finansal ve etik durumunu tarar.
class BolgeYonetimSistemi {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🛰️ SİBER İL ANALİZ MOTORU
  Future<Map<String, dynamic>> ilAnaliziYap(String seciliIl) async {
    try {
      // 1. AŞAMA: İSTİHBARAT TOPLAMA (FİREBASE TARAMASI)
      // İl bazlı filtreleme yaparak tüm bayileri radarımıza alıyoruz.
      QuerySnapshot bayiSnapshot = await _db
          .collection('bayiler')
          .where('il', isEqualTo: seciliIl)
          .get();

      if (bayiSnapshot.docs.isEmpty) {
        return {
          'basarili': true,
          'toplam_ciro': 0.0,
          'komutan_payi': 0.0,
          'aktif_bayi_sayisi': 0,
          'kritik_bayi_sayisi': 0,
          'riskli_bayiler': [],
        };
      }

      double toplamCiro = 0.0;
      int kritikBayiSayisi = 0;
      List<Map<String, dynamic>> riskliBayiler = [];

      // 2. AŞAMA: VERİ ANALİZİ VE FİNANSAL HESAPLAMA
      for (var doc in bayiSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Ciro birikimi (Bayinin toplam cirosu data içinde saklanır)
        double bayiCirosu = (data['toplam_kazanc'] ?? 0).toDouble();
        toplamCiro += bayiCirosu;

        // Siber İtibar Kontrolü (Kara Liste Protokolü)
        int sikayetSayisi = data['sikayet_sayisi'] ?? 0;
        int yildizSayisi = data['yildiz_puani'] ?? 5;

        if (sikayetSayisi >= 5 || yildizSayisi <= 1) {
          kritikBayiSayisi++;
          riskliBayiler.add({
            'firma_adi': data['firma_adi'] ?? 'BİLİNMEYEN BİRİM',
            'sikayet': sikayetSayisi,
            'id': doc.id
          });
        }
      }

      // 3. AŞAMA: %12 MUTLAK KOMUTAN PAYI (ZARAR ETMEK YOK!)
      // Toplam ciro üzerinden %10 kâr + %2 vergi mühürlenir.
      double komutanPayi = toplamCiro * 0.12;

      return {
        'basarili': true,
        'toplam_ciro': toplamCiro,
        'komutan_payi': komutanPayi,
        'aktif_bayi_sayisi': bayiSnapshot.docs.length,
        'kritik_bayi_sayisi': kritikBayiSayisi,
        'riskli_bayiler': riskliBayiler,
      };

    } catch (e) {
      return {
        'basarili': false,
        'hata': 'SİBER BAĞLANTI HATASI: ${e.toString()}'
      };
    }
  }

  // 🛡️ BAYİ DURUMU MÜHÜRLEME (KARALİSTE OPERASYONU)
  Future<void> bayiDurumunuGuncelle(String bayiId, bool karaListe) async {
    // Tek hamlede bayinin sistem yetkisini askıya alma (Atomic Update)
    await _db.collection('bayiler').doc(bayiId).update({
      'is_active': !karaListe,
      'status': karaListe ? 'BLACKLIST' : 'ACTIVE',
      'last_update': FieldValue.serverTimestamp(),
    });
  }
}