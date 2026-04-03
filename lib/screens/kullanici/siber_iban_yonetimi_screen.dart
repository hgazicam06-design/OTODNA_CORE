import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SiberIbanYonetimiScreen extends StatefulWidget {
  const SiberIbanYonetimiScreen({super.key});

  @override
  State<SiberIbanYonetimiScreen> createState() => _SiberIbanYonetimiScreenState();
}

class _SiberIbanYonetimiScreenState extends State<SiberIbanYonetimiScreen> {
  // SİBER FİNANS VERİTABANI
  final List<Map<String, dynamic>> _kayitliIbanlar = [
    {
      "banka": "Garanti BBVA Ticari",
      "isim": "Gazi *****",
      "iban": "1234 5678 9000 0012 3456 78", // Baştaki TR kısmını UI'da ekliyoruz
      "renk": Colors.greenAccent,
      "ikon": Icons.account_balance_outlined,
      "varsayilan": true,
    },
    {
      "banka": "Ziraat Şahıs Hesabı",
      "isim": "Gazi *****",
      "iban": "9876 5432 1000 0098 7654 32",
      "renk": Colors.redAccent,
      "ikon": Icons.account_balance_outlined,
      "varsayilan": false,
    }
  ];

  // 💎 TESLA MİMARİSİ: ŞIK BOTTOM SHEET
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
            color: const Color(0xFF111111), // Mat Siyah
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: const Color(0xFF00FFC2).withOpacity(0.3), width: 1.5),
            boxShadow: [BoxShadow(color: const Color(0xFF00FFC2).withOpacity(0.05), blurRadius: 40, spreadRadius: 10)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 32),
              const Row(
                children: [
                  Icon(Icons.add_card_outlined, color: Color(0xFF00FFC2), size: 28),
                  SizedBox(width: 12),
                  Text("YENİ HESAP TANIMLA", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ],
              ),
              const SizedBox(height: 32),

              // BANKA ADI
              const Text("Banka / Kurum Adı", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF000000), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
                child: TextField(
                  controller: bankaController,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: "Örn: İş Bankası Şahıs", hintStyle: TextStyle(color: Colors.white24, fontWeight: FontWeight.normal),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // IBAN NUMARASI
              const Text("IBAN Numarası", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF000000), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
                child: TextField(
                  controller: ibanController,
                  keyboardType: TextInputType.number,
                  maxLength: 24,
                  style: const TextStyle(color: Colors.white, letterSpacing: 3, fontWeight: FontWeight.bold, fontSize: 14),
                  decoration: const InputDecoration(
                    prefixText: "TR ", prefixStyle: TextStyle(color: Color(0xFF00FFC2), fontWeight: FontWeight.w900, letterSpacing: 3, fontSize: 14),
                    hintText: "0000 0000 0000 0000 0000 00", hintStyle: TextStyle(color: Colors.white24, letterSpacing: 2, fontWeight: FontWeight.normal),
                    counterText: "",
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // KAYDET BUTONU
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FFC2), foregroundColor: Colors.black, elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    if (bankaController.text.isEmpty || ibanController.text.length < 24) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Banka Adı ve 24 Haneli IBAN eksiksiz olmalıdır.", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: Colors.redAccent));
                      return;
                    }
                    FocusScope.of(context).unfocus();
                    Navigator.pop(context);
                    _biyometrikOnayAl(bankaController.text, ibanController.text);
                  },
                  icon: const Icon(Icons.fingerprint, size: 20),
                  label: const Text("BİYOMETRİK ONAY İLE KAYDET", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // 💎 TESLA MİMARİSİ: APPLE PAY TARZI BİYOMETRİK EKRAN
  void _biyometrikOnayAl(String banka, String iban) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF00FFC2).withOpacity(0.3))),
        contentPadding: const EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF00FFC2), width: 2), boxShadow: [BoxShadow(color: const Color(0xFF00FFC2).withOpacity(0.2), blurRadius: 20)]),
              child: const Icon(Icons.face_unlock_outlined, color: Color(0xFF00FFC2), size: 48),
            ),
            const SizedBox(height: 24),
            const Text("Siber Kimlik Doğrulaması", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
            const SizedBox(height: 8),
            const Text("FaceID / Parmak İzi onayınız bekleniyor...", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5)),
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
          "iban": iban, // Sadece sayılar geldi, TR'yi UI ekleyecek
          "renk": const Color(0xFF00FFC2),
          "ikon": Icons.account_balance_outlined,
          "varsayilan": false,
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Banka Hesabı Kuantum Ağına Mühürlendi! 🧬", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Color(0xFF00FFC2)));
    });
  }

  void _varsayilanYap(int index) {
    setState(() {
      for (var iban in _kayitliIbanlar) { iban['varsayilan'] = false; }
      _kayitliIbanlar[index]['varsayilan'] = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ana Çekim Hesabı Olarak Güncellendi! 🌟", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Color(0xFF00FFC2)));
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF000000);
    const surfaceColor = Color(0xFF111111);
    const primaryCyan = Color(0xFF00FFC2);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text("B A N K A   H E S A P L A R I", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 3)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.1))),
        onPressed: _yeniIbanEklePenceresiAc,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Yeni IBAN Ekle", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
      ),
      body: _kayitliIbanlar.isEmpty
          ? const Center(child: Text("Henüz kayıtlı bir banka hesabınız yok.", style: TextStyle(color: Colors.white38, fontSize: 13)))
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: _kayitliIbanlar.length,
        itemBuilder: (context, index) {
          var iban = _kayitliIbanlar[index];
          bool isVarsayilan = iban['varsayilan'];
          Color kartRengi = isVarsayilan ? primaryCyan : Colors.white38;

          // 💎 SİBER METALİK KART TASARIMI
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isVarsayilan ? primaryCyan.withOpacity(0.5) : Colors.white.withOpacity(0.05), width: isVarsayilan ? 1.5 : 1),
              boxShadow: isVarsayilan ? [BoxShadow(color: primaryCyan.withOpacity(0.1), blurRadius: 20, spreadRadius: 2)] : [],
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
                        Icon(Icons.memory, color: kartRengi.withOpacity(0.8), size: 28), // Çip İkonu!
                        const SizedBox(width: 12),
                        Text(iban['banka'].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      ],
                    ),
                    if (isVarsayilan)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: primaryCyan.withOpacity(0.5))),
                        child: const Text("ANA HESAP", style: TextStyle(color: primaryCyan, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      )
                    else
                      GestureDetector(
                        onTap: () => _varsayilanYap(index),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white12)),
                          child: const Icon(Icons.star_border, color: Colors.white38, size: 16),
                        ),
                      )
                  ],
                ),
                const SizedBox(height: 32),

                // ORTA KISIM (IBAN Numarası Monospace Formatta)
                Row(
                  children: [
                    const Text("TR", style: TextStyle(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    const SizedBox(width: 8),
                    Text(iban['iban'], style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 3, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 24),

                // ALT KISIM (İsim ve Kopyala)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("HESAP SAHİBİ", style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        const SizedBox(height: 4),
                        Text(iban['isim'].toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("IBAN Panoya Kopyalandı! 📋", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: primaryCyan)),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.content_copy_outlined, color: Colors.white, size: 18),
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