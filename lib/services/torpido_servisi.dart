import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

/// OTODNA SİBER NEŞTER VE DİJİTAL KASA SERVİSİ
class TorpidoServisi {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  // 🔥 SİBER NEŞTER API KEY (remove.bg'den alınan ücretsiz anahtar buraya girilecek)
  final String _removeBgApiKey = "YOUR_REMOVE_BG_API_KEY_HERE";

  /// GALERİDEN VEYA KAMERADAN RESİM SEÇ, ARKA PLANINI YOK ET VE BULUTA MÜHÜRLE
  Future<Map<String, dynamic>> torpidoyaBelgeEkle({
    required String kullaniciId,
    required String aracId,
    required ImageSource source,
  }) async {
    try {
      // 1. ADIM: SİBER GÖZ İLE GÖRÜNTÜYÜ YAKALA
      final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 85);
      if (pickedFile == null) return {'basarili': false, 'mesaj': 'Siber İptal: Görüntü seçilmedi.'};

      File originalFile = File(pickedFile.path);

      // 2. ADIM: SİBER NEŞTER İLE ARKA PLANI KES (API CALL)
      File? processedFile = await _arkaPlanSilSiberNester(originalFile);

      // API yanıt vermezse orijinali kullan
      File finalFile = processedFile ?? originalFile;
      String filename = "belge_${DateTime.now().millisecondsSinceEpoch}_${path.basename(finalFile.path)}";

      // 3. ADIM: KUANTUM BULUTUNA (FIREBASE STORAGE) YÜKLE
      // Klasör Yapısı: torpido_kasasi / KullaniciUID / AracID
      String storagePath = 'torpido_kasasi/$kullaniciId/$aracId/$filename';
      TaskSnapshot snapshot = await _storage.ref().child(storagePath).putFile(
        finalFile,
        SettableMetadata(contentType: 'image/png'), // Transparan mühür
      );

      // 4. ADIM: İNDİRME BAĞLANTISINI DEŞİFRE ET
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // 5. ADIM: FIRESTORE ARAÇ KÜTÜĞÜNE (ARRAY) İŞLE
      await _db.collection('araclar').doc(aracId).update({
        'torpido_belgeleri': FieldValue.arrayUnion([
          {
            'resim_url': downloadUrl,
            'storage_path': storagePath,
            'yuklenme_tarihi': FieldValue.serverTimestamp(),
          }
        ]),
      });

      return {
        'basarili': true,
        'resim_url': downloadUrl,
        'mesaj': 'Belge transparan olarak Karargaha mühürlendi.'
      };
    } catch (e) {
      debugPrint("SİBER AĞ HATASI (Torpido): $e");
      return {'basarili': false, 'mesaj': 'Kritik Hata: Veri buluta iletilemedi.'};
    }
  }

  /// SİBER MOTOR: BEYAZ/KARMAŞIK ARKA PLANI YOK EDER
  Future<File?> _arkaPlanSilSiberNester(File imageFile) async {
    try {
      if (_removeBgApiKey == "YOUR_REMOVE_BG_API_KEY_HERE" || _removeBgApiKey.isEmpty) {
        debugPrint("SİBER UYARI: API Key eksik. Orijinal dosya mühürleniyor.");
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
      } else {
        debugPrint("SİBER NEŞTER REDDEDİLDİ: HTTP ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("SİBER NEŞTER ÇÖKTÜ: $e");
      return null;
    }
  }
}