import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VatandasQrIletisimScreen extends StatefulWidget {
  final String hedefPlaka; // QR'dan gelen şifreli plaka
  final String hedefSahipId; // Firebase'deki asıl sahibin UID'si

  const VatandasQrIletisimScreen({
    super.key,
    this.hedefPlaka = "34 DNA 2026", // Test Verisi
    this.hedefSahipId = "TEST_UID_001", // Test Verisi
  });

  @override
  State<VatandasQrIletisimScreen> createState() => _VatandasQrIletisimScreenState();
}

class _VatandasQrIletisimScreenState extends State<VatandasQrIletisimScreen> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  static const Color bgColor = Color(0xFF000000);
  static const Color surfaceColor = Color(0xFF111111);
  static const Color primaryCyan = Color(0xFF00FFC2);
  static const Color dangerColor = Colors.redAccent;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _seciliHizliMesaj = "";
  final TextEditingController _ozelMesajController = TextEditingController();
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _hizliMesajlar = [
    {"baslik": "YANLIŞ PARK", "icon": Icons.local_parking, "renk": Colors.orangeAccent},
    {"baslik": "FARLAR AÇIK", "icon": Icons.lightbulb, "renk": Colors.yellowAccent},
    {"baslik": "CAM AÇIK", "icon": Icons.air, "renk": Colors.lightBlueAccent},
    {"baslik": "KAZA / HASAR", "icon": Icons.car_crash, "renk": Colors.redAccent},
    {"baslik": "ALARM ÇALIYOR", "icon": Icons.notifications_active, "renk": Colors.purpleAccent},
    {"baslik": "EVCİL HAYVAN", "icon": Icons.pets, "renk": Colors.greenAccent},
  ];

  @override
  void dispose() {
    _ozelMesajController.dispose();
    super.dispose();
  }

  // 🚀 FİREBASE: SİBER SİNYALİ FIRLATMA MOTORU
  Future<void> _bildirimGonder() async {
    String gonderilecekMesaj = _seciliHizliMesaj.isNotEmpty
        ? _seciliHizliMesaj
        : _ozelMesajController.text.trim();

    if (gonderilecekMesaj.isEmpty) {
      _uyariGoster("SİBER İHLAL: Lütfen bir acil durum mesajı seçin veya yazın!", isError: true);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isProcessing = true);

    try {
      // Doğrudan hedef aracın sahibinin bildirim kutusuna mühürle
      await _db.collection('kullanicilar').doc(widget.hedefSahipId).collection('bildirimler').add({
        'baslik': '🚨 ANONİM İSTİHBARAT SİNYALİ',
        'mesaj': 'Araç (${widget.hedefPlaka}): $gonderilecekMesaj',
        'tip': 'SOS_ANONIM',
        'okundu': false,
        'tarih': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _showSuccessDialog(gonderilecekMesaj);

    } catch (e) {
      _uyariGoster("AĞ ÇÖKTÜ: Sinyal iletilemedi!", isError: true);
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

  // 💎 SİBER BAŞARI DİYALOĞU
  void _showSuccessDialog(String mesaj) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: primaryCyan.withOpacity(0.5), width: 2)),
        title: const Row(
          children: [
            Icon(Icons.mark_email_read, color: primaryCyan, size: 28),
            SizedBox(width: 12),
            Expanded(child: Text("SİNYAL İLETİLDİ", style: TextStyle(color: primaryCyan, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Araç sahibinin Karargah terminaline acil durum bildirimi olarak fırlatıldı.", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, height: 1.5)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
              child: Text("İLETİLEN İSTİHBARAT:\n\"$mesaj\"", style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            const Text("Siber kimliğiniz ve konumunuz KVKK gereği %100 gizlenmiştir.", style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context); // Dialogu kapat
                Navigator.pop(context); // Ana ekrana (QR Okuyucuya) dön
              },
              child: const Text("GÖREV TAMAMLANDI", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, letterSpacing: 1.5))
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: primaryCyan, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text("ANONİM SİNYAL TERMİNALİ", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600), // 🖥️ Web / Tablet Kalkanı
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. HEDEF ARAÇ BİLGİSİ
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: primaryCyan.withOpacity(0.5), width: 1.5),
                        boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.1), blurRadius: 20)]
                    ),
                    child: Row(
                      children: [
                        Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.directions_car, color: primaryCyan, size: 28)
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("HEDEF ARAÇ PLAKASI", style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                              const SizedBox(height: 6),
                              Text(widget.hedefPlaka.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2)),
                            ],
                          ),
                        ),
                        const Icon(Icons.verified_user, color: primaryCyan),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // 2. HIZLI MESAJ ŞABLONLARI
                  const Text("HIZLI DURUM BİLDİRİMİ", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 250, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 3.0),
                    itemCount: _hizliMesajlar.length,
                    itemBuilder: (context, index) {
                      final mesaj = _hizliMesajlar[index];
                      bool seciliMi = _seciliHizliMesaj == mesaj["baslik"];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _seciliHizliMesaj = seciliMi ? "" : mesaj["baslik"];
                            if (_seciliHizliMesaj.isNotEmpty) _ozelMesajController.clear();
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: seciliMi ? mesaj["renk"].withOpacity(0.15) : surfaceColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: seciliMi ? mesaj["renk"] : Colors.white12, width: seciliMi ? 2 : 1),
                          ),
                          child: Row(
                            children: [
                              Icon(mesaj["icon"], color: seciliMi ? mesaj["renk"] : Colors.white38, size: 20),
                              const SizedBox(width: 12),
                              Expanded(child: Text(mesaj["baslik"], style: TextStyle(color: seciliMi ? mesaj["renk"] : Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1))),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),

                  // 3. ÖZEL MESAJ ALANI
                  const Text("VEYA ÖZEL İSTİHBARAT YAZIN", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
                    child: TextField(
                      controller: _ozelMesajController,
                      maxLines: 4,
                      maxLength: 150,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, height: 1.5, letterSpacing: 1),
                      onChanged: (val) {
                        if (val.isNotEmpty && _seciliHizliMesaj.isNotEmpty) {
                          setState(() => _seciliHizliMesaj = "");
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "Örn: Aracınız garaj girişimi kapatmış, lütfen çeker misiniz?",
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(20),
                        counterStyle: const TextStyle(color: Colors.white38, fontWeight: FontWeight.bold),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primaryCyan, width: 1.5)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 4. GÜVENLİK UYARISI
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: dangerColor.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: dangerColor.withOpacity(0.3))),
                    child: const Row(
                      children: [
                        Icon(Icons.gpp_good, color: dangerColor, size: 24),
                        SizedBox(width: 16),
                        Expanded(child: Text("SİBER UYARI: Bu sistemi taciz amacıyla kullanan IP adresleri tespit edilip OtoDNA Kuantum Ağından kalıcı olarak men edilecektir.", style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold, height: 1.5, letterSpacing: 1))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // 5. GÖNDER BUTONU
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryCyan,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          disabledBackgroundColor: primaryCyan.withOpacity(0.3)
                      ),
                      onPressed: _isProcessing ? null : _bildirimGonder,
                      icon: _isProcessing
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                          : const Icon(Icons.send_to_mobile, size: 24),
                      label: Text(
                          _isProcessing ? "SİNYAL FIRLATILIYOR..." : "ANONİM SİNYAL GÖNDER",
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5)
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}