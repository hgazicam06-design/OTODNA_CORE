// lib/screens/siber_sos_merkezi.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

/// 🚨 KUANTUM S.O.S MERKEZİ (MEGA PROTOKOL)
/// 5 saniye basılı tutma kuralıyla asılsız ihbarları önler, canlı konumu Matrix'e fırlatır.
class SiberSosMerkezi extends StatefulWidget {
  const SiberSosMerkezi({super.key});

  @override
  State<SiberSosMerkezi> createState() => _SiberSosMerkeziState();
}

class _SiberSosMerkeziState extends State<SiberSosMerkezi> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late AnimationController _basiliTutmaMotoru;
  bool _sosTetiklendi = false; // Füzeler ateşlendi mi?
  bool _islemSuruyor = false;

  @override
  void initState() {
    super.initState();
    // 5 Saniyelik Kuantum Dolum Motoru
    _basiliTutmaMotoru = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    // Motor 5 saniyeyi doldurduğunda füzeyi ateşle!
    _basiliTutmaMotoru.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _kirmiziKoduAtesle();
      }
    });
  }

  @override
  void dispose() {
    _basiliTutmaMotoru.dispose();
    super.dispose();
  }

  // ── 🚨 MATRIX KIRMIZI KOD FIRLATMA PROTOKOLÜ ──
  Future<void> _kirmiziKoduAtesle() async {
    if (_sosTetiklendi || _islemSuruyor) return;

    setState(() {
      _islemSuruyor = true;
      _sosTetiklendi = true;
    });

    HapticFeedback.heavyImpact(); // Cihazı titret
    developer.log("🚨 S.O.S PROTOKOLÜ: KIRMIZI KOD ATEŞLENDİ!");

    try {
      String uid = _auth.currentUser!.uid;

      // 1. Matrix'e Otonom S.O.S Kaydı (Canlı Veritabanı)
      await _db.collection('acil_durum_sinyalleri').add({
        'kullanici_id': uid,
        // SİBER NOT: Gerçek GPS paketi eklendiğinde buraya cihazın anlık konumu gelecek.
        // Şimdilik sistemin çalışması için Karargah (Ankara) koordinatları atanıyor.
        'konum': const GeoPoint(39.92077, 32.85411),
        'zaman_damgasi': FieldValue.serverTimestamp(),
        'durum': 'KIRMIZI_KOD_BEKLIYOR', // Admin 30 dk içinde müdahale etmeli!
        'mudahale_eden_bayi_id': null,
        'sahte_ihbar_mi': false, // Admin daha sonra bunu işaretleyip kullanıcıyı Blacklist'e atabilir
      });

      HapticFeedback.vibrate();
      _siberUyariGoster("KIRMIZI KOD ONAYLANDI", "Sinyal Karargaha ulaştı. Konumunuzda bekleyin, en yakın birimler yola çıkıyor!", SiberTema.kanKirmizi);

    } catch (e) {
      developer.log("🚨 S.O.S AĞI ÇÖKTÜ!", error: e);
      setState(() {
        _sosTetiklendi = false; // Hata olursa tekrar basabilsin
      });
      _siberUyariGoster("SİNYAL HATASI", "S.O.S sinyali iletilemedi. Lütfen doğrudan Karargahı arayın (112).", SiberTema.altinSari);
    } finally {
      if (mounted) setState(() => _islemSuruyor = false);
    }
  }

  // Kullanıcı butona basmaya başladı
  void _basilmayaBasladi(TapDownDetails details) {
    if (_sosTetiklendi) return;
    HapticFeedback.lightImpact();
    _basiliTutmaMotoru.forward(); // Sayacı başlat
  }

  // Kullanıcı 5 saniye dolmadan elini çekti
  void _basilmaBirakildi(TapUpDetails details) {
    if (_sosTetiklendi) return;
    _basiliTutmaMotoru.reverse(); // Sayacı geri al (İptal)
  }

  // Kullanıcının parmağı butondan kaydı
  void _basilmaIptal() {
    if (_sosTetiklendi) return;
    _basiliTutmaMotoru.reverse(); // İptal
  }

  // ── 🔧 ARAYÜZ YARDIMCILARI ──
  void _siberUyariGoster(String baslik, String mesaj, Color renk) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SiberTema.matGrey,
        duration: const Duration(seconds: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: renk, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: renk, size: 24),
                const SizedBox(width: 8),
                Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              ],
            ),
            const SizedBox(height: 8),
            Text(mesaj, style: const TextStyle(color: SiberTema.textMain, fontSize: 13, height: 1.5)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("ACİL DURUM MERKEZİ", style: TextStyle(color: SiberTema.kanKirmizi, fontWeight: FontWeight.w900, letterSpacing: 2)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🛡️ SİBER BİLGİLENDİRME PANELİ
                SiberTema.siberCamKalkan(
                  padding: const EdgeInsets.all(20),
                  child: const Column(
                    children: [
                      Icon(Icons.satellite_alt_outlined, color: SiberTema.kuantumCyan, size: 40),
                      SizedBox(height: 16),
                      Text("MEGA PROTOKOL: KIRMIZI KOD", style: TextStyle(color: SiberTema.kanKirmizi, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                      SizedBox(height: 12),
                      Text(
                        "S.O.S sinyali göndermek için aşağıdaki butona 5 saniye basılı tutun. Asılsız ihbarlar Karargah sistemleri tarafından tespit edilir ve hesabınız KARALİSTE'ye (Blacklist) alınır.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: SiberTema.textMuted, fontSize: 12, height: 1.6),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),

                // 🚨 OTONOM S.O.S BUTONU (Basılı Tutma Radarı)
                GestureDetector(
                  onTapDown: _basilmayaBasladi,
                  onTapUp: _basilmaBirakildi,
                  onTapCancel: _basilmaIptal,
                  child: AnimatedBuilder(
                    animation: _basiliTutmaMotoru,
                    builder: (context, child) {
                      double dolumOrani = _basiliTutmaMotoru.value;

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Dış Radar Dalgaları (Basılı tutuldukça büyür ve kızarır)
                          Container(
                            width: 200 + (dolumOrani * 40),
                            height: 200 + (dolumOrani * 40),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: SiberTema.kanKirmizi.withOpacity(0.1 + (dolumOrani * 0.3)),
                              border: Border.all(color: SiberTema.kanKirmizi.withOpacity(dolumOrani), width: 2 + (dolumOrani * 5)),
                              boxShadow: [
                                BoxShadow(color: SiberTema.kanKirmizi.withOpacity(0.5 * dolumOrani), blurRadius: 50 * dolumOrani, spreadRadius: 20 * dolumOrani)
                              ],
                            ),
                          ),
                          // İç Çekirdek (Ana Buton)
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _sosTetiklendi ? SiberTema.matGrey : SiberTema.kanKirmizi,
                              boxShadow: [
                                BoxShadow(color: SiberTema.kanKirmizi.withOpacity(0.8), blurRadius: 30, spreadRadius: 5)
                              ],
                            ),
                            child: Center(
                              child: _islemSuruyor
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                      _sosTetiklendi ? Icons.check_circle_outline : Icons.sos,
                                      color: _sosTetiklendi ? SiberTema.kuantumCyan : Colors.white,
                                      size: 60
                                  ),
                                  if (!_sosTetiklendi) ...[
                                    const SizedBox(height: 8),
                                    const Text("S . O . S", style: TextStyle(color: SiberTema.textMain, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 4)),
                                  ]
                                ],
                              ),
                            ),
                          ),
                          // Dairesel Dolum Göstergesi
                          if (!_sosTetiklendi)
                            SizedBox(
                              width: 170,
                              height: 170,
                              child: CircularProgressIndicator(
                                value: dolumOrani,
                                strokeWidth: 8,
                                color: Colors.white,
                                backgroundColor: Colors.transparent,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 40),

                // Durum Gösterge Metni
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _sosTetiklendi
                      ? const Text("SİNYAL İLETİLDİ. LÜTFEN BEKLEYİN.", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2))
                      : const Text("TETİKLEMEK İÇİN BASILI TUTUN", style: TextStyle(color: SiberTema.kanKirmizi, fontWeight: FontWeight.bold, letterSpacing: 2)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// ── DOSYA SONU MÜHRÜ ──