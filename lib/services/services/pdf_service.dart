import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

// SİBER NOT: Veri modelinin Karargah standardındaki temsili
class ServiceRecord {
  final String saseNo;
  final String bayiId;
  final int nextServiceKm;
  final String islemId;

  ServiceRecord({
    required this.saseNo,
    required this.bayiId,
    required this.nextServiceKm,
    required this.islemId
  });
}

/// 🛡️ KUANTUM YAZDIRILABİLİR FORM VE SİBER MÜHÜR MOTORU (PdfService)
/// Ustanın girdiği kontrol verilerini gerçek bir PDF'e çizer ve Karargaha loglar.
class PdfService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 📋 GERÇEK SİBER BELGE BASKISI (MAKET YIKILDI) ───────────────────────
  static Future<File> generateServiceReport(ServiceRecord record, Map<String, bool> checks) async {
    try {
      developer.log("SİBER BASKI: 🖨️ ${record.saseNo.toUpperCase()} için OtoDNA Onaylı Servis Formu çiziliyor...");

      final pdf = pw.Document();

      // Gerçek PDF Çizim Motoru
      pdf.addPage(
          pw.Page(
              build: (pw.Context context) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Başlık ve Şasi Bilgileri
                    pw.Text("\${record.bayiId.toUpperCase()} ARAC KONTROL FORMU", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                    pw.SizedBox(height: 10),
                    pw.Text("Sase Numarasi: ${record.saseNo.toUpperCase()}", style: const pw.TextStyle(fontSize: 14)),
                    pw.Text("Islem Referansi: ${record.islemId}", style: const pw.TextStyle(fontSize: 14)),
                    pw.Text("Tarih: ${DateTime.now().toLocal().toString().split(' ')[0]}", style: const pw.TextStyle(fontSize: 14)),
                    pw.Divider(thickness: 2, color: PdfColors.blue900),
                    pw.SizedBox(height: 20),

                    // Dinamik Kontrol Listesi
                    pw.Text("KONTROL EDILEN NOKTALAR:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                    pw.SizedBox(height: 10),
                    ...checks.entries.map((entry) {
                      String durum = entry.value ? "[BASARILI / ONAYLANDI]" : "[KUSURLU / DEGISTIRILMELI]";
                      PdfColor renk = entry.value ? PdfColors.green800 : PdfColors.red800;
                      return pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 6),
                          child: pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text(entry.key.toUpperCase()),
                                pw.Text(durum, style: pw.TextStyle(color: renk, fontWeight: pw.FontWeight.bold)),
                              ]
                          )
                      );
                    }),

                    pw.SizedBox(height: 50),
                    pw.Divider(color: PdfColors.grey),
                    pw.SizedBox(height: 10),

                    // 🛡️ Bayi Onayı ve Gelecek Bakım Mührü
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text("BAYI ONAYI (MUHUR)", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                                pw.SizedBox(height: 5),
                                pw.Text("Yetkili Bayi ID: ${record.bayiId}"),
                              ]
                          ),
                          pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.end,
                              children: [
                                pw.Text("GELECEK BAKIM KM", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                                pw.SizedBox(height: 5),
                                pw.Text("${record.nextServiceKm} KM", style: pw.TextStyle(fontSize: 18, color: PdfColors.red900, fontWeight: pw.FontWeight.bold)),
                              ]
                          )
                        ]
                    ),

                    pw.SizedBox(height: 30),
                    pw.Center(child: pw.Text("Isbu belge \${record.bayiId} tarafindan duzenlenmistir. OtoDNA yalnizca dijital altyapi hizmeti sunar ve hicbir hukuki mesuliyet kabul etmez.", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700), textAlign: pw.TextAlign.center)),
                  ]
              )
          )
      );

      // Kuantum Çıktı ve Dosya Kaydı
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/OtoDNA_ServisFormu_${record.saseNo.toUpperCase()}.pdf");
      await file.writeAsBytes(await pdf.save());

      // ⛓️ ATOMİK ZIRH: Kara Kutuya Logla (Kayıt Dışılığı Engelle!)
      await _db.collection('sistem_loglari').add({
        'islem_turu': 'SERVIS_FORMU_BASIMI',
        'islem_detayi': 'SİBER MÜHÜR: ${record.bayiId} yetkilisi ${record.saseNo} aracı için Resmi Servis Formu bastı.',
        'tarih': FieldValue.serverTimestamp(),
      });

      developer.log("SİBER BASKI: ✅ OtoDNA Servis Formu gercekten PDF olarak mühürlendi! Yol: ${file.path}");
      return file;

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Servis Formu PDF'i basılamadı!", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ: UI'a Kırmızı Alarm Fırlat!
      throw Exception("SİBER HATA: Servis formu PDF'e dönüştürülemedi. Cihaz hafızasını kontrol edin!");
    }
  }
}