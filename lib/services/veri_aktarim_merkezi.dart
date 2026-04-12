import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM DIŞ İSTİHBARAT VE ENTEGRASYON MERKEZİ (VeriAktarimMerkezi)
/// Dış ekspertiz yazılımlarından gelen ham verileri OtoDNA formatına çevirir,
/// Karargahın mutlak finansal kuralını (%12) uygular ve Kuantum havuzuna atomik mühürler.
class VeriAktarimMerkezi {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 📥 1. DIŞ İSTİHBARAT SÜZGECİ (EKSPERTİZ ENTEGRASYONU) ────────────────
  // 🚀 İMTİYAZ İMHA EDİLDİ: 'isMuratPlaza' parametresi Karargah emriyle kaldırıldı!
  static Future<void> disEkspertizVerisiIsle(Map<String, dynamic> disRapor) async {
    try {
      // 🛡️ Otonom Şase Temizliği
      String hamSase = disRapor['vin_code'] ?? '';
      String muhurluSase = hamSase.trim().toUpperCase();

      if (muhurluSase.isEmpty) {
        throw Exception("SİBER İHLAL: Şase numarası (DNA) olmayan dış veri Karargaha sokulamaz!");
      }

      developer.log("SİBER RADAR: 📥 $muhurluSase için dış ekspertiz verisi işleniyor...");

      // ⚖️ FİNANSAL ÇARK (MUTLAK KARARGAH KURALI)
      // İSTİSNA YOK: Karargahın sarsılmaz kuralı gereği genel pay her zaman %12'dir (%10 Net + %2 Vergi).
      double uygulanacakKomisyon = 0.12;
      String kaynakSube = disRapor['servis_adi'] ?? "Bilinmeyen Dış Kaynak";

      developer.log("SİBER FİNANS: Kaynak '$kaynakSube' olarak tespit edildi. Uygulanan komisyon oranı: %12 (MUTLAK PAY)");

      // ⛓️ ATOMİK ZIRH: WriteBatch Başlatıldı
      WriteBatch batch = _db.batch();

      // 1. 🧬 Kuantum Temiz Veriyi Havuza Al
      DocumentReference havuzRef = _db.collection('dis_ekspertiz_havuzu').doc();
      batch.set(havuzRef, {
        'sase_no': muhurluSase,
        'motor_durumu': disRapor['engine_score'] ?? "Belirtilmemiş",
        'kaporta_boya': disRapor['body_report'] ?? "Belirtilmemiş",
        'kaynak': kaynakSube,
        'uygulanan_komisyon_orani': uygulanacakKomisyon,
        'tarih': disRapor['test_date'] ?? FieldValue.serverTimestamp(),
        'otodna_onayi': false, // SİBER KURAL: Önce Karargah inceleyecek, sonra mühürlenecek!
        'aktarim_tarihi': FieldValue.serverTimestamp(),
      });

      // 2. 🚨 Kara Kutuya (Sistem Logları) Sinyal Gönder
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'DIS_VERI_AKTARIMI',
        'islem_detayi': 'SİBER ENTEGRASYON: $muhurluSase şaseli araç için "$kaynakSube" firmasından dış veri Karargah havuzuna kilitlendi.',
        'birim': 'ENTEGRASYON_MERKEZI',
        'tarih': FieldValue.serverTimestamp(),
      });

      // Tüm Füzeleri Aynı Anda Ateşle!
      await batch.commit();

      developer.log("SİBER İSTİHBARAT: ✅ $muhurluSase numaralı aracın dış ekspertiz verisi OtoDNA havuzuna atomik olarak mühürlendi.");

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Dış ekspertiz verisi içeri alınamadı!", error: e);
      throw Exception("SİSTEMSEL HATA: Dış veri Karargah duvarını aşamadı. Lütfen veri formatını kontrol edin.");
    }
  }
}