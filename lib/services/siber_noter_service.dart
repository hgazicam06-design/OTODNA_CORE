import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class SiberNoterService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── ÇİFT YÖNLÜ KUANTUM MÜHRÜ (Müşteri Onay Tetikleyicisi) ──
  Future<Map<String, dynamic>> musteriOnayiVer({
    required String islemId,
    required bool onayDurumu,
  }) async {
    try {
      // 1. Siber Radarı Aç: Müşterinin Milimetrik Konumunu Çek
      // Eğer kullanıcı reddederse veya konum kapalıysa try-catch bloğuna düşer
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 2. Firebase Kilit (Lock-in) Güncellemesi (ATOMİK ATIŞ)
      await _db.collection('islem_kayitlari').doc(islemId).update({
        'musteri_onayi': onayDurumu ? 'onaylandi' : 'reddedildi',
        'musteri_onay_tarihi': FieldValue.serverTimestamp(),
        // 📍 Müşterinin tam o saniyedeki GPS koordinatı veritabanına mühürleniyor!
        'musteri_onay_konumu': GeoPoint(position.latitude, position.longitude),
        // İşlem durumunu güncelle
        'islem_durumu': onayDurumu ? 'Kilitlendi (Çift Yönlü Mühür)' : 'İptal / İtiraz Edildi',
      });

      return {
        'basarili': true,
        'mesaj': onayDurumu ? 'Siber Mühür Basıldı! İşlem Onaylandı.' : 'İşlem Reddedildi! Bayiye Bildirim Gitti.'
      };

    } catch (e) {
      // KVKK veya Konum kapalıysa Karargahı uyar
      return {
        'basarili': false,
        'hata': 'Konum alınamadı! Çift Yönlü Mühür için konum izni zorunludur. Hata: $e'
      };
    }
  }

  // ── İŞLEM İZLEME (SİBER GÖZ) ──
  // Müşteri ekranı için aktif işlemi anlık (canlı) takip eden Kuantum Akışı
  Stream<DocumentSnapshot> canliIslemTakibi(String islemId) {
    return _db.collection('islem_kayitlari').doc(islemId).snapshots();
  }
}