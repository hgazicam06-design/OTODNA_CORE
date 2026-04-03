// lib/screens/hizli_bayi_onboarding.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

// SİBER NOT: Gerçek projede yönlendirme için eklenecek
// import 'bayi_kayit.dart';

/// 🛡️ KUANTUM HIZLI BAYİ KARŞILAMA (SiberHizliBayiOnboarding)
/// WhatsApp veya referans linkiyle gelen sektörel bayileri özel Kuantum mesajlarıyla karşılar.
class SiberHizliBayiOnboarding extends StatelessWidget {
  final String sektorKodu; // Deep Link (WhatsApp) üzerinden gelen kod

  const SiberHizliBayiOnboarding({super.key, required this.sektorKodu});

  // ── 🎨 KARARGAH TASARIM DOKTRİNİ ──
  static const Color _oledBlack = Color(0xFF000000);
  static const Color _matGrey = Color(0xFF111111);
  static const Color _kuantumCyan = Color(0xFF00FFC2);

  // ── 🧠 YAPAY ZEKA SEKTÖREL MESAJ MOTORU ──
  Map<String, String> _sektorelVeriGetir(String sektor) {
    switch (sektor) {
      case "Beyinci":
        return {
          "baslik": "SİBER BEYİN USTASI",
          "mesaj": "OtoDNA Kuantum Ağı ile yazılımlarını ve beyin onarımlarını tüm Türkiye'ye mühürle. Sektörün beyni artık senin ekranında!",
          "ikon": "memory"
        };
      case "Kurtarici":
        return {
          "baslik": "YOL YARDIM KAHRAMANI",
          "mesaj": "S.O.S sinyalleri doğrudan senin radarına düşsün! Kırmızı alarmlara ilk sen müdahale et ve Karargahın en hızlısı ol.",
          "ikon": "car_crash"
        };
      case "Surucu_Kursu":
        return {
          "baslik": "GELECEĞİN EĞİTMENİ",
          "mesaj": "Geleceğin şoförlerini OtoDNA güvencesiyle yetiştir. Yeni sürücüleri Kuantum Ağına katarak DNA puanını katla.",
          "ikon": "school"
        };
      default:
        return {
          "baslik": "KARARGAHA HOŞ GELDİN",
          "mesaj": "OtoDNA Dijital Referans Protokolü'ne adım atıyorsun. Otomotivin hantal sistemini bitirmek için doğru yerdesin.",
          "ikon": "shield"
        };
    }
  }

  IconData _getSiberIkon(String ikonKodu) {
    switch (ikonKodu) {
      case "memory": return Icons.memory_outlined;
      case "car_crash": return Icons.car_crash_outlined;
      case "school": return Icons.school_outlined;
      default: return Icons.security_outlined;
    }
  }

  void _kayitTerminalineGec(BuildContext context) {
    HapticFeedback.heavyImpact();
    developer.log("🚀 SİBER GEÇİŞ: $sektorKodu için kayıt protokolü başlatıldı.");

    // SİBER NOT: Gerçek yönlendirme kodu
    // Navigator.push(context, MaterialPageRoute(builder: (_) => BayiKayitFormu(ustaId: 'YENI_KAYIT', sektor: sektorKodu)));
  }

  @override
  Widget build(BuildContext context) {
    final veri = _sektorelVeriGetir(sektorKodu);

    return Scaffold(
      backgroundColor: _oledBlack,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🛡️ SİBER LOGO / İKON
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _kuantumCyan.withOpacity(0.1),
                    border: Border.all(color: _kuantumCyan, width: 2),
                    boxShadow: [
                      BoxShadow(color: _kuantumCyan.withOpacity(0.2), blurRadius: 40, spreadRadius: 10)
                    ]
                ),
                child: Icon(_getSiberIkon(veri["ikon"]!), color: _kuantumCyan, size: 80),
              ),
              const SizedBox(height: 40),

              // 🚀 SEKTÖREL BAŞLIK
              Text(
                veri["baslik"]!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),

              // 📜 HEDEF ODAKLI MESAJ
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _matGrey,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  veri["mesaj"]!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.6,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const Spacer(),

              // 🔐 ATEŞLEME (KAYIT) BUTONU
              SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton.icon(
                  onPressed: () => _kayitTerminalineGec(context),
                  icon: const Icon(Icons.fingerprint, color: Colors.black, size: 28),
                  label: const Text(
                    "KARARGAHA KATIL",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kuantumCyan,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 10,
                    shadowColor: _kuantumCyan.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}