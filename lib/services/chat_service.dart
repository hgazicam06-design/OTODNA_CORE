import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM İLETİŞİM MOTORU
/// OtoDNA Müşteri - Usta - Merkez Karargah arası şifreli haberleşmeyi sağlar.
class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 🔐 SİBER SOHBET ODASI KİMLİĞİ OLUŞTURUCU ──────────────────────────────
  // İki taraf arasındaki sohbet odası ID'sini alfabetik sıralayarak her zaman aynı üretir
  String _getChatRoomId(String kullanici1, String kullanici2) {
    List<String> ids = [kullanici1, kullanici2];
    ids.sort(); // Alfabetik sıralama ile benzersiz oda ID'si garantilenir
    return ids.join('_');
  }

  // ── 🚀 SİNYALİ (MESAJI) KUANTUM AĞINA MÜHÜRLE (ATOMİK ZIRH) ───────────────
  Future<void> mesajGonder(String gonderenId, String aliciId, String mesaj) async {
    try {
      String odaId = _getChatRoomId(gonderenId, aliciId);

      // ⛓️ SİBER ZIRH: Atomik WriteBatch Başlatıldı
      WriteBatch batch = _db.batch();

      // 1. Yeni Mesajı Alt Koleksiyona (Subcollection) Ekle
      DocumentReference mesajRef = _db.collection('sohbet_odalari').doc(odaId).collection('mesajlar').doc();
      batch.set(mesajRef, {
        'gonderen_id': gonderenId,
        'alici_id': aliciId,
        'mesaj': mesaj,
        'okundu': false,
        'tarih': FieldValue.serverTimestamp(),
      });

      // 2. Ana Odayı (Sohbet Listesi Ekranı için) Güncelle
      // Bu sayede kullanıcılar "Kimlerle mesajlaştım?" listesini anında görebilir.
      DocumentReference odaRef = _db.collection('sohbet_odalari').doc(odaId);
      batch.set(odaRef, {
        'katilimcilar': [gonderenId, aliciId], // Dizi içinde arama yapabilmek için
        'son_mesaj': mesaj,
        'son_gonderen': gonderenId,
        'son_guncelleme': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Mevcut odayı ezmez, sadece üstüne yazar

      // Füzeleri ateşle! (Ya ikisi de kaydedilir, ya sistem işlemi reddeder)
      await batch.commit();

      developer.log("SİBER BİLGİ: Sinyal Karargah sunucusuna mühürlendi. Hedef: $aliciId");
    } catch (e) {
      developer.log("SİBER İHLAL: Mesaj mühürlenemedi!", error: e);
      throw Exception("AĞ ÇÖKTÜ: Kuantum sinyali iletilemedi!");
    }
  }

  // ── 📡 GERÇEK ZAMANLI SİBER İSTİHBARAT (STREAM) ───────────────────────────
  Stream<QuerySnapshot> mesajAdisyonunuDinle(String gonderenId, String aliciId) {
    String odaId = _getChatRoomId(gonderenId, aliciId);

    // Mesajları tarihe göre sıralayarak canlı (real-time) dinle
    return _db.collection('sohbet_odalari')
        .doc(odaId)
        .collection('mesajlar')
        .orderBy('tarih', descending: false)
        .snapshots();
  }

  // ── 🛰️ SOHBET LİSTESİ RADARI (Aktif Sohbetleri Getir) ─────────────────────
  // Kullanıcının mesajlaştığı tüm odaları listelemek için kullanılır
  Stream<QuerySnapshot> aktifSohbetleriDinle(String kullaniciId) {
    return _db.collection('sohbet_odalari')
        .where('katilimcilar', arrayContains: kullaniciId)
        .orderBy('son_guncelleme', descending: true)
        .snapshots();
  }
}