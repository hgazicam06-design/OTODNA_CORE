import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM DIŞ İSTİHBARAT VE ENTEGRASYON MERKEZİ (VeriAktarimMerkezi)
/// Dış ekspertiz yazılımlarından gelen ham verileri OtoDNA formatına çevirir,
/// finansal kuralları (%12 veya Murat Plaza %30 istisnası) uygular ve Karargah havuzuna mühürler.
class VeriAktarimMerkezi {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 📥 1. DIŞ İSTİHBARAT SÜZGECİ (EKSPERTİZ ENTEGRASYONU) ────────────────
  static Future<void> disEkspertizVerisiIsle(Map<String, dynamic> disRapor, {bool isMuratPlaza = false}) async {
    try {
      // 🛡️ Otonom Şase Temizliği
      String hamSase = disRapor['vin_code'] ?? '';
      String mühürlüSase = hamSase.trim().toUpperCase();

    if (mühürlüSase.isEmpty) {
    throw Exception("SİBER İHLAL: Şase numarası (DNA) olmayan dış veri Karargaha sokulamaz!");
    }

    developer.log("SİBER RADAR: 📥 $mühürlüSase için dış ekspertiz verisi işleniyor...");

    // ⚖️ FİNANSAL ÇARK (KARARGAH KURALI)
    // Karargahın sarsılmaz kuralı: Genel pay %12 (%10 Net + %2 Vergi). %30 sadece Murat Plaza için geçerlidir!
    double uygulanacakKomisyon = isMuratPlaza ? 0.30 : 0.12;
    String kaynakSube = disRapor['servis_adi'] ?? "Bilinmeyen Dış Kaynak";

    developer.log("SİBER FİNANS: Kaynak '$kaynakSube' olarak tespit edildi. Uygulanan komisyon oranı: %${(uygulanacakKomisyon * 100).toInt()}");

    // 🧬 Kuantum Temiz Veri Formatı
    var temizVeri = {
    'sase_no': mühürlüSase,
    'motor_durumu': disRapor['engine_score'] ?? "Belirtilmemiş",
    'kaporta_boya': disRapor['body_report'] ?? "Belirtilmemiş",
    'kaynak': kaynakSube,
    'uygulanan_komisyon_orani': uygulanacakKomisyon,
    'tarih': disRapor['test_date'] ?? FieldValue.serverTimestamp(),
    'otodna_onayi': false, // SİBER KURAL: Önce Karargah inceleyecek, sonra mühürlenecek!
    'aktarim_tarihi': FieldValue.serverTimestamp(),
    };

    // 🚀 2. VERİYİ KARARGAH HAVUZUNA MÜHÜRLE
    await _db.collection('dis_ekspertiz_havuzu').add(temizVeri);

    developer.log("SİBER İSTİHBARAT: ✅ $mühürlüSase numaralı aracın dış ekspertiz verisi OtoDNA havuzuna başarıyla kilitlendi.");

    } catch (e) {
    developer.log("AĞ ÇÖKTÜ: Dış ekspertiz verisi içeri alınamadı!", error: e);
    throw Exception("SİSTEMSEL HATA: Dış veri Karargah duvarını aşamadı. Lütfen veri formatını kontrol edin.");
    }
  }
}