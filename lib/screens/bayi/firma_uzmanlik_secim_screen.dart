import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirmaUzmanlikSecimScreen extends StatefulWidget {
  final String firmaId; // Kayıt olan firmanın Firebase ID'si

  const FirmaUzmanlikSecimScreen({super.key, required this.firmaId});

  @override
  State<FirmaUzmanlikSecimScreen> createState() => _FirmaUzmanlikSecimScreenState();
}

class _FirmaUzmanlikSecimScreenState extends State<FirmaUzmanlikSecimScreen> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  static const Color bgColor = Color(0xFF000000);
  static const Color surfaceColor = Color(0xFF111111);
  static const Color primaryCyan = Color(0xFF00FFC2);
  static const Color dangerColor = Colors.redAccent;

  bool _isProcessing = false;

  // 🚀 STANDART UZMANLIK HAVUZU (Sen Karargahtan İstediğin Kadar Ekle)
  final List<String> _uzmanlikHavuzu = [
    "PERİYODİK BAKIM", "DSG ŞANZIMAN TAMİRİ", "AĞIR HASAR ONARIMI", "KURU ÇEKİÇ GÖÇÜK DÜZELTME",
    "PPF KORUMA KAPLAMA", "SERAMİK KAPLAMA", "MOTOR REKTİFİYE", "BEYİN (ECU) YAZILIMI",
    "DPF & EGR İPTALİ/TEMİZLİĞİ", "KRONİK SU KAÇAĞI TESPİTİ", "HİBRİT BATARYA TESTİ",
    "EV (ELEKTRİKLİ) MOTOR BAKIMI", "TRİGER DEĞİŞİMİ", "ÖN TAKIM & ROT BALANS",
    "TURBO REVİZYONU", "OTOMATİK VİTES BEYNİ", "SUNROOF TAMİRİ", "FAR PARLATMA & MERCEK"
  ];

  // Firmanın Seçtiği Uzmanlıklar
  final List<String> _secilenUzmanliklar = [];

  // Özel Uzmanlık Girişi İçin
  final TextEditingController _ozelUzmanlikCtrl = TextEditingController();

  // 🚀 ÖZEL UZMANLIK EKLEME MOTORU (Firebase Havuzuna Düşer)
  void _ozelUzmanlikEkle(String yeniUzmanlik) {
    if (yeniUzmanlik.trim().isEmpty) return;

    String formatliUzmanlik = yeniUzmanlik.trim().toUpperCase();

    if (!_secilenUzmanliklar.contains(formatliUzmanlik)) {
      setState(() {
        _secilenUzmanliklar.add(formatliUzmanlik);
      });

      // Firebase'e "Yeni Buton Önerisi" Olarak Atıyoruz (Siber İstihbarat)
      FirebaseFirestore.instance.collection('bekleyen_yeni_uzmanliklar').add({
        'uzmanlik_adi': formatliUzmanlik,
        'oneren_firma_id': widget.firmaId,
        'tarih': FieldValue.serverTimestamp(),
        'durum': 'Onay Bekliyor' // Sen Karargahtan onaylayıp genel listeye alacaksın
      });
    }

    _ozelUzmanlikCtrl.clear();
    Navigator.pop(context); // Bottom Sheet'i kapat

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("YENİ UZMANLIK SİBER AĞA İLETİLDİ!", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: primaryCyan));
  }

  // 🚀 FİRMAMIZIN PROFİLİNİ MÜHÜRLEME MOTORU
  Future<void> _kaydiTamamla() async {
    if (_secilenUzmanliklar.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("SİBER İHLAL: En az bir uzmanlık seçmelisiniz!", style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: dangerColor));
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Firmanın profilini güncelliyoruz
      await FirebaseFirestore.instance.collection('bayi_basvurulari').doc(widget.firmaId).update({
        'uzmanlik_alanlari': _secilenUzmanliklar,
        'profil_tamamlandi_mi': true,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("UZMANLIKLAR MÜHÜRLENDİ. SİSTEME GİRİŞ YAPILIYOR... 🦅", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: primaryCyan));

      // TODO: Başarılı olunca Ana Dashboard'a (Siber Komuta Merkezi) yönlendir.
      // Navigator.pushReplacementNamed(context, '/dashboard');

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("AĞ HATASI: $e", style: const TextStyle(fontWeight: FontWeight.bold)), backgroundColor: dangerColor));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
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
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('S İ B E R   U Z M A N L I K   A Ğ I', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 3)),
      ),
      body: Column(
        children: [
          // 1. BAŞLIK VE AÇIKLAMA
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              children: [
                const Text("HANGİ KONULARDA USTASINIZ?", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                const SizedBox(height: 12),
                Text("OtoDNA kullanıcıları ince detayları arar. Firmanızın sunduğu tüm spesifik hizmetleri seçin veya listede yoksa kendiniz ekleyin.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, height: 1.5, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // 2. DİNAMİK KUANTUM ÇİPLERİ (Pinterest Style Wrap)
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Wrap(
                spacing: 12,
                runSpacing: 16,
                children: [
                  ..._uzmanlikHavuzu.map((uzmanlik) => _buildKuantumCipi(uzmanlik)),
                  ..._secilenUzmanliklar.where((u) => !_uzmanlikHavuzu.contains(u)).map((u) => _buildKuantumCipi(u, ozelMi: true)),

                  // ÖZEL UZMANLIK EKLEME BUTONU (Siyah Zeminli Neon Çerçeve)
                  _buildOzelEkleButonu(),
                ],
              ),
            ),
          ),

          // 3. ATEŞLEME (MÜHÜRLE) BUTONU
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: surfaceColor,
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: SafeArea(
              child: SizedBox(
                height: 64,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _kaydiTamamla,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryCyan,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: _isProcessing
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                      : const Icon(Icons.fingerprint, size: 24),
                  label: Text(
                    _isProcessing ? "AĞA YÜKLENİYOR..." : "PROFİLİ SİSTEME MÜHÜRLE",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: KUANTUM ÇİPİ (Filtre Butonu)
  Widget _buildKuantumCipi(String uzmanlik, {bool ozelMi = false}) {
    bool isSelected = _secilenUzmanliklar.contains(uzmanlik);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _secilenUzmanliklar.remove(uzmanlik);
          } else {
            _secilenUzmanliklar.add(uzmanlik);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? primaryCyan : (ozelMi ? Colors.orangeAccent.withOpacity(0.1) : surfaceColor),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? primaryCyan : (ozelMi ? Colors.orangeAccent.withOpacity(0.5) : Colors.white.withOpacity(0.1)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [BoxShadow(color: primaryCyan.withOpacity(0.3), blurRadius: 15)] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) const Icon(Icons.check_circle, color: Colors.black, size: 16),
            if (ozelMi && !isSelected) const Icon(Icons.star, color: Colors.orangeAccent, size: 16),
            if (isSelected || ozelMi) const SizedBox(width: 8),
            Text(
              uzmanlik,
              style: TextStyle(
                color: isSelected ? Colors.black : (ozelMi ? Colors.orangeAccent : Colors.white70),
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: ÖZEL EKLENTİ BUTONU VE BOTTOM SHEET
  Widget _buildOzelEkleButonu() {
    return GestureDetector(
      onTap: () {
        // Kullanıcı listede bulamazsa kendi eklemesi için Siber Panel Açılır
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(color: primaryCyan.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text("SİSTEMDE OLMAYAN UZMANLIĞI GİRİN", style: TextStyle(color: primaryCyan, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _ozelUzmanlikCtrl,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: "Örn: PORSCHE MOTOR REKTİFİYE",
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12),
                      filled: true,
                      fillColor: bgColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primaryCyan)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _ozelUzmanlikEkle(_ozelUzmanlikCtrl.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryCyan,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text("HAFIZAYA AL VE SEÇ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  )
                ],
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white38, width: 1, style: BorderStyle.solid),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text("LİSTEDE YOK: KENDİM EKLEYECEĞİM", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }
}