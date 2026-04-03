import 'package:flutter/material.dart';

class IkinciElIlanDetayScreen extends StatefulWidget {
  final Map<String, dynamic> ilan;

  const IkinciElIlanDetayScreen({super.key, required this.ilan});

  @override
  State<IkinciElIlanDetayScreen> createState() => _IkinciElIlanDetayScreenState();
}

class _IkinciElIlanDetayScreenState extends State<IkinciElIlanDetayScreen> {
  final Map<String, int> _okunanParcaDurumlari = {
    'Ön Tampon': 1, 'Kaput': 2, 'Sağ Ön Çamurluk': 1, 'Sol Ön Çamurluk': 0,
    'Sağ Ön Kapı': 0, 'Sol Ön Kapı': 0, 'Tavan': 0,
    'Sağ Arka Kapı': 0, 'Sol Arka Kapı': 0,
    'Sağ Arka Çamurluk': 0, 'Sol Arka Çamurluk': 0,
    'Bagaj': 0, 'Arka Tampon': 0,
  };

  Color _getParcaRenk(String parca) {
    int durum = _okunanParcaDurumlari[parca] ?? 0;
    if (durum == 0) return Colors.white.withOpacity(0.03); // Orijinal Parça Rengi (Ultra Sade)
    if (durum == 1) return Colors.orangeAccent.withOpacity(0.8);
    return Colors.redAccent.withOpacity(0.9);
  }

  Widget _buildSaticiRozeti(int puan, String saticiAdi) {
    Color rozetRengi;
    IconData ikon = Icons.star;
    String rozetMetni;

    if (puan == 5) { rozetRengi = Colors.amber; rozetMetni = "Altın Rozetli Bayi"; }
    else if (puan == 4) { rozetRengi = Colors.grey[300]!; rozetMetni = "Gümüş Rozetli Bayi"; }
    else if (puan == 3) { rozetRengi = Colors.brown[300]!; rozetMetni = "Bronz Rozetli Bayi"; }
    else if (puan == 2) {
      return Row(children: [const Icon(Icons.star_border, color: Colors.white38, size: 16), const SizedBox(width: 8), Text(saticiAdi, style: const TextStyle(color: Colors.white70, fontSize: 14))]);
    } else {
      return Row(children: [const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 16), const SizedBox(width: 8), Text("$saticiAdi (Kara Liste)", style: const TextStyle(color: Colors.redAccent, fontSize: 14, decoration: TextDecoration.lineThrough))]);
    }

