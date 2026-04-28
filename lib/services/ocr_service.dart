import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM OPTİK İSTİHBARAT MOTORU (OcrService)
/// Kameradan/Galeriden belge okur; Şase (VIN), Plaka ve Bitiş Tarihlerini otonom süzer.
class OcrService {
  static final _picker = ImagePicker();

  // ── 📸 1. SİBER OPTİK GÖZ (FOTOĞRAF ÇEKİMİ) ────────────────────────────────
  static Future<File?> fotografCek({bool galeri = false}) async {
    try {
      final picked = await _picker.pickImage(
        source: galeri ? ImageSource.gallery : ImageSource.camera,
        imageQuality: 90, // Yüksek Karargah Çözünürlüğü
        preferredCameraDevice: CameraDevice.rear,
      );
      if (picked != null) {
        developer.log("SİBER BİLGİ: Optik göz hedefe kilitlendi. Fotoğraf alındı.");
        return File(picked.path);
      }
      // Kullanıcı işlemi iptal ederse sessizce geri dön (Bu bir hata değildir)
      return null;
    } catch (e) {
      developer.log("DONANIM HATASI: Optik lense (Kameraya) ulaşılamadı!", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ: Donanım hatası arayüze fırlatılır!
      throw Exception("SİBER KÖRLÜK: Kamera veya Galeri erişimi reddedildi! Lütfen cihaz izinlerini kontrol edin.");
    }
  }

  // ── 🧠 2. KUANTUM METİN ÇÖZÜCÜ (ML KIT) ───────────────────────────────────
  static Future<String> _metinOku(File resim) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      developer.log("SİBER İSTİHBARAT: Belge üzerindeki yazılar çözümleniyor...");
      final inputImage = InputImage.fromFile(resim);
      final recognized = await textRecognizer.processImage(inputImage);
      return recognized.text;
    } catch (e) {
      developer.log("YAZILIM HATASI: Metin çözümleme motoru (ML) çöktü!", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ: ML çökerse boş metin dönme, sistemi uyar!
      throw Exception("YAPAY ZEKA ARIZASI: Belge okuma motoru çöktü, sistem metni çözümleyemiyor!");
    } finally {
      textRecognizer.close();
    }
  }

  // ── 🧬 3. ARAÇ DNA'SI (VIN / ŞASE) SÜZGEÇİ ───────────────────────────────
  /// 17 karakterli Şase numarasını (VIN) bulur ve optik hataları (0/O, 1/I) düzeltir.
  static Future<OcrSonuc> vinOku(File resim) async {
    final metin = await _metinOku(resim);
    if (metin.isEmpty) return OcrSonuc.bos(OcrTur.vin);

    developer.log("SİBER RADAR: Araç DNA'sı (Şase/VIN) taranıyor...");

    // Optik düzeltme: VIN standartlarında I, O, Q harfleri olmaz!
    String temizMetin = metin
        .replaceAll(' ', '')
        .toUpperCase()
        .replaceAll('O', '0') // O harfi 0'a çevrildi
        .replaceAll('Q', '0') // Q harfi 0'a çevrildi
        .replaceAll('I', '1'); // I harfi 1'e çevrildi

    final vinRegex = RegExp(r'[A-HJ-NPR-Z0-9]{17}');
    final eslesmeler = vinRegex.allMatches(temizMetin);

    if (eslesmeler.isNotEmpty) {
      String yakalananSase = eslesmeler.first.group(0)!;
      developer.log("🎯 HEDEF VURULDU: Şase numarası mühürlendi -> $yakalananSase");
      return OcrSonuc(deger: yakalananSase, tur: OcrTur.vin, hamMetin: metin);
    }

    // Yakın eşleşme (Eksik okuma) kalkanı: 15–17 karakter arası
    final yakinRegex = RegExp(r'[A-HJ-NPR-Z0-9]{15,17}');
    final yakin = yakinRegex.allMatches(temizMetin);

    if (yakin.isNotEmpty) {
      developer.log("⚠️ SİBER UYARI: Şase numarası eksik okundu! Manuel düzeltme gerekebilir.");
      return OcrSonuc(deger: yakin.first.group(0)!, tur: OcrTur.vin, hamMetin: metin, kesin: false);
    }

    return OcrSonuc.bos(OcrTur.vin, hamMetin: metin);
  }

