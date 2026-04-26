import 'package:flutter/material.dart';

class SiberIbanYonetimiScreen extends StatefulWidget {
  const SiberIbanYonetimiScreen({super.key});

  @override
  State<SiberIbanYonetimiScreen> createState() => _SiberIbanYonetimiScreenState();
}

class _SiberIbanYonetimiScreenState extends State<SiberIbanYonetimiScreen> {
  // FİNANS VERİTABANI
  final List<Map<String, dynamic>> _kayitliIbanlar = [
    {
      "banka": "Garanti BBVA Ticari",
      "isim": "Gazi *****",
      "iban": "1234 5678 9000 0012 3456 78", // Baştaki TR kısmını UI'da ekliyoruz
      "renk": Colors.teal.shade700,
      "ikon": Icons.account_balance_outlined,
      "varsayilan": true,
    },
    {
      "banka": "Ziraat Şahıs Hesabı",
      "isim": "Gazi *****",
      "iban": "9876 5432 1000 0098 7654 32",
      "renk": Colors.black54,
      "ikon": Icons.account_balance_outlined,
      "varsayilan": false,
    }
  ];

  final Color primaryTeal = Colors.teal.shade700;
  final Color textColor = const Color(0xFF1E293B);
  final Color bgColor = const Color(0xFFFAFAFC);
  final Color surfaceColor = Colors.white;

