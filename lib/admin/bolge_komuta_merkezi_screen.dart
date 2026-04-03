import 'package:flutter/material.dart';

// 🚀 KARARGAH ZIRHLARI VE SERVİSLER
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';
import '../core/turkiye_haritasi.dart';
import '../services/bolge_yonetim_sistemi.dart'; // Yazdığımız Kuantum Motoru

class BolgeKomutaMerkeziScreen extends StatefulWidget {
  const BolgeKomutaMerkeziScreen({super.key});

  @override
  State<BolgeKomutaMerkeziScreen> createState() => _BolgeKomutaMerkeziScreenState();
}

class _BolgeKomutaMerkeziScreenState extends State<BolgeKomutaMerkeziScreen> {
  final BolgeYonetimSistemi _istihbaratServisi = BolgeYonetimSistemi();

  String? _seciliBolge;
  String? _seciliIl;
  bool _isScanning = false;
  Map<String, dynamic>? _analizSonucu;

  Future<void> _siberTaramayiBaslat() async {
    if (_seciliIl == null) {
      _siberUyariVer("SİBER İHLAL: Lütfen tarama yapılacak ili seçin!", isError: true);
      return;
    }

    setState(() {
      _isScanning = true;
      _analizSonucu = null;
    });

    // 🔴 GERÇEK FİREBASE VERİSİNİ ÇEKEN MOTOR ATEŞLENDİ
    final sonuc = await _istihbaratServisi.ilAnaliziYap(_seciliIl!);

    if (!mounted) return;

    setState(() {
      _isScanning = false;
      _analizSonucu = sonuc;
    });

    if (sonuc['basarili'] == false) {
      _siberUyariVer(sonuc['hata'] ?? "Bilinmeyen bir Kuantum hatası oluştu.", isError: true);
    } else {
      _siberUyariVer("TARAMA TAMAMLANDI: $_seciliIl Bölgesi Güvende!", isError: false);
    }
  }

