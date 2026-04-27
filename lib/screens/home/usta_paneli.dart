import 'package:flutter/material.dart';
import '../../bayi/siber_servis_kabul_paneli.dart';
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';
import '../../widgets/siber_rehber_dialog.dart';
import '../../services/corporate_notary_service.dart'; // MÜHÜR VE AI SERVİSİ

class UstaPaneliScreen extends StatefulWidget {
  const UstaPaneliScreen({super.key});

  @override
  State<UstaPaneliScreen> createState() => _UstaPaneliScreenState();
}

class _UstaPaneliScreenState extends State<UstaPaneliScreen> {
  String? _secilenAracCinsi;
  String? _secilenYakitTipi;
  final TextEditingController _saseController = TextEditingController();
  bool _veriCekiliyor = false;

  final Map<String, String> _testSonuclari = {};

  final List<String> _aracCinsleri = [
    'Motosiklet 🏍️',
    'Otomobil 🚗',
    'Kamyonet / Panelvan 🚐',
    'Minibüs 🚌',
    'Otobüs & Midibüs 🚍',
    'Kamyon & Çekici/Tır 🚛',
    'İş Makinesi & Traktör 🚜'
  ];

  final List<String> _yakitTipleri = [
    'Benzin',
    'Motorin (Dizel)',
    'Tam Elektrikli (EV)',
    'Hibrit (HEV / PHEV)',
    'Benzin + LPG',
    'Doğalgaz (CNG)'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _rehberiGoster(otomatik: true);
    });
  }

  void _rehberiGoster({bool otomatik = false}) {
    const String baslik = "OTODNA USTA PANELİ";
    const String icerik = "Siber Karargah Usta Ağına Hoş Geldiniz.\n\n"
        "Buradan aracın şase numarasını (VIN) girerek Kuantum ağından fabrika verilerini çekebilirsiniz.\n\n"
        "Seçilen araç sınıfına ve yakıt tipine göre dinamik test modülleri otomatik listelenir. "
        "Test sonuçlarını sisteme mühürlediğinizde, veriler değiştirilemez şekilde Kuantum Ağına (Siber Sicil) işlenir.";

    if (otomatik) {
      SiberRehber.otomatikGoster(context: context, screenKey: 'usta_paneli_rehber', baslik: baslik, icerik: icerik);
    } else {
      SiberRehber.goster(context: context, screenKey: 'usta_paneli_rehber', baslik: baslik, icerik: icerik);
    }
  }

  void _sasedenSorgula() async {
    if (_saseController.text.length < 17) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Şase Numarası 17 Haneli Olmalıdır!'), backgroundColor: Colors.redAccent));
      return;
    }
    setState(() => _veriCekiliyor = true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _veriCekiliyor = false;
      _secilenAracCinsi = 'Otomobil 🚗';
      _secilenYakitTipi = 'Benzin + LPG';
      _testSonuclari.clear();
    });
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Araç Fabrika Verileri Hub\'dan Çekildi! ✅'), backgroundColor: Colors.green));
  }

  void _musteriOnayinaGonder() async {
    if (_testSonuclari.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hiçbir testi tamamlamadınız!'), backgroundColor: Colors.orangeAccent));
      return;
    }
    
    if (_saseController.text.length < 17) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mühürleme için 17 Haneli Şase numarası girmelisiniz!'), backgroundColor: Colors.redAccent));
      return;
    }

    // YÜKLEME (TASLAK OLUŞTURULUYOR) ANİMASYONU
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF121B2B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFF00FFC2), width: 1.5)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 50, height: 50, child: CircularProgressIndicator(color: Color(0xFF00FFC2))),
            SizedBox(height: 16),
            Text("GPS KONUMU VE SAAT ALINIYOR...", style: TextStyle(color: Color(0xFF00FFC2), fontSize: 12, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Rapor Taslağı Oluşturuluyor\nMüşterinin Onayına Sunulacak...", textAlign: TextAlign.center, style: TextStyle(color: SiberTema.textMuted, fontSize: 10)),
          ],
        ),
      ),
    );

    // SERVİSİ ÇAĞIR (1. ANAHTAR)
    final servis = CorporateNotaryService();
    final sonuc = await servis.expertizTaslagiOlustur(
      saseNo: _saseController.text,
      testSonuclari: _testSonuclari,
      aracCinsi: _secilenAracCinsi ?? "Bilinmeyen Cins",
      yakitTipi: _secilenYakitTipi ?? "Bilinmeyen Yakıt"
    );

    if (!mounted) return;
    Navigator.pop(context); // Yükleme ekranını kapat

    if (sonuc['basarili']) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF121B2B), // Dijital Kale Kart Rengi
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.orangeAccent, width: 1.5)),
          title: const Column(
            children: [
              Icon(Icons.hourglass_top, color: Colors.orangeAccent, size: 64),
              SizedBox(height: 16),
              Text("MÜŞTERİ ONAYINA GÖNDERİLDİ!", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: const Text("Tesisimizin GPS konumuyla birlikte rapor taslağı araç sahibinin uygulamasına iletildi.\n\nMüşteri onaylayıp kendi mühürünü vurduğunda rapor Kuantum Ağı'na (Değiştirilemez) kilitlenecektir.", textAlign: TextAlign.center, style: TextStyle(color: SiberTema.textMuted, fontSize: 12)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Dialogu kapat
                setState(() {
                  _testSonuclari.clear();
                  _saseController.clear();
                });
              },
              child: const Text("YENİ ARAÇ İNCELE", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      );
    } else {
      // HATA DURUMU
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(sonuc['mesaj']), backgroundColor: Colors.redAccent));
    }
  }

  List<Widget> _dinamikModulleriGetir() {
    List<Widget> moduller = [];

    if (_secilenAracCinsi == null || _secilenYakitTipi == null) {
      return [const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text("Çalışır aksamların listelenmesi için Araç Cinsi ve Yakıt Tipi seçiniz.", textAlign: TextAlign.center, style: TextStyle(color: SiberTema.textMuted))))];
    }

    if (_secilenYakitTipi == 'Tam Elektrikli (EV)' || _secilenYakitTipi == 'Hibrit (HEV / PHEV)') {
      moduller.add(_buildKayitMotoruKarti("Yüksek Voltaj Batarya Sağlığı (%SOH)", Icons.battery_charging_full, zorunluFoto: true));
      moduller.add(_buildKayitMotoruKarti("İnvertör ve Elektrik Motoru Soğutma Sistemi", Icons.electrical_services));
      moduller.add(_buildKayitMotoruKarti("Şarj Portu ve Soket İletkenliği", Icons.ev_station));
    }

    if (_secilenYakitTipi != 'Tam Elektrikli (EV)') {
      moduller.add(_buildKayitMotoruKarti("Motor Bloğu & Yağ/Sıvı Kaçakları", Icons.build_circle, zorunluFoto: true));
      moduller.add(_buildKayitMotoruKarti("Triger / V Kayışı ve Kasnaklar", Icons.settings_applications));
      moduller.add(_buildKayitMotoruKarti("Şanzıman Vites Geçişleri & Kavrama", Icons.settings));

      if (_secilenYakitTipi == 'Motorin (Dizel)') {
        moduller.add(_buildKayitMotoruKarti("DPF (Dizel Partikül Filtresi) ve AdBlue Sistemi", Icons.cloud));
        moduller.add(_buildKayitMotoruKarti("Turboşarj ve Intercooler Basınç Testi", Icons.cyclone));
      } else {
        moduller.add(_buildKayitMotoruKarti("Egzoz Emisyon ve Katalitik Konvertör", Icons.cloud));
      }
    }

    if (_secilenYakitTipi == 'Benzin + LPG') {
      moduller.add(_buildKayitMotoruKarti("LPG Tank Üretim Tarihi & Ömrü", Icons.local_gas_station, zorunluFoto: true));
      moduller.add(_buildKayitMotoruKarti("LPG Regülatör (Beyin) ve Gaz Sızdırmazlık", Icons.warning));
    } else if (_secilenYakitTipi == 'Doğalgaz (CNG)') {
      moduller.add(_buildKayitMotoruKarti("CNG Yüksek Basınç Tankı Kontrolü", Icons.local_gas_station, zorunluFoto: true));
    }

    if (_secilenAracCinsi == 'Motosiklet 🏍️') {
      moduller.add(_buildKayitMotoruKarti("Zincir & Dişli (veya Kayış/Şaft) Gerginliği", Icons.settings_input_component, zorunluFoto: true));
      moduller.add(_buildKayitMotoruKarti("Ön Maşa (Çatal) Keçe ve Amortisör Kaçakları", Icons.motorcycle));
    }
    else if (_secilenAracCinsi!.contains('Kamyon') || _secilenAracCinsi!.contains('Otobüs')) {
      moduller.add(_buildKayitMotoruKarti("Havalı Fren Sistemi ve Kompresör Basıncı", Icons.air));
      moduller.add(_buildKayitMotoruKarti("Takograf Kalibrasyon Mührü Kontrolü", Icons.timer, zorunluFoto: true));
    }
    else if (_secilenAracCinsi!.contains('İş Makinesi')) {
      moduller.add(_buildKayitMotoruKarti("Hidrolik Pompalar ve Piston (Lift) Kaçakları", Icons.precision_manufacturing, zorunluFoto: true));
    }
    else {
      moduller.add(_buildKayitMotoruKarti("Kaporta, Boya Değişen ve Mikron Ölçümü", Icons.format_paint, zorunluFoto: true));
    }

    moduller.add(_buildKayitMotoruKarti("Lastik Diş Derinliği ve DOT (Üretim) Yılı", Icons.tire_repair, zorunluFoto: true));
    moduller.add(_buildKayitMotoruKarti("Şase Direkleri, Podye ve Alt Takım", Icons.warning_amber_rounded, isCritical: true, zorunluFoto: true));
    moduller.add(_buildKayitMotoruKarti("Fren Diskleri, Balatalar ve Fren Hidroliği", Icons.car_crash, isCritical: true, zorunluFoto: true));

    moduller.add(const SizedBox(height: 24));
    moduller.add(
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 10,
            ),
            onPressed: _musteriOnayinaGonder,
            icon: const Icon(Icons.send_to_mobile, size: 28),
            label: const Text("MÜŞTERİ ONAYINA GÖNDER", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ),
        )
    );

    return moduller;
  }

  Widget _buildKayitMotoruKarti(String baslik, IconData ikon, {bool isCritical = false, bool zorunluFoto = false}) {
    String durum = _testSonuclari[baslik] ?? 'bekliyor';

    Color kartRengi = const Color(0xFF121B2B); // Dijital Kale Kart Rengi
    Color cerceveRengi = isCritical ? Colors.redAccent.withOpacity(0.5) : Colors.white12;
    Color ikonRengi = isCritical ? Colors.redAccent : const Color(0xFF00FFC2);

    if (durum == 'onaylandi') {
      kartRengi = Colors.green.withOpacity(0.05);
      cerceveRengi = Colors.green.withOpacity(0.5);
      ikonRengi = Colors.greenAccent;
    } else if (durum == 'riskli') {
      kartRengi = Colors.red.withOpacity(0.05);
      cerceveRengi = Colors.redAccent.withOpacity(0.5);
      ikonRengi = Colors.redAccent;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: kartRengi, borderRadius: BorderRadius.circular(16), border: Border.all(color: cerceveRengi, width: durum != 'bekliyor' ? 1.5 : 1)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: ikonRengi.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(ikon, color: ikonRengi, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(baslik, style: TextStyle(color: SiberTema.textMain, fontSize: 12, fontWeight: FontWeight.bold, decoration: isCritical ? TextDecoration.underline : TextDecoration.none, decorationColor: Colors.redAccent)),
                if (zorunluFoto) ...[const SizedBox(height: 4), const Text("Zorunlu Görsel Kanıt", style: TextStyle(color: Colors.orangeAccent, fontSize: 10, fontWeight: FontWeight.bold))],
                if (durum != 'bekliyor') ...[
                  const SizedBox(height: 4),
                  Text(durum == 'onaylandi' ? "Sorunsuz" : "Kusurlu / Riskli", style: TextStyle(color: ikonRengi, fontSize: 10, fontWeight: FontWeight.bold))
                ]
              ],
            ),
          ),
          IconButton(
              icon: Icon(Icons.check_circle, color: durum == 'onaylandi' ? Colors.greenAccent : Colors.white24, size: 26),
              onPressed: () => setState(() => _testSonuclari[baslik] = 'onaylandi')
          ),
          IconButton(
              icon: Icon(Icons.cancel, color: durum == 'riskli' ? Colors.redAccent : Colors.white24, size: 26),
              onPressed: () => setState(() => _testSonuclari[baslik] = 'riskli')
          ),
        ],
      ),
    );
  }

  // 🌟 YENİ: SİBER HIZLI FİLTRE ÇİPLERİ (Ehliyet Sınıfı Kuantum Seçici)
  Widget _buildHizliAracSecici(String etiket, String tamDeger) {
    bool secili = _secilenAracCinsi == tamDeger;
    return GestureDetector(
      onTap: () => setState(() { _secilenAracCinsi = tamDeger; _testSonuclari.clear(); }),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
            color: secili ? const Color(0xFF00FFC2).withOpacity(0.15) : const Color(0xFF121B2B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: secili ? const Color(0xFF00FFC2) : Colors.white12)
        ),
        child: Text(etiket, style: TextStyle(color: secili ? const Color(0xFF00FFC2) : Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryCyan = Color(0xFF00FFC2);
    const bgColor = Color(0xFF070B14); // Dijital Kale Arka Plan
    const cardColor = Color(0xFF121B2B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
          backgroundColor: cardColor,
          elevation: 0,
          shape: const Border(bottom: BorderSide(color: SiberTema.textMuted, width: 1)),
          title: const Text('OtoDNA Usta Paneli', style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
          iconTheme: const IconThemeData(color: primaryCyan),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline_rounded, color: primaryCyan),
              tooltip: "Siber Rehber",
              onPressed: () => _rehberiGoster(otomatik: false),
            )
          ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KOZMİK ODA BUTONU
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SiberServisKabulPaneli()));
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FFC2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF00FFC2).withOpacity(0.5)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.radar, color: Color(0xFF00FFC2), size: 28),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("KOZMİK ODA İSTİHBARATI", style: TextStyle(color: Color(0xFF00FFC2), fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            SizedBox(height: 4),
                            Text("Araçların kronik sorunlarını ve fabrika verilerini anında tarayın.", style: TextStyle(color: SiberTema.textMuted, fontSize: 10)),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, color: Color(0xFF00FFC2), size: 16)
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text("SİBER HUB SORGULAMA", style: TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: _saseController, style: const TextStyle(color: SiberTema.textMain, letterSpacing: 2, fontWeight: FontWeight.bold), textCapitalization: TextCapitalization.characters, maxLength: 17, decoration: InputDecoration(hintText: '17 Haneli Şase (VIN)', hintStyle: const TextStyle(color: SiberTema.textMuted), filled: true, fillColor: cardColor, counterText: "", border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: SiberTema.textMuted))))),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _veriCekiliyor ? null : _sasedenSorgula,
                    child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), decoration: BoxDecoration(color: primaryCyan, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.3), blurRadius: 10)]), child: _veriCekiliyor ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: bgColor, strokeWidth: 2)) : const Icon(Icons.search, color: bgColor)),
                  )
                ],
              ),
              const SizedBox(height: 24),

              // 🌟 YENİ EKLENEN HIZLI FİLTRE BÖLÜMÜ
              const Text("HIZLI ARAÇ SINIFI FİLTRESİ", style: TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildHizliAracSecici("Otomobil", "Otomobil 🚗"),
                    _buildHizliAracSecici("Ticari", "Kamyonet / Panelvan 🚐"),
                    _buildHizliAracSecici("Ağır Vasıta", "Kamyon & Çekici/Tır 🚛"),
                    _buildHizliAracSecici("Motosiklet", "Motosiklet 🏍️"),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: SiberTema.textMuted)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    dropdownColor: cardColor, isExpanded: true, value: _secilenAracCinsi, hint: const Text("Tüm Araç Cinsleri Listesi...", style: TextStyle(color: SiberTema.textMuted, fontSize: 13)),
                    icon: const Icon(Icons.keyboard_arrow_down, color: primaryCyan),
                    items: _aracCinsleri.map((String cins) { return DropdownMenuItem<String>(value: cins, child: Text(cins, style: const TextStyle(color: SiberTema.textMain, fontSize: 13))); }).toList(),
                    onChanged: (String? yeniCins) { setState(() { _secilenAracCinsi = yeniCins; _testSonuclari.clear(); }); },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text("MOTOR VE YAKIT TİPİ", style: TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: SiberTema.textMuted)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    dropdownColor: cardColor, isExpanded: true, value: _secilenYakitTipi, hint: const Text("Yakıt / Motor Tipi Seçiniz...", style: TextStyle(color: SiberTema.textMuted, fontSize: 13)),
                    icon: const Icon(Icons.keyboard_arrow_down, color: primaryCyan),
                    items: _yakitTipleri.map((String yakit) { return DropdownMenuItem<String>(value: yakit, child: Text(yakit, style: const TextStyle(color: SiberTema.textMain, fontSize: 13))); }).toList(),
                    onChanged: (String? yeniYakit) { setState(() { _secilenYakitTipi = yeniYakit; _testSonuclari.clear(); }); },
                  ),
                ),
              ),
              const SizedBox(height: 32),

              if (_secilenAracCinsi != null && _secilenYakitTipi != null) ...[
                const Row(
                  children: [
                    Icon(Icons.science, color: primaryCyan, size: 20),
                    SizedBox(width: 8),
                    Text("DİNAMİK ÇALIŞIR AKSAM TESTLERİ", style: TextStyle(color: SiberTema.textMain, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              ..._dinamikModulleriGetir(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}