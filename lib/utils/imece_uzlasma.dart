// lib/utils/imece_uzlasma.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM İMECE UZLAŞMA MOTORU (SiberImeceUzlasma)
/// Bayiler arası arıza çözümlerini ve ortak kararları ATOMİK olarak Karargaha (Firebase) mühürler.
class SiberImeceUzlasma {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 🤝 1. AŞAMA: BAYİLER ARASI UZLAŞMA TALEBİ FIRLATMA ──
  static Future<void> uzlasmaBaslat({
    required String sorunluBayiId,
    required String cozenBayiId,
    required String arizaNotu,
  }) async {
    developer.log("🤝 SİBER UZLAŞMA: $cozenBayiId bayisi, $sorunluBayiId ile temasa geçti. Arıza: $arizaNotu");

    try {
      // ⛓️ ATOMİK ZIRH: İşlemleri Birbirine Kilitle
      WriteBatch batch = _db.batch();

      // 1. Talebi Uzlaşma Havuzuna Mühürle
      DocumentReference uzlasmaRef = _db.collection('uzlasma_talepleri').doc();
      batch.set(uzlasmaRef, {
        'uzlasma_id': uzlasmaRef.id,
        'sorunlu_bayi_id': sorunluBayiId,
        'cozen_bayi_id': cozenBayiId,
        'ariza_notu': arizaNotu,
        'durum': 'UZLASMA_BEKLIYOR',
        'zaman_damgasi': FieldValue.serverTimestamp(),
      });

      // 2. Kara Kutuya (Sistem Logları) Fişi Kes
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'IMECE_UZLASMA_BASLATILDI',
        'islem_detayi': 'SİBER BİLGİ: $cozenBayiId, $sorunluBayiId ile $arizaNotu sorunu için imece protokolü başlattı.',
        'kullanici_id': FirebaseAuth.instance.currentUser?.uid ?? 'SİSTEM',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      developer.log("✅ ONAY: Uzlaşma talebi Karargah radarına ve loglara ATOMİK olarak işlendi.");

    } catch (e) {
      developer.log("🚨 AĞ ÇÖKTÜ: Uzlaşma talebi gönderilemedi!", error: e);
      throw Exception("SİBER İHLAL: Uzlaşma talebi Karargaha mühürlenemedi. Lütfen bağlantınızı kontrol edin.");
    }
  }

  // ── ⚖️ 2. AŞAMA: ORTAK KARARI MÜHÜRLEME ──
  static Future<void> kararBagla({
    required String uzlasmaId,
    required SiberKararTipi tip,
  }) async {
    String kararMetni = "";
    String durumKodu = "";

    switch (tip) {
      case SiberKararTipi.UCRETSIZ_TAMIR:
        kararMetni = "İmece usulü ücretsiz halledildi. Siber Puanlar eklendi.";
        durumKodu = "TAMAMLANDI_UCRETSIZ";
        break;
      case SiberKararTipi.CEKICI_GONDER:
        kararMetni = "Araç çekiciyle ana bayiye gönderiliyor. Masraf paylaşıldı.";
        durumKodu = "CEKICI_YOLDA";
        break;
      case SiberKararTipi.UCRETLI_ONARIM:
        kararMetni = "Parça değişimi gerekiyor. Havuz onayı için Admin'e fırlatıldı.";
        durumKodu = "ADMIN_ONAYI_BEKLIYOR";
        break;
    }

    developer.log("⚖️ SİBER KARAR: $kararMetni");

    try {
      // ⛓️ ATOMİK ZIRH: Kararı ve Logu Aynı Anda Fırlat
      WriteBatch batch = _db.batch();

      // 1. Alınan kararı mevcut talebin üzerine güncelle
      DocumentReference uzlasmaRef = _db.collection('uzlasma_talepleri').doc(uzlasmaId);
      batch.update(uzlasmaRef, {
        'karar_metni': kararMetni,
        'durum': durumKodu,
        'karar_zaman_damgasi': FieldValue.serverTimestamp(),
      });

      // 2. Kararı Kara Kutuya (Sistem Logları) İşle
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'IMECE_KARARI_MUHURLENDI',
        'islem_detayi': 'SİBER KARAR: $uzlasmaId numaralı dosya karara bağlandı -> $durumKodu',
        'kullanici_id': FirebaseAuth.instance.currentUser?.uid ?? 'SİSTEM',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      developer.log("✅ ONAY: Uzlaşma kararı Karargah veritabanına ATOMİK olarak mühürlendi.");

    } catch (e) {
      developer.log("🚨 AĞ ÇÖKTÜ: Karar mühürlenemedi!", error: e);
      throw Exception("SİSTEMSEL HATA: Karar Karargaha iletilemedi.");
    }
  }
}

// ── SİBER KARAR TİPLERİ ──
enum SiberKararTipi { UCRETSIZ_TAMIR, CEKICI_GONDER, UCRETLI_ONARIM }
