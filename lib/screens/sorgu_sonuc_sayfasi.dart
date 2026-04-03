// 🚀 SİBER UYARI: Bu kodun çalışması için pubspec.yaml dosyasında 'open_file' paketinin yüklü olması gerekir.
// import 'package:open_file/open_file.dart'; (Sayfanın en üstüne eklemeyi unutma)

floatingActionButton: FloatingActionButton.extended(
onPressed: () async {
// 1. İşlem başladığını bildiren Kuantum Sinyali
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text("RAPOR ŞİFRELENİYOR... LÜTFEN BEKLEYİN.", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
backgroundColor: Color(0xFF00FFC2), // primaryCyan
duration: Duration(seconds: 1),
),
);

try {
// 2. PDF Servisini tetikle ve dosyayı oluştur
final pdfServis = PdfServis();
final file = await pdfServis.generateDnaReport(sonuclar, saseNo);

// 3. Dosyayı doğrudan cihazda (veya tarayıcıda) aç!
// await OpenFile.open(file.path);

// SİBER NOT: Eğer henüz 'open_file' paketini kurmadıysan, üstteki satırı yorumda bırak, alttakini kullan:
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text("MÜHÜRLÜ PDF HAZIR! ROTA: ${file.path}", style: const TextStyle(fontWeight: FontWeight.bold)),
backgroundColor: Colors.redAccent,
),
);

} catch (e) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text("SİBER İHLAL: Rapor Oluşturulamadı!", style: TextStyle(fontWeight: FontWeight.bold)),
backgroundColor: Colors.redAccent,
),
);
}
},
label: const Text(
"MÜHÜRLÜ RAPORU AÇ",
style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.white)
),
icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
backgroundColor: Colors.redAccent.withOpacity(0.9), // Karargah standartlarına uygun koyu kırmızı
elevation: 10,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(16),
side: BorderSide(color: Colors.redAccent.withOpacity(0.5), width: 1.5),
),
),