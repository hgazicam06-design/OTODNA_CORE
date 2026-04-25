import 'package:flutter/material.dart';
import '../../core/siber_tema.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _rehberiGoster(otomatik: true);
    });
  }

  void _rehberiGoster({bool otomatik = false}) {
    const String baslik = "MEGA PARÇA TARAYICI";
    const String icerik = "Ustanın elinize verdiği yedek parça listesini kameraya okutun!\n\n"
        "Yapay Zekamız saniyeler içinde Orijinal, Yan Sanayi ve Çıkma stoklarını tarayıp size en uygun fiyatlı sepeti sunacaktır.\n\n"
        "Eğer piyasada bulunamayan bir parça varsa, sistem size sorarak hurdacılardan (çıkmacılardan) anında fiyat teklifi ister.";

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
        backgroundColor: const Color(0xFF121B2B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.orangeAccent, width: 1.5)),
        title: const Column(
          children: [
            Icon(Icons.recycling, color: Colors.orangeAccent, size: 64),
            SizedBox(height: 16),
            Text("BAZI PARÇALAR BULUNAMADI!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Ağımızda ${_bulunanParcalar.length} parçayı bulduk ve sepetinize ekledik. Ancak aşağıdaki ${_eksikParcalar.length} parça stoklarda yok:", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: _eksikParcalar.map((e) => Text("• $e", style: const TextStyle(color: Colors.orangeAccent, fontSize: 11, fontWeight: FontWeight.bold))).toList(),
              ),
            ),
            const SizedBox(height: 12),
            const Text("İzninizle bu parçalar için İkinci El (Hurdacı) esnafından 'Siber Teklif (İhale)' isteyelim mi?", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 10)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İSTEMİYORUM", style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, foregroundColor: Colors.black),
            onPressed: () {
              Navigator.pop(context);
              _motor.hurdaciIhalesiBaslat(_eksikParcalar, "MUSTERI_123", _hedefAracMarkasi);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Hurdacı İhalesi Başlatıldı! Teklifler Cüzdanınıza düşecek."), backgroundColor: Colors.orangeAccent));
            },
            child: const Text("EVET, TEKLİF TOPLA", style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
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
          backgroundColor: Colors.black.withOpacity(0.8),
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20), onPressed: () => Navigator.pop(context)),
          title: const Text("MEGA PARÇA TARAYICI", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline_rounded, color: SiberTema.kuantumCyan),
              tooltip: "Siber Rehber",
              onPressed: () => _rehberiGoster(otomatik: false),
            )
          ],
        ),
        body: Column(
          children: [
            // TARAYICI KONTROL PANELİ
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.black,
                border: Border(bottom: BorderSide(color: SiberTema.kuantumCyan, width: 2)),
              ),
              child: Column(
                children: [
                  const Text("LİSTEYİ YAPAY ZEKAYA OKUTUN", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity, height: 60,
                    child: ElevatedButton.icon(
                      style: SiberTema.kuantumButonStili(),
                      onPressed: _tariyor ? null : _kameraylaListeyiOku,
                      icon: _tariyor ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black)) : const Icon(Icons.document_scanner, size: 28, color: Colors.black),
                      label: Text(_tariyor ? "YAPAY ZEKA LİSTEYİ OKUYOR..." : "KAMERAYI AÇ VE TARA", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1, color: Colors.black)),
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
                          Icon(Icons.auto_awesome, size: 64, color: Colors.white.withOpacity(0.1)),
                          const SizedBox(height: 16),
                          Text("Taranan parçalar burada listelenecektir.", style: TextStyle(color: Colors.white.withOpacity(0.2))),
                        ],
                      ),
                    ),
            ),
            
            // SATIN ALMA BAR
            if (_taramaBitti && _bulunanParcalar.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(color: Colors.black, border: Border(top: BorderSide(color: Colors.white12))),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("TOPLAM SEPET TUTARI", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                          Text("₺${_toplamTutar.toStringAsFixed(2)}", style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 24, fontWeight: FontWeight.w900)),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: SiberTema.kuantumCyan, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Siparişiniz satıcılara iletildi!")));
                        },
                        child: const Text("SİPARİŞİ ONAYLA", style: TextStyle(fontWeight: FontWeight.bold)),
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
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: _bulunanParcalar.length,
      itemBuilder: (context, index) {
        final item = _bulunanParcalar[index];
        bool isOrijinal = item['bulunan_durum'].toString().contains("Orijinal");
        bool isCikma = item['bulunan_durum'].toString().contains("Çıkma");

        Color badgeColor = isOrijinal ? SiberTema.kuantumCyan : (isCikma ? Colors.orangeAccent : Colors.white54);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SiberTema.matGrey,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              Icon(isCikma ? Icons.recycling : Icons.build_circle, color: badgeColor, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['urun_ad'], style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("Satıcı: ${item['bayi_adi']}", style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: badgeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: badgeColor.withOpacity(0.5))),
                      child: Text(item['bulunan_durum'], style: TextStyle(color: badgeColor, fontSize: 9, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
              Text("₺${item['liste_fiyati'].toStringAsFixed(0)}", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            ],
          ),
        );
      },
    );
  }
}
