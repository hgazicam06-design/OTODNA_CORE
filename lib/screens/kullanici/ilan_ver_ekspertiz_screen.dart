import 'package:flutter/material.dart';
import 'ilan_ver_fotograf_aciklama_screen.dart';

class IlanVerEkspertizScreen extends StatefulWidget {
  final List<String> secilenArac;

  const IlanVerEkspertizScreen({super.key, required this.secilenArac});

  @override
  State<IlanVerEkspertizScreen> createState() => _IlanVerEkspertizScreenState();
}

class _IlanVerEkspertizScreenState extends State<IlanVerEkspertizScreen> {
  bool _otodnaSenkronizasyon = false;
  double _bazFiyat = 1500000;
  double _hesaplananFiyat = 1500000;
  final TextEditingController _kullaniciFiyatController = TextEditingController();

  // PARÇA DURUMLARI: 0 = Orijinal, 1 = Boyalı, 2 = Değişen
  final Map<String, int> _parcaDurumlari = {
    'Ön Tampon': 0, 'Kaput': 0, 'Sağ Ön Çamurluk': 0, 'Sol Ön Çamurluk': 0,
    'Sağ Ön Kapı': 0, 'Sol Ön Kapı': 0, 'Tavan': 0,
    'Sağ Arka Kapı': 0, 'Sol Arka Kapı': 0,
    'Sağ Arka Çamurluk': 0, 'Sol Arka Çamurluk': 0,
    'Bagaj': 0, 'Arka Tampon': 0,
  };

  @override
  void dispose() {
    _kullaniciFiyatController.dispose();
    super.dispose();
  }

  void _fiyatGuncelle() {
    double yenifiyat = _bazFiyat;
    _parcaDurumlari.forEach((parca, durum) {
      if (durum == 1) yenifiyat -= 18000;
      if (durum == 2) yenifiyat -= 45000;
    });
    setState(() { _hesaplananFiyat = yenifiyat; });
  }

