// lib/services/ai_istihbarat_koprusu.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../services/chronic_radar_service.dart';
import '../models/chronic_issue_model.dart';

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

  /// 🧠 FORUM SOHBET TARAYICISI: Mesajı okuyup kronik arızaları tespit eder ve arka plana işler
  static Future<void> forumSohbetiniTara(String mesaj, String province, String district) async {
    try {
      if (_geminiApiKey == 'KARARGAH_API_ANAHTARINI_BURAYA_GIRIN') {
        // AI Kapalıyken Simülasyon (Test İçin)
        if (mesaj.toLowerCase().contains('dsg') || mesaj.toLowerCase().contains('şanzıman')) {
          debugPrint("Siber Karargah: Mock AI Kronik Arıza Yakaladı -> DSG Vuruntusu ($province/$district)");
          final radarService = ChronicRadarService();
          await radarService.logGeographicFault('mock_dsg_issue_id', province, district);
        }
        return;
      }

      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _geminiApiKey,
      );

      final prompt = TextPart(
        'Sen OtoDNA Karargahı Yapay Zekasısın. Aşağıdaki kullanıcı mesajını analiz et. '
        'Eğer araçla ilgili kronik veya potansiyel kronik bir arıza (motor, şanzıman, elektronik vb.) bahsediliyorsa tespit et. '
        'Mesaj: "$mesaj" '
        'Cevabı sadece JSON formatında ver. Eğer arıza yoksa {"ariza_var": false} dön. '
        'Eğer arıza varsa: {"ariza_var": true, "brand": "Marka", "model": "Model", "issue_title": "Arıza Başlığı", "component": "Bozulan Parça"}'
      );

      final response = await model.generateContent([
        Content.text(prompt.text)
      ]);

      if (response.text != null) {
        String cleanJson = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
        final Map<String, dynamic> data = jsonDecode(cleanJson);
        
        if (data['ariza_var'] == true) {
          debugPrint("🚨 AI RADARI KRONİK ARIZA YAKALADI: ${data['issue_title']} - ${data['brand']} ${data['model']}");
          debugPrint("📍 Lokasyon Kaydediliyor: $province / $district");
          
          final radarService = ChronicRadarService();
          // Not: Gerçek sistemde burada veritabanından title ile ID bulup onu loglamalıyız.
          // Şimdilik mock ID ile kaydediyoruz.
          await radarService.logGeographicFault('ai_detected_issue', province, district);
        }
      }
    } catch (e) {
      debugPrint("🚨 AI SOHBET TARAYICISI ARIZALANDI: $e");
    }
  }
}
