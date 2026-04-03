// lib/core/takip_radari.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM TAKİP VE DİJİTAL REFERANS MOTORU (SiberTakipRadari)
/// Hantal 2 yıllık muayene çilesini bitirip, aracı KM ve Yaşına göre otonom izler.
/// "OtoDNA Onaylıdır" mührünü ve DNA Skorunu (0-100) güncel tutar.
class SiberTakipRadari {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 📅 1. KUANTUM ARA-MUAYENE (TAKVİM VE KM) PLANLAYICI ──
  /// Aracın mevcut KM'sine ve yaşına bakarak sıradaki ara-muayene hedefini Karargaha kazır.
  static Future<void> siberMuayenePlanla({
    required String aracSaseNo, // Plaka yerine eşsiz Şase No kullanmak daha güvenlidir
    required int mevcutKm,
    required int aracYasi
  }) async {
    developer.log("📡 RADAR AKTİF: $aracSaseNo şaseli aracın ara-muayene planı hesaplanıyor...");

    try {
      // Standart Karargah Kuralı: 6 Ay veya +10.000 KM (Hangisi önce dolarsa)
      DateTime gelecekKontrolTarihi = DateTime.now().add(const Duration(days: 180));
      int hedefKm = mevcutKm + 10000;

      // 🧠 Kuantum Zekası: Eğer araç 10 yaşından büyükse radarı sıklaştır! (3 Ay veya 5.000 KM)
      if (aracYasi > 10) {
        developer.log("⚠️ YAŞLI ARAÇ TESPİTİ: Takip radarı 3 Ay / 5.000 KM'ye daraltıldı.");
        gelecekKontrolTarihi = DateTime.now().add(const Duration(days: 90));
        hedefKm = mevcutKm + 5000;
      }

      await _db.collection('arac_bakimlari').add({
        "sase_no": aracSaseNo,
        "baslangic_km": mevcutKm,
        "hedef_km": hedefKm,
        "hedef_tarih": gelecekKontrolTarihi,
        "durum": "BEKLIYOR", // Muayene gelince ustanın mührüyle "TAMAMLANDI" olacak
        "olusturulma_zaman_damgasi": FieldValue.serverTimestamp(),
      });

      developer.log("✅ HEDEF KİLİTLENDİ: Ara-Muayene planı Matrix'e yazıldı.");
      // SİBER NOT: Burada "Firebase Messaging" ile anlık Push Bildirim (Zamanlanmış) servisi tetiklenecek.

    } catch (e) {
      developer.log("🚨 AĞ ÇÖKTÜ: Muayene planlanamadı!", error: e);
    }
  }

  // ── 🧬 2. DNA PUANI VE DİJİTAL REFERANS (MÜHÜR) MOTORU ──
  /// Aracın bakıma gelme/gelmeme durumuna göre 0-100 arası DNA puanını ve Karargah mührünü yeniler.
  static Future<void> kuantumPuanGuncelle({
    required String aracSaseNo,
    required bool zamanindaGeldiMi
  }) async {
    developer.log("🧬 DNA ANALİZİ: $aracSaseNo şaseli aracın referans puanı hesaplanıyor...");

    try {
      DocumentReference aracRef = _db.collection('arac_kimlikleri').doc(aracSaseNo);

      // Çakışmaları önleyen ACID Kuantum İşlemi (Transaction)
      await _db.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(aracRef);

        if (!snapshot.exists) {
          throw Exception("SİBER İHLAL: Araç Karargah veri tabanında bulunamadı!");
        }

        var data = snapshot.data() as Map<String, dynamic>;
        int mevcutSkor = (data['dna_skoru'] ?? 50).toInt();
        int yeniSkor = mevcutSkor;
        String yeniDurum = data['muayene_durumu'] ?? "BİLİNMİYOR";

        if (zamanindaGeldiMi) {
          // 🟢 Araç zamanında geldiyse: DNA Puanını artır ve Vitrin Mührünü parlat
          yeniSkor += 5;
          if (yeniSkor > 100) yeniSkor = 100; // Zırh Kuralı: Sınır 100'ü geçemez
          yeniDurum = "🟢 OTODNA ONAYLIDIR / REFERANSLIDIR";
          developer.log("✅ ONAY: Araç zamanında geldi. DNA Puanı +5 arttı. Yeni Puan: $yeniSkor");
        } else {
          // 🔴 Araç bakımı aksattıysa: Puanı düşür ve Referansı askıya al
          yeniSkor -= 10; // Ceza motoru daha sert çalışır!
          if (yeniSkor < 0) yeniSkor = 0; // Zırh Kuralı: Sınır 0'ın altına düşemez
          yeniDurum = "🔴 REFERANS BEKLİYOR / GECİKMELİ";
          developer.log("⚠️ İHLAL: Araç bakımı aksattı! DNA Puanı -10 düştü. Yeni Puan: $yeniSkor");
        }

        // Matriks'i yepyeni Kuantum Skoruyla Güncelle
        transaction.update(aracRef, {
          "dna_skoru": yeniSkor,
          "muayene_durumu": yeniDurum,
          "son_muayene_zaman_damgasi": FieldValue.serverTimestamp(),
        });
      });

    } catch (e) {
      developer.log("🚨 AĞ ÇÖKTÜ: DNA Puanı güncellenemedi!", error: e);
    }
  }
}