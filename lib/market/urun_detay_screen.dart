import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/siber_tema.dart';
import '../../core/siber_seo_motoru.dart'; // 🚀 SİBER SEO ENJEKSİYONU
import 'siber_sepet_screen.dart'; // 🛒 SİBER SEPET KÖPRÜSÜ

class UrunDetayScreen extends StatefulWidget {
  final String ilanId;
  final Map<String, dynamic> urunVerisi;

  const UrunDetayScreen({super.key, required this.ilanId, required this.urunVerisi});

  @override
  State<UrunDetayScreen> createState() => _UrunDetayScreenState();
}

class _UrunDetayScreenState extends State<UrunDetayScreen> {
  static const Color primaryCyan = SiberTema.kuantumCyan;
  static const Color siberGold = SiberTema.siberGold;

  int _seciliResimIndex = 0;
  String _seciliVaryant = "Standart Uyumlu";
  int _adet = 1;

  late String baslik;
  late double fiyat;
  late String satici;
  late String aciklama;
  late String resimUrl;

  @override
  void initState() {
    super.initState();
    baslik = widget.urunVerisi['ilan_ad'] ?? widget.urunVerisi['baslik'] ?? "Siber Parça";
    fiyat = (widget.urunVerisi['fiyat'] ?? 0).toDouble();
    satici = widget.urunVerisi['vitrin_etiketi'] ?? "OtoDNA Onaylı Satıcı";
    aciklama = widget.urunVerisi['aciklama'] ?? "Kuantum motor sistemleriyle tam uyumlu yüksek performanslı siber yedek parça. Zorlu hava koşullarına ve siber saldırılara karşı maksimum dayanıklılık sağlar. Bu ürün Karargah laboratuvarlarında 10.000 saat test edilmiştir ve kusursuz çalışmaktadır. Garanti kapsamında 2 yıl ücretsiz onarım mevcuttur.";
    resimUrl = widget.urunVerisi['resim_url'] ?? "https://via.placeholder.com/400x400/000000/00FFC2?text=OtoDNA";
  }

