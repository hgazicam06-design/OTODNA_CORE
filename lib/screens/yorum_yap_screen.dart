import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class YorumYapScreen extends StatefulWidget {
  final String firmaId;
  final String firmaAdi;
  final String islemId;

  const YorumYapScreen({
    super.key,
    this.firmaId = "FİRMA_001", // Test verisi
    this.firmaAdi = "HEDEF FİRMA", // Test verisi
    this.islemId = "SRV-2026-000", // Test verisi
  });

  @override
  State<YorumYapScreen> createState() => _YorumYapScreenState();
}

class _YorumYapScreenState extends State<YorumYapScreen> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  static const Color bgColor = Color(0xFF000000);
  static const Color surfaceColor = Color(0xFF111111);
  static const Color primaryCyan = Color(0xFF00FFC2);
  static const Color warningColor = Colors.amberAccent;
  static const Color dangerColor = Colors.redAccent;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _yorumController = TextEditingController();
  int _verilenPuan = 5;
  bool _isProcessing = false;

  @override
  void dispose() {
    _yorumController.dispose();
    super.dispose();
  }

  // 🚀 FİREBASE: İSTİHBARATI ANKARA MERKEZE FIRLAT
  Future<void> _yorumuGonder() async {
    String yorum = _yorumController.text.trim();
    User? user = _auth.currentUser;

    if (_verilenPuan <= 3 && yorum.length < 10) {
      _uyariGoster("SİBER İHLAL: Düşük puan verdiğinizde detaylı açıklama yapmak zorundasınız!", isError: true);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // 1. Atomik İşlem Paketi (WriteBatch) Başlat
      WriteBatch batch = _db.batch();

      // Değerlendirme Kaydı
      DocumentReference yorumRef = _db.collection('degerlendirmeler').doc();
      batch.set(yorumRef, {
        'firma_id': widget.firmaId,
        'firma_adi': widget.firmaAdi,
        'musteri_id': user?.uid ?? 'ANONİM_MÜŞTERİ',
        'islem_id': widget.islemId,
        'puan': _verilenPuan,
        'yorum': yorum,
        'tarih': FieldValue.serverTimestamp(),
      });

      // 🚨 EĞER PUAN 3'ÜN ALTINDAYSA ANKARA MERKEZE KIRMIZI ALARM FIRLAT!
      if (_verilenPuan < 3) {
        DocumentReference alarmRef = _db.collection('merkez_uyarilari').doc();
        batch.set(alarmRef, {
          'tip': 'DÜŞÜK_PUAN_İHLALİ',
          'firma_id': widget.firmaId,
          'firma_adi': widget.firmaAdi,
          'islem_id': widget.islemId,
          'puan': _verilenPuan,
          'sebep': yorum,
          'durum': 'İNCELENİYOR', // Karargah paneline (Super Admin) kırmızı düşecek
          'tarih': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      if (!mounted) return;
      _showSuccessDialog(_verilenPuan < 3);

    } catch (e) {
      _uyariGoster("AĞ ÇÖKTÜ: Mühürlü yorum iletilemedi!", isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _uyariGoster(String mesaj, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1)),
        backgroundColor: isError ? dangerColor : primaryCyan,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessDialog(bool isKirmiziAlarm) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isKirmiziAlarm ? dangerColor : primaryCyan, width: 2)),
        title: Row(
          children: [
            Icon(isKirmiziAlarm ? Icons.warning_amber_rounded : Icons.check_circle, color: isKirmiziAlarm ? dangerColor : primaryCyan, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text(isKirmiziAlarm ? "KIRMIZI ALARM VERİLDİ" : "MÜHÜR İLETİLDİ", style: TextStyle(color: isKirmiziAlarm ? dangerColor : primaryCyan, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1))),
          ],
        ),
        content: Text(
          isKirmiziAlarm
              ? "Verdiğiniz düşük puan Ankara Merkez Karargahında acil koda dönüştü. Firma derhal incelemeye alınacaktır!"
              : "Değerlendirmeniz Kuantum Ağına mühürlendi. OtoDNA kalitesine katkınızdan dolayı teşekkür ederiz.",
          style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text("GÖREV TAMAMLANDI", style: TextStyle(color: isKirmiziAlarm ? dangerColor : primaryCyan, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          )
        ],
      ),
    );
  }

  String _puanMetniGetir() {
    switch (_verilenPuan) {
      case 5: return "KUSURSUZ (ALTIN MÜHÜR)";
      case 4: return "BAŞARILI (GÜMÜŞ MÜHÜR)";
      case 3: return "STANDART (BRONZ MÜHÜR)";
      case 2: return "YETERSİZ (İNCELEME GEREKİR)";
      case 1: return "BERBAT (SİBER İHLAL - KARA LİSTE)";
      default: return "DEĞERLENDİRME YAPILMADI";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: primaryCyan, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text("HİZMET DEĞERLENDİRME", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600), // 🖥️ Web / Double Teyp Kalkanı
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. HEDEF FİRMA BİLGİSİ
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.store, color: primaryCyan, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("HEDEF FİRMA", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                              const SizedBox(height: 4),
                              Text(widget.firmaAdi.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 2. ETKİLEŞİMLİ YILDIZ RADARI
                  const Text("HİZMET KALİTESİNİ MÜHÜRLE", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        iconSize: 48,
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return ScaleTransition(scale: animation, child: child);
                          },
                          child: Icon(
                            index < _verilenPuan ? Icons.star : Icons.star_border,
                            key: ValueKey<bool>(index < _verilenPuan),
                            color: index < _verilenPuan ? warningColor : Colors.white24,
                          ),
                        ),
                        onPressed: () => setState(() => _verilenPuan = index + 1),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // 3. DİNAMİK PUAN METNİ
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(color: _verilenPuan < 3 ? dangerColor.withOpacity(0.1) : warningColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: _verilenPuan < 3 ? dangerColor.withOpacity(0.5) : warningColor.withOpacity(0.5))),
                    child: Text(
                      _puanMetniGetir(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _verilenPuan < 3 ? dangerColor : warningColor, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // 4. DETAYLI İSTİHBARAT (YORUM) KUTUSU
                  const Text("SİBER İSTİHBARAT RAPORU (YORUM)", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
                    child: TextField(
                      controller: _yorumController,
                      maxLines: 5,
                      style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5),
                      decoration: InputDecoration(
                        hintText: "Firmanın işlemi ve hizmet kalitesi hakkında detaylı bilgi verin...",
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(20),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primaryCyan, width: 1.5)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 5. ATEŞLEME BUTONU
                  SizedBox(
                    height: 64,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryCyan,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        disabledBackgroundColor: primaryCyan.withOpacity(0.3),
                      ),
                      onPressed: _isProcessing ? null : _yorumuGonder,
                      icon: _isProcessing
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                          : const Icon(Icons.shield, size: 24),
                      label: Text(
                        _isProcessing ? "İSTİHBARAT İLETİLİYOR..." : "ANKARA MERKEZ'E GÖNDER",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}