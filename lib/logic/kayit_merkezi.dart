import 'package:cloud_firestore/cloud_firestore.dart';

class KayitMerkezi {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------------------------------------------------
  // 📦 10'LU PAKET KAYIT (KUANTUM BATCH WRITE) MOTORU
  // ---------------------------------------------------------
  // Ürünleri tek tek değil, çelik kasa mantığıyla tek seferde Firebase'e yazar.
  // Bu yöntem, ağ trafiğini azaltır ve işlemlerin yarım kalmasını engeller.
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
        // 12% = %10 Kar + %2 Vergi protokolüne dayanır.
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
        // Ürünler vitrinde "Murat Plaza" etiketiyle görünür, asıl tedarikçi gizlenir.
        Map<String, dynamic> muhurluVeri = {
          'urun_ad': urun['ad'],
          'kategori': urun['kategori'] ?? 'Genel',
          'asil_satici_id': gercekSaticiId,
          'asil_satici_adi': gercekSaticiAdi, // Sadece Admin panelinde görünür
          'satici_goster': false, // Vitrinde ASLA gerçek satıcı adı yazmaz
          'vitrin_etiketi': "Murat Plaza", // Müşteri algısı yönetimi
          'orijinal_fiyat': orijinalAlisFiyati,
          'gazi_komisyon': komutanGaziPayi,
          'bayi_hakedis': bayiHakedis,
          'kayit_tarihi': FieldValue.serverTimestamp(),
          'durum': 'Onaylı/Satışta',
        };

        // Veriyi ateşlemeye hazırla (Batch listesine ekle)
        batch.set(yeniUrunRef, muhurluVeri);
      }

      // 🚀 TÜM FÜZELERİ AYNI ANDA ATEŞLE (Atomik Kayıt)
      await batch.commit();

    } catch (e) {
      // Hata durumunda siber log oluştur
      throw Exception("SİBER HATA: Kayıt motoru devre dışı kaldı. Detay: $e");
    }
  }
}