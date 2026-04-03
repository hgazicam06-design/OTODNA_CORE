import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Titreşim (Haptic) için
import 'package:url_launcher/url_launcher.dart';

class SiberSosMerkeziScreen extends StatefulWidget {
  const SiberSosMerkeziScreen({super.key});

  @override
  State<SiberSosMerkeziScreen> createState() => _SiberSosMerkeziScreenState();
}

class _SiberSosMerkeziScreenState extends State<SiberSosMerkeziScreen> with SingleTickerProviderStateMixin {
  // SİMÜLASYON VERİLERİ
  final String _anlikKonum = "İvedik OSB (Enlem: 39.9, Boylam: 32.8)";
  final List<String> _engellenenlerListesi = ["Gazi Oto (Sinyal İhlali)", "Sahte Hesap_01", "Ahmet Usta (Kara Liste)"];

  // 💎 5 SANİYELİK BASILI TUTMA MOTORU
  late AnimationController _basiliTutmaController;
  bool _sosGonderildi = false;

  @override
  void initState() {
    super.initState();
    // Tam 5 saniyelik animasyon motoru
    _basiliTutmaController = AnimationController(vsync: this, duration: const Duration(seconds: 5));

    _basiliTutmaController.addListener(() {
      setState(() {}); // Ekrandaki çemberin dolmasını anlık çizdirir
      if (_basiliTutmaController.isCompleted && !_sosGonderildi) {
        _sosSinyaliniKuyrugaAl();
      }
    });
  }

  @override
  void dispose() {
    _basiliTutmaController.dispose();
    super.dispose();
  }

  // BUTONA BASILMAYA BAŞLANDIĞINDA
  void _baslamayiTetikle() {
    if (_sosGonderildi) return;
    HapticFeedback.lightImpact(); // Hafif titreşim
    _basiliTutmaController.forward();
  }

  // BUTONDAN PARMAK ERKEN ÇEKİLİRSE
  void _iptalEt() {
    if (_sosGonderildi) return;
    _basiliTutmaController.reverse(); // Çemberi geri sararak iptal et
  }

