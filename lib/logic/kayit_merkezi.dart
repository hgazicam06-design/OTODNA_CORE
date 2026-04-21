import 'package:cloud_firestore/cloud_firestore.dart';

class KayitMerkezi {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------------------------------------------------
  // 📦 10'LU PAKET KAYIT (KUANTUM BATCH WRITE) MOTORU
  // ---------------------------------------------------------
  Future<void> onluPaketKaydet(List<Map<String, dynamic>> urunler) async {
    if (urunler.isEmpty) return;

    WriteBatch batch = _db.batch();
    CollectionReference urunlerRef = _db.collection('yedek_parcalar');

    try {
      for (var urun in urunler) {
        double orijinalAlisFiyati = (urun['fiyat'] ?? 0).toDouble();
        String gercekSaticiAdi = urun['bayi'] ?? "Bilinmeyen Tedarikçi";
        String gercekSaticiId = urun['bayi_id'] ?? "ID_YOK";

        // 🔥 YENİ KURAL: KİM OLDUĞU FARK ETMEZ, SABİT %12 KARARGAH PAYI!
        double komutanGaziPayi = orijinalAlisFiyati * 0.12; // %10 Kâr + %2 Vergi
        double bayiHakedis = orijinalAlisFiyati * 0.88;

        DocumentReference yeniUrunRef = urunlerRef.doc();

        // 🔓 ŞEFFAFLIK PROTOKOLÜ: Herkes kendi ismiyle vitrine çıkar!
        Map<String, dynamic> muhurluVeri = {
          'urun_ad': urun['ad'],
          'kategori': urun['kategori'] ?? 'Genel',
          'asil_satici_id': gercekSaticiId,
          'asil_satici_adi': gercekSaticiAdi,
          'satici_goster': true, // ARTIK SATICI GİZLEMEK YOK!
          'vitrin_etiketi': gercekSaticiAdi, // Herkesin kendi dükkan ismi!
          'orijinal_fiyat': orijinalAlisFiyati,
          'gazi_komisyon': komutanGaziPayi,
          'bayi_hakedis': bayiHakedis,
          'kayit_tarihi': FieldValue.serverTimestamp(),
          'durum': 'Onaylı/Satışta',
        };

        batch.set(yeniUrunRef, muhurluVeri);
      }

      // 🚀 TÜM FÜZELERİ AYNI ANDA ATEŞLE
      await batch.commit();

    } catch (e) {
      throw Exception("SİBER HATA: Kayıt motoru devre dışı kaldı. Detay: $e");
    }
  }
}