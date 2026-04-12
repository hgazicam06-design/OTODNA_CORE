import 'dart:io';
import 'dart:async';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AiServis {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final stt.SpeechToText _speechToText = stt.SpeechToText();

  // ===========================================================================
  // 👁️ 1. SİBER OPTİK (OCR): RUHSATTAN ŞASE (VIN) OKUMA MOTORU
  // ===========================================================================
  Future<String?> ruhsattanSaseOku(File imageFile) async {
    try {
      // 🚀 Gerçek Google ML Kit Yapay Zekasını Ateşle
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      // Metni temizle (Boşlukları yok et ki şase tek parça kalsın)
      String fullText = recognizedText.text.replaceAll(RegExp(r'\s+'), '');

      // 🧠 Kuantum Filtresi: 17 Haneli Şase (VIN) Bulma Algoritması
      // Şase numaraları I, O, Q harflerini içermez, 17 hanelidir.
      RegExp vinRegExp = RegExp(r'[A-HJ-NPR-Z0-9]{17}');
      Match? match = vinRegExp.firstMatch(fullText);

      await textRecognizer.close();

      if (match != null) {
        return match.group(0); // Şase bulundu! (Örn: WBA316020K123456)
      } else {
        throw Exception("RUHSAT OKUNAMADI: Optik taramada 17 haneli Şase (VIN) tespit edilemedi!");
      }
    } catch (e) {
      throw Exception("SİBER OPTİK ÇÖKTÜ: Görüntü işlenemedi! Hata: $e");
    }
  }

  // ===========================================================================
  // 🎙️ 2. SESLİ İSTİHBARAT MOTORU (SPEECH-TO-TEXT) - %100 GERÇEK
  // ===========================================================================
  Future<String> sesiMetneCevir() async {
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

        // 🛡️ Siber Kalkan: 5 Saniye içinde ses gelmezse sistemi kapatır
        Future.delayed(const Duration(seconds: 5), () {
          if (!completer.isCompleted) {
            _speechToText.stop();
            completer.completeError("SESSİZLİK: Ses algılanamadı, mikrofon kapatıldı.");
          }
        });
      } else {
        completer.completeError("SİBER İHLAL: Mikrofon izni reddedildi veya donanım bulunamadı!");
      }

      return completer.future;
    } catch (e) {
      throw Exception("MİKROFON SİNYALİ KOPTU: Hata: $e");
    }
  }

  // ===========================================================================
  // ☁️ 3. BULUT TEKNİK KATALOG VE DNA MOTORU - %100 GERÇEK FİREBASE
  // ===========================================================================
  Future<Map<String, dynamic>> parcaDetaylariniBuluttanGetir(String saseNo) async {
    try {
      // 🚀 MAKET YOK! DOĞRUDAN MATRIX'E (FIREBASE) BAĞLANTI
      DocumentSnapshot doc = await _db.collection('arac_katalog').doc(saseNo).get();

      if (doc.exists && doc.data() != null) {
        var data = doc.data() as Map<String, dynamic>;
        return data['parcalar'] ?? {};
      } else {
        throw Exception("İSTİHBARAT BOŞ: Bu şaseye ($saseNo) ait Kuantum Kataloğu bulunamadı!");
      }
    } catch (e) {
      throw Exception("VERİTABANI BAĞLANTISI KOPTU: Siber Katalog çekilemedi! $e");
    }
  }

  // ===========================================================================
  // 🗺️ 4. SİBER HARİTA VE DİSTRİBÜTÖR EŞLEŞTİRME - %100 GERÇEK YÖNLENDİRME
  // ===========================================================================
  Future<void> esnaflariHaritadaGoster(String parcaAdi, String sehir) async {
    try {
      // 🚀 Gerçek Google Maps Rotasını Oluştur (Örn: "Fren Balatası Oto Parçacı Ankara")
      final String query = Uri.encodeComponent("$parcaAdi Oto Parçacı $sehir");
      final Uri mapUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');

      // Harita uygulamasını (Google Maps/Apple Maps) tetikle
      if (await canLaunchUrl(mapUrl)) {
        await launchUrl(mapUrl, mode: LaunchMode.externalApplication);
      } else {
        throw Exception("RADAR ÇÖKTÜ: Cihazda harita protokolü başlatılamadı!");
      }
    } catch (e) {
      throw Exception("SİBER ROTA HATASI: Hedef koordinatlar çizilemedi! $e");
    }
  }
}