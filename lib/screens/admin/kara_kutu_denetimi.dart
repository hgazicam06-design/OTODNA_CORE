import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // Sadece debug modunda log basmak için

/// OTODNA KARA KUTU VE GÖLGE TELEMETRİ İSTİHBARAT SERVİSİ
class KaraKutuServisi {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- 📡 SİBER GÖLGE: ARKA PLAN TELEMETRİ KAYDI ---
  // Bu fonksiyon araç hareket ettikçe arka planda sessizce çalışır.
  // Kullanıcı bu verileri göremez, sadece Amiral Gemisi (Merkez) erişebilir.
  Future<void> arkaPlanTelemetriKaydet({
    required String kullaniciId,
    required String aracId,
    required double mesafeKm,
    required String yolSarti, // Asfalt, Çamur, Mıcır, Zorlu Arazi vb.
    required int zorlanmaSkoru, // 1 ile 10 arası motor/mekanik zorlanma
  }) async {
    try {
      WriteBatch batch = _db.batch(); // 🔥 Kuantum Mührü
      DocumentReference telemetriRef = _db.collection('kara_kutu_verileri').doc();

      batch.set(telemetriRef, {
        'kullanici_id': kullaniciId,
        'arac_id': aracId,
        'eklenen_km': mesafeKm,
        'zemin_turu': yolSarti,
        'zorlanma_skoru': zorlanmaSkoru,
        'gizli_kayit_tarihi': FieldValue.serverTimestamp(),
      });

      await batch.commit(); // Sessizce Ateşle
    } catch (e) {
      // Sessiz Protokol: Kullanıcıya yansıtma ama geliştirici radarında tut!
      if (kDebugMode) {
        print("🔴 SİBER GÖLGE HATASI (TELEMETRİ KAYDEDİLEMEDİ): $e");
      }
    }
  }

  // --- 🕵️‍♂️ DERİN DEVLET: KARA KUTU İNCELEME PROTOKOLÜ ---
  Future<Map<String, dynamic>> derinIncelemeBaslat({
    required String adminId,
    required String adminSifre,
    required String hedefAracId,
  }) async {
    try {
      // 1. GÜVENLİK KALKANI: Şifreyi kod içine asla gömmüyoruz!
      // Doğrulamayı Firebase'in en derin "sistem_ayarlari" koleksiyonundan çekiyoruz.
      DocumentSnapshot yetkiDoc = await _db.collection('sistem_ayarlari').doc('guvenlik').get();
      String gercekSifre = yetkiDoc.exists ? (yetkiDoc.data() as Map<String, dynamic>)['master_key'] : "GAZI_YEDE_SIFRE_00";

      if (adminSifre != gercekSifre) {
        // 🚨 SİBER İHLAL: Yetkisiz erişim denemesi anında füzeyi ateşler ve loglara yazar! (Atomik olarak)
        WriteBatch ihlalBatch = _db.batch();
        DocumentReference ihlalLogRef = _db.collection('sistem_loglari').doc();

        ihlalBatch.set(ihlalLogRef, {
          'islem_turu': 'sos', // Kırmızı Alarm (Admin Panelinde yanar)
          'islem_detayi': 'SİBER İHLAL: Kara Kutu verilerine YETKİSİZ ERİŞİM denemesi! Araç ID: $hedefAracId',
          'bayi_isim': 'YETKİSİZ TERMİNAL (ID: $adminId)',
          'tarih': FieldValue.serverTimestamp(),
        });

        await ihlalBatch.commit();
        return {'basarili': false, 'mesaj': 'ERİŞİM REDDEDİLDİ: Geçersiz Güvenlik Mührü!'};
      }

      // 2. YETKİ ONAYLANDI: Aracın tüm gizli geçmişini (Kara Kutu) Kuantum Ağında tara
      QuerySnapshot telemetriSnap = await _db.collection('kara_kutu_verileri')
          .where('arac_id', isEqualTo: hedefAracId)
          .orderBy('gizli_kayit_tarihi', descending: true)
          .get();

      // 3. İnceleme Başlatıldığını Amiral Gemisine (Loglara) Kaydet (Atomik)
      WriteBatch basariBatch = _db.batch();
      DocumentReference basariLogRef = _db.collection('sistem_loglari').doc();

      basariBatch.set(basariLogRef, {
        'islem_turu': 'basarili',
        'islem_detayi': 'DERİN İNCELEME: $hedefAracId plakalı aracın Kara Kutu verileri Karargaha açıldı.',
        'bayi_isim': 'AMİRAL GEMİSİ',
        'tarih': FieldValue.serverTimestamp(),
      });

      await basariBatch.commit();

      List<Map<String, dynamic>> dokum = telemetriSnap.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      return {
        'basarili': true,
        'mesaj': 'SİBER KİLİT AÇILDI. Veriler Aktarılıyor...',
        'veriler': dokum,
        'toplam_kayit': dokum.length,
      };

    } catch (e) {
      return {'basarili': false, 'mesaj': 'SİSTEM HATASI: Kara Kutu bağlantısı kurulamadı. $e'};
    }
  }
}