  // ── 🇹🇷 4. TÜRKİYE PLAKA RADARI ───────────────────────────────────────────
  static Future<OcrSonuc> plakaOku(File resim) async {
    final metin = await _metinOku(resim);
    if (metin.isEmpty) return OcrSonuc.bos(OcrTur.plaka);

    developer.log("SİBER RADAR: Araç Plakası taranıyor...");

    // Gelişmiş Türkiye Plaka Regex: (Örn: 06GZ1923, 34ABC123, 01A12)
    final plakaRegex = RegExp(r'\b(0[1-9]|[1-7][0-9]|8[01])\s?[A-Z]{1,3}\s?[0-9]{2,4}\b');
    final eslesen = plakaRegex.firstMatch(metin.toUpperCase());

    if (eslesen != null) {
      final temizPlaka = eslesen.group(0)!.replaceAll(' ', '');
      developer.log("🎯 HEDEF VURULDU: Plaka mühürlendi -> $temizPlaka");
      return OcrSonuc(deger: temizPlaka, tur: OcrTur.plaka, hamMetin: metin);
    }

    return OcrSonuc.bos(OcrTur.plaka, hamMetin: metin);
  }

  // ── 📅 5. GELECEK ZAMAN SENSÖRÜ (BİTİŞ TARİHLERİ) ────────────────────────
  /// Belgedeki tüm tarihleri tarar ve "en uzak gelecekteki" (bitiş) tarihi cımbızlar.
  static Future<OcrSonuc> tarihOku(File resim) async {
    final metin = await _metinOku(resim);
    if (metin.isEmpty) return OcrSonuc.bos(OcrTur.tarih);

    developer.log("SİBER RADAR: Belge üzerindeki bitiş tarihleri taranıyor...");

    final tarihRegex = RegExp(r'\b(\d{1,2})[./\-](\d{1,2})[./\-](\d{4})\b|\b(\d{4})[./\-](\d{1,2})[./\-](\d{1,2})\b');
    final tum = tarihRegex.allMatches(metin);

    DateTime? enSon;
    String enSonStr = '';

    for (final m in tum) {
      try {
        DateTime? d;
        if (m.group(1) != null) {
          d = DateTime(int.parse(m.group(3)!), int.parse(m.group(2)!), int.parse(m.group(1)!));
        } else {
          d = DateTime(int.parse(m.group(4)!), int.parse(m.group(5)!), int.parse(m.group(6)!));
        }

        if (d.isAfter(DateTime.now()) && (enSon == null || d.isAfter(enSon))) {
          enSon = d;
          enSonStr = m.group(0)!; // Orijinal metindeki hali
        }
      } catch (_) {
        // Hatalı tarih formatlarını sessizce atla
      }
    }

    if (enSon != null) {
      developer.log("🎯 HEDEF VURULDU: Bitiş tarihi mühürlendi -> $enSonStr");
      return OcrSonuc(deger: enSonStr, tur: OcrTur.tarih, hamMetin: metin, tarih: enSon, kesin: true);
    }

    return OcrSonuc.bos(OcrTur.tarih, hamMetin: metin);
  }
}

// ── 💎 SİBER SONUÇ VERİ MODELLERİ ──────────────────────────────────────────
enum OcrTur { vin, plaka, tarih }

class OcrSonuc {
  final String deger;
  final OcrTur tur;
  final String hamMetin;
  final bool kesin;
  final DateTime? tarih;

  OcrSonuc({
    required this.deger,
    required this.tur,
    required this.hamMetin,
    this.kesin = true,
    this.tarih,
  });

  // Hata durumlarında boş sonuç fırlatmak için Kuantum Kalkanı
  factory OcrSonuc.bos(OcrTur tur, {String hamMetin = ''}) {
    return OcrSonuc(deger: '', tur: tur, hamMetin: hamMetin, kesin: false);
  }

  bool get bulundu => deger.isNotEmpty;
}