// lib/screens/ariza_kaydi.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// SİBER NOT: Gerçek projede Storage kullanılacak
// import 'package:firebase_storage/firebase_storage.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM KANIT VE MÜHÜRLEME MOTORU (SiberArizaKaydi)
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

  File? _kanitMedya; // Kameradan veya galeriden alınan dosya
  bool _islemSuruyor = false;

  // ── 📸 SİBER KAMERA / GALERİ ERİŞİMİ ──
  Future<void> _medyaSec(ImageSource kaynak) async {
    developer.log("SİBER RADAR: Medya erişim protokolü tetiklendi.");
    try {
      final picker = ImagePicker();
      final secilenDosya = await picker.pickImage(
        source: kaynak,
        imageQuality: 70, // Veritabanı optimizasyonu
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

  // ── ⚖️ YARGI MOTORU (FOTOĞRAFSIZ ONAY ENGELİ) ──
  Future<void> _yesilTikOnayi() async {
    // 1. ZIRH: Fotoğraf Yoksa İhlal Ver!
    if (_kanitMedya == null) {
      developer.log("🚨 SİBER İHLAL: Kanıt yüklenmeden mühürleme yapılamaz!");
      _siberUyariGoster(
          "KANIT BULUNAMADI!",
          "DİKKAT: Fotoğraf veya Video yüklemeden Yeşil Tık (✅) basamazsınız. Sistem kilitlendi.",
          Colors.redAccent
      );
      return;
    }

    setState(() => _islemSuruyor = true);
    developer.log("🚀 MÜHÜRLEME BAŞLADI: Kanıt Karargaha iletiliyor...");

    try {
      // 2. KANIT YÜKLEME (Firebase Storage Simülasyonu)
      // SİBER NOT: Gerçek projede burada resim Firebase Storage'a atılıp indirme linki (URL) alınır.
      // String dosyaUrl = await _storageaKanitYukle(_kanitMedya!);
      String simuleEdilmisUrl = "https://otodna.karargah/storage/${widget.saseNo}_kanit.jpg";

      // 3. VERİTABANI MÜHRÜ (Firestore)
      await _db.collection('ekspertiz_raporlari').add({
        'sase_no': widget.saseNo,
        'modul_kodu': widget.modulKodu,
        'usta_id': widget.ustaId,
        'durum': 'ONAYLANDI_YESIL_TIK',
        'kanit_url': simuleEdilmisUrl,
        'zaman_damgasi': FieldValue.serverTimestamp(),
      });

      developer.log("✅ SİBER MÜHÜR BASILDI: İşlem Karargah ağında şifrelendi.");

      _siberUyariGoster("SİBER MÜHÜR BASILDI!", "Kayıt başarıyla Karargaha işlendi.", const Color(0xFF00FFC2));

      // İşlem bitince ekranı kapat ve usta paneline dön
      if (mounted) Navigator.pop(context);

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Mühürleme işlemi başarısız!", error: e);
      _siberUyariGoster("BAĞLANTI HATASI", "Mühür Karargaha iletilemedi.", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _islemSuruyor = false);
    }
  }

  // ── 🚨 ARAYÜZ YARDIMCILARI ──
  void _siberUyariGoster(String baslik, String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF111111), // Mat Cam
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: renk, width: 2),
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
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // OLED Siyah
      appBar: AppBar(
        title: const Text('KANIT YÜKLEME MERKEZİ', style: TextStyle(color: Color(0xFF00FFC2), fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF00FFC2)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Üst Bilgi Paneli
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("DENETİM MODÜLÜ", style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2)),
                    const SizedBox(height: 4),
                    Text(widget.modulKodu.replaceAll('_', ' '), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // 2. Siber Medya Paneli
              Expanded(
                child: GestureDetector(
                  onTap: () => _medyaSec(ImageSource.camera),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _kanitMedya == null ? const Color(0xFF111111) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _kanitMedya == null ? Colors.redAccent.withOpacity(0.5) : const Color(0xFF00FFC2),
                        width: 2,
                      ),
                      image: _kanitMedya != null
                          ? DecorationImage(image: FileImage(_kanitMedya!), fit: BoxFit.cover)
                          : null,
                    ),
                    child: _kanitMedya == null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_a_photo_outlined, color: Colors.redAccent, size: 60),
                        SizedBox(height: 16),
                        Text("ZORUNLU KANIT GEREKİYOR", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        SizedBox(height: 8),
                        Text("Kamerayı Açmak İçin Dokun", style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    )
                        : Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => setState(() => _kanitMedya = null),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 3. Karargah Mühürleme Butonu
              SizedBox(
                height: 60,
                child: _islemSuruyor
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF00FFC2)))
                    : ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline, color: Colors.black, size: 28),
                  label: const Text("YEŞİL TIK (MÜHÜRLE)", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FFC2),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: _kanitMedya == null ? 0 : 10,
                    shadowColor: const Color(0xFF00FFC2).withOpacity(0.5),
                  ),
                  onPressed: _yesilTikOnayi,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}