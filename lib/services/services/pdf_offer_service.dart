import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

// SİBER NOT: Teklif kalemleri modeli (Karargah standardı)
class OfferItem {
  final String description;
  final int quantity;
  final double totalPrice;

  OfferItem({required this.description, required this.quantity, required this.totalPrice});
}

/// 🛡️ KUANTUM TEKLİF VE FİNANS BASKI MOTORU (PdfOfferService)
/// Fiyat tekliflerini gerçek ve mühürlü PDF dosyalarına dönüştürür, işlemi Karargaha loglar.
class PdfOfferService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 💰 SİBER FİYAT TEKLİFİ BASKISI (MAKET YIKILDI) ──────────────────────
  static Future<File> generateOffer({
    required String bayiId,
    required String plate,
    required List<OfferItem> items,
  }) async {
    try {
      developer.log("SİBER BASKI: 💰 $plate plakalı araç için Teklif Formu çiziliyor...");

      // Kuantum Finans Hesaplamaları
      double grandTotal = 0;
      for (var item in items) {
        grandTotal += item.totalPrice;
      }
      double kdv = grandTotal * 0.20; // %20 KDV
      double genelToplam = grandTotal + kdv;

      final pdf = pw.Document();

      // Gerçek PDF Sayfası Tasarımı
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("OTODNA RESMI FIYAT TEKLIFI", style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
              pw.SizedBox(height: 10),
              pw.Text("Arac Plakasi: ${plate.toUpperCase()}", style: const pw.TextStyle(fontSize: 14)),
              pw.Text("Tarih: ${DateTime.now().toLocal().toString().split(' ')[0]}", style: const pw.TextStyle(fontSize: 14)),
              pw.Divider(thickness: 2, color: PdfColors.teal900),
              pw.SizedBox(height: 20),

              // Dinamik Fiyat Tablosu
              pw.TableHelper.fromTextArray(
                context: context,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.teal800),
                data: <List<String>>[
                  <String>['Parca / Hizmet Detayi', 'Miktar', 'Toplam (KDV Haric)'],
                  ...items.map((item) => [
                    item.description,
                    item.quantity.toString(),
                    "TL ${item.totalPrice.toStringAsFixed(2)}"
                  ]).toList(),
                ],
              ),

              pw.SizedBox(height: 20),

              // Finansal Özet Tablosu
              pw.Container(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text("ARA TOPLAM: TL ${grandTotal.toStringAsFixed(2)}", style: const pw.TextStyle(fontSize: 14)),
                        pw.Text("KDV (%20): TL ${kdv.toStringAsFixed(2)}", style: const pw.TextStyle(fontSize: 14)),
                        pw.Divider(color: PdfColors.grey),
                        pw.Text("GENEL TOPLAM: TL ${genelToplam.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
                      ]
                  )
              ),

              pw.SizedBox(height: 40),
              pw.Text("SARTLAR VE KOSULLAR:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
              pw.Text("1. Isbu teklif 7 gun gecerlidir."),
              pw.Text("2. Mali degeri yoktur, fatura yerine gecmez."),
              pw.Text("3. OtoDNA Kuantum Agi tarafindan siber olarak guvenceye alinmistir."),

              pw.SizedBox(height: 30),

              // 🚀 GERÇEK SİBER QR KOD ENTEGRASYONU
              pw.Center(
                child: pw.BarcodeWidget(
                  color: PdfColors.black,
                  barcode: pw.Barcode.qrCode(),
                  data: "OTODNA_OFFER_${plate.toUpperCase()}_${DateTime.now().millisecondsSinceEpoch}",
                  width: 90,
                  height: 90,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Center(child: pw.Text("DIJITAL TEKLIF MUHURU", style: const pw.TextStyle(fontSize: 8, letterSpacing: 1.2))),
            ],
          ),
        ),
      );

      // Kuantum Çıktı ve Dosya Kaydı
      final output = await getTemporaryDirectory();
      String siberZaman = DateTime.now().millisecondsSinceEpoch.toString();
      final file = File("${output.path}/OtoDNA_Teklif_${plate.toUpperCase()}_$siberZaman.pdf");
      await file.writeAsBytes(await pdf.save());

      // ⛓️ ATOMİK ZIRH: İşlemi Karargah Kara Kutusuna Mühürle
      await _db.collection('sistem_loglari').add({
        'islem_turu': 'FIYAT_TEKLIFI',
        'islem_detayi': 'SİBER BİLGİ: $bayiId yetkilisi tarafindan $plate plakali arac icin teklif belgesi basildi. Toplam Tutar: ₺$genelToplam',
        'tarih': FieldValue.serverTimestamp(),
      });

      developer.log("SİBER BASKI: ✅ Fiyat Teklifi PDF olarak gercekten basildi ve Karargaha raporlandi! Yol: ${file.path}");
      return file;

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Fiyat Teklifi PDF'i basilamadi!", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ: UI'a Kırmızı Alarm Fırlat!
      throw Exception("SİBER HATA: Teklif dosyasi olusturulamadi. Cihaz hafizasini veya ag baglantisini kontrol edin!");
    }
  }
}