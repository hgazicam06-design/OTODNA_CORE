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

  // ── 🚀 SİNYALİ (MESAJI) KUANTUM AĞINA MÜHÜRLE ──────────────────────────────
  Future<void> mesajGonder(String gonderenId, String aliciId, String mesaj) async {
    try {
      String odaId = _getChatRoomId(gonderenId, aliciId);

      // Sohbet odasına sinyali mühürle
      await _db.collection('sohbet_odalari').doc(odaId).collection('mesajlar').add({
        'gonderen_id': gonderenId,
        'alici_id': aliciId,
        'mesaj': mesaj,
        'okundu': false,
        'tarih': FieldValue.serverTimestamp(),
      });

      developer.log("SİBER BİLGİ: Mesaj başarıyla Karargah sunucusuna mühürlendi. Hedef: $aliciId");
    } catch (e) {
      developer.log("SİBER İHLAL: Mesaj gönderilemedi!", error: e);
      throw Exception("AĞ ÇÖKTÜ: Sinyal iletilemedi.");
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
}