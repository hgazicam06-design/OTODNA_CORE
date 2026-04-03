import 'package:cloud_firestore/cloud_firestore.dart';
// Bir önceki adımda yazdığımız SOS sistemini içeri aktarıyoruz
import 'otodna_mega_protocol.dart';

class OtoDnaScanner {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final OtoDnaMegaProtocol _megaProtocol = OtoDnaMegaProtocol();

  // ---------------------------------------------------------
  // 🔍 SİBER GÖZ: QR OKUNDUĞUNDA TETİKLENECEK GERÇEK MOTOR
  // ---------------------------------------------------------
  Future<Map<String, dynamic>?> onQrScanned({
    required String qrData,
    String? aktifKullaniciId, // SOS durumunda kimin taradığını bilmek için
    GeoPoint? anlikKonum,     // SOS durumunda nereye ambulans/çekici gidecek
  }) async {
    try {
      // 🚨 1. ACİL DURUM (SOS) KONTROLÜ
      // Eğer QR kodu "ACIL_DURUM" içeriyorsa (Örn: ACIL_DURUM:34DNA2026)
      if (qrData.contains("ACIL_DURUM") && aktifKullaniciId != null && anlikKonum != null) {
        String aracId = qrData.split(":").last; // Plakayı ayıkla

        // Ankara Merkez'e ve en yakın bayiye anında Kırmızı Alarm gönder!
        await _megaProtocol.tetikleSiberSOS(
          kullaniciId: aktifKullaniciId,
          konum: anlikKonum,
          qrKodu: qrData,
          aracRaporuOzet: "Siber Göz (QR) Üzerinden Acil Çağrı! Araç Kimliği: $aracId",
        );

        return {"statu": "SOS_TETIKLENDI", "mesaj": "Acil durum protokolü devrede! Ankara Merkez bilgilendirildi."};
      }

      // 🔍 2. NORMAL ARAÇ TARAMASI (DİJİTAL GEÇMİŞİ ÇEK)
      // QR datası doğrudan plaka veya şase numarası kabul ediliyor
      String plakaID = qrData.trim().replaceAll(" ", "").toUpperCase();

      DocumentSnapshot aracDoc = await _db.collection('araclar').doc(plakaID).get();

      if (!aracDoc.exists) {
        return {"statu": "BULUNAMADI", "mesaj": "Siber Ağda böyle bir araç yok. Belki de Kuantum sistemine henüz kaydedilmemiştir."};
      }

      var aracVerisi = aracDoc.data() as Map<String, dynamic>;
      bool kirmiziXVarMi = aracVerisi['kritik_hata_var_mi'] ?? false;

      // ❌ 3. TRAFİĞE ÇIKIŞ RİSKİ KONTROLÜ (KIRMIZI X PROTOKOLÜ)
      if (kirmiziXVarMi) {
        // UI (Arayüz) tarafında ekranı kırmızıya boyamak için bu değişkeni yolluyoruz
        aracVerisi['siber_uyari'] = "DİKKAT: Araçta usta tarafından onaylanmış KIRMIZI X var! Trafiğe çıkması risklidir!";
      } else {
        // UI tarafında yeşil tık ve "OtoDNA Referanslıdır" mührü basılacak
        aracVerisi['siber_uyari'] = "Kusursuz. Dijital Referans geçerli.";
      }

      // 4. SONUÇLARI ARAYÜZE (Ekrana) GÖNDER
      aracVerisi['statu'] = "BASARILI";
      return aracVerisi;

    } catch (e) {
      print("Kuantum Tarayıcı Hatası: $e");
      return {"statu": "HATA", "mesaj": "Ağ bağlantısı koptu: $e"};
    }
  }
}