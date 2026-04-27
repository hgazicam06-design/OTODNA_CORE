import 'package:flutter/material.dart';

import '../../core/responsive_kalkan.dart';

class IkinciElIlanDetayScreen extends StatefulWidget {
  final Map<String, dynamic> ilan;

  const IkinciElIlanDetayScreen({super.key, required this.ilan});

  @override
  State<IkinciElIlanDetayScreen> createState() => _IkinciElIlanDetayScreenState();
}

class _IkinciElIlanDetayScreenState extends State<IkinciElIlanDetayScreen> {
  // 🏢 PLAZA KALİTESİ PALET
  final Color primaryTeal = Colors.teal.shade700;
  final Color bgColor = const Color(0xFFFAFAFC);
  final Color textColor = const Color(0xFF1E293B);
  final Color cardColor = Colors.white;
  final Color dangerColor = Colors.redAccent;
  final Color warningColor = Colors.orange;

  final Map<String, int> _okunanParcaDurumlari = {
    'Ön Tampon': 1, 'Kaput': 2, 'Sağ Ön Çamurluk': 1, 'Sol Ön Çamurluk': 0,
    'Sağ Ön Kapı': 0, 'Sol Ön Kapı': 0, 'Tavan': 0,
    'Sağ Arka Kapı': 0, 'Sol Arka Kapı': 0,
    'Sağ Arka Çamurluk': 0, 'Sol Arka Çamurluk': 0,
    'Bagaj': 0, 'Arka Tampon': 0,
  };

  Color _getParcaRenk(String parca) {
    int durum = _okunanParcaDurumlari[parca] ?? 0;
    if (durum == 0) return primaryTeal.withValues(alpha: 0.1); // Orijinal Parça
    if (durum == 1) return warningColor.withValues(alpha: 0.8); // Boyalı
    return dangerColor.withValues(alpha: 0.9); // Değişen
  }
  
  Color _getParcaTextRenk(String parca) {
    int durum = _okunanParcaDurumlari[parca] ?? 0;
    if (durum == 0) return primaryTeal;
    return Colors.white;
  }

