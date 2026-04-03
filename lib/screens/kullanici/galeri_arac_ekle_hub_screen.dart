import 'package:flutter/material.dart';

class GaleriAracEkleHubScreen extends StatefulWidget {
  const GaleriAracEkleHubScreen({super.key});

  @override
  State<GaleriAracEkleHubScreen> createState() => _GaleriAracEkleHubScreenState();
}

class _GaleriAracEkleHubScreenState extends State<GaleriAracEkleHubScreen> {
  final TextEditingController _saseController = TextEditingController();
  final TextEditingController _fiyatController = TextEditingController();
  final TextEditingController _kmController = TextEditingController();

  bool _hubSorgulaniyor = false;
  bool _aracBulundu = false;
  String _seciliHasar = "Kusursuz (Boya/Değişen Yok)";

  // EKRANA DÜŞECEK DİNAMİK VERİLER İÇİN KASA
  Map<String, String> _hubVerileri = {};

  // =========================================================================
  // 🧠 SİBER ŞASE (VIN) ÇÖZÜCÜ MOTOR (Backend API Simülasyonu)
  // İleride burası OtoDNA sunucusuna bağlanıp gerçek fabrikadan veri çekecek!
  // =========================================================================
  final Map<String, Map<String, String>> _siberHubVeritabanim = {
    "WDD205": {
      "Marka/Model": "Mercedes-Benz C200d",
      "Paket": "AMG Line",
      "Yıl": "2023",
      "Motor Gücü": "163 HP (+20 HP EQ Boost)",
      "Motor Hacmi": "1992 cc",
      "Şanzıman": "9G-TRONIC",
      "Renk": "Obsidyen Siyahı",
    },
    "5YJ3": {
      "Marka/Model": "Tesla Model 3",
      "Paket": "Long Range AWD",
      "Yıl": "2024",
      "Motor Gücü": "498 HP (Çift Motor)",
      "Motor Hacmi": "Elektrikli (EV)",
      "Şanzıman": "Tek İleri Redüktör",
      "Renk": "İnci Beyazı",
    },
    "VF1": {
      "Marka/Model": "Renault Megane",
      "Paket": "Icon",
      "Yıl": "2022",
      "Motor Gücü": "140 HP",
      "Motor Hacmi": "1332 cc",
      "Şanzıman": "EDC (Çift Kavrama)",
      "Renk": "Gümüş Gri",
    }
  };

