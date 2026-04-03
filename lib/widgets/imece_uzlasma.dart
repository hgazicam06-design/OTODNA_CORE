// lib/utils/imece_uzlasma.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM İMECE UZLAŞMA MOTORU (SiberImeceUzlasma)
/// Bayiler arası arıza çözümlerini ve ortak kararları doğrudan Karargaha (Firebase) mühürler.
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
      // Talebi doğrudan Firebase'e mühürle
      await _db.collection('uzlasma_talepleri').add({
        'sorunlu_bayi_id': sorunluBayiId,
        'cozen_bayi_id': cozenBayiId,
        'ariza_notu': arizaNotu,
        'durum': 'UZLASMA_BEKLIYOR',
        'zaman_damgasi': FieldValue.serverTimestamp(),
      });
      developer.log("✅ ONAY: Uzlaşma talebi Karargah radarına işlendi.");
    } catch (e) {
      developer.log("🚨 AĞ ÇÖKTÜ: Uzlaşma talebi gönderilemedi!", error: e);
    }
  }

  // ── ⚖️ 2. AŞAMA: ORTAK KARARI MÜHÜRLEME ──
  static Future<void> kararBagla({
    required String uzlasmaId, // Hangi talebin karara bağlandığını bilmek ŞART!
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
      // Alınan kararı mevcut talebin üzerine güncelle
      await _db.collection('uzlasma_talepleri').doc(uzlasmaId).update({
        'karar_metni': kararMetni,
        'durum': durumKodu,
        'karar_zaman_damgasi': FieldValue.serverTimestamp(),
      });
      developer.log("✅ ONAY: Uzlaşma kararı Karargah veritabanına mühürlendi.");
    } catch (e) {
      developer.log("🚨 AĞ ÇÖKTÜ: Karar mühürlenemedi!", error: e);
    }
  }
}

// ── SİBER KARAR TİPLERİ ──
enum SiberKararTipi { UCRETSIZ_TAMIR, CEKICI_GONDER, UCRETLI_ONARIM }