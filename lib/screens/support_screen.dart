import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  static const Color bgColor = Color(0xFF000000);
  static const Color surfaceColor = Color(0xFF111111);
  static const Color primaryCyan = Color(0xFF00FFC2);
  static const Color warningColor = Colors.amberAccent;
  static const Color dangerColor = Colors.redAccent;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _mesajController = TextEditingController();
  bool _isProcessing = false;

  // SİBER KATEGORİLER
  final List<String> _kategoriler = [
    "SİBER AĞ HATASI (TEKNİK)",
    "MÜHÜR VE İTİRAZ TALEBİ",
    "FİNANS VE KOMİSYON (%12)",
    "FİRMA / MÜŞTERİ ŞİKAYETİ",
    "DİĞER"
  ];
  late String _secilenKategori;

  @override
  void initState() {
    super.initState();
    _secilenKategori = _kategoriler[0];
  }

  @override
  void dispose() {
    _mesajController.dispose();
    super.dispose();
  }

  // 🚀 FİREBASE: SİNYALİ ANKARA MERKEZE FIRLAT
  Future<void> _talebiMerkezeIlet() async {
    String mesaj = _mesajController.text.trim();

    if (mesaj.isEmpty || mesaj.length < 10) {
      _uyariGoster("SİBER İHLAL: Mesajınız çok kısa, lütfen detayı belirtin!", isError: true);
      return;
    }

    User? user = _auth.currentUser;
    if (user == null) {
      _uyariGoster("KİMLİK İHLALİ: Oturum açmadan merkeze sinyal gönderemezsiniz!", isError: true);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Doğrudan Karargah veritabanına mühürle
      await _db.collection('destek_talepleri').add({
        'kullanici_id': user.uid,
        'kategori': _secilenKategori,
        'mesaj': mesaj,
        'durum': 'AÇIK', // Admin panelinde kırmızı yanacak
        'tarih': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // Başarılı Kuantum Sinyali
      _showSuccessDialog();

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
        content: Text(mesaj, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
        backgroundColor: isError ? dangerColor : primaryCyan,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // 💎 SİBER BAŞARI DİYALOĞU
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: primaryCyan.withOpacity(0.5))),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: primaryCyan, size: 28),
            SizedBox(width: 12),
            Text("SİNYAL ALINDI", style: TextStyle(color: SiberTema.textMain, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ],
        ),
        content: const Text(
          "Talebiniz Ankara Merkez Karargahına şifreli olarak ulaştı. Kuantum ağımız 24 saat içerisinde müdahale edecektir.",
          style: TextStyle(color: SiberTema.textMuted, fontSize: 12, fontWeight: FontWeight.bold, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Diyaloğu kapat
              Navigator.pop(context); // Ekrandan çık
            },
            child: const Text("ANLAŞILDI", style: TextStyle(color: primaryCyan, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
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
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: primaryCyan, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text("MERKEZ DESTEK HATTI", style: TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700), // 🖥️ Web / Double Teyp Kalkanı
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. ANKARA MERKEZ BİLGİ KUTUSU
                  _buildInfoBox(),
                  const SizedBox(height: 32),

                  // 2. KATEGORİ SEÇİMİ (Kuantum Dropdown)
                  const Text("SİBER SORUN KATEGORİSİ", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: SiberTema.textMuted)),
                    child: DropdownButtonFormField<String>(
                      value: _secilenKategori,
                      dropdownColor: surfaceColor,
                      icon: const Icon(Icons.keyboard_arrow_down, color: primaryCyan),
                      style: const TextStyle(color: SiberTema.textMain, fontSize: 12, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.radar, color: primaryCyan.withOpacity(0.5), size: 20),
                      ),
                      items: _kategoriler.map((String k) {
                        return DropdownMenuItem<String>(value: k, child: Text(k, style: const TextStyle(letterSpacing: 1)));
                      }).toList(),
                      onChanged: (val) => setState(() => _secilenKategori = val!),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 3. MESAJ KUTUSU
                  const Text("DETAYLI İSTİHBARAT RAPORU", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: SiberTema.textMuted)),
                    child: TextField(
                      controller: _mesajController,
                      maxLines: 6,
                      style: const TextStyle(color: SiberTema.textMain, fontSize: 13, height: 1.5),
                      decoration: InputDecoration(
                        hintText: "Karşılaştığınız siber ihlali veya sistem hatasını buraya detaylıca yazın...",
                        hintStyle: TextStyle(color: SiberTema.textMain.withOpacity(0.2), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(20),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primaryCyan, width: 1.5)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // 4. ATEŞLEME BUTONU
                  SizedBox(
                    height: 64,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryCyan,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        disabledBackgroundColor: primaryCyan.withOpacity(0.3),
                      ),
                      onPressed: _isProcessing ? null : _talebiMerkezeIlet,
                      icon: _isProcessing
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.satellite_alt, size: 24),
                      label: Text(
                        _isProcessing ? "SİNYAL İLETİLİYOR..." : "MERKEZE İLET",
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2),
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

  // 💎 YARDIMCI BİLEŞEN: BİLGİ KUTUSU
  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: warningColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: warningColor.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: warningColor.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.support_agent, color: warningColor, size: 32),
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("DİKKAT", style: TextStyle(color: warningColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                SizedBox(height: 6),
                Text(
                  "Tüm talepleriniz Ankara Merkez tarafından incelenir ve 24 saat içinde müdahale edilir.",
                  style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.bold, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}