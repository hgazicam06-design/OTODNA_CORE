import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

// SİBER NOT: Modellerin Karargah standartlarındaki yapıları
class ServiceAction {
  final bool kontrolEdildi;
  final bool degistirildi;
  ServiceAction({required this.kontrolEdildi, required this.degistirildi});
}

class OfferItem {
  final String parcaAdi;
  final int miktar;
  final double birimFiyat;
  OfferItem({required this.parcaAdi, required this.miktar, required this.birimFiyat});
}

/// 🛡️ KUANTUM PDF BASKI VE MÜHÜRLEME MOTORU (PdfGenerator)
/// İşlem raporlarını ve teklifleri gerçek PDF dosyalarına dönüştürür ve Kuantum Ağına loglar.
class PdfGenerator {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 📋 1. SİBER ARAÇ KONTROL FORMU (ÇİFT TİKLİ) ──────────────────────────
  static Future<File> createControlFormPDF({
    required String saseNo,
    required String bayiId,
    required Map<String, ServiceAction> results,
  }) async {
    try {
      developer.log("SİBER BASKI: 📋 $saseNo için Araç Kontrol Formu çiziliyor...");

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("OTODNA ARAC KONTROL RAPORU", style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
              pw.SizedBox(height: 10),
              pw.Text("Sase Numarasi: ${saseNo.toUpperCase()}", style: const pw.TextStyle(fontSize: 14)),
              pw.Text("Tarih: ${DateTime.now().toLocal().toString().split(' ')[0]}", style: const pw.TextStyle(fontSize: 14)),
              pw.Divider(thickness: 2, color: PdfColors.blue900),
              pw.SizedBox(height: 20),

              // Dinamik Tablo Çizimi
              pw.TableHelper.fromTextArray(
                context: context,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
                data: <List<String>>[
                  <String>['Hizmet/Parca Adi', 'Kontrol Edildi', 'Degistirildi'],
                  ...results.entries.map((entry) => [
                    entry.key,
                    entry.value.kontrolEdildi ? '[EVET]' : '[HAYIR]',
                    entry.value.degistirildi ? '[EVET]' : '[HAYIR]'
                  ]).toList(),
                ],
              ),

              pw.SizedBox(height: 40),
              pw.Center(
                child: pw.BarcodeWidget(
                  color: PdfColors.black,
                  barcode: pw.Barcode.qrCode(),
                  data: "OTODNA_CTRL_${saseNo.toUpperCase()}",
                  width: 80,
                  height: 80,
                ),
              ),
              pw.Center(child: pw.Text("DIJITAL KONTROL MUHURU", style: const pw.TextStyle(fontSize: 8))),
            ],
          ),
        ),
      );

      // Kuantum Çıktı Kaydı
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/OtoDNA_Kontrol_${saseNo.toUpperCase()}.pdf");
      await file.writeAsBytes(await pdf.save());

      // ⛓️ ATOMİK ZIRH: Kara Kutuya Logla (Kayıt Dışılığı Engelle!)
      await _logPdfIslemi('KONTROL_FORMU', saseNo, bayiId);

      developer.log("SİBER BASKI: ✅ Kontrol Formu PDF olarak mühürlendi! Yol: ${file.path}");
      return file;

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Kontrol PDF'i basılamadı!", error: e);
      throw Exception("SİBER HATA: Kontrol formu oluşturulamadı. Cihaz hafızası dolu olabilir!");
    }
  }

  // ── 💰 2. SİBER FİYAT TEKLİF FORMU ───────────────────────────────────────
  static Future<File> createPriceOfferPDF({
    required String musteriAdi,
    required String bayiId,
    required List<OfferItem> items,
    required double total,
  }) async {
    try {
      developer.log("SİBER BASKI: 💰 $musteriAdi için Fiyat Teklif Formu çiziliyor...");

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("OTODNA RESMI FIYAT TEKLIFI", style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
              pw.SizedBox(height: 10),
              pw.Text("Musteri: ${musteriAdi.toUpperCase()}", style: const pw.TextStyle(fontSize: 14)),
              pw.Text("Tarih: ${DateTime.now().toLocal().toString().split(' ')[0]}", style: const pw.TextStyle(fontSize: 14)),
              pw.Divider(thickness: 2, color: PdfColors.teal900),
              pw.SizedBox(height: 20),

              // Fiyat Tablosu
              pw.TableHelper.fromTextArray(
                context: context,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.teal800),
                data: <List<String>>[
                  <String>['Parca / Hizmet', 'Miktar', 'Birim Fiyat', 'Toplam'],
                  ...items.map((item) => [
                    item.parcaAdi,
                    item.miktar.toString(),
                    "TL ${item.birimFiyat.toStringAsFixed(2)}",
                    "TL ${(item.miktar * item.birimFiyat).toStringAsFixed(2)}"
                  ]).toList(),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Text("GENEL TOPLAM: TL ${total.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ),

              pw.SizedBox(height: 50),
              pw.Text("SARTLAR VE KOSULLAR:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
              pw.Text("1. Isbu teklif 7 gun gecerlidir."),
              pw.Text("2. Mali degeri yoktur, fatura yerine gecmez."),
              pw.Text("3. OtoDNA Kuantum Agi tarafindan siber olarak guvenceye alinmistir."),
            ],
          ),
        ),
      );

      final output = await getTemporaryDirectory();
      String siberZaman = DateTime.now().millisecondsSinceEpoch.toString();
      final file = File("${output.path}/OtoDNA_Teklif_$siberZaman.pdf");
      await file.writeAsBytes(await pdf.save());

      // ⛓️ ATOMİK ZIRH: Kara Kutuya Logla
      await _logPdfIslemi('FIYAT_TEKLIFI', 'Musteri: $musteriAdi', bayiId);

      developer.log("SİBER BASKI: ✅ Fiyat Teklifi PDF olarak mühürlendi! Yol: ${file.path}");
      return file;

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Fiyat Teklifi PDF'i basılamadı!", error: e);
      throw Exception("SİBER HATA: Fiyat teklifi oluşturulamadı. Lütfen sistemi kontrol edin!");
    }
  }

  // ── 📡 İÇ SİBER PROTOKOL: PDF İŞLEMİNİ KARA KUTUYA MÜHÜRLE ──────────────
  static Future<void> _logPdfIslemi(String islemTuru, String hedef, String bayiId) async {
    try {
      await _db.collection('sistem_loglari').add({
        'islem_turu': islemTuru,
        'islem_detayi': 'SİBER BİLGİ: $bayiId yetkilisi tarafından $hedef için $islemTuru belgesi basıldı.',
        'tarih': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      developer.log("SİBER UYARI: Loglama motoru başarısız oldu!", error: e);
    }
  }
}