  Widget _buildSaticiRozeti(int puan, String saticiAdi) {
    Color rozetRengi;
    IconData ikon = Icons.star;
    String rozetMetni;

    if (puan == 5) { rozetRengi = Colors.amber.shade700; rozetMetni = "Altın Rozetli Bayi"; }
    else if (puan == 4) { rozetRengi = Colors.blueGrey.shade400; rozetMetni = "Gümüş Rozetli Bayi"; }
    else if (puan == 3) { rozetRengi = Colors.brown.shade400; rozetMetni = "Bronz Rozetli Bayi"; }
    else if (puan == 2) {
      return Row(children: [const Icon(Icons.star_border, color: Colors.white38, size: 16), const SizedBox(width: 8), Text(saticiAdi, style: TextStyle(color: textColor, fontSize: 14, fontFamily: 'Avenir', fontWeight: FontWeight.bold))]);
    } else {
      return Row(children: [Icon(Icons.warning_amber_rounded, color: dangerColor, size: 16), const SizedBox(width: 8), Text("$saticiAdi (Kara Liste)", style: TextStyle(color: dangerColor, fontSize: 14, decoration: TextDecoration.lineThrough, fontFamily: 'Avenir', fontWeight: FontWeight.bold))]);
    }

    return Row(
      children: [
        Icon(ikon, color: rozetRengi, size: 20),
        const SizedBox(width: 8),
        Text(saticiAdi, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
        const SizedBox(width: 12),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: rozetRengi.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: rozetRengi.withValues(alpha: 0.5))), child: Text(rozetMetni, style: TextStyle(color: rozetRengi, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Avenir'))),
      ],
    );
  }

  // =======================================================================
  // PLAZA REZERVASYON SİSTEMİ
  // =======================================================================
  void _kaporaSistemiAc(String fiyatStr) {
    const String kaporaBedeli = "10.000 TL";

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(32)), boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.1), blurRadius: 20)]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 32),
            Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: primaryTeal.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(Icons.lock_clock_outlined, color: primaryTeal, size: 24)), const SizedBox(width: 16), Text("Araç Rezervasyonu", style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Avenir'))]),
            const SizedBox(height: 16),
            const Text("Bu aracı sizin adınıza ayırtmak ve satıcının doğrudan iletişim bilgilerine erişmek için OtoDNA Havuzuna kapora yatırmanız gerekmektedir.", style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
            const SizedBox(height: 32),

            // ÜCRET KUTUSU
            Container(
              padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("İlan Satış Fiyatı", style: TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Avenir')), Text("₺$fiyatStr", style: const TextStyle(color: Colors.white38, fontSize: 14, decoration: TextDecoration.lineThrough, fontWeight: FontWeight.bold, fontFamily: 'Avenir'))]),
                  Padding(padding: const EdgeInsets.symmetric(vertical: 16.0), child: Divider(color: Colors.white.withValues(alpha: 0.05), height: 1)),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Kapora Bedeli", style: TextStyle(color: primaryTeal, fontSize: 15, fontWeight: FontWeight.w900, fontFamily: 'Avenir')), Text(kaporaBedeli, style: TextStyle(color: primaryTeal, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Avenir'))]),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // SORUMLULUK REDDİ BEYANI
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: dangerColor.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: dangerColor.withValues(alpha: 0.2))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, color: dangerColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text("OtoDNA üzerinden kapora yatırılmadan yapılan harici elden ticaretlerde sorumluluk kabul edilmez.", style: TextStyle(color: dangerColor, fontSize: 11, height: 1.5, fontWeight: FontWeight.bold, fontFamily: 'Avenir'))),
                ],
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Kapora Ödendi! Satıcı İletişim Bilgileri Açıldı. ✅', style: TextStyle(fontFamily: 'Avenir', fontWeight: FontWeight.bold)), backgroundColor: primaryTeal));
                },
                child: Text("$kaporaBedeli YATIR VE REZERVE ET", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5, fontFamily: 'Avenir')),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool havuzVarMi = widget.ilan['havuz_uygun'] ?? false;
    bool karaListeMi = widget.ilan['puan'] == 1;
    String ilanFiyati = widget.ilan['fiyat'] ?? '0 TL';

    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: bgColor,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 300.0,
              floating: false,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: primaryTeal, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(icon: Icon(Icons.ios_share, color: primaryTeal, size: 20), onPressed: () {}),
                IconButton(icon: Icon(Icons.favorite_border, color: primaryTeal, size: 20), onPressed: () {}),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)))
                  ),
                  child: Center(
                    child: Icon(widget.ilan['gorsel_ikon'] ?? Icons.directions_car_outlined, size: 140, color: Colors.white.withValues(alpha: 0.03)),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.ilan['baslik'] ?? 'İlan Başlığı', style: TextStyle(color: karaListeMi ? dangerColor : textColor, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5, decoration: karaListeMi ? TextDecoration.lineThrough : TextDecoration.none, fontFamily: 'Avenir')),
                    const SizedBox(height: 8),
                    Text(ilanFiyati, style: TextStyle(color: primaryTeal, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1, fontFamily: 'Avenir')),
                    const SizedBox(height: 32),

                    // SATICI ROZETİ
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 10)]),
                      child: _buildSaticiRozeti(widget.ilan['puan'] ?? 3, widget.ilan['satici'] ?? 'Bilinmeyen Satıcı'),
                    ),
                    const SizedBox(height: 32),

                    // TEKNİK DETAYLAR
                    GridView.count(
                      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, childAspectRatio: 2.5, crossAxisSpacing: 16, mainAxisSpacing: 16,
                      children: [
                        _buildDetayKutusu(Icons.calendar_month_outlined, "Yıl", "2022", cardColor),
                        _buildDetayKutusu(Icons.speed_outlined, "Kilometre", "45.000 KM", cardColor),
                        _buildDetayKutusu(Icons.settings_outlined, "Vites", "Otomatik", cardColor),
                        _buildDetayKutusu(Icons.local_gas_station_outlined, "Yakıt", "Elektrik", cardColor),
                      ],
                    ),
                    const SizedBox(height: 48),

                    // EKSPERTİZ BAŞLIĞI
                    Text("Plaza Ekspertiz Şeması", style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Avenir')),
                    const SizedBox(height: 16),

                    // EKSPERTİZ ÇİZİMİ (Araç Kuşbakışı)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 15)]),
                      child: Column(
                        children: [
                          _buildAracParcasi("Ön Tampon", 140, 30, const BorderRadius.vertical(top: Radius.circular(30))),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildAracParcasi("Sol Ön Çamurluk", 35, 80, const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(5))),
                              const SizedBox(width: 4),
                              _buildAracParcasi("Kaput", 100, 80, BorderRadius.circular(8)),
                              const SizedBox(width: 4),
                              _buildAracParcasi("Sağ Ön Çamurluk", 35, 80, const BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(5))),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildAracParcasi("Sol Ön Kapı", 35, 70, BorderRadius.circular(4)),
                              const SizedBox(width: 4),
                              _buildAracParcasi("Tavan", 100, 145, BorderRadius.circular(12)),
                              const SizedBox(width: 4),
                              _buildAracParcasi("Sağ Ön Kapı", 35, 70, BorderRadius.circular(4)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildAracParcasi("Sol Arka Kapı", 35, 70, BorderRadius.circular(4)),
                              const SizedBox(width: 108), // Tavan genisliği + bosluklar
                              _buildAracParcasi("Sağ Arka Kapı", 35, 70, BorderRadius.circular(4)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildAracParcasi("Sol Arka Çamurluk", 35, 80, const BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(20))),
                              const SizedBox(width: 4),
                              _buildAracParcasi("Bagaj", 100, 80, BorderRadius.circular(8)),
                              const SizedBox(width: 4),
                              _buildAracParcasi("Sağ Arka Çamurluk", 35, 80, const BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(20))),
                            ],
                          ),
                          const SizedBox(height: 4),
                          _buildAracParcasi("Arka Tampon", 140, 30, const BorderRadius.vertical(bottom: Radius.circular(30))),

                          const SizedBox(height: 32),

                          // RENK LEJANDI
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.circle, color: primaryTeal.withValues(alpha: 0.2), size: 12), const SizedBox(width: 6), const Text("Orijinal", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')), const SizedBox(width: 16),
                              Icon(Icons.circle, color: warningColor, size: 12), const SizedBox(width: 6), const Text("Boyalı", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')), const SizedBox(width: 16),
                              Icon(Icons.circle, color: dangerColor, size: 12), const SizedBox(width: 6), const Text("Değişmiş", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // SATICI AÇIKLAMASI
                    Text("Satıcı Açıklaması", style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Avenir')),
                    const SizedBox(height: 16),
                    const Text(
                      "Araç tamamen yetkili servis bakımlıdır. Sağ ön çamurluk sürtmeden kaynaklı boyalıdır, kaput ise bayide orijinaliyle değişmiştir. Haricinde hatasızdır.",
                      style: TextStyle(color: Colors.white54, height: 1.6, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),

        // =======================================================================
        // ALT AKSİYON MENÜSÜ
        // =======================================================================
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
              boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, -5))]
          ),
          child: SafeArea(
            child: Row(
              children: [
                // CHAT BUTONU
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
                  child: IconButton(
                    icon: Icon(Icons.chat_bubble_outline, color: textColor, size: 24),
                    onPressed: () {
                      if (karaListeMi) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Satıcıya Mesaj Penceresi Açılıyor...', style: TextStyle(fontFamily: 'Avenir', fontWeight: FontWeight.bold)), backgroundColor: primaryTeal));
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // REZERVE BUTONU
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: havuzVarMi && !karaListeMi ? primaryTeal : Colors.black12,
                        foregroundColor: havuzVarMi && !karaListeMi ? Colors.white : Colors.black38,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (!havuzVarMi || karaListeMi) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bu ilan OtoDNA Güvencesine kapalıdır!', style: TextStyle(fontFamily: 'Avenir', fontWeight: FontWeight.bold)), backgroundColor: Colors.redAccent));
                          return;
                        }
                        _kaporaSistemiAc(ilanFiyati);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(havuzVarMi ? Icons.lock_clock_outlined : Icons.gpp_bad_outlined, size: 20),
                          const SizedBox(width: 8),
                          Text(havuzVarMi ? "KAPORA İLE REZERVE ET" : "GÜVENCESİZ İLAN", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5, fontFamily: 'Avenir')),
                        ],
                      ),
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

  // 💎 PLAZA MİMARİSİ: İNCE DETAY KUTUSU
  Widget _buildDetayKutusu(IconData ikon, String baslik, String deger, Color cardColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 5)]),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.teal.shade700.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(ikon, color: Colors.teal.shade700, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(baslik, style: const TextStyle(color: Colors.white45, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Avenir')), const SizedBox(height: 2), Text(deger, style: TextStyle(color: const Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.w900, fontFamily: 'Avenir'))])),
        ],
      ),
    );
  }

  // 💎 PLAZA MİMARİSİ: İNCE ÇİZGİLİ ARABA ŞEMASI
  Widget _buildAracParcasi(String parcaAdi, double genislik, double yukseklik, BorderRadius kavis) {
    return Container(
      width: genislik, height: yukseklik,
      decoration: BoxDecoration(
        color: _getParcaRenk(parcaAdi),
        borderRadius: kavis,
        border: Border.all(color: Colors.white, width: 2), // Parçalar arası ayırıcı beyaz çizgi
      ),
      child: Center(
        child: Text(
          parcaAdi.replaceAll(" Çamurluk", "\nÇamurluk").replaceAll(" Kapı", "\nKapı"),
          textAlign: TextAlign.center,
          style: TextStyle(color: _getParcaTextRenk(parcaAdi), fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
        ),
      ),
    );
  }
}