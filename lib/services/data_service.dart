import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM VERİ VE ARAÇ KATALOG MOTORU (DataService)
/// Araç markaları ve modellerini doğrudan Kuantum Ağından (Firebase) çeker.
/// SİBER NOT: Şehir ve bölge verileri 'CityService' üzerinden çekilmektedir.
class DataService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 📡 ARAÇ MARKALARINI SORGULA (100% CANLI FİREBASE) ──────────────────
  static Future<List<String>> markalariGetir() async {
    try {
      developer.log("SİBER RADAR: Araç marka kataloğu Kuantum Ağından çekiliyor...");

      // 🚀 MAKET YOK: Firebase 'arac_markalari' koleksiyonundaki tüm aktif markaları çek
      QuerySnapshot snapshot = await _db
          .collection('arac_markalari')
          .where('aktif', isEqualTo: true)
          .get();

      if (snapshot.docs.isEmpty) {
        developer.log("SİBER UYARI: Karargahta hiç marka bulunamadı.");
        return [];
      }

      // Doküman ID'lerini (Örn: RENAULT, BMW) marka adı olarak alıp alfabetik sıralıyoruz
      List<String> markalar = snapshot.docs.map((doc) => doc.id.toUpperCase()).toList();
      markalar.sort(); // Alfabetik mühür

      developer.log("SİBER BİLGİ: ${markalar.length} adet marka radara yüklendi.");
      return markalar;

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Marka kataloğu çekilemedi!", error: e);
      // UI EKRANINDA KIRMIZI ALARM VERMESİ İÇİN HATAYI FIRLAT
      throw Exception("SİBER AĞ HATASI: Araç markaları Karargahtan yüklenemedi!");
    }
  }

  // ── 📡 MARKAYA GÖRE MODEL SORGULAMA MOTORU (100% CANLI FİREBASE) ───────
  static Future<List<String>> modelleriGetir(String marka) async {
    try {
      developer.log("SİBER BİLGİ: $marka markası için model istihbaratı çekiliyor...");

      // 🚀 MAKET YOK: Firebase 'arac_markalari' koleksiyonundan markanın belgesini oku
      DocumentSnapshot doc = await _db.collection('arac_markalari').doc(marka.toUpperCase()).get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // 'modeller' dizisini (Array) Firebase'den çek
        List<String> modeller = List<String>.from(data['modeller'] ?? []);
        modeller.sort(); // Alfabetik mühür

        developer.log("SİBER BİLGİ: $marka için ${modeller.length} model tespit edildi.");
        return modeller;
      } else {
        developer.log("SİBER UYARI: $marka markasına ait model istihbaratı bulunamadı!");
        return [];
      }

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Model verileri alınamadı!", error: e);
      throw Exception("SİBER AĞ HATASI: $marka modelleri ağdan çekilemedi!");
    }
  }
}