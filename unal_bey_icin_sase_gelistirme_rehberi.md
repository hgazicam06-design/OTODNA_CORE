# Ünal Bey İçin Geliştirme Rehberi: Kuantum Veri Yönlendiricisi ve Tramer Kazıcı

Sayın Ünal Bey, bu belge OtoDNA'nın yeni nesil araç tanıma ve veri kazıma motorunu (Siber Şase Motoru) projeye nasıl entegre edeceğinizi adım adım göstermektedir. Lütfen aşağıdaki dosyaları projedeki ilgili klasörlere oluşturarak projeyi güncelleyiniz.

## 1. Klasör Yapısının Kurulması
Lütfen `lib/services/` altında **`sase`** adında yeni bir klasör oluşturun. 

Aşağıdaki 4 dosyayı bu klasörün (`lib/services/sase/`) içine ekleyeceksiniz.

---

## 2. Ücretsiz Global API: NHTSA Servisi
Bu servis 17 haneli global şaseleri ücretsiz çözecektir.

**Dosya Yolu:** `lib/services/sase/nhtsa_api_service.dart`

```dart
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

class NhtsaApiService {
  static const String _baseUrl = 'https://vpic.nhtsa.dot.gov/api/vehicles/decodevin';

  static Future<Map<String, dynamic>?> decodeVin(String vin) async {
    developer.log("🌐 NHTSA Ağına Bağlanılıyor... Hedef Şase: \$vin");

    try {
      final url = Uri.parse('\$_baseUrl/\$vin?format=json');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['Results'] as List<dynamic>?;

        if (results == null || results.isEmpty) return null;

        Map<String, dynamic> parsedData = {};
        for (var item in results) {
          final variable = item['Variable']?.toString();
          final value = item['Value']?.toString();
          
          if (variable != null && value != null && value != "null" && value.isNotEmpty) {
            parsedData[variable] = value;
          }
        }

        return {
          "kaynak": "NHTSA",
          "marka": parsedData['Make'] ?? "Bilinmiyor",
          "model": parsedData['Model'] ?? "Bilinmiyor",
          "yil": parsedData['Model Year'] ?? "Bilinmiyor",
          "kasa_tipi": parsedData['Body Class'] ?? "Bilinmiyor",
          "motor": parsedData['Displacement (L)'] != null ? "\${parsedData['Displacement (L)']}L" : "Bilinmiyor",
        };
      }
      return null;
    } catch (e) {
      developer.log("💥 NHTSA Bağlantı Koptu: \$e");
      return null;
    }
  }
}
```

---

## 3. Web Veri Kazıyıcı: JDM ve Tramer Altyapısı
Bu servis, JDM araçları ve Tramer gibi API desteği olmayan yerlerden kazıma yapar.

**Dosya Yolu:** `lib/services/sase/siber_veri_kazici_service.dart`

```dart
import 'dart:developer' as developer;

class SiberVeriKaziciService {
  
  // Japon araçları için taslak kazıyıcı
  static Future<Map<String, dynamic>?> jdmSaseKazi(String kisaSase) async {
    developer.log("🕷️ SİBER KAZICI: JDM Şase Taraması Başlatıldı... Hedef: \$kisaSase");
    await Future.delayed(const Duration(seconds: 2));

    // Test JDM Verileri (Buraya ileride HTTP Scraping kodları eklenecek)
    if (kisaSase.toUpperCase().startsWith("JZX100")) {
      return {"kaynak": "Siber Kazıcı", "marka": "Toyota", "model": "Chaser", "yil": "1998"};
    }
    return null;
  }

  // Tramer Hasar Kaydı için taslak kazıyıcı
  static Future<Map<String, dynamic>?> tramerKazi(String plakaVeyaSase) async {
    developer.log("🕷️ SİBER KAZICI: Tramer Taraması Başlatıldı... Hedef: \$plakaVeyaSase");
    await Future.delayed(const Duration(seconds: 1));
    return {"kaynak": "Tramer Modülü", "durum": "Siber sistem hazırlandı, entegrasyon bekleniyor."};
  }
}
```

---

## 4. Yapay Zeka Son Çare: Gemini Fallback
Şase eğer hiçbir yerde bulunamazsa, bu servis üzerinden Gemini yapay zekasına sorulur.

**Dosya Yolu:** `lib/services/sase/gemini_fallback_service.dart`

```dart
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:google_generative_ai/google_generative_ai.dart';
import '../api_key_service.dart';

class GeminiFallbackService {
  static Future<Map<String, dynamic>?> aiSaseCozumle(String sase) async {
    developer.log("🧠 KUANTUM ZEKA Devrede... Şase: \$sase");
    try {
      final apiKey = await ApiKeyService.geminiKeyOku();
      if (apiKey == null || apiKey.isEmpty) return null;

      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      final prompt = '''
        Sen uzman bir otomotiv kriminalistisin. Şase: "\$sase"
        Lütfen analiz et ve sadece JSON formatında dön:
        {"marka": "Bulunan", "model": "Bulunan", "yil": "Tahmini"}
      ''';

      final response = await model.generateContent([Content.text(prompt)]);
      String cleanedJson = response.text!.replaceAll("```json", "").replaceAll("```", "").trim();
      
      final parsedData = json.decode(cleanedJson);
      parsedData["kaynak"] = "Gemini AI";
      return parsedData;

    } catch (e) {
      developer.log("💥 KUANTUM ZEKA ÇÖKTÜ: \$e");
      return null;
    }
  }
}
```

---

## 5. Sistemi Yönetecek Beyin: Kuantum Şase Yönlendiricisi
Arayüzlerden çağırılacak olan tek dosya burasıdır. Tüm yönlendirmeyi yapar.

**Dosya Yolu:** `lib/services/sase/kuantum_sase_router.dart`

```dart
import 'dart:developer' as developer;
import 'nhtsa_api_service.dart';
import 'siber_veri_kazici_service.dart';
import 'gemini_fallback_service.dart';

class KuantumSaseRouter {
  static Future<Map<String, dynamic>?> saseyiCozumle(String saseRaw) async {
    final sase = saseRaw.trim().replaceAll(" ", "").toUpperCase();
    if (sase.isEmpty) return null;

    Map<String, dynamic>? sonuc;

    if (sase.length == 17) {
      sonuc = await NhtsaApiService.decodeVin(sase);
      if (sonuc == null || sonuc["marka"] == "Bilinmiyor") {
        sonuc = await GeminiFallbackService.aiSaseCozumle(sase);
      }
    } else {
      sonuc = await SiberVeriKaziciService.jdmSaseKazi(sase);
      if (sonuc == null) {
        sonuc = await GeminiFallbackService.aiSaseCozumle(sase);
      }
    }
    return sonuc;
  }
}
```

> **Not:** Ünal Bey, bu mimariyi test etmek için projenin herhangi bir yerinde `KuantumSaseRouter.saseyiCozumle("SİZİN_ŞASENİZ")` kodunu çalıştırmanız yeterlidir.
