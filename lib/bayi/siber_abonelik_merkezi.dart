import 'package:otodna/core/siber_tema.dart';
// lib/bayi/siber_abonelik_merkezi.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

/// 🛡️ KUANTUM ABONELİK VE AYARLAR TERMİNALİ
/// Bayinin Karargaha ödeyeceği aylık/yıllık lisans bedellerini ve sistem ayarlarını yönetir.
class SiberAbonelikMerkezi extends StatefulWidget {
  SiberAbonelikMerkezi({super.key});

  @override
  State<SiberAbonelikMerkezi> createState() => _SiberAbonelikMerkeziState();
}

class _SiberAbonelikMerkeziState extends State<SiberAbonelikMerkezi> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _bayiId = FirebaseAuth.instance.currentUser?.uid ?? "BILINMEYEN_BAYI";
  bool _islemSuruyor = false;

  // SİBER AYARLAR (Otonom Toggle)
  bool _otonomBildirimAcik = true;
  bool _aiReklamOptimizasyonu = true;

  @override
  void initState() {
    super.initState();
    _siberAyarlariGetir();
  }

  Future<void> _siberAyarlariGetir() async {
    var snap = await _db.collection('bayiler').doc(_bayiId).get();
    if (snap.exists && mounted) {
      var data = snap.data() as Map<String, dynamic>;
      setState(() {
        _otonomBildirimAcik = data['otonom_sms_aktif'] ?? true;
        _aiReklamOptimizasyonu = data['ai_reklam_aktif'] ?? true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("KARARGAH ABONELİK VE AYARLAR", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12, fontFamily: 'Avenir')),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: SiberTema.kuantumCyan),
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 🛡️ 1. GÜNCEL ABONELİK RADARI ──
              Text("AKTİF LİSANS DURUMU", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
              SizedBox(height: 12),
              _buildGuncelAbonelikDurumu(),

              SizedBox(height: 32),

              // ── 💎 2. KUANTUM LİSANS PAKETLERİ ──
              Text("LİSANS YENİLEME / YÜKSELTME", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
              SizedBox(height: 12),
              _buildLisansPaketi("SİBER PİYADE (AYLIK)", "Temel servis modülleri ve 500 SMS hakkı.", 1250.0, false),
              SizedBox(height: 12),
              _buildLisansPaketi("KUANTUM LİDER (YILLIK)", "Sınırsız modül, Yapay Zeka hedefleme ve %10 İndirim.", 13500.0, true),

              SizedBox(height: 32),

              // ── ⚙️ 3. SİSTEM VE OTONOMİ AYARLARI ──
              Text("DİJİTAL DÜKKAN AYARLARI", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
              SizedBox(height: 12),
              _buildAyarToggle("Otonom Müşteri Bildirimleri", "Araç durumu değiştiğinde müşteriye anında siber SMS/Bildirim fırlatılır.", _otonomBildirimAcik, (val) {
                setState(() => _otonomBildirimAcik = val);
                _db.collection('bayiler').doc(_bayiId).set({'otonom_sms_aktif': val}, SetOptions(merge: true));
                _ayarLogla("Otonom Bildirim", val);
              }),
              SizedBox(height: 8),
              _buildAyarToggle("Yapay Zeka Reklam Hedeflemesi", "Bakım verilerine göre sistem müşterilere otonom parça reklamı çıkartır.", _aiReklamOptimizasyonu, (val) {
                setState(() => _aiReklamOptimizasyonu = val);
                _db.collection('bayiler').doc(_bayiId).set({'ai_reklam_aktif': val}, SetOptions(merge: true));
                _ayarLogla("AI Reklam Hedefleme", val);
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ── 🔍 GÜNCEL ABONELİK (CANLI VERİTABANI BAĞLANTISI) ──
  Widget _buildGuncelAbonelikDurumu() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _db.collection('bayiler').doc(_bayiId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
        }

        var data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        Timestamp? bitisTarihi = data['abonelik_bitis_tarihi'];
        bool aktifMi = false;
        int kalanGun = 0;

        if (bitisTarihi != null) {
          kalanGun = bitisTarihi.toDate().difference(DateTime.now()).inDays;
          aktifMi = kalanGun > 0;
        }

        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: aktifMi ? SiberTema.kuantumCyan.withOpacity(0.05) : SiberTema.kanKirmizi.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: aktifMi ? SiberTema.kuantumCyan.withOpacity(0.5) : SiberTema.kanKirmizi, width: 2),
            boxShadow: aktifMi ? [] : [BoxShadow(color: SiberTema.kanKirmizi.withOpacity(0.2), blurRadius: 20)],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(aktifMi ? "SİSTEM ÇEVRİMİÇİ" : "LİSANS SÜRESİ DOLDU!", style: TextStyle(color: aktifMi ? SiberTema.kuantumCyan : SiberTema.kanKirmizi, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13, fontFamily: 'Avenir')),
                  Icon(aktifMi ? Icons.verified_user : Icons.gpp_bad, color: aktifMi ? SiberTema.kuantumCyan : SiberTema.kanKirmizi),
                ],
              ),
              SizedBox(height: 16),
              Divider(color: Colors.white10),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("KALAN LİSANS SÜRESİ:", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                  Text(aktifMi ? "$kalanGun GÜN" : "0 GÜN", style: TextStyle(color: aktifMi ? Colors.white : SiberTema.kanKirmizi, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  // ── 💎 LİSANS SATIN ALMA KARTLARI ──
  Widget _buildLisansPaketi(String baslik, String detay, double fiyat, bool isVip) {
    return Container(
      decoration: BoxDecoration(
        color: SiberTema.matGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isVip ? Colors.amberAccent.withOpacity(0.5) : Colors.white10),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Icon(isVip ? Icons.workspace_premium : Icons.shield_outlined, color: isVip ? Colors.amberAccent : SiberTema.kuantumCyan, size: 32),
        title: Text(baslik, style: TextStyle(color: isVip ? Colors.amberAccent : Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1, fontFamily: 'Avenir')),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 6),
          child: Text(detay, style: TextStyle(color: Colors.white54, fontSize: 10, fontFamily: 'Avenir')),
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isVip ? Colors.amberAccent : SiberTema.kuantumCyan.withOpacity(0.1),
            foregroundColor: isVip ? Colors.black : SiberTema.kuantumCyan,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: isVip ? Colors.transparent : SiberTema.kuantumCyan)),
          ),
          onPressed: _islemSuruyor ? null : () => _abonelikSatinAl(baslik, fiyat, isVip ? 365 : 30),
          child: Text("₺${fiyat.toInt()}", style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
        ),
      ),
    );
  }

  // ── ⚙️ SİSTEM AYARLARI TOGGLE ──
  Widget _buildAyarToggle(String baslik, String altMetin, bool deger, Function(bool) onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: SwitchListTile(
        title: Text(baslik, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
        subtitle: Text(altMetin, style: TextStyle(color: Colors.white38, fontSize: 9, fontFamily: 'Avenir')),
        value: deger,
        activeColor: SiberTema.kuantumCyan,
        onChanged: onChanged,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  // ── 🛡️ ATOMİK LİSANS SATIN ALMA (WRITEBATCH & LOG) ──
  Future<void> _abonelikSatinAl(String paketAdi, double tutar, int eklenecekGun) async {
    if (_islemSuruyor) return; // 🔒 DOUBLE SPEND ZIRHI
    setState(() => _islemSuruyor = true);
    developer.log("SİBER FİNANS: $paketAdi için Kuantum ödeme köprüsü açılıyor...");

    try {
      WriteBatch batch = _db.batch();

      // 1. Bayinin Lisans Süresini Güncelle (SÜRE KAYBI AÇIĞI KAPATILDI)
      DocumentReference bayiRef = _db.collection('bayiler').doc(_bayiId);
      DocumentSnapshot bayiSnap = await bayiRef.get();
      
      DateTime simdikiZaman = DateTime.now();
      DateTime yeniBitis = simdikiZaman.add(Duration(days: eklenecekGun));

      if (bayiSnap.exists) {
        var veri = bayiSnap.data() as Map<String, dynamic>;
        Timestamp? mevcutBitis = veri['abonelik_bitis_tarihi'];
        if (mevcutBitis != null) {
          DateTime mevcutBitisTarihi = mevcutBitis.toDate();
          if (mevcutBitisTarihi.isAfter(simdikiZaman)) {
            // Bayinin içerideki hakkı yanmasın diye mevcut sürenin üstüne ekle!
            yeniBitis = mevcutBitisTarihi.add(Duration(days: eklenecekGun));
          }
        }
      }

      batch.set(bayiRef, {
        'abonelik_bitis_tarihi': yeniBitis,
        'abonelik_paketi': paketAdi,
        'abonelik_aktif': true,
      }, SetOptions(merge: true)); // 🔥 SİBER ZIRH EKLENDİ!

      // 2. Karargah Finans Havuzuna (OtoDNA Geliri) Parayı Mühürle
      DocumentReference finansRef = _db.collection('otodna_gelir_havuzu').doc();
      batch.set(finansRef, {
        'bayi_id': _bayiId,
        'islem_turu': 'LISANS_YENILEME',
        'paket': paketAdi,
        'tutar': tutar,
        'tarih': FieldValue.serverTimestamp(),
      });

      // 3. Kara Kutuya (Sistem Logları) İşle
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'ABONELIK_SATIN_ALINDI',
        'islem_detayi': 'SİBER FİNANS: $_bayiId, $paketAdi lisansını ₺$tutar ödeyerek Karargahtan satın aldı. Süre: $eklenecekGun gün uzatıldı.',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: SiberTema.kuantumCyan, content: Text("SİBER ONAY: Lisans başarıyla güncellendi!", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Avenir'))));
      }
    } catch (e) {
      developer.log("🚨 AĞ ÇÖKTÜ: Lisans ödemesi alınamadı!", error: e);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: SiberTema.kanKirmizi, content: Text("BAĞLANTI HATASI!", style: TextStyle(color: Colors.white, fontFamily: 'Avenir'))));
    } finally {
      if (mounted) setState(() => _islemSuruyor = false);
    }
  }

  void _ayarLogla(String ayarAdi, bool durum) {
    developer.log("⚙️ SİBER AYAR: $ayarAdi -> ${durum ? 'AKTİF' : 'PASİF'}");
  }
}