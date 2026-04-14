// lib/screens/ariza_kaydi.dart
import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // 🔥 GERÇEK STORAGE MOTORU

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

/// 🛡️ KUANTUM KANIT VE MÜHÜRLEME MOTORU
/// Ustanın fotoğraf/video yüklemeden yeşil tık (✅) atmasını engelleyen acımasız denetim terminali.
class SiberArizaKaydi extends StatefulWidget {
  final String saseNo;
  final String modulKodu; // Örn: ICE_MOTOR_KACAK
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

  File? _kanitMedya; // Kameradan alınan dosya
  bool _islemSuruyor = false;

  // ── 📸 SİBER KAMERA / GALERİ ERİŞİMİ ──
  Future<void> _medyaSec(ImageSource kaynak) async {
    developer.log("SİBER RADAR: Medya erişim protokolü tetiklendi.");
    try {
      final picker = ImagePicker();
      final secilenDosya = await picker.pickImage(
        source: kaynak,
        imageQuality: 70, // Bulut optimizasyonu
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

  // ── ⚖️ YARGI MOTORU (GERÇEK STORAGE VE WRITEBATCH ZIRHI) ──
  Future<void> _yesilTikOnayi() async {
    // 1. ZIRH: Fotoğraf Yoksa İhlal Ver!
    if (_kanitMedya == null) {
      developer.log("🚨 SİBER İHLAL: Kanıt yüklenmeden mühürleme yapılamaz!");
      _siberUyariGoster(
          "KANIT BULUNAMADI!",
          "DİKKAT: Fotoğraf yüklemeden Yeşil Tık (✅) basamazsınız. Sistem kilitlendi.",
          SiberTema.kanKirmizi
      );
      return;
    }

    setState(() => _islemSuruyor = true);
    developer.log("🚀 MÜHÜRLEME BAŞLADI: Kanıt Karargaha iletiliyor...");

    try {
      // 2. GERÇEK BULUT YÜKLEMESİ (Firebase Storage)
      String dosyaYolu = 'ekspertiz_kanitlari/${widget.saseNo}/${widget.modulKodu}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      TaskSnapshot snapshot = await _storage.ref().child(dosyaYolu).putFile(_kanitMedya!);
      String gercekKanitUrl = await snapshot.ref.getDownloadURL();

      // 3. ATOMİK VERİTABANI MÜHRÜ VE KARA KUTU (WriteBatch)
      WriteBatch batch = _db.batch();

      // A. Ekspertiz Raporunu Mühürle
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

      // B. Kara Kutuya (Sistem Logları) İşle
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'EKSPERTIZ_MUHURLENDI',
        'islem_detayi': 'SİBER ONAY: ${widget.ustaId} ID\'li usta, ${widget.saseNo} şaseli aracın ${widget.modulKodu} parçasına görsel kanıtlı onay verdi.',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit(); // Füzeyi ateşle!

      developer.log("✅ SİBER MÜHÜR BASILDI: İşlem Karargah ağında atomik olarak şifrelendi.");

      if (!mounted) return;
      _siberUyariGoster("SİBER MÜHÜR BASILDI!", "Kayıt başarıyla Karargaha işlendi.", SiberTema.kuantumCyan);

      // İşlem bitince ekranı kapat
      Navigator.pop(context);

    } catch (e) {
      developer.log("🚨 AĞ ÇÖKTÜ: Mühürleme işlemi başarısız!", error: e);
      if (mounted) {
        setState(() => _islemSuruyor = false);
        _siberUyariGoster("BAĞLANTI HATASI", "Mühür Karargaha iletilemedi! İnternetinizi kontrol edin.", SiberTema.kanKirmizi);
      }
    }
  }

  // ── 🚨 ARAYÜZ YARDIMCILARI ──
  void _siberUyariGoster(String baslik, String mesaj, Color renk) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SiberTema.matGrey,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: renk.withOpacity(0.5), width: 2),
        ),
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
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent, // Arka plan Zırhtan geliyor
        appBar: AppBar(
          title: const Text('KANIT YÜKLEME MERKEZİ', style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 15)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: SiberTema.kuantumCyan.withOpacity(0.2), height: 1),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. ÜST BİLGİ PANELİ (3D Derinlikli)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: SiberTema.matGrey.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
                    boxShadow: SiberTema.siberGolgeKatmanli, // 🔥 3D Zırh
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("DENETİM MODÜLÜ", style: TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(widget.modulKodu.replaceAll('_', ' '), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.pin_drop, color: SiberTema.altinSari, size: 16),
                          const SizedBox(width: 8),
                          Text("ŞASE: ${widget.saseNo}", style: const TextStyle(color: SiberTema.altinSari, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // 2. SİBER MEDYA PANELİ (Kamera Ekranı)
                Expanded(
                  child: GestureDetector(
                    onTap: () => _medyaSec(ImageSource.camera),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _kanitMedya == null ? SiberTema.matGrey.withOpacity(0.5) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _kanitMedya == null ? SiberTema.kanKirmizi.withOpacity(0.5) : SiberTema.kuantumCyan,
                          width: 2,
                        ),
                        boxShadow: _kanitMedya == null ? SiberTema.siberGolgeDerin : [], // 🔥 3D Derinlik
                        image: _kanitMedya != null
                            ? DecorationImage(image: FileImage(_kanitMedya!), fit: BoxFit.cover)
                            : null,
                      ),
                      child: _kanitMedya == null
                          ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_a_photo_rounded, color: SiberTema.kanKirmizi, size: 60, shadows: [Shadow(color: SiberTema.kanKirmizi, blurRadius: 15)]),
                          const SizedBox(height: 16),
                          const Text("ZORUNLU KANIT GEREKİYOR", style: TextStyle(color: SiberTema.kanKirmizi, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                          const SizedBox(height: 8),
                          Text("Kamerayı Açmak İçin Dokun", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                        ],
                      )
                          : Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Container(
                            margin: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: SiberTema.oledBlack.withOpacity(0.7), shape: BoxShape.circle, border: Border.all(color: SiberTema.kanKirmizi)),
                            child: IconButton(
                              icon: const Icon(Icons.close, color: SiberTema.kanKirmizi),
                              onPressed: () => setState(() => _kanitMedya = null),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // 3. KARARGAH MÜHÜRLEME BUTONU (3D)
                SizedBox(
                  height: 64,
                  child: ElevatedButton.icon(
                    icon: _islemSuruyor
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: SiberTema.oledBlack, strokeWidth: 3))
                        : const Icon(Icons.check_circle_outline, color: SiberTema.oledBlack, size: 28),
                    label: Text(
                        _islemSuruyor ? "AĞA YÜKLENİYOR..." : "YEŞİL TIK (MÜHÜRLE)",
                        style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 15, color: SiberTema.oledBlack)
                    ),
                    style: SiberTema.kuantumButonStili(), // 🔥 3D Kuantum Zırhı
                    onPressed: _islemSuruyor ? null : _yesilTikOnayi,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}