import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class KuantumOcrMotoru {
  final ImagePicker _picker = ImagePicker();

  // ── 1. ORTAK SİBER TARAMA FONKSİYONU ──
  // Kamerayı açar, görüntüyü dondurur ve Google ML Kit ile metni okur
  Future<String?> _kameradanMetinOku() async {
    try {
      final XFile? foto = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
      if (foto == null) return null;

      final InputImage inputImage = InputImage.fromFilePath(foto.path);
      final TextRecognizer textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      return recognizedText.text;
    } catch (e) {
      print("SİBER OCR HATASI: Göz Kalkanı Aşılamadı -> $e");
      return null;
    }
  }

  // ── 2. MÜŞTERİ CEPHESİ: AKILLI RUHSAT ANALİZİ ──
  Future<Map<String, String>?> ruhsatTaramaMotoru() async {
    String? hamMetin = await _kameradanMetinOku();
    if (hamMetin == null || hamMetin.isEmpty) return null;

    String plaka = "BULUNAMADI";
    String sase = "BULUNAMADI";

    // 🛡️ Kuantum Filtreleri (Regex)
    // Türkiye Plaka Formatı (Örn: 34 ABC 123 veya 06GZ1071)
    RegExp plakaRegex = RegExp(r'\b[0-9]{2}\s?[A-Z]{1,3}\s?[0-9]{2,4}\b');
    var plakaEslesme = plakaRegex.firstMatch(hamMetin);
    if (plakaEslesme != null) plaka = plakaEslesme.group(0) ?? "BULUNAMADI";

    // Şase numarası global standartlarda 17 haneli alfasayısal bir koddur
    RegExp saseRegex = RegExp(r'\b[A-HJ-NPR-Z0-9]{17}\b');
    var saseEslesme = saseRegex.firstMatch(hamMetin);
    if (saseEslesme != null) sase = saseEslesme.group(0) ?? "BULUNAMADI";

    return {
      "plaka": plaka.replaceAll(" ", "").toUpperCase(), // Boşlukları temizle ve büyüt
      "sase": sase.toUpperCase(),
      "ham_metin": hamMetin, // Hata ayıklama için ham metni de döndürüyoruz
    };
  }

  // ── 3. BAYİ CEPHESİ: AKILLI FATURA VE PARÇA ANALİZİ ──
  Future<Map<String, dynamic>?> faturaTaramaMotoru() async {
    String? hamMetin = await _kameradanMetinOku();
    if (hamMetin == null || hamMetin.isEmpty) return null;

    double toplamMaliyet = 0.0;
    List<String> bulunanParcalar = [];

    // Metni satır satır bölerek parçala
    List<String> satirlar = hamMetin.split('\n');

    // Fiyat Tespiti İçin Regex (Örn: 1500.50, 1.500,50, 200)
    RegExp fiyatRegex = RegExp(r'\b\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{2})?\b');

    for (var satir in satirlar) {
      // İçinde TL, KDV veya TOPLAM geçen satırlardaki rakamı çek
      if (satir.toUpperCase().contains("TL") || satir.toUpperCase().contains("TOPLAM")) {
        var fiyatEslesme = fiyatRegex.firstMatch(satir);
        if (fiyatEslesme != null) {
          // Türk formatındaki fiyatları standart double'a çevir
          String temizFiyat = fiyatEslesme.group(0)!.replaceAll('.', '').replaceAll(',', '.');
          double? fiyat = double.tryParse(temizFiyat);
          if (fiyat != null && fiyat > toplamMaliyet) {
            toplamMaliyet = fiyat; // En yüksek tutarı "Genel Toplam" olarak kabul et
          }
        }
      }
      // İçinde hiç rakam geçmeyen ve mantıklı bir uzunlukta olan satırları Parça Adı olarak kabul et
      else if (satir.length > 4 && !satir.contains(RegExp(r'[0-9]')) && !satir.toUpperCase().contains("FATURA")) {
        bulunanParcalar.add(satir.trim());
      }
    }

    return {
      "maliyet": toplamMaliyet,
      "parcalar": bulunanParcalar,
      "ham_metin": hamMetin,
    };
  }
}