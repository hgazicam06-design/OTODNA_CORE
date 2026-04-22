// lib/services/pdf_rapor_servisi.dart
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM PDF BİLANÇO JENERATÖRÜ
/// OtoDNA sisteminin mühürlü muhasebe ve ciro dökümünü otonom PDF olarak cihaza yazar.
class PdfRaporServisi {
  static Future<void> olusturVeAc({
    required String bayiId,
    required double brutIscilik,
    required double brutParca,
    required double otodnaKomisyonu,
    required double netKazanc,
  }) async {
    developer.log("SİBER PDF: $bayiId için mühürlü bilanço üretiliyor...");

    final pdf = pw.Document();

    // Font yüklemeleri (Türkçe karakter desteği için)
    // Şimdilik standart Helvetica kullanıyoruz, özel font istenirse eklenebilir.
    final ttf = pw.Font.helvetica();
    final ttfBold = pw.Font.helveticaBold();

    final genCiro = brutIscilik + brutParca;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ── 🦅 BAŞLIK VE LOGO ALANI ──
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('OTODNA SİBER KARARGAH', style: pw.TextStyle(font: ttfBold, fontSize: 24, color: PdfColors.black)),
                      pw.SizedBox(height: 4),
                      pw.Text('RESMİ CİRO VE BİLANÇO DÖKÜMÜ', style: pw.TextStyle(font: ttf, fontSize: 12, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.black, width: 2),
                    ),
                    child: pw.Text('ONAYLI', style: pw.TextStyle(font: ttfBold, fontSize: 16, color: PdfColors.black)),
                  ),
                ],
              ),
              pw.SizedBox(height: 32),

              // ── 📄 CARİ BİLGİLERİ ──
              pw.Text('BAYİ KİMLİĞİ:', style: pw.TextStyle(font: ttfBold, fontSize: 12)),
              pw.Text(bayiId, style: pw.TextStyle(font: ttf, fontSize: 10)),
              pw.SizedBox(height: 8),
              pw.Text('DÖKÜM TARİHİ:', style: pw.TextStyle(font: ttfBold, fontSize: 12)),
              pw.Text('${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}', style: pw.TextStyle(font: ttf, fontSize: 10)),
              pw.SizedBox(height: 32),

              // ── 📊 MUHASEBE TABLOSU ──
              pw.Table.fromTextArray(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                headerStyle: pw.TextStyle(font: ttfBold, fontSize: 10, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.black),
                cellStyle: pw.TextStyle(font: ttf, fontSize: 10),
                cellAlignment: pw.Alignment.centerRight,
                headerAlignment: pw.Alignment.centerLeft,
                headers: ['İŞLEM KALEMİ', 'TUTAR (₺)'],
                data: [
                  ['Brüt İşçilik Geliri', brutIscilik.toStringAsFixed(2)],
                  ['Brüt Parça Satışı', brutParca.toStringAsFixed(2)],
                  ['GENEL CİRO (Brüt Toplam)', genCiro.toStringAsFixed(2)],
                ],
              ),
              pw.SizedBox(height: 24),

              // ── ⚠️ GİDERLER VE KESİNTİLER ──
              pw.Text('KESİNTİLER VE KOMİSYON (SADECE PARÇA ÜZERİNDEN %12)', style: pw.TextStyle(font: ttfBold, fontSize: 10, color: PdfColors.red800)),
              pw.SizedBox(height: 8),
              pw.Table.fromTextArray(
                border: pw.TableBorder.all(color: PdfColors.red800),
                headerStyle: pw.TextStyle(font: ttfBold, fontSize: 10, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.red800),
                cellStyle: pw.TextStyle(font: ttf, fontSize: 10, color: PdfColors.red800),
                cellAlignment: pw.Alignment.centerRight,
                headerAlignment: pw.Alignment.centerLeft,
                headers: ['KESİNTİ KALEMİ', 'TUTAR (₺)'],
                data: [
                  ['OtoDNA Evrensel Karargah Payı', '- ${otodnaKomisyonu.toStringAsFixed(2)}'],
                ],
              ),
              pw.SizedBox(height: 32),

              // ── 💰 NET KAZANÇ (ALTIN BÖLÜM) ──
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  border: pw.Border.all(color: PdfColors.black, width: 2),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('BAYİ NET ÇEKİLEBİLİR BAKİYE:', style: pw.TextStyle(font: ttfBold, fontSize: 14)),
                    pw.Text('₺${netKazanc.toStringAsFixed(2)}', style: pw.TextStyle(font: ttfBold, fontSize: 18)),
                  ],
                ),
              ),

              pw.Spacer(),

              // ── 🛡️ ALT BİLGİ VE GÜVENLİK ──
              pw.Divider(color: PdfColors.grey500),
              pw.Text(
                'Bu belge OtoDNA Kuantum Ağı tarafından otomatik olarak oluşturulmuştur. Çifte harcama ve veri bütünlüğü koruma altındadır.',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(font: ttf, fontSize: 8, color: PdfColors.grey700),
              ),
            ],
          );
        },
      ),
    );

    // ── 📂 DOSYAYI CİHAZA YAZ VE AÇ ──
    try {
      final output = await getTemporaryDirectory();
      final dosyaYolu = "${output.path}/OtoDNA_Bilanco_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final file = File(dosyaYolu);
      
      await file.writeAsBytes(await pdf.save());
      developer.log("SİBER PDF BAŞARILI: $dosyaYolu");
      
      // Oluşturulan PDF'i sistemin yerleşik okuyucusuyla aç
      await OpenFile.open(dosyaYolu);
    } catch (e) {
      developer.log("SİBER PDF HATASI: Belge oluşturulamadı veya açılamadı.", error: e);
    }
  }
}
