import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🚀 KARARGAH ZIRHLARI VE MERKEZİ İSTİHBARAT
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';
import '../core/turkiye_haritasi.dart';

class BayiYonetimMerkeziScreen extends StatefulWidget {
  const BayiYonetimMerkeziScreen({super.key});

  @override
  State<BayiYonetimMerkeziScreen> createState() => _BayiYonetimMerkeziScreenState();
}

class _BayiYonetimMerkeziScreenState extends State<BayiYonetimMerkeziScreen> {
  final _formKey = GlobalKey<FormState>(); // Siber Doğrulama Kalkanı

  // Kurumsal Bilgi Kontrolcüleri
  final TextEditingController _firmaAdiController = TextEditingController();
  final TextEditingController _vergiNoController = TextEditingController();
  final TextEditingController _yetkiliKisiController = TextEditingController();
  final TextEditingController _telefonController = TextEditingController();
  final TextEditingController _tamAdresController = TextEditingController();

  // Vitrin ve Tanıtım Kontrolcüleri
  final TextEditingController _tanitimController = TextEditingController();
  final TextEditingController _yeniIslemController = TextEditingController();

  String? _seciliBolge;
  String? _seciliIl;
  String? _seciliUzmanlik;
  bool _isSaving = false;

  // 🔥 ARAÇ GRUBU ÇOKLU SEÇİM MOTORU
  final List<String> _aracGruplari = [
    'Tüm Markalar',
    'Alman Grubu (BMW, Mercedes, Audi, VW)',
    'Asya Grubu (Toyota, Honda, Hyundai)',
    'Fransız Grubu (Peugeot, Renault)',
    'İtalyan Grubu (Fiat, Alfa Romeo)',
    'Amerikan Grubu (Ford, Chevrolet)',
    'Sadece Tek Marka (Özel Servis)'
  ];
  final Set<String> _seciliAracGruplari = {}; // Tıklananları hafızada tutar

  // Siber Arama Motorunu Koruyan Sabit Liste
  final List<String> _uzmanlikAlanlari = [
    'Mekanik & Motor',
    'Otomatik Şanzıman',
    'Kaporta & Boya',
    'Oto Elektrik & Elektronik',
    'Ekspertiz Merkezi',
    'Yedek Parça Tedariği',
    'Diğer (Yeni İşlem Ekle)' // Deep State Onayına Gider
  ];

  @override
  void dispose() {
    _firmaAdiController.dispose();
    _vergiNoController.dispose();
    _yetkiliKisiController.dispose();
    _telefonController.dispose();
    _tamAdresController.dispose();
    _tanitimController.dispose();
    _yeniIslemController.dispose();
    super.dispose();
  }

  // --- 🔴 FİREBASE: GERÇEK VERİ YAZMA VE KARANTİNA MOTORU ---
  Future<void> _bayiyiAgaKaydet() async {
    if (!_formKey.currentState!.validate()) {
      _siberUyariVer("SİBER İHLAL: Lütfen zorunlu alanları doldurun!", isError: true);
      return;
    }

    if (_seciliBolge == null || _seciliIl == null || _seciliUzmanlik == null) {
      _siberUyariVer("SİBER İHLAL: Bölge, İl ve Uzmanlık Alanı seçimi zorunludur!", isError: true);
      return;
    }

    if (_seciliAracGruplari.isEmpty) {
      _siberUyariVer("SİBER İHLAL: En az bir araç grubu seçmelisiniz!", isError: true);
      return;
    }

    // Özel İşlem Kontrolü
    if (_seciliUzmanlik == 'Diğer (Yeni İşlem Ekle)' && _yeniIslemController.text.trim().isEmpty) {
      _siberUyariVer("SİBER İHLAL: Önermek istediğiniz yeni işlemi yazmalısınız!", isError: true);
      return;
    }

    setState(() => _isSaving = true);
    FocusScope.of(context).unfocus();

    String bayiiID = _vergiNoController.text.trim();
    String nihaiUzmanlik = _seciliUzmanlik == 'Diğer (Yeni İşlem Ekle)' ? 'ONAY BEKLİYOR' : _seciliUzmanlik!;

    try {
      // 1. Bayiyi Kuantum Ağına Mühürle
      await FirebaseFirestore.instance.collection('bayiler').doc(bayiiID).set({
        "firma_adi": _firmaAdiController.text.trim(),
        "vergi_no": bayiiID,
        "yetkili_kisi": _yetkiliKisiController.text.trim(),
        "telefon": _telefonController.text.trim(),
        "merkeze_bagli_mi": _seciliIl == TurkiyeHaritasi.genelMerkez,
        "bolge": _seciliBolge,
        "il": _seciliIl,
        "tam_adres": _tamAdresController.text.trim(),
        "uzmanlik_alani": nihaiUzmanlik,
        "arac_gruplari": _seciliAracGruplari.toList(),
        "tanitim_metni": _tanitimController.text.trim(),
        "aktif_mi": true,
        "onay": false, // Merkez onaylayana kadar vitrinde görünmez
        "puan": 5.0,
        "kayit_tarihi": FieldValue.serverTimestamp(),
      });

      // 2. Yeni İşlem Karantina (Onay) Havuzuna Gönder
      if (_seciliUzmanlik == 'Diğer (Yeni İşlem Ekle)') {
        await FirebaseFirestore.instance.collection('onay_bekleyen_islemler').add({
          "bayi_id": bayiiID,
          "firma_adi": _firmaAdiController.text.trim(),
          "onerilen_islem": _yeniIslemController.text.trim(),
          "tarih": FieldValue.serverTimestamp(),
          "durum": "bekliyor" // Admin Karargahından onay alacak
        });
      }

      if (!mounted) return;
      _siberUyariVer("ONAYLANDI: Bayi Ağa Kaydedildi! (Varsa yeni işlem onaya gönderildi) 🦅", isError: false);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _siberUyariVer("VERİTABANI HATASI: Matriks Bağlantısı Koptu!", isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _siberUyariVer(String mesaj, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: TextStyle(color: isError ? Colors.white : SiberTema.oledBlack, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
        backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.radar, color: SiberTema.kuantumCyan), onPressed: () => Navigator.pop(context)),
          title: Text("DİSTRİBÜTÖR AĞI KURULUMU", style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 2, fontFamily: 'Avenir')),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: Colors.white.withOpacity(0.05), height: 1),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/radar_grid.png'),
              fit: BoxFit.cover,
              opacity: 0.05,
            ),
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  _buildBolumBasligi("FİRMA & KURUM BİLGİLERİ (RESMİ)"),
                  _buildSiberTextField("Gerçek Ticari Ünvan (Örn: Gazi Oto. San. Tic.)", Icons.storefront, _firmaAdiController),
                  _buildSiberTextField("Vergi Kimlik Numarası", Icons.receipt_long, _vergiNoController, isNumber: true),
                  _buildSiberTextField("Yetkili Kişi Ad Soyad", Icons.person_outline, _yetkiliKisiController),
                  _buildSiberTextField("İletişim Numarası", Icons.phone_android, _telefonController, isNumber: true),