    return Row(
      children: [
        Icon(ikon, color: rozetRengi, size: 20),
        const SizedBox(width: 8),
        Text(saticiAdi, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(width: 12),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: rozetRengi.withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: rozetRengi.withOpacity(0.3))), child: Text(rozetMetni, style: TextStyle(color: rozetRengi, fontSize: 10, fontWeight: FontWeight.bold))),
      ],
    );
  }

  // =======================================================================
  // YENİ TİCARİ MODEL: KAPORA VE REZERVASYON SİSTEMİ (Tesla Pop-up Style)
  // =======================================================================
  void _kaporaSistemiAc(String fiyatStr) {
    const String kaporaBedeli = "10.000 TL";

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: const BorderRadius.vertical(top: Radius.circular(32)), border: Border.all(color: Colors.white.withOpacity(0.1))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 32),
            const Row(children: [Icon(Icons.lock_clock_outlined, color: Color(0xFF00FFC2), size: 28), SizedBox(width: 12), Text("Rezervasyon", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.5))]),
            const SizedBox(height: 16),
            const Text("Bu aracı sizin adınıza ayırtmak ve satıcının doğrudan iletişim bilgilerine erişmek için Kuantum Havuzuna kapora yatırmanız gerekmektedir.", style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5)),
            const SizedBox(height: 32),

            // ÜCRET KUTUSU (Minimalist)
            Container(
              padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF000000), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("İlan Satış Fiyatı", style: TextStyle(color: Colors.white54, fontSize: 14)), Text("₺$fiyatStr", style: const TextStyle(color: Colors.white54, fontSize: 14, decoration: TextDecoration.lineThrough))]),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 16.0), child: Divider(color: Colors.white12, height: 1)),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Kapora Bedeli", style: TextStyle(color: Color(0xFF00FFC2), fontSize: 15, fontWeight: FontWeight.bold)), Text(kaporaBedeli, style: const TextStyle(color: Color(0xFF00FFC2), fontSize: 18, fontWeight: FontWeight.bold))]),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // SİBER SORUMLULUK REDDİ BEYANI
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.redAccent.withOpacity(0.2))),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                  SizedBox(width: 12),
                  Expanded(child: Text("OtoDNA üzerinden kapora yatırılmadan yapılan harici elden ticaretlerde sorumluluk kabul edilmez.", style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.5))),
                ],
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FFC2), foregroundColor: Colors.black, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kapora Ödendi! Satıcı İletişim Bilgileri Açıldı. ✅'), backgroundColor: Colors.green));
                },
                child: Text("$kaporaBedeli YATIR VE REZERVE ET", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.5)),
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
    // 🌑 TESLA / OLED SİYAHI PALET
    const bgColor = Color(0xFF000000);
    const primaryCyan = Color(0xFF00FFC2);
    const cardColor = Color(0xFF111111);
    const textMuted = Colors.white54;

    bool havuzVarMi = widget.ilan['havuz_uygun'] ?? false;
    bool karaListeMi = widget.ilan['puan'] == 1;
    String ilanFiyati = widget.ilan['fiyat'] ?? '0 TL';

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            backgroundColor: bgColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.ios_share, color: Colors.white, size: 20), onPressed: () {}),
              IconButton(icon: const Icon(Icons.favorite_border, color: Colors.white, size: 20), onPressed: () {}),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: cardColor, // Kapak Fotoğrafı Arka Planı
                child: Center(
                  // Burada devasa şeffaf bir ikon kullanıyoruz
                  child: Icon(widget.ilan['gorsel_ikon'] ?? Icons.directions_car_outlined, size: 140, color: Colors.white.withOpacity(0.03)),
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
                  Text(widget.ilan['baslik'] ?? 'İlan Başlığı', style: TextStyle(color: karaListeMi ? Colors.redAccent : Colors.white, fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.5, decoration: karaListeMi ? TextDecoration.lineThrough : TextDecoration.none)),
                  const SizedBox(height: 8),
                  Text(ilanFiyati, style: const TextStyle(color: primaryCyan, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1)),
                  const SizedBox(height: 32),

                  // SATICI ROZETİ (Minimalist)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
                    child: _buildSaticiRozeti(widget.ilan['puan'] ?? 3, widget.ilan['satici'] ?? 'Bilinmeyen Satıcı'),
                  ),
                  const SizedBox(height: 32),

                  // TEKNİK DETAYLAR (İnce Çizgili Kutu Formatı)
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
                  const Text("Siber Ekspertiz Şeması", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.5)),
                  const SizedBox(height: 16),

                  // EKSPERTİZ ÇİZİMİ (Araç Kuşbakışı)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
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

                        // RENK LEJANDI (Sade)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.circle, color: Colors.white.withOpacity(0.1), size: 12), const SizedBox(width: 6), const Text("Orijinal", style: TextStyle(color: textMuted, fontSize: 12)), const SizedBox(width: 16),
                            const Icon(Icons.circle, color: Colors.orangeAccent, size: 12), const SizedBox(width: 6), const Text("Boyalı", style: TextStyle(color: textMuted, fontSize: 12)), const SizedBox(width: 16),
                            const Icon(Icons.circle, color: Colors.redAccent, size: 12), const SizedBox(width: 6), const Text("Değişmiş", style: TextStyle(color: textMuted, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // SATICI AÇIKLAMASI
                  const Text("Satıcı Açıklaması", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.5)),
                  const SizedBox(height: 16),
                  const Text(
                    "Araç tamamen yetkili servis bakımlıdır. Sağ ön çamurluk sürtmeden kaynaklı boyalıdır, kaput ise bayide orijinaliyle değişmiştir. Haricinde hatasızdır.",
                    style: TextStyle(color: textMuted, height: 1.6, fontSize: 14),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),

      // =======================================================================
      // ALT AKSİYON MENÜSÜ (Düz, Siyah ve Minimal)
      // =======================================================================
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
            color: bgColor,
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05)))
        ),
        child: SafeArea(
          child: Row(
            children: [
              // CHAT BUTONU
              Container(
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.1))),
                child: IconButton(
                  icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 24),
                  onPressed: () {
                    if (karaListeMi) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Satıcıya Mesaj Penceresi Açılıyor...')));
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
                      backgroundColor: havuzVarMi && !karaListeMi ? primaryCyan : const Color(0xFF222222),
                      foregroundColor: havuzVarMi && !karaListeMi ? Colors.black : Colors.white54,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      if (!havuzVarMi || karaListeMi) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bu ilan OtoDNA Güvencesine kapalıdır!'), backgroundColor: Colors.redAccent));
                        return;
                      }
                      _kaporaSistemiAc(ilanFiyati);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(havuzVarMi ? Icons.lock_clock_outlined : Icons.gpp_bad_outlined, size: 20),
                        const SizedBox(width: 8),
                        Text(havuzVarMi ? "KAPORA İLE REZERVE ET" : "GÜVENCESİZ İLAN", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // 💎 TESLA MİMARİSİ: İNCE DETAY KUTUSU
  Widget _buildDetayKutusu(IconData ikon, String baslik, String deger, Color cardColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Row(
        children: [
          Icon(ikon, color: Colors.white54, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(baslik, style: const TextStyle(color: Colors.white38, fontSize: 11)), const SizedBox(height: 2), Text(deger, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))])),
        ],
      ),
    );
  }

  // 💎 TESLA MİMARİSİ: İNCE ÇİZGİLİ ARABA ŞEMASI
  Widget _buildAracParcasi(String parcaAdi, double genislik, double yukseklik, BorderRadius kavis) {
    return Container(
      width: genislik, height: yukseklik,
      decoration: BoxDecoration(
        color: _getParcaRenk(parcaAdi),
        borderRadius: kavis,
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1), // İnce Çerçeve
      ),
      child: Center(
        child: Text(
          parcaAdi.replaceAll(" Çamurluk", "\nÇamurluk").replaceAll(" Kapı", "\nKapı"),
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 9, fontWeight: FontWeight.bold),
        ),q
      ),
    );
  }
}