  void _siberUyariVer(String mesaj, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: TextStyle(color: isError ? Colors.white : SiberTema.oledBlack, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
        backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.my_location, color: SiberTema.kuantumCyan), onPressed: () => Navigator.pop(context)),
          title: Text("BÖLGE KOMUTA MERKEZİ", style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 2, fontFamily: 'Avenir')),
          centerTitle: true,
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/images/radar_grid.png'), fit: BoxFit.cover, opacity: 0.05),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1. RADAR HEDEF SEÇİMİ ──
                Text("HEDEF LOKASYON BELİRLE", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 2, fontFamily: 'Avenir')),
                const SizedBox(height: 16),

                _buildDropdownContainer(
                  hint: "Tarama Bölgesi Seçin",
                  icon: Icons.map,
                  value: _seciliBolge,
                  items: TurkiyeHaritasi.bolgeler,
                  onChanged: (String? yeniBolge) {
                    setState(() {
                      _seciliBolge = yeniBolge;
                      _seciliIl = null;
                      _analizSonucu = null;
                    });
                  },
                ),

                _buildDropdownContainer(
                  hint: _seciliBolge == null ? "Önce Bölge Seçiniz" : "Tarama Yapılacak İl",
                  icon: Icons.radar,
                  value: _seciliIl,
                  items: _seciliBolge != null ? TurkiyeHaritasi.bolgeIlleri[_seciliBolge!]! : [],
                  onChanged: _seciliBolge == null ? null : (String? yeniIl) {
                    setState(() => _seciliIl = yeniIl);
                  },
                ),

                const SizedBox(height: 24),

                // ── 2. 3D SİBER TARAMA BUTONU ──
                GestureDetector(
                  onTap: _isScanning ? null : _siberTaramayiBaslat,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: double.infinity,
                    height: 65,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: _isScanning
                            ? [SiberTema.matGrey, SiberTema.oledBlack]
                            : [SiberTema.kuantumCyan.withOpacity(0.9), SiberTema.kuantumCyan.withOpacity(0.6)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _isScanning ? Colors.white24 : Colors.white.withOpacity(0.5), width: 1.5),
                      boxShadow: _isScanning ? [] : [
                        BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.3), offset: const Offset(0, 8), blurRadius: 15),
                        const BoxShadow(color: Colors.white30, offset: Offset(0, -2), blurRadius: 2, inset: true),
                      ],
                    ),
                    child: Center(
                      child: _isScanning
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: SiberTema.oledBlack, strokeWidth: 3))
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.satellite_alt, size: 24, color: SiberTema.oledBlack),
                          const SizedBox(width: 12),
                          const Text(
                            "BÖLGEYİ TARA VE ANALİZ ET",
                            style: TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5, fontFamily: 'Avenir', shadows: [Shadow(color: Colors.white54, blurRadius: 2, offset: Offset(0, 1))]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ── 3. ANALİZ SONUÇLARI (SİBER CAM KALKAN İÇİNDE) ──
                if (_analizSonucu != null && _analizSonucu!['basarili'] == true)
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("SİBER İSTİHBARAT RAPORU: ${_seciliIl?.toUpperCase()}", style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.5, fontFamily: 'Avenir')),
                          const SizedBox(height: 16),

                          // Finansal Veriler (Komutan Payı)
                          Row(
                            children: [
                              Expanded(child: _buildVeriKutusu("AĞ CİROSU", "₺${_analizSonucu!['toplam_ciro'].toStringAsFixed(2)}", Icons.account_balance_wallet, Colors.white)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildVeriKutusu("KOMUTAN PAYI (%12)", "₺${_analizSonucu!['komutan_payi'].toStringAsFixed(2)}", Icons.diamond, SiberTema.kuantumCyan, isHighlight: true)),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Operasyonel Veriler
                          Row(
                            children: [
                              Expanded(child: _buildVeriKutusu("AKTİF BAYİ", "${_analizSonucu!['aktif_bayi_sayisi']}", Icons.storefront, Colors.white)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildVeriKutusu("RİSKLİ BAYİ", "${_analizSonucu!['kritik_bayi_sayisi']}", Icons.warning_amber_rounded, SiberTema.kanKirmizi)),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Riskli Bayiler Listesi (Kırmızı Alarm)
                          if ((_analizSonucu!['riskli_bayiler'] as List).isNotEmpty) ...[
                            Text("⚠️ KARA LİSTE ADAYLARI (5+ ŞİKAYET)", style: TextStyle(color: SiberTema.kanKirmizi.withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5, fontFamily: 'Avenir')),
                            const SizedBox(height: 12),
                            ...(_analizSonucu!['riskli_bayiler'] as List).map((bayi) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: SiberTema.kanKirmizi.withOpacity(0.05),
                                    border: Border.all(color: SiberTema.kanKirmizi.withOpacity(0.3)),
                                    borderRadius: BorderRadius.circular(12)
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(bayi['firma_adi'], style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Avenir')),
                                    Text("${bayi['sikayet']} Şikayet", style: const TextStyle(color: SiberTema.kanKirmizi, fontSize: 13, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                                  ],
                                ),
                              );
                            }),
                          ]
                        ],
                      ),
                    ),
                  )
                else if (_analizSonucu != null && _analizSonucu!['basarili'] == false)
                  Center(child: Text("Radar Bağlantısı Koptu. Tekrar Deneyin.", style: TextStyle(color: SiberTema.kanKirmizi.withOpacity(0.8), fontFamily: 'Avenir'))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- GÖRSEL ZIRH PARÇALARI (3D DERİNLİK EFEKTLERİ) ---

  Widget _buildDropdownContainer({required String hint, required IconData icon, required String? value, required List<String> items, required void Function(String?)? onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        // 3D Dışa Çıkık Panel Hissi
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [SiberTema.matGrey.withOpacity(0.8), SiberTema.oledBlack],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, spreadRadius: 1, offset: const Offset(0, 4)),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          dropdownColor: SiberTema.matGrey,
          icon: const Icon(Icons.arrow_drop_down_circle, color: SiberTema.kuantumCyan),
          hint: Row(children: [Icon(icon, color: SiberTema.kuantumCyan, size: 20), const SizedBox(width: 16), Text(hint, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13, fontFamily: 'Avenir'))]),
          value: value,
          items: items.map((String item) => DropdownMenuItem<String>(value: item, child: Row(children: [Icon(icon, color: SiberTema.kuantumCyan, size: 20), const SizedBox(width: 16), Text(item, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, fontFamily: 'Avenir', fontWeight: FontWeight.w500))]))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildVeriKutusu(String baslik, String deger, IconData ikon, Color renk, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // 3D İçeri Çökük (Emboss) Veri Ekranı Hissi
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [SiberTema.oledBlack, SiberTema.matGrey.withOpacity(0.5)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isHighlight ? SiberTema.kuantumCyan.withOpacity(0.5) : Colors.white.withOpacity(0.05), width: isHighlight ? 1.5 : 1),
        boxShadow: [
          if (isHighlight) BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.05), blurRadius: 15, spreadRadius: -2, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(ikon, color: renk, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(baslik, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.w800, fontFamily: 'Avenir', overflow: TextOverflow.ellipsis))),
            ],
          ),
          const SizedBox(height: 12),
          Text(deger, style: TextStyle(color: isHighlight ? SiberTema.kuantumCyan : Colors.white.withOpacity(0.9), fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
        ],
      ),
    );
  }
}