                  const SizedBox(height: 20),
                  _buildBolumBasligi("LOKASYON & BÖLGE PROTOKOLÜ"),

                  _buildDropdownContainer(
                    hint: "Faaliyet Bölgesi Seçin",
                    icon: Icons.map,
                    value: _seciliBolge,
                    items: TurkiyeHaritasi.bolgeler,
                    onChanged: (String? yeniBolge) {
                      setState(() {
                        _seciliBolge = yeniBolge;
                        _seciliIl = null;
                      });
                    },
                  ),

                  _buildDropdownContainer(
                    hint: _seciliBolge == null ? "Önce Bölge Seçiniz" : "Merkez İl Seçin",
                    icon: Icons.location_city,
                    value: _seciliIl,
                    items: _seciliBolge != null ? TurkiyeHaritasi.bolgeIlleri[_seciliBolge!]! : [],
                    onChanged: _seciliBolge == null ? null : (String? yeniIl) {
                      setState(() => _seciliIl = yeniIl);
                    },
                  ),

                  _buildSiberTextField("Tam Açık Adres...", Icons.location_on_outlined, _tamAdresController, isMultiline: true),

                  const SizedBox(height: 20),
                  _buildBolumBasligi("ŞEFFAF VİTRİN VE HİZMET AĞI"),

                  // 🛠️ UZMANLIK ALANI SEÇİMİ (KARIŞIKLIĞI ÖNLER)
                  _buildDropdownContainer(
                    hint: "Ana Uzmanlık / Hizmet Türü Seçin",
                    icon: Icons.build_circle_outlined,
                    value: _seciliUzmanlik,
                    items: _uzmanlikAlanlari,
                    onChanged: (String? yeniUzmanlik) {
                      setState(() => _seciliUzmanlik = yeniUzmanlik);
                    },
                  ),

