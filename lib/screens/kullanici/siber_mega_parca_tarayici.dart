import 'package:flutter/material.dart';
import '../../core/responsive_kalkan.dart';
import '../../services/siber_mega_parca_motoru.dart';
import '../../widgets/siber_rehber_dialog.dart';

class SiberMegaParcaTarayiciScreen extends StatefulWidget {
  const SiberMegaParcaTarayiciScreen({super.key});

  @override
  State<SiberMegaParcaTarayiciScreen> createState() => _SiberMegaParcaTarayiciScreenState();
}

class _SiberMegaParcaTarayiciScreenState extends State<SiberMegaParcaTarayiciScreen> {
  final SiberMegaParcaMotoru _motor = SiberMegaParcaMotoru();
  final String _hedefAracMarkasi = "BMW 3 Serisi"; // Gerçekte kullanıcıdan veya şaseden alınır
  
  bool _tariyor = false;
  bool _taramaBitti = false;

  List<Map<String, dynamic>> _bulunanParcalar = [];
  List<String> _eksikParcalar = [];
  double _toplamTutar = 0.0;

  final Color primaryTeal = Colors.teal.shade700;
  final Color textColor = const Color(0xFF1E293B);
  final Color bgColor = const Color(0xFFFAFAFC);
  final Color surfaceColor = Colors.white;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _rehberiGoster(otomatik: true);
    });
  }

  void _rehberiGoster({bool otomatik = false}) {
    const String baslik = "AKILLI PARÇA TARAYICI";
    const String icerik = "Ustanın elinize verdiği yedek parça listesini kameraya okutun!\n\n"
        "Yapay Zekamız saniyeler içinde Orijinal, Yan Sanayi ve Çıkma stoklarını tarayıp size en uygun fiyatlı sepeti sunacaktır.\n\n"
        "Eğer piyasada bulunamayan bir parça varsa, sistem size sorarak anlaşmalı tedarikçilerden anında fiyat teklifi ister.";

    if (otomatik) {
      SiberRehber.otomatikGoster(context: context, screenKey: 'mega_parca_rehber', baslik: baslik, icerik: icerik);
    } else {
      SiberRehber.goster(context: context, screenKey: 'mega_parca_rehber', baslik: baslik, icerik: icerik);
    }
  }

  Future<void> _kameraylaListeyiOku() async {
    setState(() {
      _tariyor = true;
      _taramaBitti = false;
    });

    // 1. OCR ile fotoğrafı metne çevir (SİMÜLASYON)
    List<String> okunanListe = await _motor.ocrIleListeyiCikar("dummy_image_path");

    // 2. Kuantum Şelale Aramasını Başlat
    Map<String, dynamic> aramaSonucu = await _motor.selaleTaramasiBaslat(okunanListe, _hedefAracMarkasi);

    if (!mounted) return;

    setState(() {
      _bulunanParcalar = List<Map<String, dynamic>>.from(aramaSonucu['bulunanlar']);
      _eksikParcalar = List<String>.from(aramaSonucu['eksikler']);
      _toplamTutar = aramaSonucu['toplamTutar'];
      _tariyor = false;
      _taramaBitti = true;
    });

    // 3. Eksik parça varsa Hurdacı İhalesi onayı iste
    if (_eksikParcalar.isNotEmpty) {
      _hurdaciOnayiIste();
    }
  }

  void _hurdaciOnayiIste() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.orange.shade700, width: 2)),
        title: Column(
          children: [
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(Icons.recycling, color: Colors.orange.shade700, size: 48)),
            const SizedBox(height: 16),
            Text("BAZI PARÇALAR BULUNAMADI!", style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 16, fontFamily: 'Avenir')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Ağımızda ${_bulunanParcalar.length} parçayı bulduk ve sepetinize ekledik. Ancak aşağıdaki ${_eksikParcalar.length} parça stoklarda yok:", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _eksikParcalar.map((e) => Text("• $e", style: TextStyle(color: Colors.orange.shade800, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir'))).toList(),
              ),
            ),
            const SizedBox(height: 16),
            const Text("İzninizle bu parçalar için yetkili tedarikçilerimizden anlık ihale teklifi isteyelim mi?", textAlign: TextAlign.center, style: TextStyle(color: Colors.white45, fontSize: 11, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İSTEMİYORUM", style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade700, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              Navigator.pop(context);
              _motor.hurdaciIhalesiBaslat(_eksikParcalar, "MUSTERI_123", _hedefAracMarkasi);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Tedarikçi İhalesi Başlatıldı! Teklifler Cüzdanınıza düşecek.", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Avenir')), backgroundColor: Colors.orange.shade700));
            },
            child: const Text("EVET, TEKLİF TOPLA", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5, fontFamily: 'Avenir')),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: primaryTeal, size: 20), onPressed: () => Navigator.pop(context)),
          title: Text("AKILLI PARÇA TARAYICI", style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2, fontFamily: 'Avenir')),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.help_outline_rounded, color: primaryTeal),
              tooltip: "Rehber",
              onPressed: () => _rehberiGoster(otomatik: false),
            )
          ],
        ),
        body: Column(
          children: [
            // TARAYICI KONTROL PANELİ
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5))],
                border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
              ),
              child: Column(
                children: [
                  const Text("LİSTEYİ YAPAY ZEKAYA OKUTUN", style: TextStyle(color: Colors.white45, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity, height: 60,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryTeal, foregroundColor: Colors.white, elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _tariyor ? null : _kameraylaListeyiOku,
                      icon: _tariyor ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white)) : const Icon(Icons.document_scanner, size: 24, color: Colors.white),
                      label: Text(_tariyor ? "YAPAY ZEKA OKUYOR..." : "KAMERAYI AÇ VE TARA", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1, color: SiberTema.textMain, fontFamily: 'Avenir')),
                    ),
                  ),
                ],
              ),
            ),

            // SEPET VE SONUÇLAR
            Expanded(
              child: _taramaBitti
                  ? _buildSepetEkrani()
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.document_scanner_outlined, size: 72, color: Colors.white.withValues(alpha: 0.05)),
                          const SizedBox(height: 16),
                          const Text("Taranan parçalar burada listelenecektir.", style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                        ],
                      ),
                    ),
            ),
            
            // SATIN ALMA BAR
            if (_taramaBitti && _bulunanParcalar.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))]),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("TOPLAM SEPET", style: TextStyle(color: Colors.white45, fontSize: 10, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                          Text("₺${_toplamTutar.toStringAsFixed(2)}", style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Siparişiniz satıcılara iletildi!", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Avenir')), backgroundColor: primaryTeal));
                        },
                        child: const Text("SİPARİŞİ ONAYLA", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5, fontFamily: 'Avenir')),
                      )
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildSepetEkrani() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      itemCount: _bulunanParcalar.length,
      itemBuilder: (context, index) {
        final item = _bulunanParcalar[index];
        bool isOrijinal = item['bulunan_durum'].toString().contains("Orijinal");
        bool isCikma = item['bulunan_durum'].toString().contains("Çıkma");

        Color badgeColor = isOrijinal ? primaryTeal : (isCikma ? Colors.orange.shade700 : Colors.blue.shade700);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5))]
          ),
          child: Row(
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(isCikma ? Icons.recycling : Icons.build_circle, color: badgeColor, size: 24)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['urun_ad'], style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                    const SizedBox(height: 4),
                    Text("Satıcı: ${item['bayi_adi']}", style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: badgeColor.withValues(alpha: 0.3))),
                      child: Text(item['bulunan_durum'].toString().toUpperCase(), style: TextStyle(color: badgeColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5, fontFamily: 'Avenir')),
                    )
                  ],
                ),
              ),
              Text("₺${item['liste_fiyati'].toStringAsFixed(0)}", style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
            ],
          ),
        );
      },
    );
  }
}
