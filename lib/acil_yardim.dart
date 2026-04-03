import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM S.O.S VE ACİL MÜDAHALE MOTORU (SiberSosButonu)
/// 5 saniye basılı tutulduğunda asılsız ihbar kalkanını aşar ve sinyali doğrudan Karargah ağına fırlatır.
class SiberSosButonu extends StatefulWidget {
  final String kullaniciId;
  final String saseNo;
  final String qrOlusturanBayiId;

  const SiberSosButonu({
    super.key,
    required this.kullaniciId,
    required this.saseNo,
    required this.qrOlusturanBayiId,
  });

  @override
  State<SiberSosButonu> createState() => _SiberSosButonuState();
}

class _SiberSosButonuState extends State<SiberSosButonu> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  double _progress = 0.0;
  Timer? _timer;
  bool _isSent = false;
  bool _isPressing = false;

  void _startHold() {
    if (_isSent) return;

    setState(() => _isPressing = true);
    HapticFeedback.heavyImpact(); // İlk dokunuşta askeri titreşim

    developer.log("🚨 S.O.S PROTOKOLÜ: Füze ateşlemesi başlatıldı. 5 saniye bekleniyor...");

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        if (_progress < 1.0) {
          _progress += 0.02; // 50 adım * 100ms = 5000ms (5 Saniye)
          if ((_progress * 100).toInt() % 20 == 0) {
            HapticFeedback.selectionClick(); // Doldukça kalp atışı gibi titrer
          }
        } else {
          _timer?.cancel();
          _sendEmergencySignal();
        }
      });
    });
  }

  void _stopHold() {
    _timer?.cancel();
    if (!_isSent) {
      setState(() {
        _progress = 0.0;
        _isPressing = false;
      });
      developer.log("⚠️ S.O.S İPTAL: Kullanıcı ateşlemeyi durdurdu.");
    }
  }

  Future<void> _sendEmergencySignal() async {
    setState(() {
      _isSent = true;
      _isPressing = false;
    });

    HapticFeedback.vibrate(); // Uzun siber titreşim
    developer.log("🚀 SİNYAL FIRLATILDI: Kuantum ağına S.O.S mühürleniyor!");

    try {
      // ⚖️ KARARGAH S.O.S PROTOKOLÜ:
      // 1. QR'ı veren bayiye, 2. En yakın bayiye, 3. Admine eşzamanlı gider.
      // 30 dk içinde müdahale edilmezse admin arar. Asılsızsa ceza (Sarı üye) uygulanır.
      await _db.collection('sos_sinyalleri').add({
        'kullanici_id': widget.kullaniciId,
        'sase_no': widget.saseNo,
        'hedef_bayi_1': widget.qrOlusturanBayiId,
        'hedef_bayi_2': 'SISTEM_EN_YAKIN_BAYIYI_ATAYACAK', // Otonom GPS motoru doldurur
        'durum': 'YENI_SINYAL',
        'zaman_damgasi': FieldValue.serverTimestamp(),
        // Adminin 30 dk kuralı için zamanlayıcı mühür
        'admin_mudahale_son_tarih': DateTime.now().add(const Duration(minutes: 30)).toIso8601String(),
        'asisiz_ihbar_mi': false,
      });

      developer.log("✅ S.O.S BAŞARILI: Karargah, ilk bayi ve en yakın bayi uyarıldı!");
    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: S.O.S Sinyali iletilemedi!", error: e);
      // Sinyal gitmezse butonu sıfırla ki tekrar basabilsin
      setState(() {
        _isSent = false;
        _progress = 0.0;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _startHold(),
      onLongPressEnd: (_) => _stopHold(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── 🔴 SİBER RADAR VE BUTON GÖVDESİ ──
          Stack(
            alignment: Alignment.center,
            children: [
              // Arka plan neon parlaması
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _isPressing ? 180 : 150,
                height: _isPressing ? 180 : 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(_isPressing ? 0.6 : 0.0),
                      blurRadius: _isPressing ? 50 : 0,
                      spreadRadius: _isPressing ? 10 : 0,
                    ),
                  ],
                ),
              ),
              // İlerleme Çemberi
              SizedBox(
                width: 160,
                height: 160,
                child: CircularProgressIndicator(
                  value: _progress,
                  strokeWidth: 8,
                  color: const Color(0xFF00FFC2), // Kuantum Turkuazı dolum efekti
                  backgroundColor: Colors.white10,
                ),
              ),
              // Acil Durum Çekirdeği
              AnimatedScale(
                scale: _isPressing ? 0.9 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: _isSent ? Colors.green.shade800 : Colors.redAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 2),
                  ),
                  child: Icon(
                      _isSent ? Icons.gpp_good_rounded : Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 60
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // ── 📝 ASKERİ BİLGİLENDİRME METİNLERİ ──
          Text(
              _isSent ? "SİNYAL KARARGAHA İLETİLDİ!" : "YARDIM İÇİN 5 SN BASILI TUTUN",
              style: TextStyle(
                color: _isSent ? const Color(0xFF00FFC2) : Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                fontSize: 16,
              )
          ),
          const SizedBox(height: 8),

          // Etik Uyarı Metni (Asılsız İhbar Sistemi)
          if (!_isSent)
            const Text(
              "DİKKAT: Asılsız ihbarlar ceza puanı (Sarı Üyelik)\nve sistemden men edilme ile sonuçlanır.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.5, letterSpacing: 1),
            ),
        ],
      ),
    );
  }
}