import 'dart:io';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class GarantiKalemi {
  final String parcaAdi;
  final String garantiSuresi; // Örn: "10.000 KM / 6 Ay" veya "Yok"
  final bool kapsamDahilinde;

  GarantiKalemi(this.parcaAdi, this.garantiSuresi, this.kapsamDahilinde);

  // Karargah veritabanına mühürlemek için dönüştürücü
  Map<String, dynamic> toMap() {
    return {
      'parca_adi': parcaAdi,
      'garanti_suresi': garantiSuresi,
      'kapsam_dahilinde': kapsamDahilinde,
    };
  }
}

/// 🛡️ KUANTUM GARANTİ BELGESİ MOTORU
/// Garanti kurallarını Kuantum Ağından çeker, gerçek bir PDF belgesine dönüştürür ve QR mühür basar.
class GarantiBelgesiServisi {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 🔍 1. DİNAMİK GARANTİ İSTİHBARATI (MAKET YIKILDI) ─────────────────────
  static Future<List<GarantiKalemi>> kalemleriOlustur(List<String> secilenParcalar) async {
    try {
      developer.log("SİBER RADAR: Parçaların garanti kapsamları Kuantum Ağında taranıyor...");
      List<GarantiKalemi> sonucListesi = [];

      for (var parca in secilenParcalar) {
        // Gerçek Karargah Veritabanı Taraması
        DocumentSnapshot doc = await _db.collection('garanti_kurallari').doc(parca).get();

        if (doc.exists) {
          var data = doc.data() as Map<String, dynamic>;
          sonucListesi.add(GarantiKalemi(
            parca,
            data['sure'] ?? "Standart 6 Ay",
            data['kapsam'] ?? true,
          ));
        } else {
          // Veritabanında yoksa otonom standart kural (Sarf malzeme filtresi)
          bool sarfMi = parca.toUpperCase().contains("AMPUL") || parca.toUpperCase().contains("SİLECEK");
          sonucListesi.add(GarantiKalemi(
            parca,
            sarfMi ? "Garanti Yok (Sarf Malzeme)" : "Standart 6 Ay",
            !sarfMi,
          ));
        }
      }

      developer.log("SİBER BİLGİ: ${sonucListesi.length} kalem için garanti kuralları eşleştirildi.");
      return sonucListesi;

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Garanti şartları okunamadı!", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ
      throw Exception("SİBER İHLAL: Garanti veritabanına erişilemiyor. Lütfen Karargah bağlantınızı kontrol edin!");
    }
  }

  // ── 📄 2. GERÇEK DİJİTAL MÜHÜRLÜ PDF BASKISI (SİVİL PRINT İMHA EDİLDİ) ───
  static Future<File> garantiBelgesiBas({
    required String saseNo,
    required String islemId,
    required List<GarantiKalemi> liste
  }) async {
    try {
      developer.log("SİBER BİLGİ: 🛡️ $saseNo için Resmi Garanti Belgesi mühürleniyor...");

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("OTODNA RESMI GARANTI BELGESI", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
              pw.SizedBox(height: 10),
              pw.Text("Sase No: ${saseNo.toUpperCase()}", style: const pw.TextStyle(fontSize: 14)),
              pw.Text("Islem Referans: $islemId", style: const pw.TextStyle(fontSize: 14)),
              pw.Divider(thickness: 2, color: PdfColors.blue900),
              pw.SizedBox(height: 20),

              // Garanti Kalemleri Listesi
              ...liste.map((kalem) {
                String durum = kalem.kapsamDahilinde ? "[GARANTILI]" : "[KAPSAM DISI]";
                PdfColor renk = kalem.kapsamDahilinde ? PdfColors.green800 : PdfColors.red800;
                return pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 8),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(kalem.parcaAdi, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text("${kalem.garantiSuresi}  $durum", style: pw.TextStyle(color: renk, fontWeight: pw.FontWeight.bold)),
                      ],
                    )
                );
              }).toList(),

              pw.SizedBox(height: 30),
              pw.Text("GARANTI SARTLARI:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
              pw.Text("1. Hatali kullanim ve agir arazi sartlari garantiyi gecersiz kilar."),
              pw.Text("2. OtoDNA muhuru olmayan belgeler gecersizdir."),
              pw.SizedBox(height: 40),

              // 🚀 GERÇEK SİBER QR KOD ENTEGRASYONU
              pw.Center(
                child: pw.BarcodeWidget(
                  color: PdfColors.black,
                  barcode: pw.Barcode.qrCode(),
                  data: "OTODNA_VERIFY_$islemId",
                  width: 100,
                  height: 100,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Center(child: pw.Text("DIJITAL MUHUR KODU", style: const pw.TextStyle(fontSize: 8, letterSpacing: 1.5))),
            ],
          ),
        ),
      );

      // Kuantum Çıktı
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/OtoDNA_Garanti_${saseNo.toUpperCase()}.pdf");
      await file.writeAsBytes(await pdf.save());

      // ⛓️ ATOMİK ZIRH: İşlemi Karargah Veritabanına Kilitliyoruz (Kayıt Dışılık Önlendi!)
      WriteBatch batch = _db.batch();

      DocumentReference garantiRef = _db.collection('garanti_belgeleri').doc(islemId);
      batch.set(garantiRef, {
        'sase_no': saseNo.toUpperCase(),
        'islem_id': islemId,
        'kapsam_listesi': liste.map((e) => e.toMap()).toList(),
        'basim_tarihi': FieldValue.serverTimestamp(),
      });

      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'GARANTI_BELGESI_BASIMI',
        'islem_detayi': 'SİBER MÜHÜR: $saseNo şaseli araç için resmi garanti belgesi oluşturuldu.',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit(); // Füzeler ateşlendi!

      developer.log("SİBER BASKI: ✅ Garanti PDF'i başarıyla mühürlendi ve Kuantum Ağına kilitlendi! Konum: ${file.path}");
      return file;

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Garanti belgesi basılamadı!", error: e);
      // 🚨 SESSİZ ÇÖKÜŞ ENGELLENDİ
      throw Exception("SİBER HATA: Garanti belgesi PDF olarak mühürlenemedi. Lütfen cihaz depolama izinlerini kontrol edin!");
    }
  }
}