import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../core/responsive_kalkan.dart';

/// 🛡️ KUANTUM KANIT VE MÜHÜRLEME MOTORU (Ivory & Gold Tema)
/// Ustanın fotoğraf/video yüklemeden yeşil tık (✅) atmasını engelleyen acımasız denetim terminali.
class SiberArizaKaydi extends StatefulWidget {
  final String saseNo;
  final String modulKodu;
  final String ustaId;

  const SiberArizaKaydi({
    super.key,
    required this.saseNo,
    required this.modulKodu,
    required this.ustaId,
  });

  @override
  State<SiberArizaKaydi> createState() => _SiberArizaKaydiState();
}

class _SiberArizaKaydiState extends State<SiberArizaKaydi> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  File? _kanitMedya;
  bool _islemSuruyor = false;

  // ⚜️ RENK PALETİ (Fildişi Sedef & Metalik Gold)
  static const Color darkGold = Color(0xFFB8860B);
  static const Color lightGold = Color(0xFFF3E5AB);
  static const Color bgIvory = Color(0xFFFAFAFC);
  static const Color textDark = Color(0xFF2C2519);
  static const Color cardWhite = Colors.white;

  // ── 📸 KAMERA / GALERİ ERİŞİMİ ──
  Future<void> _medyaSec(ImageSource kaynak) async {
    developer.log("SİBER RADAR: Medya erişim protokolü tetiklendi.");
    try {
      final picker = ImagePicker();
      final secilenDosya = await picker.pickImage(
        source: kaynak,
        imageQuality: 70,
      );

      if (secilenDosya != null) {
        setState(() {
          _kanitMedya = File(secilenDosya.path);
        });
        developer.log("✅ GÖRSEL KANIT EKLENDİ: ${secilenDosya.name}");
      }
    } catch (e) {
      developer.log("KAMERA HATASI: Medya çekilemedi!", error: e);
    }
  }

  // ── ⚖️ YARGI MOTORU (WRITEBATCH) ──
  Future<void> _yesilTikOnayi() async {
    if (_kanitMedya == null) {
      developer.log("🚨 SİBER İHLAL: Kanıt yüklenmeden mühürleme yapılamaz!");
      _siberUyariGoster(
          "KANIT BULUNAMADI!",
          "DİKKAT: Fotoğraf yüklemeden onay veremezsiniz.",
          Colors.redAccent
      );
      return;
    }

    setState(() => _islemSuruyor = true);
    developer.log("🚀 MÜHÜRLEME BAŞLADI: Kanıt Karargaha iletiliyor...");

    try {
      String dosyaYolu = 'ekspertiz_kanitlari/${widget.saseNo}/${widget.modulKodu}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      TaskSnapshot snapshot = await _storage.ref().child(dosyaYolu).putFile(_kanitMedya!);
      String gercekKanitUrl = await snapshot.ref.getDownloadURL();

      WriteBatch batch = _db.batch();

      DocumentReference raporRef = _db.collection('ekspertiz_raporlari').doc();
      batch.set(raporRef, {
        'rapor_id': raporRef.id,
        'sase_no': widget.saseNo,
        'modul_kodu': widget.modulKodu,
        'usta_id': widget.ustaId,
        'durum': 'ONAYLANDI_YESIL_TIK',
        'kanit_url': gercekKanitUrl,
        'zaman_damgasi': FieldValue.serverTimestamp(),
      });

      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'EKSPERTIZ_MUHURLENDI',
        'islem_detayi': 'SİBER ONAY: ${widget.ustaId} ID\'li usta, ${widget.saseNo} şaseli aracın ${widget.modulKodu} parçasına görsel kanıtlı onay verdi.',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      developer.log("✅ SİBER MÜHÜR BASILDI.");

      if (!mounted) return;
      _siberUyariGoster("MÜHÜR BASILDI!", "Kayıt başarıyla işlendi.", Colors.green);

      Navigator.pop(context);

    } catch (e) {
      developer.log("🚨 AĞ ÇÖKTÜ: Mühürleme işlemi başarısız!", error: e);
      if (mounted) {
        setState(() => _islemSuruyor = false);
        _siberUyariGoster("BAĞLANTI HATASI", "Mühür iletilemedi! İnternetinizi kontrol edin.", Colors.redAccent);
      }
    }
  }

  void _siberUyariGoster(String baslik, String mesaj, Color renk) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: cardWhite,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: renk.withOpacity(0.5), width: 2),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
            const SizedBox(height: 4),
            Text(mesaj, style: const TextStyle(color: Colors.black87, fontSize: 12, fontFamily: 'Avenir')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: bgIvory,
        appBar: AppBar(
          title: const Text('KANIT VE MÜHÜR MERKEZİ', style: TextStyle(color: textDark, fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 15, fontFamily: 'Avenir')),
          backgroundColor: bgIvory,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: textDark),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: darkGold.withOpacity(0.2), height: 1),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. ÜST BİLGİ PANELİ (Fildişi ve Altın)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: darkGold.withOpacity(0.3), width: 1.5),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("DENETİM MODÜLÜ", style: TextStyle(color: Colors.black54, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                      const SizedBox(height: 6),
                      Text(widget.modulKodu.replaceAll('_', ' '), style: const TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.pin_drop, color: darkGold, size: 16),
                          const SizedBox(width: 8),
                          Text("ŞASE: ${widget.saseNo}", style: const TextStyle(color: darkGold, fontSize: 13, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // 2. KAMERA PANELİ
                Expanded(
                  child: GestureDetector(
                    onTap: () => _medyaSec(ImageSource.camera),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _kanitMedya == null ? cardWhite : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _kanitMedya == null ? Colors.redAccent.withOpacity(0.5) : darkGold,
                          width: 2,
                        ),
                        boxShadow: _kanitMedya == null ? [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)] : [],
                        image: _kanitMedya != null
                            ? DecorationImage(image: FileImage(_kanitMedya!), fit: BoxFit.cover)
                            : null,
                      ),
                      child: _kanitMedya == null
                          ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add_a_photo_rounded, color: Colors.redAccent, size: 50),
                          ),
                          const SizedBox(height: 16),
                          const Text("GÖRSEL KANIT ZORUNLU", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
                          const SizedBox(height: 8),
                          const Text("Kamerayı Açmak İçin Dokun", style: TextStyle(color: Colors.black54, fontSize: 12, fontFamily: 'Avenir')),
                        ],
                      )
                          : Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Container(
                            margin: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: cardWhite.withOpacity(0.9), shape: BoxShape.circle, border: Border.all(color: Colors.redAccent)),
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.redAccent),
                              onPressed: () => setState(() => _kanitMedya = null),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // 3. MÜHÜRLEME BUTONU (Altın Gradient)
                SizedBox(
                  height: 64,
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [lightGold, darkGold],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: darkGold.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: ElevatedButton.icon(
                      icon: _islemSuruyor
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                          : const Icon(Icons.check_circle_outline, color: Colors.white, size: 28),
                      label: Text(
                          _islemSuruyor ? "AĞA YÜKLENİYOR..." : "MÜHRÜ ONAYLA (YEŞİL TIK)",
                          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 15, color: Colors.white, fontFamily: 'Avenir')
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _islemSuruyor ? null : _yesilTikOnayi,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}