  void _hubSorgusuBaslat() {
    String girilenSase = _saseController.text.trim().replaceAll(" ", "").toUpperCase();

    if (girilenSase.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Geçersiz Şase (VIN) numarası.", style: TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent));
      return;
    }

    FocusScope.of(context).unfocus(); // Klavyeyi kapat
    setState(() { _hubSorgulaniyor = true; _aracBulundu = false; });

    // Terminal Komutu Gecikmesi (API'ye istek atıyormuşuz gibi 2 saniye bekler)
    Future.delayed(const Duration(milliseconds: 2000), () {

      // GİRİLEN ŞASEYİ VERİTABANINDA ARA (Algoritma)
      Map<String, String>? bulunanArac;

      _siberHubVeritabanim.forEach((saseKodu, aracVerisi) {
        if (girilenSase.startsWith(saseKodu)) {
          bulunanArac = aracVerisi;
        }
      });

      if (bulunanArac != null) {
        // ARAÇ BULUNDUYSA EKRANA DÜŞÜR!
        setState(() {
          _hubSorgulaniyor = false;
          _aracBulundu = true;
          _hubVerileri = bulunanArac!;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Terminal: Fabrika verileri eşleşti.", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Color(0xFF00FFC2)));
      } else {
        // ARAÇ BULUNAMADIYSA
        setState(() => _hubSorgulaniyor = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Siber Ağ Hatası: Bu şase numarasına ait fabrika verisi bulunamadı.", style: TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent));
      }
    });
  }

  void _ilaniYayinla() {
    if (_fiyatController.text.isEmpty || _kmController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen Fiyat ve Kilometre bilgilerini girin.", style: TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent));
      return;
    }
    // İleride bu veriler (Şase, Fiyat, KM ve _hubVerileri) tek bir paket olup Firebase'e fırlatılacak.
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Araç DNA'sı Ağa Başarıyla Mühürlendi.", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: Colors.green));
    Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF000000);
    const surfaceColor = Color(0xFF111111);
    const primaryCyan = Color(0xFF00FFC2);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text("Kuantum Veri Terminali", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16, letterSpacing: 0.5)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Adım 1/3", style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 8),
            const Text("Şase (VIN) İle Çözümleme", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.5)),
            const SizedBox(height: 24),

            _buildPremiumInput("Şase No (Dene: WDD205, 5YJ3, VF1)", Icons.terminal_outlined, _saseController, isUppercase: true, inputColor: surfaceColor),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: _hubSorgulaniyor ? surfaceColor : primaryCyan,
                    foregroundColor: _hubSorgulaniyor ? Colors.white : Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: _hubSorgulaniyor ? Colors.white24 : Colors.transparent)
                ),
                onPressed: _hubSorgulaniyor ? null : _hubSorgusuBaslat,
                child: _hubSorgulaniyor
                    ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2)), SizedBox(width: 12), Text("Ağ Taranıyor...", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w600))])
                    : const Text("HUB'DAN VERİLERİ ÇEK", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1)),
              ),
            ),
            const SizedBox(height: 40),

            // =========================================================================
            // EĞER TERMİNAL VERİYİ BULURSA BU EKRAN DÜŞER
            // =========================================================================
            if (_aracBulundu) ...[
              const Text("Adım 2/3", style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 8),
              const Text("Orijinal Fabrika Verileri", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.5)),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryCyan.withOpacity(0.3), width: 1)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_hubVerileri["Marka/Model"]!, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.5)),
                    const SizedBox(height: 4),
                    Text("${_hubVerileri["Paket"]} - ${_hubVerileri["Yıl"]}", style: const TextStyle(color: Colors.white54, fontSize: 13)),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Colors.white12, height: 1)),

                    GridView.count(
                      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 20, childAspectRatio: 2.5,
                      children: [
                        _buildHubDetayi("Motor Gücü", _hubVerileri["Motor Gücü"]!, Icons.electric_bolt_outlined),
                        _buildHubDetayi("Motor Hacmi", _hubVerileri["Motor Hacmi"]!, Icons.engineering_outlined),
                        _buildHubDetayi("Şanzıman", _hubVerileri["Şanzıman"]!, Icons.account_tree_outlined),
                        _buildHubDetayi("Fabrika Rengi", _hubVerileri["Renk"]!, Icons.format_paint_outlined),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              const Text("Adım 3/3", style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 8),
              const Text("İlan Detayları", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.5)),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(child: _buildPremiumInput("Fiyat (TL)", Icons.payments_outlined, _fiyatController, isNumber: true, inputColor: surfaceColor)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildPremiumInput("Kilometre", Icons.speed_outlined, _kmController, isNumber: true, inputColor: surfaceColor)),
                ],
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _seciliHasar,
                    dropdownColor: surfaceColor,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    items: ["Kusursuz (Boya/Değişen Yok)", "1-2 Parça Lokal Boyalı", "Değişenli / İşlemli", "Ağır Hasar Kayıtlı"].map((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)));
                    }).toList(),
                    onChanged: (newValue) => setState(() => _seciliHasar = newValue!),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              InkWell(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Galeri Açılıyor..."), backgroundColor: Color(0xFF111111))),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white24)),
                  child: const Column(
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, color: Colors.white54, size: 36),
                      SizedBox(height: 16),
                      Text("Araç Fotoğraflarını Yükle", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                      SizedBox(height: 4),
                      Text("Maksimum 20 Fotoğraf", style: TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: _ilaniYayinla,
                  child: const Text("AĞA GÖNDER VE YAYINLA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1)),
                ),
              ),
              const SizedBox(height: 40),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildHubDetayi(String baslik, String deger, IconData ikon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(ikon, color: Colors.white38, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(baslik, style: const TextStyle(color: Colors.white38, fontSize: 11)),
              const SizedBox(height: 2),
              Text(deger, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumInput(String hint, IconData icon, TextEditingController controller, {bool isNumber = false, bool isUppercase = false, required Color inputColor}) {
    return Container(
      decoration: BoxDecoration(color: inputColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        textCapitalization: isUppercase ? TextCapitalization.characters : TextCapitalization.sentences,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(prefixIcon: Icon(icon, color: Colors.white54, size: 20), hintText: hint, hintStyle: const TextStyle(color: Colors.white38, fontSize: 13), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 16)),
      ),
    );
  }
}