  void _siberSenkronizasyonBaslat() {
    setState(() { _otodnaSenkronizasyon = !_otodnaSenkronizasyon; });

    if (_otodnaSenkronizasyon) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Siber Ağ Taraması Başladı... 📡"), backgroundColor: Color(0xFF00FFC2)));
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        setState(() {
          _parcaDurumlari['Kaput'] = 2;
          _parcaDurumlari['Sağ Ön Çamurluk'] = 1;
          _fiyatGuncelle();
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Geçmiş Eşleşti: 1 Değişen, 1 Boyalı! 🛑"), backgroundColor: Colors.redAccent));
      });
    } else {
      setState(() {
        _parcaDurumlari.updateAll((key, value) => 0);
        _fiyatGuncelle();
      });
    }
  }

  // 💎 TESLA MİMARİSİ: ALTTAN AÇILAN ZARİF MENÜ
  void _parcaDurumuSecMenuAc(String parca) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF111111), // Koyu Gri Tesla Yüzeyi
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 24),
                Text("$parca Durumu", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.5)),
                const SizedBox(height: 8),
                const Text("Seçtiğiniz parçanın ekspertiz sonucunu işaretleyin.", style: TextStyle(color: Colors.white54, fontSize: 13)),
                const SizedBox(height: 24),
                _buildDurumSecenekButonu(parca, "Orijinal / İşlemsiz", 0, Colors.white),
                _buildDurumSecenekButonu(parca, "Boyalı / Lokal Boya", 1, Colors.orangeAccent),
                _buildDurumSecenekButonu(parca, "Değişen / Yenilenen", 2, Colors.redAccent),
              ],
            ),
          );
        }
    );
  }

  Widget _buildDurumSecenekButonu(String parca, String baslik, int durumDegeri, Color renk) {
    bool isSelected = _parcaDurumlari[parca] == durumDegeri;
    return InkWell(
      onTap: () {
        setState(() {
          _parcaDurumlari[parca] = durumDegeri;
          _fiyatGuncelle();
        });
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? renk.withOpacity(0.1) : const Color(0xFF000000),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? renk.withOpacity(0.5) : Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: isSelected ? renk : Colors.white38, size: 20),
            const SizedBox(width: 16),
            Text(baslik, style: TextStyle(color: isSelected ? renk : Colors.white70, fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // 🎨 ŞEMA RENKLENDİRME MOTORU (HUD / BLUEPRINT EFEKTİ)
  Color _getParcaRenk(String parca) {
    int durum = _parcaDurumlari[parca]!;
    if (durum == 0) return const Color(0xFF111111); // Orijinal: Koyu Gri
    if (durum == 1) return Colors.orangeAccent.withOpacity(0.15); // Boyalı: Saydam Turuncu
    return Colors.redAccent.withOpacity(0.15); // Değişen: Saydam Kırmızı
  }

  Color _getParcaBorderRenk(String parca) {
    int durum = _parcaDurumlari[parca]!;
    if (durum == 0) return Colors.white12;
    if (durum == 1) return Colors.orangeAccent.withOpacity(0.5);
    return Colors.redAccent.withOpacity(0.5);
  }

  Color _getParcaMetinRenk(String parca) {
    int durum = _parcaDurumlari[parca]!;
    if (durum == 0) return Colors.white38;
    if (durum == 1) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  void _devamEt() {
    FocusScope.of(context).unfocus();
    if (_kullaniciFiyatController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen hedef satış fiyatınızı girin.", style: TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent));
      return;
    }
    double kullaniciFiyati = double.tryParse(_kullaniciFiyatController.text) ?? _hesaplananFiyat;
    Navigator.push(context, MaterialPageRoute(builder: (context) => IlanVerFotografAciklamaScreen(secilenArac: widget.secilenArac, yapayZekaFiyati: kullaniciFiyati)));
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF000000);
    const surfaceColor = Color(0xFF111111);
    const accentColor = Colors.white;
    const primaryCyan = Color(0xFF00FFC2);

    double altLimit = _hesaplananFiyat - 35000;
    double ustLimit = _hesaplananFiyat + 40000;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: accentColor, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('A D I M   2 / 3', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 4)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Ekspertiz Haritası", style: TextStyle(color: accentColor, fontSize: 32, fontWeight: FontWeight.w600, letterSpacing: -1)),
                  const SizedBox(height: 8),
                  Text("${widget.secilenArac.join(' > ')}\nAracın kaporta durumunu dijital şemaya işleyin.", style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.5)),
                  const SizedBox(height: 32),

                  // =========================================================
                  // OTODNA SENKRONİZASYON (TOGGLE)
                  // =========================================================
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _otodnaSenkronizasyon ? primaryCyan.withOpacity(0.5) : Colors.white.withOpacity(0.05))
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: _otodnaSenkronizasyon ? primaryCyan.withOpacity(0.1) : Colors.white.withOpacity(0.05), shape: BoxShape.circle),
                          child: Icon(Icons.radar, color: _otodnaSenkronizasyon ? primaryCyan : Colors.white54, size: 24),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Ağdan Geçmişi Çek", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text("Aracın OtoDNA'daki mühürlü geçmişini haritaya otomatik yansıt.", style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.4)),
                            ],
                          ),
                        ),
                        Switch(
                          value: _otodnaSenkronizasyon,
                          activeColor: primaryCyan,
                          activeTrackColor: primaryCyan.withOpacity(0.3),
                          inactiveThumbColor: Colors.white54,
                          inactiveTrackColor: Colors.white12,
                          onChanged: (val) => _siberSenkronizasyonBaslat(),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // =========================================================
                  // 3D SİBER ŞEMA (BLUEPRINT HUD TASARIMI)
                  // =========================================================
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Column(
                        children: [
                          // ÖN TAMPON
                          _buildAracParcasi("Ön Tampon", 140, 24, BorderRadius.vertical(top: Radius.circular(30))),
                          const SizedBox(height: 6),

                          // KAPUT VE ÖN ÇAMURLUKLAR
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildAracParcasi("Sol Ön Çamurluk", 32, 80, const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(4))),
                              const SizedBox(width: 6),
                              _buildAracParcasi("Kaput", 96, 80, BorderRadius.circular(8)),
                              const SizedBox(width: 6),
                              _buildAracParcasi("Sağ Ön Çamurluk", 32, 80, const BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(4))),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // TAVAN VE ÖN KAPILAR
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildAracParcasi("Sol Ön Kapı", 32, 70, BorderRadius.circular(4)),
                              const SizedBox(width: 6),
                              _buildAracParcasi("Tavan", 96, 146, BorderRadius.circular(12)),
                              const SizedBox(width: 6),
                              _buildAracParcasi("Sağ Ön Kapı", 32, 70, BorderRadius.circular(4)),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // ARKA KAPILAR
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildAracParcasi("Sol Arka Kapı", 32, 70, BorderRadius.circular(4)),
                              const SizedBox(width: 108), // Tavan genişliği (96) + boşluklar (12)
                              _buildAracParcasi("Sağ Arka Kapı", 32, 70, BorderRadius.circular(4)),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // BAGAJ VE ARKA ÇAMURLUKLAR
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildAracParcasi("Sol Arka Çamurluk", 32, 80, const BorderRadius.only(topLeft: Radius.circular(4), bottomLeft: Radius.circular(20))),
                              const SizedBox(width: 6),
                              _buildAracParcasi("Bagaj", 96, 80, BorderRadius.circular(8)),
                              const SizedBox(width: 6),
                              _buildAracParcasi("Sağ Arka Çamurluk", 32, 80, const BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(20))),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // ARKA TAMPON
                          _buildAracParcasi("Arka Tampon", 140, 24, const BorderRadius.vertical(bottom: Radius.circular(30))),
                        ],
                      ),
                    ),
                  ),

                  // RENK LEJANDI (Minimalist)
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.circle_outlined, color: Colors.white38, size: 14), const SizedBox(width: 6), const Text("Orijinal", style: TextStyle(color: Colors.white54, fontSize: 11)), const SizedBox(width: 16),
                      const Icon(Icons.circle, color: Colors.orangeAccent, size: 14), const SizedBox(width: 6), const Text("Boyalı", style: TextStyle(color: Colors.white54, fontSize: 11)), const SizedBox(width: 16),
                      const Icon(Icons.circle, color: Colors.redAccent, size: 14), const SizedBox(width: 6), const Text("Değişen", style: TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 48),

                  // =========================================================
                  // YAPAY ZEKA VE FİYAT ONAYI
                  // =========================================================
                  const Text("Yapay Zeka Piyasa Analizi", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Text("₺${(altLimit/1000).toStringAsFixed(0)}k - ₺${(ustLimit/1000).toStringAsFixed(0)}k", key: ValueKey(_hesaplananFiyat), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w600, letterSpacing: -1)),
                  ),
                  const SizedBox(height: 24),

                  // Sizin Fiyatınız Input (Floating Label)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
                    child: TextField(
                      controller: _kullaniciFiyatController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        icon: Icon(Icons.currency_lira, color: Colors.white54, size: 20),
                        labelText: "Sizin Satış Fiyatınız (₺)",
                        labelStyle: TextStyle(color: Colors.white38, fontSize: 13, fontWeight: FontWeight.normal),
                        border: InputBorder.none,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // SABİT ALT BUTON
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: bgColor,
              border: Border(top: BorderSide(color: Colors.white12)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryCyan,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _devamEt,
                child: const Text("FİYATI ONAYLA VE DEVAM ET", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
              ),
            ),
          )
        ],
      ),
    );
  }

  // 💎 TESLA MİMARİSİ: ŞEMATİK ARAÇ PARÇASI
  Widget _buildAracParcasi(String parcaAdi, double genislik, double yukseklik, BorderRadius kavis) {
    return GestureDetector(
      onTap: () => _parcaDurumuSecMenuAc(parcaAdi),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: genislik, height: yukseklik,
        decoration: BoxDecoration(
          color: _getParcaRenk(parcaAdi),
          borderRadius: kavis,
          border: Border.all(color: _getParcaBorderRenk(parcaAdi), width: 1.5),
        ),
        child: Center(
          child: Text(
            parcaAdi.replaceAll(" Çamurluk", "\nÇamurluk").replaceAll(" Kapı", "\nKapı"),
            textAlign: TextAlign.center,
            style: TextStyle(color: _getParcaMetinRenk(parcaAdi), fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
        ),
      ),
    );
  }
}