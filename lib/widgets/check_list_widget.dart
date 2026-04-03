// lib/widgets/check_list_widget.dart
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
// import 'package:image_picker/image_picker.dart'; // AI Kalfa için kamera

/// 🛡️ KUANTUM DENETİM VE ONAY PROTOKOLÜ (SiberCheckList)
/// Sıradan onayları engeller, Kuantum temasıyla parlar ve isteğe bağlı AI Kalfa (Kanıt) duvarı kurar.
class SiberCheckList extends StatefulWidget {
  final Map<String, bool> baslangicKontrolleri;
  final bool zorunluKanitAktifMi; // AI Kalfa Fotoğraf sorsun mu?
  final Function(Map<String, bool>) onDegisim; // Değişimleri ana ekrana fırlatır

  const SiberCheckList({
    super.key,
    required this.baslangicKontrolleri,
    this.zorunluKanitAktifMi = false,
    required this.onDegisim,
  });

  @override
  State<SiberCheckList> createState() => _SiberCheckListState();
}

class _SiberCheckListState extends State<SiberCheckList> {
  late Map<String, bool> _kontroller;

  // ── 🎨 KARARGAH TASARIM DOKTRİNİ ──
  static const Color _matGrey = Color(0xFF111111);
  static const Color _kuantumCyan = Color(0xFF00FFC2);

  @override
  void initState() {
    super.initState();
    // Gelen veriyi Kuantum hafızaya klonla
    _kontroller = Map<String, bool>.from(widget.baslangicKontrolleri);
  }

  // ── 📸 AI KALFA: FOTOĞRAFLI ONAY PROTOKOLÜ ──
  Future<void> _durumDegistirVeKanitIste(String anahtar, bool mevcutDurum) async {
    // İşaret kaldırılıyorsa (false yapılıyorsa) kanıta gerek yok, direkt kaldır
    if (mevcutDurum == true) {
      setState(() {
        _kontroller[anahtar] = false;
        widget.onDegisim(_kontroller);
      });
      return;
    }

    // İşaret konuluyorsa ve Karargah Kuralı (Zorunlu Kanıt) aktifse
    if (widget.zorunluKanitAktifMi) {
      developer.log("🚨 AI KALFA: $anahtar için optik kanıt (fotoğraf) talep ediliyor...");

      // SİBER NOT: Gerçek projede image_picker ile kamera açılır
      bool kanitYuklendiMi = await _simuleKameraAcVeDogrula();

      if (!kanitYuklendiMi) {
        _siberUyariGoster("MÜHÜR REDDEDİLDİ!", "Kanıt (Fotoğraf/Video) olmadan YEŞİL TIK basılamaz.", Colors.orangeAccent);
        return; // İşlemi iptal et, kutu işaretlenmez!
      }
    }

    // Kanıt yüklendiyse veya zorunlu değilse mühürle (true yap)
    setState(() {
      _kontroller[anahtar] = true;
      widget.onDegisim(_kontroller);
    });
    developer.log("✅ SİBER ONAY: $anahtar Karargah standartlarından geçti.");
  }

  // (Simülasyon) Kamerayı açar ve resim gelirse true döner
  Future<bool> _simuleKameraAcVeDogrula() async {
    // await ImagePicker().pickImage(source: ImageSource.camera);
    await Future.delayed(const Duration(milliseconds: 500));
    return true; // Test için her zaman onaylıyoruz. Gerçekte resim varsa true döner.
  }

  // ── 🚨 ARAYÜZ YARDIMCILARI ──
  void _siberUyariGoster(String baslik, String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0A0A0A), // Çok Koyu Siyah/Gri
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
    return Column(
      children: _kontroller.keys.map((String key) {
        bool isOnayli = _kontroller[key] ?? false;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isOnayli ? _kuantumCyan.withOpacity(0.05) : _matGrey,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOnayli ? _kuantumCyan : Colors.white12,
              width: isOnayli ? 1.5 : 1.0,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(
              key.toUpperCase(),
              style: TextStyle(
                color: isOnayli ? _kuantumCyan : Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
            trailing: InkWell(
              onTap: () => _durumDegistirVeKanitIste(key, isOnayli),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isOnayli ? _kuantumCyan : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isOnayli ? _kuantumCyan : Colors.white30, width: 2),
                ),
                child: Icon(
                  Icons.check,
                  size: 20,
                  color: isOnayli ? Colors.black : Colors.transparent,
                ),
              ),
            ),
            onTap: () => _durumDegistirVeKanitIste(key, isOnayli),
          ),
        );
      }).toList(),
    );
  }
}