                  // 🛠️ LİSTEDE YOKSA AÇILAN SİBER ONAY KUTUSU
                  if (_seciliUzmanlik == 'Diğer (Yeni İşlem Ekle)') ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                          color: SiberTema.kanKirmizi.withOpacity(0.05),
                          border: Border.all(color: SiberTema.kanKirmizi.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(16)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.security, color: SiberTema.kanKirmizi, size: 18),
                              SizedBox(width: 8),
                              Text("ADMİN ONAYI GEREKİYOR", style: TextStyle(color: SiberTema.kanKirmizi, fontSize: 12, fontWeight: FontWeight.w800, fontFamily: 'Avenir')),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildSiberTextField("Önermek İstediğiniz Özel İşlemi Yazın...", Icons.add_task, _yeniIslemController),
                        ],
                      ),
                    ),
                  ],

                  // 🔥 ARAÇ GRUBU SEÇİMİ (ÇOKLU TIKLAMA)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 12),
                    child: Text("Hizmet Verilen Araç Grupları (Birden fazla seçilebilir):", style: TextStyle(color: SiberTema.kuantumCyan.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                  ),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _aracGruplari.map((grup) {
                      final isSelected = _seciliAracGruplari.contains(grup);
                      return FilterChip(
                        label: Text(grup, style: TextStyle(color: isSelected ? SiberTema.oledBlack : Colors.white70, fontWeight: FontWeight.w700, fontSize: 12, fontFamily: 'Avenir')),
                        selected: isSelected,
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              _seciliAracGruplari.add(grup);
                            } else {
                              _seciliAracGruplari.remove(grup);
                            }
                          });
                        },
                        selectedColor: SiberTema.kuantumCyan,
                        backgroundColor: SiberTema.matGrey,
                        checkmarkColor: SiberTema.oledBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: isSelected ? SiberTema.kuantumCyan : Colors.white.withOpacity(0.1)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // 🛠️ FİRMA ÇALIŞMA ŞEKLİ VE TANITIM VİTRİNİ
                  _buildSiberTextField(
                      "Çalışma şekliniz, koşullarınız ve hizmet detaylarınız hakkında bilgi verin. Bu metin müşteri vitrininde şeffaf olarak görünecektir.",
                      Icons.text_snippet_outlined,
                      _tanitimController,
                      isMultiline: true
                  ),

                  const SizedBox(height: 40),

                  // 🚀 3D FİZYOLOJİK FİREBASE KAYIT BUTONU
                  GestureDetector(
                    onTap: _isSaving ? null : _bayiyiAgaKaydet,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: double.infinity,
                      height: 65,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: _isSaving
                              ? [SiberTema.matGrey, SiberTema.oledBlack]
                              : [SiberTema.kuantumCyan.withOpacity(0.9), SiberTema.kuantumCyan.withOpacity(0.6)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _isSaving ? Colors.white24 : Colors.white.withOpacity(0.5), width: 1.5),
                        boxShadow: _isSaving ? [] : [
                          // Tuşun altındaki karanlık derinlik (3D yükseklik hissi)
                          BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.3), offset: const Offset(0, 8), blurRadius: 15),
                        ],
                      ),
                      child: Center(
                        child: _isSaving
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: SiberTema.oledBlack, strokeWidth: 3))
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_business, size: 24, color: SiberTema.oledBlack),
                            const SizedBox(width: 12),
                            const Text(
                              "BAYİYİ ONAYLA VE AĞA BAĞLA",
                              style: TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1.5, fontFamily: 'Avenir', shadows: [Shadow(color: Colors.white54, blurRadius: 2, offset: Offset(0, 1))]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- 🎨 SİBER GÖRSEL ZIRHLAR (3D VE DERİNLİK EFEKTLERİ) ---

  Widget _buildBolumBasligi(String baslik) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(baslik, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 2, fontFamily: 'Avenir')),
    );
  }

  Widget _buildSiberTextField(String hint, IconData icon, TextEditingController controller, {bool isNumber = false, bool isMultiline = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        // 3D İçeri Çökük (Emboss) Hissi
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [SiberTema.oledBlack, SiberTema.matGrey.withOpacity(0.5)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
        boxShadow: [
          // Dış Kuantum Parlaması
          BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.05), blurRadius: 15, spreadRadius: -2, offset: const Offset(0, 5)),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : (isMultiline ? TextInputType.multiline : TextInputType.text),
        maxLines: isMultiline ? 4 : 1,
        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, fontFamily: 'Avenir', fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          prefixIcon: isMultiline
              ? Padding(padding: const EdgeInsets.only(bottom: 60), child: Icon(icon, color: SiberTema.kuantumCyan, size: 20))
              : Icon(icon, color: SiberTema.kuantumCyan, size: 20),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 13, fontFamily: 'Avenir'),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: (value) {
          if (!isMultiline && (value == null || value.trim().isEmpty)) {
            return "Bu alan boş bırakılamaz";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownContainer({required String hint, required IconData icon, required String? value, required List<String> items, required void Function(String?)? onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        // 3D Dışa Çıkık Panel Hissi
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [SiberTema.matGrey.withOpacity(0.8), SiberTema.oledBlack],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, spreadRadius: 1, offset: const Offset(0, 4)),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          dropdownColor: SiberTema.matGrey,
          icon: const Icon(Icons.arrow_drop_down_circle, color: SiberTema.kuantumCyan),
          hint: Row(children: [Icon(icon, color: SiberTema.kuantumCyan, size: 20), const SizedBox(width: 16), Text(hint, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13, fontFamily: 'Avenir'))]),
          value: value,
          items: items.map((String item) => DropdownMenuItem<String>(value: item, child: Row(children: [Icon(icon, color: SiberTema.kuantumCyan, size: 20), const SizedBox(width: 16), Text(item, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, fontFamily: 'Avenir', fontWeight: FontWeight.w500))]))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}