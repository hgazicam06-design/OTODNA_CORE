import 'package:cloud_firestore/cloud_firestore.dart';

/// OTODNA KUANTUM EKSPERTİZ VE DENETİM SERVİSİ
class EkspertizServisi {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- 🛠️ SİBER EKSPERTİZ: PARÇA KONTROL MOTORU ---
  Future<Map<String, dynamic>> kontrolNoktasiGuncelle({
    required String aracId,
    required String bayiId,
    required String parcaAdi,
    required bool isSafe,
    required String detay,
    required String fotoUrl, // [2026-02-22] Kuralı: Fotoğraf Zorunlu!
  }) async {
    try {
      // 1. SİBER KALKAN: Kanıt yüklenmeden işlem yapılamaz!
      if (fotoUrl.isEmpty) {
        return {'basarili': false, 'mesaj': 'SİBER İHLAL: Kanıt fotoğrafı yüklemek zorunludur!'};
      }

      if (isSafe) {
        // 🔥 YEŞİL TIK PROTOKOLÜ (ATOMİK - WRITEBATCH ZIRHI)
        WriteBatch batch = _db.batch();

        // Ekspertiz noktasına mühür vur
        DocumentReference noktaRef = _db.collection('araclar').doc(aracId).collection('ekspertiz_noktalari').doc();
        batch.set(noktaRef, {
          'parca': parcaAdi,
          'durum': 'ONAYLANDI',
          'detay': detay,
          'foto_url': fotoUrl,
          'bayi_id': bayiId,
          'tarih': FieldValue.serverTimestamp(),
        });

        // Aracın kendi DNA sicilini de eşzamanlı güncelle
        DocumentReference aracRef = _db.collection('araclar').doc(aracId);
        batch.update(aracRef, {
          'son_muayene_tarihi': FieldValue.serverTimestamp(),
          'son_islem_yapan_bayi': bayiId,
        });

        await batch.commit(); // Füzeyi Ateşle!

        return {'basarili': true, 'mesaj': '✅ $parcaAdi onaylandı ve Kuantum Ağına mühürlendi.'};
      } else {
        // PARÇA HATALIYSA: KRİTİK HATA PROTOKOLÜNÜ (İDAM) BAŞLAT
        return await _kritikHataRaporla(aracId: aracId, bayiId: bayiId, parcaAdi: parcaAdi, detay: detay, fotoUrl: fotoUrl);
      }
    } catch (e) {
      return {'basarili': false, 'mesaj': 'Ağ Bağlantısı Koptu: $e'};
    }
  }

  // --- 🚨 KIRMIZI ALARM: TRAFİĞE ÇIKIŞ ENGELİ (ATOMİK PROTOKOL) ---
  Future<Map<String, dynamic>> _kritikHataRaporla({
    required String aracId,
    required String bayiId,
    required String parcaAdi,
    required String detay,
    required String fotoUrl,
  }) async {
    try {
      // Kopmaz Kuantum Bağı: Ya hepsi aynı anda yazılır, ya hiçbiri!
      WriteBatch batch = _db.batch();

      // 1. Aracın Dijital Sicilini Anında Kilitle
      DocumentReference aracRef = _db.collection('araclar').doc(aracId);
      batch.update(aracRef, {
        'durum': 'RİSKLİ - TRAFİĞE ÇIKAMAZ',
        'son_guncelleme': FieldValue.serverTimestamp(),
      });

      // 2. Ekspertiz Raporuna Kritik Hata Olarak İşle
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
        'mesaj': '$parcaAdi parçasında kritik hata tespit edildi: $detay. Araç kilitlendi.',
        'okundu': false,
        'tarih': FieldValue.serverTimestamp(),
      });

      // 4. Sistem Loglarına (Kara Kutu) Kırmızı Alarm (SOS) Yaz
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'sos', // Admin panelinde kırmızı neon yakar!
        'islem_detayi': 'EKSPERTİZ MÜDAHALESİ: $aracId plakalı araç $parcaAdi arızası yüzünden trafiğe kapatıldı!',
        'bayi_isim': bayiId,
        'tarih': FieldValue.serverTimestamp(),
      });

      // TÜM FÜZELERİ AYNI ANDA ATEŞLE!
      await batch.commit();

      return {'basarili': true, 'mesaj': '🚨 KRİTİK HATA AĞA İŞLENDİ! Araç trafiğe kapatıldı ve tüm birimler uyarıldı.'};
    } catch (e) {
      return {'basarili': false, 'mesaj': 'HATA: Kritik rapor oluşturulamadı! Sistem yöneticisine başvurun. $e'};
    }
  }
}