import 'package:flutter/material.dart';

import '../../core/responsive_kalkan.dart';

class FirmalarScreen extends StatefulWidget {
  const FirmalarScreen({super.key});

  @override
  State<FirmalarScreen> createState() => _FirmalarScreenState();
}

class _FirmalarScreenState extends State<FirmalarScreen> {
  String _secilenKategori = 'Tümü';
  String _aramaMetni = '';

  // 🏢 PLAZA KALİTESİ PALET
  final Color primaryTeal = Colors.teal.shade700;
  final Color bgColor = const Color(0xFFFAFAFC);
  final Color textColor = const Color(0xFF1E293B);
  final Color dangerColor = Colors.redAccent;

  // =========================================================================
  // 🚀 NİŞ UZMANLIK VE SANAYİ KATEGORİLERİ
  // =========================================================================
  final List<Map<String, dynamic>> _kategoriler = [
    {'isim': 'Tümü', 'ikon': Icons.apps_outlined},
    {'isim': 'Distribütör & Ana Bayi', 'ikon': Icons.account_balance_outlined},
    {'isim': 'OtoDNA Servis', 'ikon': Icons.build_circle_outlined},
    {'isim': 'Motor Rektefiye & Torna', 'ikon': Icons.precision_manufacturing_outlined},
    {'isim': 'İleri Şanzıman & Diferansiyel', 'ikon': Icons.settings_applications_outlined},
    {'isim': 'Yazılım, Tuning & Diagnostik', 'ikon': Icons.memory_outlined},
    {'isim': 'Elektrik, Beyin & İmmobilizer', 'ikon': Icons.electrical_services_outlined},
    {'isim': 'Kaynak (Argon & Alüminyum)', 'ikon': Icons.hardware_outlined},
    {'isim': 'Kaporta & Boya', 'ikon': Icons.format_paint_outlined},
    {'isim': 'Rulman, Keçe & Oring', 'ikon': Icons.radio_button_unchecked_outlined},
    {'isim': 'Radyatör & İntercooler', 'ikon': Icons.severe_cold_outlined},
    {'isim': 'Hidrolik & Direksiyon Kutusu', 'ikon': Icons.settings_input_component_outlined},
    {'isim': 'Kilit, Cam & Sunroof', 'ikon': Icons.lock_outline},
  ];

  // =========================================================================
  // 🏢 KURUMSAL FİRMA VE NİŞ USTA VERİTABANI
  // =========================================================================
  final List<Map<String, dynamic>> _firmalar = [
    {
      'isim': 'OtoDNA Türkiye Merkez Distribütörlüğü',
      'kategori': 'Distribütör & Ana Bayi',
      'il': 'Ankara',
      'ilce': 'Yenimahalle',
      'puan': 5,
      'uzmanlik': ['Merkez Yönetim', 'Lisanslama'],
      'mesafe': '0.0 km',
      'onayli': true,
    },
    {
      'isim': 'Hassas Motor Rektefiye ve Torna',
      'kategori': 'Motor Rektefiye & Torna',
      'il': 'Ankara',
      'ilce': 'Ostim',
      'puan': 5,
      'uzmanlik': ['Silindir Kapak Taşlama', 'Gömlek Çakma', 'Krank Taşlama'],
      'mesafe': '12.4 km',
      'onayli': true,
    },
    {
      'isim': 'Şanzıman Vadisi Otomatik Revizyon',
      'kategori': 'İleri Şanzıman & Diferansiyel',
      'il': 'Ankara',
      'ilce': 'Şaşmaz Oto Sanayi',
      'puan': 4,
      'uzmanlik': ['Tork Konvertörü', 'Valf Gövdesi (Beyin)', 'Diferansiyel Ötme'],
      'mesafe': '8.2 km',
      'onayli': true,
    },
    {
      'isim': 'Siber Chip Tuning & Remapping',
      'kategori': 'Yazılım, Tuning & Diagnostik',
      'il': 'Ankara',
      'ilce': 'İvedik OSB',
      'puan': 5,
      'uzmanlik': ['Stage 1-2-3', 'EGR/DPF/AdBlue Çözümü', 'Can-bus Analizi'],
      'mesafe': '15.1 km',
      'onayli': true,
    },
    {
      'isim': 'Merkez Rulman ve Keçe',
      'kategori': 'Rulman, Keçe & Oring',
      'il': 'Ankara',
      'ilce': 'Ostim',
      'puan': 3,
      'uzmanlik': ['Teker Bilyası', 'Viton / NBR', 'Şanzıman Keçesi'],
      'mesafe': '14.5 km',
      'onayli': true,
    },
    {
      'isim': 'Garantili Argon & Alüminyum Kaynak',
      'kategori': 'Kaynak (Argon & Alüminyum)',
      'il': 'Ankara',
      'ilce': 'Şaşmaz',
      'puan': 4,
      'uzmanlik': ['Çatlak Motor Bloğu', 'Jant Kaynağı', 'Şanzıman Muhafazası'],
      'mesafe': '9.0 km',
      'onayli': true,
    },
    {
      'isim': 'Korsan Gösterge ve Elektronik',
      'kategori': 'Elektrik, Beyin & İmmobilizer',
      'il': 'Ankara',
      'ilce': 'İskitler',
      'puan': 1, // KARA LİSTE
      'uzmanlik': ['KM Düşürme (İllegal)', 'İmmobilizer İptali'],
      'mesafe': '5.5 km',
      'onayli': false,
    },
  ];

