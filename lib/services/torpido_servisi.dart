import 'dart:io';
import 'dart:developer' as developer;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

/// 🛡️ OTODNA SİBER NEŞTER VE DİJİTAL KASA SERVİSİ
class TorpidoServisi {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  // 🔥 SİBER NEŞTER API KEY (remove.bg'den alınan ücretsiz anahtar buraya girilecek)
  final String _removeBgApiKey = "YOUR_REMOVE_BG_API_KEY_HERE";

  /// GALERİDEN VEYA KAMERADAN RESİM SEÇ, ARKA PLANINI YOK ET VE BULUTA MÜHÜRLE
  Future<String?> torpidoyaBelgeEkle({
    required String kullaniciId,
    required String aracId,
    required ImageSource source,
  }) async {
    try {
      developer.log("SİBER GÖZ: Optik lens açılıyor, belge taranacak...");

      // 1. ADIM: SİBER GÖZ İLE GÖRÜNTÜYÜ YAKALA
      final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 85);
      if (pickedFile == null) {
        developer.log("SİBER İPTAL: Kullanıcı taramadan vazgeçti.");
        return null; // Sessiz çöküş değil, bu bir kullanıcı iptalidir.
      }

      File originalFile = File(pickedFile.path);

      // 2. ADIM: SİBER NEŞTER İLE ARKA PLANI KES (API CALL)
      developer.log("SİBER NEŞTER: Arka plan temizliği için yapay zeka tetikleniyor...");
      File? processedFile = await _arkaPlanSilSiberNester(originalFile);

      // API yanıt vermezse orijinali kullan (İşlemi durdurmamak için Taktiksel Geri Çekilme)
      File finalFile = processedFile ?? originalFile;
      String filename = "belge_${DateTime.now().millisecondsSinceEpoch}_${path.basename(finalFile.path)}";

      // 3. ADIM: KUANTUM BULUTUNA (FIREBASE STORAGE) YÜKLE
      developer.log("KUANTUM BULUT: Belge Karargah sunucularına şifrelenerek yükleniyor...");
      String storagePath = 'torpido_kasasi/$kullaniciId/${aracId.toUpperCase()}/$filename';

      TaskSnapshot snapshot = await _storage.ref().child(storagePath).putFile(
        finalFile,
        SettableMetadata(contentType: 'image/png'), // Transparan mühür
      );

      // 4. ADIM: İNDİRME BAĞLANTISINI DEŞİFRE ET
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // 5. ADIM: FIRESTORE ARAÇ KÜTÜĞÜNE (ARRAY) İŞLE
      developer.log("SİBER MÜHÜR: Belge URL'si araç DNA'sına işleniyor...");
      await _db.collection('araclar').doc(aracId.toUpperCase()).update({
        'torpido_belgeleri': FieldValue.arrayUnion([
          {
            'resim_url': downloadUrl,
            'storage_path': storagePath,
            'yuklenme_tarihi': FieldValue.serverTimestamp(),
          }
        ]),
      });

      developer.log("GÖREV TAMAM: ✅ Belge transparan olarak Karargaha mühürlendi.");

      return downloadUrl; // Arayüzde anında göstermek için linki geri fırlat

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Torpido servisi bağlantısı koptu!", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ: UI tarafına kırmızı alarm fırlatılır.
      throw Exception("SİBER KASA HATASI: Belge buluta yüklenemedi! Lütfen internet bağlantınızı kontrol edin.");
    }
  }

  /// SİBER MOTOR: BEYAZ/KARMAŞIK ARKA PLANI YOK EDER
  Future<File?> _arkaPlanSilSiberNester(File imageFile) async {
    try {
      if (_removeBgApiKey == "YOUR_REMOVE_BG_API_KEY_HERE" || _removeBgApiKey.isEmpty) {
        developer.log("SİBER UYARI: Neşter API Key eksik. Orijinal dosya mühürleniyor.");
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
        developer.log("SİBER NEŞTER: Arka plan başarıyla imha edildi!");
        return await File(tempPath).writeAsBytes(res.bodyBytes);
      } else {
        developer.log("SİBER NEŞTER REDDEDİLDİ: HTTP ${response.statusCode}");
        return null; // Başarısızlık durumunda orijinal dosyaya döner
      }
    } catch (e) {
      developer.log("SİBER NEŞTER ÇÖKTÜ!", error: e);
      return null;
    }
  }
}