import 'package:flutter/material.dart';

import '../../core/responsive_kalkan.dart';
import '../../services/google_hub_service.dart';

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

  // 🏢 PLAZA KALİTESİ PALET
  final Color primaryTeal = Colors.teal.shade700;
  final Color bgColor = const Color(0xFFFAFAFC);
  final Color textColor = const Color(0xFF1E293B);

  // EKRANA DÜŞECEK DİNAMİK VERİLER İÇİN KASA
  Map<String, String> _hubVerileri = {};

  // =========================================================================
  // 🧠 PLAZA ŞASE (VIN) ÇÖZÜCÜ MOTOR (Backend API Simülasyonu)
  // =========================================================================
  
  void _hubSorgusuBaslat() async {
    String girilenSase = _saseController.text.trim().replaceAll(" ", "").toUpperCase();

    if (girilenSase.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Geçersiz Şase (VIN) numarası.", style: TextStyle(color: SiberTema.textMain, fontFamily: 'Avenir')), backgroundColor: Colors.redAccent));
      return;
    }

    FocusScope.of(context).unfocus(); // Klavyeyi kapat
    setState(() { _hubSorgulaniyor = true; _aracBulundu = false; });

    // GİRİLEN ŞASEYİ MERKEZİ HUB'DAN ARA
    var hubRaporu = await GoogleHubService.fetchGlobalData(girilenSase);

    if (hubRaporu != null && hubRaporu.containsKey("detaylar")) {
      // ARAÇ BULUNDUYSA EKRANA DÜŞÜR!
      if (mounted) {
        setState(() {
          _hubSorgulaniyor = false;
          _aracBulundu = true;
          _hubVerileri = Map<String, String>.from(hubRaporu["detaylar"]);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Merkez Veritabanı: Fabrika verileri eşleşti.", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, fontFamily: 'Avenir')), backgroundColor: primaryTeal));
      }
    } else {
      // ARAÇ BULUNAMADIYSA
      if (mounted) {
        setState(() => _hubSorgulaniyor = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sistem Hatası: Bu şase numarasına ait fabrika verisi bulunamadı.", style: TextStyle(color: SiberTema.textMain, fontFamily: 'Avenir')), backgroundColor: Colors.redAccent));
      }
    }
  }

  void _ilaniYayinla() {
    if (_fiyatController.text.isEmpty || _kmController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen Fiyat ve Kilometre bilgilerini girin.", style: TextStyle(color: SiberTema.textMain, fontFamily: 'Avenir')), backgroundColor: Colors.redAccent));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Araç Kaydı Plaza Ağına Başarıyla Mühürlendi.", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, fontFamily: 'Avenir')), backgroundColor: primaryTeal));
    Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: primaryTeal, size: 20), onPressed: () => Navigator.pop(context)),
          title: Text("OtoDNA Veri Terminali", style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5, fontFamily: 'Avenir')),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Adım 1/3", style: TextStyle(color: primaryTeal, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
              const SizedBox(height: 8),
              Text("Şase (VIN) İle Çözümleme", style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Avenir')),
              const SizedBox(height: 24),

              _buildPremiumInput("Şase No (Örn: WDD205, 5YJ3)", Icons.terminal_outlined, _saseController, isUppercase: true),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _hubSorgulaniyor ? Colors.white : primaryTeal,
                      foregroundColor: _hubSorgulaniyor ? primaryTeal : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: _hubSorgulaniyor ? primaryTeal : Colors.transparent, width: 2)
                  ),
                  onPressed: _hubSorgulaniyor ? null : _hubSorgusuBaslat,
                  child: _hubSorgulaniyor
                      ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: primaryTeal, strokeWidth: 2)), const SizedBox(width: 12), Text("Veritabanı Taranıyor...", style: TextStyle(color: primaryTeal, fontWeight: FontWeight.w900, fontFamily: 'Avenir'))])
                      : const Text("MERKEZDEN VERİLERİ ÇEK", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1, fontFamily: 'Avenir')),
                ),
              ),
              const SizedBox(height: 40),

              // =========================================================================
              // EĞER TERMİNAL VERİYİ BULURSA BU EKRAN DÜŞER
              // =========================================================================
              if (_aracBulundu) ...[
                Text("Adım 2/3", style: TextStyle(color: primaryTeal, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                const SizedBox(height: 8),
                Text("Orijinal Fabrika Verileri", style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Avenir')),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(20), 
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 5))]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: primaryTeal.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(Icons.verified, color: primaryTeal, size: 28)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_hubVerileri["Marka/Model"]!, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Avenir')),
                                const SizedBox(height: 4),
                                Text("${_hubVerileri["Paket"]} - ${_hubVerileri["Yıl"]}", style: const TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                              ],
                            ),
                          )
                        ],
                      ),
                      
                      Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Divider(color: Colors.white.withValues(alpha: 0.05), height: 1)),

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

                Text("Adım 3/3", style: TextStyle(color: primaryTeal, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                const SizedBox(height: 8),
                Text("İlan Detayları", style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Avenir')),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(child: _buildPremiumInput("Fiyat (TL)", Icons.payments_outlined, _fiyatController, isNumber: true)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildPremiumInput("Kilometre", Icons.speed_outlined, _kmController, isNumber: true)),
                  ],
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _seciliHasar,
                      dropdownColor: Colors.white,
                      isExpanded: true,
                      icon: Icon(Icons.keyboard_arrow_down, color: primaryTeal),
                      style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
                      items: ["Kusursuz (Boya/Değişen Yok)", "1-2 Parça Lokal Boyalı", "Değişenli / İşlemli", "Ağır Hasar Kayıtlı"].map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value, style: TextStyle(color: textColor, fontSize: 14, fontFamily: 'Avenir')));
                      }).toList(),
                      onChanged: (newValue) => setState(() => _seciliHasar = newValue!),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                InkWell(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Medya Yöneticisi Açılıyor..."), backgroundColor: primaryTeal)),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 32),
                    decoration: BoxDecoration(color: primaryTeal.withValues(alpha: 0.02), borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryTeal.withValues(alpha: 0.3))),
                    child: Column(
                      children: [
                        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: primaryTeal.withValues(alpha: 0.1))), child: Icon(Icons.add_photo_alternate_outlined, color: primaryTeal, size: 36)),
                        const SizedBox(height: 16),
                        Text("Araç Fotoğraflarını Yükle", style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 14, fontFamily: 'Avenir')),
                        const SizedBox(height: 4),
                        const Text("Maksimum 20 Fotoğraf", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: _ilaniYayinla,
                    child: const Text("SİSTEME KAYDET VE YAYINLA", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1, fontFamily: 'Avenir')),
                  ),
                ),
                const SizedBox(height: 40),
              ]
            ],
          ),
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
              Text(baslik, style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
              const SizedBox(height: 2),
              Text(deger, style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumInput(String hint, IconData icon, TextEditingController controller, {bool isNumber = false, bool isUppercase = false}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 10)]),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        textCapitalization: isUppercase ? TextCapitalization.characters : TextCapitalization.sentences,
        style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
        decoration: InputDecoration(prefixIcon: Icon(icon, color: primaryTeal, size: 20), hintText: hint, hintStyle: const TextStyle(color: Colors.white38, fontSize: 13, fontFamily: 'Avenir'), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 16)),
      ),
    );
  }
}