import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// OTODNA KUANTUM EKSPERTİZ VE DENETİM SERVİSİ (V2.0 - ZIRHLI)
/// Bu sınıf, araçların fiziki durumunu Kuantum Ağına mühürleyen ana motorudur.
class EkspertizServisi {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- 🛠️ SİBER EKSPERTİZ: PARÇA KONTROL MOTORU ---
  // [2026-02-22] Kararı: Görsel kanıt yüklenmeden hiçbir parça ONAYLANAMAZ!
  Future<void> kontrolNoktasiGuncelle({
    required String aracId,
    required String bayiId,
    required String parcaAdi,
    required bool isSafe,
    required String detay,
    required String fotoUrl,
  }) async {
    try {
      developer.log("SİBER EKSPERTİZ: $aracId aracı için '$parcaAdi' kontrolü başlatıldı...");

      // 1. AŞAMA: SİBER KANIT KONTROLÜ
      if (fotoUrl.isEmpty) {
        developer.log("SİBER İHLAL: Kanıt fotoğrafı eksik!");
        // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ: UI tarafına doğrudan fırlat!
        throw Exception("SİBER İHLAL: Kanıt fotoğrafı yüklemek zorunludur! DNA kaydı fotoğrafsız mühürlenemez.");
      }

      if (isSafe) {
        // 🔥 YEŞİL TIK PROTOKOLÜ (ATOMİK - WRITEBATCH ZIRHI)
        WriteBatch batch = _db.batch();

        // A. Ekspertiz Noktasına Mühür Vur
        DocumentReference noktaRef = _db.collection('araclar').doc(aracId).collection('ekspertiz_noktalari').doc();
        batch.set(noktaRef, {
          'parca': parcaAdi,
          'durum': 'ONAYLANDI',
          'detay': detay,
          'foto_url': fotoUrl,
          'bayi_id': bayiId,
          'tarih': FieldValue.serverTimestamp(),
        });

        // B. Aracın Kuantum DNA'sını Güncelle
        DocumentReference aracRef = _db.collection('araclar').doc(aracId);
        batch.update(aracRef, {
          'dna_skoru': FieldValue.increment(1), // Her başarılı kontrol skoru yükseltir
          'son_muayene_tarihi': FieldValue.serverTimestamp(),
          'son_islem_yapan_bayi': bayiId,
          'durum': 'AKTİF - GÜVENLİ',
        });

        await batch.commit(); // Füzeyi Karargaha Gönder!
        developer.log("SİBER MÜHÜR: ✅ $parcaAdi onaylandı ve Kuantum Ağına kilitlendi.");

      } else {
        // 🚨 PARÇA HATALIYSA: KRİTİK HATA PROTOKOLÜNÜ (İDAM) BAŞLAT
        await _kritikHataRaporla(aracId: aracId, bayiId: bayiId, parcaAdi: parcaAdi, detay: detay, fotoUrl: fotoUrl);
      }
    } catch (e) {
      developer.log("SİBER İHLAL: Kontrol noktası güncellenemedi!", error: e);
      throw Exception("EKSPERTİZ HATASI: Parça onayı ağa işlenemedi. Lütfen Kuantum Ağınızı kontrol edin! Hata: $e");
    }
  }

  // --- 🚨 KIRMIZI ALARM: TRAFİĞE ÇIKIŞ ENGELİ (ATOMİK PROTOKOL) ---
  Future<void> _kritikHataRaporla({
    required String aracId,
    required String bayiId,
    required String parcaAdi,
    required String detay,
    required String fotoUrl,
  }) async {
    try {
      developer.log("🚨 KIRMIZI ALARM: $parcaAdi için Kritik Hata Protokolü (İdam) devrede!");
      WriteBatch batch = _db.batch();

      // 1. Aracın Dijital Sicilini ANINDA Kilitle (Trafiğe Çıkamaz!)
      DocumentReference aracRef = _db.collection('araclar').doc(aracId);
      batch.update(aracRef, {
        'durum': 'RİSKLİ - TRAFİĞE ÇIKAMAZ',
        'dna_skoru': FieldValue.increment(-10), // Kritik hata DNA skorunu çökertir
        'son_guncelleme': FieldValue.serverTimestamp(),
      });

      // 2. Ekspertiz Raporuna Kritik Hata Kaydını Göm
      DocumentReference raporRef = aracRef.collection('ekspertiz_noktalari').doc();
      batch.set(raporRef, {
        'parca': parcaAdi,
        'durum': 'KRİTİK HATA',
        'detay': detay,
        'foto_url': fotoUrl,
        'bayi_id': bayiId,
        'tarih': FieldValue.serverTimestamp(),
      });

      // 3. Amiral Gemisine (Admin) ve Alıcıya Siber Bildirim Fırlat
      DocumentReference bildirimRef = _db.collection('sistem_bildirimleri').doc();
      batch.set(bildirimRef, {
        'hedef': 'ADMIN_VE_ALICI',
        'arac_id': aracId,
        'baslik': '🚨 TRAFİK ÇIKIŞ RİSKİ!',
        'mesaj': '$parcaAdi parçasında kritik hata: $detay. Araç sistem tarafından kilitlendi.',
        'oncelik': 'KRİTİK',
        'okundu': false,
        'tarih': FieldValue.serverTimestamp(),
      });

      // 4. Kara Kutuya (Sistem Logları) SOS Kaydı Yaz
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'sos',
        'islem_detayi': 'SİBER MÜDAHALE: $aracId plakalı araç $parcaAdi arızası nedeniyle karantinaya alındı.',
        'bayi_id': bayiId,
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit(); // Tüm birimleri uyar ve sistemi kilitle!
      developer.log("SİBER BİLGİ: 🚨 KRİTİK HATA AĞA İŞLENDİ! Araç karantinaya alındı.");

    } catch (e) {
      developer.log("SİSTEM ÇÖKTÜ: Kritik rapor oluşturulamadı!", error: e);
      throw Exception("SİSTEMSEL ANOMALİ: Kritik hata raporu Karargaha iletilemedi! Güvenli bağlantıyı kontrol edin.");
    }
  }
}