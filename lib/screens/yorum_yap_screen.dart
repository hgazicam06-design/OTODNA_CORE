import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🔥 SİBER KÖPRÜLER VE TEMA
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

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
      _siberUyariGoster("SİBER İHLAL: Düşük puan verdiğinizde detaylı açıklama yapmak zorundasınız!", isError: true);
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
      _siberUyariGoster("AĞ ÇÖKTÜ: Mühürlü yorum iletilemedi!", isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _siberUyariGoster(String mesaj, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: TextStyle(fontWeight: FontWeight.w900, color: isError ? Colors.white : SiberTema.oledBlack, letterSpacing: 1, fontFamily: 'Avenir')),
        backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessDialog(bool isKirmiziAlarm) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: SiberTema.matGrey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isKirmiziAlarm ? SiberTema.kanKirmizi : SiberTema.kuantumCyan, width: 2)),
        title: Row(
          children: [
            Icon(isKirmiziAlarm ? Icons.warning_amber_rounded : Icons.check_circle, color: isKirmiziAlarm ? SiberTema.kanKirmizi : SiberTema.kuantumCyan, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text(isKirmiziAlarm ? "KIRMIZI ALARM VERİLDİ" : "MÜHÜR İLETİLDİ", style: TextStyle(color: isKirmiziAlarm ? SiberTema.kanKirmizi : SiberTema.kuantumCyan, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir'))),
          ],
        ),
        content: Text(
          isKirmiziAlarm
              ? "Verdiğiniz düşük puan Ankara Merkez Karargahında acil koda dönüştü. Firma derhal incelemeye alınacaktır!"
              : "Değerlendirmeniz Kuantum Ağına mühürlendi. OtoDNA kalitesine katkınızdan dolayı teşekkür ederiz.",
          style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, height: 1.5, fontFamily: 'Avenir'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text("GÖREV TAMAMLANDI", style: TextStyle(color: isKirmiziAlarm ? SiberTema.kanKirmizi : SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
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
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20), onPressed: () => Navigator.pop(context)),
          title: const Text("HİZMET DEĞERLENDİRME", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/images/radar_grid.png'), fit: BoxFit.cover, opacity: 0.05),
          ),
          child: SafeArea(
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: SiberTema.matGrey.withOpacity(0.8), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.1), shape: BoxShape.circle),
                                  child: const Icon(Icons.store, color: SiberTema.kuantumCyan, size: 24),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("HEDEF FİRMA", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
                                      const SizedBox(height: 4),
                                      Text(widget.firmaAdi.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // 2. ETKİLEŞİMLİ YILDIZ RADARI
                      const Text("HİZMET KALİTESİNİ MÜHÜRLE", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
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
                                color: index < _verilenPuan ? SiberTema.altinSari : Colors.white24,
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
                        decoration: BoxDecoration(color: _verilenPuan < 3 ? SiberTema.kanKirmizi.withOpacity(0.1) : SiberTema.altinSari.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: _verilenPuan < 3 ? SiberTema.kanKirmizi.withOpacity(0.5) : SiberTema.altinSari.withOpacity(0.5))),
                        child: Text(
                          _puanMetniGetir(),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: _verilenPuan < 3 ? SiberTema.kanKirmizi : SiberTema.altinSari, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir'),
                        ),
                      ),
                      const SizedBox(height: 48),

                      // 4. DETAYLI İSTİHBARAT (YORUM) KUTUSU
                      const Text("SİBER İSTİHBARAT RAPORU (YORUM)", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            decoration: BoxDecoration(color: SiberTema.matGrey.withOpacity(0.8), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
                            child: TextField(
                              controller: _yorumController,
                              maxLines: 5,
                              style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5, fontFamily: 'Avenir'),
                              decoration: InputDecoration(
                                hintText: "Firmanın işlemi ve hizmet kalitesi hakkında detaylı bilgi verin...",
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir'),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(20),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: SiberTema.kuantumCyan, width: 1.5)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // 5. ATEŞLEME BUTONU
                      SizedBox(
                        height: 64,
                        child: ElevatedButton.icon(
                          style: SiberTema.kuantumButonStili(),
                          onPressed: _isProcessing ? null : _yorumuGonder,
                          icon: _isProcessing
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: SiberTema.oledBlack, strokeWidth: 2))
                              : const Icon(Icons.shield, size: 24, color: SiberTema.oledBlack),
                          label: Text(
                            _isProcessing ? "İSTİHBARAT İLETİLİYOR..." : "ANKARA MERKEZ'E GÖNDER",
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: SiberTema.oledBlack, fontFamily: 'Avenir'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}