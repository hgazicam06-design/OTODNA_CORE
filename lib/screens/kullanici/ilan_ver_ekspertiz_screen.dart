import 'package:flutter/material.dart';
import '../../core/responsive_kalkan.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Plaza Ağ Taraması Başladı... 📡", style: TextStyle(fontFamily: 'Avenir', fontWeight: FontWeight.bold)), backgroundColor: Colors.teal.shade700));
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        setState(() {
          _parcaDurumlari['Kaput'] = 2;
          _parcaDurumlari['Sağ Ön Çamurluk'] = 1;
          _fiyatGuncelle();
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Geçmiş Eşleşti: 1 Değişen, 1 Boyalı! 🛑", style: TextStyle(fontFamily: 'Avenir', fontWeight: FontWeight.bold)), backgroundColor: Colors.redAccent));
      });
    } else {
      setState(() {
        _parcaDurumlari.updateAll((key, value) => 0);
        _fiyatGuncelle();
      });
    }
  }

  // 💎 PLAZA MİMARİSİ: ALTTAN AÇILAN ZARİF MENÜ
  void _parcaDurumuSecMenuAc(String parca) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          final Color primaryTeal = Colors.teal.shade700;
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20)]
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 24),
                Text("$parca Durumu", style: const TextStyle(color: Color(0xFF1E293B), fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Avenir')),
                const SizedBox(height: 8),
                const Text("Seçtiğiniz parçanın ekspertiz sonucunu işaretleyin.", style: TextStyle(color: Colors.black54, fontSize: 13, fontFamily: 'Avenir', fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                _buildDurumSecenekButonu(parca, "Orijinal / İşlemsiz", 0, primaryTeal),
                _buildDurumSecenekButonu(parca, "Boyalı / Lokal Boya", 1, Colors.orange),
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? renk.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? renk.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.05)),
          boxShadow: isSelected ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5)]
        ),
        child: Row(
          children: [
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: isSelected ? renk : Colors.black26, size: 20),
            const SizedBox(width: 16),
            Text(baslik, style: TextStyle(color: isSelected ? renk : Colors.black54, fontSize: 14, fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold, fontFamily: 'Avenir')),
          ],
        ),
      ),
    );
  }

  // 🎨 ŞEMA RENKLENDİRME MOTORU (PLAZA EFEKTİ)
  Color _getParcaRenk(String parca) {
    int durum = _parcaDurumlari[parca]!;
    if (durum == 0) return Colors.teal.shade700.withValues(alpha: 0.05); // Orijinal
    if (durum == 1) return Colors.orange.withValues(alpha: 0.15); // Boyalı
    return Colors.redAccent.withValues(alpha: 0.15); // Değişen
  }

  Color _getParcaBorderRenk(String parca) {
    int durum = _parcaDurumlari[parca]!;
    if (durum == 0) return Colors.black.withValues(alpha: 0.05);
    if (durum == 1) return Colors.orange.withValues(alpha: 0.5);
    return Colors.redAccent.withValues(alpha: 0.5);
  }

  Color _getParcaMetinRenk(String parca) {
    int durum = _parcaDurumlari[parca]!;
    if (durum == 0) return Colors.teal.shade700;
    if (durum == 1) return Colors.orange;
    return Colors.redAccent;
  }

  void _devamEt() {
    FocusScope.of(context).unfocus();
    if (_kullaniciFiyatController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen hedef satış fiyatınızı girin.", style: TextStyle(color: Colors.white, fontFamily: 'Avenir')), backgroundColor: Colors.redAccent));
      return;
    }
    double kullaniciFiyati = double.tryParse(_kullaniciFiyatController.text) ?? _hesaplananFiyat;
    Navigator.push(context, MaterialPageRoute(builder: (context) => IlanVerFotografAciklamaScreen(secilenArac: widget.secilenArac, yapayZekaFiyati: kullaniciFiyati)));
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFFAFAFC);
    const Color textColor = Color(0xFF1E293B);
    final Color primaryTeal = Colors.teal.shade700;

    double altLimit = _hesaplananFiyat - 35000;
    double ustLimit = _hesaplananFiyat + 40000;

    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: primaryTeal, size: 20), onPressed: () => Navigator.pop(context)),
          title: Text('A D I M   2 / 3', style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 4, fontFamily: 'Avenir')),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Ekspertiz Haritası", style: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1, fontFamily: 'Avenir')),
                    const SizedBox(height: 8),
                    Text("${widget.secilenArac.join(' > ')}\nAracın kaporta durumunu dijital şemaya işleyin.", style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.5, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                    const SizedBox(height: 32),

                    // =========================================================
                    // OTODNA SENKRONİZASYON (TOGGLE)
                    // =========================================================
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _otodnaSenkronizasyon ? primaryTeal.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.05), width: _otodnaSenkronizasyon ? 2 : 1),
                          boxShadow: [
                            if (_otodnaSenkronizasyon)
                              BoxShadow(color: primaryTeal.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 5))
                            else
                              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5))
                          ]
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: _otodnaSenkronizasyon ? primaryTeal.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05), shape: BoxShape.circle),
                            child: Icon(Icons.radar, color: _otodnaSenkronizasyon ? primaryTeal : Colors.black38, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Ağdan Geçmişi Çek", style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                                const SizedBox(height: 4),
                                const Text("Aracın OtoDNA'daki mühürlü geçmişini haritaya otomatik yansıt.", style: TextStyle(color: Colors.black54, fontSize: 11, height: 1.4, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                              ],
                            ),
                          ),
                          Switch(
                            value: _otodnaSenkronizasyon,
                            activeColor: Colors.white,
                            activeTrackColor: primaryTeal,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: Colors.black26,
                            onChanged: (val) => _siberSenkronizasyonBaslat(),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // =========================================================
                    // PLAZA ŞEMA TASARIMI
                    // =========================================================
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15)]
                        ),
                        child: Column(
                          children: [
                            // ÖN TAMPON
                            _buildAracParcasi("Ön Tampon", 140, 24, const BorderRadius.vertical(top: Radius.circular(30))),
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

                    // RENK LEJANDI
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.circle_outlined, color: Colors.black26, size: 14), const SizedBox(width: 6), const Text("Orijinal", style: TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Avenir')), const SizedBox(width: 16),
                        const Icon(Icons.circle, color: Colors.orange, size: 14), const SizedBox(width: 6), const Text("Boyalı", style: TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Avenir')), const SizedBox(width: 16),
                        const Icon(Icons.circle, color: Colors.redAccent, size: 14), const SizedBox(width: 6), const Text("Değişen", style: TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                      ],
                    ),
                    const SizedBox(height: 48),

                    // =========================================================
                    // YAPAY ZEKA VE FİYAT ONAYI
                    // =========================================================
                    const Text("Yapay Zeka Piyasa Analizi", style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
                    const SizedBox(height: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text("₺${(altLimit/1000).toStringAsFixed(0)}k - ₺${(ustLimit/1000).toStringAsFixed(0)}k", key: ValueKey(_hesaplananFiyat), style: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1, fontFamily: 'Avenir')),
                    ),
                    const SizedBox(height: 24),

                    // Sizin Fiyatınız Input
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5)]),
                      child: TextField(
                        controller: _kullaniciFiyatController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Avenir'),
                        decoration: InputDecoration(
                          icon: Icon(Icons.currency_lira, color: primaryTeal, size: 20),
                          labelText: "Sizin Satış Fiyatınız (₺)",
                          labelStyle: const TextStyle(color: Colors.black45, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
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
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, -5))]
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryTeal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _devamEt,
                    child: const Text("FİYATI ONAYLA VE DEVAM ET", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1, fontFamily: 'Avenir')),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // 💎 PLAZA MİMARİSİ: ŞEMATİK ARAÇ PARÇASI
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
            style: TextStyle(color: _getParcaMetinRenk(parcaAdi), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5, fontFamily: 'Avenir'),
          ),
        ),
      ),
    );
  }
}