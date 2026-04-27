import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';

class ArizaBildirimScreen extends StatefulWidget {
  const ArizaBildirimScreen({super.key});

  @override
  State<ArizaBildirimScreen> createState() => _ArizaBildirimScreenState();
}

class _ArizaBildirimScreenState extends State<ArizaBildirimScreen> {
  final TextEditingController _plakaController = TextEditingController();
  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _detayController = TextEditingController();
  bool _isSaving = false;
  late Timer _saatTimer;
  DateTime _suAnkiZaman = DateTime.now();

  // 🤖 SİBER USTA (YAPAY ZEKA) AYARLARI
  final FlutterTts _flutterTts = FlutterTts();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isSpeechReady = false;

  String _ustaIsmi = "Kuantum Usta";
  bool _isKadinSes = false;
  double _sesHizi = 0.5; // 0.0 ile 1.0 arası

  final ImagePicker _picker = ImagePicker();
  List<QueryDocumentSnapshot> _gecmisKayitlar = [];
  bool _isSearchingHistory = false;
  DateTime? _filtreTarihi;

  // 🌟 DETAYLANDIRILMIŞ VE AŞAĞI AÇILAN (EXPANSION) BAKIM FORMLARI
  final List<Map<String, dynamic>> _bakimGruplari = [
    {
      "grupAd": "PERİYODİK BAKIM (10.000 - 15.000 KM)",
      "parcalar": [
        {"ad": "Motor Yağı", "durum": null, "foto": null, "ozelSecenek": true, "isYag": true, "kmSiniri": "10000", "yilSiniri": "1", "viskozite": "", "marka": ""},
        {"ad": "Yağ Filtresi", "durum": null, "foto": null, "ozelSecenek": false, "isYag": false},
        {"ad": "Hava Filtresi", "durum": null, "foto": null, "ozelSecenek": false, "isYag": false},
        {"ad": "Polen (Kabin) Filtresi", "durum": null, "foto": null, "ozelSecenek": false, "isYag": false},
        {"ad": "Yakıt Filtresi", "durum": null, "foto": null, "ozelSecenek": false, "isYag": false},
        {"ad": "Antifriz / Soğutma Sıvısı", "durum": null, "foto": null, "ozelSecenek": false, "isYag": false},
        {"ad": "Fren Hidrolik Sıvısı", "durum": null, "foto": null, "ozelSecenek": false, "isYag": false},
      ]
    },
    {
      "grupAd": "AĞIR BAKIM VE YÜRÜYEN AKSAM",
      "parcalar": [
        {"ad": "Triger Seti (Kayış/Zincir)", "durum": null, "foto": null, "ozelSecenek": true, "isYag": false, "kmSiniri": "90000", "yilSiniri": "4"},
        {"ad": "Devirdaim (Su Pompası)", "durum": null, "foto": null, "ozelSecenek": false, "isYag": false},
        {"ad": "V-Kayışı (Alternatör)", "durum": null, "foto": null, "ozelSecenek": false, "isYag": false},
        {"ad": "Ön Fren Balataları", "durum": null, "foto": null, "ozelSecenek": false, "isYag": false},
        {"ad": "Arka Fren Balataları", "durum": null, "foto": null, "ozelSecenek": false, "isYag": false},
        {"ad": "Ön / Arka Fren Diskleri", "durum": null, "foto": null, "ozelSecenek": false, "isYag": false},
        {"ad": "Buji / Kızdırma Bujisi", "durum": null, "foto": null, "ozelSecenek": false, "isYag": false},
        {"ad": "Şanzıman Yağı", "durum": null, "foto": null, "ozelSecenek": true, "isYag": true, "kmSiniri": "60000", "yilSiniri": "4", "viskozite": "", "marka": ""},
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _saatTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _suAnkiZaman = DateTime.now());
    });
    _ustaAyarlariniYukle();
  }

  Future<void> _ustaAyarlariniYukle() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _ustaIsmi = prefs.getString('usta_ismi') ?? "Kuantum Usta";
      _isKadinSes = prefs.getBool('usta_cinsiyet') ?? false;
      _sesHizi = prefs.getDouble('usta_hiz') ?? 0.5;
    });

    _speech = stt.SpeechToText();
    _isSpeechReady = await _speech.initialize();

    await _flutterTts.setLanguage("tr-TR");
    await _flutterTts.setSpeechRate(_sesHizi);
    await _flutterTts.setPitch(_isKadinSes ? 1.3 : 0.7);

    if (mounted) {
      await _flutterTts.speak("Oto DNA sistemine hoş geldiniz komutanım. Ben $_ustaIsmi, aracı mühürlemeye hazırım.");
    }
  }

  void _ustaAyarlariniAc() {
    TextEditingController isimController = TextEditingController(text: _ustaIsmi);
    double geciciHiz = _sesHizi;
    bool geciciKadin = _isKadinSes;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Colors.white, // Plaza Kalitesi Rengi
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.teal.shade700, width: 1.5)),
              title: Row(children: [Icon(Icons.engineering, color: Colors.teal.shade700), const SizedBox(width: 8), Text("Siber Usta Ayarları", style: TextStyle(color: Colors.teal.shade700, fontSize: 16, fontWeight: FontWeight.bold))]),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(controller: isimController, style: const TextStyle(color: Color(0xFF1E293B)), decoration: InputDecoration(labelText: "Ustanın İsmi", labelStyle: const TextStyle(color: Colors.white54), enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.teal.shade700)))),
                    const SizedBox(height: 24),
                    const Text("Usta Cinsiyeti (Ses Tonu)", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Expanded(child: RadioListTile<bool>(title: const Text("Erkek", style: TextStyle(color: Color(0xFF1E293B), fontSize: 12)), value: false, groupValue: geciciKadin, activeColor: Colors.teal.shade700, onChanged: (v) => setModalState(() => geciciKadin = v!))),
                        Expanded(child: RadioListTile<bool>(title: const Text("Kadın", style: TextStyle(color: Color(0xFF1E293B), fontSize: 12)), value: true, groupValue: geciciKadin, activeColor: Colors.teal.shade700, onChanged: (v) => setModalState(() => geciciKadin = v!))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text("Konuşma Hızı (0 ile 1 arası)", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                    Slider(value: geciciHiz, min: 0.1, max: 1.0, activeColor: Colors.teal.shade700, inactiveColor: Colors.black12, onChanged: (v) => setModalState(() => geciciHiz = v)),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal", style: TextStyle(color: Colors.white54))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade700, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('usta_ismi', isimController.text.trim());
                    await prefs.setBool('usta_cinsiyet', geciciKadin);
                    await prefs.setDouble('usta_hiz', geciciHiz);
                    if (!mounted) return;
                    Navigator.pop(context);
                    _ustaAyarlariniYukle();
                  },
                  child: const Text("KAYDET", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                )
              ],
            );
          }
      ),
    );
  }

  Future<void> _plakaGecmisiniSorgula(String plaka) async {
    if (plaka.isEmpty) return;
    setState(() => _isSearchingHistory = true);
    FocusScope.of(context).unfocus();
    String formatliPlaka = plaka.replaceAll(" ", "").toUpperCase();
    try {
      var snapshot = await FirebaseFirestore.instance.collection('ariza_raporlari').where('plaka', isEqualTo: formatliPlaka).orderBy('muhurlenme_vakti', descending: true).get();
      setState(() { _gecmisKayitlar = snapshot.docs; _isSearchingHistory = false; _filtreTarihi = null; });
      if (_gecmisKayitlar.isEmpty) {
        await _flutterTts.speak("Komutanım, ağda bu araca ait geçmiş bulunamadı.");
      } else {
        await _flutterTts.speak("Tüm geçmiş kayıtlar radara yansıtıldı.");
      }
    } catch (e) {
      setState(() => _isSearchingHistory = false);
    }
  }

  Future<void> _tarihSec(BuildContext context) async {
    final DateTime? secilen = await showDatePicker(
      context: context, initialDate: _filtreTarihi ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now(),
      builder: (context, child) => Theme(data: ThemeData.light().copyWith(colorScheme: ColorScheme.light(primary: Colors.teal.shade700, onPrimary: Colors.white, surface: Colors.white)), child: child!),
    );
    if (secilen != null) setState(() => _filtreTarihi = secilen);
  }

  void _dinlemeyiBaslatDurur() async {
    if (!_isListening && _isSpeechReady) {
      await _flutterTts.stop();
      setState(() => _isListening = true);
      _speech.listen(localeId: "tr_TR", onResult: (val) => setState(() => _detayController.text = val.recognizedWords));
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _parcaFotografiCek(int grupIndex, int parcaIndex) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 60);
    if (image != null) {
      setState(() {
        _bakimGruplari[grupIndex]['parcalar'][parcaIndex]['foto'] = File(image.path);
        if (_bakimGruplari[grupIndex]['parcalar'][parcaIndex]['durum'] == null) _bakimGruplari[grupIndex]['parcalar'][parcaIndex]['durum'] = true;
      });
    }
  }

  Future<void> _durumDegistir(int grupIndex, int parcaIndex, bool isOK) async {
    if (isOK) {
      if (_bakimGruplari[grupIndex]['parcalar'][parcaIndex]['foto'] == null) {
        await _flutterTts.speak("Komutanım, yeşil onay için önce kamera ile fotoğraf çekmeniz zorunludur.");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Onay (✅) için fotoğraf ZORUNLUDUR!"), backgroundColor: Colors.orange));
        await _parcaFotografiCek(grupIndex, parcaIndex);
      } else {
        setState(() => _bakimGruplari[grupIndex]['parcalar'][parcaIndex]['durum'] = true);
      }
    } else {
      setState(() => _bakimGruplari[grupIndex]['parcalar'][parcaIndex]['durum'] = false);
    }
  }

  Future<void> _arizayiSistemeIsle() async {
    if (_plakaController.text.isEmpty || _kmController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Plaka ve Kilometre Zorunludur!"), backgroundColor: Colors.redAccent));
      return;
    }

    setState(() => _isSaving = true);
    FocusScope.of(context).unfocus();

    String plakaID = _plakaController.text.trim().replaceAll(" ", "").toUpperCase();
    int girilenKM = int.tryParse(_kmController.text.trim()) ?? 0;
    List<Map<String, dynamic>> islenenKontroller = [];

    try {
      for (var grup in _bakimGruplari) {
        for (var parca in grup['parcalar']) {
          if (parca['durum'] != null) {
            String? fotoLink;
            if (parca['foto'] != null) {
              String dosyaAdi = "${DateTime.now().millisecondsSinceEpoch}_${parca['ad'].toString().replaceAll(" ", "")}.jpg";
              Reference ref = FirebaseStorage.instance.ref().child('bakim_dosyalari/$plakaID/$dosyaAdi');
              fotoLink = await (await ref.putFile(parca['foto'])).ref.getDownloadURL();
            }
            islenenKontroller.add({
              "grup": grup['grupAd'], "ad": parca['ad'], "durum": parca['durum'], "foto_link": fotoLink ?? "Yok",
              if (parca['ozelSecenek'] == true && parca['durum'] == true) "gelecek_degisim_km": parca['kmSiniri'],
              if (parca['ozelSecenek'] == true && parca['durum'] == true) "gelecek_degisim_yil": parca['yilSiniri'],
              if (parca['isYag'] == true && parca['durum'] == true) "yag_viskozitesi": parca['viskozite'],
              if (parca['isYag'] == true && parca['durum'] == true) "yag_markasi": parca['marka'],
            });
          }
        }
      }

      if (islenenKontroller.isEmpty && _detayController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Hiçbir bakım işlemi girmediniz!"), backgroundColor: Colors.orange));
        setState(() => _isSaving = false);
        return;
      }

      DateTime suAn = DateTime.now();
      DateTime kaliciMuhurZamani = suAn.add(const Duration(hours: 2));

      await FirebaseFirestore.instance.collection('ariza_raporlari').add({
        "plaka": plakaID, "km": girilenKM, "detay": _detayController.text.trim(),
        "kontrol_noktalari": islenenKontroller,
        "raporlayan_bayi": "OtoDNA Merkez",
        "raporlayan_usta": _ustaIsmi,
        "muhurlenme_vakti": Timestamp.fromDate(suAn), "kesinlesme_vakti": Timestamp.fromDate(kaliciMuhurZamani),
      });

      await FirebaseFirestore.instance.collection('araclar').doc(plakaID).set({"km": girilenKM, "son_bakim_tarihi": Timestamp.fromDate(suAn)}, SetOptions(merge: true));

      if (!mounted) return;
      await _flutterTts.speak("Kayıt mühürlendi komutanım.");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("AĞA İŞLENDİ! 2 Saat İçinde Silinmemek Üzere Mühürlenecek! 🔒"), backgroundColor: Colors.teal.shade700));
      Navigator.pop(context);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sistem Hatası: $e"), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _saatTimer.cancel(); _flutterTts.stop(); if (_isListening) _speech.stop();
    _plakaController.dispose(); _kmController.dispose(); _detayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🏢 PLAZA KALİTESİ PALET
    const bgColor = Color(0xFFFAFAFC);
    final primaryTeal = Colors.teal.shade700;
    const cardColor = Colors.white;
    const textColor = Color(0xFF1E293B);

    String saatFormatli = "${_suAnkiZaman.hour.toString().padLeft(2, '0')}:${_suAnkiZaman.minute.toString().padLeft(2, '0')}:${_suAnkiZaman.second.toString().padLeft(2, '0')}";

    var gosterilecekGecmis = _filtreTarihi == null ? _gecmisKayitlar : _gecmisKayitlar.where((doc) {
      DateTime t = (doc['muhurlenme_vakti'] as Timestamp).toDate();
      return t.year == _filtreTarihi!.year && t.month == _filtreTarihi!.month && t.day == _filtreTarihi!.day;
    }).toList();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
          backgroundColor: cardColor,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1)),
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: primaryTeal, size: 20), onPressed: () => Navigator.pop(context)),
          title: Text("Kalıcı Mühür Terminali", style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1, fontFamily: 'Avenir')),
          centerTitle: true
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🌟 DİJİTAL KALE: BİLGİ PANELİ EKLENDİ
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3))),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                  SizedBox(width: 12),
                  Expanded(child: Text("DİKKAT: Mühürlenen raporlar 2 saat içinde Kuantum Ağına işlenir ve asla değiştirilemez.", style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold, height: 1.4))),
                ],
              ),
            ),

            // SAAT (Plaza Cam Tasarımı)
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryTeal.withValues(alpha: 0.2)), boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.03), blurRadius: 15)]), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("İşlem Saati:", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)), Text("2 Saat Sonra Kalıcı Kilit", style: TextStyle(color: primaryTeal, fontSize: 10))]), Text(saatFormatli, style: TextStyle(color: textColor, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir'))])),
            const SizedBox(height: 24),

            // PLAKA VE KM
            Row(children: [
              Expanded(flex: 2, child: Container(padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.05))), child: TextField(controller: _plakaController, textCapitalization: TextCapitalization.characters, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, letterSpacing: 1), decoration: InputDecoration(icon: Icon(Icons.pin, color: primaryTeal, size: 20), hintText: "Plaka", hintStyle: const TextStyle(color: Colors.white26, letterSpacing: 0), border: InputBorder.none)))),
              const SizedBox(width: 12),
              Expanded(flex: 1, child: Container(padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3))), child: TextField(controller: _kmController, keyboardType: TextInputType.number, style: TextStyle(color: textColor, fontWeight: FontWeight.bold), decoration: const InputDecoration(hintText: "KM *", hintStyle: TextStyle(color: Colors.redAccent), border: InputBorder.none)))),
            ]),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: primaryTeal.withValues(alpha: 0.1), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: primaryTeal.withValues(alpha: 0.5)))), onPressed: _isSearchingHistory ? null : () => _plakaGecmisiniSorgula(_plakaController.text), icon: _isSearchingHistory ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: primaryTeal, strokeWidth: 2)) : Icon(Icons.history, color: primaryTeal, size: 20), label: Text("TÜM DNA GEÇMİŞİNİ GETİR", style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)))),

            // GEÇMİŞ
            if (_gecmisKayitlar.isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                  padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Eski Kuantum Kayıtları", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                            GestureDetector(onTap: () => _tarihSec(context), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white.withValues(alpha: 0.05))), child: Row(children: [Icon(Icons.calendar_month, color: primaryTeal, size: 14), const SizedBox(width: 6), Text(_filtreTarihi == null ? "Tarih Seç" : "${_filtreTarihi!.day}/${_filtreTarihi!.month}/${_filtreTarihi!.year}", style: TextStyle(color: primaryTeal, fontSize: 11, fontWeight: FontWeight.bold))]))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (gosterilecekGecmis.isEmpty) const Text("Seçili tarihte işlem bulunamadı.", style: TextStyle(color: Colors.white54, fontSize: 12)),
                        ...gosterilecekGecmis.map((doc) {
                          var data = doc.data() as Map<String, dynamic>;
                          DateTime tarih = (data['muhurlenme_vakti'] as Timestamp).toDate();
                          List bakimlar = data['kontrol_noktalari'] ?? [];
                          return Container(
                              margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("${tarih.day}/${tarih.month}/${tarih.year} - ${tarih.hour.toString().padLeft(2,'0')}:${tarih.minute.toString().padLeft(2,'0')}", style: TextStyle(color: primaryTeal, fontSize: 12, fontWeight: FontWeight.bold)), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(6)), child: Text("KM: ${data['km']}", style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold)))]),
                                    Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Divider(color: Colors.white.withValues(alpha: 0.05))),
                                    if (bakimlar.isNotEmpty) ...bakimlar.map((b) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [Icon(b['durum'] == true ? Icons.check_circle : Icons.cancel, color: b['durum'] == true ? Colors.green : Colors.redAccent, size: 14), const SizedBox(width: 6), Expanded(child: Text(b['ad'], style: const TextStyle(color: Colors.white87, fontSize: 11)))]) )),
                                    const SizedBox(height: 8),
                                    Text(data['detay'] ?? "", style: const TextStyle(color: Colors.white54, fontSize: 11, fontStyle: FontStyle.italic)),
                                    const SizedBox(height: 8),
                                    if (data['raporlayan_usta'] != null) Text("İşlemi Yapan: ${data['raporlayan_usta']}", style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ]
                              )
                          );
                        })
                      ]
                  )
              )
            ],

            const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider(color: Colors.white12)),

            // 🌟 YETKİLİ SERVİS FORMU (AŞAĞI AÇILAN - EXPANSION)
            Row(
              children: [
                Container(width: 3, height: 16, decoration: BoxDecoration(color: primaryTeal, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 8),
                const Text("YETKİLİ SERVİS PROTOKOLÜ", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.5)),
              ],
            ),
            const SizedBox(height: 8),
            const Text("Fotoğrafı olmayan parçaya sistem yeşil tık (✅) attırmaz.", style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            ...List.generate(_bakimGruplari.length, (grupIndex) {
              var grup = _bakimGruplari[grupIndex];
              // Kuantum Expandable Liste Tasarımı -> Plaza Expandable Liste
              return Container(
                margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 8)]),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent), // Çizgiyi gizle
                  child: ExpansionTile(
                    iconColor: primaryTeal, collapsedIconColor: Colors.black54,
                    title: Text(grup['grupAd'], style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12)),
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05)))),
                        child: Column(
                          children: List.generate(grup['parcalar'].length, (parcaIndex) {
                            var parca = grup['parcalar'][parcaIndex];
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(parca['ad'], style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold))),
                                      GestureDetector(onTap: () => _parcaFotografiCek(grupIndex, parcaIndex), child: Container(margin: const EdgeInsets.symmetric(horizontal: 4), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: parca['foto'] != null ? Colors.blue.withValues(alpha: 0.1) : bgColor, borderRadius: BorderRadius.circular(10), border: Border.all(color: parca['foto'] != null ? Colors.blue : Colors.black.withValues(alpha: 0.05))), child: Icon(Icons.camera_alt, color: parca['foto'] != null ? Colors.blue : Colors.black45, size: 16))),
                                      GestureDetector(onTap: () => _durumDegistir(grupIndex, parcaIndex, true), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: parca['durum'] == true ? Colors.green.withValues(alpha: 0.1) : bgColor, borderRadius: BorderRadius.circular(10), border: Border.all(color: parca['durum'] == true ? Colors.green : Colors.black.withValues(alpha: 0.05))), child: Icon(Icons.check, color: parca['durum'] == true ? Colors.green : Colors.black45, size: 16))),
                                      const SizedBox(width: 6),
                                      GestureDetector(onTap: () => _durumDegistir(grupIndex, parcaIndex, false), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: parca['durum'] == false ? Colors.redAccent.withValues(alpha: 0.1) : bgColor, borderRadius: BorderRadius.circular(10), border: Border.all(color: parca['durum'] == false ? Colors.redAccent : Colors.black.withValues(alpha: 0.05))), child: Icon(Icons.close, color: parca['durum'] == false ? Colors.redAccent : Colors.black45, size: 16))),
                                    ],
                                  ),
                                ),
                                if (parca['ozelSecenek'] == true && parca['durum'] == true)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 12, top: 4), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: primaryTeal.withValues(alpha: 0.2))),
                                    child: Column(
                                      children: [
                                        Row(children: [Icon(Icons.av_timer, color: primaryTeal, size: 18), const SizedBox(width: 8), const Text("Değişim\nAralığı:", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)), const SizedBox(width: 12), Expanded(child: TextField(onChanged: (v) => parca['kmSiniri'] = v, keyboardType: TextInputType.number, style: TextStyle(color: primaryTeal, fontSize: 13, fontWeight: FontWeight.bold), decoration: InputDecoration(isDense: true, hintText: parca['kmSiniri'], hintStyle: const TextStyle(color: Colors.white26), labelText: "KM", labelStyle: const TextStyle(color: Colors.white38, fontSize: 10), enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryTeal))))), const SizedBox(width: 12), Expanded(child: TextField(onChanged: (v) => parca['yilSiniri'] = v, keyboardType: TextInputType.number, style: TextStyle(color: primaryTeal, fontSize: 13, fontWeight: FontWeight.bold), decoration: InputDecoration(isDense: true, hintText: parca['yilSiniri'], hintStyle: const TextStyle(color: Colors.white26), labelText: "YIL", labelStyle: const TextStyle(color: Colors.white38, fontSize: 10), enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryTeal))))) ]),
                                        if (parca['isYag'] == true) ...[
                                          const SizedBox(height: 12), Divider(color: Colors.white.withValues(alpha: 0.05)), const SizedBox(height: 8),
                                          Row(children: [const Icon(Icons.water_drop, color: Colors.orange, size: 18), const SizedBox(width: 8), Expanded(child: TextField(onChanged: (v) => parca['viskozite'] = v, style: const TextStyle(color: Colors.orange, fontSize: 13, fontWeight: FontWeight.bold), decoration: const InputDecoration(isDense: true, hintText: "Örn: 5W-30", hintStyle: TextStyle(color: Colors.white26), labelText: "Viskozite", labelStyle: TextStyle(color: Colors.white38, fontSize: 10), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange))))), const SizedBox(width: 12), Expanded(child: TextField(onChanged: (v) => parca['marka'] = v, style: const TextStyle(color: Colors.orange, fontSize: 13, fontWeight: FontWeight.bold), decoration: const InputDecoration(isDense: true, hintText: "Örn: Castrol", hintStyle: TextStyle(color: Colors.white26), labelText: "Marka", labelStyle: TextStyle(color: Colors.white38, fontSize: 10), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange))))) ])
                                        ]
                                      ],
                                    ),
                                  )
                              ],
                            );
                          }),
                        ),
                      )
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),

            // 🤖 SİBER USTA PANELİ (MİKROFON + AYARLAR)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    // SİBER USTA (İŞ ELBİSELİ AVATAR)
                    GestureDetector(
                      onTap: _dinlemeyiBaslatDurur,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300), padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(shape: BoxShape.circle, color: _isListening ? Colors.redAccent.withValues(alpha: 0.1) : cardColor, border: Border.all(color: _isListening ? Colors.redAccent : Colors.black.withValues(alpha: 0.05), width: 2), boxShadow: _isListening ? [BoxShadow(color: Colors.redAccent.withValues(alpha: 0.2), blurRadius: 15)] : [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 8)]),
                        // TULUM GİYMİŞ USTA İKONU
                        child: Icon(_isListening ? Icons.graphic_eq : Icons.engineering, color: _isListening ? Colors.redAccent : primaryTeal, size: 36),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // AYARLAR DİŞLİSİ
                    GestureDetector(
                      onTap: _ustaAyarlariniAc,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
                        child: const Row(
                          children: [
                            Icon(Icons.settings, color: Colors.white54, size: 12),
                            SizedBox(width: 4),
                            Text("Ayarlar", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: _isListening ? Colors.redAccent.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.05))),
                    child: TextField(
                      controller: _detayController, maxLines: 5, style: TextStyle(color: textColor, fontSize: 13, height: 1.5),
                      decoration: InputDecoration(hintText: "$_ustaIsmi sizi dinliyor komutanım...\n(Mikrofona basıp konuşun veya yazın)", hintStyle: const TextStyle(color: Colors.white26, fontSize: 12), border: InputBorder.none),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // MÜHÜRLE BUTONU (Derin Kırmızı / Tehlike Rengi)
            SizedBox(
                width: double.infinity, height: 70,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF991B1B), // Koyu Tehlike Kırmızısı
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Colors.redAccent, width: 1.5)),
                        elevation: 15, shadowColor: Colors.redAccent.withValues(alpha: 0.3)
                    ),
                    onPressed: _isSaving ? null : _arizayiSistemeIsle,
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("SİSTEME KALICI OLARAK MÜHÜRLE", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1.5)),
                          SizedBox(height: 2),
                          Text("(Bu işlem geri alınamaz)", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.bold))
                        ]
                    )
                )
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
