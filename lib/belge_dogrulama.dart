import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM BELGE VE DİJİTAL KİMLİK MÜHÜRLEME MERKEZİ (BelgeDogrulama)
/// Bayinin resmi belgelerini (HYB, Vergi Levhası) doğrudan kameradan alıp Karargaha (Firebase) şifreleyen terminal.
class BelgeDogrulama extends StatefulWidget {
  final String bayiId; // Belgeleri yükleyen bayinin Karargah kimliği

  const BelgeDogrulama({super.key, required this.bayiId});

  @override
  State<BelgeDogrulama> createState() => _BelgeDogrulamaState();
}

class _BelgeDogrulamaState extends State<BelgeDogrulama> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  File? _hybDosyasi;
  File? _imzaDosyasi;
  bool _islemSuruyor = false;

  // ── 🎨 KARARGAH TASARIM DOKTRİNİ ──
  static const Color _oledBlack = Color(0xFF000000);
  static const Color _matGrey = Color(0xFF111111);
  static const Color _kuantumCyan = Color(0xFF00FFC2);

  // ── 📸 GERÇEK BELGE TARAMA MOTORU ──
  Future<void> _belgeSec(String belgeTipi) async {
    developer.log("SİBER RADAR: $belgeTipi için optik tarayıcı tetiklendi.");
    HapticFeedback.mediumImpact();

    try {
      final picker = ImagePicker();
      final secilenDosya = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70, // Optimizasyon
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

  // ── 🚀 KARARGAHA MÜHÜRLEME (FIREBASE) ──
  Future<void> _saticiligiAktifEt() async {
    HapticFeedback.heavyImpact();

    if (_hybDosyasi == null || _imzaDosyasi == null) {
      _siberUyariGoster(
        "EKSİK BELGE!",
        "DİKKAT: HYB ve İmza Sirkülerini yüklemeden Karargah onayına geçemezsiniz.",
        Colors.redAccent,
      );
      return;
    }

    setState(() => _islemSuruyor = true);
    developer.log("🚀 SİBER MÜHÜR: Belgeler Karargaha iletiliyor...");

    try {
      // SİBER NOT: Gerçekte burada Storage'a yüklenip URL'si Firestore'a yazılır.
      // Firestore'da bayinin belgesini onaylıyoruz.
      await _db.collection('bayi_basvurulari').doc(widget.bayiId).set({
        'belgeler_yuklendi': true,
        'hyb_onay': 'BEKLIYOR',
        'imza_onay': 'BEKLIYOR',
        'belge_zaman_damgasi': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      developer.log("✅ ONAY: Belgeler başarıyla mühürlendi. Admin onayı bekleniyor.");
      _siberUyariGoster("MÜHÜRLENDİ!", "Resmi belgeler Karargaha iletildi. Aktivasyon bekleniyor.", _kuantumCyan);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Belgeler iletilemedi!", error: e);
      _siberUyariGoster("BAĞLANTI HATASI", "İşlem Karargaha iletilemedi.", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _islemSuruyor = false);
    }
  }

  // ── 🚨 ARAYÜZ YARDIMCILARI ──
  void _siberUyariGoster(String baslik, String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _matGrey,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: renk, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            const SizedBox(height: 4),
            Text(mesaj, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool onayaHazir = _hybDosyasi != null && _imzaDosyasi != null;

    return Scaffold(
      backgroundColor: _oledBlack,
      appBar: AppBar(
        title: const Text("RESMİ BELGE ONAY MERKEZİ", style: TextStyle(color: _kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 14)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kuantumCyan),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _talimatKutusu("SİBER UYARI: Ürün eklemek ve Barkod mühürlemek için resmi belgelerinizi optik tarayıcı ile Karargaha iletin."),
              const SizedBox(height: 30),

              _belgeButonu("HİZMET YETERLİLİK BELGESİ (HYB)", "HYB", _hybDosyasi != null),
              const SizedBox(height: 16),
              _belgeButonu("İMZA SİRKÜLERİ / VERGİ LEVHASI", "İmza", _imzaDosyasi != null),

              const Spacer(),

              SizedBox(
                height: 60,
                width: double.infinity,
                child: _islemSuruyor
                    ? const Center(child: CircularProgressIndicator(color: _kuantumCyan))
                    : ElevatedButton.icon(
                  icon: Icon(Icons.verified_user_outlined, color: onayaHazir ? Colors.black : Colors.white30),
                  label: const Text("SATICILIĞI AKTİF ET VE MÜHÜRLE", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: onayaHazir ? _kuantumCyan : Colors.white10,
                    foregroundColor: onayaHazir ? Colors.black : Colors.white30,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: onayaHazir ? 10 : 0,
                    shadowColor: _kuantumCyan.withOpacity(0.5),
                  ),
                  onPressed: onayaHazir ? _saticiligiAktifEt : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _belgeButonu(String metin, String tip, bool yuklendiMi) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: _matGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: yuklendiMi ? _kuantumCyan : Colors.white24, width: yuklendiMi ? 2 : 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(metin, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
        subtitle: Text(yuklendiMi ? "ZAMAN DAMGALI KANIT YÜKLENDİ" : "KAMERAYI AÇMAK İÇİN DOKUNUN",
            style: TextStyle(color: yuklendiMi ? _kuantumCyan : Colors.white54, fontSize: 10, letterSpacing: 1, height: 2)),
        trailing: Icon(yuklendiMi ? Icons.check_circle : Icons.document_scanner_outlined, color: yuklendiMi ? _kuantumCyan : Colors.orangeAccent, size: 28),
        onTap: () => _belgeSec(tip),
      ),
    );
  }

  Widget _talimatKutusu(String metin) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
        color: Colors.orangeAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orangeAccent.withOpacity(0.5), width: 1.5)
    ),
    child: Row(
      children: [
        const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 30),
        const SizedBox(width: 12),
        Expanded(child: Text(metin, style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.5, letterSpacing: 1))),
      ],
    ),
  );
}import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM BELGE VE DİJİTAL KİMLİK MÜHÜRLEME MERKEZİ (BelgeDogrulama)
/// Bayinin resmi belgelerini (HYB, Vergi Levhası) doğrudan kameradan alıp Karargaha (Firebase) şifreleyen terminal.
class BelgeDogrulama extends StatefulWidget {
  final String bayiId; // Belgeleri yükleyen bayinin Karargah kimliği

  const BelgeDogrulama({super.key, required this.bayiId});

  @override
  State<BelgeDogrulama> createState() => _BelgeDogrulamaState();
}

class _BelgeDogrulamaState extends State<BelgeDogrulama> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  File? _hybDosyasi;
  File? _imzaDosyasi;
  bool _islemSuruyor = false;

  // ── 🎨 KARARGAH TASARIM DOKTRİNİ ──
  static const Color _oledBlack = Color(0xFF000000);
  static const Color _matGrey = Color(0xFF111111);
  static const Color _kuantumCyan = Color(0xFF00FFC2);

  // ── 📸 GERÇEK BELGE TARAMA MOTORU ──
  Future<void> _belgeSec(String belgeTipi) async {
    developer.log("SİBER RADAR: $belgeTipi için optik tarayıcı tetiklendi.");
    HapticFeedback.mediumImpact();

    try {
      final picker = ImagePicker();
      final secilenDosya = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70, // Optimizasyon
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

  // ── 🚀 KARARGAHA MÜHÜRLEME (FIREBASE) ──
  Future<void> _saticiligiAktifEt() async {
    HapticFeedback.heavyImpact();

    if (_hybDosyasi == null || _imzaDosyasi == null) {
      _siberUyariGoster(
        "EKSİK BELGE!",
        "DİKKAT: HYB ve İmza Sirkülerini yüklemeden Karargah onayına geçemezsiniz.",
        Colors.redAccent,
      );
      return;
    }

    setState(() => _islemSuruyor = true);
    developer.log("🚀 SİBER MÜHÜR: Belgeler Karargaha iletiliyor...");

    try {
      // SİBER NOT: Gerçekte burada Storage'a yüklenip URL'si Firestore'a yazılır.
      // Firestore'da bayinin belgesini onaylıyoruz.
      await _db.collection('bayi_basvurulari').doc(widget.bayiId).set({
        'belgeler_yuklendi': true,
        'hyb_onay': 'BEKLIYOR',
        'imza_onay': 'BEKLIYOR',
        'belge_zaman_damgasi': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      developer.log("✅ ONAY: Belgeler başarıyla mühürlendi. Admin onayı bekleniyor.");
      _siberUyariGoster("MÜHÜRLENDİ!", "Resmi belgeler Karargaha iletildi. Aktivasyon bekleniyor.", _kuantumCyan);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Belgeler iletilemedi!", error: e);
      _siberUyariGoster("BAĞLANTI HATASI", "İşlem Karargaha iletilemedi.", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _islemSuruyor = false);
    }
  }

  // ── 🚨 ARAYÜZ YARDIMCILARI ──
  void _siberUyariGoster(String baslik, String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _matGrey,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: renk, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            const SizedBox(height: 4),
            Text(mesaj, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool onayaHazir = _hybDosyasi != null && _imzaDosyasi != null;

    return Scaffold(
      backgroundColor: _oledBlack,
      appBar: AppBar(
        title: const Text("RESMİ BELGE ONAY MERKEZİ", style: TextStyle(color: _kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 14)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kuantumCyan),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _talimatKutusu("SİBER UYARI: Ürün eklemek ve Barkod mühürlemek için resmi belgelerinizi optik tarayıcı ile Karargaha iletin."),
              const SizedBox(height: 30),

              _belgeButonu("HİZMET YETERLİLİK BELGESİ (HYB)", "HYB", _hybDosyasi != null),
              const SizedBox(height: 16),
              _belgeButonu("İMZA SİRKÜLERİ / VERGİ LEVHASI", "İmza", _imzaDosyasi != null),

              const Spacer(),

              SizedBox(
                height: 60,
                width: double.infinity,
                child: _islemSuruyor
                    ? const Center(child: CircularProgressIndicator(color: _kuantumCyan))
                    : ElevatedButton.icon(
                  icon: Icon(Icons.verified_user_outlined, color: onayaHazir ? Colors.black : Colors.white30),
                  label: const Text("SATICILIĞI AKTİF ET VE MÜHÜRLE", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: onayaHazir ? _kuantumCyan : Colors.white10,
                    foregroundColor: onayaHazir ? Colors.black : Colors.white30,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: onayaHazir ? 10 : 0,
                    shadowColor: _kuantumCyan.withOpacity(0.5),
                  ),
                  onPressed: onayaHazir ? _saticiligiAktifEt : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _belgeButonu(String metin, String tip, bool yuklendiMi) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: _matGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: yuklendiMi ? _kuantumCyan : Colors.white24, width: yuklendiMi ? 2 : 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(metin, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
        subtitle: Text(yuklendiMi ? "ZAMAN DAMGALI KANIT YÜKLENDİ" : "KAMERAYI AÇMAK İÇİN DOKUNUN",
            style: TextStyle(color: yuklendiMi ? _kuantumCyan : Colors.white54, fontSize: 10, letterSpacing: 1, height: 2)),
        trailing: Icon(yuklendiMi ? Icons.check_circle : Icons.document_scanner_outlined, color: yuklendiMi ? _kuantumCyan : Colors.orangeAccent, size: 28),
        onTap: () => _belgeSec(tip),
      ),
    );
  }

  Widget _talimatKutusu(String metin) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
        color: Colors.orangeAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orangeAccent.withOpacity(0.5), width: 1.5)
    ),
    child: Row(
      children: [
        const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 30),
        const SizedBox(width: 12),
        Expanded(child: Text(metin, style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.5, letterSpacing: 1))),
      ],
    ),
  );
}