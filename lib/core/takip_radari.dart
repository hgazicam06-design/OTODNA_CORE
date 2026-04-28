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
    required String aracSaseNo,
    required int mevcutKm,
    required int aracYasi
  }) async {
    developer.log("📡 RADAR AKTİF: $aracSaseNo şaseli aracın ara-muayene planı hesaplanıyor...");

    try {
      // Standart Karargah Kuralı: 6 Ay veya +10.000 KM (Hangisi önce dolarsa)
      DateTime gelecekKontrolTarihi = DateTime.now().add(Duration(days: 180));
      int hedefKm = mevcutKm + 10000;

      // 🧠 Kuantum Zekası: Eğer araç 10 yaşından büyükse radarı sıklaştır! (3 Ay veya 5.000 KM)
      if (aracYasi > 10) {
        developer.log("⚠️ YAŞLI ARAÇ TESPİTİ: Takip radarı 3 Ay / 5.000 KM'ye daraltıldı.");
        gelecekKontrolTarihi = DateTime.now().add(Duration(days: 90));
        hedefKm = mevcutKm + 5000;
      }

      // 🔥 ATOMİK ZIRH: Planı oluştur ve Karargah Kara Kutusuna anında raporla!
      WriteBatch batch = _db.batch();

      DocumentReference bakimRef = _db.collection('arac_bakimlari').doc();
      batch.set(bakimRef, {
        "sase_no": aracSaseNo,
        "baslangic_km": mevcutKm,
        "hedef_km": hedefKm,
        "hedef_tarih": gelecekKontrolTarihi,
        "durum": "BEKLIYOR", // Muayene gelince ustanın mührüyle "TAMAMLANDI" olacak
        "olusturulma_zaman_damgasi": FieldValue.serverTimestamp(),
      });

      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        "islem_turu": "MUAYENE_PLANLANDI",
        "sase_no": aracSaseNo,
        "islem_detayi": "Ara-Muayene kilitlendi: Hedef $hedefKm KM veya ${gelecekKontrolTarihi.toLocal().toString().split(' ')[0]}",
        "tarih": FieldValue.serverTimestamp(),
        "otonom_kayit": true,
      });

      await batch.commit();
      developer.log("✅ HEDEF KİLİTLENDİ: Ara-Muayene planı ve loglar Matrix'e yazıldı.");

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
      // 🛡️ SİBER DÜZELTME: Karargah standartlarına uyum için 'vehicles' koleksiyonu.
      DocumentReference aracRef = _db.collection('vehicles').doc(aracSaseNo);
      DocumentReference logRef = _db.collection('sistem_loglari').doc();

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
        String detayMesaji = "";

        if (zamanindaGeldiMi) {
          // 🟢 Araç zamanında geldiyse: DNA Puanını artır ve Vitrin Mührünü parlat
          yeniSkor += 5;
          if (yeniSkor > 100) yeniSkor = 100; // Zırh Kuralı: Sınır 100'ü geçemez
          yeniDurum = "🟢 OTODNA ONAYLIDIR / REFERANSLIDIR";
          detayMesaji = "BAŞARILI: Araç bakıma zamanında geldi. DNA Puanı arttı (+5).";
        } else {
          // 🔴 Araç bakımı aksattıysa: Puanı düşür ve Referansı askıya al
          yeniSkor -= 10; // Ceza motoru daha sert çalışır!
          if (yeniSkor < 0) yeniSkor = 0; // Zırh Kuralı: Sınır 0'ın altına düşemez
          yeniDurum = "🔴 REFERANS BEKLİYOR / GECİKMELİ";
          detayMesaji = "İHLAL: Bakım gecikti! Araç DNA Puanı düştü (-10). Mühür askıya alındı.";
        }

        // 1. Matriks'i yepyeni Kuantum Skoruyla Güncelle
        transaction.update(aracRef, {
          "dna_skoru": yeniSkor,
          "muayene_durumu": yeniDurum,
          "son_muayene_zaman_damgasi": FieldValue.serverTimestamp(),
        });

        // 2. Kuantum Loglama (Transaction içinde mühürlenir)
        transaction.set(logRef, {
          "islem_turu": "DNA_SKOR_GUNCELLEMESI",
          "sase_no": aracSaseNo,
          "islem_detayi": detayMesaji,
          "eski_skor": mevcutSkor,
          "yeni_skor": yeniSkor,
          "tarih": FieldValue.serverTimestamp(),
          "otonom_kayit": true,
        });
      });

      developer.log("✅ MÜHÜR VURULDU: DNA Skoru güncellendi ve Kara Kutuya kaydedildi.");
    } catch (e) {
      developer.log("🚨 AĞ ÇÖKTÜ: DNA Puanı güncellenemedi!", error: e);
    }
  }

  // ── 👁️ 3. SİBER GÖZ: OTO ELEKTRONİK VE DİJİTAL SİSTEMLER TARAMASI ──
  /// ECU, Ateşleme, Aydınlatma, Güvenlik ve Şarj sistemlerini tarar.
  /// Hata varsa aracı "RİSKLİ" kategorisine alır ve dijital mühür kurallarını denetler.
  static Future<void> siberGozElektronikTaramasi({
    required String aracSaseNo,
    required String ustaUid,
    required List<String> hataKodlari, // Örn: ['P0300', 'U0100'] (Boşsa sorun yok)
    required bool obdRaporuYuklendi,
    required bool multimetreVerisiGirildi,
    required bool sensorGrafikAnaliziYapildi,
  }) async {
    developer.log("👁️ SİBER GÖZ AKTİF: $aracSaseNo şaseli aracın elektronik sinir ağı taranıyor...");

    try {
      // 🛡️ Dijital İmza Kuralı Denetimi (Zırhlı Kontrol)
      // Elektronik sistemlerde "Hata Yok" demek yetmez, kanıtlanmalıdır.
      if (!obdRaporuYuklendi || !multimetreVerisiGirildi || !sensorGrafikAnaliziYapildi) {
        throw Exception("SİBER İHLAL: Dijital İmza Kuralı (OBD/Multimetre/Grafik) eksik! Elektronik mühür vurulamaz.");
      }

      DocumentReference aracRef = _db.collection('vehicles').doc(aracSaseNo);
      DocumentReference elektronikLogRef = _db.collection('elektronik_taramalar').doc();
      DocumentReference sistemLogRef = _db.collection('sistem_loglari').doc();

      // Çakışmaları önleyen ACID Kuantum İşlemi (Transaction)
      await _db.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(aracRef);

        if (!snapshot.exists) {
          throw Exception("SİBER İHLAL: Araç Karargah veri tabanında bulunamadı!");
        }

        bool sistemTemiz = hataKodlari.isEmpty;
        String yeniDurum;
        String islemDetayi;

        if (sistemTemiz) {
          yeniDurum = "🟢 ELEKTRONİK SİSTEM KUSURSUZ";
          islemDetayi = "Siber Göz Taraması Başarılı: ECU, Ateşleme, Optik, Güvenlik ve Şarj sistemlerinde hata bulunamadı.";
        } else {
          yeniDurum = "🔴 RİSKLİ (ELEKTRONİK ARIZA)";
          islemDetayi = "KRİTİK UYARI: Elektronik sistemlerde hata tespit edildi! Hata Kodları: ${hataKodlari.join(', ')}";
          
          // Araç riskli ise Kuantum Motoru gereği DNA Puanı sert etkilenir (-15 Puan)
          var data = snapshot.data() as Map<String, dynamic>;
          int mevcutSkor = (data['dna_skoru'] ?? 50).toInt();
          int yeniSkor = mevcutSkor - 15;
          if (yeniSkor < 0) yeniSkor = 0;
          
          transaction.update(aracRef, {
            "dna_skoru": yeniSkor,
          });
        }

        // 1. Ana Araç Durumunu Güncelle (Sinir Ağı Durumu)
        transaction.update(aracRef, {
          "elektronik_durum": yeniDurum,
          "son_elektronik_tarama_tarihi": FieldValue.serverTimestamp(),
          "riskli_mi": !sistemTemiz,
        });

        // 2. Detaylı Elektronik Tarama Raporu (Siber Göz Dökümü)
        transaction.set(elektronikLogRef, {
          "sase_no": aracSaseNo,
          "usta_uid": ustaUid,
          "hata_kodlari": hataKodlari,
          "sistem_temiz_mi": sistemTemiz,
          "dijital_imzalar": {
            "obd_raporu": obdRaporuYuklendi,
            "multimetre_verisi": multimetreVerisiGirildi,
            "sensor_grafik": sensorGrafikAnaliziYapildi,
          },
          "tarama_kapsami": [
            "ECU ve Kontrol Üniteleri (Beyin, SRS, Kalibrasyon)",
            "Ateşleme ve Yakıt Yönetimi (Bobin, Enjektör, Sensörler)",
            "Aydınlatma ve Optik Sistemler (LED/Xenon, Cluster)",
            "Güvenlik ve Konfor (ABS/ESP, İmmobilizer, Kameralar)",
            "Şarj ve Marş Sistemleri (Alternatör, BMS)"
          ],
          "tarih": FieldValue.serverTimestamp(),
        });

        // 3. Karargah Kara Kutusuna Yaz (Sistem Logu)
        transaction.set(sistemLogRef, {
          "islem_turu": "ELEKTRONIK_TARAMA",
          "sase_no": aracSaseNo,
          "islem_detayi": islemDetayi,
          "usta_uid": ustaUid,
          "tarih": FieldValue.serverTimestamp(),
          "otonom_kayit": false,
        });
      });

      developer.log("⚡ SİBER GÖZ TARAMASI TAMAMLANDI: Veriler buluta mühürlendi.");
    } catch (e) {
      developer.log("🚨 ELEKTRONİK AĞ ÇÖKTÜ: Siber Göz taraması kaydedilemedi!", error: e);
      rethrow; // UI'da Kırmızı Alarmla ustaya göstermek için hatayı fırlat
    }
  }
}