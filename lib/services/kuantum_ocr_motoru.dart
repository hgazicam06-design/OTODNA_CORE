import 'dart:io';
import 'dart:developer' as developer;
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class KuantumOcrMotoru {
  final ImagePicker _picker = ImagePicker();

  // ── 1. ORTAK SİBER TARAMA FONKSİYONU ──
  // Kamerayı açar, görüntüyü dondurur ve Google ML Kit ile metni okur
  Future<String> _kameradanMetinOku() async {
    try {
      developer.log("SİBER OPTİK: Göz kalkanı (Kamera) açılıyor...");
      final XFile? foto = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);

      if (foto == null) {
        // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ: Kullanıcı kamerayı kapatırsa null dönme, hata fırlat!
        throw Exception("Kullanıcı optik taramayı iptal etti.");
      }

      developer.log("SİBER OPTİK: Görüntü yakalandı, Kuantum ML Kit motoru çalıştırılıyor...");
      final InputImage inputImage = InputImage.fromFilePath(foto.path);
      final TextRecognizer textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      if (recognizedText.text.isEmpty) {
        throw Exception("SİBER KÖRLÜK: Görüntüden hiçbir metin çıkarılamadı!");
      }

      return recognizedText.text;
    } catch (e) {
      developer.log("SİBER OCR HATASI: Göz Kalkanı Aşılamadı!", error: e);
      throw Exception("SİBER OPTİK ÇÖKTÜ: Kamera veya okuma motoru arızalı! Hata: $e");
    }
  }

  // ── 2. MÜŞTERİ CEPHESİ: AKILLI RUHSAT ANALİZİ ──
  // Dönüş tipindeki '?' (null olabilirlik) kaldırıldı. Kesin sonuç veya Exception döner!
  Future<Map<String, String>> ruhsatTaramaMotoru() async {
    try {
      String hamMetin = await _kameradanMetinOku();

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

      developer.log("SİBER İSTİHBARAT: Ruhsat tarandı. Şase: $sase | Plaka: $plaka");

      return {
        "plaka": plaka.replaceAll(" ", "").toUpperCase(), // Boşlukları temizle ve büyüt
        "sase": sase.toUpperCase(),
        "ham_metin": hamMetin, // Hata ayıklama için ham metni de döndürüyoruz
      };
    } catch (e) {
      developer.log("RUHSAT TARAMA BAŞARISIZ!", error: e);
      throw Exception("RUHSAT OKUNAMADI: Lütfen net bir şekilde tekrar çekin.");
    }
  }

  // ── 3. BAYİ CEPHESİ: AKILLI FATURA VE PARÇA ANALİZİ ──
  Future<Map<String, dynamic>> faturaTaramaMotoru() async {
    try {
      String hamMetin = await _kameradanMetinOku();

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

      developer.log("SİBER İSTİHBARAT: Fatura tarandı. Maliyet: ₺$toplamMaliyet | Parça Sayısı: ${bulunanParcalar.length}");

      return {
        "maliyet": toplamMaliyet,
        "parcalar": bulunanParcalar,
        "ham_metin": hamMetin,
      };
    } catch (e) {
      developer.log("FATURA TARAMA BAŞARISIZ!", error: e);
      throw Exception("FATURA OKUNAMADI: Belgenin net göründüğünden emin olun.");
    }
  }
}