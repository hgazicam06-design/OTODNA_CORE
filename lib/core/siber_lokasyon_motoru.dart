import 'package:flutter/material.dart';

class SiberLokasyonMotoru extends StatefulWidget {
  final Function(String ulke, String sehir, String bolge) onLokasyonSecildi;

  const SiberLokasyonMotoru({super.key, required this.onLokasyonSecildi});

  @override
  State<SiberLokasyonMotoru> createState() => _SiberLokasyonMotoruState();
}

class _SiberLokasyonMotoruState extends State<SiberLokasyonMotoru> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  static const Color bgColor = Color(0xFF000000);
  static const Color surfaceColor = Color(0xFF111111);
  static const Color primaryCyan = Color(0xFF00FFC2);

  // 🌍 KÜRESEL İSTİHBARAT VERİLERİ (81 İl ve 7 Bölge Mühürlendi!)
  final Map<String, String> _turkiyeSehirleri = {
    // 📍 Marmara Bölgesi (11 İl)
    "İstanbul": "Marmara Bölgesi", "Edirne": "Marmara Bölgesi", "Kırklareli": "Marmara Bölgesi", "Tekirdağ": "Marmara Bölgesi", "Çanakkale": "Marmara Bölgesi", "Kocaeli": "Marmara Bölgesi", "Yalova": "Marmara Bölgesi", "Sakarya": "Marmara Bölgesi", "Bilecik": "Marmara Bölgesi", "Bursa": "Marmara Bölgesi", "Balıkesir": "Marmara Bölgesi",
    // 📍 Ege Bölgesi (8 İl)
    "İzmir": "Ege Bölgesi", "Manisa": "Ege Bölgesi", "Aydın": "Ege Bölgesi", "Denizli": "Ege Bölgesi", "Muğla": "Ege Bölgesi", "Afyonkarahisar": "Ege Bölgesi", "Kütahya": "Ege Bölgesi", "Uşak": "Ege Bölgesi",
    // 📍 Akdeniz Bölgesi (8 İl)
    "Antalya": "Akdeniz Bölgesi", "Burdur": "Akdeniz Bölgesi", "Isparta": "Akdeniz Bölgesi", "Mersin": "Akdeniz Bölgesi", "Adana": "Akdeniz Bölgesi", "Hatay": "Akdeniz Bölgesi", "Osmaniye": "Akdeniz Bölgesi", "Kahramanmaraş": "Akdeniz Bölgesi",
    // 📍 İç Anadolu Bölgesi (13 İl)
    "Ankara": "İç Anadolu Bölgesi", "Konya": "İç Anadolu Bölgesi", "Eskişehir": "İç Anadolu Bölgesi", "Kırıkkale": "İç Anadolu Bölgesi", "Kırşehir": "İç Anadolu Bölgesi", "Yozgat": "İç Anadolu Bölgesi", "Nevşehir": "İç Anadolu Bölgesi", "Niğde": "İç Anadolu Bölgesi", "Kayseri": "İç Anadolu Bölgesi", "Aksaray": "İç Anadolu Bölgesi", "Karaman": "İç Anadolu Bölgesi", "Sivas": "İç Anadolu Bölgesi", "Çankırı": "İç Anadolu Bölgesi",
    // 📍 Karadeniz Bölgesi (18 İl)
    "Bolu": "Karadeniz Bölgesi", "Düzce": "Karadeniz Bölgesi", "Zonguldak": "Karadeniz Bölgesi", "Karabük": "Karadeniz Bölgesi", "Bartın": "Karadeniz Bölgesi", "Kastamonu": "Karadeniz Bölgesi", "Sinop": "Karadeniz Bölgesi", "Çorum": "Karadeniz Bölgesi", "Amasya": "Karadeniz Bölgesi", "Samsun": "Karadeniz Bölgesi", "Tokat": "Karadeniz Bölgesi", "Ordu": "Karadeniz Bölgesi", "Giresun": "Karadeniz Bölgesi", "Trabzon": "Karadeniz Bölgesi", "Gümüşhane": "Karadeniz Bölgesi", "Rize": "Karadeniz Bölgesi", "Bayburt": "Karadeniz Bölgesi", "Artvin": "Karadeniz Bölgesi",
    // 📍 Doğu Anadolu Bölgesi (14 İl)
    "Erzurum": "Doğu Anadolu Bölgesi", "Erzincan": "Doğu Anadolu Bölgesi", "Kars": "Doğu Anadolu Bölgesi", "Tunceli": "Doğu Anadolu Bölgesi", "Bingöl": "Doğu Anadolu Bölgesi", "Elazığ": "Doğu Anadolu Bölgesi", "Malatya": "Doğu Anadolu Bölgesi", "Muş": "Doğu Anadolu Bölgesi", "Bitlis": "Doğu Anadolu Bölgesi", "Ağrı": "Doğu Anadolu Bölgesi", "Iğdır": "Doğu Anadolu Bölgesi", "Van": "Doğu Anadolu Bölgesi", "Hakkari": "Doğu Anadolu Bölgesi", "Şırnak": "Doğu Anadolu Bölgesi",
    // 📍 Güneydoğu Anadolu Bölgesi (9 İl)
    "Gaziantep": "Güneydoğu Anadolu Bölgesi", "Kilis": "Güneydoğu Anadolu Bölgesi", "Adıyaman": "Güneydoğu Anadolu Bölgesi", "Şanlıurfa": "Güneydoğu Anadolu Bölgesi", "Diyarbakır": "Güneydoğu Anadolu Bölgesi", "Mardin": "Güneydoğu Anadolu Bölgesi", "Batman": "Güneydoğu Anadolu Bölgesi", "Siirt": "Güneydoğu Anadolu Bölgesi", "Ardahan": "Doğu Anadolu Bölgesi" // Ardahan düzeltmesi
  };

  final Map<String, String> _almanyaEyaletleri = {
    "Berlin": "Kuzeydoğu Almanya",
    "Bavyera (Münih)": "Güney Almanya",
    "Hessen (Frankfurt)": "Orta Almanya",
    "Hamburg": "Kuzey Almanya",
    // Tüm eyaletler eklenecek...
  };

  String _seciliUlke = "Türkiye";
  String? _seciliYer;

  @override
  Widget build(BuildContext context) {
    // 🧠 YAPAY ZEKA: Ülkeye göre gösterilecek haritayı otomatik seç
    Map<String, String> aktifListe = _seciliUlke == "Türkiye" ? _turkiyeSehirleri : _almanyaEyaletleri;

    // Şehirleri alfabetik sırala (Mükemmel Kuantum Dizilimi)
    var siraliSehirler = aktifListe.keys.toList()..sort();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.satellite_alt, color: primaryCyan.withOpacity(0.8), size: 24),
              const SizedBox(width: 12),
              const Text("KÜRESEL LOKASYON RADARI", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.white12, thickness: 1),
          ),

          // 1. ÜLKE SEÇİM SİBER BUTONLARI (TOGGLE)
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
            child: Row(
              children: [
                _buildUlkeToggle("Türkiye", Icons.star_and_crescent),
                _buildUlkeToggle("Almanya", Icons.euro_symbol), // Gelecekte dünya ülkeleri eklenebilir
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. ŞEHİR / EYALET SEÇİM DROPDOWN
          const Text("OPERASYON BÖLGESİ / ŞEHİR", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            value: _seciliYer,
            dropdownColor: surfaceColor, // Açılır menünün arka planı Siber Cam
            icon: const Icon(Icons.keyboard_arrow_down, color: primaryCyan),
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              filled: true,
              fillColor: bgColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryCyan, width: 1.5)),
            ),
            hint: Text("BİR LOKASYON SEÇİN...", style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
            items: siraliSehirler.map((String yer) {
              return DropdownMenuItem<String>(
                value: yer,
                child: Text(yer.toUpperCase(), style: const TextStyle(letterSpacing: 1)),
              );
            }).toList(),
            onChanged: (yeniYer) {
              setState(() {
                _seciliYer = yeniYer;
              });
              // Üst widget'a (Forma veya Firebase kayıt motoruna) veriyi fırlat
              if (yeniYer != null) {
                widget.onLokasyonSecildi(_seciliUlke, yeniYer, aktifListe[yeniYer]!);
              }
            },
          ),

          // 3. SEÇİLEN BÖLGE İSTİHBARATI (Sadece yer seçildiğinde Kuantum parlaması yapar)
          if (_seciliYer != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: primaryCyan.withOpacity(0.3))),
              child: Row(
                children: [
                  const Icon(Icons.my_location, color: primaryCyan, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    "BAĞLI DİSTRİBÜTÖRLÜK: ${aktifListe[_seciliYer]?.toUpperCase()}",
                    style: const TextStyle(color: primaryCyan, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                ],
              ),
            )
          ]
        ],
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: ÜLKE SEÇİM TOGGLE
  Widget _buildUlkeToggle(String ulkeAdi, IconData icon) {
    bool isSelected = _seciliUlke == ulkeAdi;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!isSelected) {
            setState(() {
              _seciliUlke = ulkeAdi;
              _seciliYer = null; // Ülke değişince şehri mecburen sıfırla (Kuantum Temizliği)
            });
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryCyan.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? primaryCyan.withOpacity(0.5) : Colors.transparent),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? primaryCyan : Colors.white38, size: 16),
              const SizedBox(width: 8),
              Text(
                ulkeAdi.toUpperCase(),
                style: TextStyle(color: isSelected ? primaryCyan : Colors.white38, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}