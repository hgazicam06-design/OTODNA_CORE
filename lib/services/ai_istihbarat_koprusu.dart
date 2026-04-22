// lib/services/ai_istihbarat_koprusu.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIIstihbaratKoprusu {
  // Karargah Gizli API Anahtarı (Production'da .env'den alınmalıdır)
  static const String _geminiApiKey = 'KARARGAH_API_ANAHTARINI_BURAYA_GIRIN';
  
  /// 👁️ YAPAY ZEKA GÖZÜ: Gönderilen fotoğrafı analiz edip Parça Adı, Marka ve OEM kodunu çıkartır.
  static Future<Map<String, String>?> parcayiTani(XFile imageFile) async {
    try {
      if (_geminiApiKey == 'KARARGAH_API_ANAHTARINI_BURAYA_GIRIN') {
        debugPrint("🚨 AI RADARI HATASI: Gemini API anahtarı eksik!");
        // Simülasyon verisi dön (Geliştirme aşamasında API key yoksa test amaçlı)
        await Future.delayed(const Duration(seconds: 2));
        return {
          "parca_adi": "Ön Tampon",
          "marka": "FIAT Egea",
          "oem": "OEM-7382-X"
        };
      }

      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _geminiApiKey,
      );

      final imageBytes = await imageFile.readAsBytes();
      
      final prompt = TextPart(
        'Sen bir OtoDNA Karargahı Yapay Zekasısın (Siber Göz). '
        'Gönderilen araç parçasının görselini analiz et. '
        'Sadece aşağıdaki JSON formatında cevap ver. Başka hiçbir açıklama yazma. '
        '{"parca_adi": "Parçanın genel adı (Örn: Ön Filitre)", "marka": "Aracın tahmini markası ve modeli", "oem": "Tahmini OEM veya stok formatında bir kod"}'
      );
      
      final imagePart = DataPart('image/jpeg', imageBytes);

      final response = await model.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      if (response.text != null) {
        String cleanJson = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
        final Map<String, dynamic> data = jsonDecode(cleanJson);
        
        return {
          "parca_adi": data["parca_adi"]?.toString() ?? "Bilinmiyor",
          "marka": data["marka"]?.toString() ?? "Bilinmiyor",
          "oem": data["oem"]?.toString() ?? "Bilinmiyor",
        };
      }
      return null;
    } catch (e) {
      debugPrint("🚨 AI GÖZÜ ARIZALANDI: $e");
      return null;
    }
  }
}
