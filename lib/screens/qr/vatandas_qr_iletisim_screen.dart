import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🔥 SİBER KÖPRÜLER
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

class VatandasQrIletisimScreen extends StatefulWidget {
  final String hedefPlaka;
  final String hedefSahipId;

  const VatandasQrIletisimScreen({
    super.key,
    required this.hedefPlaka,
    required this.hedefSahipId,
  });

  @override
  State<VatandasQrIletisimScreen> createState() => _VatandasQrIletisimScreenState();
}

class _VatandasQrIletisimScreenState extends State<VatandasQrIletisimScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _seciliHizliMesaj = "";
  final TextEditingController _ozelMesajController = TextEditingController();

  bool _isProcessing = false;
  bool _isBlocked = false;
  int _spamSayaci = 0;

  final List<Map<String, dynamic>> _hizliMesajlar = [
    {"baslik": "YANLIŞ PARK", "icon": Icons.local_parking, "renk": Colors.orangeAccent},
    {"baslik": "FARLAR AÇIK", "icon": Icons.lightbulb, "renk": Colors.yellowAccent},
    {"baslik": "CAM AÇIK", "icon": Icons.air, "renk": Colors.lightBlueAccent},
    {"baslik": "KAZA / HASAR", "icon": Icons.car_crash, "renk": SiberTema.kanKirmizi},
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
    if (_isBlocked) {
      _siberUyari("SİBER ENGEL: Sisteme erişiminiz kilitlendi!", isError: true);
      return;
    }

    String gonderilecekMesaj = _seciliHizliMesaj.isNotEmpty
        ? _seciliHizliMesaj
        : _ozelMesajController.text.trim();

    if (gonderilecekMesaj.isEmpty) {
      _siberUyari("SİBER İHLAL: Lütfen bir acil durum mesajı seçin veya yazın!", isError: true);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isProcessing = true);

    try {
      // 1. Hedef aracın sahibinin bildirim kutusuna mühürle
      await _db.collection('kullanicilar').doc(widget.hedefSahipId).collection('bildirimler').add({
        'baslik': '🚨 ANONİM İSTİHBARAT SİNYALİ',
        'mesaj': 'Araç (${widget.hedefPlaka}): $gonderilecekMesaj',
        'tip': 'SOS_ANONIM',
        'okundu': false,
        'tarih': FieldValue.serverTimestamp(),
      });

      // 2. Anti-Spam Kalkanı (2 mesajdan sonra kilitler)
      _spamSayaci++;
      if (_spamSayaci >= 2) {
        setState(() => _isBlocked = true);
      }

      if (!mounted) return;
      _siberUyari("SİNYAL ARAÇ SAHİBİNE İLETİLDİ! 🦅", isError: false);

      // 3 Saniye sonra ana ekrana dön
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && !_isBlocked) Navigator.pop(context);
      });

    } catch (e) {
      _siberUyari("AĞ ÇÖKTÜ: Sinyal iletilemedi!", isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _siberUyari(String mesaj, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: TextStyle(color: isError ? Colors.white : SiberTema.oledBlack, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
      backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent, elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20), onPressed: () => Navigator.pop(context)),
          title: const Text("ANONİM SİNYAL TERMİNALİ", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2, fontFamily: 'Avenir')),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEDEF ARAÇ BİLGİSİ
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    color: SiberTema.matGrey,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5), width: 1.5),
                    boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.1), blurRadius: 20)]
                ),
                child: Row(
                  children: [
                    Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.directions_car, color: SiberTema.kuantumCyan, size: 28)
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("HEDEF ARAÇ PLAKASI", style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
                          const SizedBox(height: 6),
                          Text(widget.hedefPlaka.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
                        ],
                      ),
                    ),
                    const Icon(Icons.verified_user, color: SiberTema.kuantumCyan),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              if (_isBlocked)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(color: SiberTema.kanKirmizi.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: SiberTema.kanKirmizi, width: 2)),
                  child: const Column(
                    children: [
                      Icon(Icons.block, color: SiberTema.kanKirmizi, size: 64),
                      SizedBox(height: 16),
                      Text("SİBER ENGEL DEVREDE", style: TextStyle(color: SiberTema.kanKirmizi, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
                      SizedBox(height: 8),
                      Text("Sistemi suistimal ettiğiniz tespit edildi. Bu araca daha fazla sinyal gönderemezsiniz.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                    ],
                  ),
                )
              else ...[
                // 2. HIZLI MESAJ ŞABLONLARI
                const Text("HIZLI DURUM BİLDİRİMİ", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
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
                          color: seciliMi ? mesaj["renk"].withOpacity(0.15) : SiberTema.matGrey,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: seciliMi ? mesaj["renk"] : Colors.white12, width: seciliMi ? 2 : 1),
                        ),
                        child: Row(
                          children: [
                            Icon(mesaj["icon"], color: seciliMi ? mesaj["renk"] : Colors.white38, size: 20),
                            const SizedBox(width: 12),
                            Expanded(child: Text(mesaj["baslik"], style: TextStyle(color: seciliMi ? mesaj["renk"] : Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir'))),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),

                // 3. ÖZEL MESAJ ALANI
                const Text("VEYA ÖZEL İSTİHBARAT YAZIN", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
                  child: TextField(
                    controller: _ozelMesajController,
                    maxLines: 4,
                    maxLength: 150,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, height: 1.5, letterSpacing: 1, fontFamily: 'Avenir'),
                    onChanged: (val) {
                      if (val.isNotEmpty && _seciliHizliMesaj.isNotEmpty) {
                        setState(() => _seciliHizliMesaj = "");
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Örn: Aracınız garaj girişimi kapatmış, lütfen çeker misiniz?",
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir'),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(20),
                      counterStyle: const TextStyle(color: Colors.white38, fontWeight: FontWeight.bold),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: SiberTema.kuantumCyan, width: 1.5)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 4. GÖNDER BUTONU
                SizedBox(
                  width: double.infinity, height: 64,
                  child: ElevatedButton.icon(
                    style: SiberTema.kuantumButonStili(),
                    onPressed: _isProcessing ? null : _bildirimGonder,
                    icon: _isProcessing
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: SiberTema.oledBlack, strokeWidth: 2))
                        : const Icon(Icons.send_to_mobile, size: 24, color: SiberTema.oledBlack),
                    label: Text(
                        _isProcessing ? "SİNYAL FIRLATILIYOR..." : "ANONİM SİNYAL GÖNDER",
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5, color: SiberTema.oledBlack, fontFamily: 'Avenir')
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}