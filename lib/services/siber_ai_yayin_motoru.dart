import 'package:google_generative_ai/google_generative_ai.dart';

/// OtoDNA Siber AI Yayın Motoru
/// Sahibinden gibi platformlardaki manuel veri girişini bitiren, 
/// Gemini AI destekli otonom ilan derleme servisidir.
class SiberAiYayinMotoru {
  // TODO: Prod ortamında bu anahtar .env dosyasından çekilmelidir.
  static const String _mockApiKey = "AIzaSy_MOCK_GEMINI_API_KEY_XXXXXXXXXXXX";
  
  /// Araca ait verileri alıp, 'Plaza Kalitesinde' resmi ve elit bir ilan metni yazar.
  static Future<String> ilanMetniYaz(Map<String, dynamic> aracVerisi) async {
    try {
      String apiKey = _mockApiKey;

      final model = GenerativeModel(model: 'gemini-1.5-pro', apiKey: apiKey);

      final prompt = """
      Sen lüks ve kurumsal bir OtoDNA Plaza galerisinin baş editörüsün. Üslubun son derece resmi, güven veren, elit ve profesyonel olmalıdır (plaza kalitesinde). 
      Lütfen aşağıdaki araç verilerini kullanarak etkileyici, kurumsal bir ilan metni oluştur. İlan metninde abartılı emojiler kullanma, sade ve etkileyici bir format kullan.
      
      Araç Bilgileri:
      - Marka/Model: ${aracVerisi['markaModel'] ?? 'Bilinmiyor'}
      - Yıl: ${aracVerisi['yil'] ?? 'Bilinmiyor'}
      - OtoDNA Siber Skoru: ${aracVerisi['dnaSkoru'] ?? 'Belirtilmedi'}/100
      - OtoDNA Onaylı Ekstralar: ${aracVerisi['onayliEkstralar'] ?? 'Fabrika Çıkışlı'}
      - Ekspertiz (Boya/Değişen): ${aracVerisi['ekspertiz'] ?? 'Kusursuz / Orijinal'}
      - Tramer: ${aracVerisi['tramer'] ?? 'Hasar Kaydı Bulunmamaktadır'}
      
      Metnin sonunda, arabanın OtoDNA Kuantum Garajları tarafından tüm bakımlarının yapıldığını, işlemlerin dijital olarak mühürlendiğini ve %100 güvenle satın alınabileceğini belirten şık, kurumsal bir kapanış yap.
      """;

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      return response.text ?? "OtoDNA Siber Zeka şu an yanıt veremiyor.";
    } catch (e) {
      return "SİBER AI BAĞLANTI HATASI: İlan metni otonom olarak oluşturulamadı. (Sistem dışı hata: $e)";
    }
  }

  /// Aracın özelliklerine ve piyasa verilerine göre otonom fiyat bandı belirler.
  static Future<String> piyasaDegeriAnalizEt(String markaModel, int yil, int dnaSkoru) async {
    try {
      String apiKey = _mockApiKey;

      final model = GenerativeModel(model: 'gemini-1.5-pro', apiKey: apiKey);

      final prompt = """
      Sen kurumsal bir otomotiv değerleme uzmanısın. Başka hiçbir kelime veya açıklama yazmadan SADECE rakamsal bir fiyat bandı döndüreceksin.
      $yil model $markaModel bir aracın, OtoDNA kondisyon skoru 100 üzerinden $dnaSkoru ise, Türkiye piyasasında ortalama kurumsal satış fiyatı ne kadar olmalıdır? 
      Lütfen sonucu sadece şu formatta döndür: '1.450.000 ₺ - 1.500.000 ₺'
      """;

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      return response.text?.trim() ?? "Siber Analiz Yapılamadı";
    } catch (e) {
      return "Fiyat Tespiti Başarısız";
    }
  }
}
