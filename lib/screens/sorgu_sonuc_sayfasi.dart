import 'package:flutter/material.dart';
// 🚀 SİBER UYARI: Bu kodun çalışması için pubspec.yaml dosyasında 'open_file' paketi yüklü olmalı.
// import 'package:open_file/open_file.dart';
// import '../services/pdf_servis.dart'; // Kendi pdf_servis.dart dosyanın yolunu buraya ekle

import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

class SorguSonucSayfasi extends StatefulWidget {
  final Map<String, dynamic> sonuclar;
  final String saseNo;

  const SorguSonucSayfasi({
    super.key,
    required this.sonuclar,
    required this.saseNo,
  });

  @override
  State<SorguSonucSayfasi> createState() => _SorguSonucSayfasiState();
}

class _SorguSonucSayfasiState extends State<SorguSonucSayfasi> {
  bool _pdfOlusturuluyor = false;

  // 🚀 FİREBASE: MÜHÜRLÜ RAPOR (PDF) OLUŞTURMA MOTORU
  Future<void> _muhurluRaporuAc() async {
    setState(() => _pdfOlusturuluyor = true);

    // 1. İşlem başladığını bildiren Kuantum Sinyali
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("RAPOR ŞİFRELENİYOR... LÜTFEN BEKLEYİN.", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
        backgroundColor: SiberTema.kuantumCyan,
        duration: Duration(seconds: 1),
      ),
    );

    try {
      // 2. PDF Servisini tetikle ve dosyayı oluştur (SİBER NOT: PdfServis() sınıfını senin eklemen gerek)
      // final pdfServis = PdfServis();
      // final file = await pdfServis.generateDnaReport(widget.sonuclar, widget.saseNo);

      // Simülasyon gecikmesi (Gerçek servise bağlayınca bu satırı sil)
      await Future.delayed(const Duration(seconds: 2));

      // 3. Dosyayı doğrudan cihazda (veya tarayıcıda) aç!
      // await OpenFile.open(file.path);

      if (!mounted) return;
      // SİBER NOT: open_file paketini kurduğunda üstteki yorumu açıp alttaki SnackBar'ı silebilirsin.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("MÜHÜRLÜ PDF HAZIR VE KAYDEDİLDİ!", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: SiberTema.kuantumCyan,
        ),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("SİBER İHLAL: Rapor Oluşturulamadı!", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: SiberTema.kanKirmizi,
        ),
      );
    } finally {
      if (mounted) setState(() => _pdfOlusturuluyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: SiberTema.oledBlack,
          elevation: 1,
          shadowColor: SiberTema.kuantumCyan.withOpacity(0.3),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: SiberTema.kuantumCyan, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "SİBER DNA RAPORU",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir'),
          ),
          centerTitle: true,
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/images/radar_grid.png'), fit: BoxFit.cover, opacity: 0.05),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_user, color: SiberTema.kuantumCyan.withOpacity(0.5), size: 100),
                const SizedBox(height: 24),
                const Text("ARAÇ DNA'SI ÇÖZÜMLENDİ", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
                const SizedBox(height: 12),
                Text("ŞASE: ${widget.saseNo}", style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 3, fontFamily: 'monospace')),
                // ... Buraya aracın hasar/değişen durumlarını gösteren diğer siber kartları ekleyebilirsin ...
              ],
            ),
          ),
        ),

        // 🔥 OTONOM PDF FIRLATMA BUTONU
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _pdfOlusturuluyor ? null : _muhurluRaporuAc,
          label: Text(
            _pdfOlusturuluyor ? "ŞİFRELENİYOR..." : "MÜHÜRLÜ RAPORU AÇ",
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.white, fontFamily: 'Avenir'),
          ),
          icon: _pdfOlusturuluyor
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.picture_as_pdf, color: Colors.white),
          backgroundColor: SiberTema.kanKirmizi.withOpacity(0.9), // Karargah standartlarına uygun koyu kırmızı
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: SiberTema.kanKirmizi.withOpacity(0.5), width: 1.5),
          ),
        ),
      ),
    );
  }
}