  // =========================================================================
  // 🎖️ KURUMSAL ROZET ALGORİTMASI
  // =========================================================================
  Widget _buildFirmaRozeti(int puan) {
    if (puan == 5) {
      return _rozetTasarimi(Icons.workspace_premium_outlined, Colors.amber.shade700, "ALTIN YILDIZ");
    } else if (puan == 4) {
      return _rozetTasarimi(Icons.workspace_premium_outlined, Colors.blueGrey.shade400, "GÜMÜŞ YILDIZ");
    } else if (puan == 3) {
      return _rozetTasarimi(Icons.workspace_premium_outlined, Colors.brown.shade400, "BRONZ YILDIZ");
    } else if (puan == 2) {
      return _rozetTasarimi(Icons.info_outline, primaryTeal, "ONAYLI İŞLETME");
    } else {
      // 1 Yıldız: Kara Liste Sistemi (Kırmızı Uyarı)
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: dangerColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: dangerColor.withValues(alpha: 0.5))),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, color: dangerColor, size: 14),
            const SizedBox(width: 6),
            Text("KARA LİSTE", style: TextStyle(color: dangerColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
          ],
        ),
      );
    }
  }

  Widget _rozetTasarimi(IconData ikon, Color renk, String metin) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: renk.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: renk.withValues(alpha: 0.5))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikon, color: renk, size: 14),
          const SizedBox(width: 6),
          Text(metin, style: TextStyle(color: renk, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filtrelenmisFirmalar = _firmalar.where((firma) {
      bool kategoriUyuyor = _secilenKategori == 'Tümü' || firma['kategori'] == _secilenKategori;
      bool aramaUyuyor = firma['isim'].toString().toLowerCase().contains(_aramaMetni.toLowerCase()) ||
          firma['uzmanlik'].toString().toLowerCase().contains(_aramaMetni.toLowerCase());
      return kategoriUyuyor && aramaUyuyor;
    }).toList();

    filtrelenmisFirmalar.sort((a, b) => b['puan'].compareTo(a['puan']));

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
          title: Text('Hizmet Ağı & Firmalar', style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5, fontFamily: 'Avenir')),
          centerTitle: true,
          actions: [
            IconButton(icon: Icon(Icons.map_outlined, color: primaryTeal, size: 22), onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Plaza Haritası Yükleniyor...'), backgroundColor: primaryTeal));
            })
          ],
        ),
        body: Column(
          children: [
            // =========================================================================
            // MİNİMALİST ARAMA ÇUBUĞU
            // =========================================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(16), 
                  border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)]
                ),
                child: TextField(
                  style: TextStyle(color: textColor, fontSize: 14, fontFamily: 'Avenir', fontWeight: FontWeight.bold),
                  onChanged: (val) => setState(() => _aramaMetni = val),
                  decoration: InputDecoration(
                      hintText: 'Firma, Usta veya Uzmanlık Ara...',
                      hintStyle: const TextStyle(color: Colors.black38, fontSize: 13, fontFamily: 'Avenir'),
                      prefixIcon: Icon(Icons.search, color: primaryTeal, size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16)
                  ),
                ),
              ),
            ),

            // =========================================================================
            // YATAY KATEGORİ KAYDIRICISI
            // =========================================================================
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _kategoriler.length,
                itemBuilder: (context, index) {
                  var kat = _kategoriler[index];
                  bool isSelected = _secilenKategori == kat['isim'];
                  return GestureDetector(
                    onTap: () => setState(() => _secilenKategori = kat['isim']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryTeal : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSelected ? primaryTeal : Colors.black.withValues(alpha: 0.05)),
                        boxShadow: [
                          if (isSelected) BoxShadow(color: primaryTeal.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))
                          else BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5)
                        ]
                      ),
                      child: Row(
                        children: [
                          Icon(kat['ikon'], color: isSelected ? Colors.white : Colors.black54, size: 16),
                          const SizedBox(width: 8),
                          Text(kat['isim'], style: TextStyle(color: isSelected ? Colors.white : textColor, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'Avenir')),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Divider(color: Colors.black.withValues(alpha: 0.05)),

            // =========================================================================
            // FİRMA LİSTESİ (Plaza Kalitesi Kartlar)
            // =========================================================================
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: filtrelenmisFirmalar.length,
                itemBuilder: (context, index) {
                  var firma = filtrelenmisFirmalar[index];
                  bool isKaraListe = firma['puan'] == 1;

                  return Opacity(
                    opacity: isKaraListe ? 0.6 : 1.0,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: firma['kategori'] == 'Distribütör & Ana Bayi' 
                            ? primaryTeal.withValues(alpha: 0.5) 
                            : Colors.black.withValues(alpha: 0.05),
                          width: firma['kategori'] == 'Distribütör & Ana Bayi' ? 2.0 : 1.0
                        ),
                        boxShadow: [
                          if(firma['kategori'] == 'Distribütör & Ana Bayi')
                             BoxShadow(color: primaryTeal.withValues(alpha: 0.05), blurRadius: 15, spreadRadius: 2)
                          else
                             BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)
                        ]
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Logo Alanı (Yuvarlak)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isKaraListe ? dangerColor.withValues(alpha: 0.1) : primaryTeal.withValues(alpha: 0.1),
                                    shape: BoxShape.circle
                                  ),
                                  child: Icon(isKaraListe ? Icons.warning_amber_rounded : Icons.business_outlined, color: isKaraListe ? dangerColor : primaryTeal, size: 28)
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(child: Text(firma['kategori'].toUpperCase(), overflow: TextOverflow.ellipsis, style: TextStyle(color: isKaraListe ? dangerColor : primaryTeal, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir'))),
                                          if (firma['onayli']) Icon(Icons.verified, color: primaryTeal, size: 16),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(firma['isim'], style: TextStyle(color: isKaraListe ? dangerColor : textColor, fontSize: 16, fontWeight: FontWeight.w900, decoration: isKaraListe ? TextDecoration.lineThrough : TextDecoration.none, fontFamily: 'Avenir')),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on_outlined, color: Colors.black38, size: 14),
                                          const SizedBox(width: 4),
                                          Text("${firma['ilce']} / ${firma['il']} (${firma['mesafe']})", style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Uzmanlık Alanları ve Rozet
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Wrap(
                                    spacing: 6, runSpacing: 6,
                                    children: (firma['uzmanlik'] as List<String>).map((uzmanlik) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(6)),
                                        child: Text(uzmanlik, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _buildFirmaRozeti(firma['puan']),
                              ],
                            ),

                            // Kara Liste Uyarısı veya Randevu Butonu
                            if (isKaraListe) ...[
                              const SizedBox(height: 20),
                              Container(
                                width: double.infinity, padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: dangerColor.withValues(alpha: 0.5)), color: dangerColor.withValues(alpha: 0.05)),
                                child: Text("KARA LİSTE UYARISI: Bu firma OtoDNA standartlarına uymadığı veya müşteri şikayeti aldığı için ağdan izole edilmiştir. Randevu oluşturulamaz.", textAlign: TextAlign.center, style: TextStyle(color: dangerColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5, height: 1.5, fontFamily: 'Avenir')),
                              )
                            ] else ...[
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  // Yol Tarifi (Şık İkon Buton)
                                  InkWell(
                                    onTap: () {},
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      decoration: BoxDecoration(border: Border.all(color: Colors.black.withValues(alpha: 0.1)), borderRadius: BorderRadius.circular(12)),
                                      child: Row(
                                        children: [
                                          Icon(Icons.directions, size: 16, color: textColor),
                                          const SizedBox(width: 6),
                                          Text("Yol Tarifi", style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                                        ]
                                      )
                                    ),
                                  ),
                                  const Spacer(),
                                  // Randevu Al (Vurgulu Buton)
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryTeal,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
                                    ),
                                    onPressed: () { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${firma['isim']} için Dijital Randevu Talebi İletiliyor...'), backgroundColor: primaryTeal)); },
                                    child: const Text("Randevu Al", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, fontFamily: 'Avenir')),
                                  ),
                                ],
                              )
                            ]
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}