  // 💎 PLAZA KALİTESİ: ŞIK BOTTOM SHEET
  void _yeniIbanEklePenceresiAc() {
    final TextEditingController bankaController = TextEditingController();
    final TextEditingController ibanController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 40, offset: const Offset(0, -10))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 32),
              Row(
                children: [
                  Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: primaryTeal.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(Icons.add_card_outlined, color: primaryTeal, size: 28)),
                  const SizedBox(width: 16),
                  Text("YENİ HESAP TANIMLA", style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                ],
              ),
              const SizedBox(height: 32),

              // BANKA ADI
              const Text("Banka / Kurum Adı", style: TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black.withValues(alpha: 0.05))),
                child: TextField(
                  controller: bankaController,
                  style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'Avenir'),
                  decoration: const InputDecoration(
                    hintText: "Örn: İş Bankası Şahıs", hintStyle: TextStyle(color: Colors.black38, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // IBAN NUMARASI
              const Text("IBAN Numarası", style: TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black.withValues(alpha: 0.05))),
                child: TextField(
                  controller: ibanController,
                  keyboardType: TextInputType.number,
                  maxLength: 24,
                  style: TextStyle(color: textColor, letterSpacing: 3, fontWeight: FontWeight.w900, fontSize: 14, fontFamily: 'monospace'),
                  decoration: InputDecoration(
                    prefixText: "TR ", prefixStyle: TextStyle(color: primaryTeal, fontWeight: FontWeight.w900, letterSpacing: 3, fontSize: 14, fontFamily: 'monospace'),
                    hintText: "0000 0000 0000 0000 0000 00", hintStyle: const TextStyle(color: Colors.black26, letterSpacing: 2, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                    counterText: "",
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // KAYDET BUTONU
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal, foregroundColor: Colors.white, elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    if (bankaController.text.isEmpty || ibanController.text.length < 24) {
                      _plazaUyariGoster("KAYIT HATASI", "Banka Adı ve 24 Haneli IBAN eksiksiz olmalıdır.", Colors.redAccent);
                      return;
                    }
                    FocusScope.of(context).unfocus();
                    Navigator.pop(context);
                    _biyometrikOnayAl(bankaController.text, ibanController.text);
                  },
                  icon: const Icon(Icons.fingerprint, size: 24),
                  label: const Text("BİYOMETRİK ONAY İLE KAYDET", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1, fontFamily: 'Avenir')),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // 💎 APPLE PAY TARZI BİYOMETRİK EKRAN
  void _biyometrikOnayAl(String banka, String iban) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
        contentPadding: const EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: primaryTeal, width: 2), boxShadow: [BoxShadow(color: primaryTeal.withValues(alpha: 0.1), blurRadius: 20)]),
              child: Icon(Icons.face_unlock_outlined, color: primaryTeal, size: 48),
            ),
            const SizedBox(height: 32),
            Text("Kimlik Doğrulaması", style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
            const SizedBox(height: 12),
            const Text("FaceID / Parmak İzi onayınız bekleniyor...", textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 12, height: 1.5, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
          ],
        ),
      ),
    );

    // 2 saniye sonra onayı ver ve listeye ekle
    Future.delayed(const Duration(seconds: 2), () {
      if(!mounted) return;
      Navigator.pop(context);
      setState(() {
        _kayitliIbanlar.add({
          "banka": banka,
          "isim": "Gazi *****",
          "iban": iban, 
          "renk": primaryTeal,
          "ikon": Icons.account_balance_outlined,
          "varsayilan": false,
        });
      });
      _plazaUyariGoster("İŞLEM BAŞARILI", "Banka Hesabı Sisteme Kaydedildi!", Colors.green);
    });
  }

  void _varsayilanYap(int index) {
    setState(() {
      for (var iban in _kayitliIbanlar) { iban['varsayilan'] = false; }
      _kayitliIbanlar[index]['varsayilan'] = true;
    });
    _plazaUyariGoster("GÜNCELLENDİ", "Ana Çekim Hesabı Olarak Güncellendi!", primaryTeal);
  }

  void _plazaUyariGoster(String baslik, String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: renk, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
            const SizedBox(height: 4),
            Text(mesaj, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white, 
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: primaryTeal, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text("B A N K A   H E S A P L A R I", style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 3, fontFamily: 'Avenir')),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryTeal,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: _yeniIbanEklePenceresiAc,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Yeni IBAN Ekle", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.5, fontFamily: 'Avenir')),
      ),
      body: _kayitliIbanlar.isEmpty
          ? Center(child: Text("Henüz kayıtlı bir banka hesabınız yok.", style: TextStyle(color: Colors.black45, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Avenir')))
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        physics: const BouncingScrollPhysics(),
        itemCount: _kayitliIbanlar.length,
        itemBuilder: (context, index) {
          var iban = _kayitliIbanlar[index];
          bool isVarsayilan = iban['varsayilan'];
          Color kartRengi = isVarsayilan ? primaryTeal : Colors.black54;

          // 💎 PLAZA KALİTESİ KART TASARIMI
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isVarsayilan ? primaryTeal : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
              boxShadow: isVarsayilan 
                  ? [BoxShadow(color: primaryTeal.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10))] 
                  : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5))],
              gradient: isVarsayilan ? LinearGradient(colors: [primaryTeal, Colors.teal.shade500], begin: Alignment.topLeft, end: Alignment.bottomRight) : null
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ÜST KISIM (Banka Adı, Çip İkonu ve Yıldız)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.memory, color: isVarsayilan ? Colors.white.withValues(alpha: 0.8) : Colors.black45, size: 28), // Çip İkonu!
                        const SizedBox(width: 12),
                        Text(iban['banka'].toUpperCase(), style: TextStyle(color: isVarsayilan ? Colors.white : textColor, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                      ],
                    ),
                    if (isVarsayilan)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                        child: const Text("ANA HESAP", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                      )
                    else
                      GestureDetector(
                        onTap: () => _varsayilanYap(index),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.black12)),
                          child: const Icon(Icons.star_border, color: Colors.black38, size: 18),
                        ),
                      )
                  ],
                ),
                const SizedBox(height: 32),

                // ORTA KISIM (IBAN Numarası Monospace Formatta)
                Row(
                  children: [
                    Text("TR", style: TextStyle(color: isVarsayilan ? Colors.white70 : Colors.black45, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2, fontFamily: 'monospace')),
                    const SizedBox(width: 12),
                    Text(iban['iban'], style: TextStyle(color: isVarsayilan ? Colors.white : textColor, fontSize: 18, letterSpacing: 3, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
                  ],
                ),
                const SizedBox(height: 32),

                // ALT KISIM (İsim ve Kopyala)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("HESAP SAHİBİ", style: TextStyle(color: isVarsayilan ? Colors.white54 : Colors.black45, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                        const SizedBox(height: 6),
                        Text(iban['isim'].toUpperCase(), style: TextStyle(color: isVarsayilan ? Colors.white : textColor, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => _plazaUyariGoster("KOPYALANDI", "IBAN Panoya Kopyalandı! 📋", isVarsayilan ? Colors.green : primaryTeal),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: isVarsayilan ? Colors.white.withValues(alpha: 0.2) : bgColor, borderRadius: BorderRadius.circular(12)),
                        child: Icon(Icons.content_copy_outlined, color: isVarsayilan ? Colors.white : textColor, size: 20),
                      ),
                    )
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}