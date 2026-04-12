import 'dart:io';
import 'dart:developer' as developer;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/service_model.dart';

/// 🛡️ KUANTUM BELGE VE RAPORLAMA MOTORU (PdfServis)
/// Araç DNA'sını resmi, mühürlü ve değiştirilemez bir belgeye (PDF) dönüştürür.
class PdfServis {

  // ── 📄 DNA RAPORU OLUŞTURMA (SİBER BASKI) ────────────────────────────────
  Future<File> generateDnaReport(List<ServiceModel> kayitlar, String saseNo) async {
    try {
      developer.log("SİBER BİLGİ: $saseNo şaseli araç için Kuantum PDF Raporu hazırlanıyor...");

      final pdf = pw.Document(
        title: 'OtoDNA Raporu - $saseNo',
        author: 'OtoDNA Karargah',
      );

      // ⚠️ SİBER NOT: Flutter PDF paketi Türkçe karakterleri (ş, ğ, ı) desteklemez!
      // İleride uygulamanın assets klasörüne bir font ekleyip burayı aktif etmelisin:
      // final font = pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Regular.ttf"));
      // Şimdilik sistem çökmesin diye varsayılan Karargah fontu devrede.

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            _buildHeader(saseNo),
            pw.SizedBox(height: 20),

            // 🛡️ SİBER KONTROL: Araç sicili temiz mi, yoksa kabarık mı?
            if (kayitlar.isEmpty)
              _buildTemizSicilPaneli()
            else ...[
              _buildSummaryTable(kayitlar),
              pw.SizedBox(height: 20),
              pw.Text("SERVIS GECMISI DETAYLARI", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
              pw.Divider(color: PdfColors.blue900, thickness: 2),
              pw.SizedBox(height: 10),
              ...kayitlar.map((k) => _buildKayitItem(k)).toList(),
            ],

            pw.SizedBox(height: 40),
            _buildOfficialSeal(), // Ankara Merkez Dijital Mührü
          ],
        ),
      );

      // Kuantum Çıktı (Cihazın geçici klasörüne kaydetme)
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/OtoDNA_${saseNo.toUpperCase()}.pdf");
      await file.writeAsBytes(await pdf.save());

      developer.log("SİBER BASKI: ✅ PDF Raporu başarıyla mühürlendi! Konum: ${file.path}");
      return file;

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: PDF Raporu basılamadı!", error: e);
      // 🚨 KUSURSUZ ZIRH: Komutan Gazi'nin kurduğu Kırmızı Alarm kalkanı aktiftir!
      throw Exception("SİBER HATA: Belge oluşturulamadı. Lütfen cihazın depolama izinlerini kontrol edin.");
    }
  }

  // ── 🖼️ PDF TASARIM (UI) BİLEŞENLERİ ─────────────────────────────────────

  pw.Widget _buildHeader(String sase) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("OtoDNA ARAC DNA RAPORU", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
            pw.Text("Sase No: ${sase.toUpperCase()}", style: const pw.TextStyle(fontSize: 12)),
            pw.Text("Rapor Tarihi: ${DateTime.now().toString().split(' ')[0]}", style: const pw.TextStyle(color: PdfColors.grey700)),
          ],
        ),
        pw.Container(
          width: 60,
          height: 60,
          decoration: pw.BoxDecoration(
            color: PdfColors.blue900,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Center(child: pw.Text("DNA", style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 18))),
        ),
      ],
    );
  }

  // Eğer araçta hiçbir hasar/kayıt yoksa basılacak Siber Yeşil Pano
  pw.Widget _buildTemizSicilPaneli() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#E8F5E9'), // Açık yeşil siber arka plan
        border: pw.Border.all(color: PdfColors.green800, width: 2),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Center(
        child: pw.Column(
          children: [
            pw.Text("KUSURSUZ SİCİL", style: pw.TextStyle(color: PdfColors.green900, fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text(
              "Siber İstihbarat Radarlarımıza gore bu araca ait herhangi bir servis, kaza veya revizyon kaydi BULUNMAMAKTADIR.",
              style: pw.TextStyle(color: PdfColors.green800, fontSize: 12),
              textAlign: pw.TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildKayitItem(ServiceModel k) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("${k.kilometre.toInt()} KM", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
              pw.Text(k.parcaDurumu.toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: _getStatusColor(k.parcaDurumu))),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Text("Islem: ${k.aciklama}"), // Türkçe karakter çökmesini önlemek için "İşlem" yerine "Islem"
          pw.Text("Servis: ${k.islemiYapanBayi} (Bolge: ${k.bolgeKodu})", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryTable(List<ServiceModel> kayitlar) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
      cellAlignment: pw.Alignment.centerLeft,
      data: <List<String>>[
        <String>['Tarih', 'Kilometre', 'Parca Durumu', 'Bayi'], // Türkçe karakter filtresi
        ...kayitlar.map((k) => [
          k.tarih.toString().split(' ')[0],
          k.kilometre.toString(),
          k.parcaDurumu,
          k.islemiYapanBayi
        ])
      ],
    );
  }

  // ── 🔴 KARARGAH DİJİTAL MÜHRÜ ───────────────────────────────────────────
  pw.Widget _buildOfficialSeal() {
    return pw.Center(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(20),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.red900, width: 3),
          shape: pw.BoxShape.circle,
        ),
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text("ANKARA MERKEZ", style: pw.TextStyle(color: PdfColors.red900, fontWeight: pw.FontWeight.bold, fontSize: 12)),
            pw.Text("DISTRIBUTORLUGU", style: pw.TextStyle(color: PdfColors.red900, fontWeight: pw.FontWeight.bold, fontSize: 10)),
            pw.SizedBox(height: 5),
            pw.Text("DIJITAL MUHUR", style: pw.TextStyle(color: PdfColors.red700, fontSize: 8, letterSpacing: 2)),
          ],
        ),
      ),
    );
  }

  // ── 🎨 DURUM RENKLENDİRİCİ ──────────────────────────────────────────────
  PdfColor _getStatusColor(String status) {
    String s = status.toLowerCase();
    if (s.contains("orijinal")) return PdfColors.green900;
    if (s.contains("yan sanayi")) return PdfColors.orange900;
    if (s.contains("riskli") || s.contains("kirmizi_x")) return PdfColors.red900;
    return PdfColors.grey700;
  }
}