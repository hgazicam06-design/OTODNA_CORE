import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM ÜRÜN VE ARAÇ KATALOĞU MOTORU (CatalogService)
/// Araç marka/modellerini ve parça kategorilerini Karargah veritabanından (Firebase) canlı çeker.
class CatalogService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 🚗 1. CANLI MARKA RADARI (MAKET YIKILDI) ──────────────────────────────
  static Future<List<String>> markalariGetir() async {
    try {
      developer.log("SİBER RADAR: Karargah kütüphanesinden araç markaları taranıyor...");

      // Markalar Firestore'daki 'arac_katalogu' koleksiyonunun doküman ID'leri olarak tutulur.
      QuerySnapshot snapshot = await _db.collection('arac_katalogu').get();

      if (snapshot.docs.isEmpty) {
        developer.log("SİBER UYARI: Karargah marka kataloğu boş döndü!");
        return [];
      }

      List<String> markalar = snapshot.docs.map((doc) => doc.id).toList();
      developer.log("SİBER İSTİHBARAT: ${markalar.length} adet marka mühürlendi.");
      return markalar;

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Marka kataloğuna ulaşılamadı!", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ: Arayüze kırmızı alarm fırlatılır.
      throw Exception("SİSTEMSEL HATA: Araç markaları Kuantum Ağından çekilemedi. Bağlantınızı kontrol edin!");
    }
  }

  // ── 🏎️ 2. MARKAYA GÖRE CANLI MODEL SÜZGECİ ───────────────────────────────
  static Future<List<String>> modellereGoreGetir(String marka) async {
    try {
      if (marka.isEmpty) return [];

      developer.log("SİBER RADAR: '$marka' markasına ait modeller Karargahtan çekiliyor...");
      DocumentSnapshot doc = await _db.collection('arac_katalogu').doc(marka).get();

      if (!doc.exists) {
        developer.log("SİBER İHLAL: '$marka' markası Kuantum Ağında bulunamadı!");
        return [];
      }

      // Dokümanın içindeki 'modeller' listesi çekilir
      List<String> modeller = List<String>.from(doc['modeller'] ?? []);
      developer.log("SİBER İSTİHBARAT: $marka için ${modeller.length} model listelendi.");
      return modeller;

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Model kataloğuna ulaşılamadı!", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ
      throw Exception("SİSTEMSEL HATA: Araç modelleri çekilemedi. Lütfen Karargah ağını kontrol edin!");
    }
  }

  // ── ⚙️ 3. CANLI YEDEK PARÇA KATEGORİLERİ ──────────────────────────────────
  static Future<List<String>> parcaKategorileriGetir() async {
    try {
      developer.log("SİBER RADAR: Karargah onaylı yedek parça kategorileri taranıyor...");

      // Kategoriler 'sistem_ayarlari' koleksiyonunda tek bir belgede tutulabilir
      DocumentSnapshot doc = await _db.collection('sistem_ayarlari').doc('parca_kategorileri').get();

      if (!doc.exists) {
        developer.log("SİBER UYARI: Kategori listesi bulunamadı!");
        return [];
      }

      List<String> kategoriler = List<String>.from(doc['kategoriler'] ?? []);
      developer.log("SİBER İSTİHBARAT: ${kategoriler.length} adet yedek parça kategorisi çekildi.");
      return kategoriler;

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Kategori ağına ulaşılamadı!", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ
      throw Exception("SİSTEMSEL HATA: Parça kategorileri okunamadı. Kuantum Ağınızı kontrol edin!");
    }
  }
}