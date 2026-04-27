import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';
import '../../widgets/siber_rehber_dialog.dart';
import '../../services/siber_lojistik_motoru.dart';

/// 🌪️ OTODNA ÇIĞIR (B2C YOLCU EKRANI)
/// Müşterinin 10 km çapındaki taksileri DNA skoruna ve şoför puanına göre
/// filtreleyip çağırdığı Kuantum Radar arayüzü.
class OtoDnaCigirScreen extends StatefulWidget {
  const OtoDnaCigirScreen({super.key});

  @override
  State<OtoDnaCigirScreen> createState() => _OtoDnaCigirScreenState();
}

class _OtoDnaCigirScreenState extends State<OtoDnaCigirScreen> {
  // 🏢 FİLDİŞİ SEDEF PALET
  final Color bgColor = const Color(0xFFFDFBF7);
  final Color surfaceColor = Colors.white;
  final Color primaryTeal = Colors.teal.shade700;
  final Color textMain = const Color(0xFF1E293B);
  final Color textMuted = const Color(0xFF64748B);
  final Color accentGold = Colors.amber.shade700;
  final Color dangerColor = SiberTema.kanKirmizi;

  bool _sadeceTemizDna = false;
  bool _radarTariyor = false;
  bool _hedefSecildi = false;
  String _seciliRota = "Hızlı Rota"; // Hızlı, Güvenli, Kestirme

  // ── YOLCU SADAKAT MOTORU ──
  final int _musteriYolcuPuani = 1500; // Örnek yolcu puanı (Kullandıkça artar)
  late double _dinamikIndirimOrani;

  // ── FİNANS MOTORU SİMÜLASYONU ──
  final double _odaAcilisUcreti = 30.0;
  final double _kmBasinaUcret = 20.0;
  final double _mesafeKm = 8.5; // Simüle edilmiş hedef mesafe
  
  double get _odaTarifesiFiyati => _odaAcilisUcreti + (_mesafeKm * _kmBasinaUcret);
  double get _otodnaIndirimi => _odaTarifesiFiyati * _dinamikIndirimOrani; // Dinamik İndirim
  double get _netMusteriFiyati => _odaTarifesiFiyati - _otodnaIndirimi;

  // ── SİBER İSTİHBARAT: LOJİSTİK MOTORU ──
  final SiberLojistikMotoru _lojistikMotoru = SiberLojistikMotoru();
  List<Map<String, dynamic>> _taksiListesi = [];

