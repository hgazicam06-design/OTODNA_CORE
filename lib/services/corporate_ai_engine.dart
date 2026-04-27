import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/chronic_radar_service.dart';

// ============================================================================
// DOSYA AMACI: 
// Bu servis, OtoDNA platformunun tüm Yapay Zeka (AI) ve makine öğrenimi 
// işlevlerini tek çatı altında toplar. Gemini API ile parça tanıma, 
// forum sohbetlerini okuyarak kronik arıza tespiti yapma, ML Kit ile 
// ruhsattan Şase (VIN) okuma ve Speech-to-Text (Sesli İstihbarat) hizmetlerini
// barındırır.
// ============================================================================

class CorporateAIEngine {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final stt.SpeechToText _speechToText = stt.SpeechToText();
  
  // Kurumsal API Anahtarı (Production'da .env'den alınmalıdır)
  static const String _geminiApiKey = 'KARARGAH_API_ANAHTARINI_BURAYA_GIRIN';

  // =======================================================================
  // 1. GÖRSEL YAPAY ZEKA: PARÇA TANIMA (GEMİNİ)
  // =======================================================================
  static Future<Map<String, String>?> parcayiTani(XFile imageFile) async {
    try {
      if (_geminiApiKey == 'KARARGAH_API_ANAHTARINI_BURAYA_GIRIN') {
        debugPrint("OTODNA BİLGİ: Gemini API anahtarı eksik, simülasyon çalıştırılıyor.");
        await Future.delayed(const Duration(seconds: 2));
        return {
          "parca_adi": "Ön Tampon",
          "marka": "FIAT Egea",
          "oem": "OEM-7382-X"
        };
      }

      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _geminiApiKey);
      final imageBytes = await imageFile.readAsBytes();
      
      final prompt = TextPart(
        'Sen bir OtoDNA Yapay Zeka Uzmanısın. '
        'Gönderilen araç parçasının görselini analiz et. '
        'Sadece aşağıdaki JSON formatında cevap ver. Başka hiçbir açıklama yazma. '
        '{"parca_adi": "Parçanın adı", "marka": "Aracın tahmini markası ve modeli", "oem": "Tahmini OEM kodu"}'
      );
      
      final imagePart = DataPart('image/jpeg', imageBytes);
      final response = await model.generateContent([Content.multi([prompt, imagePart])]);

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
      debugPrint("OTODNA HATA: Görsel analiz çöktü! $e");
      return null;
    }
  }

  // =======================================================================
  // 2. DOĞAL DİL İŞLEME: SOHBET TARAMASI VE KRONİK ARIZA TESPİTİ
  // =======================================================================
  static Future<void> forumSohbetiniTara(String mesaj, String province, String district) async {
    try {
      if (_geminiApiKey == 'KARARGAH_API_ANAHTARINI_BURAYA_GIRIN') {
        if (mesaj.toLowerCase().contains('dsg') || mesaj.toLowerCase().contains('şanzıman')) {
          final radarService = ChronicRadarService();
          await radarService.logGeographicFault('mock_dsg_issue_id', province, district);
        }
        return;
      }

      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _geminiApiKey);
      final prompt = TextPart(
        'Sen OtoDNA Yapay Zeka Uzmanısın. Aşağıdaki kullanıcı mesajını analiz et. '
        'Eğer araçla ilgili kronik veya potansiyel kronik bir arıza bahsediliyorsa tespit et. '
        'Mesaj: "$mesaj" '
        'Cevabı JSON formatında ver. Eğer arıza yoksa {"ariza_var": false} dön. '
        'Eğer arıza varsa: {"ariza_var": true, "brand": "Marka", "model": "Model", "issue_title": "Arıza Başlığı", "component": "Bozulan Parça"}'
      );

      final response = await model.generateContent([Content.text(prompt.text)]);

      if (response.text != null) {
        String cleanJson = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
        final Map<String, dynamic> data = jsonDecode(cleanJson);
        
        if (data['ariza_var'] == true) {
          debugPrint("OTODNA BİLGİ: Kronik arıza tespit edildi (${data['issue_title']}). Lokasyon: $province/$district");
          final radarService = ChronicRadarService();
          await radarService.logGeographicFault('ai_detected_issue', province, district);
        }
      }
    } catch (e) {
      debugPrint("OTODNA HATA: NLP sohbet analizi başarısız oldu: $e");
    }
  }

  // =======================================================================
  // 3. OPTİK KARAKTER TANIMA (OCR): RUHSATTAN ŞASİ NO OKUMA
  // =======================================================================
  static Future<String?> ruhsattanSaseOku(File imageFile) async {
    try {
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      String fullText = recognizedText.text.replaceAll(RegExp(r'\s+'), '');
      RegExp vinRegExp = RegExp(r'[A-HJ-NPR-Z0-9]{17}');
      Match? match = vinRegExp.firstMatch(fullText);

      await textRecognizer.close();

      if (match != null) {
        return match.group(0); 
      } else {
        throw Exception("Ruhsat analizinde 17 haneli Şase (VIN) bulunamadı.");
      }
    } catch (e) {
      throw Exception("OCR Görüntü işleme başarısız! Hata: $e");
    }
  }

  // =======================================================================
  // 4. SESE DAYALI VERİ GİRİŞİ (SPEECH-TO-TEXT)
  // =======================================================================
  static Future<String> sesiMetneCevir() async {
    Completer<String> completer = Completer<String>();

    try {
      bool available = await _speechToText.initialize();
      if (available) {
        _speechToText.listen(
          onResult: (result) {
            if (result.finalResult) {
              completer.complete(result.recognizedWords);
            }
          },
        );

        Future.delayed(const Duration(seconds: 5), () {
          if (!completer.isCompleted) {
            _speechToText.stop();
            completer.completeError("Ses algılanamadı, mikrofon kapatıldı.");
          }
        });
      } else {
        completer.completeError("Mikrofon izni reddedildi veya donanım bulunamadı!");
      }

      return completer.future;
    } catch (e) {
      throw Exception("Mikrofon sinyali hatası: $e");
    }
  }

  // =======================================================================
  // 5. BULUT KATALOG VE HARİTA YÖNLENDİRME
  // =======================================================================
  static Future<Map<String, dynamic>> parcaDetaylariniBuluttanGetir(String saseNo) async {
    try {
      DocumentSnapshot doc = await _db.collection('arac_katalog').doc(saseNo).get();
      if (doc.exists && doc.data() != null) {
        var data = doc.data() as Map<String, dynamic>;
        return data['parcalar'] ?? {};
      } else {
        throw Exception("Bu şaseye ($saseNo) ait katalog bulunamadı.");
      }
    } catch (e) {
      throw Exception("Veritabanı bağlantısı koptu: $e");
    }
  }

  static Future<void> esnaflariHaritadaGoster(String parcaAdi, String sehir) async {
    try {
      final String query = Uri.encodeComponent("$parcaAdi Oto Parçacı $sehir");
      final Uri mapUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');

      if (await canLaunchUrl(mapUrl)) {
        await launchUrl(mapUrl, mode: LaunchMode.externalApplication);
      } else {
        throw Exception("Harita uygulaması başlatılamadı.");
      }
    } catch (e) {
      throw Exception("Rota oluşturulamadı: $e");
    }
  }
}
