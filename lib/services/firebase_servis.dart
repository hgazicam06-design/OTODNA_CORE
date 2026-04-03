import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import '../models/service_model.dart'; // Modelinin yolu doğru kalmalı

/// 🛡️ KUANTUM VERİTABANI MOTORU (FirebaseServis)
/// Araç DNA'sını mühürleme ve Karargah (Ankara Merkez) üzerinden istihbarat çekme merkezi.
class FirebaseServis {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── 📝 ARACA YENİ DNA VERİSİ EKLEME (KUANTUM MÜHÜRÜ) ──────────────────────
  Future<void> servisKaydiEkle(ServiceModel model) async {
    try {
      developer.log("SİBER BİLGİ: Araç DNA mühürleme protokolü başlatıldı. Şase: ${model.saseNo}");

      await _firestore.collection('servis_kayitlari').add({
        "saseNo": model.saseNo.toUpperCase(),
        "islemiYapanBayi": model.islemiYapanBayi.toUpperCase(),
        "parcaDurumu": model.parcaDurumu,
        "kilometre": model.kilometre,
        "tarih": model.tarih.toIso8601String(),
        "aciklama": model.aciklama,
        "distributorId": "ANK-MERKEZ", // Karargah Mührü Sabitlendi
        "bolgeKodu": 1, // İç Anadolu Sabit
        "olusturulmaTarihi": FieldValue.serverTimestamp(),
      });

      developer.log("SİBER MÜHÜR: Veri, Ankara Merkez Veritabanına sarsılmaz şekilde işlendi!");
    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Servis kaydı mühürlenemedi!", error: e);
      throw Exception("SİSTEMSEL İHLAL: Araç DNA'sı Karargaha iletilemedi.");
    }
  }

  // ── 📡 ŞASEDEN ARAÇ DNA'SI SORGULAMA (RADAR) ──────────────────────────────
  Future<List<ServiceModel>> saseIleSorgula(String saseNo) async {
    try {
      developer.log("SİBER İSTİHBARAT: $saseNo şase numaralı aracın sicili radarda taranıyor...");

      var snapshot = await _firestore
          .collection('servis_kayitlari')
          .where('saseNo', isEqualTo: saseNo.toUpperCase())
          .orderBy('kilometre', descending: true) // En son yapılan işlem en üstte
          .get();

      developer.log("GÖREV TAMAM: ${snapshot.docs.length} adet DNA kaydı radara düştü.");

      return snapshot.docs.map((doc) {
        var data = doc.data();
        return ServiceModel(
          id: doc.id,
          saseNo: data['saseNo'] ?? '',
          islemiYapanBayi: data['islemiYapanBayi'] ?? 'BİLİNMEYEN BAYİ',
          parcaDurumu: data['parcaDurumu'] ?? 'BELİRTİLMEMİŞ',
          kilometre: (data['kilometre'] ?? 0).toDouble(),
          tarih: data['tarih'] != null ? DateTime.parse(data['tarih']) : DateTime.now(),
          aciklama: data['aciklama'] ?? '',
          distributorId: data['distributorId'] ?? 'ANK-MERKEZ',
          bolgeKodu: data['bolgeKodu'] ?? 1,
        );
      }).toList();

    } catch (e) {
      developer.log("SORGULAMA HATASI: İstihbarat ağı koptu!", error: e);
      return []; // Sistem çökmesin diye boş liste döndürülür
    }
  }
}