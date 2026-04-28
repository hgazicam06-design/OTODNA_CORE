// lib/widgets/check_list_widget.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // 🚀 SİBER GÖZ (GERÇEK KAMERA) ENTEGRE EDİLDİ
import 'dart:ui';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM DENETİM VE ONAY PROTOKOLÜ (SiberCheckList)
/// Sıradan onayları engeller, Kuantum temasıyla parlar ve GERÇEK KAMERA (Kanıt) duvarı kurar.
class SiberCheckList extends StatefulWidget {
  final Map<String, bool> baslangicKontrolleri;
  final bool zorunluKanitAktifMi; // AI Kalfa Fotoğraf sorsun mu?
  final Function(Map<String, bool>) onDegisim; // Değişimleri ana ekrana fırlatır
  final Function(String anahtar, String resimYolu)? onKanitYuklendi; // Firebase Storage için resmi fırlatır

  SiberCheckList({
    super.key,
    required this.baslangicKontrolleri,
    this.zorunluKanitAktifMi = false,
    required this.onDegisim,
    this.onKanitYuklendi,
  });

  @override
  State<SiberCheckList> createState() => _SiberCheckListState();
}

class _SiberCheckListState extends State<SiberCheckList> {
  late Map<String, bool> _kontroller;
  final ImagePicker _siberKamera = ImagePicker(); // Karargah Kamerası

  // ── 🎨 KARARGAH TASARIM DOKTRİNİ ──
  static Color _matGrey = Color(0xFF111111);
  static Color _kuantumCyan = Color(0xFF00FFC2);
  static Color _alertOrange = Colors.orangeAccent;

  @override
  void initState() {
    super.initState();
    _kontroller = Map<String, bool>.from(widget.baslangicKontrolleri);
  }

  // 📡 SİBER SENKRONİZASYON: Dışarıdan gelen değişimleri algıla
  @override
  void didUpdateWidget(SiberCheckList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.baslangicKontrolleri != widget.baslangicKontrolleri) {
      _kontroller = Map<String, bool>.from(widget.baslangicKontrolleri);
    }
  }

  // ── 📸 AI KALFA: GERÇEK FOTOĞRAFLI ONAY PROTOKOLÜ ──
  Future<void> _durumDegistirVeKanitIste(String anahtar, bool mevcutDurum) async {
    // İşaret kaldırılıyorsa (false yapılıyorsa) kanıta gerek yok, direkt kaldır
    if (mevcutDurum == true) {
      setState(() {
        _kontroller[anahtar] = false;
        widget.onDegisim(_kontroller);
      });
      developer.log("🚨 SİBER BİLGİ: $anahtar onayı usta tarafından geri çekildi.");
      return;
    }

    // İşaret konuluyorsa ve Karargah Kuralı (Zorunlu Kanıt) aktifse
    if (widget.zorunluKanitAktifMi) {
      developer.log("🚨 AI KALFA: $anahtar için GERÇEK optik kanıt (fotoğraf) talep ediliyor...");

      // 🚀 MAKET YIKILDI: GERÇEK KAMERA AÇILIYOR
      String? cekilenResimYolu = await _gercekKameraAcVeDogrula();

      if (cekilenResimYolu == null) {
        _siberUyariGoster("MÜHÜR REDDEDİLDİ!", "Kanıt (Fotoğraf) yüklemeden bu parçaya ONAY veremezsiniz.", _alertOrange);
        return; // Kamera iptal edildi, işlemi iptal et! Kutu İŞARETLENMEZ!
      }

      // Resim başarıyla çekildiyse, Firebase'e yüklemesi için ana ekrana fırlat
      if (widget.onKanitYuklendi != null) {
        widget.onKanitYuklendi!(anahtar, cekilenResimYolu);
      }
    }

    // Kanıt yüklendiyse veya zorunlu değilse mühürle (true yap)
    setState(() {
      _kontroller[anahtar] = true;
      widget.onDegisim(_kontroller);
    });
    developer.log("✅ SİBER ONAY: $anahtar Karargah standartlarından geçti ve kilitlendi.");
  }

  // 📸 GERÇEK SİBER GÖZ MOTORU
  Future<String?> _gercekKameraAcVeDogrula() async {
    try {
      final XFile? foto = await _siberKamera.pickImage(
        source: ImageSource.camera,
        imageQuality: 70, // Firebase Storage tasarrufu için optimize edildi
      );

      if (foto != null) {
        return foto.path; // Fotoğrafın fiziksel yolunu döndür
      }
      return null; // Kullanıcı kamerayı kapattı
    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Kamera motoru başlatılamadı!", error: e);
      _siberUyariGoster("KAMERA HATASI", "Siber Göz (Kamera) başlatılamadı. İzinleri kontrol edin.", Colors.redAccent);
      return null;
    }
  }

  // ── 🚨 ARAYÜZ YARDIMCILARI ──
  void _siberUyariGoster(String baslik, String mesaj, Color renk) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Color(0xFF0A0A0A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: renk, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            SizedBox(height: 4),
            Text(mesaj, style: TextStyle(color: Colors.white70, fontSize: 12)),
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
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Siber Cam Zırhı
              child: Container(
                decoration: BoxDecoration(
                  color: isOnayli ? _kuantumCyan.withOpacity(0.08) : _matGrey.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isOnayli ? _kuantumCyan : Colors.white12,
                    width: isOnayli ? 1.5 : 1.0,
                  ),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    key.toUpperCase(),
                    style: TextStyle(
                      color: isOnayli ? _kuantumCyan : Colors.white70,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 1.5,
                    ),
                  ),
                  subtitle: (widget.zorunluKanitAktifMi && !isOnayli)
                      ? Text("📸 ONAY İÇİN KANIT ZORUNLUDUR", style: TextStyle(color: _alertOrange, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1))
                      : null,
                  trailing: InkWell(
                    onTap: () => _durumDegistirVeKanitIste(key, isOnayli),
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isOnayli ? _kuantumCyan : Colors.black45,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isOnayli ? _kuantumCyan : Colors.white30, width: 2),
                        boxShadow: isOnayli ? [BoxShadow(color: _kuantumCyan.withOpacity(0.5), blurRadius: 8)] : [],
                      ),
                      child: Icon(
                        Icons.check,
                        size: 22,
                        color: isOnayli ? Colors.black : Colors.transparent,
                      ),
                    ),
                  ),
                  onTap: () => _durumDegistirVeKanitIste(key, isOnayli),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}