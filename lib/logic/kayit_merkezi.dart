import 'package:cloud_firestore/cloud_firestore.dart';

class KayitMerkezi {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------------------------------------------------
  // 📦 10'LU PAKET KAYIT (KUANTUM BATCH WRITE) MOTORU
  // ---------------------------------------------------------
  // Ürünleri tek tek değil, çelik kasa mantığıyla tek seferde Firebase'e yazar.
  Future<void> onluPaketKaydet(List<Map<String, dynamic>> urunler) async {
    if (urunler.isEmpty) return;

    // Kuantum Çelik Kasa: Tüm işlemler topluca ve hatasız işlenmek için hazırlanır
    WriteBatch batch = _db.batch();
    CollectionReference urunlerRef = _db.collection('yedek_parcalar');

    try {
      for (var urun in urunler) {
        double orijinalAlisFiyati = (urun['fiyat'] ?? 0).toDouble();
        String gercekSaticiAdi = urun['bayi'] ?? "Bilinmeyen Tedarikçi";
        String gercekSaticiId = urun['bayi_id'] ?? "ID_YOK";

        double komutanGaziPayi = 0;
        double bayiHakedis = 0;

        // ⚙️ TİCARET VE FİNANS MOTORU: Murat Plaza (%30) vs Diğer Bayiler (%12)
        if (gercekSaticiAdi == "Murat Plaza") {
          komutanGaziPayi = orijinalAlisFiyati * 0.30; // Özel Kar Anlaşması
          bayiHakedis = orijinalAlisFiyati * 0.70;
        } else {
          komutanGaziPayi = orijinalAlisFiyati * 0.12; // %10 Kâr + %2 Vergi
          bayiHakedis = orijinalAlisFiyati * 0.88;
        }

        // Firebase'de yeni bir boş satır (döküman) aç
        DocumentReference yeniUrunRef = urunlerRef.doc();

        // 🔒 GİZLİLİK VE VERİ PAKETİ MÜHRÜ
        Map<String, dynamic> muhurluVeri = {
          'urun_ad': urun['ad'],
          'kategori': urun['kategori'] ?? 'Genel',
          'asil_satici_id': gercekSaticiId,
          'asil_satici_adi': gercekSaticiAdi, // Sadece senin Admin panelinde görünür
          'satici_goster': false, // Vitrinde ASLA gerçek satıcı adı yazmaz
          'vitrin_etiketi': "Murat Plaza", // Müşteriler tüm ürünleri Murat Plaza'nın sanır
          'orijinal_fiyat': orijinalAlisFiyati,
          'gazi_komisyon': komutanGaziPayi,
          'bayi_hakedis': bayiHakedis,
          'kayit_tarihi': FieldValue.serverTimestamp(),
          'durum': 'Onaylı/Satışta',
        };

        // Veriyi ateşlemeye hazırla (Kasaya koy)
        batch.set(yeniUrunRef, muhurluVeri);
      }

      // 🚀 TÜM FÜZELERİ AYNI ANDA ATEŞLE (Canlı Veritabanı Kaydı)
      await batch.commit();

    } catch (e) {
      print("Kritik Toplu Kayıt Hatası: $e");
      throw Exception("Kuantum Ağ Bağlantısı Koptu, Kayıt Başarısız: $e");
    }
  }
}