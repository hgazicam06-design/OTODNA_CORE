import 'package:otodna/core/siber_tema.dart';
// lib/bayi/belge_dogrulama.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI VE MERKEZİ TEMA BAĞLANTISI
import '../core/siber_tema.dart'; // Yollar klasör yapınıza göre ../../core/ olabilir
import '../core/responsive_kalkan.dart';

/// 🛡️ KUANTUM BELGE VE DİJİTAL KİMLİK MÜHÜRLEME MERKEZİ (BelgeDogrulama)
/// Bayinin resmi belgelerini (HYB, Vergi Levhası) doğrudan kameradan alıp Karargah Bulutuna (Storage) ve Firestore'a ATOMİK şifreleyen terminal.
class BelgeDogrulama extends StatefulWidget {
  final String bayiId; // Belgeleri yükleyen bayinin Karargah kimliği

  BelgeDogrulama({super.key, required this.bayiId});

  @override
  State<BelgeDogrulama> createState() => _BelgeDogrulamaState();
}

class _BelgeDogrulamaState extends State<BelgeDogrulama> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  File? _hybDosyasi;
  File? _imzaDosyasi;
  bool _islemSuruyor = false;

  // ── 📸 GERÇEK BELGE TARAMA MOTORU ──
  Future<void> _belgeSec(String belgeTipi) async {
    developer.log("SİBER RADAR: $belgeTipi için optik tarayıcı tetiklendi.");
    HapticFeedback.mediumImpact();

    try {
      final picker = ImagePicker();
      final secilenDosya = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 60, // Bulut optimizasyonu için %60 Kuantum sıkıştırması
      );

      if (secilenDosya != null) {
        setState(() {
          if (belgeTipi == "HYB") {
            _hybDosyasi = File(secilenDosya.path);
          } else {
            _imzaDosyasi = File(secilenDosya.path);
          }
        });
        HapticFeedback.vibrate();
        developer.log("✅ GÖRSEL KANIT EKLENDİ: $belgeTipi");
      }
    } catch (e) {
      developer.log("KAMERA HATASI: Medya çekilemedi!", error: e);
    }
  }

  // ── 🚀 KARARGAHA GERÇEK MÜHÜRLEME (PARALEL STORAGE + WRITEBATCH) ──
  Future<void> _saticiligiAktifEt() async {
    HapticFeedback.heavyImpact();

    if (_hybDosyasi == null || _imzaDosyasi == null) {
      _siberUyariGoster(
        "EKSİK BELGE!",
        "DİKKAT: HYB ve İmza Sirkülerini yüklemeden Karargah onayına geçemezsiniz.",
        SiberTema.kanKirmizi,
      );
      return;
    }

    setState(() => _islemSuruyor = true);
    developer.log("🚀 SİBER MÜHÜR: Belgeler Karargah Bulutuna (Storage) paralel olarak yükleniyor...");

    try {
      // 1. BELGELERİ BULUTA (STORAGE) PARALEL YÜKLE (Kuantum Hızlandırma)
      String hybYol = 'bayi_belgeleri/${widget.bayiId}/HYB_${DateTime.now().millisecondsSinceEpoch}.jpg';
      String imzaYol = 'bayi_belgeleri/${widget.bayiId}/IMZA_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // İki füzeyi aynı anda ateşleyip zaman kazanıyoruz!
      List<TaskSnapshot> yuklemeSonuclari = await Future.wait([
        _storage.ref().child(hybYol).putFile(_hybDosyasi!),
        _storage.ref().child(imzaYol).putFile(_imzaDosyasi!),
      ]);

      // Şifreli URL'leri al
      String hybUrl = await yuklemeSonuclari[0].ref.getDownloadURL();
      String imzaUrl = await yuklemeSonuclari[1].ref.getDownloadURL();

      // 2. ATOMİK ZIRH (WRITEBATCH) İLE FİREBASE'E MÜHÜRLE
      WriteBatch batch = _db.batch();

      // Bayi Başvuru Dosyasını Güncelle
      DocumentReference bayiRef = _db.collection('bayi_basvurulari').doc(widget.bayiId);
      batch.set(bayiRef, {
        'belgeler_yuklendi': true,
        'hyb_belge_url': hybUrl,
        'imza_belge_url': imzaUrl,
        'hyb_onay': 'BEKLIYOR',
        'imza_onay': 'BEKLIYOR',
        'belge_zaman_damgasi': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Kara Kutuya Sinyal Gönder
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'RESMI_BELGE_YUKLENDI',
        'islem_detayi': 'SİBER İSTİHBARAT: ${widget.bayiId} kimlikli bayi HYB ve Vergi Levhası belgelerini buluta yükleyerek aktivasyon talep etti.',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit(); // Tüm füzeleri ateşle!

      developer.log("✅ ONAY: Belgeler başarıyla buluta kilitlendi ve loglandı. Admin onayı bekleniyor.");

      if (mounted) {
        _siberUyariGoster("MÜHÜRLENDİ!", "Resmi belgeler Karargaha iletildi. Aktivasyon bekleniyor.", SiberTema.kuantumCyan);
        Navigator.pop(context);
      }
    } catch (e) {
      developer.log("🚨 AĞ ÇÖKTÜ: Belgeler iletilemedi!", error: e);
      if (mounted) _siberUyariGoster("BAĞLANTI HATASI", "İşlem Karargaha iletilemedi. Dosya boyutu büyük olabilir.", SiberTema.kanKirmizi);
    } finally {
      if (mounted) setState(() => _islemSuruyor = false);
    }
  }

  // ── 🚨 ARAYÜZ YARDIMCILARI ──
  void _siberUyariGoster(String baslik, String mesaj, Color renk) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SiberTema.matGrey,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: renk, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
            SizedBox(height: 4),
            Text(mesaj, style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Avenir')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool onayaHazir = _hybDosyasi != null && _imzaDosyasi != null;

    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("RESMİ BELGE ONAY MERKEZİ", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13, fontFamily: 'Avenir')),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: SiberTema.kuantumCyan),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _talimatKutusu("SİBER UYARI: Ürün eklemek ve Barkod mühürlemek için resmi belgelerinizi optik tarayıcı ile Karargaha iletin."),
                SizedBox(height: 30),

                _belgeButonu("HİZMET YETERLİLİK BELGESİ (HYB)", "HYB", _hybDosyasi != null),
                SizedBox(height: 16),
                _belgeButonu("İMZA SİRKÜLERİ / VERGİ LEVHASI", "İmza", _imzaDosyasi != null),

                Spacer(),

                SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: _islemSuruyor
                      ? Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan))
                      : ElevatedButton.icon(
                    icon: Icon(Icons.verified_user_outlined, color: onayaHazir ? Colors.black : Colors.white30),
                    label: Text("SATICILIĞI AKTİF ET VE MÜHÜRLE", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12, fontFamily: 'Avenir')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: onayaHazir ? SiberTema.kuantumCyan : Colors.white10,
                      foregroundColor: onayaHazir ? Colors.black : Colors.white30,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: onayaHazir ? 10 : 0,
                      shadowColor: SiberTema.kuantumCyan.withOpacity(0.5),
                    ),
                    onPressed: onayaHazir ? _saticiligiAktifEt : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _belgeButonu(String metin, String tip, bool yuklendiMi) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: SiberTema.matGrey.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: yuklendiMi ? SiberTema.kuantumCyan : Colors.white24, width: yuklendiMi ? 2 : 1),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(metin, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1, fontFamily: 'Avenir')),
        subtitle: Text(yuklendiMi ? "ZAMAN DAMGALI KANIT YÜKLENDİ" : "KAMERAYI AÇMAK İÇİN DOKUNUN",
            style: TextStyle(color: yuklendiMi ? SiberTema.kuantumCyan : Colors.white54, fontSize: 9, letterSpacing: 1, height: 2, fontFamily: 'Avenir')),
        trailing: Icon(yuklendiMi ? Icons.check_circle : Icons.document_scanner_outlined, color: yuklendiMi ? SiberTema.kuantumCyan : Colors.orangeAccent, size: 28),
        onTap: () => _belgeSec(tip),
      ),
    );
  }

  Widget _talimatKutusu(String metin) => Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
        color: Colors.orangeAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orangeAccent.withOpacity(0.5), width: 1.5)
    ),
    child: Row(
      children: [
        Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 30),
        SizedBox(width: 12),
        Expanded(child: Text(metin, style: TextStyle(color: Colors.white70, fontSize: 10, height: 1.5, letterSpacing: 1, fontWeight: FontWeight.bold, fontFamily: 'Avenir'))),
      ],
    ),
  );
}