  @override
  void initState() {
    super.initState();
    _dinamikIndirimOrani = SiberLojistikMotoru.sadakatIndirimOraniHesapla(_musteriYolcuPuani);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _rehberiGoster(otomatik: true);
    });
    
    // Motor üzerinden yakın araçları dinliyoruz
    _lojistikMotoru.getYakindakiSoforler(41.0, 28.9).listen((liste) {
      if (mounted) {
        setState(() {
          _taksiListesi = liste;
        });
      }
    });
  }

  void _rehberiGoster({bool otomatik = false}) {
    const String baslik = "OTODNA ÇIĞIR (YOLCU RADARI)";
    const String icerik = "Siber Ulaşım Ağına Hoş Geldiniz.\n\n"
        "Bu ekran 5 KM çapındaki tüm OtoDNA onaylı araçları listeler. Sistem size gitmek istediğiniz yer için 3 farklı Yapay Zeka rotası sunar.\n\n"
        "Şoförle para pazarlığına girmezsiniz. Ekranda gördüğünüz fiyat (Odalar Tarifesi - %2 OtoDNA İndirimi) sabittir. Eğer şoför tarafından rahatsız edilirseniz, 'ENGELLE' butonuna basarak o aracı Kuantum Ağı'ndan silebilirsiniz.";

    if (otomatik) {
      SiberRehber.otomatikGoster(context: context, screenKey: 'cigir_yolcu_rehber', baslik: baslik, icerik: icerik);
    } else {
      SiberRehber.goster(context: context, screenKey: 'cigir_yolcu_rehber', baslik: baslik, icerik: icerik);
    }
  }

  void _siberUyari(String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: const TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
      backgroundColor: renk,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _taksiCagir(String plaka) async {
    setState(() => _radarTariyor = true);
    HapticFeedback.heavyImpact();
    
    _siberUyari("$plaka plakalı araca ÇIĞIR sinyali gönderildi! Yanıt bekleniyor...", primaryTeal);

    await Future.delayed(const Duration(seconds: 3)); // Simülasyon
    
    setState(() => _radarTariyor = false);
    _siberUyari("✅ ŞOFÖR ONAYLADI! Araç konumunuza doğru yola çıktı.", primaryTeal);
  }

  void _durakBaskaninaMesajAt(String durakAdi) {
    _siberUyari("$durakAdi Başkanına kriptolu mesaj kanalı açılıyor...", accentGold);
  }

  @override
  Widget build(BuildContext context) {
    // Filtreleme Algoritması
    List<Map<String, dynamic>> gosterilenAraclar = _taksiListesi;
    if (_sadeceTemizDna) {
      gosterilenAraclar = _taksiListesi.where((taksi) => taksi['dna_skoru'] >= 80).toList();
    }

    // Mesafe sırasına göre diz
    gosterilenAraclar.sort((a, b) => a['mesafe'].compareTo(b['mesafe']));

    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: primaryTeal, size: 20), onPressed: () => context.pop()),
          title: Text("OTODNA ÇIĞIR", style: TextStyle(color: primaryTeal, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2, fontFamily: 'Avenir')),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.help_outline_rounded, color: primaryTeal),
              tooltip: "Siber Rehber",
              onPressed: () => _rehberiGoster(otomatik: false),
            )
          ],
        ),
        body: Column(
          children: [
            // ── SİBER RADAR VE HEDEF ──
            _buildRadarPaneli(),

            if (_hedefSecildi) _buildAiRotaVeFinansPaneli(),

            // ── YAKINDAKİ ARAÇLAR ──
            Expanded(
              child: _radarTariyor 
                ? _buildRadarTaramaAnimasyonu()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: gosterilenAraclar.length,
                    itemBuilder: (context, index) {
                      return _buildTaksiKarti(gosterilenAraclar[index]);
                    },
                  ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRadarPaneli() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(bottom: BorderSide(color: primaryTeal, width: 2)),
        boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.05), blurRadius: 10)]
      ),
      child: Column(
        children: [
          // HEDEF SEÇİCİ
          InkWell(
            onTap: () => setState(() => _hedefSecildi = true),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: primaryTeal, size: 24),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Nereye Gideceksiniz?", style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                      Text(_hedefSecildi ? "Kadıköy Meydan (8.5 KM)" : "Konum Seçmek İçin Dokunun", style: TextStyle(color: textMain, fontSize: 14, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // FİLTRE: Sadece Temiz DNA Raporu
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _sadeceTemizDna = !_sadeceTemizDna);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _sadeceTemizDna ? primaryTeal.withOpacity(0.1) : surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _sadeceTemizDna ? primaryTeal : Colors.black.withOpacity(0.05)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_sadeceTemizDna ? Icons.health_and_safety : Icons.health_and_safety_outlined, color: _sadeceTemizDna ? primaryTeal : textMuted, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "SADECE DNA RAPORU TEMİZ ARAÇLAR", 
                    style: TextStyle(color: _sadeceTemizDna ? primaryTeal : textMuted, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAiRotaVeFinansPaneli() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: accentGold.withOpacity(0.5)), boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.05), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("KUANTUM A.I. ROTASI SEÇİN", style: TextStyle(color: accentGold, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildRotaSecenek("Hızlı Rota", Icons.speed, true)),
              const SizedBox(width: 8),
              Expanded(child: _buildRotaSecenek("Güvenli Rota", Icons.health_and_safety, false)),
              const SizedBox(width: 8),
              Expanded(child: _buildRotaSecenek("Kestirme", Icons.map, false)),
            ],
          ),
          Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.white.withOpacity(0.05))),
          
          // FİNANS ÖZETİ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Oda Tarifesi", style: TextStyle(color: textMuted, fontSize: 12)),
              Text("₺${_odaTarifesiFiyati.toStringAsFixed(2)}", style: TextStyle(color: textMuted, fontSize: 12, decoration: TextDecoration.lineThrough)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("%${(_dinamikIndirimOrani * 100).toStringAsFixed(1)} Yolcu Sadakat İndirimi", style: TextStyle(color: primaryTeal, fontSize: 12, fontWeight: FontWeight.bold)),
              Text("- ₺${_otodnaIndirimi.toStringAsFixed(2)}", style: TextStyle(color: primaryTeal, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("NET ÖDENECEK (KDV Dahil)", style: TextStyle(color: textMain, fontSize: 14, fontWeight: FontWeight.w900)),
              Text("₺${_netMusteriFiyati.toStringAsFixed(2)}", style: TextStyle(color: primaryTeal, fontSize: 24, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 4),
          Text("* Şoför hizmet faturasını (%20 KDV) yolculuk sonu kesecektir.", style: TextStyle(color: textMuted.withOpacity(0.8), fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildRotaSecenek(String isim, IconData ikon, bool aktif) {
    return GestureDetector(
      onTap: () => setState(() => _seciliRota = isim),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: _seciliRota == isim ? accentGold.withOpacity(0.1) : bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _seciliRota == isim ? accentGold : Colors.black.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Icon(ikon, color: _seciliRota == isim ? accentGold : textMuted, size: 20),
            const SizedBox(height: 6),
            Text(isim, style: TextStyle(color: _seciliRota == isim ? accentGold : textMuted, fontSize: 10, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  Widget _buildRadarTaramaAnimasyonu() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80, height: 80,
            child: CircularProgressIndicator(color: primaryTeal, strokeWidth: 2),
          ),
          const SizedBox(height: 24),
          Text("SİNYAL MERKEZE İLETİLİYOR...", style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 8),
          Text("Şoförün onay vermesi bekleniyor", style: TextStyle(color: textMuted, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildTaksiKarti(Map<String, dynamic> taksi) {
    int puan = taksi['puan'];
    bool isVIP = taksi['isVip'] ?? false;
    bool isRiskli = puan <= 70;
    
    Color anaRenk = isVIP ? accentGold : (isRiskli ? dangerColor : primaryTeal);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: anaRenk.withOpacity(0.5), width: isVIP ? 2 : 1),
        boxShadow: isVIP ? [BoxShadow(color: accentGold.withOpacity(0.15), blurRadius: 20)] : [BoxShadow(color: Colors.white.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // PLAKA VE ROZET
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.white, width: 2)),
                      child: Text(taksi['plaka'] ?? "", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    ),
                    if (isVIP)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: accentGold.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: accentGold)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: accentGold, size: 12),
                            const SizedBox(width: 4),
                            Text("ALTIN ŞOFÖR", style: TextStyle(color: accentGold, fontSize: 9, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      )
                  ],
                ),
                const SizedBox(height: 16),

                // ŞOFÖR ADI (ŞİFRELİ) VE DURAK
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.person, color: anaRenk, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(taksi['soforAdi'] ?? "Bilinmiyor", style: TextStyle(color: textMain, fontSize: 16, fontWeight: FontWeight.w900)),
                          Text("${taksi['arac']} • ${taksi['mesafe']} KM Uzakta", style: TextStyle(color: textMuted, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text("Bağlı Durak: ${taksi['durakAdi'] ?? 'Bağımsız'}", style: TextStyle(color: primaryTeal, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    
                    // PUAN VE YORUMLAR
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            Text("${taksi['yildiz'] ?? '5.0'}", style: TextStyle(color: textMain, fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text("(${taksi['yorumSayisi'] ?? 0} Yorum)", style: TextStyle(color: textMuted, fontSize: 9)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
                          child: Text("Çığır: ${taksi['puan']}", style: TextStyle(color: anaRenk, fontSize: 10, fontWeight: FontWeight.bold)),
                        )
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),

          // AKSİYON BUTONLARI
          Container(
            decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05)))),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _durakBaskaninaMesajAt(taksi['durakAdi'] ?? 'Bilinmeyen Durak'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Center(child: Text("DURAKLA GÖRÜŞ", style: TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1))),
                    ),
                  )
                ),
                Container(width: 1, height: 40, color: Colors.white.withOpacity(0.05)),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _siberUyari("Şoför Engellendi. Kuantum Ağı'nda size bir daha görünmeyecek.", dangerColor);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Center(child: Text("ENGELLE", style: TextStyle(color: dangerColor, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1))),
                    ),
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.white.withOpacity(0.05)),
                Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap: () {
                      if (!_hedefSecildi) {
                        _siberUyari("Lütfen önce nereye gideceğinizi seçin!", dangerColor);
                        return;
                      }
                      if (!_radarTariyor) _taksiCagir(taksi['plaka']);
                    },
                    borderRadius: const BorderRadius.only(bottomRight: Radius.circular(16)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(color: anaRenk.withOpacity(0.1), borderRadius: const BorderRadius.only(bottomRight: Radius.circular(16))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cell_tower, color: anaRenk, size: 16),
                          const SizedBox(width: 8),
                          Text("₺${_netMusteriFiyati.toStringAsFixed(0)} İLE ÇAĞIR", style: TextStyle(color: anaRenk, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
