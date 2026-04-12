import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:developer' as developer;

class SiberNoterService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── ÇİFT YÖNLÜ KUANTUM MÜHRÜ (Müşteri Onay Tetikleyicisi) ──
  Future<void> musteriOnayiVer({
    required String islemId,
    required bool onayDurumu,
  }) async {
    try {
      developer.log("SİBER NOTER: $islemId referanslı işlem için müşteri kararı tetiklendi. GPS uyduları aranıyor...");

      // 1. Siber Radarı Aç: Müşterinin Milimetrik Konumunu Çek
      // Eğer kullanıcı reddederse veya konum kapalıysa try-catch bloğuna düşer ve füzeyi patlatır!
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      developer.log("SİBER RADAR: Hedef kilitlendi! Konum: ${position.latitude}, ${position.longitude}");

      // ⛓️ SİBER ZIRH: ATOMİK WRITEBATCH BAŞLATILDI
      WriteBatch batch = _db.batch();

      // 2. Firebase Kilit (Lock-in) Güncellemesi
      DocumentReference islemRef = _db.collection('islem_kayitlari').doc(islemId);
      batch.update(islemRef, {
        'musteri_onayi': onayDurumu ? 'onaylandi' : 'reddedildi',
        'musteri_onay_tarihi': FieldValue.serverTimestamp(),
        // 📍 Müşterinin tam o saniyedeki GPS koordinatı veritabanına mühürleniyor!
        'musteri_onay_konumu': GeoPoint(position.latitude, position.longitude),
        // İşlem durumunu güncelle
        'islem_durumu': onayDurumu ? 'Kilitlendi (Çift Yönlü Mühür)' : 'İptal / İtiraz Edildi',
      });

      // 3. Kara Kutuya (Sistem Logları) İşlemi Mühürle
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': onayDurumu ? 'MUSTERI_ONAYI' : 'MUSTERI_REDDI',
        'islem_detayi': 'SİBER NOTER: Müşteri işlemi ${onayDurumu ? 'ONAYLADI' : 'REDDETTİ'}. İşlem ID: $islemId',
        'konum_kilit': GeoPoint(position.latitude, position.longitude),
        'tarih': FieldValue.serverTimestamp(),
      });

      // TÜM FÜZELERİ AYNI ANDA ATEŞLE!
      await batch.commit();

      developer.log("SİBER MÜHÜR: ✅ Çift yönlü onay protokolü Kuantum Ağına kusursuzca işlendi.");

    } catch (e) {
      developer.log("SİBER İHLAL: Müşteri onayı alınamadı! Konum veya ağ hatası.", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ: UI tarafına doğrudan fırlat.
      throw Exception("SİBER NOTER HATASI: İşlemi onaylamak/reddetmek için GPS (Konum) izni zorunludur! Lütfen cihazınızın konumunu açın.");
    }
  }

  // ── İŞLEM İZLEME (SİBER GÖZ) ──
  // Müşteri ekranı için aktif işlemi anlık (canlı) takip eden Kuantum Akışı
  Stream<DocumentSnapshot> canliIslemTakibi(String islemId) {
    developer.log("SİBER GÖZ: $islemId numaralı işlemin akışı radara bağlandı.");
    return _db.collection('islem_kayitlari').doc(islemId).snapshots();
  }
}