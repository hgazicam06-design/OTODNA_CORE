// lib/screens/kullanici/sos_mekanizmasi.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI VE MERKEZİ TEMA BAĞLANTISI (2 Kat Yukarı)
import '../../../../core/siber_tema.dart';

/// 🛡️ KUANTUM AKILLI S.O.S ATEŞLEME MOTORU (SiberAkilliSOSButonu)
/// 5 saniye basılı tutulduğunda asılsız alarm filtresini geçer ve Matrix'e (Karargaha) KIZIL KOD gönderir.
class SiberAkilliSOSButonu extends StatefulWidget {
  final String kullaniciId;
  final String saseNo; // Hangi aracın yardıma ihtiyacı var?
  final String qrAlanBayiId; // Aracı sisteme kaydeden asıl bayi

  const SiberAkilliSOSButonu({
    super.key,
    required this.kullaniciId,
    required this.saseNo,
    required this.qrAlanBayiId,
  });

  @override
  State<SiberAkilliSOSButonu> createState() => _SiberAkilliSOSButonuState();
}

class _SiberAkilliSOSButonuState extends State<SiberAkilliSOSButonu> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  double _deger = 0.0;
  Timer? _timer;
  bool _sosGonderildi = false;

  // ── ⏱️ 5 SANİYE GÜVENLİK SAYACI ──
  void _sayaciBaslat() {
    if (_sosGonderildi) return;

    HapticFeedback.lightImpact(); // Dokunma hissi başlar
    developer.log("⚠️ S.O.S TETİKLENDİ: 5 Saniyelik güvenlik filtresi aşılıyor...");

    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        if (_deger < 1.0) {
          _deger += 0.01; // 50ms * 100 = 5000ms (5 Saniye)
          if ((_deger * 100).toInt() % 20 == 0) {
            HapticFeedback.selectionClick(); // Dolarken kalp atışı gibi titrer
          }
        } else {
          _timer?.cancel();
          _sosMuhurleVeGonder();
        }
      });
    });
  }

  void _sayaciDurdur() {
    if (_sosGonderildi) return;
    _timer?.cancel();
    setState(() => _deger = 0.0);
    developer.log("🛑 İPTAL: S.O.S ateşlemesi durduruldu.");
  }

  // ── 🚀 FİREBASE S.O.S MÜHÜR MOTORU (ATOMİK ZIRHLI) ──
  Future<void> _sosMuhurleVeGonder() async {
    setState(() {
      _sosGonderildi = true;
      _deger = 1.0;
    });

    HapticFeedback.heavyImpact(); // FÜZE ATEŞLENDİ TİTREŞİMİ!
    developer.log("🚨 KIZIL KOD: Asılsız alarm filtresi geçildi! Sinyal Karargaha fırlatılıyor...");

    try {
      // SİBER NOT: Gerçek projede Geolocator paketi ile anlık GPS çekilir.
      // Şimdilik Karargah lokasyonunu (Ankara) simüle ediyoruz.
      double anlikEnlem = 39.92077;
      double anlikBoylam = 32.85411;

      // 🛡️ ATOMİK MÜHÜRLEME DEVREDE
      WriteBatch batch = _db.batch();

      DocumentReference sosRef = _db.collection('sos_sinyalleri').doc();
      batch.set(sosRef, {
        'kullanici_id': widget.kullaniciId,
        'sase_no': widget.saseNo,
        'asil_bayi_id': widget.qrAlanBayiId,
        'konum_enlem': anlikEnlem,
        'konum_boylam': anlikBoylam,
        'durum': 'ACIL_MUDEHALE_BEKLIYOR',
        'zaman_damgasi': FieldValue.serverTimestamp(),
      });

      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'KIZIL_KOD_SOS',
        'islem_detayi': 'SİBER ALARM: ${widget.kullaniciId} kullanıcısı, ${widget.saseNo} şaseli araç için KIZIL KOD ateşledi.',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit(); // Füzeleri gönder!

      developer.log("✅ MÜHÜRLENDİ: En yakın bayiler, asıl bayi ve Ankara Merkez uyarıldı!");

      if (mounted) {
        _siberUyariGoster("KIZIL KOD GÖNDERİLDİ!", "Ekipler yolda. Konumunuz Ankara Merkez tarafından izleniyor.", SiberTema.kanKirmizi);
      }
    } catch (e) {
      developer.log("🚨 AĞ ÇÖKTÜ: S.O.S fırlatılamadı!", error: e);
      if (mounted) {
        _siberUyariGoster("BAĞLANTI HATASI", "Sinyal iletilemedi, lütfen polisi arayın (112)!", SiberTema.kanKirmizi);
      }
    }
  }

  // ── 🚨 ARAYÜZ YARDIMCILARI ──
  void _siberUyariGoster(String baslik, String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SiberTema.matGrey,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: renk, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            const SizedBox(height: 4),
            Text(mesaj, style: const TextStyle(color: SiberTema.textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 🚀 ATEŞLEME MEKANİZMASI
        GestureDetector(
          onLongPressStart: (_) => _sayaciBaslat(),
          onLongPressEnd: (_) => _sayaciDurdur(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 🛡️ 5 SANİYELİK İLERLEME ÇEMBERİ VE NEON ZIRH
              SizedBox(
                width: 240,
                height: 240,
                child: CircularProgressIndicator(
                  value: _deger,
                  strokeWidth: 12,
                  backgroundColor: SiberTema.oledBlack,
                  color: _sosGonderildi ? SiberTema.kuantumCyan : SiberTema.kanKirmizi,
                ),
              ),
              // 🔴 ANA SİBER BUTON
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _deger > 0 ? 190 + (_deger * 10) : 180, // Basılı tuttukça büyür
                height: _deger > 0 ? 190 + (_deger * 10) : 180,
                decoration: BoxDecoration(
                  color: _sosGonderildi ? SiberTema.kuantumCyan.withOpacity(0.2) : SiberTema.kanKirmizi.withOpacity(0.8),
                  shape: BoxShape.circle,
                  border: Border.all(color: _sosGonderildi ? SiberTema.kuantumCyan : SiberTema.kanKirmizi, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: (_sosGonderildi ? SiberTema.kuantumCyan : SiberTema.kanKirmizi).withOpacity(_deger > 0 ? 0.8 : 0.3),
                      blurRadius: _deger > 0 ? 50 : 20,
                      spreadRadius: _deger > 0 ? 10 : 2,
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _sosGonderildi ? Icons.verified_user : Icons.warning_amber_rounded,
                      color: _sosGonderildi ? SiberTema.kuantumCyan : Colors.white,
                      size: 60,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _sosGonderildi ? "EKİPLER\nYOLDA" : "S.O.S\nATEŞLE",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _sosGonderildi ? SiberTema.kuantumCyan : Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        letterSpacing: 2,
                      ),
                    ),
                    if (!_sosGonderildi) ...[
                      const SizedBox(height: 8),
                      const Text(
                        "5 SN BASILI TUTUN",
                        style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.w900),
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // 📜 KARARGAH KURALLARI VE BİLGİLENDİRME
        if (_sosGonderildi)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: SiberTema.kuantumCyan.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3)),
            ),
            child: const Text(
              "SİBER ONAY: Admin 30 dakika içinde sizinle iletişime geçecektir. Lütfen güvenli bir alanda bekleyin.",
              textAlign: TextAlign.center,
              style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, fontSize: 12, height: 1.5, letterSpacing: 0.5),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: SiberTema.matGrey.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SiberTema.textMuted),
            ),
            child: const Column(
              children: [
                Text("DİKKAT: ASILSIZ İHBAR CEZASI", style: TextStyle(color: SiberTema.kanKirmizi, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
                SizedBox(height: 8),
                Text(
                  "Asılsız alarmlar Karargah radarına kaydedilir. 1. ihlalde Sarı Kart (uyarı), 2. ihlalde Kırmızı Kart ile bu özellik sisteminizde süresiz devre dışı bırakılır.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: SiberTema.textMuted, fontSize: 11, height: 1.5, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
      ],
    );
  }
}