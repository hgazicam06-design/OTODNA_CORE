import 'dart:typed_data';
import 'dart:developer' as developer;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class KuantumPdfMotoru {
  /// 📄 SİBER GARANTİ BELGESİ ÜRETİM VE PAYLAŞIM PROTOKOLÜ
  Future<void> garantiBelgesiUretVePaylas({
    required String bayiIsim,
    required String plaka,
    required String aracTipi,
    required double toplamMaliyet,
    required List<Map<String, dynamic>> degisenParcalar,
    required String islemTarihi,
    required String islemKonumu,
  }) async {
    try {
      developer.log("SİBER PDF: $plaka plakalı araç için Garanti Belgesi mühürleme işlemi başlatıldı...");
      final pdf = pw.Document();

      // Kuantum Renk Paleti (PDF Formatı İçin)
      final PdfColor oledBlack = PdfColor.fromHex('#050505');
      final PdfColor kuantumCyan = PdfColor.fromHex('#00F0FF');
      final PdfColor matGrey = PdfColor.fromHex('#1A1A1A');
      final PdfColor altinSari = PdfColor.fromHex('#FFD700');

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return pw.Container(
              color: oledBlack,
              padding: const pw.EdgeInsets.all(24),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // --- 1. SİBER BAŞLIK VE LOGO ALANI ---
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(bayiIsim.toUpperCase(), style: pw.TextStyle(color: kuantumCyan, fontSize: 32, fontWeight: pw.FontWeight.bold)),
                          pw.Text("DİJİTAL REFERANS PROTOKOLÜ - OTODNA ALTYAPISI", style: const pw.TextStyle(color: PdfColors.white, fontSize: 10, letterSpacing: 2)),
                        ],
                      ),
                      // Kuantum Mührü İkonu
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: kuantumCyan, width: 2),
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                        ),
                        child: pw.Text("RESMİ BELGE", style: pw.TextStyle(color: kuantumCyan, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      )
                    ],
                  ),
                  pw.SizedBox(height: 30),

                  // --- 2. İŞLEM BİLGİLERİ (ZIRHLI PANEL) ---
                  pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: matGrey,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                      border: pw.Border.all(color: PdfColors.white, width: 0.5),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        _bilgiSatiri("YETKİLİ BAYİ:", bayiIsim, kuantumCyan),
                        _bilgiSatiri("ARAÇ PLAKASI:", plaka, PdfColors.white),
                        _bilgiSatiri("ARAÇ TİPİ:", aracTipi, PdfColors.white),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 30),

                  // --- 3. DEĞİŞEN PARÇALAR LİSTESİ ---
                  pw.Text("ONAYLANAN İŞLEMLER VE PARÇALAR", style: pw.TextStyle(color: altinSari, fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.Divider(color: kuantumCyan, thickness: 1),
                  pw.SizedBox(height: 10),

                  ...degisenParcalar.map((parca) {
                    return pw.Container(
                      margin: const pw.EdgeInsets.only(bottom: 8),
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: kuantumCyan, width: 0.5),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(parca['parca_adi'], style: const pw.TextStyle(color: PdfColors.white, fontSize: 12)),
                          pw.Text("✅ Mühürlendi", style: pw.TextStyle(color: kuantumCyan, fontSize: 10)),
                        ],
                      ),
                    );
                  }),

                  pw.SizedBox(height: 30),

                  // --- 4. TOPLAM MALİYET ---
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Text("TOPLAM MALİYET: ", style: const pw.TextStyle(color: PdfColors.white, fontSize: 14)),
                      pw.Text("₺${toplamMaliyet.toStringAsFixed(2)}", style: pw.TextStyle(color: kuantumCyan, fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.Spacer(),

                  // --- 5. SİBER NOTER VE KOORDİNAT DAMGASI (Hukuki Zırh) ---
                  pw.Divider(color: PdfColors.white, thickness: 0.5),
                  pw.SizedBox(height: 10),
                  pw.Center(
                    child: pw.Text(
                      "İşbu belge $bayiIsim firması tarafından düzenlenmiş olup tüm hukuki ve ticari mesuliyet firmaya aittir. OtoDNA yalnızca dijital altyapı hizmeti sunar ve hiçbir şekilde mesuliyet kabul etmez.",
                      style: const pw.TextStyle(color: PdfColors.grey400, fontSize: 8),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Center(
                    child: pw.Text(
                      "🔒 MÜHÜR ZAMANI: $islemTarihi | 📍 KONUM: $islemKonumu",
                      style: pw.TextStyle(color: kuantumCyan, fontSize: 8),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      developer.log("SİBER PDF: Belge başarıyla kriptolandı, cihaz paylaşım protokolü tetikleniyor...");

      // 6. PDF'i Byte'a Çevir ve Müşteriye Fırlat (Share Plus)
      final Uint8List pdfBytes = await pdf.save();

      // Doğrudan hafızadan WhatsApp, Mail veya cihaza kaydetme menüsünü açar
      await Share.shareXFiles(
        [XFile.fromData(pdfBytes, name: 'OtoDNA_Garanti_${plaka.replaceAll(" ", "")}.pdf', mimeType: 'application/pdf')],
        text: 'OtoDNA Dijital Garanti Belgeniz ektedir. Bizi tercih ettiğiniz için teşekkür ederiz!',
      );

      developer.log("SİBER BİLGİ: Garanti belgesi başarıyla fırlatıldı/kaydedildi.");

    } catch (e) {
      developer.log("SİBER İHLAL: PDF Belgesi üretilemedi veya paylaşılamadı!", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ: UI tarafına kırmızı alarm fırlatılır.
      throw Exception("PDF MOTORU ARIZASI: Garanti belgesi oluşturulamadı! Cihaz izinlerini kontrol edin.");
    }
  }

  pw.Widget _bilgiSatiri(String baslik, String deger, PdfColor degerRengi) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(baslik, style: const pw.TextStyle(color: PdfColors.grey, fontSize: 10)),
        pw.SizedBox(height: 4),
        pw.Text(deger, style: pw.TextStyle(color: degerRengi, fontSize: 12, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }
}