  // 💎 İNTERNETSİZ ÇALIŞAN (OFFLINE) S.O.S MOTORU
  void _sosSinyaliniKuyrugaAl() {
    setState(() => _sosGonderildi = true);
    HapticFeedback.heavyImpact(); // Cihazı güçlü titret

    // İnternet kontrolü simülasyonu ve Offline Kuyruk Mührü
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.redAccent.withOpacity(0.5), width: 2)),
        contentPadding: const EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.satellite_alt_outlined, color: Colors.redAccent, size: 48),
            const SizedBox(height: 24),
            const Text("SİNYAL CİHAZA MÜHÜRLENDİ", textAlign: TextAlign.center, style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
            const SizedBox(height: 16),
            const Text("S.O.S talebiniz çevrimdışı kuyruğa alındı.\n\nİnternet bağlantısı sağlandığı ilk milisaniyede konumunuz Kuantum Merkezine otomatik fırlatılacaktır.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  Navigator.pop(context);
                  // Butonu sıfırla ki tekrar basabilsin
                  setState(() { _sosGonderildi = false; _basiliTutmaController.reset(); });
                },
                child: const Text("ANLAŞILDI", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- GERÇEK DONANIM: TELEFON ARAMASI ---
  Future<void> _telefonuAra(String numara) async {
    final Uri url = Uri(scheme: 'tel', path: numara);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Arama başlatılamadı! İzinleri kontrol edin.", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: Colors.redAccent));
    }
  }

  // --- GERÇEK DONANIM: SMS GÖNDERME ---
  Future<void> _smsGonder(String numara, String mesaj) async {
    final Uri url = Uri(scheme: 'sms', path: numara, queryParameters: {'body': mesaj});
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("SMS başlatılamadı!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: Colors.redAccent));
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
    const bgColor = Color(0xFF000000);
    const surfaceColor = Color(0xFF111111);
    const primaryCyan = Color(0xFF00FFC2);
    const dangerColor = Colors.redAccent;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text("G Ü V E N L İ K   D U V A R I", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 3)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =================================================================
            // 1. ACİL DURUM (S.O.S) PANELİ (5 SANİYE BASILI TUTMALI)
            // =================================================================
            Container(
              width: double.infinity, padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: dangerColor.withOpacity(0.5), width: 2),
                  boxShadow: [BoxShadow(color: dangerColor.withOpacity(0.15), blurRadius: 40, spreadRadius: 10)]
              ),
              child: Column(
                children: [
                  const Text("S.O.S ACİL SİNYAL", style: TextStyle(color: dangerColor, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 8),
                  const Text("Yardım çağırmak için 5 saniye basılı tutun.", style: TextStyle(color: Colors.white54, fontSize: 11)),
                  const SizedBox(height: 32),

                  // 💎 5 SANİYELİK İNTERAKTİF S.O.S BUTONU
                  GestureDetector(
                    onTapDown: (_) => _baslamayiTetikle(),
                    onTapUp: (_) => _iptalEt(),
                    onTapCancel: () => _iptalEt(),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Dış Çember Animasyonu
                        SizedBox(
                          width: 140, height: 140,
                          child: CircularProgressIndicator(
                            value: _basiliTutmaController.value,
                            strokeWidth: 8,
                            backgroundColor: dangerColor.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(dangerColor),
                          ),
                        ),
                        // İç Buton
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: _basiliTutmaController.isAnimating ? 110 : 120,
                          height: _basiliTutmaController.isAnimating ? 110 : 120,
                          decoration: BoxDecoration(
                              color: dangerColor.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: dangerColor, width: 2),
                              boxShadow: [BoxShadow(color: dangerColor.withOpacity(0.5), blurRadius: _basiliTutmaController.isAnimating ? 30 : 10)]
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.power_settings_new, color: dangerColor, size: _basiliTutmaController.isAnimating ? 32 : 40),
                              if (_basiliTutmaController.isAnimating)
                                Text("${(5 - (_basiliTutmaController.value * 5)).ceil()}", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Gerçekçi GPS HUD
                  Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(color: const Color(0xFF000000), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
                      child: Row(
                          children: [
                            const Icon(Icons.satellite_alt_outlined, color: Colors.white38, size: 18),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("SON TESPİT EDİLEN KONUM", style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                    const SizedBox(height: 4),
                                    Text(_anlikKonum, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                )
                            )
                          ]
                      )
                  ),
                  const SizedBox(height: 24),

                  // ARAMA VE SMS BUTONLARI (Flat & Premium)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: dangerColor, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                          onPressed: () => _telefonuAra("112"),
                          icon: const Icon(Icons.call_outlined, size: 18),
                          label: const Text("112 ARA", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF000000), foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: dangerColor.withOpacity(0.5)))),
                          onPressed: () => _smsGonder("Yakınlarımın Numarası", "ACİL! Kaza yaptım. Konumum: $_anlikKonum"),
                          icon: const Icon(Icons.message_outlined, color: dangerColor, size: 18),
                          label: const Text("SMS AT", style: TextStyle(color: dangerColor, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 48),

            // =================================================================
            // 2. QR ŞİKAYET BİLDİRİMİ
            // =================================================================
            const Text("BAYİ / İŞLETME ŞİKAYETİ", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Kötü niyetli olduğunu düşündüğünüz bayinin veya ustanın QR kodunu okutarak doğrudan Kuantum Merkezine şikayet dosyası açabilirsiniz.", style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity, height: 56,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(side: BorderSide(color: primaryCyan.withOpacity(0.5)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kamera Açılıyor... Bayi QR'ını Okutun! 📸", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: primaryCyan)),
                      icon: const Icon(Icons.qr_code_scanner_outlined, color: primaryCyan, size: 20),
                      label: const Text("ŞİKAYET İÇİN QR OKUT", style: TextStyle(color: primaryCyan, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // =================================================================
            // 3. KARA LİSTE (ENGELLEME) YÖNETİMİ
            // =================================================================
            const Text("GÜVENLİK & KARA LİSTE", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Siber ağınıza erişmesini engellediğiniz hesaplar:", style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  ..._engellenenlerListesi.map((isim) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: const Color(0xFF000000), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [const Icon(Icons.block_outlined, color: dangerColor, size: 16), const SizedBox(width: 12), Text(isim, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5))]),
                        GestureDetector(
                            onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$isim engeli kaldırıldı.", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: Colors.greenAccent)),
                            child: const Text("KALDIR", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1))
                        )
                      ],
                    ),
                  )),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.white12)),

                  Row(
                    children: [
                      Expanded(
                          child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFF000000), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
                              child: const TextField(
                                  style: TextStyle(color: Colors.white, fontSize: 13),
                                  decoration: InputDecoration(hintText: "ID Girin...", hintStyle: TextStyle(color: Colors.white24, fontSize: 12), border: InputBorder.none)
                              )
                          )
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: dangerColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          onPressed: () {},
                          child: const Text("ENGELLE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1))
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}