  @override
  Widget build(BuildContext context) {
    double kdvliFiyat = fiyat * 1.20; // %20 KDV eklentisi

    return SiberSeoMotoru.seoKalkaniIleSar(
      baslik: baslik,
      aciklama: aciklama.substring(0, aciklama.length > 150 ? 150 : aciklama.length), // 150 karaktere kırpılmış
      resimUrl: resimUrl,
      child: Scaffold(
        backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. KUANTUM ARKA PLAN
          Positioned.fill(child: Container(decoration: SiberTema.siberArkaPlan)),

          // 2. ANA İÇERİK (KAYDIRILABİLİR ALAN)
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildDetayAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 120), // Alt bar için boşluk
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFotoRadari(),
                        _buildSiberKunye(),
                        _buildDevFiyatKutusu(kdvliFiyat),
                        _buildVaryantMotoru(),
                        _buildGenisAciklamaPaneli(),
                        _buildSiberRozetler(),
                        _buildAkordeonMenuler(),
                        const SizedBox(height: 32),
                        _buildBenzerUrunlerRadari(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. SABİT ALT BAR (SEPETE EKLE)
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: _buildSabitAltBar(kdvliFiyat),
          ),
        ],
      ),
    ));
  }

  // ─── CAM ZIRHLI APP BAR ───
  Widget _buildDetayAppBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), border: const Border(bottom: BorderSide(color: Colors.white10))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle), child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18)),
              ),
              const Text('S İ B E R   D E T A Y', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 3, fontFamily: 'Avenir')),
              Row(
                children: [
                  Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle), child: const Icon(Icons.share_outlined, color: Colors.white, size: 20)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SiberSepetScreen())),
                    child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: primaryCyan.withOpacity(0.5))), child: const Icon(Icons.shopping_cart_outlined, color: primaryCyan, size: 20)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // ─── FOTOĞRAF GALERİSİ ───
  Widget _buildFotoRadari() {
    List<String> resimler = [resimUrl, resimUrl, resimUrl, resimUrl]; // Örnek çoklu resim

    return Column(
      children: [
        // Ana Görsel
        Container(
          width: double.infinity, height: 350,
          decoration: BoxDecoration(color: Colors.black, image: DecorationImage(image: NetworkImage(resimler[_seciliResimIndex]), fit: BoxFit.cover)),
          child: Stack(
            children: [
              Positioned(top: 16, left: 16, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: SiberTema.kanKirmizi, borderRadius: BorderRadius.circular(8)), child: const Text("- %15", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)))),
            ],
          ),
        ),
        // Küçük Resimler (Thumbnails)
        Container(
          height: 80, color: Colors.black.withOpacity(0.5),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: ListView.builder(
            scrollDirection: Axis.horizontal, itemCount: resimler.length, padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              bool seciliMi = _seciliResimIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _seciliResimIndex = index),
                child: Container(
                  width: 60, margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: seciliMi ? primaryCyan : Colors.white10, width: seciliMi ? 2 : 1),
                    image: DecorationImage(image: NetworkImage(resimler[index]), fit: BoxFit.cover),
                  ),
                  foregroundDecoration: BoxDecoration(color: seciliMi ? Colors.transparent : Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(8)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── SİBER KÜNYE (Başlık & Yıldızlar) ───
  Widget _buildSiberKunye() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(baslik, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, height: 1.3, fontFamily: 'Avenir')),
          const SizedBox(height: 12),
          Row(
            children: [
              Row(children: List.generate(5, (index) => const Icon(Icons.star, color: siberGold, size: 16))),
              const SizedBox(width: 8),
              const Text("4.9 (128 Değerlendirme)", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
            ],
          ),
          const SizedBox(height: 20),
          _buildKunyeSatiri("Satıcı", satici, primaryCyan),
          _buildKunyeSatiri("Kategori", "Oto Yedek Parça / Motor", Colors.white70),
          _buildKunyeSatiri("Stok Kodu", "ODNA-2049-X", Colors.white70),
        ],
      ),
    );
  }

  Widget _buildKunyeSatiri(String baslik, String deger, Color renk) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(baslik, style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir'))),
          const Text(":", style: TextStyle(color: Colors.white38)),
          const SizedBox(width: 12),
          Expanded(child: Text(deger, style: TextStyle(color: renk, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Avenir'))),
        ],
      ),
    );
  }

  // ─── DEV FİYAT KUTUSU ───
  Widget _buildDevFiyatKutusu(double kdvliFiyat) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SiberTema.kanKirmizi.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SiberTema.kanKirmizi.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: SiberTema.kanKirmizi.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("TOPLAM KDV DAHİL", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
          const SizedBox(height: 8),
          Text("₺${kdvliFiyat.toStringAsFixed(2)}", style: const TextStyle(color: SiberTema.kanKirmizi, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1, fontFamily: 'Avenir')),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.credit_card, color: Colors.white54, size: 16),
                SizedBox(width: 8),
                Text("Peşin Fiyatına 6 Taksit İmkanı!", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ─── VARYANT VE SEÇENEK MOTORU ───
  Widget _buildVaryantMotoru() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Seçenekler", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      dropdownColor: Colors.black,
                      value: _seciliVaryant,
                      icon: const Icon(Icons.keyboard_arrow_down, color: primaryCyan),
                      isExpanded: true,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
                      items: ["Standart Uyumlu", "Pro Performans Serisi", "VIP Kuantum Zırhlı"].map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value));
                      }).toList(),
                      onChanged: (yeniDeger) => setState(() => _seciliVaryant = yeniDeger!),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      dropdownColor: Colors.black,
                      value: _adet,
                      icon: const Icon(Icons.keyboard_arrow_down, color: primaryCyan),
                      isExpanded: true,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
                      items: [1, 2, 3, 4, 5].map((int value) {
                        return DropdownMenuItem<int>(value: value, child: Text("$value Adet"));
                      }).toList(),
                      onChanged: (yeniDeger) => setState(() => _adet = yeniDeger!),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // ─── GENİŞ AÇIKLAMA PANELİ ───
  Widget _buildGenisAciklamaPaneli() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Ürün Açıklaması", style: TextStyle(color: primaryCyan, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5, fontFamily: 'Avenir')),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
            child: Text(aciklama, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.6, fontFamily: 'Avenir')),
          ),
        ],
      ),
    );
  }

  // ─── SİBER ROZETLER (KARGO, ORİJİNAL) ───
  Widget _buildSiberRozetler() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildRozetItem(Icons.local_shipping_outlined, "Türkiye'nin Her\nNoktasına Teslim"),
          _buildRozetItem(Icons.verified_outlined, "%100 Orijinal\nGarantili Ürün"),
          _buildRozetItem(Icons.credit_card_outlined, "Kredi Kartına\nTaksit İmkanı"),
        ],
      ),
    );
  }

  Widget _buildRozetItem(IconData icon, String text) {
    return Expanded(
      child: Column(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle, border: Border.all(color: Colors.white10)), child: Icon(icon, color: primaryCyan, size: 24)),
          const SizedBox(height: 8),
          Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold, height: 1.3, fontFamily: 'Avenir')),
        ],
      ),
    );
  }

  // ─── AKORDEON MENÜLER ───
  Widget _buildAkordeonMenuler() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          _buildSiberAkordeon("Yorumlar (128)", Icons.comment_outlined, "Ürün hakkında 128 adet doğrulanmış Kuantum ağı incelemesi bulunmaktadır."),
          const SizedBox(height: 12),
          _buildSiberAkordeon("Taksit Seçenekleri", Icons.payment_outlined, "Tüm kredi kartlarına peşin fiyatına 6 taksit veya 12 aya varan vade seçenekleri."),
          const SizedBox(height: 12),
          _buildSiberAkordeon("Siber İade Koşulları", Icons.assignment_return_outlined, "14 gün içerisinde siber kasadan koşulsuz iade hakkınız mevcuttur."),
        ],
      ),
    );
  }

  Widget _buildSiberAkordeon(String baslik, IconData ikon, String icerik) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), border: Border.all(color: Colors.white10), borderRadius: BorderRadius.circular(16)),
          child: ExpansionTile(
            collapsedIconColor: Colors.white54,
            iconColor: primaryCyan,
            leading: Icon(ikon, color: Colors.white54, size: 20),
            title: Text(baslik, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(icerik, style: const TextStyle(color: Colors.white54, fontSize: 12, height: 1.5, fontFamily: 'Avenir')),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ─── BENZER ÜRÜNLER (YATAY RADAR) ───
  Widget _buildBenzerUrunlerRadari() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text("Benzer Siber Ürünler", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: 5, physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return Container(
                width: 160, margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 120, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), image: DecorationImage(image: NetworkImage(resimUrl), fit: BoxFit.cover))),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("120 NM Redüktörlü Kuantum Motor", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Avenir'), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 8),
                          Text("₺${(fiyat * 0.8).toStringAsFixed(2)}", style: const TextStyle(color: primaryCyan, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }

  // ─── SABİT ALT BAR (SEPETE EKLE) ───
  Widget _buildSabitAltBar(double kdvliFiyat) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            border: const Border(top: BorderSide(color: Colors.white10)),
            boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Toplam Tutar", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                    const SizedBox(height: 4),
                    Text("₺${(kdvliFiyat * _adet).toStringAsFixed(2)}", style: const TextStyle(color: primaryCyan, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Avenir')),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryCyan,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 10, shadowColor: primaryCyan.withOpacity(0.5),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("SİBER SEPETE EKLENDİ!"), backgroundColor: primaryCyan));
                      },
                      child: const Text("SEPETE EKLE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5, fontFamily: 'Avenir')),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
