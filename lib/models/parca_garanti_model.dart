import 'package:cloud_firestore/cloud_firestore.dart';

/// 🛡️ OTODNA PARÇA GARANTİ VE MÜHÜR MODELİ
/// Dijital torpidoya gönderilecek olan, yetkili usta tarafından imzalanmış parça sertifikası.
class ParcaGarantiModel {
  final String? id;
  final String aracId;
  final String ustaUid;
  final String firmaUnvani; // Müşterinin torpidosunda firmayı görsün diye
  
  // 🕸️ KUANTUM İSTİHBARAT AĞI (4 KATMANLI ADLİ KONUM)
  // Bu işlem tam olarak hangi ilçede yapıldı? Sigorta kütüphanesini beslemek için kritik.
  final String countryId;
  final String regionId;
  final String cityId;
  final String districtId;

  final String parcaAdi;
  final String oemKodu;
  final String benzersizSeriNo; // Kutuya özel tek kullanımlık kod
  final String irsaliyeFaturaNo; // Tedarikçi Fatura No
  final int aiGuvenSkoru; // Sahtecilik risk skoru (Örn: 98 = Güvenilir)
  final bool adliProtokolKabulEdildi; // Yasal Uyarı Sözleşmesi
  final String degisimOncesiFoto; // Zorunlu kanıt
  final String degisimSonrasiFoto; // Zorunlu kanıt
  final int garantiSuresiAy;
  final DateTime gecerlilikBitisTarihi;
  final bool otodnaMuhruBasildiMi; // AI ve Usta onayı
  final bool musteriOnayladiMi; // Çift taraflı mühür (Müşteri onayı)
  final String gorseliKimCekti; // 'musteri' veya 'usta'
  final DateTime islemTarihi;

  ParcaGarantiModel({
    this.id,
    required this.aracId,
    required this.ustaUid,
    required this.firmaUnvani,
    required this.countryId,
    required this.regionId,
    required this.cityId,
    required this.districtId,
    required this.parcaAdi,
    required this.oemKodu,
    required this.benzersizSeriNo,
    required this.irsaliyeFaturaNo,
    required this.aiGuvenSkoru,
    required this.adliProtokolKabulEdildi,
    required this.degisimOncesiFoto,
    required this.degisimSonrasiFoto,
    required this.garantiSuresiAy,
    required this.gecerlilikBitisTarihi,
    required this.otodnaMuhruBasildiMi,
    required this.musteriOnayladiMi,
    required this.gorseliKimCekti,
    required this.islemTarihi,
  });

  Map<String, dynamic> toMap() {
    return {
      'arac_id': aracId,
      'usta_uid': ustaUid,
      'firma_unvani': firmaUnvani,
      'country_id': countryId,
      'region_id': regionId,
      'city_id': cityId,
      'district_id': districtId,
      'parca_adi': parcaAdi,
      'oem_kodu': oemKodu,
      'benzersiz_seri_no': benzersizSeriNo,
      'irsaliye_fatura_no': irsaliyeFaturaNo,
      'ai_guven_skoru': aiGuvenSkoru,
      'adli_protokol_kabul_edildi': adliProtokolKabulEdildi,
      'degisim_oncesi_foto': degisimOncesiFoto,
      'degisim_sonrasi_foto': degisimSonrasiFoto,
      'garanti_suresi_ay': garantiSuresiAy,
      'gecerlilik_bitis_tarihi': gecerlilikBitisTarihi,
      'otodna_muhru_basildi_mi': otodnaMuhruBasildiMi,
      'musteri_onayladi_mi': musteriOnayladiMi,
      'gorseli_kim_cekti': gorseliKimCekti,
      'islem_tarihi': islemTarihi,
      'kayit_tarihi': FieldValue.serverTimestamp(),
    };
  }

  factory ParcaGarantiModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
    return ParcaGarantiModel(
      id: doc.id,
      aracId: data['arac_id'] ?? '',
      ustaUid: data['usta_uid'] ?? '',
      firmaUnvani: data['firma_unvani'] ?? 'Bilinmeyen Firma',
      countryId: data['country_id'] ?? '',
      regionId: data['region_id'] ?? '',
      cityId: data['city_id'] ?? '',
      districtId: data['district_id'] ?? '',
      parcaAdi: data['parca_adi'] ?? '',
      oemKodu: data['oem_kodu'] ?? '',
      benzersizSeriNo: data['benzersiz_seri_no'] ?? '',
      irsaliyeFaturaNo: data['irsaliye_fatura_no'] ?? '',
      aiGuvenSkoru: (data['ai_guven_skoru'] ?? 0).toInt(),
      adliProtokolKabulEdildi: data['adli_protokol_kabul_edildi'] ?? false,
      degisimOncesiFoto: data['degisim_oncesi_foto'] ?? '',
      degisimSonrasiFoto: data['degisim_sonrasi_foto'] ?? '',
      garantiSuresiAy: data['garanti_suresi_ay'] ?? 0,
      gecerlilikBitisTarihi: (data['gecerlilik_bitis_tarihi'] as Timestamp?)?.toDate() ?? DateTime.now(),
      otodnaMuhruBasildiMi: data['otodna_muhru_basildi_mi'] ?? false,
      musteriOnayladiMi: data['musteri_onayladi_mi'] ?? false,
      gorseliKimCekti: data['gorseli_kim_cekti'] ?? 'usta',
      islemTarihi: (data['islem_tarihi'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
