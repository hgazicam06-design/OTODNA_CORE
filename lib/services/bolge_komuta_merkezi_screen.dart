import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🦅 OTODNA BÖLGE YÖNETİM VE İSTİHBARAT SİSTEMİ
/// Bu motor, Türkiye'nin 81 ilindeki bayilerin finansal ve etik durumunu tarar.
class BolgeYonetimSistemi {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🛰️ SİBER İL ANALİZ MOTORU
  Future<Map<String, dynamic>> ilAnaliziYap(String seciliIl) async {
    try {
      developer.log("SİBER RADAR: $seciliIl bölgesi için istihbarat taraması başlatıldı...");

      // 1. AŞAMA: İSTİHBARAT TOPLAMA (FİREBASE TARAMASI)
      // İl bazlı filtreleme yaparak tüm bayileri radarımıza alıyoruz.
      QuerySnapshot bayiSnapshot = await _db
          .collection('bayiler')
          .where('il', isEqualTo: seciliIl)
          .get();

      if (bayiSnapshot.docs.isEmpty) {
        developer.log("SİBER BİLGİ: $seciliIl bölgesinde aktif Kuantum birimi bulunamadı.");
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

        // 1 Yıldız ve 5 şikayet acımasızca radara yakalanır
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

      developer.log("SİBER BİLGİ: $seciliIl taraması tamamlandı. Bölge Cirosu: ₺$toplamCiro, Karargah Payı: ₺$komutanPayi");

      return {
        'basarili': true,
        'toplam_ciro': toplamCiro,
        'komutan_payi': komutanPayi,
        'aktif_bayi_sayisi': bayiSnapshot.docs.length,
        'kritik_bayi_sayisi': kritikBayiSayisi,
        'riskli_bayiler': riskliBayiler,
      };

    } catch (e) {
      developer.log("SİBER İHLAL: Bölge istihbarat motoru çöktü!", error: e);
      // Ekranda sonsuz yüklemeyi durdurmak için Kırmızı Alarm fırlatıyoruz!
      throw Exception("BÖLGE TARAMA HATASI: İstihbarat ağına ulaşılamıyor!");
    }
  }

  // 🛡️ BAYİ DURUMU MÜHÜRLEME (KARALİSTE OPERASYONU)
  Future<void> bayiDurumunuGuncelle(String bayiId, bool karaListe) async {
    try {
      developer.log("SİBER BİLGİ: Bayi ($bayiId) için Karaliste protokolü tetiklendi. Dondurma: $karaListe");

      // ⛓️ SİBER ZIRH: Atomik WriteBatch Başlatıldı
      WriteBatch batch = _db.batch();

      // 1. Bayinin sistem yetkisini askıya al veya aktif et
      DocumentReference bayiRef = _db.collection('bayiler').doc(bayiId);
      batch.update(bayiRef, {
        'is_active': !karaListe,
        'status': karaListe ? 'BLACKLIST' : 'ACTIVE',
        'last_update': FieldValue.serverTimestamp(),
      });

      // 2. Admin Kara Kutu Loguna mühürle
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': karaListe ? 'BAYİ_DONDURULDU' : 'BAYİ_AKTİF_EDİLDİ',
        'islem_detayi': 'SİBER HAKEMLİK: $bayiId numaralı bayinin erişimi güncellendi.',
        'tarih': FieldValue.serverTimestamp(),
      });

      // Füzeleri ateşle! (Ya ikisi de olur, ya hiçbiri olmaz)
      await batch.commit();
      developer.log("SİBER BİLGİ: Karaliste operasyonu Kuantum Ağına mühürlendi.");

    } catch (e) {
      developer.log("SİBER İHLAL: Karaliste işlemi başarısız oldu!", error: e);
      throw Exception("MÜHÜRLEME ARIZASI: Bayi erişim durumu güncellenemedi!");
    }
  }
}