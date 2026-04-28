// lib/services/torpido_servisi.dart
import 'dart:io';
import 'dart:developer' as developer;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import '../models/parca_garanti_model.dart';

// 🚀 KARARGAH MERKEZİ TEMA BAĞLANTISI (Gerekiyorsa)
// import '../core/siber_tema.dart';

/// 🛡️ OTODNA SİBER NEŞTER VE DİJİTAL KASA SERVİSİ (V3 - FULL ARMORED)
class TorpidoServisi {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  // 🔥 SİBER NEŞTER API KEY (remove.bg'den alınan ücretsiz anahtar buraya girilecek)
  final String _removeBgApiKey = "YOUR_REMOVE_BG_API_KEY_HERE";

  // ── 📸 BELGE YÜKLEME VE SİBER ANALİZ MOTORU ──
  Future<String?> torpidoyaBelgeEkle({
    required String kullaniciId,
    required String aracId,
    required String belgeTuru,
    required ImageSource source,
  }) async {
    try {
      developer.log("SİBER GÖZ: Optik lens açılıyor [$belgeTuru] taranacak...");

      final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 85);
      if (pickedFile == null) return null;

      File originalFile = File(pickedFile.path);

      // 🛠️ SİBER NEŞTER: Arka plan temizliği
      File? processedFile = await _arkaPlanSilSiberNester(originalFile);
      File finalFile = processedFile ?? originalFile;
      String filename = "${belgeTuru.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}.png";

      // ☁️ KUANTUM BULUTUNA SEVKİAYAT
      String storagePath = 'torpido_kasasi/$kullaniciId/${aracId.toUpperCase()}/$filename';
      TaskSnapshot snapshot = await _storage.ref().child(storagePath).putFile(
        finalFile,
        SettableMetadata(contentType: 'image/png'),
      );

      String downloadUrl = await snapshot.ref.getDownloadURL();

      // 🔱 ATOMİK MÜHÜR: Firestore Kaydı
      await _db.collection('araclar').doc(aracId.toUpperCase()).update({
        'torpido_belgeleri': FieldValue.arrayUnion([
          {
            'belge_turu': belgeTuru,
            'resim_url': downloadUrl,
            'storage_path': storagePath,
            'yuklenme_tarihi': FieldValue.serverTimestamp(),
            'durum': 'MÜHÜRLÜ',
          }
        ]),
      });

      developer.log("✅ SİBER ONAY: $belgeTuru Karargaha mühürlendi.");
      return downloadUrl;

    } catch (e) {
      developer.log("🚨 SİBER İHLAL: Torpido yükleme başarısız!", error: e);
      throw Exception("SİBER KASA HATASI: Belge Matrix'e sızdırılamadı.");
    }
  }

  // ── 📝 ÖZEL KOD VE METADATA GÜNCELLEME MOTORU ──
  /// [2026-04-17] GÜNCELLEME: Boya, Teyp ve Lastik kodlarını mühürler.
  Future<void> torpidoMetadataGuncelle({
    required String aracId,
    String? boyaKodu,
    String? teypKodu,
    String? lastikOlcusu,
    String? lastikBasinci,
  }) async {
    try {
      developer.log("📡 SİBER VERİ: Araç metadata mühürleri güncelleniyor...");

      Map<String, dynamic> guncelleme = {};
      if (boyaKodu != null) guncelleme['boya_kodu'] = boyaKodu;
      if (teypKodu != null) guncelleme['teyp_kodu'] = teypKodu;
      if (lastikOlcusu != null) guncelleme['lastik_olcusu'] = lastikOlcusu;
      if (lastikBasinci != null) guncelleme['lastik_basinci'] = lastikBasinci;

      guncelleme['son_metadata_guncelleme'] = FieldValue.serverTimestamp();

      await _db.collection('araclar').doc(aracId.toUpperCase()).set(
        {'dijital_torpido': guncelleme},
        SetOptions(merge: true),
      );

      developer.log("✅ MÜHÜR ONAYI: Araç kimlik kodları sisteme işlendi.");
    } catch (e) {
      developer.log("🚨 AĞ HATASI: Metadata işlenemedi!", error: e);
      throw Exception("KOD MÜHÜRLEME HATASI!");
    }
  }

  // ── 🛡️ OTODNA GARANTİ MÜHRÜ VE PARÇA KARNESİ ──
  Future<void> garantiBelgesiFirlat(ParcaGarantiModel belge) async {
    try {
      developer.log("🛡️ SİBER MÜHÜR: Garanti belgesi torpidoya ışınlanıyor...");

      // 1. Garanti Belgeleri koleksiyonuna bağımsız mühür kaydı
      DocumentReference docRef = _db.collection('garanti_belgeleri').doc();
      await docRef.set(belge.toMap());

      // 2. Aracın dijital torpidosuna (kullanıcı görsün diye) referans atma
      await _db.collection('araclar').doc(belge.aracId.toUpperCase()).update({
        'garanti_belgeleri': FieldValue.arrayUnion([
          {
            'belge_id': docRef.id,
            'firma_unvani': belge.firmaUnvani,
            'parca_adi': belge.parcaAdi,
            'oem_kodu': belge.oemKodu,
            'bitis_tarihi': belge.gecerlilikBitisTarihi,
            'muhurlu_mu': belge.otodnaMuhruBasildiMi,
            'islem_tarihi': belge.islemTarihi,
          }
        ]),
      });

      developer.log("✅ MÜHÜR ONAYI: Garanti belgesi başarıyla torpidoya kilitlendi.");
    } catch (e) {
      developer.log("🚨 AĞ HATASI: Garanti mühürlenemedi!", error: e);
      throw Exception("GARANTİ MÜHÜRLEME HATASI!");
    }
  }

  // ── 🤝 İKİ TARAFLI MÜHÜR (ATOMİK WRITEBATCH) ──
  Future<void> ikiTarafliMuhurFirlat(ParcaGarantiModel belge) async {
    try {
      developer.log("🤝 ÇİFT TARAFLI MÜHÜR: Atomik işlem başlatılıyor...");

      WriteBatch batch = _db.batch();

      // 1. Garanti Belgesi Bağımsız Kayıt
      DocumentReference docRef = _db.collection('garanti_belgeleri').doc();
      batch.set(docRef, belge.toMap());

      // 2. Araca Referans Atma
      DocumentReference aracRef = _db.collection('araclar').doc(belge.aracId.toUpperCase());
      batch.update(aracRef, {
        'garanti_belgeleri': FieldValue.arrayUnion([
          {
            'belge_id': docRef.id,
            'firma_unvani': belge.firmaUnvani,
            'parca_adi': belge.parcaAdi,
            'oem_kodu': belge.oemKodu,
            'bitis_tarihi': belge.gecerlilikBitisTarihi,
            'muhurlu_mu': belge.otodnaMuhruBasildiMi,
            'musteri_onayladi_mi': belge.musteriOnayladiMi, // YENİ
            'islem_tarihi': belge.islemTarihi,
          }
        ]),
      });

      // Atomik olarak tüm işlemleri tek seferde işle
      await batch.commit();

      developer.log("✅ İKİ TARAFLI MÜHÜR: İşlem kusursuzca mühürlendi.");
    } catch (e) {
      developer.log("🚨 ATOMİK HATA: İki taraflı mühür çakışması!", error: e);
      throw Exception("ATOMİK İŞLEM BAŞARISIZ!");
    }
  }

  // ── 🧠 OEM KODU YAPAY ZEKA DOĞRULAMASI (MOCK) ──
  Future<bool> oemKoduDogrula(String oemKodu) async {
    developer.log("🤖 AI SORGUSU: OEM Kodu katalogda aranıyor: $oemKodu");
    await Future.delayed(Duration(seconds: 2)); // AI Düşünme Süresi
    
    // Gerçekte devasa bir yedek parça veritabanına (Kuantum Kataloğuna) istek atılır.
    String kodUpper = oemKodu.toUpperCase();
    if (kodUpper.length > 4 && (kodUpper.contains("ORG") || kodUpper.contains("OEM") || kodUpper.contains("GEN") || kodUpper.contains("BOSCH") || kodUpper.contains("VALEO"))) {
      return true; // Geçerli
    }
    return false; // Geçersiz (Yan sanayi veya sahte)
  }

  // ── 🤖 YAPAY ZEKA OPTİK TARAMA (VISION OCR MOCK) ──
  Future<Map<String, dynamic>> aiOptikTarama(File gorsel) async {
    developer.log("👁️ SİBER GÖZ: Otonom AI optik tarama başlatıldı...");
    await Future.delayed(Duration(seconds: 3)); // AI OCR İşlem Süresi

    // 🚨 KATI ADLİ PROTOKOL: Görüntü Kalitesi Kontrolü (Mock)
    // Gerçekte API'nin döndüğü blur/confidence skoruna bakılır.
    // Simülasyon: Dosya boyutu çok küçükse (örneğin karanlık veya kalitesizse) reddet
    int length = await gorsel.length();
    if (length < 50000) { // 50KB altıysa muhtemelen çok kalitesiz/bulanık
      developer.log("🚨 AI REDDİ: Görüntü kalitesi yetersiz, okunamadı.");
      throw Exception("GÖRÜNTÜ KALİTESİ YETERSİZ: Lütfen daha aydınlık bir ortamda net bir fotoğraf çekin. İşlem Adli Delil standartlarına uymuyor.");
    }

    // Gerçekte Google Cloud Vision veya AWS Rekognition API'ye gönderilip veri çekilir.
    // Şimdilik test senaryosu için Kuantum simülasyonu dönüyoruz.
    return {
      'oemKodu': 'ORG-99X-V2',
      'benzersizSeriNo': 'SN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      'irsaliyeFaturaNo': 'FTR-2026-04X',
      'aiGuvenSkoru': 98, // %98 başarıyla orijinal
    };
  }

  // ── 🔒 ÇIKMA PARÇA KONTROL MOTORU ──
  Future<bool> seriNoKullanilmisMi(String seriNo) async {
    developer.log("🔍 SİBER DEDEKTİF: '$seriNo' seri numarası karargah havuzunda taranıyor...");
    
    try {
      var query = await _db.collection('garanti_belgeleri')
                           .where('benzersiz_seri_no', isEqualTo: seriNo)
                           .limit(1)
                           .get();
                           
      if (query.docs.isNotEmpty) {
        developer.log("🚨 KIZIL ALARM: Bu seri numarası daha önce kullanılmış (ÇIKMA PARÇA)!");
        return true;
      }
      return false;
    } catch (e) {
      developer.log("🚨 HATA: Seri no sorgulanamadı.", error: e);
      return true; // Güvenlik gereği hata durumunda sistemi kilitle
    }
  }

  // ── 🔪 SİBER NEŞTER (AI BG REMOVAL) ──
  Future<File?> _arkaPlanSilSiberNester(File imageFile) async {
    try {
      if (_removeBgApiKey == "YOUR_REMOVE_BG_API_KEY_HERE" || _removeBgApiKey.isEmpty) {
        return null;
      }
      var request = http.MultipartRequest('POST', Uri.parse('https://api.remove.bg/v1.0/removebg'));
      request.headers['X-Api-Key'] = _removeBgApiKey;
      request.files.add(await http.MultipartFile.fromPath('image_file', imageFile.path));
      request.fields['size'] = 'auto';

      var response = await request.send();
      if (response.statusCode == 200) {
        http.Response res = await http.Response.fromStream(response);
        String tempPath = path.join(path.dirname(imageFile.path), "siber_kesim_${DateTime.now().millisecondsSinceEpoch}.png");
        return await File(tempPath).writeAsBytes(res.bodyBytes);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}