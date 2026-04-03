import 'package:flutter/material.dart';

class FirmalarScreen extends StatefulWidget {
  const FirmalarScreen({super.key});

  @override
  State<FirmalarScreen> createState() => _FirmalarScreenState();
}

class _FirmalarScreenState extends State<FirmalarScreen> {
  String _secilenKategori = 'Tümü';
  String _aramaMetni = '';

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
  // 🏢 SİBER FİRMA VE NİŞ USTA VERİTABANI
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
  // 🎖️ ULTRA-MİNİMALİST ROZET ALGORİTMASI (Renk blokları yok edildi)
  // =========================================================================
  Widget _buildFirmaRozeti(int puan) {
    if (puan == 5) {
      return _rozetTasarimi(Icons.workspace_premium_outlined, const Color(0xFF00FFC2), "ALTIN ROZET"); // Kuantum Turkuazı
    } else if (puan == 4) {
      return _rozetTasarimi(Icons.workspace_premium_outlined, Colors.white70, "GÜMÜŞ ROZET");
    } else if (puan == 3) {
      return _rozetTasarimi(Icons.workspace_premium_outlined, Colors.white38, "BRONZ ROZET");
    } else if (puan == 2) {
      return _rozetTasarimi(Icons.info_outline, Colors.white24, "STANDART");
    } else {
      // 1 Yıldız: Kara Liste Sistemi (Düz ve asil kırmızı)
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.redAccent.withOpacity(0.3))),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 14),
            SizedBox(width: 6),
            Text("KARA LİSTE", style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ],
        ),
      );
    }
  }

  Widget _rozetTasarimi(IconData ikon, Color renk, String metin) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(6), border: Border.all(color: renk.withOpacity(0.3))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikon, color: renk, size: 14),
          const SizedBox(width: 6),
          Text(metin, style: TextStyle(color: renk, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🌑 ULTRA-PREMIUM TASARIM DEĞİŞKENLERİ
    const bgColor = Color(0xFF000000);
    const surfaceColor = Color(0xFF111111);
    const primaryCyan = Color(0xFF00FFC2);

    List<Map<String, dynamic>> filtrelenmisFirmalar = _firmalar.where((firma) {
      bool kategoriUyuyor = _secilenKategori == 'Tümü' || firma['kategori'] == _secilenKategori;
      bool aramaUyuyor = firma['isim'].toString().toLowerCase().contains(_aramaMetni.toLowerCase()) ||
          firma['uzmanlik'].toString().toLowerCase().contains(_aramaMetni.toLowerCase());
      return kategoriUyuyor && aramaUyuyor;
    }).toList();

    filtrelenmisFirmalar.sort((a, b) => b['puan'].compareTo(a['puan']));

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('Hizmet Ağı & Firmalar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16, letterSpacing: 0.5)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.map_outlined, color: Colors.white54, size: 22), onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uydu Haritası Yükleniyor...')));
          })
        ],
      ),
      body: Column(
        children: [
          // =========================================================================
          // MİNİMALİST ARAMA ÇUBUĞU (Tesla Tarzı)
          // =========================================================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
              child: TextField(
                style: const TextStyle(color: Colors.white, fontSize: 14),
                onChanged: (val) => setState(() => _aramaMetni = val),
                decoration: const InputDecoration(
                    hintText: 'Firma, Usta veya Uzmanlık Ara...',
                    hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                    prefixIcon: Icon(Icons.search, color: Colors.white54, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14)
                ),
              ),
            ),
          ),

          // =========================================================================
          // YATAY KATEGORİ KAYDIRICISI (Buzlu Cam Mantığı, Çizgisiz Seçim)
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
                      color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent, // Seçili olan çok hafif beyaz oluyor
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? Colors.white24 : Colors.transparent),
                    ),
                    child: Row(
                      children: [
                        Icon(kat['ikon'], color: isSelected ? Colors.white : Colors.white38, size: 16),
                        const SizedBox(width: 8),
                        Text(kat['isim'], style: TextStyle(color: isSelected ? Colors.white : Colors.white38, fontWeight: FontWeight.w600, fontSize: 12)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Divider(color: Colors.white12)),

          // =========================================================================
          // FİRMA LİSTESİ (Çerçevesiz Flat Kartlar)
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
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      // Merkez bayiyi sadece çok hafif neon bir çerçeve ile ayırdık, gerisi düz renk
                      border: Border.all(color: firma['kategori'] == 'Distribütör & Ana Bayi' ? primaryCyan.withOpacity(0.3) : Colors.white.withOpacity(0.02)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // İnce Çizgili Firma İkonu
                              Icon(isKaraListe ? Icons.warning_amber_rounded : Icons.business_outlined, color: isKaraListe ? Colors.redAccent : Colors.white54, size: 28),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(child: Text(firma['kategori'].toUpperCase(), overflow: TextOverflow.ellipsis, style: TextStyle(color: isKaraListe ? Colors.redAccent : primaryCyan, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5))),
                                        if (firma['onayli']) const Icon(Icons.verified, color: primaryCyan, size: 14), // Mavi tiki de turkuaz (kurumsal) yaptık
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(firma['isim'], style: TextStyle(color: isKaraListe ? Colors.redAccent : Colors.white, fontSize: 16, fontWeight: FontWeight.bold, decoration: isKaraListe ? TextDecoration.lineThrough : TextDecoration.none)),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on_outlined, color: Colors.white38, size: 14),
                                        const SizedBox(width: 4),
                                        Text("${firma['ilce']} / ${firma['il']} (${firma['mesafe']})", style: const TextStyle(color: Colors.white54, fontSize: 12)),
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
                                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(6)), // İnce zarif tagler
                                      child: Text(uzmanlik, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w500)),
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
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.redAccent.withOpacity(0.5))),
                              child: const Text("KARA LİSTE UYARISI: Bu firma OtoDNA standartlarına uymadığı veya müşteri şikayeti aldığı için ağdan izole edilmiştir. Randevu oluşturulamaz.", textAlign: TextAlign.center, style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5, height: 1.5)),
                            )
                          ] else ...[
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                // Yol Tarifi (Sade Text Buton)
                                InkWell(
                                  onTap: () {},
                                  borderRadius: BorderRadius.circular(8),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    child: Text("Yol Tarifi", style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                                const Spacer(),
                                // Randevu Al (Tesla Tarzı Yarı Saydam Kutu Buton)
                                InkWell(
                                  onTap: () { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${firma['isim']} için Dijital Randevu Talebi İletiliyor...'), backgroundColor: const Color(0xFF111111))); },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                    child: const Text("Randevu Al", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                                  ),
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
    );
  }
}